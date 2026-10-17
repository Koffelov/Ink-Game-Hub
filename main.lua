-- Ishak Hub: Red Light Green Light / Help Players.
-- Set a return point beside the doll before enabling Help Players.
-- No anti-detection guarantee. Pickup support depends on the game's actual prompts.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
assert(localPlayer, "Ishak Hub must run on the client")
local playerGui = localPlayer:WaitForChild("PlayerGui", 10)
assert(playerGui, "Ishak Hub: PlayerGui is unavailable")

local previous = playerGui:FindFirstChild("IshakHub_RLGLHelpPlayers")
if previous and previous:GetAttribute("IshakHubVersion") == 1 then
    local unload = previous:FindFirstChild("Unload")
    if unload and unload:IsA("BindableEvent") then
        unload:Fire()
    end
end

local createHelpPlayers = (function()
-- RLGL rescue controller. Teleport(rootPart, destinationCFrame) is supplied by the host.
-- No remote names or server pickup state are assumed.
return function(config)
    local players = config.Players
    local workspace = config.Workspace
    local localPlayer = config.LocalPlayer
    local library = config.Library
    local waitFor = config.Wait or task.wait
    local spawn = config.Spawn or task.spawn
    local clock = config.Clock or os.clock
    local controller = {}
    local enabled, busy, workerRunning, syncingToggle = false, false, false, false
    local destroyed = false
    local connections = {}
    local generation, enabledCharacter = 0, nil
    local toggle, deathConnection
    local completed, retryAt = {}, {}
    local lastNotice = -math.huge
    local startWorker

    local function child(parent, name)
        return parent and parent:FindFirstChild(name)
    end

    local function isA(instance, className)
        if not instance then return false end
        local ok, result = pcall(function() return instance:IsA(className) end)
        return ok and result == true
    end

    local function currentGame()
        local value = child(child(workspace, "Values"), "CurrentGame")
        return value and value.Value
    end

    local function alive(player)
        local character = player and player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = child(character, "HumanoidRootPart")
        if not character or not character.Parent or not humanoid or humanoid.Health <= 0
            or not root or not root.Parent then
            return nil
        end
        return character, humanoid, root
    end

    local function notice(message)
        if clock() - lastNotice < 5 then return end
        lastNotice = clock()
        pcall(function()
            if config.Notify then config.Notify(message)
            elseif library and library.Notify then library:Notify(message, 4) end
        end)
    end

    local function finishCFrame()
        if type(config.FinishCFrame) ~= "function" then return config.FinishCFrame end
        local ok, destination = pcall(config.FinishCFrame)
        if ok then return destination end
        return nil
    end

    local function syncToggle()
        if syncingToggle or not toggle or not toggle.SetValue then return end
        syncingToggle = true
        pcall(function() toggle:SetValue(enabled) end)
        syncingToggle = false
    end

    local function stop(resetHistory)
        enabled = false
        enabledCharacter = nil
        generation = generation + 1
        if deathConnection then
            pcall(function() deathConnection:Disconnect() end)
            deathConnection = nil
        end
        if resetHistory then completed, retryAt = {}, {} end
        syncToggle()
    end

    local function active(token, character)
        if not enabled or generation ~= token then return false end
        if library and library.Unloaded then controller:Destroy(); return false end
        if currentGame() ~= "RedLightGreenLight" then stop(true); return false end
        if alive(localPlayer) ~= character then stop(false); return false end
        return true
    end

    local function targetModels(player, character)
        local models, seen = {}, {}
        local function add(model)
            if model and not seen[model] then seen[model] = true; models[#models + 1] = model end
        end
        local live = child(workspace, "Live")
        add(character)
        add(child(live, player.Name))
        add(child(child(live, "GreenPlayers"), player.Name))
        return models
    end

    local function injured(player, character)
        for _, model in ipairs(targetModels(player, character)) do
            if child(model, "InjuredWalking") or child(model, "Crawling") then return true end
        end
        return false
    end

    local function isDescendant(part, model)
        local ok, result = pcall(function() return part:IsDescendantOf(model) end)
        return ok and result == true
    end

    local function carrier(targetPlayer, targetRoot)
        local ok, parts = pcall(function() return targetRoot:GetConnectedParts(true) end)
        if not ok or type(parts) ~= "table" then return nil end
        for _, player in ipairs(players:GetPlayers()) do
            local character = player ~= targetPlayer and alive(player)
            if character then
                for _, part in ipairs(parts) do
                    if isDescendant(part, character) then return player end
                end
            end
        end
        return nil
    end

    local function rescuePrompt(player, character)
        for _, model in ipairs(targetModels(player, character)) do
            for _, candidate in ipairs(model:GetDescendants()) do
                if isA(candidate, "ProximityPrompt") and candidate.Enabled then
                    local text = (tostring(candidate.Name) .. " " .. tostring(candidate.ActionText)):lower()
                    text = text:gsub("[%s_%-]", "")
                    if text:find("carry", 1, true) or text:find("pickup", 1, true)
                        or text:find("help", 1, true) or text:find("revive", 1, true)
                        or text:find("rescue", 1, true) then
                        return candidate
                    end
                end
            end
        end
        return nil
    end

    local function promptLocation(prompt, targetRoot)
        local parent = prompt.Parent
        if isA(parent, "Attachment") then return parent.WorldCFrame, parent.WorldPosition end
        if isA(parent, "BasePart") then return parent.CFrame, parent.Position end
        if isA(parent, "Model") then
            local ok, pivot = pcall(function() return parent:GetPivot() end)
            if ok and pivot then return pivot, pivot.Position end
        end
        return targetRoot.CFrame, targetRoot.Position
    end

    local function distance(a, b)
        local ok, result = pcall(function() return (a - b).Magnitude end)
        if ok and type(result) == "number" then return result end
        return math.huge
    end

    local function teleport(root, destination)
        local ok, result = pcall(config.Teleport, root, destination)
        return ok and result ~= false
    end

    local function attempt(player, character, targetRoot, token, localCharacter, localRoot)
        local origin = localRoot.CFrame
        local prompt, originalDuration, inputStarted
        local moved, reachedFinish = false, false
        local ok, outcome = pcall(function()
            if not finishCFrame() then return "finish" end
            if not active(token, localCharacter) then return "cancelled" end
            prompt = rescuePrompt(player, character)
            if not prompt then return "prompt" end
            if carrier(player, targetRoot) then return "taken" end
            local approach, position = promptLocation(prompt, targetRoot)
            moved = true
            if not teleport(localRoot, approach) then return "teleport" end
            waitFor(0.1)
            if not active(token, localCharacter) then return "cancelled" end
            if alive(player) ~= character or not injured(player, character) then return "target" end
            if not prompt.Parent or not prompt.Enabled then return "prompt" end
            if carrier(player, targetRoot) then return "taken" end
            local _, currentPosition = promptLocation(prompt, targetRoot)
            position = currentPosition
            if distance(localRoot.Position, position) > (tonumber(prompt.MaxActivationDistance) or 10) then
                return "range"
            end
            originalDuration = prompt.HoldDuration
            prompt.HoldDuration = 0
            if config.FirePrompt then
                local fired, result = pcall(config.FirePrompt, prompt)
                if not fired or result == false then return "interaction" end
            else
                inputStarted = true
                prompt:InputHoldBegin()
                waitFor(0.03)
                if not active(token, localCharacter) then return "cancelled" end
                prompt:InputHoldEnd()
                inputStarted = false
            end

            local confirmed = false
            local deadline = clock() + (config.PickupTimeout or 1.5)
            for _ = 1, 40 do
                if not active(token, localCharacter) then return "cancelled" end
                if alive(player) ~= character then return "target" end
                local owner = carrier(player, targetRoot)
                if owner == localPlayer then confirmed = true; break end
                if owner then return "taken" end
                if not injured(player, character) then return "recovered" end
                if clock() >= deadline then break end
                waitFor(0.05)
            end
            if not confirmed then return "unconfirmed" end
            if not active(token, localCharacter) then return "cancelled" end
            local destination = finishCFrame()
            if not destination then return "finish" end
            if not teleport(localRoot, destination) then return "teleport" end
            reachedFinish = true
            waitFor(0.1)
            for _ = 1, 10 do
                if not active(token, localCharacter) then return "cancelled" end
                if alive(player) ~= character then return "target" end
                if carrier(player, targetRoot) == localPlayer
                    and distance(localRoot.Position, destination.Position) <= 12
                    and distance(targetRoot.Position, destination.Position) <= 12
                    and distance(targetRoot.Position, localRoot.Position) <= 12 then
                    return "success"
                end
                waitFor(0.05)
            end
            return "follow"
        end)

        -- Cooperative cancellation always reaches this cleanup, including a throwing prompt API.
        if prompt then
            if inputStarted then pcall(function() prompt:InputHoldEnd() end) end
            if originalDuration ~= nil then
                pcall(function() prompt.HoldDuration = originalDuration end)
            end
        end
        if not ok then outcome = "error" end
        -- A cancelled controller must never move a new character or a new round.
        if moved and not reachedFinish and active(token, localCharacter) then
            teleport(localRoot, origin)
        end
        if outcome == "success" then
            completed[character] = true
            return true, outcome
        end
        retryAt[character] = clock() + (config.RetryDelay or 5)
        if outcome == "finish" then notice("Help Players: set the finish location first.")
        elseif outcome == "follow" then notice("Help Players: pickup confirmed, but arrival with the player was not confirmed.")
        elseif outcome ~= "cancelled" and outcome ~= "taken" then
            notice("Help Players: rescue was not confirmed; the attempt stopped.")
        end
        return false, outcome
    end

    function controller:Step(token)
        token = token or generation
        if busy or not active(token, enabledCharacter) then return false, "inactive" end
        local localCharacter, _, localRoot = alive(localPlayer)
        local allPlayers = players:GetPlayers()
        for _, player in ipairs(allPlayers) do
            if player ~= localPlayer then
                local character = alive(player)
                if character and completed[character] and not injured(player, character) then
                    completed[character], retryAt[character] = nil, nil
                end
            end
        end
        if carrier(localPlayer, localRoot) then
            notice("Help Players: drop/release the delivered player before the next rescue.")
            return false, "carrying"
        end
        local nearest, nearestCharacter, nearestRoot, nearestDistance
        for _, player in ipairs(allPlayers) do
            if player ~= localPlayer then
                local character, _, root = alive(player)
                if character and not completed[character] and (retryAt[character] or 0) <= clock()
                    and injured(player, character) and not carrier(player, root) then
                    local gap = distance(root.Position, localRoot.Position)
                    if not nearestDistance or gap < nearestDistance then
                        nearest, nearestCharacter, nearestRoot, nearestDistance = player, character, root, gap
                    end
                end
            end
        end
        if not nearest then return false, "idle" end
        busy = true
        local ok, result, reason = pcall(attempt, nearest, nearestCharacter, nearestRoot,
            token, localCharacter, localRoot)
        busy = false
        if not ok then
            retryAt[nearestCharacter] = clock() + (config.RetryDelay or 5)
            notice("Help Players: the attempt stopped after an interaction error.")
            return false, "error"
        end
        return result, reason
    end

    startWorker = function()
        if workerRunning or not enabled then return end
        workerRunning = true
        local token, character = generation, enabledCharacter
        local spawned = pcall(spawn, function()
            local ok = pcall(function()
                while active(token, character) do
                    controller:Step(token)
                    waitFor(0.2)
                end
            end)
            workerRunning = false
            if not ok then
                stop(false)
                notice("Help Players: the rescue worker stopped after an error.")
            elseif enabled then startWorker() end
        end)
        if not spawned then
            workerRunning = false
            stop(false)
            notice("Help Players: the rescue worker could not start.")
        end
    end

    function controller:SetEnabled(value)
        if not value then stop(false); return false end
        if destroyed then return false end
        if enabled then return true end
        if currentGame() ~= "RedLightGreenLight" or (library and library.Unloaded) then
            notice("Help Players is available during Red Light Green Light.")
            syncToggle()
            return false
        end
        local character, humanoid = alive(localPlayer)
        if not character then syncToggle(); return false end
        if not finishCFrame() then
            notice("Help Players: set the finish location first.")
            syncToggle()
            return false
        end
        enabled, enabledCharacter = true, character
        generation = generation + 1
        if humanoid.Died then
            deathConnection = humanoid.Died:Connect(function() stop(false) end)
        end
        syncToggle()
        startWorker()
        return true
    end

    function controller:Stop()
        stop(false)
    end

    function controller:Destroy()
        if destroyed then return end
        destroyed = true
        stop(false)
        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        connections = {}
    end

    if localPlayer.CharacterAdded then
        connections[#connections + 1] = localPlayer.CharacterAdded:Connect(function() stop(false) end)
    end
    local gameValue = child(child(workspace, "Values"), "CurrentGame")
    if gameValue and gameValue.GetPropertyChangedSignal then
        connections[#connections + 1] = gameValue:GetPropertyChangedSignal("Value"):Connect(function()
            if currentGame() ~= "RedLightGreenLight" then stop(true) end
        end)
    end

    toggle = config.Group:AddToggle("RedLightHelpPlayers", {
        Text = "Help Players",
        Default = false,
        Tooltip = "Rescue injured players and return to your saved finish location. Pickup must be confirmed.",
        Callback = function(value)
            if not syncingToggle then controller:SetEnabled(value) end
        end,
    })
    return controller
end
end)()

local connections = {}
local library = { Unloaded = false }
local savedFinish = nil
local controller = nil
local toggleValue = false
local toggleOptions = nil
local gui = Instance.new("ScreenGui")
gui.Name = "IshakHub_RLGLHelpPlayers"
gui:SetAttribute("IshakHubVersion", 1)
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function make(className, properties, parent)
    local instance = Instance.new(className)
    for key, value in pairs(properties) do
        instance[key] = value
    end
    instance.Parent = parent
    return instance
end

local panel = make("Frame", {
    Size = UDim2.fromOffset(350, 318),
    Position = UDim2.new(0.5, -175, 0.5, -159),
    BackgroundColor3 = Color3.fromRGB(22, 24, 31),
    BorderSizePixel = 0,
    Active = true,
}, gui)
make("UICorner", { CornerRadius = UDim.new(0, 12) }, panel)
make("UIStroke", { Color = Color3.fromRGB(62, 67, 85), Thickness = 1 }, panel)

local header = make("TextLabel", {
    Size = UDim2.new(1, -52, 0, 44),
    Position = UDim2.fromOffset(16, 0),
    BackgroundTransparency = 1,
    Text = "Ishak Hub",
    TextColor3 = Color3.fromRGB(231, 234, 245),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
    Active = true,
}, panel)

local close = make("TextButton", {
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(1, -40, 0, 5),
    BackgroundTransparency = 1,
    Text = "×",
    TextColor3 = Color3.fromRGB(180, 187, 205),
    Font = Enum.Font.Gotham,
    TextSize = 26,
}, panel)

make("TextLabel", {
    Size = UDim2.new(1, -32, 0, 22),
    Position = UDim2.fromOffset(16, 45),
    BackgroundTransparency = 1,
    Text = "Red Light Green Light",
    TextColor3 = Color3.fromRGB(159, 168, 194),
    Font = Enum.Font.GothamMedium,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

local function button(text, top)
    local item = make("TextButton", {
        Size = UDim2.new(1, -32, 0, 38),
        Position = UDim2.fromOffset(16, top),
        BackgroundColor3 = Color3.fromRGB(40, 44, 57),
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Color3.fromRGB(230, 234, 246),
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        AutoButtonColor = true,
    }, panel)
    make("UICorner", { CornerRadius = UDim.new(0, 7) }, item)
    return item
end

local saveButton = button("Сохранить точку у куклы", 79)
local finishButton = button("Телепорт к сохранённой точке", 125)
local toggleButton = button("Help Players: OFF", 171)
local status = make("TextLabel", {
    Size = UDim2.new(1, -32, 0, 70),
    Position = UDim2.fromOffset(16, 220),
    BackgroundTransparency = 1,
    Text = "Встань у куклы и сохрани точку возврата. Z — показать/скрыть меню.",
    TextColor3 = Color3.fromRGB(159, 168, 194),
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
}, panel)

local function notify(message)
    if not library.Unloaded then
        status.Text = message
    end
end

local function inRound()
    local values = Workspace:FindFirstChild("Values")
    local current = values and values:FindFirstChild("CurrentGame")
    return current and current.Value == "RedLightGreenLight"
end

local function rootPart()
    local character = localPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
        return root
    end
    return nil
end

local group = {}
local toggle = {}
function toggle:SetValue(value)
    value = value == true
    if toggleValue == value then
        return
    end
    toggleValue = value
    toggleButton.Text = value and "Help Players: ON" or "Help Players: OFF"
    toggleButton.BackgroundColor3 = value and Color3.fromRGB(51, 91, 67) or Color3.fromRGB(40, 44, 57)
    if toggleOptions then
        toggleOptions.Callback(value)
    end
end

function group:AddToggle(_, options)
    toggleOptions = options
    return toggle
end

controller = createHelpPlayers({
    Players = Players,
    Workspace = Workspace,
    LocalPlayer = localPlayer,
    Library = library,
    Group = group,
    FinishCFrame = function()
        return savedFinish
    end,
    Teleport = function(root, destination)
        root.CFrame = destination
    end,
    FirePrompt = type(fireproximityprompt) == "function" and fireproximityprompt or nil,
    Notify = notify,
})

table.insert(connections, saveButton.Activated:Connect(function()
    if toggleValue then
        notify("Сначала выключи Help Players, затем сохрани новую точку.")
        return
    end
    local root = rootPart()
    if not inRound() or not root then
        notify("Точка сохраняется живым персонажем в Red Light Green Light.")
        return
    end
    savedFinish = root.CFrame
    notify("Точка у куклы сохранена. Можно включить Help Players.")
end))

table.insert(connections, finishButton.Activated:Connect(function()
    if toggleValue then
        notify("Выключи Help Players перед ручным телепортом.")
        return
    end
    local root = rootPart()
    if not inRound() or not savedFinish or not root then
        notify("Сначала сохрани точку в текущем раунде Red Light Green Light.")
        return
    end
    root.CFrame = savedFinish
end))

table.insert(connections, toggleButton.Activated:Connect(function()
    toggle:SetValue(not toggleValue)
end))

local function unload()
    if library.Unloaded then
        return
    end
    library.Unloaded = true
    controller:Destroy()
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    table.clear(connections)
    gui:Destroy()
end

local unloadEvent = make("BindableEvent", { Name = "Unload" }, gui)
table.insert(connections, unloadEvent.Event:Connect(unload))
table.insert(connections, close.Activated:Connect(unload))
table.insert(connections, gui.Destroying:Connect(unload))

local dragInput = nil
local dragStart = nil
local dragPosition = nil
table.insert(connections, header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
        dragStart = input.Position
        dragPosition = panel.Position
    end
end))

table.insert(connections, UserInputService.InputChanged:Connect(function(input)
    if dragInput and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local offset = input.Position - dragStart
        panel.Position = UDim2.new(dragPosition.X.Scale, dragPosition.X.Offset + offset.X, dragPosition.Y.Scale, dragPosition.Y.Offset + offset.Y)
    end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input)
    if input == dragInput then
        dragInput = nil
    end
end))

table.insert(connections, UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and not UserInputService:GetFocusedTextBox() and input.KeyCode == Enum.KeyCode.Z then
        panel.Visible = not panel.Visible
    end
end))

local values = Workspace:FindFirstChild("Values")
local currentGame = values and values:FindFirstChild("CurrentGame")
if currentGame then
    table.insert(connections, currentGame:GetPropertyChangedSignal("Value"):Connect(function()
        if not inRound() then
            savedFinish = nil
            toggle:SetValue(false)
            notify("Раунд завершён. В новом раунде сохрани точку у куклы заново.")
        end
    end))
end
