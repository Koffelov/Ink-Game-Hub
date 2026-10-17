-- Ishak Hub: full HSX base with Help Players, Auto Kill Hiders and Lights Out Auto Hover.
-- Upstream: capitanomoby4-design/hsx-lol @ d39b037a95059d14f36d5f0892ad3a70a8a89957.
local PlayToggleSound, PlayErrorSound
-- leak by uwustudios discord.gg/uwustudios
local Players
Players = game:GetService("Players")
local ReplicatedStorage
ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace
Workspace = game:GetService("Workspace")
local UserInputService
UserInputService = game:GetService("UserInputService")
local CoreGui
CoreGui = game:GetService("CoreGui")
local HttpService
HttpService = game:GetService("HttpService")
game:GetService("Stats")
game:GetService("SoundService")
game:GetService("TweenService")
local RunService
RunService = game:GetService("RunService")
local localPlayer
localPlayer = Players.LocalPlayer
local getupvalues
getupvalues = debug.getupvalues or debug.get_upvalues
local lib, lib2, lib3, fn, png, ogg, ogg2, v, fn2

do
	local setupvalue = debug.setupvalue or debug.setup_value
	local getconstants = debug.getconstants or debug.get_constants
	_G.HSX_RunService = RunService
	_G.HSX_HttpService = HttpService
	lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Koffelov/Ink-Game-Hub/main/library.lua"))()
	lib2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Koffelov/Ink-Game-Hub/main/ThemeManager.lua"))()
	lib3 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Koffelov/Ink-Game-Hub/main/SaveManager.lua"))()
	local options = lib.Options
	local toggles = lib.Toggles
	_G.HSX_SaveManager = lib3
	_G.HSX_ThemeManager = lib2
	_G.HSX_Options = options
	_G.HSX_Toggles = toggles

	local function fn3(arg, arg2)
		return (pcall(function()
			if not writefile then
				return
			end
			local response = game:HttpGet(arg)
			if type(response) ~= "string" or #response < 100 then
				return
			end

			pcall(function()
				if makefolder then
					pcall(makefolder, "HollyScriptX")
				end

				writefile("HollyScriptX/" .. arg2, response)
			end)
		end))
	end

	fn = function(arg)
		local tbl = {}

		pcall(function()
			if getcustomasset then
				table.insert(tbl, getcustomasset)
			end
		end)

		pcall(function()
			if getsynasset then
				table.insert(tbl, getsynasset)
			end
		end)

		pcall(function()
			if getasset then
				table.insert(tbl, getasset)
			end
		end)

		pcall(function()
			if syn and syn.getcustomasset then
				table.insert(tbl, syn.getcustomasset)
			end
		end)

		local tbl2 = { "HollyScriptX/" .. arg, arg }

		for _, v2 in ipairs(tbl) do
			for _, v3 in ipairs(tbl2) do
				local v4 = nil
				if pcall(function()
					v4 = v2(v3)
				end) and type(v4) == "string" and #v4 > 0 then
					return v4
				end
			end
		end

		return nil
	end

	fn3("https://raw.githubusercontent.com/eikikrkr-ux/Obsidian-test-m/main/041e94a72daeb3c9393502ee13430cdf.png", "Holy.png")
	png = fn("Holy.png")
	fn3("https://raw.githubusercontent.com/wwxohzxc1337-droid/ewngEHWIJFKELG/main/2026-09-12-03-09-48.ogg", "HSX_Toggle.ogg")
	ogg = fn("HSX_Toggle.ogg")
	fn3("https://raw.githubusercontent.com/wwxohzxc1337-droid/ewngEHWIJFKELG/main/2026-09-12-03-20-58.ogg", "HSX_Failed.ogg")
	ogg2 = fn("HSX_Failed.ogg")

	local function fn4()
		local ok, result = pcall(function()
			return game:GetService("HttpService"):GenerateGUID(false)
		end)

		return ok and result or "S" .. tostring(math.random(100000, 999999))
	end

	v = fn4()
	MainModule = MainModule or {}
	MainModule.Keybinds = MainModule.Keybinds or {}
-- Coordinate Instant Interact with the normal hold used by Help Players.
do
    local createPromptInteraction = (function()
-- Local prompt-duration broker. A lease keeps one prompt at its recorded native duration.
-- The host owns the broker lifetime; setting HoldDuration locally does not promise server acceptance.
return function(config)
    local workspace = config.Workspace
    local originals = setmetatable({}, { __mode = "k" })
    local leases = setmetatable({}, { __mode = "k" })
    local instant, destroyed = false, false
    local addedConnection
    local broker = {}

    local function isPrompt(prompt)
        if not prompt then return false end
        local ok, result = pcall(function() return prompt:IsA("ProximityPrompt") end)
        return ok and result == true
    end

    local function writeDuration(prompt, duration)
        return pcall(function() prompt.HoldDuration = duration end)
    end

    local function remember(prompt)
        if originals[prompt] ~= nil then return originals[prompt] end
        local ok, duration = pcall(function() return prompt.HoldDuration end)
        if not ok or type(duration) ~= "number" or duration ~= duration
            or duration < 0 or duration == math.huge then
            return nil
        end
        originals[prompt] = duration
        return duration
    end

    local function applyInstant(prompt)
        if leases[prompt] or not isPrompt(prompt) then return end
        if remember(prompt) ~= nil then writeDuration(prompt, 0) end
    end

    local function disconnectAdded()
        local connection = addedConnection
        addedConnection = nil
        if connection then pcall(function() connection:Disconnect() end) end
    end

    local function restoreUnleased()
        for prompt, duration in pairs(originals) do
            if not leases[prompt] then
                writeDuration(prompt, duration)
                originals[prompt] = nil
            end
        end
    end

    function broker:SetInstant(value)
        if destroyed then return false end
        local requested = value and true or false
        if instant == requested then return true end
        instant = requested
        if not instant then
            disconnectAdded()
            restoreUnleased()
            return true
        end

        -- Subscribe before enumerating so prompts added during discovery are covered.
        local connected, connection = pcall(function()
            return workspace.DescendantAdded:Connect(function(prompt)
                if instant and not destroyed then applyInstant(prompt) end
            end)
        end)
        if not connected or not connection then
            instant = false
            return false
        end
        addedConnection = connection

        local listed, descendants = pcall(function() return workspace:GetDescendants() end)
        if not listed or type(descendants) ~= "table" then
            instant = false
            disconnectAdded()
            restoreUnleased()
            return false
        end
        for _, prompt in ipairs(descendants) do applyInstant(prompt) end
        return true
    end

    function broker:Acquire(prompt)
        if destroyed or not isPrompt(prompt) or leases[prompt] then return nil end
        local duration = remember(prompt)
        if duration == nil then return nil end
        if not writeDuration(prompt, duration) then
            if not instant then originals[prompt] = nil end
            return nil
        end

        -- Registry tokens do not retain the prompt; only the caller's live lease does.
        local token = { Released = false }
        leases[prompt] = token
        local lease = { Duration = duration }
        function lease.Release()
            if token.Released then return false end
            token.Released = true
            if leases[prompt] ~= token then return false end
            leases[prompt] = nil
            local nativeDuration = originals[prompt]
            if nativeDuration == nil then return true end
            if instant and not destroyed then
                return writeDuration(prompt, 0)
            end
            originals[prompt] = nil
            return writeDuration(prompt, nativeDuration)
        end
        return lease
    end

    function broker:Destroy()
        if destroyed then return end
        destroyed = true
        instant = false
        disconnectAdded()
        -- Active leases remain native until their holders perform release cleanup.
        restoreUnleased()
    end

    return broker
end
    end)()
    if MainModule.AutoKillHidersController then
        pcall(function() MainModule.AutoKillHidersController:Destroy() end)
        MainModule.AutoKillHidersController = nil
    end
    if MainModule.LightsOutHoverController then
        pcall(function() MainModule.LightsOutHoverController:Destroy() end)
        MainModule.LightsOutHoverController = nil
    end
    if MainModule.HelpPlayersController then
        pcall(function() MainModule.HelpPlayersController:Destroy() end)
        MainModule.HelpPlayersController = nil
    end
    if MainModule.PromptInteraction then
        pcall(function() MainModule.PromptInteraction:Destroy() end)
    end
    if MainModule.ProximityConnection then
        pcall(function() MainModule.ProximityConnection:Disconnect() end)
        MainModule.ProximityConnection = nil
    end
    local promptInteraction = createPromptInteraction({ Workspace = Workspace })
    MainModule.PromptInteraction = promptInteraction
    if type(lib.OnUnload) == "function" then
        lib:OnUnload(function() promptInteraction:Destroy() end)
    end
end

	MainModule._KeybindPress = MainModule._KeybindPress or {}

	fn2 = function(arg, arg2, arg3)
		local n = 0.9
		local str, str2

		if type(arg) == "table" then
			str = tostring(arg.Title or arg.title or "Ishak Hub")
			str2 = tostring(arg.Description or arg.Content or arg.text or arg.Desc or "")
			n = tonumber(arg.Duration or arg.duration) or 0.9
		else
			str = "Ishak Hub"
			str2 = ""

			if type(arg) == "string" then
				str2 = tostring(arg2 or "")
				n = tonumber(arg3) or 0.9
				str = arg
			end
		end

		local str3 = str2 ~= "" and str .. " | " .. str2 or str

		pcall(function()
			if lib.Notify then
				lib:Notify(str3, n)
			end
		end)
	end

	lib.SetNotifySide = function(arg, notifySide)
		pcall(function()
			if lib.NotifySide ~= nil then
				lib.NotifySide = notifySide
			end
		end)
	end

	MainModule._HSX_Side = {}

	MainModule.wrapGroupbox = function(arg)
		return {
			_raw = arg,
			AddToggle = function(arg2, arg3, arg4)
				local v2 = arg:AddToggle(arg3, arg4 or {})

				if MainModule.ToggleRefs then
					MainModule.ToggleRefs[arg3] = v2
				end

				MainModule._AllToggleRefs = MainModule._AllToggleRefs or {}
				MainModule._AllToggleRefs[arg3] = v2
				return v2
			end,
			AddCheckbox = function(arg2, arg3, arg4)
				if arg.AddCheckbox then
					return arg:AddCheckbox(arg3, arg4)
				end
				return arg2:AddToggle(arg3, arg4)
			end,
			AddSlider = function(arg2, arg3, arg4)
				return arg:AddSlider(arg3, arg4)
			end,
			AddDropdown = function(arg2, arg3, arg4)
				return arg:AddDropdown(arg3, arg4)
			end,
			AddInput = function(arg2, arg3, arg4)
				return arg:AddInput(arg3, arg4)
			end,
			AddButton = function(arg2, arg3)
				return arg:AddButton(arg3)
			end,
			AddLabel = function(arg2, arg3)
				return arg:AddLabel(arg3)
			end,
			AddDivider = function()
				if arg.AddDivider then
					return arg:AddDivider()
				end
			end,
			Checkbox = function(arg2, arg3)
				local tbl = arg3 or {}
				local str = tostring(tbl.Id or tbl.Title or "C" .. math.random(100000, 999999)):gsub("%s+", "")
				local callback = tbl.Callback

				local tbl2 = {
					Text = tbl.Title or str,
					Default = tbl.Value and true or false,
					Tooltip = tbl.Desc or tbl.Tooltip,
					Callback = function(arg4)
						if MainModule and MainModule._SuppressUI then
							return
						end

						if callback then
							pcall(callback, arg4)
						end
					end,
				}

				local v2

				if arg.AddCheckbox then
					v2 = arg:AddCheckbox(str, tbl2)
				else
					v2 = arg:AddToggle(str, tbl2)
				end

				if MainModule.ToggleRefs then
					MainModule.ToggleRefs[str] = v2
				end

				MainModule._AllToggleRefs = MainModule._AllToggleRefs or {}
				MainModule._AllToggleRefs[str] = v2
				return v2
			end,
			Toggle = function(arg2, arg3)
				local tbl = arg3 or {}
				local str = tostring(tbl.Id or tbl.Title or "T" .. math.random(100000, 999999)):gsub("%s+", "")
				local callback = tbl.Callback

				local v2 = arg:AddToggle(str, {
					Text = tbl.Title or str,
					Default = tbl.Value and true or false,
					Tooltip = tbl.Desc or tbl.Tooltip,
					Callback = function(arg4)
						if MainModule and MainModule._SuppressUI then
							return
						end

						if callback then
							pcall(callback, arg4)
						end
					end,
				})

				if MainModule.ToggleRefs then
					MainModule.ToggleRefs[str] = v2
				end

				MainModule._AllToggleRefs = MainModule._AllToggleRefs or {}
				MainModule._AllToggleRefs[str] = v2
				return v2
			end,
			Button = function(arg2, arg3)
				if type(arg3) == "string" then
					local v2 = arg3

					return function(arg4, arg5)
						return arg:AddButton({
							Text = v2,
							Func = function()
								if arg5 then
									pcall(arg5)
								end
							end,
						})
					end
				end

				arg3 = arg3 or {}

				return arg:AddButton({
					Text = arg3.Title or arg3.Text or "Button",
					Func = function()
						if arg3.Callback then
							pcall(arg3.Callback)
						end
					end,
					Tooltip = arg3.Desc or arg3.Tooltip,
				})
			end,
			Slider = function(arg2, arg3)
				local tbl = arg3 or {}
				local str = tostring(tbl.Id or tbl.Title or "S" .. math.random(100000, 999999)):gsub("%s+", "")
				local tbl2 = tbl.Value or {}
				local min = tbl2.Min or tbl.Min or 0
				local max = tbl2.Max or tbl.Max or 100
				local default = tbl2.Default or tbl.Default or min
				local callback = tbl.Callback

				return arg:AddSlider(str, {
					Text = tbl.Title or str,
					Default = default,
					Min = min,
					Max = max,
					Rounding = tbl.Step and (tbl.Step < 1 and 1 or 0) or 0,
					Callback = function(arg4)
						if callback then
							pcall(callback, arg4)
						end
					end,
				})
			end,
			Dropdown = function(arg2, arg3)
				local tbl = arg3 or {}
				local str = tostring(tbl.Id or tbl.Title or "D" .. math.random(100000, 999999)):gsub("%s+", "")
				local callback = tbl.Callback

				return arg:AddDropdown(str, {
					Text = tbl.Title or str,
					Values = tbl.Values or {},
					Default = tbl.Value or tbl.Default,
					Callback = function(arg4)
						if callback then
							pcall(callback, arg4)
						end
					end,
				})
			end,
			Input = function(arg2, arg3)
				local tbl = arg3 or {}
				local str = tostring(tbl.Id or tbl.Title or "I" .. math.random(100000, 999999)):gsub("%s+", "")
				local callback = tbl.Callback

				return arg:AddInput(str, {
					Text = tbl.Title or str,
					Default = tbl.Value or tbl.Default or "",
					Placeholder = tbl.Placeholder,
					Callback = function(arg4)
						if callback then
							pcall(callback, arg4)
						end
					end,
				})
			end,
			Paragraph = function(arg2, arg3)
				local tbl = arg3 or {}
				local flag = type(tbl) == "string" and tbl
				local title

				if flag then
					title = flag
				else
					title = tbl.Title or tbl.Text or ""
				end

				local v2 = arg:AddLabel(tostring(title))

				v2.SetTitle = function(arg4, arg5)
					pcall(function()
						if v2.SetText then
							v2:SetText(arg5)
						end
					end)
				end

				return v2
			end,
			Colorpicker = function(arg2, arg3)
				local tbl = arg3 or {}
				local str = tostring(tbl.Id or tbl.Title or "C" .. math.random(100000, 999999)):gsub("%s+", ""):gsub("[^%w_]", "")
				local callback = tbl.Callback
				local default = tbl.Default or tbl.Value or Color3.fromRGB(255, 255, 255)
				local title = tbl.Title or str
				local v2 = nil

				pcall(function()
					v2 = arg:AddLabel(title):AddColorPicker(str, {
						Default = default,
						Title = title,
						Callback = function(arg4)
							if callback then
								pcall(callback, arg4)
							end
						end,
					})
				end)

				return v2
			end,
			Keybind = function(arg2, arg3)
				local tbl = arg3 or {}
				local str = tostring(tbl.Id or tbl.Title or "K" .. math.random(100000, 999999)):gsub("%s+", "")
				local callback = tbl.Callback
				local v2 = arg:AddLabel(tbl.Title or str)
				local v3 = nil

				pcall(function()
					v3 = v2:AddKeyPicker(str, {
						Default = tbl.Value or tbl.Default or "None",
						Mode = "Hold",
						Text = tbl.Title or str,
						NoUI = tbl.NoUI ~= false,
						Callback = function(arg4)
							if callback then
								local name = typeof(arg4) == "EnumItem" and arg4.Name or tostring(arg4)
								if name == "true" or name == "false" then
									return
								end
								pcall(callback, name)
							end
						end,
					})
				end)

				return v3 or v2
			end,
			AddKeyPicker = function(arg2, arg3, arg4)
				return arg:AddLabel(arg4 and arg4.Text or arg3):AddKeyPicker(arg3, arg4)
			end,
		}
	end

	MainModule.wrapTab = function(arg)
		local n = 0

		return {
			_raw = arg,
			AddLeftGroupbox = function(arg2, arg3, arg4)
				return MainModule.wrapGroupbox(arg:AddLeftGroupbox(arg3, arg4))
			end,
			AddRightGroupbox = function(arg2, arg3, arg4)
				return MainModule.wrapGroupbox(arg:AddRightGroupbox(arg3, arg4))
			end,
			Section = function(arg2, arg3)
				local tbl = arg3 or {}
				local title = tbl.Title or "Section"
				local icon = tbl.Icon
				n += 1
				local v2

				if n % 2 == 1 then
					v2 = arg:AddLeftGroupbox(title, icon)
				else
					v2 = arg:AddRightGroupbox(title, icon)
				end

				return MainModule.wrapGroupbox(v2)
			end,
		}
	end

	MainModule.ToggleRefs = MainModule.ToggleRefs or {}
	MainModule.ToggleGameRequirements = MainModule.ToggleGameRequirements or {}
	MainModule.guiCreated = false
	MainModule.pendingNotifications = {}

	_G.HSX_SafeDestroy = function(arg)
		if arg and arg.Parent then
			pcall(function()
				arg:Destroy()
			end)
		end
	end

	_G.HSX_GetDistance = function(arg, arg2)
		return (arg - arg2).Magnitude
	end

	MainModule = MainModule or {}

	MainModule.get_character = function()
		return localPlayer.Character
	end

	MainModule.get_humanoid = function(arg)
		return arg and arg:FindFirstChildOfClass("Humanoid")
	end

	MainModule.get_root_part = function(arg)
		return arg and arg:FindFirstChild("HumanoidRootPart")
	end

	local function fn5()
		local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
		if not playerGui then
			return
		end
		local hollyScriptXCursor = playerGui:FindFirstChild("HollyScriptX_Cursor")

		if hollyScriptXCursor then
			hollyScriptXCursor:Destroy()
		end
	end

	fn5()

	local function fn6()
		local tbl = {}

		for _, v2 in ipairs({
			"rbxassetid://104315907592805",
			"rbxassetid://108984896666483",
			"rbxassetid://137039654355633",
			"rbxassetid://78566751748949",
			"rbxassetid://91827823102469",
			"rbxassetid://104648030814650",
			"rbxassetid://131646387432374",
		}) do
			tbl[v2] = true
			local str = v2:gsub("%D", "")

			if str ~= "" then
				tbl[str] = true
			end
		end

		local function fn7(arg)
			local str = tostring(arg or "")
			if tbl[str] then
				return true
			end
			local str2 = str:gsub("%D", "")
			return str2 ~= "" and tbl[str2] == true
		end

		local function fn8(arg)
			if not arg or not arg:IsA("Sound") then
				return
			end

			pcall(function()
				if fn7(arg.SoundId) then
					arg.Volume = 0

					pcall(function()
						arg:Stop()
					end)
				end
			end)
		end

		pcall(function()
			local v2 = ipairs
			local SoundService = game:GetService("SoundService")

			for _, descendant in v2(SoundService:GetDescendants()) do
				fn8(descendant)
			end
		end)

		pcall(function()
			for _, descendant in ipairs(workspace:GetDescendants()) do
				fn8(descendant)
			end
		end)

		pcall(function()
			local modules = ReplicatedStorage:FindFirstChild("Modules")
			modules = modules and modules:FindFirstChild("PlayableArcadeGame")
			modules = modules and modules:FindFirstChild("Games")
			local mario = modules and modules:FindFirstChild("Mario")
			mario = mario and mario:FindFirstChild("SFX")

			if mario then
				for _, descendant in ipairs(mario:GetDescendants()) do
					if descendant:IsA("Sound") then
						pcall(function()
							descendant.Volume = 0

							pcall(function()
								descendant:Stop()
							end)
						end)
					end
				end
			end
		end)

		pcall(function()
			game:GetService("SoundService").DescendantAdded:Connect(function(descendant)
				fn8(descendant)
			end)
		end)

		pcall(function()
			workspace.DescendantAdded:Connect(function(descendant)
				fn8(descendant)
			end)
		end)
	end

	fn6()

	MainModule.is_xeno_executor = function()
		if identifyexecutor and type(identifyexecutor) == "function" then
			local str = identifyexecutor():lower()
			if str:find("xeno") or str:find("Xeno") then
				return true
			end
		end

		return false
	end

	MainModule.is_potassium_executor = function()
		if identifyexecutor and type(identifyexecutor) == "function" then
			if identifyexecutor():lower():find("potassium") then
				return true
			end
		end

		return false
	end

	MainModule.is_feature_supported = function(arg)
		if MainModule.is_xeno_executor() then
			for _, v2 in ipairs({ "AutoDodge", "FreeGuard", "AutoQTE", "Desync" }) do
				if v2 == arg then
					return false
				end
			end
		end

		if MainModule.is_potassium_executor() then
			for _, v2 in ipairs({ "ArcadeAutoFarm", "AutoFarm" }) do
				if v2 == arg then
					return false
				end
			end
		end

		return true
	end

	MainModule.update_toggle_availability = function(arg, arg2, arg3)
		local flag = true

		if arg2 then
			flag = MainModule.is_game_active and MainModule.is_game_active(arg2) or false
		end

		local flag2 = true

		if MainModule.is_feature_supported then
			flag2 = MainModule.is_feature_supported(arg)
		end

		local flag3 = arg2 ~= nil and not flag or not flag2
		MainModule.ToggleGameRequirements = MainModule.ToggleGameRequirements or {}

		if arg2 then
			MainModule.ToggleGameRequirements[arg] = arg2
		end

		local tbl = { arg3 }

		if MainModule.ToggleRefs and MainModule.ToggleRefs[arg] then
			table.insert(tbl, MainModule.ToggleRefs[arg])
		end

		if MainModule._AllToggleRefs and MainModule._AllToggleRefs[arg] then
			table.insert(tbl, MainModule._AllToggleRefs[arg])
		end

		for _, v2 in ipairs(tbl) do
			if v2 then
				if flag3 then
					pcall(function()
						if v2.SetDisabled then
							v2:SetDisabled(true)
						end
					end)

					pcall(function()
						if v2.SetValue then
							v2:SetValue(false)
						end
					end)

					pcall(function()
						if v2.Set then
							v2:Set(false)
						end
					end)
				else
					pcall(function()
						if v2.SetDisabled then
							v2:SetDisabled(false)
						end
					end)
				end
			end
		end
	end

	MainModule.notify = function(arg, arg2, arg3)
		local n = tonumber(arg3) or 0.9

		if MainModule.guiCreated then
			fn2({ Title = arg, Description = arg2, Duration = n })
		else
			table.insert(MainModule.pendingNotifications, { title = arg, text = arg2, duration = n })

			pcall(function()
				fn2({ Title = arg, Description = arg2, Duration = n })
			end)
		end
	end

	MainModule.SpectateModeEnabled = false

	MainModule.toggle_spectate_mode = function(arg)
		local spectateModeEnabled = arg and true or false
		MainModule.SpectateModeEnabled = spectateModeEnabled

		pcall(function()
			local values = workspace:FindFirstChild("Values")
			if not values then
				return
			end
			local canSpectateIfWonGame = values:FindFirstChild("CanSpectateIfWonGame")

			if canSpectateIfWonGame and canSpectateIfWonGame:IsA("ValueBase") then
				canSpectateIfWonGame.Value = spectateModeEnabled
			end
		end)

		PlayToggleSound()
		return true
	end

	MainModule.RapidFireEnabled = false
	MainModule.OriginalFireRates = {}
	MainModule.RapidFireConnection = nil

	MainModule.toggle_rapid_fire = function(rapidFireEnabled)
		MainModule.RapidFireEnabled = rapidFireEnabled

		if rapidFireEnabled then
			if MainModule.RapidFireConnection then
				return
			end

			MainModule.RapidFireConnection = RunService.Heartbeat:Connect(function()
				if not MainModule.RapidFireEnabled then
					return
				end

				pcall(function()
					local weapons = ReplicatedStorage:FindFirstChild("Weapons")

					if weapons and weapons:FindFirstChild("Guns") then
						for _, descendant in pairs(weapons.Guns:GetDescendants()) do
							if descendant.Name == "FireRateCD" and (descendant:IsA("NumberValue") or descendant:IsA("IntValue")) then
								if not MainModule.OriginalFireRates[descendant] then
									MainModule.OriginalFireRates[descendant] = descendant.Value
								end

								descendant.Value = 0
							end
						end
					end

					local getCharacter = MainModule.get_character and MainModule.get_character() or MainModule.GetCharacter and MainModule.GetCharacter()

					if getCharacter then
						for _, child in pairs(getCharacter:GetChildren()) do
							if child:IsA("Tool") then
								for _, descendant in pairs(child:GetDescendants()) do
									if descendant.Name == "FireRateCD" and (descendant:IsA("NumberValue") or descendant:IsA("IntValue")) then
										if not MainModule.OriginalFireRates[descendant] then
											MainModule.OriginalFireRates[descendant] = descendant.Value
										end

										descendant.Value = 0
									end
								end
							end
						end
					end
				end)
			end)
		else
			if MainModule.RapidFireConnection then
				MainModule.RapidFireConnection:Disconnect()
				MainModule.RapidFireConnection = nil
			end

			for k, originalFireRate in pairs(MainModule.OriginalFireRates) do
				if k and k.Parent then
					k.Value = originalFireRate
				else
					MainModule.OriginalFireRates[k] = nil
				end
			end

			MainModule.OriginalFireRates = {}
		end

		if MainModule.ToggleRefs.RapidFire then
			MainModule.ToggleRefs.RapidFire:SetValue(rapidFireEnabled)
		end

		PlayToggleSound()
	end

	MainModule.ArcadeAutoFarmEnabled = false
	MainModule.ArcadeAutoFarmTask = nil
	MainModule.ArcadeCurrentGame = nil
	MainModule.ArcadeConsoleCache = nil

	local function fn7()
		if MainModule.ArcadeConsoleCache and MainModule.ArcadeConsoleCache.Parent then
			return MainModule.ArcadeConsoleCache
		end

		for _, v2 in workspace:GetDescendants() do
			local screen = v2:FindFirstChild("Screen")
			if screen and screen:FindFirstChild("SurfaceGui") then
				MainModule.ArcadeConsoleCache = v2
				return v2
			end
		end

		return nil
	end

	local function fn8()
		local ok, result = pcall(function()
			return require(ReplicatedStorage.Modules.PlayableArcadeGame)
		end)

		if not ok or not result then
			return
		end
		local v2 = fn7()
		if not v2 then
			return
		end
		local character = localPlayer.Character
		if not character then
			return
		end
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			return
		end

		if MainModule.ArcadeCurrentGame then
			pcall(function()
				MainModule.ArcadeCurrentGame.Stopping = true
				MainModule.ArcadeCurrentGame:Destroy()
			end)

			MainModule.ArcadeCurrentGame = nil
		end

		local v3 = result.new(v2, humanoidRootPart)
		MainModule.ArcadeCurrentGame = v3
		v3:start()
		local now = os.clock()

		while v3.State ~= "Running" and os.clock() - now < 3 do
			if not MainModule.ArcadeAutoFarmEnabled then
				return
			end
			task.wait()
		end

		if not MainModule.ArcadeAutoFarmEnabled then
			return
		end

		if v3.State ~= "Running" then
			pcall(function()
				v3:Destroy()
			end)

			MainModule.ArcadeCurrentGame = nil
			return
		end

		v3.Score = 4499

		if v3.ScoreLabel then
			v3.ScoreLabel.Text = "Score: 4499"
		end

		table.clear(v3.CalculateScore)

		for i = 1, 99 do
			table.insert(v3.CalculateScore, "Coin")
		end

		v3:win("You Won! Congrats! :D")
	end

	MainModule.toggle_arcade_auto_farm = function(arg)
		local arcadeAutoFarmEnabled = arg and true or false

		if arcadeAutoFarmEnabled then
			if MainModule.is_potassium_executor and MainModule.is_potassium_executor() then
				pcall(function()
					fn2("Auto Farm", "This feature is not available in your executor", 1.2)
				end)

				MainModule.ArcadeAutoFarmEnabled = false

				if MainModule.ToggleRefs and MainModule.ToggleRefs.ArcadeAutoFarm then
					pcall(function()
						MainModule.ToggleRefs.ArcadeAutoFarm:SetValue(false)
					end)
				end

				if PlayToggleSound then
					PlayToggleSound()
				end

				return false
			end

			if HSX_IsPlayerAttr and HSX_IsGuardPlayer then
				if HSX_IsPlayerAttr() and not HSX_IsGuardPlayer() then
					pcall(function()
						fn2("Auto Farm", "You need to be a guard to use this function", 1.2)
					end)

					MainModule.ArcadeAutoFarmEnabled = false

					if MainModule.ToggleRefs and MainModule.ToggleRefs.ArcadeAutoFarm then
						pcall(function()
							MainModule.ToggleRefs.ArcadeAutoFarm:SetValue(false)
						end)
					end

					if PlayToggleSound then
						PlayToggleSound()
					end

					return false
				end

				if not HSX_IsGuardPlayer() then
					pcall(function()
						fn2("Auto Farm", "You need to be a guard to use this function", 1.2)
					end)

					MainModule.ArcadeAutoFarmEnabled = false

					if MainModule.ToggleRefs and MainModule.ToggleRefs.ArcadeAutoFarm then
						pcall(function()
							MainModule.ToggleRefs.ArcadeAutoFarm:SetValue(false)
						end)
					end

					if PlayToggleSound then
						PlayToggleSound()
					end

					return false
				end
			end
		end

		MainModule.ArcadeAutoFarmEnabled = arcadeAutoFarmEnabled

		if MainModule.ArcadeAutoFarmTask then
			pcall(function()
				task.cancel(MainModule.ArcadeAutoFarmTask)
			end)

			MainModule.ArcadeAutoFarmTask = nil
		end

		if not arcadeAutoFarmEnabled then
			if MainModule.ArcadeCurrentGame then
				pcall(function()
					MainModule.ArcadeCurrentGame.Stopping = true
					MainModule.ArcadeCurrentGame:Destroy()
				end)

				MainModule.ArcadeCurrentGame = nil
			end

			if PlayToggleSound then
				PlayToggleSound()
			end

			return true
		end

		MainModule.ArcadeAutoFarmTask = task.spawn(function()
			while MainModule.ArcadeAutoFarmEnabled do
				pcall(fn8)
				if MainModule.ArcadeAutoFarmEnabled then
					task.wait(1)
					continue
				end
				break
			end

			MainModule.ArcadeAutoFarmTask = nil
		end)

		if PlayToggleSound then
			PlayToggleSound()
		end

		return true
	end

	MainModule.AutoPunchEnabled = false
	MainModule._AutoPunchOriginal = nil

	MainModule.toggle_auto_punch = function(arg)
		local autoPunchEnabled = arg and true or false

		if autoPunchEnabled then
			local flag = false

			for _, v2 in ipairs({ "IsGuard", "isGuard", "Isguard" }) do
				local attribute = localPlayer:GetAttribute(v2)
				if attribute == true or attribute == 1 or attribute == "true" then
					flag = true
					break
				end
			end

			if not flag then
				pcall(function()
					fn2("Auto Punch Machine", "You need to be a guard to use this function", 1.2)
				end)

				MainModule.AutoPunchEnabled = false

				if MainModule.ToggleRefs and MainModule.ToggleRefs.AutoPunch then
					pcall(function()
						MainModule.ToggleRefs.AutoPunch:SetValue(false)
					end)
				end

				if PlayToggleSound then
					PlayToggleSound()
				end

				return false
			end
		end

		MainModule.AutoPunchEnabled = autoPunchEnabled

		local ok, result = pcall(function()
			return require(game:GetService("ReplicatedStorage").Modules.StrengthTester)
		end)

		if not ok or type(result) ~= "table" then
			if PlayToggleSound then
				PlayToggleSound()
			end

			return false
		end

		if autoPunchEnabled then
			if not MainModule._AutoPunchOriginal then
				MainModule._AutoPunchOriginal = result.Start
			end

			result.Start = function(arg2)
				local v2 = MainModule._AutoPunchOriginal(arg2)

				if typeof(arg2) == "table" and arg2.SpinComplete then
					task.delay(0.1, function()
						if MainModule.AutoPunchEnabled and arg2.SpinComplete and arg2.SpinComplete.Parent then
							pcall(function()
								arg2.SpinComplete:Fire({ PowerLevel = 5, Percent = 100, QteSuccess = true })
							end)
						end
					end)
				end

				return v2
			end
		elseif MainModule._AutoPunchOriginal then
			result.Start = MainModule._AutoPunchOriginal
			MainModule._AutoPunchOriginal = nil
		end

		if PlayToggleSound then
			PlayToggleSound()
		end

		return true
	end

	MainModule.PentathlonThreads = {}
	MainModule.PentathlonConnections = {}
	MainModule.PentathlonStates = {}
	local v2 = nil
	local tbl = { val = false, time = 0 }

	local function fn9()
		local character = localPlayer.Character
		if not character then
			return nil
		end

		local ok, result = pcall(function()
			for _, v3 in ipairs(getgc(true)) do
				if type(v3) == "table" and rawget(v3, "GUID") and rawget(v3, "Players") and rawget(v3, "Active") then
					local value = rawget(v3, "Players")
					if type(value) ~= "table" then
						continue
					end

					for _, v4 in pairs(value) do
						if v4 == character then
							return v3
						end
					end
				end
			end

			return nil
		end)

		return ok and result or nil
	end

	local function fn10()
		if v2 then
			return v2
		end
		v2 = fn9()
		return v2
	end

	local function fn11()
		local time = tbl.time

		if tick() - time > 0.5 then
			tbl.time = tick()
			tbl.val = localPlayer:GetAttribute("InPentathlon") == true or Workspace:FindFirstChild("PentathlonMap") ~= nil
		end

		return tbl.val
	end

	local function fn12()
		local ok, result = pcall(function()
			return require(ReplicatedStorage.Modules.Games.PentathlonClient)
		end)

		return ok and result or nil
	end

	local function fn13(arg)
		local v3 = MainModule.PentathlonThreads[arg]

		if v3 then
			pcall(task.cancel, v3)
			MainModule.PentathlonThreads[arg] = nil
		end

		local v4 = MainModule.PentathlonConnections[arg]

		if v4 and typeof(v4) == "RBXScriptConnection" then
			pcall(function()
				v4:Disconnect()
			end)
		end

		MainModule.PentathlonConnections[arg] = nil
		MainModule.PentathlonStates[arg] = nil
	end

	MainModule.StopPentathlonauto1 = function()
		fn13("Ddakji")
	end

	MainModule.StopPentathlonauto2 = function()
		fn13("FlyingStone")
	end

	MainModule.StopPentathlonauto3 = function()
		fn13("Gonggi")
	end

	MainModule.StopPentathlonauto4 = function()
		fn13("SpinningTop")
	end

	MainModule.StopPentathlonauto5 = function()
		fn13("Jegi")
	end

	task.spawn(function()
		while true do
			task.wait(1)

			if v2 and not fn11() then
				v2 = nil
			end
		end
	end)

	MainModule.AutoDdakji = false

	MainModule.toggle_auto_ddakji = function(autoDdakji)
		if autoDdakji then
			if MainModule.is_game_active and not MainModule.is_game_active("Pentathlon") then
				MainModule.notify("Auto Ddakji", "Wait for Pentathlon!", 0.9)
				PlayErrorSound()
				return
			end
		end

		MainModule.StopPentathlonauto1()
		MainModule.AutoDdakji = autoDdakji

		if autoDdakji then
			local v3 = fn12()
			if not v3 then
				PlayToggleSound()
				return
			end
			local n = 0.95123884995606622
			local vector = Vector3.new(-147.3337, 6001.0757, -19.965336)
			local n2 = 0

			MainModule.PentathlonThreads.Ddakji = task.spawn(function()
				while MainModule.AutoDdakji do
					if fn11() then
						if tick() - n2 >= 1.5 then
							local v4 = fn10()

							if v4 and v4.Active and v4.CurrentPlayer == localPlayer.Character then
								pcall(function()
									v3.RunServerGame(v4, "Thrown", { Power = n, Position = vector })
								end)

								n2 = tick()
							end
						end

						task.wait(0.1)
						continue
					end

					break
				end

				fn13("Ddakji")
			end)
		end

		PlayToggleSound()
	end

	MainModule.AutoFlyingStone = false

	MainModule.toggle_auto_flying_stone = function(autoFlyingStone)
		if autoFlyingStone then
			if MainModule.is_game_active and not MainModule.is_game_active("Pentathlon") then
				MainModule.notify("Auto Flying Stone", "Wait for Pentathlon!", 0.9)
				PlayErrorSound()
				return
			end
		end

		MainModule.StopPentathlonauto2()
		MainModule.AutoFlyingStone = autoFlyingStone

		if autoFlyingStone then
			local v3 = fn12()
			if not v3 then
				PlayToggleSound()
				return
			end
			local n = 0
			local tbl2 = { stand = nil, game = nil }

			MainModule.PentathlonThreads.FlyingStone = task.spawn(function()
				while MainModule.AutoFlyingStone do
					if fn11() then
						if tick() - n >= 1.5 then
							local v4 = fn10()

							if v4 and v4.Active and v4.CurrentPlayer == localPlayer.Character then
								local character = localPlayer.Character
								character = character and character:FindFirstChild("HumanoidRootPart")

								if character then
									if not tbl2.stand or tbl2.game ~= v4 then
										tbl2.game = v4
										local pentathlonMap = Workspace:FindFirstChild("PentathlonMap")
										tbl2.stand = pentathlonMap and pentathlonMap:FindFirstChild("Stand", true)
									end

									local position

									if tbl2.stand and tbl2.stand:FindFirstChild("Target") then
										position = tbl2.stand.Target.Position
									else
										position = character.Position + character.CFrame.LookVector * 20
									end

									local n2 = character.Position + Vector3.new(0, 1.5, 0)
									local unit = (position - n2).Unit

									pcall(function()
										v3.RunServerGame(v4, "Thrown", { ThrowPower = "Perfect", Origin = n2, Direction = unit })
									end)

									n = tick()
								end
							end
						end

						task.wait(0.1)
						continue
					end

					break
				end

				fn13("FlyingStone")
			end)
		end

		PlayToggleSound()
	end

	MainModule.AutoGonggi = false

	MainModule.toggle_auto_gonggi = function(autoGonggi)
		if autoGonggi then
			if MainModule.is_game_active and not MainModule.is_game_active("Pentathlon") then
				MainModule.notify("Auto Gonggi", "Wait for Pentathlon!", 0.9)
				PlayErrorSound()
				return
			end
		end

		MainModule.StopPentathlonauto3()
		MainModule.AutoGonggi = autoGonggi

		if autoGonggi then
			local v3 = fn12()
			if not v3 then
				PlayToggleSound()
				return
			end
			local n = 0
			local tbl2 = {}
			local v4 = nil

			MainModule.PentathlonThreads.Gonggi = task.spawn(function()
				while MainModule.AutoGonggi do
					if fn11() then
						local v5 = fn10()

						if v5 and v5.Active and v5.CurrentPlayer == localPlayer.Character and tick() - n >= 2.5 then
							if v5 ~= v4 then
								v4 = v5
								table.clear(tbl2)
							end

							local pentathlonMap = Workspace:FindFirstChild("PentathlonMap")

							if pentathlonMap then
								local v6 = nil

								for _, descendant in ipairs(pentathlonMap:GetDescendants()) do
									if descendant:IsA("BasePart") and descendant:FindFirstChild("GrabHighlight") and not tbl2[descendant.Name] then
										v6 = descendant
										break
									end
								end

								if v6 then
									tbl2[v6.Name] = true
									n = tick()

									task.spawn(function()
										task.wait(0.4)

										if v5 and v5.Active then
											pcall(function()
												v3.RunServerGame(v5, "GotPiece", { Name = v6.Name })
											end)
										end

										task.wait(0.3)

										if v5 and v5.Active then
											local flag = true

											for _, descendant in ipairs(pentathlonMap:GetDescendants()) do
												if descendant:IsA("BasePart") and descendant:FindFirstChild("GrabHighlight") and not tbl2[descendant.Name] then
													flag = false
													break
												end
											end

											if flag then
												pcall(function()
													v3.RunServerGame(v5, "TimeSlowFinish")
												end)
											end
										end
									end)
								end
							end
						end

						task.wait(0.1)
						continue
					end

					break
				end

				fn13("Gonggi")
			end)
		end

		PlayToggleSound()
	end

	MainModule.AutoSpinningTop = false

	MainModule.toggle_auto_spinning_top = function(autoSpinningTop)
		if autoSpinningTop then
			if MainModule.is_game_active and not MainModule.is_game_active("Pentathlon") then
				MainModule.notify("Auto Spinning Top", "Wait for Pentathlon!", 0.9)
				PlayErrorSound()
				return
			end
		end

		MainModule.StopPentathlonauto4()
		MainModule.AutoSpinningTop = autoSpinningTop

		if autoSpinningTop then
			local v3 = fn12()
			if not v3 then
				PlayToggleSound()
				return
			end
			local str = "Tie"
			local flag = false
			local n = 0
			local v4 = nil

			local function fn14(arg)
				if flag or not arg or not arg.HandleRequest then
					return
				end
				local handleRequest = arg.HandleRequest

				arg.HandleRequest = function(arg2, arg3, arg4, ...)
					if arg3 == "Aim" then
						str = "Aim"
					elseif arg3 == "SetPlayer" or arg3 == "Restart" then
						str = "Tie"
					elseif arg3 == "Reset" then
						str = nil
					end

					local v5 = table.pack(...)
					local v6 = handleRequest
					v5.n = 4 + v5.n - 1
					table.move(v5, 1, v5.n, 4, v5)
					v5[1] = arg2
					v5[2] = arg3
					v5[3] = arg4
					return v6(table.unpack(v5, 1, v5.n))
				end

				flag = true
			end

			MainModule.PentathlonThreads.SpinningTop = task.spawn(function()
				while MainModule.AutoSpinningTop do
					if fn11() then
						local v5 = fn10()

						if v5 and v5.Active then
							if v5 ~= v4 then
								v4 = v5
								flag = false
								str = "Tie"
								fn14(v5)
							end

							if v5.CurrentPlayer == localPlayer.Character then
								local now = tick()

								if str == "Tie" and now - n > 0.3 then
									pcall(function()
										v3.RunServerGame(v5, "Tied", {})
									end)

									n = now
								elseif str == "Aim" and now - n > 1.5 then
									pcall(function()
										v3.RunServerGame(v5, "Thrown", {})
									end)

									n = now
								end
							end
						end

						task.wait(0.1)
						continue
					end

					break
				end

				fn13("SpinningTop")
			end)
		end

		PlayToggleSound()
	end

	MainModule.AutoJegi = false

	MainModule.toggle_auto_jegi = function(autoJegi)
		if autoJegi then
			if MainModule.is_game_active and not MainModule.is_game_active("Pentathlon") then
				MainModule.notify("Auto Jegi", "Wait for Pentathlon!", 0.9)
				PlayErrorSound()
				return
			end
		end

		MainModule.StopPentathlonauto5()
		MainModule.AutoJegi = autoJegi

		if autoJegi then
			local v3 = fn12()
			if not v3 then
				PlayToggleSound()
				return
			end
			local n = 0

			MainModule.PentathlonThreads.Jegi = task.spawn(function()
				while MainModule.AutoJegi do
					if fn11() then
						if tick() - n >= 0.8 then
							local v4 = fn10()

							if v4 and v4.Active and v4.CurrentPlayer == localPlayer.Character then
								pcall(function()
									v3.RunServerGame(v4, "Kick", { Lose = false })
								end)

								n = tick()
							end
						end

						task.wait(0.1)
						continue
					end

					break
				end

				fn13("Jegi")
			end)
		end

		PlayToggleSound()
	end

	MainModule.DalgonaAutoRelax = false
	MainModule.DalgonaAutoRelaxConnection = nil
	MainModule.DalgonaLastRelax = 0

	MainModule.toggle_dalgona_auto_relax = function(dalgonaAutoRelax)
		MainModule.DalgonaAutoRelax = dalgonaAutoRelax

		if MainModule.DalgonaAutoRelaxConnection then
			MainModule.DalgonaAutoRelaxConnection:Disconnect()
			MainModule.DalgonaAutoRelaxConnection = nil
		end

		if dalgonaAutoRelax then
			MainModule.DalgonaLastRelax = 0

			MainModule.DalgonaAutoRelaxConnection = RunService.Heartbeat:Connect(function()
				if not MainModule.DalgonaAutoRelax then
					return
				end
				local dalgonaLastRelax = MainModule.DalgonaLastRelax
				if tick() - dalgonaLastRelax < 5 then
					return
				end
				local playerGui = localPlayer:FindFirstChild("PlayerGui")
				if not playerGui then
					return
				end
				local dalgonaUI = playerGui:FindFirstChild("DalgonaUI")
				if not dalgonaUI then
					return
				end
				local breathing = dalgonaUI:FindFirstChild("Breathing")
				if not breathing or not breathing.Visible then
					return
				end
				local breath = breathing:FindFirstChild("Breath")
				if not breath then
					return
				end
				local crackProgressBar = breathing:FindFirstChild("CrackProgressBar")
				if not crackProgressBar then
					return
				end
				local chanceShadow = crackProgressBar:FindFirstChild("ChanceShadow")
				chanceShadow = chanceShadow and chanceShadow:FindFirstChild("Chance")
				local n = tonumber((chanceShadow and chanceShadow.Text or "0%"):match("(%d+)")) or 0
				if n <= 0 or n >= 95 then
					return
				end

				pcall(function()
					firesignal(breath.MouseButton1Click)
				end)

				MainModule.DalgonaLastRelax = tick()
			end)
		end

		PlayToggleSound()
	end

	MainModule.TugOfWarAutoQTEMiss = false
	MainModule.TugOfWarAutoQTEMissConnection = nil

	local function fn14()
		local playerGui = localPlayer:FindFirstChild("PlayerGui")
		if not playerGui then
			return nil
		end
		local tbl2 = {}
		local tugOfWarUIV2 = playerGui:FindFirstChild("TugOfWarUIV2")
		local tugOfWarUI = playerGui:FindFirstChild("TugOfWarUI")
		local findFirstChild = playerGui.FindFirstChild
		tbl2[1] = tugOfWarUIV2
		tbl2[2] = tugOfWarUI

		do
			local values = table.pack(findFirstChild(playerGui, "TugofWarRemake"))
			table.move(values, 1, values.n, 3, tbl2)
		end

		for _, v3 in ipairs(tbl2) do
			if v3 then
				local circleBase = (v3:FindFirstChild("TugofWarRemake") or v3):FindFirstChild("CircleBase")
				if circleBase then
					return circleBase
				end
				local circleBase2 = v3:FindFirstChild("CircleBase", true)
				if circleBase2 then
					return circleBase2
				end
			end
		end

		for _, descendant in ipairs(playerGui:GetDescendants()) do
			if descendant.Name == "CircleBase" and descendant:FindFirstChild("Arrow") and descendant:FindFirstChild("Medium") then
				return descendant
			end
		end

		return nil
	end

	MainModule.toggle_tug_of_war_auto_qte_miss = function(tugOfWarAutoQTEMiss)
		MainModule.TugOfWarAutoQTEMiss = tugOfWarAutoQTEMiss

		if MainModule.TugOfWarAutoQTEMissConnection then
			MainModule.TugOfWarAutoQTEMissConnection:Disconnect()
			MainModule.TugOfWarAutoQTEMissConnection = nil
		end

		if tugOfWarAutoQTEMiss then
			MainModule.TugOfWarAutoQTEMissConnection = RunService.RenderStepped:Connect(function()
				if not MainModule.TugOfWarAutoQTEMiss then
					return
				end

				if localPlayer:GetAttribute("TugOfWarPhase") ~= "QTE" then
					return
				end
				local v3 = fn14()
				if not v3 then
					return
				end
				local arrow = v3:FindFirstChild("Arrow")
				local medium = v3:FindFirstChild("Medium")
				if not arrow or not medium then
					return
				end
				medium.Rotation = arrow.Rotation
			end)
		end

		PlayToggleSound()
	end

	MainModule.AutoRespawnOnFall = {
		Enabled = false,
		Connection = nil,
		FallHeight = 950,
		TeleportPosition = Vector3.new(0, 966, -6),
		HasTeleported = false,
	}

	MainModule.toggle_auto_respawn_on_fall = function(enabled)
		if enabled then
			if MainModule.is_game_active and not MainModule.is_game_active("SkySquidGame") then
				MainModule.notify("Auto Respawn", "Wait for SkySquidGame!", 0.9)
				PlayErrorSound()
				return
			end
		end

		MainModule.AutoRespawnOnFall.Enabled = enabled
		MainModule.AutoRespawnOnFall.HasTeleported = false

		if MainModule.AutoRespawnOnFall.Connection then
			MainModule.AutoRespawnOnFall.Connection:Disconnect()
			MainModule.AutoRespawnOnFall.Connection = nil
		end

		if enabled then
			MainModule.AutoRespawnOnFall.Connection = RunService.Heartbeat:Connect(function()
				if not MainModule.AutoRespawnOnFall.Enabled then
					return
				end

				if MainModule.is_game_active and not MainModule.is_game_active("SkySquidGame") then
					return
				end
				local v3 = MainModule.get_character()
				if not v3 then
					return
				end
				local v4 = MainModule.get_root_part(v3)
				if not v4 then
					return
				end
				local y = v4.Position.Y

				if y <= MainModule.AutoRespawnOnFall.FallHeight and not MainModule.AutoRespawnOnFall.HasTeleported then
					v4.CFrame = CFrame.new(MainModule.AutoRespawnOnFall.TeleportPosition)
					MainModule.AutoRespawnOnFall.HasTeleported = true
				end

				if MainModule.AutoRespawnOnFall.FallHeight < y then
					MainModule.AutoRespawnOnFall.HasTeleported = false
				end
			end)
		end

		PlayToggleSound()
	end

	MainModule.VoidKillSettings = { Enabled = false, Conn = nil, CharConn = nil, Platform = nil, BackupPlatform = nil }
	MainModule.VoidAnimIds = { "rbxassetid://107989020363293", "rbxassetid://95016887526212", "rbxassetid://81454586970343" }

	MainModule.toggle_void_kill = function(enabled)
		local voidKill = MainModule.ToggleRefs.VoidKill

		if enabled then
			if not MainModule.is_game_active("SkySquidGame") then
				fn2("Void Kill", "Wait for SkySquidGame!", 0.9)
				PlayErrorSound()

				if voidKill and voidKill.SetValue then
					pcall(function()
						voidKill:SetValue(false)
					end)
				end

				return false
			end
		end

		if not enabled then
			if MainModule.VoidKillSettings.Conn then
				MainModule.VoidKillSettings.Conn:Disconnect()
				MainModule.VoidKillSettings.Conn = nil
			end

			if MainModule.VoidKillSettings.CharConn then
				MainModule.VoidKillSettings.CharConn:Disconnect()
				MainModule.VoidKillSettings.CharConn = nil
			end

			if MainModule.VoidKillSettings.Platform then
				MainModule.VoidKillSettings.Platform:Destroy()
				MainModule.VoidKillSettings.Platform = nil
			end

			if MainModule.VoidKillSettings.BackupPlatform then
				MainModule.VoidKillSettings.BackupPlatform:Destroy()
				MainModule.VoidKillSettings.BackupPlatform = nil
			end

			PlayToggleSound()
			return true
		end

		MainModule.VoidKillSettings.Enabled = enabled

		local function fn15(arg)
			local humanoid = arg:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return
			end

			MainModule.VoidKillSettings.Conn = humanoid.AnimationPlayed:Connect(function(arg2)
				if not MainModule.VoidKillSettings.Enabled then
					return
				end

				if arg2.Animation and table.find(MainModule.VoidAnimIds, arg2.Animation.AnimationId) then
					local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
					if not humanoidRootPart then
						return
					end
					local cFrame = humanoidRootPart.CFrame
					local n = math.random() * 3.1415926535897931 * 2
					local n2 = cFrame.Position + Vector3.new(math.cos(n) * 63, 0, math.sin(n) * 63)
					local cframe = CFrame.new(n2 + Vector3.new(0, 0.5, 0))

					if MainModule.VoidKillSettings.Platform then
						MainModule.VoidKillSettings.Platform:Destroy()
					end

					if MainModule.VoidKillSettings.BackupPlatform then
						MainModule.VoidKillSettings.BackupPlatform:Destroy()
					end

					local part = Instance.new("Part")
					part.Name = HttpService:GenerateGUID(false)
					part.Size = Vector3.new(240, 3, 240)
					part.Material = Enum.Material.Plastic
					part.Position = n2 + Vector3.new(0, -3, 0)
					part.Anchored = true
					part.CanCollide = true
					part.Transparency = 0.5
					part.Parent = workspace
					local part2 = Instance.new("Part")
					part2.Name = HttpService:GenerateGUID(false)
					part2.Size = Vector3.new(240, 2, 240)
					part2.Position = n2 + Vector3.new(0, -7, 0)
					part2.Anchored = true
					part2.CanCollide = true
					part2.Transparency = 1
					part2.Parent = workspace
					MainModule.VoidKillSettings.Platform = part
					MainModule.VoidKillSettings.BackupPlatform = part2
					humanoidRootPart.CFrame = cframe

					if arg.PrimaryPart then
						arg:SetPrimaryPartCFrame(cframe)
					end

					local connection = nil

					connection = arg2.Stopped:Connect(function()
						task.wait(1.5)

						if arg and arg.Parent and MainModule.VoidKillSettings.Enabled then
							local humanoidRootPart2 = arg:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart2 then
								humanoidRootPart2.CFrame = cFrame

								if arg.PrimaryPart then
									arg:SetPrimaryPartCFrame(cFrame)
								end
							end
						end

						task.wait(1.5)

						if part then
							part:Destroy()
						end

						if part2 then
							part2:Destroy()
						end

						MainModule.VoidKillSettings.Platform = nil
						MainModule.VoidKillSettings.BackupPlatform = nil

						if connection then
							connection:Disconnect()
						end
					end)
				end
			end)
		end

		if localPlayer.Character then
			fn15(localPlayer.Character)
		end

		MainModule.VoidKillSettings.CharConn = localPlayer.CharacterAdded:Connect(function(character)
			task.wait(1)

			if MainModule.VoidKillSettings.Enabled then
				fn15(character)
			end
		end)

		PlayToggleSound()
		return true
	end

	MainModule.AntiCrack = function()
		local effects = workspace:FindFirstChild("Effects")

		if effects then
			for _, child in ipairs(effects:GetChildren()) do
				if child.Name and child.Name:find("Outline") then
					for _, descendant in ipairs(child:GetDescendants()) do
						if descendant:IsA("BasePart") and descendant.Name ~= "DalgonaClickPart" then
							pcall(function()
								local clone = descendant:Clone()
								clone.Name = "DalgonaClickPart"
								clone.Parent = descendant.Parent
								clone.Size = Vector3.one
								clone.Transparency = 1
								clone.CanCollide = false
								clone.Anchored = true
								clone.Position = descendant.Position
							end)
						end
					end
				end
			end
		end
	end

	MainModule.anti_crack = MainModule.AntiCrack

	MainModule.toggle_anti_crack = function()
		MainModule.AntiCrack()
		PlayToggleSound()
		return true
	end

	MainModule.shitahhdalgonaez = function()
		if not getgc or not getupvalues or not setupvalue then
			return
		end

		for _, v3 in ipairs(getgc()) do
			if type(v3) == "function" then
				local v4 = nil

				if getconstants then
					local ok, result = pcall(getconstants, v3)
					local v5 = nil

					if ok then
						v4 = result
					else
						v4 = v5
					end
				end

				local flag = false

				if type(v4) == "table" then
					for _, v5 in pairs(v4) do
						if v5 == "Completed" or v5 == "Progress" then
							flag = true
							break
						elseif type(v5) == "string" and v5:find("%%", 1, true) then
							flag = true
							break
						end
					end
				end

				if flag then
					local ok, result = pcall(getupvalues, v3)

					if ok and type(result) == "table" then
						for k, v5 in pairs(result) do
							if type(v5) == "number" and v5 == v5 and v5 >= 0 and v5 < 50000 then
								pcall(setupvalue, v3, k, 100000)
							end
						end
					end
				end
			end
		end
	end

	MainModule.HideNicknameEnabled = false
	MainModule.HideAllNicknamesEnabled = false
	MainModule.HideNicknameConnection = nil
	MainModule.HideAllNicknamesConnection = nil

	local function fn15()
		local live = workspace:FindFirstChild("Live")
		if not live then
			return nil
		end
		local v3 = live:FindFirstChild(localPlayer.Name)
		if not v3 then
			return nil
		end
		local torso = v3:FindFirstChild("Torso")
		if not torso then
			return nil
		end
		return torso:FindFirstChild("Player_Nametag")
	end

	local function fn16()
		local v3 = fn15()

		if v3 then
			pcall(function()
				v3.Enabled = false

				if v3:IsA("BillboardGui") or v3:IsA("SurfaceGui") then
					v3.Enabled = false
				end

				for _, descendant in ipairs(v3:GetDescendants()) do
					if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("ImageLabel") then
						descendant.Visible = false
					end
				end
			end)
		end
	end

	local function fn17()
		local v3 = fn15()

		if v3 then
			pcall(function()
				v3.Enabled = true

				for _, descendant in ipairs(v3:GetDescendants()) do
					if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("ImageLabel") then
						descendant.Visible = true
					end
				end
			end)
		end
	end

	local function fn18()
		local live = workspace:FindFirstChild("Live")
		if not live then
			return
		end

		for _, child in ipairs(live:GetChildren()) do
			local torso = child:FindFirstChild("Torso")

			if torso then
				local playerNametag = torso:FindFirstChild("Player_Nametag")

				if playerNametag then
					pcall(function()
						playerNametag.Enabled = false

						for _, descendant in ipairs(playerNametag:GetDescendants()) do
							if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("ImageLabel") then
								descendant.Visible = false
							end
						end
					end)
				end
			end
		end
	end

	local function fn19()
		local live = workspace:FindFirstChild("Live")
		if not live then
			return
		end

		for _, child in ipairs(live:GetChildren()) do
			local torso = child:FindFirstChild("Torso")

			if torso then
				local playerNametag = torso:FindFirstChild("Player_Nametag")

				if playerNametag then
					pcall(function()
						playerNametag.Enabled = true

						for _, descendant in ipairs(playerNametag:GetDescendants()) do
							if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("ImageLabel") then
								descendant.Visible = true
							end
						end
					end)
				end
			end
		end
	end

	MainModule.toggle_hide_nickname = function(hideNicknameEnabled)
		MainModule.HideNicknameEnabled = hideNicknameEnabled

		if MainModule.HideNicknameConnection then
			MainModule.HideNicknameConnection:Disconnect()
			MainModule.HideNicknameConnection = nil
		end

		if hideNicknameEnabled then
			fn16()

			MainModule.HideNicknameConnection = RunService.Heartbeat:Connect(function()
				if MainModule.HideNicknameEnabled then
					fn16()
				end
			end)
		else
			fn17()
		end

		PlayToggleSound()
	end

	MainModule.toggle_hide_all_nicknames = function(hideAllNicknamesEnabled)
		MainModule.HideAllNicknamesEnabled = hideAllNicknamesEnabled

		if MainModule.HideAllNicknamesConnection then
			MainModule.HideAllNicknamesConnection:Disconnect()
			MainModule.HideAllNicknamesConnection = nil
		end

		if hideAllNicknamesEnabled then
			fn18()

			MainModule.HideAllNicknamesConnection = RunService.Heartbeat:Connect(function()
				if MainModule.HideAllNicknamesEnabled then
					fn18()
				end
			end)
		else
			fn19()
		end

		PlayToggleSound()
	end

	MainModule.CustomGravityEnabled = false
	MainModule.CustomGravityValue = 196.2
	MainModule.CustomGravityConnection = nil

	MainModule.toggle_custom_gravity = function(customGravityEnabled)
		MainModule.CustomGravityEnabled = customGravityEnabled

		if MainModule.CustomGravityConnection then
			MainModule.CustomGravityConnection:Disconnect()
			MainModule.CustomGravityConnection = nil
		end

		if customGravityEnabled then
			Workspace.Gravity = MainModule.CustomGravityValue

			MainModule.CustomGravityConnection = RunService.Heartbeat:Connect(function()
				if MainModule.CustomGravityEnabled then
					Workspace.Gravity = MainModule.CustomGravityValue
				end
			end)
		else
			Workspace.Gravity = 196.2
		end

		PlayToggleSound()
	end

	MainModule.set_custom_gravity = function(arg)
		local customGravityValue = tonumber(arg)

		if customGravityValue and customGravityValue >= 50 and customGravityValue <= 500 then
			MainModule.CustomGravityValue = customGravityValue

			if MainModule.CustomGravityEnabled then
				Workspace.Gravity = MainModule.CustomGravityValue
			end
		else
			MainModule.notify("Custom Gravity", "Invalid number (50-500)", 0.9)
			PlayErrorSound()
		end
	end

	MainModule.CustomJumpPowerEnabled = false
	MainModule.CustomJumpPowerValue = 50
	MainModule.CustomJumpPowerConnection = nil

	MainModule.toggle_custom_jump_power = function(customJumpPowerEnabled)
		MainModule.CustomJumpPowerEnabled = customJumpPowerEnabled

		if MainModule.CustomJumpPowerConnection then
			MainModule.CustomJumpPowerConnection:Disconnect()
			MainModule.CustomJumpPowerConnection = nil
		end

		if customJumpPowerEnabled then
			local v3 = MainModule.get_character()

			if v3 then
				local v4 = MainModule.get_humanoid(v3)

				if v4 then
					MainModule.OriginalJumpPower = v4.JumpPower
					v4.JumpPower = MainModule.CustomJumpPowerValue
				end
			end

			MainModule.CustomJumpPowerConnection = RunService.Heartbeat:Connect(function()
				if MainModule.CustomJumpPowerEnabled then
					local v4 = MainModule.get_character()

					if v4 then
						local v5 = MainModule.get_humanoid(v4)

						if v5 and v5.JumpPower ~= MainModule.CustomJumpPowerValue then
							v5.JumpPower = MainModule.CustomJumpPowerValue
						end
					end
				end
			end)
		else
			local v3 = MainModule.get_character()

			if v3 then
				local v4 = MainModule.get_humanoid(v3)

				if v4 then
					v4.JumpPower = MainModule.OriginalJumpPower or 50
				end
			end
		end

		PlayToggleSound()
	end

	MainModule.set_custom_jump_power = function(arg)
		local customJumpPowerValue = tonumber(arg)

		if customJumpPowerValue and customJumpPowerValue >= 20 and customJumpPowerValue <= 200 then
			MainModule.CustomJumpPowerValue = customJumpPowerValue

			if MainModule.CustomJumpPowerEnabled then
				local v3 = MainModule.get_character()

				if v3 then
					local v4 = MainModule.get_humanoid(v3)

					if v4 then
						v4.JumpPower = MainModule.CustomJumpPowerValue
					end
				end
			end
		else
			MainModule.notify("Custom Jump Power", "Invalid number (20-200)", 0.9)
			PlayErrorSound()
		end
	end

	MainModule.CustomGravityEnabled = false
	MainModule.CustomGravityValue = 196.2
	MainModule.CustomGravityConnection = nil

	MainModule.toggle_custom_gravity = function(customGravityEnabled)
		MainModule.CustomGravityEnabled = customGravityEnabled

		if MainModule.CustomGravityConnection then
			MainModule.CustomGravityConnection:Disconnect()
			MainModule.CustomGravityConnection = nil
		end

		if customGravityEnabled then
			Workspace.Gravity = MainModule.CustomGravityValue

			MainModule.CustomGravityConnection = RunService.Heartbeat:Connect(function()
				if MainModule.CustomGravityEnabled then
					Workspace.Gravity = MainModule.CustomGravityValue
				end
			end)
		else
			Workspace.Gravity = 196.2
		end

		PlayToggleSound()
	end

	MainModule.set_custom_gravity = function(arg)
		local customGravityValue = tonumber(arg)

		if customGravityValue and customGravityValue >= 50 and customGravityValue <= 500 then
			MainModule.CustomGravityValue = customGravityValue

			if MainModule.CustomGravityEnabled then
				Workspace.Gravity = MainModule.CustomGravityValue
			end
		else
			MainModule.notify("Custom Gravity", "Invalid number (50-500)", 0.9)
			PlayErrorSound()
		end
	end

	MainModule.CustomJumpPowerEnabled = false
	MainModule.CustomJumpPowerValue = 50
	MainModule.CustomJumpPowerConnection = nil

	MainModule.toggle_custom_jump_power = function(customJumpPowerEnabled)
		MainModule.CustomJumpPowerEnabled = customJumpPowerEnabled

		if MainModule.CustomJumpPowerConnection then
			MainModule.CustomJumpPowerConnection:Disconnect()
			MainModule.CustomJumpPowerConnection = nil
		end

		if customJumpPowerEnabled then
			local v3 = MainModule.get_character()

			if v3 then
				local v4 = MainModule.get_humanoid(v3)

				if v4 then
					MainModule.OriginalJumpPower = v4.JumpPower
					v4.JumpPower = MainModule.CustomJumpPowerValue
				end
			end

			MainModule.CustomJumpPowerConnection = RunService.Heartbeat:Connect(function()
				if MainModule.CustomJumpPowerEnabled then
					local v4 = MainModule.get_character()

					if v4 then
						local v5 = MainModule.get_humanoid(v4)

						if v5 and v5.JumpPower ~= MainModule.CustomJumpPowerValue then
							v5.JumpPower = MainModule.CustomJumpPowerValue
						end
					end
				end
			end)
		else
			local v3 = MainModule.get_character()

			if v3 then
				local v4 = MainModule.get_humanoid(v3)

				if v4 then
					v4.JumpPower = MainModule.OriginalJumpPower or 50
				end
			end
		end

		PlayToggleSound()
	end

	MainModule.set_custom_jump_power = function(customJumpPowerValue)
		MainModule.CustomJumpPowerValue = customJumpPowerValue

		if MainModule.CustomJumpPowerEnabled then
			local v3 = MainModule.get_character()

			if v3 then
				local v4 = MainModule.get_humanoid(v3)

				if v4 then
					v4.JumpPower = MainModule.CustomJumpPowerValue
				end
			end
		end
	end

	MainModule.CustomWinEnabled = false
	MainModule.CustomWinValue = 67
	MainModule.CustomWinConnection = nil

	MainModule.toggle_custom_win = function(customWinEnabled)
		MainModule.CustomWinEnabled = customWinEnabled

		if MainModule.CustomWinConnection then
			MainModule.CustomWinConnection:Disconnect()
			MainModule.CustomWinConnection = nil
		end

		if customWinEnabled then
			localPlayer:SetAttribute("_GameWins", MainModule.CustomWinValue)

			MainModule.CustomWinConnection = RunService.Heartbeat:Connect(function()
				if MainModule.CustomWinEnabled then
					localPlayer:SetAttribute("_GameWins", MainModule.CustomWinValue)
				end
			end)
		end

		PlayToggleSound()
	end

	MainModule.set_custom_win = function(arg)
		local num = tonumber(arg)

		if num and num >= 0 and num <= 999999 then
			MainModule.CustomWinValue = math.floor(num)

			if MainModule.CustomWinEnabled then
				localPlayer:SetAttribute("_GameWins", MainModule.CustomWinValue)
			end
		else
			MainModule.notify("Custom Win", "Invalid number", 0.9)
		end
	end

	MainModule.AutoVoteEnabled = false
	MainModule.AutoVoteConnection = nil
	MainModule.VoteOption = "KeepPlaying"

	MainModule.toggle_auto_vote = function(autoVoteEnabled)
		MainModule.AutoVoteEnabled = autoVoteEnabled

		if MainModule.AutoVoteConnection then
			MainModule.AutoVoteConnection:Disconnect()
			MainModule.AutoVoteConnection = nil
		end

		if autoVoteEnabled then
			MainModule.AutoVoteConnection = RunService.Heartbeat:Connect(function()
				if MainModule.AutoVoteEnabled then
					pcall(function()
						local remotes = ReplicatedStorage:FindFirstChild("Remotes")

						if remotes then
							local extraTemporaryRemote = remotes:FindFirstChild("ExtraTemporaryRemote")

							if extraTemporaryRemote then
								extraTemporaryRemote:FireServer({ Voting = MainModule.VoteOption })
							end
						end
					end)
				end
			end)
		end

		PlayToggleSound()
	end

	MainModule.set_vote_option = function(voteOption)
		MainModule.VoteOption = voteOption
	end

	MainModule.NoCooldownProximityEnabled = false
	MainModule.ProximityConnection = nil

	MainModule.toggle_no_cooldown_proximity = function(noCooldownProximityEnabled)
		local broker = MainModule.PromptInteraction
		local enabled = noCooldownProximityEnabled and true or false
		if broker and broker:SetInstant(enabled) then
			MainModule.NoCooldownProximityEnabled = enabled
		end
		PlayToggleSound()
	end

	MainModule.InfiniteJumpEnabled = false
	MainModule.InfiniteJumpConnection = nil

	MainModule.toggle_infinite_jump = function(infiniteJumpEnabled)
		MainModule.InfiniteJumpEnabled = infiniteJumpEnabled

		if MainModule.InfiniteJumpConnection then
			MainModule.InfiniteJumpConnection:Disconnect()
			MainModule.InfiniteJumpConnection = nil
		end

		if infiniteJumpEnabled then
			MainModule.InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
				if MainModule.InfiniteJumpEnabled and localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
					localPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		end

		PlayToggleSound()
	end

	MainModule.Rebel = { Enabled = false, Connection = nil }
	MainModule.ParkourArtistEnabled = false
	MainModule.ParkourArtistConnection = nil
	MainModule.OriginalPower = nil
	MainModule.ParkourArtistState = nil
	MainModule.ParkourArtistConns = {}

	MainModule.unlock_parkour_artist = function()
		local animations = game:GetService("ReplicatedStorage"):FindFirstChild("Animations")
		animations = animations and animations:FindFirstChild("Abilities")
		animations = animations and animations:FindFirstChild("ParkourArtist")

		if animations then
			if animations:IsA("BoolValue") then
				animations.Value = true
			elseif animations:IsA("NumberValue") or animations:IsA("IntValue") then
				animations.Value = 1
			end

			for _, descendant in pairs(animations:GetDescendants()) do
				if descendant:IsA("BoolValue") then
					descendant.Value = true
				elseif descendant:IsA("NumberValue") or descendant:IsA("IntValue") then
					descendant.Value = 1
				end
			end
		end

		localPlayer:SetAttribute("__OwnsParkourArtist", true)
		localPlayer:SetAttribute("HasParkourArtist", true)
		localPlayer:SetAttribute("UnlockedParkourArtist", true)
	end

	MainModule._ParkourCleanup = function()
		for _, parkourArtistConn in ipairs(MainModule.ParkourArtistConns) do
			pcall(function()
				parkourArtistConn:Disconnect()
			end)
		end

		MainModule.ParkourArtistConns = {}

		if MainModule.ParkourArtistConnection then
			pcall(function()
				MainModule.ParkourArtistConnection:Disconnect()
			end)

			MainModule.ParkourArtistConnection = nil
		end

		MainModule.ParkourArtistState = nil
	end

	MainModule._ParkourStartMechanics = function()
	end

	MainModule.ParkourArtistFolder = nil

	MainModule.toggle_parkour_artist = function(arg)
		local parkourArtistEnabled = arg and true or false
		MainModule.ParkourArtistEnabled = parkourArtistEnabled

		if parkourArtistEnabled then
			if not MainModule.OriginalPower then
				MainModule.OriginalPower = localPlayer:GetAttribute("_EquippedPower") or ""
			end

			pcall(function()
				local live = Workspace:FindFirstChild("Live") or Workspace:WaitForChild("Live", 5)
				if not live then
					return
				end
				local v3 = live:FindFirstChild(localPlayer.Name) or live:WaitForChild(localPlayer.Name, 5)
				if not v3 then
					return
				end
				local parkourArtist = v3:FindFirstChild("ParkourArtist")

				if parkourArtist then
					parkourArtist:Destroy()
				end

				local folder = Instance.new("Folder")
				folder.Name = "ParkourArtist"
				folder.Parent = v3
				MainModule.ParkourArtistFolder = folder
			end)

			pcall(function()
				localPlayer:SetAttribute("_EquippedPower", "PARKOUR ARTIST")
				localPlayer:SetAttribute("__OwnsParkourArtist", true)
				localPlayer:SetAttribute("HasParkourArtist", true)
				localPlayer:SetAttribute("UnlockedParkourArtist", true)
			end)

			if MainModule.ParkourArtistConnection then
				pcall(function()
					MainModule.ParkourArtistConnection:Disconnect()
				end)
			end

			MainModule.ParkourArtistConnection = RunService.Heartbeat:Connect(function()
				if not MainModule.ParkourArtistEnabled then
					return
				end

				pcall(function()
					localPlayer:SetAttribute("_EquippedPower", "PARKOUR ARTIST")
					local live = Workspace:FindFirstChild("Live")
					live = live and live:FindFirstChild(localPlayer.Name)

					if live and not live:FindFirstChild("ParkourArtist") then
						local folder = Instance.new("Folder")
						folder.Name = "ParkourArtist"
						folder.Parent = live
						MainModule.ParkourArtistFolder = folder
					end
				end)
			end)

			fn2("Parkour Artist", "Enabled", 0.8)
		else
			MainModule.ParkourArtistEnabled = false

			if MainModule.ParkourArtistConnection then
				pcall(function()
					MainModule.ParkourArtistConnection:Disconnect()
				end)

				MainModule.ParkourArtistConnection = nil
			end

			pcall(function()
				if MainModule.ParkourArtistFolder and MainModule.ParkourArtistFolder.Parent then
					MainModule.ParkourArtistFolder:Destroy()
				end

				MainModule.ParkourArtistFolder = nil
				local live = Workspace:FindFirstChild("Live")
				live = live and live:FindFirstChild(localPlayer.Name)

				if live then
					local parkourArtist = live:FindFirstChild("ParkourArtist")

					if parkourArtist then
						parkourArtist:Destroy()
					end
				end
			end)

			if MainModule.OriginalPower ~= nil then
				pcall(function()
					localPlayer:SetAttribute("_EquippedPower", MainModule.OriginalPower)
				end)

				MainModule.OriginalPower = nil
			end

			fn2("Parkour Artist", "Disabled", 0.8)
		end

		PlayToggleSound()
	end

	MainModule.set_parkour_artist = function()
		MainModule.unlock_parkour_artist()
		PlayToggleSound()
	end

	MainModule.SpikesPlatformTeleport = {
		Enabled = false,
		Connection = nil,
		Platform = nil,
		OriginalCFrame = nil,
		SpikesPosition = nil,
	}

	MainModule.toggle_spikes_platform_teleport = function(arg)
		if not (arg and true or false) then
			if PlayToggleSound then
				PlayToggleSound()
			end

			return true
		end

		pcall(function()
			if not MainModule.AntiSpikesEnabled then
				MainModule.toggle_anti_spikes(true)

				pcall(function()
					if MainModule.ToggleRefs and MainModule.ToggleRefs.AntiSpikes then
						MainModule.ToggleRefs.AntiSpikes:SetValue(true)
					end
				end)
			end
		end)

		task.wait(0.35)
		local v3 = nil

		if MainModule.AntiSpikesPlatforms then
			v3 = nil

			for _, antiSpikesPlatform in pairs(MainModule.AntiSpikesPlatforms) do
				if antiSpikesPlatform and antiSpikesPlatform.Parent and antiSpikesPlatform:IsA("BasePart") then
					v3 = antiSpikesPlatform
					break
				else
					v3 = nil
				end
			end
		end

		if not v3 then
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("BasePart") and (descendant.Name == "HSX_AntiSpikePlatform" or descendant.Name:find("AntiSpike")) then
					v3 = descendant
					break
				end
			end
		end

		if not v3 then
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if string.lower(tostring(descendant.Name)) == "killingparts" then
					local isBasePart = descendant:IsA("BasePart") and descendant or descendant:FindFirstChildWhichIsA("BasePart", true)
					if isBasePart then
						v3 = isBasePart
						break
					end
				end
			end
		end

		local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

		if v3 and humanoidRootPart then
			humanoidRootPart.CFrame = CFrame.new(v3.Position + Vector3.new(0, 4, 0))

			pcall(function()
				fn2("Teleport", "To spikes platform", 0.9)
			end)
		else
			pcall(function()
				fn2("Teleport", "No platform found", 0.9)
			end)
		end

		pcall(function()
			if MainModule.ToggleRefs and MainModule.ToggleRefs.TeleportToSpikes then
				MainModule.ToggleRefs.TeleportToSpikes:SetValue(false)
			end
		end)

		if PlayToggleSound then
			PlayToggleSound()
		end

		return true
	end

	MainModule.HCGlassESPEnabled = false
	MainModule.HCGlassESPConnection = nil
	MainModule.HCGlassESPObjects = {}

	MainModule.create_hc_glass_esp = function(adornee, arg)
		if MainModule.HCGlassESPObjects[adornee] then
			return
		end
		local primaryPart = adornee.PrimaryPart
		if not primaryPart then
			return
		end
		local highlight = Instance.new("Highlight")
		highlight.Adornee = adornee
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = arg and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0.3
		highlight.Parent = adornee
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Adornee = primaryPart
		billboardGui.Size = UDim2.new(0, 100, 0, 30)
		billboardGui.StudsOffset = Vector3.new(0, 3, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.Parent = primaryPart
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = arg and "BREAKABLE" or "SAFE"
		textLabel.TextColor3 = arg and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextStrokeTransparency = 0
		textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		textLabel.Parent = billboardGui
		MainModule.HCGlassESPObjects[adornee] = { highlight = highlight, billboard = billboardGui, label = textLabel, tile = adornee }
	end

	MainModule.scan_hc_glass_bridge = function()
		local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
		if not glassHolder then
			return
		end

		for _, child in pairs(glassHolder:GetChildren()) do
			for _, child2 in pairs(child:GetChildren()) do
				if child2:IsA("Model") and child2.PrimaryPart then
					MainModule.create_hc_glass_esp(child2, child2.PrimaryPart:GetAttribute("exploitingisevil") == true)
				end
			end
		end
	end

	MainModule.clear_hc_glass_esp = function()
		for _, hcGlassESPObject in pairs(MainModule.HCGlassESPObjects) do
			if hcGlassESPObject.highlight then
				pcall(function()
					hcGlassESPObject.highlight:Destroy()
				end)
			end

			if hcGlassESPObject.billboard then
				pcall(function()
					hcGlassESPObject.billboard:Destroy()
				end)
			end
		end

		MainModule.HCGlassESPObjects = {}
	end

	MainModule.toggle_hc_glass_esp = function(hcGlassESPEnabled)
		if hcGlassESPEnabled then
			if MainModule.is_game_active and not MainModule.is_game_active("GlassBridge") then
				MainModule.notify("Glass ESP", "Wait for GlassBridge!", 0.9)
				PlayErrorSound()
				return
			end
		end

		MainModule.HCGlassESPEnabled = hcGlassESPEnabled

		if MainModule.HCGlassESPConnection then
			MainModule.HCGlassESPConnection:Disconnect()
			MainModule.HCGlassESPConnection = nil
		end

		if hcGlassESPEnabled then
			MainModule.scan_hc_glass_bridge()

			MainModule.HCGlassESPConnection = RunService.Heartbeat:Connect(function()
				if not MainModule.HCGlassESPEnabled then
					return
				end

				if not MainModule.is_game_active("GlassBridge") then
					MainModule.disable_toggle("HCGlassESP")
					return
				end
				MainModule.scan_hc_glass_bridge()
			end)
		else
			MainModule.clear_hc_glass_esp()
		end

		PlayToggleSound()
	end

	MainModule.TugOfWarAutoQTEMiss = false
	MainModule.TugOfWarAutoQTEMissConnection = nil

	MainModule.toggle_tug_of_war_auto_qte_miss = function(tugOfWarAutoQTEMiss)
		MainModule.TugOfWarAutoQTEMiss = tugOfWarAutoQTEMiss

		if MainModule.TugOfWarAutoQTEMissConnection then
			MainModule.TugOfWarAutoQTEMissConnection:Disconnect()
			MainModule.TugOfWarAutoQTEMissConnection = nil
		end

		if tugOfWarAutoQTEMiss then
			MainModule.TugOfWarAutoQTEMissConnection = RunService.RenderStepped:Connect(function()
				if not MainModule.TugOfWarAutoQTEMiss then
					return
				end

				if localPlayer:GetAttribute("TugOfWarPhase") ~= "QTE" then
					return
				end
				local v3 = fn14()
				if not v3 then
					return
				end
				local arrow = v3:FindFirstChild("Arrow")
				local medium = v3:FindFirstChild("Medium")
				if not (arrow and medium) then
					return
				end
				medium.Rotation = arrow.Rotation
			end)
		end

		PlayToggleSound()
	end
end

MainModule.is_mobile = function()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

MainModule.is_game_active = function(arg)
	if not arg then
		return true
	end

	if arg == "Pentathlon" then
		if localPlayer:GetAttribute("InPentathlon") == true then
			return true
		end

		if Workspace:FindFirstChild("PentathlonMap") then
			return true
		end
	end

	local values = Workspace:FindFirstChild("Values")
	if not values then
		return false
	end
	local currentGame = values:FindFirstChild("CurrentGame")
	if not currentGame then
		return false
	end
	local value = currentGame.Value
	if value == arg then
		return true
	end

	if arg == "HideAndSeek" and (value == "HideAndSeek" or value == "Hide & Seek") then
		return true
	end
	local flag = arg == "JumpRope"
	local flag2

	if flag then
		flag2 = value == "JumpRope" or value == "Jump Rope"
	else
		flag2 = flag
	end

	if flag2 then
		return true
	end

	if arg == "GlassBridge" and (value == "GlassBridge" or value == "Glass Bridge") then
		return true
	end
	local flag3 = arg == "RedLightGreenLight"

	if flag3 then
		flag3 = value == "RedLightGreenLight" or value == "Red Light Green Light" or value == "RLGL"
	end

	if flag3 then
		return true
	end

	if arg == "SkySquidGame" and (value == "SkySquidGame" or value == "Sky Squid Game") then
		return true
	end
	local flag4 = arg == "LastDinner"
	local flag5

	if flag4 then
		flag5 = value == "LastDinner" or value == "Last Dinner"
	else
		flag5 = flag4
	end

	if flag5 then
		return true
	end
	return false
end

MainModule.disable_toggle = function(arg)
	if MainModule.ToggleRefs[arg] and MainModule.ToggleRefs[arg].SetValue then
		pcall(function()
			MainModule.ToggleRefs[arg]:SetValue(false)
		end)
	end
end

MainModule.can_enable_toggle = function(arg, arg2, arg3)
	if not MainModule.is_game_active(arg) then
		MainModule.notify(arg2, "Wait for " .. arg .. "!", 0.9)
		PlayErrorSound()

		if arg3 and arg3.SetValue then
			pcall(function()
				arg3:SetValue(false)
			end)
		end

		return false
	end

	if not MainModule.is_feature_supported(arg2) then
		MainModule.notify(arg2, "Not supported in your executor", 0.9)
		PlayErrorSound()

		if arg3 and arg3.SetValue then
			pcall(function()
				arg3:SetValue(false)
			end)
		end

		return false
	end

	return true
end

MainModule.safe_teleport = function(arg)
	local v2 = MainModule.get_character()

	if v2 then
		local v3 = MainModule.get_root_part(v2)
		if v3 then
			v3.CFrame = CFrame.new(arg)
			return true
		end
	end

	return false
end

MainModule.SafeTeleport = MainModule.safe_teleport
MainModule.AntiSpikesEnabled = false
MainModule.AntiSpikesPlatforms = {}
MainModule.AntiSpikesConn = nil

MainModule.toggle_anti_spikes = function(arg)
	MainModule.AntiSpikesEnabled = arg and true or false

	for _, antiSpikesPlatform in ipairs(MainModule.AntiSpikesPlatforms) do
		pcall(function()
			if antiSpikesPlatform then
				antiSpikesPlatform:Destroy()
			end
		end)
	end

	MainModule.AntiSpikesPlatforms = {}

	if MainModule.AntiSpikesConn then
		pcall(function()
			MainModule.AntiSpikesConn:Disconnect()
		end)

		MainModule.AntiSpikesConn = nil
	end

	if not arg then
		PlayToggleSound()
		return true
	end
	local hideAndSeekMap = Workspace:FindFirstChild("HideAndSeekMap")
	local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")

	if not killingParts then
		MainModule.notify("Anti-Spikes", "HideAndSeekMap / KillingParts not found", 0.9)
		PlayErrorSound()
		MainModule.AntiSpikesEnabled = false
		return false
	end

	local n = 0

	local function fn3(arg2)
		if not arg2:IsA("BasePart") then
			return
		end
		local part = Instance.new("Part")
		part.Name = "HSX_AntiSpike"
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 0.5
		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.fromRGB(60, 60, 60)
		local max = math.max
		local z = arg2.Size.Z
		part.Size = Vector3.new(math.max(arg2.Size.X, 4), 1, max(z, 4))
		part.CFrame = CFrame.new(arg2.Position + Vector3.new(0, 20, 0))
		part.Parent = workspace
		table.insert(MainModule.AntiSpikesPlatforms, part)
		n += 1
	end

	for _, descendant in ipairs(killingParts:GetDescendants()) do
		if descendant:IsA("BasePart") then
			fn3(descendant)
		end
	end

	for _, child in ipairs(killingParts:GetChildren()) do
		if child:IsA("BasePart") then
			fn3(child)
		end
	end

	MainModule.notify("Anti-Spikes", "Successfully disabled (" .. tostring(n) .. ")", 0.9)
	PlayToggleSound()
	return true
end

MainModule.DashInGBEnabled = false
MainModule.DashInGBConn = nil

MainModule.toggle_dash_in_gb = function(arg)
	local dashInGBEnabled = arg and true or false

	if dashInGBEnabled then
		if MainModule.is_game_active and not MainModule.is_game_active("GlassBridge") then
			MainModule.notify("Dash in GB", "Wait for GlassBridge!", 0.9)
			PlayErrorSound()
			return false
		end
	end

	MainModule.DashInGBEnabled = dashInGBEnabled

	if MainModule.DashInGBConn then
		pcall(function()
			MainModule.DashInGBConn:Disconnect()
		end)

		MainModule.DashInGBConn = nil
	end

	if dashInGBEnabled then
		pcall(function()
			localPlayer:SetAttribute("CanDashInGB", true)
			localPlayer:SetAttribute("DashInGlassBridge", true)
		end)

		MainModule.DashInGBConn = RunService.Heartbeat:Connect(function()
			if not MainModule.DashInGBEnabled then
				return
			end

			pcall(function()
				localPlayer:SetAttribute("CanDashInGB", true)
				localPlayer:SetAttribute("DashInGlassBridge", true)
			end)
		end)
	else
		pcall(function()
			localPlayer:SetAttribute("CanDashInGB", nil)
			localPlayer:SetAttribute("DashInGlassBridge", nil)
		end)
	end

	if PlayToggleSound then
		PlayToggleSound()
	end

	return true
end

MainModule.is_hider = function(arg)
	return arg and arg:GetAttribute("IsHider") == true
end

MainModule.is_seeker = function(arg)
	return arg and arg:GetAttribute("IsHunter") == true
end

MainModule.is_hider = function(arg)
	local v2 = arg or localPlayer
	local flag = false

	pcall(function()
		if v2:GetAttribute("IsHider") == true or v2:GetAttribute("ishider") == true or v2:GetAttribute("Hider") == true then
			flag = true
		end

		local attribute = v2:GetAttribute("Role") or v2:GetAttribute("Team")

		if attribute == "Hider" or attribute == "hider" then
			flag = true
		end

		local character = v2.Character

		if character then
			if character:GetAttribute("IsHider") or character:GetAttribute("Hider") then
				flag = true
			end

			if character:FindFirstChild("IsHider") then
				flag = true
			end
		end
	end)

	return flag
end

MainModule.is_seeker = function(arg)
	local v2 = arg or localPlayer
	local flag = false

	pcall(function()
		if v2:GetAttribute("IsHunter") == true or v2:GetAttribute("IsSeeker") == true or v2:GetAttribute("ishunter") == true then
			flag = true
		end

		local attribute = v2:GetAttribute("Role") or v2:GetAttribute("Team")

		if attribute == "Hunter" or attribute == "Seeker" or attribute == "hunter" or attribute == "seeker" then
			flag = true
		end

		local character = v2.Character

		if character then
			if character:GetAttribute("IsHunter") or character:GetAttribute("IsSeeker") then
				flag = true
			end
		end
	end)

	return flag
end

MainModule.is_guard_target = function(arg)
	if not arg then
		return false
	end
	local flag = false

	pcall(function()
		if arg:GetAttribute("IsGuard") == true or arg:GetAttribute("isGuard") == true then
			flag = true
		end

		local character = arg.Character
		local attribute

		if character then
			attribute = character:GetAttribute("IsGuard") or character:GetAttribute("isGuard")
		else
			attribute = character
		end

		if attribute then
			flag = true
		end
	end)

	return flag
end

MainModule.PlayerAttachEnabled = false
MainModule.attachedTarget = nil
MainModule.attachConnection = nil
MainModule.autoSearchConnection = nil

MainModule.AttachConfig = {
	BehindDistance = 5.2,
	FrontDistance = 10,
	LerpAlpha = 0.5,
	SwitchSpeed = 0.4,
	MaxStep = 16,
	LeadFactor = 1.2,
	FrontOnlySpeed = 18,
}

MainModule.find_best_target = function()
	local character = localPlayer.Character
	character = character and character:FindFirstChild("HumanoidRootPart")
	if not character then
		return nil
	end
	local v2 = MainModule.is_seeker(localPlayer)
	local v3 = MainModule.is_hider(localPlayer)
	local huge = math.huge
	local v4 = nil

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoidRootPart and humanoid.Health > 0 then
				if v2 then
					if MainModule.is_hider(player) or MainModule.is_guard_target(player) then
						local magnitude = (humanoidRootPart.Position - character.Position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v4 = player
						end
					end
				elseif v3 then
					if MainModule.is_seeker(player) then
						local magnitude = (humanoidRootPart.Position - character.Position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v4 = player
						end
					end
				else
					local magnitude = (humanoidRootPart.Position - character.Position).Magnitude

					if magnitude < huge then
						huge = magnitude
						v4 = player
					end
				end
			end
		end
	end

	return v4
end

MainModule.detach = function()
	if MainModule.attachConnection then
		pcall(function()
			MainModule.attachConnection:Disconnect()
		end)

		MainModule.attachConnection = nil
	end

	MainModule.attachedTarget = nil
	local character = localPlayer.Character

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.PlatformStand = false
			humanoid.AutoRotate = true
		end
	end

	if MainModule.FaceTargetModule and MainModule.FaceTargetModule.Enabled then
		pcall(function()
			MainModule.toggle_face_target(false)
		end)

		pcall(function()
			if ToggleRefs and MainModule.ToggleRefs.FaceTarget then
				MainModule.ToggleRefs.FaceTarget:SetValue(false)
			end
		end)
	end
end

MainModule.attachToPlayer = function(attachedTarget)
	if not attachedTarget or not attachedTarget.Character then
		return false
	end

	if MainModule.attachedTarget == attachedTarget and MainModule.attachConnection then
		return true
	end
	MainModule.detach()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	character = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoidRootPart or not character then
		return false
	end
	local humanoidRootPart2 = attachedTarget.Character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart2 then
		return false
	end
	MainModule.attachedTarget = attachedTarget
	local lookVector = humanoidRootPart2.CFrame.LookVector
	local n = humanoidRootPart2.Position - lookVector * MainModule.AttachConfig.BehindDistance
	local cframe = CFrame.Angles
	local n2 = -lookVector.X
	humanoidRootPart.CFrame = CFrame.new(n.X, humanoidRootPart2.Position.Y, n.Z) * cframe(0, math.atan2(n2, -lookVector.Z), 0)

	if not (MainModule.FaceTargetModule and MainModule.FaceTargetModule.Enabled) then
		pcall(function()
			MainModule.toggle_face_target(true)
		end)

		pcall(function()
			if ToggleRefs and MainModule.ToggleRefs.FaceTarget then
				MainModule.ToggleRefs.FaceTarget:SetValue(true)
			end
		end)
	end

	MainModule.attachConnection = RunService.Heartbeat:Connect(function()
		if not MainModule.PlayerAttachEnabled or not MainModule.attachedTarget then
			MainModule.detach()
			return
		end
		local attachedTarget2 = MainModule.attachedTarget

		if not attachedTarget2.Character then
			local v2 = MainModule.find_best_target()

			if v2 then
				MainModule.attachToPlayer(v2)
			else
				MainModule.detach()
			end

			return
		end

		local humanoidRootPart3 = attachedTarget2.Character:FindFirstChild("HumanoidRootPart")
		local humanoid = attachedTarget2.Character:FindFirstChildOfClass("Humanoid")
		local character2 = localPlayer.Character
		character2 = character2 and character2:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart3 or not humanoid or humanoid.Health <= 0 or not character2 then
			local v2 = MainModule.find_best_target()

			if v2 and v2 ~= attachedTarget2 then
				MainModule.attachToPlayer(v2)
			else
				MainModule.detach()
			end

			return
		end

		local lookVector2 = humanoidRootPart3.CFrame.LookVector
		local vector = Vector3.new()

		pcall(function()
			vector = humanoidRootPart3.AssemblyLinearVelocity or humanoidRootPart3.Velocity or Vector3.new()
		end)

		local vector2 = Vector3.new(vector.X, 0, vector.Z)
		local flag = vector2.Magnitude > (MainModule.AttachConfig.FrontOnlySpeed or 22) and vector2.Magnitude > 0.1
		local flag2 = false

		if flag then
			local unit = vector2.Unit
			local vector3 = Vector3.new(lookVector2.X, 0, lookVector2.Z)

			if vector3.Magnitude > 0.1 and unit:Dot(vector3.Unit) > 0.85 then
				flag2 = true
			end
		end

		local n3 = (flag2 and lookVector2 or -lookVector2) * (flag2 and MainModule.AttachConfig.FrontDistance or MainModule.AttachConfig.BehindDistance)
		local n4 = vector * (MainModule.AttachConfig.LeadFactor or 1.35) * 0.05
		local n5 = humanoidRootPart3.Position + n3 + Vector3.new(n4.X, 0, n4.Z)
		local vector3 = Vector3.new(n5.X, humanoidRootPart3.Position.Y, n5.Z)
		local switchSpeed = flag2 and MainModule.AttachConfig.SwitchSpeed or MainModule.AttachConfig.LerpAlpha
		local position = character2.Position
		local n6 = vector3 - position
		local maxStep = MainModule.AttachConfig.MaxStep or 18

		if maxStep < n6.Magnitude then
			vector3 = position + n6.Unit * maxStep
		end

		local n7

		if n6.Magnitude > 20 then
			n7 = 0.85
		elseif n6.Magnitude > 10 then
			n7 = math.max(switchSpeed, 0.65)
		else
			n7 = switchSpeed
		end

		local vector4 = Vector3.new(position.X + (vector3.X - position.X) * n7, humanoidRootPart3.Position.Y, position.Z + (vector3.Z - position.Z) * n7)
		local position2 = humanoidRootPart3.Position
		character2.CFrame = CFrame.new(vector4, Vector3.new(position2.X, vector4.Y, position2.Z))
	end)

	return true
end

MainModule.startAutoSearch = function()
	if MainModule.autoSearchConnection then
		pcall(function()
			MainModule.autoSearchConnection:Disconnect()
		end)

		MainModule.autoSearchConnection = nil
	end

	MainModule.autoSearchConnection = RunService.Heartbeat:Connect(function()
		if not MainModule.PlayerAttachEnabled then
			return
		end

		if MainModule.attachedTarget then
			return
		end

		if tick() % 0.5 < 0.03 then
			local v2 = MainModule.find_best_target()

			if v2 then
				MainModule.attachToPlayer(v2)
			end
		end
	end)
end

MainModule.toggle_player_attach = function(arg)
	local playerAttachEnabled = arg and true or false
	MainModule.PlayerAttachEnabled = playerAttachEnabled

	if playerAttachEnabled then
		MainModule._MovecheckFromAuto = true
		pcall(MainModule.HSX_MovecheckAutoStart)
		MainModule._MovecheckFromAuto = false
		local v2 = MainModule.find_best_target()

		if v2 then
			MainModule.attachToPlayer(v2)
			MainModule.startAutoSearch()
		else
			MainModule.PlayerAttachEnabled = false

			pcall(function()
				fn2("Player Attach", "No target found", 0.9)
			end)

			pcall(function()
				if ToggleRefs and MainModule.ToggleRefs.PlayerAttach then
					MainModule.ToggleRefs.PlayerAttach:SetValue(false)
				end
			end)
		end
	else
		pcall(MainModule.HSX_MovecheckAutoStop)

		if MainModule.autoSearchConnection then
			pcall(function()
				MainModule.autoSearchConnection:Disconnect()
			end)

			MainModule.autoSearchConnection = nil
		end

		MainModule.detach()
	end

	if PlayToggleSound then
		PlayToggleSound()
	end

	return true
end

MainModule.FaceTargetModule = { Enabled = false, Connection = nil }

MainModule.toggle_face_target = function(enabled)
	if type(enabled) ~= "boolean" then
		enabled = not MainModule.FaceTargetModule.Enabled
	end

	if MainModule.FaceTargetModule.Connection then
		MainModule.FaceTargetModule.Connection:Disconnect()
		MainModule.FaceTargetModule.Connection = nil
	end

	MainModule.FaceTargetModule.Enabled = enabled

	if enabled then
		MainModule.FaceTargetModule.Connection = RunService.Heartbeat:Connect(function()
			if not MainModule.FaceTargetModule.Enabled then
				return
			end
			local character = localPlayer.Character
			if not character then
				return
			end
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end
			local position = humanoidRootPart.Position
			local huge = math.huge
			local v2 = nil

			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= localPlayer and player.Character then
					local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 then
						local magnitude = (humanoidRootPart2.Position - position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v2 = player
						end
					end
				end
			end

			if v2 and v2.Character then
				local humanoidRootPart2 = v2.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					local cframe = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart2.Position)
					local n = cframe - cframe.Position
					humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * n
				end
			end
		end)
	end

	PlayToggleSound()
end

MainModule.AutoDodge = {
	Enabled = false,
	AnimationIds = {
		"rbxassetid://88451099342711",
		"rbxassetid://79649041083405",
		"rbxassetid://73242877658272",
		"rbxassetid://114928327045353",
		"rbxassetid://135690448001690",
		"rbxassetid://103355259844069",
		"rbxassetid://125906547773381",
		"rbxassetid://121147456137931",
		"rbxassetid://96924216250322",
		"rbxassetid://116839849594540",
		"rbxassetid://104041807075625",
		"rbxassetid://83057176809194",
		"rbxassetid://103318207627541",
		"rbxassetid://121473077508383",
		"rbxassetid://94215646393565",
		"rbxassetid://81533666958052",
		"rbxassetid://116839849594540",
	},
	Connections = {},
	LastDodgeTime = 0,
	DodgeCooldown = 0.9,
	Range = 3.8,
	RangeSquared = 14.44,
	AnimationIdsSet = {},
	ActiveAnimations = {},
	LastAnimationStartTime = {},
	CapturedCall = nil,
	LastCapturedCallTime = 0,
	OriginalFireServer = nil,
	Remote = nil,
	HeartbeatConnection = nil,
	DodgeAttempts = {},
}

for _, animationId in ipairs(MainModule.AutoDodge.AnimationIds) do
	MainModule.AutoDodge.AnimationIdsSet[animationId] = true
end

MainModule.getLocalPlayer = function()
	local ok, result = pcall(function()
		return game:GetService("Players").LocalPlayer
	end)

	if ok and result then
		return result
	end
	return nil
end

MainModule.setupRemoteHook = function()
	return false
end

MainModule.executeDodge = function()
	if not MainModule.AutoDodge.Enabled then
		return false
	end
	local now = tick()
	if now - MainModule.AutoDodge.LastDodgeTime < MainModule.AutoDodge.DodgeCooldown then
		return false
	end
	local v2 = MainModule.getLocalPlayer()
	if not v2 then
		return false
	end
	local backpack = v2.Backpack
	if not backpack then
		return false
	end
	local dodge = backpack:FindFirstChild("DODGE!")

	if not dodge then
		local character = v2.Character

		if character then
			dodge = character:FindFirstChild("DODGE!")
		end
	end

	if not dodge then
		return false
	end
	local playerGui = v2:FindFirstChild("PlayerGui")
	playerGui = playerGui and playerGui:FindFirstChild("Hotbar")
	local backpack2 = playerGui and playerGui:FindFirstChild("Backpack")
	backpack2 = backpack2 and backpack2:FindFirstChild("Hotbar")
	if not backpack2 then
		return false
	end
	local v3 = nil

	for _, child in pairs(backpack2:GetChildren()) do
		local toolName = child:FindFirstChild("ToolName")
		if toolName and toolName.Text == "DODGE!" then
			v3 = child
			break
		end
	end

	if not v3 then
		return false
	end
	MainModule.AutoDodge.LastDodgeTime = now

	return pcall(function()
		if getconnections then
			for _, v4 in pairs(getconnections(v3.MouseButton1Down)) do
				pcall(function()
					v4:Fire()
				end)
			end

			task.wait(0.05)

			for _, v4 in pairs(getconnections(v3.MouseButton1Up)) do
				pcall(function()
					v4:Fire()
				end)
			end
		end
	end) and true or false
end

MainModule.isLookingAtPlayer = function(arg, arg2)
	if not arg or not arg.Character then
		return false
	end

	if not arg2 or not arg2.Character then
		return false
	end
	local head = arg.Character:FindFirstChild("Head")
	local humanoidRootPart = arg2.Character:FindFirstChild("HumanoidRootPart")
	if not (head and humanoidRootPart) then
		return false
	end
	return (humanoidRootPart.Position - head.Position).Unit:Dot(head.CFrame.LookVector) > 0.1
end

MainModule.setupHeartbeatProcessing = function()
	MainModule.AutoDodge.HeartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
		if not MainModule.AutoDodge.Enabled then
			return
		end
		local v2 = MainModule.getLocalPlayer()
		if not v2 or not v2.Character then
			return
		end
		local lastDodgeTime = MainModule.AutoDodge.LastDodgeTime
		if tick() - lastDodgeTime < MainModule.AutoDodge.DodgeCooldown then
			return
		end
		local humanoidRootPart = v2.Character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			return
		end
		local v3 = pairs
		local Players2 = game:GetService("Players")

		for _, player in v3(Players2:GetPlayers()) do
			if player ~= v2 and player.Character then
				local character = player.Character
				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					if MainModule.AutoDodge.RangeSquared < (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude then
						MainModule.AutoDodge.ActiveAnimations[player.Name] = nil
						continue
					end

					if MainModule.isLookingAtPlayer(player, v2) then
						local humanoid = character:FindFirstChild("Humanoid")

						if humanoid then
							local playingAnimationTracks = humanoid:GetPlayingAnimationTracks()

							for _, playingAnimationTrack in pairs(playingAnimationTracks) do
								if playingAnimationTrack and playingAnimationTrack.Animation and playingAnimationTrack.IsPlaying then
									local animationId = playingAnimationTrack.Animation.AnimationId

									if MainModule.AutoDodge.AnimationIdsSet[animationId] then
										if not MainModule.AutoDodge.ActiveAnimations[player.Name] then
											MainModule.AutoDodge.ActiveAnimations[player.Name] = {}
										end

										if not MainModule.AutoDodge.ActiveAnimations[player.Name][animationId] then
											MainModule.AutoDodge.ActiveAnimations[player.Name][animationId] = true

											if MainModule.executeDodge() then
												if playingAnimationTrack.Stopped then
													playingAnimationTrack.Stopped:Once(function()
														if MainModule.AutoDodge.ActiveAnimations[player.Name] then
															MainModule.AutoDodge.ActiveAnimations[player.Name][animationId] = nil
														end
													end)
												else
													task.delay(2, function()
														if MainModule.AutoDodge.ActiveAnimations[player.Name] then
															MainModule.AutoDodge.ActiveAnimations[player.Name][animationId] = nil
														end
													end)
												end

												return
											end

											MainModule.AutoDodge.ActiveAnimations[player.Name][animationId] = nil
											continue
										end
									end
								end
							end

							continue
						end

						continue
					end
				end
			end
		end
	end)

	table.insert(MainModule.AutoDodge.Connections, MainModule.AutoDodge.HeartbeatConnection)
end

MainModule.setupPlayerCleanupTracking = function()
	local Players2 = game:GetService("Players")

	local function fn3(arg, arg2)
		local humanoid = arg2:FindFirstChild("Humanoid")

		if humanoid then
			humanoid.Died:Once(function()
				MainModule.AutoDodge.ActiveAnimations[arg.Name] = nil
				MainModule.AutoDodge.LastAnimationStartTime[arg.Name] = nil
			end)
		end
	end

	local function fn4(player)
		if player == MainModule.getLocalPlayer() then
			return
		end

		if player.Character then
			fn3(player, player.Character)
		end

		local connection = player.CharacterAdded:Connect(function(character)
			fn3(player, character)
		end)

		table.insert(MainModule.AutoDodge.Connections, connection)
	end

	for _, player in pairs(Players2:GetPlayers()) do
		fn4(player)
	end

	local connection = Players2.PlayerAdded:Connect(fn4)
	table.insert(MainModule.AutoDodge.Connections, connection)
end

MainModule.setupLeaveCleanup = function()
	local Players2 = game:GetService("Players")
	local v2 = MainModule.getLocalPlayer()

	if v2 then
		local connection = Players2.PlayerRemoving:Connect(function(player)
			if player == v2 then
				MainModule.toggle_auto_dodge(false)
			else
				MainModule.AutoDodge.ActiveAnimations[player.Name] = nil
				MainModule.AutoDodge.LastAnimationStartTime[player.Name] = nil
			end
		end)

		table.insert(MainModule.AutoDodge.Connections, connection)
	end
end

MainModule.toggle_auto_dodge = function(arg)
	local autoDodge = MainModule.ToggleRefs and MainModule.ToggleRefs.AutoDodge

	if arg then
		if MainModule.can_enable_toggle and not MainModule.can_enable_toggle("HideAndSeek", "Auto Dodge", autoDodge) then
			return false
		end

		pcall(function()
			local autoUse = localPlayer:FindFirstChild("AutoUse")

			if autoUse and autoUse:IsA("ValueBase") and autoUse.Value == false then
				MainModule._AutoDodgeSavedAutoUse = false
				autoUse.Value = true
			elseif localPlayer:GetAttribute("AutoUse") == false then
				MainModule._AutoDodgeSavedAutoUse = false
				localPlayer:SetAttribute("AutoUse", true)
			end
		end)

		pcall(function()
			local dodge = localPlayer.Character and localPlayer.Character:FindFirstChild("DODGE!") or localPlayer.Backpack and localPlayer.Backpack:FindFirstChild("DODGE!")

			if dodge then
				local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid:EquipTool(dodge)
					task.wait(0.15)
					dodge:Activate()
				end
			end
		end)
	end

	for _, connection in pairs(MainModule.AutoDodge.Connections) do
		if connection then
			pcall(function()
				connection:Disconnect()
			end)
		end
	end

	MainModule.AutoDodge.Enabled = false
	MainModule.AutoDodge.Connections = {}
	MainModule.AutoDodge.ActiveAnimations = {}
	MainModule.AutoDodge.LastAnimationStartTime = {}
	MainModule.AutoDodge.LastDodgeTime = 0
	MainModule.AutoDodge.HeartbeatConnection = nil

	if arg then
		MainModule.AutoDodge.Enabled = true
		MainModule.setupPlayerCleanupTracking()
		MainModule.setupHeartbeatProcessing()
		MainModule.setupLeaveCleanup()
	else
		pcall(function()
			if MainModule._AutoDodgeSavedAutoUse == false then
				local autoUse = localPlayer:FindFirstChild("AutoUse")

				if autoUse and autoUse:IsA("ValueBase") then
					autoUse.Value = false
				end

				localPlayer:SetAttribute("AutoUse", false)
				MainModule._AutoDodgeSavedAutoUse = nil
			end
		end)
	end

	if PlayToggleSound then
		PlayToggleSound()
	end

	return true
end

MainModule.AutoUltraInstinct = {
	Enabled = false,
	ViewOwnHitboxes = false,
	AnimationIds = {
		"rbxassetid://88451099342711",
		"rbxassetid://79649041083405",
		"rbxassetid://73242877658272",
		"rbxassetid://114928327045353",
		"rbxassetid://135690448001690",
		"rbxassetid://103355259844069",
		"rbxassetid://125906547773381",
		"rbxassetid://121147456137931",
		"rbxassetid://96924216250322",
		"rbxassetid://116839849594540",
		"rbxassetid://104041807075625",
		"rbxassetid://83057176809194",
		"rbxassetid://103318207627541",
		"rbxassetid://121473077508383",
		"rbxassetid://94215646393565",
		"rbxassetid://81533666958052",
		"rbxassetid://116839849594540",
		"rbxassetid://85793691404836",
		"rbxassetid://86197206792061",
		"rbxassetid://87978085217719",
		"rbxassetid://85623602463927",
		"rbxassetid://103062305177426",
		"rbxassetid://99157505926076",
		"rbxassetid://114769224376981",
		"rbxassetid://9783204720378",
		"rbxassetid://94443309383954",
		"rbxassetid://98785078701251",
		"rbxassetid://123072675259257",
		"rbxassetid://85743982894847",
		"rbxassetid://89439896387299",
		"rbxassetid://97863204720378",
		"rbxassetid://106756593687295",
		"rbxassetid://81816623746576",
		"rbxassetid://81392013026663",
		"rbxassetid://109822392402606",
		"rbxassetid://134675465964672",
		"rbxassetid://137659772694747",
		"rbxassetid://85756694343517",
		"rbxassetid://131235569946744",
		"rbxassetid://76323709902827",
		"rbxassetid://73150160715773",
	},
	Connections = {},
	AnimationIdsSet = {},
	DodgedHitboxes = {},
	LastDodgeTime = 0,
	MinDodgeInterval = 0.02,
	LastLookVectors = {},
	Active6663Hitbox = nil,
	IsDodging6663 = false,
	Dodge6663Count = 0,
	Max6663Dodges = 200,
	IsInside6663Hitbox = false,
	SpecialAnimations = { ["1123072675259257"] = true, ["99157505926076"] = true },
	SpecialAnimationData = {},
	SpecialDodgeRadius = 20,
	SpecialTrackRadius = 1500,
	IsInitialized = false,
}

for _, animationId in ipairs(MainModule.AutoUltraInstinct.AnimationIds) do
	MainModule.AutoUltraInstinct.AnimationIdsSet[animationId] = true
end

MainModule.AUI_cachedTool = nil
MainModule.AUI_lastToolCheck = 0

MainModule.AUI_findUltraTool = function()
	local now = tick()
	if MainModule.AUI_cachedTool and now - MainModule.AUI_lastToolCheck < 0.3 then
		return MainModule.AUI_cachedTool
	end
	local localPlayer2 = Players.LocalPlayer
	if not localPlayer2 then
		return nil
	end
	local character = localPlayer2.Character

	if character then
		for _, child in pairs(character:GetChildren()) do
			if child:IsA("Tool") and child.Name:lower():find("ultra") then
				MainModule.AUI_cachedTool = child
				MainModule.AUI_lastToolCheck = now
				return child
			end
		end
	end

	local backpack = localPlayer2:FindFirstChild("Backpack")

	if backpack then
		for _, child in pairs(backpack:GetChildren()) do
			if child:IsA("Tool") and child.Name:lower():find("ultra") then
				MainModule.AUI_cachedTool = child
				MainModule.AUI_lastToolCheck = now
				return child
			end
		end
	end

	MainModule.AUI_cachedTool = nil
	MainModule.AUI_lastToolCheck = now
	return nil
end

MainModule.AUI_pressUltraHotbar = function()
	local v2 = MainModule.AUI_findUltraTool()
	if not v2 then
		return false
	end
	local name = v2.Name
	local localPlayer2 = Players.LocalPlayer
	if not localPlayer2 then
		return false
	end
	local hotbar = localPlayer2:FindFirstChild("PlayerGui") and localPlayer2.PlayerGui:FindFirstChild("Hotbar")
	if not hotbar then
		return false
	end
	local backpack = hotbar:FindFirstChild("Backpack")
	if not backpack then
		return false
	end
	local hotbar2 = backpack:FindFirstChild("Hotbar")
	if not hotbar2 then
		return false
	end
	local v3 = nil

	for _, child in pairs(hotbar2:GetChildren()) do
		local toolName = child:FindFirstChild("ToolName")
		if toolName and toolName.Text == name then
			v3 = child
			break
		end
	end

	if not v3 then
		return false
	end

	if not getconnections then
		return false
	end

	return (pcall(function()
		for _, v4 in pairs(getconnections(v3.MouseButton1Down)) do
			pcall(function()
				v4:Fire()
			end)
		end

		task.wait(0.05)

		for _, v4 in pairs(getconnections(v3.MouseButton1Up)) do
			pcall(function()
				v4:Fire()
			end)
		end
	end))
end

MainModule.AUI_isEnemyLookingAtUs = function(arg, arg2, arg3)
	local autoUltraInstinct = MainModule.AutoUltraInstinct
	local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return false, 0, false
	end
	local lookVector = humanoidRootPart.CFrame.LookVector
	local v2 = lookVector:Dot((arg2 - humanoidRootPart.Position).Unit)
	local v3 = autoUltraInstinct.LastLookVectors[arg3]
	local flag = false

	if v3 then
		if math.acos(math.clamp(lookVector:Dot(v3.vector), -1, 1)) > 0.25 then
			flag = true
		end
	end

	autoUltraInstinct.LastLookVectors[arg3] = { vector = lookVector, time = tick() }
	return v2 > 0.05 or flag, v2, flag
end

MainModule.AUI_executeUltraNow = function(arg)
	local autoUltraInstinct = MainModule.AutoUltraInstinct
	if not autoUltraInstinct.Enabled then
		return false
	end
	local now = tick()
	local flag = arg and (string.find(arg, "6663") or autoUltraInstinct.Active6663Hitbox and arg == autoUltraInstinct.Active6663Hitbox.hitboxId .. "_touch")

	if flag then
		if not autoUltraInstinct.IsInside6663Hitbox then
			return false
		end

		if not autoUltraInstinct.Active6663Hitbox or not autoUltraInstinct.Active6663Hitbox.active then
			return false
		end

		if autoUltraInstinct.Max6663Dodges <= autoUltraInstinct.Dodge6663Count then
			return false
		end
	else
		if now - autoUltraInstinct.LastDodgeTime < autoUltraInstinct.MinDodgeInterval then
			return false
		end

		if autoUltraInstinct.DodgedHitboxes[arg] then
			return false
		end
		autoUltraInstinct.DodgedHitboxes[arg] = true
	end

	local v2 = MainModule.AUI_pressUltraHotbar()

	if v2 then
		if not flag then
			autoUltraInstinct.LastDodgeTime = now
		else
			autoUltraInstinct.Dodge6663Count = autoUltraInstinct.Dodge6663Count + 1
		end
	end

	if not flag then
		task.spawn(function()
			task.wait(1.5)
			autoUltraInstinct.DodgedHitboxes[arg] = nil
		end)
	end

	return v2
end

MainModule.AUI_startLimitedDodgeFor6663 = function(active6663Hitbox)
	local autoUltraInstinct = MainModule.AutoUltraInstinct
	if autoUltraInstinct.IsDodging6663 then
		return
	end
	autoUltraInstinct.IsDodging6663 = true
	autoUltraInstinct.Active6663Hitbox = active6663Hitbox
	autoUltraInstinct.Dodge6663Count = 0
	autoUltraInstinct.IsInside6663Hitbox = true

	task.spawn(function()
		while true do
			if autoUltraInstinct.IsDodging6663 and active6663Hitbox and active6663Hitbox.active and autoUltraInstinct.Dodge6663Count < autoUltraInstinct.Max6663Dodges then
				if autoUltraInstinct.IsInside6663Hitbox then
					if not (not active6663Hitbox.active or not active6663Hitbox.frontHitbox or not active6663Hitbox.frontHitbox.Parent) then
						if not MainModule.AUI_executeUltraNow(active6663Hitbox.hitboxId .. "_touch", "6663 TOUCH DODGE") then
							task.wait(0.01)
						else
							task.wait(0.03)
						end

						continue
					end
				end
			end

			break
		end

		autoUltraInstinct.IsDodging6663 = false
		autoUltraInstinct.Active6663Hitbox = nil
		autoUltraInstinct.IsInside6663Hitbox = false
	end)
end

MainModule.AUI_setupHitboxUpdater = function(arg, arg2, arg3, arg4)
	if arg4 then
		return nil
	end
	local v2 = nil

	return (RunService.RenderStepped:Connect(function()
		if not MainModule.AutoUltraInstinct.Enabled then
			if v2 then
				v2:Disconnect()
			end

			return
		end

		if not arg or not arg.Parent then
			if v2 then
				v2:Disconnect()
			end

			return
		end

		if not arg2 or not arg2.Parent then
			if v2 then
				v2:Disconnect()
			end

			return
		end

		arg.CFrame = arg2.CFrame * arg3
	end))
end

MainModule.AUI_getAnimationLength = function(arg)
	local ok, result = pcall(function()
		return arg.Length
	end)

	return ok and result or 1
end

MainModule.AUI_getForwardLength = function(arg, arg2)
	if arg2 then
		return 55
	end
	local n

	if arg:find("99157505926076") or arg:find("123072675259257") then
		n = 16
	else
		local pos = arg:find("73242877658272") or arg:find("79649041083405")
		n = 5

		if pos then
			n = 6.5
		end
	end

	return n
end

MainModule.AUI_setupSpecialAnimationTracking = function(arg, arg2, arg3)
	local autoUltraInstinct = MainModule.AutoUltraInstinct
	local match = arg2:match("(%d+)$") or arg2:match("/(%d+)$")
	if not match then
		return
	end

	if not autoUltraInstinct.SpecialAnimations[match] then
		return
	end
	local character = arg.Character
	if not character then
		return
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end
	local localPlayer2 = Players.LocalPlayer
	if arg == localPlayer2 then
		return
	end
	local str = tostring(tick()) .. "_" .. tostring(arg.Name) .. "_special_" .. match
	local flag = true
	local flag2 = false
	local connection = nil

	autoUltraInstinct.SpecialAnimationData[str] = {
		active = true,
		character = character,
		humanoidRootPart = humanoidRootPart,
		player = arg,
		animId = match,
		hasDodged = false,
		startTime = tick(),
		isTracking = false,
	}

	connection = RunService.Heartbeat:Connect(function()
		if not autoUltraInstinct.Enabled then
			if connection then
				connection:Disconnect()
			end

			return
		end

		if not flag or flag2 then
			if connection then
				connection:Disconnect()
			end

			return
		end

		local character2 = localPlayer2.Character
		if not character2 then
			return
		end
		local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart2 then
			return
		end

		if not character or not character.Parent or not humanoidRootPart or not humanoidRootPart.Parent then
			flag = false

			if connection then
				connection:Disconnect()
			end

			return
		end

		if (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= autoUltraInstinct.SpecialDodgeRadius then
			if not flag2 then
				flag2 = true
				autoUltraInstinct.SpecialAnimationData[str].hasDodged = true

				if connection then
					connection:Disconnect()
				end

				MainModule.AUI_executeUltraNow(str .. "_special_dodge", "SPECIAL ANIMATION DODGE")
			end
		end
	end)

	task.spawn(function()
		while flag and arg3 and arg3.IsPlaying do
			task.wait(0.03)
		end

		flag = false

		if connection then
			connection:Disconnect()
		end

		autoUltraInstinct.SpecialAnimationData[str] = nil
	end)
end

MainModule.AUI_createHitbox = function(arg, arg2, arg3, arg4)
	local autoUltraInstinct = MainModule.AutoUltraInstinct
	if not autoUltraInstinct.Enabled then
		return nil
	end
	local localPlayer2 = Players.LocalPlayer
	local match = arg2:match("(%d+)$") or arg2:match("/(%d+)$")

	if match and autoUltraInstinct.SpecialAnimations[match] and arg4 ~= localPlayer2 then
		task.spawn(function()
			MainModule.AUI_setupSpecialAnimationTracking(arg4, arg2, arg3)
		end)

		return nil
	end

	if arg4 == localPlayer2 and not autoUltraInstinct.ViewOwnHitboxes then
		return nil
	end
	local flag = not arg
	if flag or not arg.Parent then
		return nil
	end
	local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
	local flag2 = not humanoidRootPart
	if flag2 then
		return nil
	end
	local character = localPlayer2 and localPlayer2.Character
	local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")
	local v2 = humanoidRootPart2 and humanoidRootPart
	local magnitude = nil

	if v2 then
		magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude
	end

	task.wait(0.01)
	if flag or not arg.Parent then
		return nil
	end

	if flag2 or not humanoidRootPart.Parent then
		return nil
	end

	if not arg3 or not arg3.IsPlaying then
		return nil
	end
	local anchored = arg2:find("6663") ~= nil
	local str = tostring(tick()) .. "_" .. tostring(arg.Name) .. "_" .. string.sub(arg2, -8)
	local v3 = MainModule.AUI_getAnimationLength(arg3)
	local n

	if anchored then
		n = v3 + 3.1
	else
		n = math.max(0.1, v3 - 0.1)
	end

	local cFrame = nil
	local position = nil

	if anchored then
		position = humanoidRootPart.Position
		cFrame = humanoidRootPart.CFrame
	end

	local v4 = MainModule.AUI_getForwardLength(arg2, anchored)
	local part = Instance.new("Part")

	if anchored then
		part.Name = "GiantHitbox_6663_STATIC_" .. tick()
		part.Size = Vector3.new(55, 32.5, 55)
		part.Color = Color3.fromRGB(255, 0, 100)
		part.Transparency = 0.35
		part.Anchored = true
	else
		part.Name = "Hitbox_Front_" .. string.sub(arg2, -6) .. "_" .. tick()
		part.Size = Vector3.new(8, 6, v4)
		part.Color = Color3.fromRGB(255, 50, 50)
		part.Transparency = 0.35
		part.Anchored = false
	end

	part.CanCollide = false
	part.Material = Enum.Material.Neon
	local cframe = CFrame.new(0, 1.2, -(v4 / 2 + 1.5))

	if anchored then
		part.CFrame = cFrame * cframe
	else
		part.CFrame = humanoidRootPart.CFrame * cframe
	end

	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Adornee = part
	selectionBox.Color3 = part.Color
	selectionBox.LineThickness = anchored and 0.35 or 0.12
	selectionBox.Transparency = 0.25
	selectionBox.Parent = part
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.Color = ColorSequence.new(part.Color)
	particleEmitter.Size = NumberSequence.new(anchored and 4 or 0.4)
	particleEmitter.Rate = anchored and 200 or 20
	particleEmitter.Lifetime = NumberRange.new(anchored and 1.5 or 0.25)
	particleEmitter.SpreadAngle = Vector2.new(360, 360)
	particleEmitter.VelocityInheritance = 0
	particleEmitter.Speed = NumberRange.new(anchored and 10 or 1.5)
	particleEmitter.Parent = part

	local tbl = {
		active = true,
		character = arg,
		frontHitbox = part,
		backHitbox = nil,
		hitboxId = str,
		animationStartTime = tick(),
		hasDodged = false,
		animationTrack = arg3,
		startDistance = magnitude,
		hasEnteredRadius = false,
		characterName = arg.Name,
		turnWindowEndTime = tick() + 1.4,
		is6663 = anchored,
		staticPosition = position,
		staticCFrame = cFrame,
	}

	if anchored then
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(255, 0, 100)
		pointLight.Range = 60
		pointLight.Brightness = 4
		pointLight.Parent = part
		local attachment = Instance.new("Attachment")
		attachment.Parent = part
		local smoke = Instance.new("Smoke")
		smoke.Color = Color3.fromRGB(255, 0, 100)
		smoke.Opacity = 0.5
		smoke.RiseVelocity = 5
		smoke.Size = 12
		smoke.Parent = attachment
		local part2 = Instance.new("Part")
		part2.Name = "RotationEffect"
		part2.Size = Vector3.new(60, 2, 60)
		part2.Shape = Enum.PartType.Cylinder
		part2.Color = Color3.fromRGB(255, 0, 100)
		part2.Transparency = 0.7
		part2.Material = Enum.Material.Neon
		part2.Anchored = true
		part2.CanCollide = false
		part2.CFrame = cFrame
		part2.Parent = Workspace

		task.spawn(function()
			local now = tick()

			while tbl.active and part2 and part2.Parent and autoUltraInstinct.Enabled do
				part2.CFrame = cFrame * CFrame.Angles(0, math.rad((tick() - now) * 180), 0)
				task.wait()
			end

			if part2 then
				pcall(function()
					part2:Destroy()
				end)
			end
		end)
	end

	part.Parent = Workspace
	local part2 = Instance.new("Part")
	part2.Name = "Hitbox_Back_" .. string.sub(arg2, -6) .. "_" .. tick()
	part2.Size = Vector3.new(0.8, 0.8, 0.8)
	part2.Color = Color3.fromRGB(255, 200, 100)
	part2.Transparency = 0.15
	part2.Material = Enum.Material.Neon
	part2.Anchored = anchored
	part2.CanCollide = false
	local cframe2 = CFrame.new(0, 0.3, 0.8)

	if anchored then
		part2.CFrame = cFrame * cframe2
	else
		part2.CFrame = humanoidRootPart.CFrame * cframe2
	end

	local selectionBox2 = Instance.new("SelectionBox")
	selectionBox2.Adornee = part2
	selectionBox2.Color3 = Color3.fromRGB(255, 200, 100)
	selectionBox2.LineThickness = 0.02
	selectionBox2.Transparency = 0.5
	selectionBox2.Parent = part2
	part2.Parent = Workspace
	tbl.backHitbox = part2
	local v5 = MainModule.AUI_setupHitboxUpdater(part, humanoidRootPart, cframe, anchored)
	local v6 = MainModule.AUI_setupHitboxUpdater(part2, humanoidRootPart, cframe2, anchored)

	if arg4 == localPlayer2 then
		task.spawn(function()
			if anchored then
				while arg3 and arg3.IsPlaying do
					task.wait(0.03)
				end

				task.wait(3.1)
			elseif n > 0 and n < v3 then
				task.wait(n)
			else
				while arg3 and arg3.IsPlaying do
					task.wait(0.03)
				end
			end

			tbl.active = false

			if anchored then
				autoUltraInstinct.IsDodging6663 = false
				autoUltraInstinct.Active6663Hitbox = nil
				autoUltraInstinct.IsInside6663Hitbox = false
			end

			if v5 then
				v5:Disconnect()
			end

			if v6 then
				v6:Disconnect()
			end

			if part and part.Parent then
				part:Destroy()
			end

			if part2 and part2.Parent then
				part2:Destroy()
			end
		end)

		return { part, part2 }
	end

	local connection = nil

	if not anchored then
		connection = RunService.RenderStepped:Connect(function()
			if not autoUltraInstinct.Enabled then
				if connection then
					connection:Disconnect()
				end

				return
			end

			if tbl.hasDodged or not tbl.active then
				if connection then
					connection:Disconnect()
				end

				return
			end

			local turnWindowEndTime = tbl.turnWindowEndTime

			if tick() > turnWindowEndTime then
				if connection then
					connection:Disconnect()
				end

				return
			end

			if not humanoidRootPart2 or not humanoidRootPart2.Parent then
				return
			end

			if not arg or not arg.Parent then
				return
			end
			local humanoidRootPart3 = arg:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart3 then
				return
			end

			if tbl.startDistance and tbl.startDistance > 5.5 and (humanoidRootPart3.Position - humanoidRootPart2.Position).Magnitude <= 5.5 then
				if not tbl.hasEnteredRadius then
					tbl.hasEnteredRadius = true
				end

				local v7, v8, v9 = MainModule.AUI_isEnemyLookingAtUs(arg, humanoidRootPart2.Position, tbl.characterName)

				if (v7 or v9) and tbl.hasEnteredRadius and tbl.active then
					tbl.hasDodged = true

					if connection then
						connection:Disconnect()
					end

					MainModule.AUI_executeUltraNow(str .. "_turn", "")
				end
			end
		end)
	end

	local function fn3(arg5, arg6)
		if not autoUltraInstinct.Enabled then
			return
		end

		if not humanoidRootPart2 or not humanoidRootPart2.Parent then
			return
		end
		local flag3

		if arg5 == humanoidRootPart2 then
			flag3 = true
		else
			local flag4 = character

			if character then
				flag4 = arg5.Parent == character or arg5:IsDescendantOf(character)
			end

			flag3 = false

			if flag4 then
				flag3 = true
			end
		end

		if flag3 then
			if anchored then
				if not tbl.hasDodged and tbl.active then
					tbl.hasDodged = true
					autoUltraInstinct.IsInside6663Hitbox = true
					MainModule.AUI_startLimitedDodgeFor6663(tbl)
				end
			elseif not tbl.hasDodged then
				tbl.hasDodged = true

				if connection then
					connection:Disconnect()
				end

				MainModule.AUI_executeUltraNow(arg6, "")
			end
		end
	end

	local function fn4(arg5)
		if not autoUltraInstinct.Enabled or not anchored or not tbl.active then
			return
		end
		local flag3

		if arg5 == humanoidRootPart2 then
			flag3 = true
		else
			local flag4 = character and (arg5.Parent == character or arg5:IsDescendantOf(character))
			flag3 = false

			if flag4 then
				flag3 = true
			end
		end

		if flag3 then
			autoUltraInstinct.IsInside6663Hitbox = false
		end
	end

	local str2 = str .. "_front"
	local str3 = str .. "_back"

	local connection2 = part.Touched:Connect(function(hit)
		fn3(hit, str2)
	end)

	local connection3 = part2.Touched:Connect(function(hit)
		fn3(hit, str3)
	end)

	local connection4 = nil

	if anchored then
		connection4 = part.TouchEnded:Connect(function(hit)
			fn4(hit)
		end)
	end

	local function fn5()
		tbl.active = false

		if anchored then
			autoUltraInstinct.IsDodging6663 = false
			autoUltraInstinct.Active6663Hitbox = nil
			autoUltraInstinct.IsInside6663Hitbox = false
		end

		if v5 then
			v5:Disconnect()
		end

		if v6 then
			v6:Disconnect()
		end

		if connection then
			connection:Disconnect()
		end

		if connection2 then
			connection2:Disconnect()
		end

		if connection3 then
			connection3:Disconnect()
		end

		if connection4 then
			connection4:Disconnect()
		end

		task.spawn(function()
			task.wait(2)
			autoUltraInstinct.LastLookVectors[tbl.characterName] = nil
		end)

		task.spawn(function()
			task.wait(1.5)

			if not anchored then
				autoUltraInstinct.DodgedHitboxes[str2] = nil
				autoUltraInstinct.DodgedHitboxes[str3] = nil
				autoUltraInstinct.DodgedHitboxes[str .. "_turn"] = nil
			end
		end)

		if part and part.Parent then
			part:Destroy()
		end

		if part2 and part2.Parent then
			part2:Destroy()
		end
	end

	task.spawn(function()
		if anchored then
			while arg3 and arg3.IsPlaying do
				task.wait(0.03)
			end

			task.wait(3.1)
		elseif n > 0 and n < v3 then
			task.wait(n)
		else
			while arg3 and arg3.IsPlaying do
				task.wait(0.03)
			end
		end

		fn5()
	end)

	return { part, part2 }
end

MainModule.AUI_destroyAllHitboxes = function()
	for _, child in pairs(Workspace:GetChildren()) do
		local isPart = child:IsA("Part")
		local pos

		if isPart then
			pos = child.Name:find("Hitbox") or child.Name:find("GiantHitbox") or child.Name:find("RotationEffect")
		else
			pos = isPart
		end

		if pos then
			pcall(function()
				child:Destroy()
			end)
		end
	end
end

MainModule.AUI_setupAnimationTracking = function()
	local autoUltraInstinct = MainModule.AutoUltraInstinct

	local function fn3(arg)
		if not arg then
			return
		end

		local function fn4(character)
			local humanoid = character:WaitForChild("Humanoid", 5)
			if not humanoid then
				return
			end

			local connection = humanoid.AnimationPlayed:Connect(function(arg2)
				if not autoUltraInstinct.Enabled then
					return
				end
				local animationId = arg2.Animation.AnimationId

				if autoUltraInstinct.AnimationIdsSet[animationId] then
					task.spawn(function()
						MainModule.AUI_createHitbox(arg.Character, animationId, arg2, arg)
					end)
				end
			end)

			table.insert(autoUltraInstinct.Connections, connection)
		end

		if arg.Character then
			fn4(arg.Character)
		end

		local connection = arg.CharacterAdded:Connect(fn4)
		table.insert(autoUltraInstinct.Connections, connection)
	end

	for _, player in pairs(Players:GetPlayers()) do
		task.spawn(function()
			fn3(player)
		end)
	end

	local connection = Players.PlayerAdded:Connect(function(player)
		fn3(player)
	end)

	table.insert(autoUltraInstinct.Connections, connection)
end

MainModule.toggle_auto_ultra_instinct = function(enabled)
	local autoUltraInstinct = MainModule.AutoUltraInstinct
	enabled = enabled and true or false
	autoUltraInstinct.Enabled = enabled

	if enabled then
		MainModule.PushAutoUseTrue("AutoUltraInstinct")
		MainModule.AUI_destroyAllHitboxes()

		if not autoUltraInstinct.IsInitialized then
			MainModule.AUI_setupAnimationTracking()

			task.spawn(function()
				while true do
					task.wait(5)
					local now = tick()

					for k, lastLookVector in pairs(autoUltraInstinct.LastLookVectors) do
						if now - lastLookVector.time > 2 then
							autoUltraInstinct.LastLookVectors[k] = nil
						end
					end
				end
			end)

			task.spawn(function()
				while true do
					task.wait(10)
					local now = tick()

					for k, v2 in pairs(autoUltraInstinct.SpecialAnimationData) do
						if v2.startTime and now - v2.startTime > 10 then
							autoUltraInstinct.SpecialAnimationData[k] = nil
						end
					end
				end
			end)

			autoUltraInstinct.IsInitialized = true
		end
	else
		MainModule.AUI_destroyAllHitboxes()
		autoUltraInstinct.IsDodging6663 = false
		autoUltraInstinct.Active6663Hitbox = nil
		autoUltraInstinct.Dodge6663Count = 0
		autoUltraInstinct.IsInside6663Hitbox = false
		autoUltraInstinct.SpecialAnimationData = {}
		MainModule.PopAutoUse("AutoUltraInstinct")
	end

	PlayToggleSound()
	return true
end

MainModule.ThrowHelper = {
	Enabled = false,
	Connection = nil,
	LockedTarget = nil,
	IsLocked = false,
	CurrentTarget = nil,
	LastLookTarget = nil,
	CheckInterval = 0.5,
	LastCheckTime = 0,
	DotThreshold = 0.3,
}

MainModule.FaceTargetModule = MainModule.ThrowHelper

MainModule.AutoThrow = {
	Enabled = false,
	LastThrowTime = 0,
	ThrowCooldown = 0.3,
	KeybindConnection = nil,
	TempFaceTask = nil,
	MobileButton = nil,
	IsThrowing = false,
}

MainModule.ThrowHelper_isLookingAtPlayer = function(arg, arg2)
	if not arg or not arg.Character then
		return false
	end

	if not arg2 or not arg2.Character then
		return false
	end
	local head = arg.Character:FindFirstChild("Head")
	local head2 = arg2.Character:FindFirstChild("Head")
	local humanoidRootPart = arg2.Character:FindFirstChild("HumanoidRootPart")
	if not (head and head2 and humanoidRootPart) then
		return false
	end
	local unit = (head.Position - head2.Position).Unit
	local dotThreshold = MainModule.ThrowHelper.DotThreshold
	return unit:Dot(head2.CFrame.LookVector) > dotThreshold
end

MainModule.ThrowHelper_findClosestPlayer = function()
	local character = localPlayer.Character
	if not character then
		return nil
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return nil
	end
	local position = humanoidRootPart.Position
	local huge = math.huge
	local v2 = nil

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 then
				local magnitude = (humanoidRootPart2.Position - position).Magnitude

				if magnitude < huge then
					huge = magnitude
					v2 = player
				end
			end
		end
	end

	return v2
end

MainModule.ThrowHelper_findPlayerLookingAt = function()
	local character = localPlayer.Character
	if not character then
		return nil
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return nil
	end
	local position = humanoidRootPart.Position
	local huge = math.huge
	local v2 = nil

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			if MainModule.ThrowHelper_isLookingAtPlayer(player, localPlayer) then
				local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					local magnitude = (humanoidRootPart2.Position - position).Magnitude

					if magnitude < huge then
						huge = magnitude
						v2 = player
					end
				end
			end
		end
	end

	if v2 then
		return v2
	end
	return MainModule.ThrowHelper_findClosestPlayer()
end

MainModule.ThrowHelper_selectTarget = function()
	local v2 = MainModule.ThrowHelper_findPlayerLookingAt()

	if v2 then
		MainModule.ThrowHelper.LockedTarget = v2
		MainModule.ThrowHelper.IsLocked = true
		return true
	end

	return false
end

MainModule.ThrowHelper_resetTarget = function()
	MainModule.ThrowHelper.LockedTarget = nil
	MainModule.ThrowHelper.IsLocked = false
	MainModule.ThrowHelper.CurrentTarget = nil
	MainModule.ThrowHelper.LastLookTarget = nil
end

MainModule.ThrowHelper_toggleFaceTarget = function(enabled, arg)
	if type(enabled) ~= "boolean" then
		enabled = not MainModule.ThrowHelper.Enabled
	end

	if MainModule.ThrowHelper.Connection then
		MainModule.ThrowHelper.Connection:Disconnect()
		MainModule.ThrowHelper.Connection = nil
	end

	MainModule.ThrowHelper.Enabled = enabled

	if enabled then
		if arg then
			MainModule.ThrowHelper_selectTarget()
		end

		MainModule.ThrowHelper.Connection = RunService.Heartbeat:Connect(function()
			if not MainModule.ThrowHelper.Enabled then
				return
			end
			local character = localPlayer.Character
			if not character then
				return
			end
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end

			if MainModule.ThrowHelper.IsLocked and MainModule.ThrowHelper.LockedTarget then
				if MainModule.ThrowHelper.LockedTarget.Character and MainModule.ThrowHelper.LockedTarget.Character:FindFirstChild("HumanoidRootPart") then
					local humanoidRootPart2 = MainModule.ThrowHelper.LockedTarget.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 then
						local cframe = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart2.Position)
						local n = cframe - cframe.Position
						humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * n
					end
				else
					MainModule.ThrowHelper_resetTarget()
					MainModule.ThrowHelper_selectTarget()
				end
			else
				local now = tick()

				if MainModule.ThrowHelper.CheckInterval <= now - MainModule.ThrowHelper.LastCheckTime then
					MainModule.ThrowHelper.LastCheckTime = now
					local v2 = MainModule.ThrowHelper_findPlayerLookingAt()

					if v2 then
						MainModule.ThrowHelper.LastLookTarget = v2
						MainModule.ThrowHelper.CurrentTarget = v2
					elseif MainModule.ThrowHelper.LastLookTarget and MainModule.ThrowHelper.LastLookTarget.Character then
						MainModule.ThrowHelper.CurrentTarget = MainModule.ThrowHelper.LastLookTarget
					else
						local v3 = MainModule.ThrowHelper_findClosestPlayer()
						MainModule.ThrowHelper.CurrentTarget = v3
						MainModule.ThrowHelper.LastLookTarget = v3
					end
				end

				MainModule.ThrowHelper.CurrentTarget = MainModule.ThrowHelper.LastLookTarget

				if MainModule.ThrowHelper.CurrentTarget and MainModule.ThrowHelper.CurrentTarget.Character then
					local humanoidRootPart2 = MainModule.ThrowHelper.CurrentTarget.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart2 then
						local cframe = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart2.Position)
						local n = cframe - cframe.Position
						humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * n
					end
				end
			end
		end)
	else
		MainModule.ThrowHelper_resetTarget()
	end
end

MainModule.AutoThrow_findThrowTool = function()
	if localPlayer.Backpack then
		for _, child in pairs(localPlayer.Backpack:GetChildren()) do
			if child:IsA("Tool") and string.find(child.Name, "Throw") then
				return child
			end
		end
	end

	if localPlayer.Character then
		for _, child in pairs(localPlayer.Character:GetChildren()) do
			if child:IsA("Tool") and string.find(child.Name, "Throw") then
				return child
			end
		end
	end

	return nil
end

MainModule.AutoThrow_executeThrow = function()
	if not MainModule.AutoThrow.Enabled then
		return false
	end
	local now = tick()
	if now - MainModule.AutoThrow.LastThrowTime < MainModule.AutoThrow.ThrowCooldown then
		return false
	end
	local v2 = MainModule.AutoThrow_findThrowTool()
	if not v2 then
		return false
	end
	local hotbar = localPlayer.PlayerGui:FindFirstChild("Hotbar")
	if not hotbar then
		return false
	end
	local backpack = hotbar:FindFirstChild("Backpack")
	if not backpack then
		return false
	end
	local hotbar2 = backpack:FindFirstChild("Hotbar")
	if not hotbar2 then
		return false
	end
	local v3 = nil

	for _, child in pairs(hotbar2:GetChildren()) do
		if child:FindFirstChild("ToolName") and child.ToolName.Text == v2.Name then
			v3 = child
			break
		end
	end

	if not v3 then
		return false
	end
	MainModule.AutoThrow.LastThrowTime = now

	if not MainModule.ThrowHelper.Enabled then
		MainModule.ThrowHelper_toggleFaceTarget(true, true)
	elseif not MainModule.ThrowHelper.IsLocked then
		MainModule.ThrowHelper_selectTarget()
	end

	local ok = pcall(function()
		for _, v4 in pairs(getconnections(v3.MouseButton1Down)) do
			v4:Fire()
		end

		task.wait(0.05)

		for _, v4 in pairs(getconnections(v3.MouseButton1Up)) do
			v4:Fire()
		end
	end)

	if ok then
		if MainModule.AutoThrow.TempFaceTask then
			task.cancel(MainModule.AutoThrow.TempFaceTask)
		end

		MainModule.AutoThrow.TempFaceTask = task.delay(1, function()
			if MainModule.ThrowHelper.Enabled and MainModule.ThrowHelper.IsLocked then
				MainModule.ThrowHelper_resetTarget()

				task.delay(0.5, function()
					if MainModule.ThrowHelper.Enabled then
						MainModule.ThrowHelper_toggleFaceTarget(false)
					end
				end)
			end

			MainModule.AutoThrow.TempFaceTask = nil
		end)
	end

	return ok
end

MainModule.AutoThrow_createMobileButton = function()
	if MainModule.AutoThrow.MobileButton then
		return
	end
	local playerGui = localPlayer:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HSX_AutoThrowMobile"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	local textButton = Instance.new("TextButton")
	textButton.Name = "ThrowBtn"
	textButton.Size = UDim2.fromOffset(100, 100)
	textButton.Position = UDim2.new(1, -120, 1, -220)
	textButton.AnchorPoint = Vector2.new(0, 0)
	textButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	textButton.BackgroundTransparency = 0.15
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.Text = "THROW"
	textButton.Font = Enum.Font.GothamBold
	textButton.TextSize = 18
	textButton.AutoButtonColor = true
	textButton.Parent = screenGui
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(1, 0)
	uiCorner.Parent = textButton
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(255, 255, 255)
	uiStroke.Thickness = 1.5
	uiStroke.Transparency = 0.5
	uiStroke.Parent = textButton

	textButton.MouseButton1Click:Connect(function()
		MainModule.AutoThrow_executeThrow()
	end)

	textButton.TouchTap:Connect(function()
		MainModule.AutoThrow_executeThrow()
	end)

	MainModule.AutoThrow.MobileButton = screenGui
end

MainModule.AutoThrow_destroyMobileButton = function()
	if MainModule.AutoThrow.MobileButton then
		pcall(function()
			MainModule.AutoThrow.MobileButton:Destroy()
		end)

		MainModule.AutoThrow.MobileButton = nil
	end
end

MainModule.toggle_auto_throw = function(arg)
	MainModule.AutoThrow.Enabled = arg and true or false

	if MainModule.AutoThrow.KeybindConnection then
		MainModule.AutoThrow.KeybindConnection:Disconnect()
		MainModule.AutoThrow.KeybindConnection = nil
	end

	MainModule.AutoThrow_destroyMobileButton()

	if arg then
		pcall(function()
			MainModule.PushAutoUseTrue("AutoThrow")
		end)

		MainModule.AutoThrow.KeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.F then
				MainModule.AutoThrow_executeThrow()
			end
		end)

		MainModule.AutoThrow_createMobileButton()
	else
		MainModule.ThrowHelper_resetTarget()

		if MainModule.ThrowHelper.Connection then
			MainModule.ThrowHelper.Connection:Disconnect()
			MainModule.ThrowHelper.Connection = nil
		end

		MainModule.ThrowHelper.Enabled = false

		pcall(function()
			MainModule.PopAutoUse("AutoThrow")
		end)
	end

	PlayToggleSound()
	return true
end

MainModule.Fly = { Enabled = false, Speed = 50, Connection = nil, BodyVelocity = nil }

MainModule.toggle_fly = function(arg, arg2)
	if arg then
		MainModule._MovecheckFromAuto = true
		pcall(MainModule.HSX_MovecheckAutoStart)
		MainModule._MovecheckFromAuto = false
	else
		pcall(MainModule.HSX_MovecheckAutoStop)
	end

	if arg then
		if MainModule.Fly.Enabled then
			return
		end
		MainModule.Fly.Enabled = true
		local v2 = MainModule.get_character()
		if not v2 then
			return
		end
		local v3 = MainModule.get_humanoid(v2)
		local v4 = MainModule.get_root_part(v2)
		if not (v3 and v4) then
			return
		end
		v3.UseJumpPower = false
		v3.AutoRotate = false
		v3.PlatformStand = true

		if MainModule.Fly.BodyVelocity then
			MainModule.Fly.BodyVelocity:Destroy()
		end

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "FlyBodyVelocity"
		bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
		bodyVelocity.Parent = v4
		MainModule.Fly.BodyVelocity = bodyVelocity

		MainModule.Fly.Connection = RunService.Heartbeat:Connect(function()
			if not MainModule.Fly.Enabled or not v2 or not v2.Parent then
				MainModule.toggle_fly(false, true)
				return
			end
			v4 = MainModule.get_root_part(v2)
			v3 = MainModule.get_humanoid(v2)
			if not v4 or not bodyVelocity or not v3 then
				MainModule.toggle_fly(false, true)
				return
			end
			local currentCamera = workspace.CurrentCamera
			if not currentCamera then
				return
			end
			local cFrame = currentCamera.CFrame
			local lookVector = cFrame.LookVector
			local rightVector = cFrame.RightVector
			local upVector = cFrame.UpVector
			local vector = Vector3.zero
			local flag = false

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				vector = Vector3.zero + lookVector
				flag = true
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				vector -= lookVector
				flag = true
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				vector -= rightVector
				flag = true
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				vector += rightVector
				flag = true
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				vector += upVector
				flag = true
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				vector -= upVector
				flag = true
			end

			if not flag then
				local moveDirection = v3.MoveDirection

				if moveDirection.Magnitude > 0.1 then
					vector = lookVector * moveDirection.Z + rightVector * moveDirection.X + upVector * moveDirection.Y
					flag = true
				end
			end

			if flag and vector.Magnitude > 0 then
				bodyVelocity.Velocity = vector.Unit * MainModule.Fly.Speed
			else
				bodyVelocity.Velocity = Vector3.zero
			end
		end)
	else
		if not MainModule.Fly.Enabled then
			return
		end
		MainModule.Fly.Enabled = false

		if MainModule.Fly.Connection then
			MainModule.Fly.Connection:Disconnect()
			MainModule.Fly.Connection = nil
		end

		if MainModule.Fly.BodyVelocity then
			MainModule.Fly.BodyVelocity:Destroy()
			MainModule.Fly.BodyVelocity = nil
		end

		local v2 = MainModule.get_character()

		if v2 then
			local v3 = MainModule.get_root_part(v2)

			if v3 then
				v3.AssemblyLinearVelocity = Vector3.zero
			end

			local v4 = MainModule.get_humanoid(v2)

			if v4 then
				v4.UseJumpPower = true
				v4.AutoRotate = true
				v4.PlatformStand = false
			end
		end
	end

	if not arg2 then
		PlayToggleSound()
	end
end

MainModule.set_fly_speed = function(speed)
	MainModule.Fly.Speed = speed
end

MainModule.harmfulEffectsList = {
	"RagdollStun",
	"Stun",
	"Stunned",
	"StunEffect",
	"StunHit",
	"Knockback",
	"Knockdown",
	"Knockout",
	"Dazed",
	"Paralyzed",
	"Freeze",
	"Frozen",
	"Sleep",
	"Slow",
	"Slowed",
	"Root",
	"Rooted",
}

MainModule.RemoveStunEnabled = false

MainModule.toggle_remove_stun = function(removeStunEnabled)
	MainModule.RemoveStunEnabled = removeStunEnabled

	if removeStunEnabled then
		local function fn3()
			local v2 = MainModule.get_character()
			if not v2 then
				return
			end

			for _, v3 in ipairs(MainModule.harmfulEffectsList) do
				local v4 = v2:FindFirstChild(v3)

				if v4 then
					pcall(function()
						v4:Destroy()
					end)
				end
			end

			local v3 = MainModule.get_humanoid(v2)

			if v3 and v3:GetAttribute("Stunned") then
				v3:SetAttribute("Stunned", false)
			end
		end

		fn3()

		RunService.Heartbeat:Connect(function()
			if MainModule.RemoveStunEnabled then
				fn3()
			end
		end)
	end

	PlayToggleSound()
end

MainModule.SpeedHackEnabled = false
MainModule.SpeedValue = 39
MainModule.SpeedHackLoop = nil

MainModule.toggle_speed_hack = function(speedHackEnabled)
	MainModule.SpeedHackEnabled = speedHackEnabled

	if speedHackEnabled then
		MainModule._MovecheckFromAuto = true
		pcall(MainModule.HSX_MovecheckAutoStart)
		MainModule._MovecheckFromAuto = false
	else
		pcall(MainModule.HSX_MovecheckAutoStop)
	end

	if speedHackEnabled then
		if MainModule.SpeedHackLoop then
			task.cancel(MainModule.SpeedHackLoop)
		end

		MainModule.SpeedHackLoop = task.spawn(function()
			while MainModule.SpeedHackEnabled do
				local v2 = MainModule.get_character()

				if v2 then
					local v3 = MainModule.get_humanoid(v2)

					if v3 and v3.Health > 0 then
						v3.WalkSpeed = MainModule.SpeedValue
					end
				end

				task.wait(0.1)
			end
		end)
	else
		if MainModule.SpeedHackLoop then
			task.cancel(MainModule.SpeedHackLoop)
			MainModule.SpeedHackLoop = nil
		end

		local v2 = MainModule.get_character()

		if v2 then
			local v3 = MainModule.get_humanoid(v2)

			if v3 then
				v3.WalkSpeed = 16
			end
		end
	end

	PlayToggleSound()
end

MainModule.set_speed_value = function(arg)
	MainModule.SpeedValue = math.min(arg, 50)

	if MainModule.SpeedHackEnabled then
		local v2 = MainModule.get_character()

		if v2 then
			local v3 = MainModule.get_humanoid(v2)

			if v3 and v3.Health > 0 then
				v3.WalkSpeed = MainModule.SpeedValue
			end
		end
	end
end

MainModule.FOVEnabled = false
MainModule.FOVValue = 120
MainModule.FOVConnection = nil

MainModule.toggle_fov = function(fovEnabled)
	if type(fovEnabled) ~= "boolean" then
		fovEnabled = not MainModule.FOVEnabled
	end

	MainModule.FOVEnabled = fovEnabled
	local currentCamera = workspace.CurrentCamera

	if fovEnabled then
		currentCamera.FieldOfView = MainModule.FOVValue

		if MainModule.FOVConnection then
			MainModule.FOVConnection:Disconnect()
		end

		MainModule.FOVConnection = currentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
			if MainModule.FOVEnabled and currentCamera.FieldOfView ~= MainModule.FOVValue then
				currentCamera.FieldOfView = MainModule.FOVValue
			end
		end)
	else
		if MainModule.FOVConnection then
			MainModule.FOVConnection:Disconnect()
			MainModule.FOVConnection = nil
		end

		currentCamera.FieldOfView = 70
	end

	PlayToggleSound()
end

MainModule.set_fov = function(arg)
	MainModule.FOVValue = math.min(arg, 120)

	if MainModule.FOVEnabled then
		workspace.CurrentCamera.FieldOfView = MainModule.FOVValue
	end
end

MainModule.AutoQTEMode = "Legit"
MainModule.AutoQTEEnabled = false

MainModule.toggle_auto_qte = function(autoQTEEnabled)
	local autoQTE = MainModule.ToggleRefs.AutoQTE

	if autoQTEEnabled then
		if MainModule.is_xeno_executor() then
			MainModule.notify("Auto QTE", "Not supported in your executor", 0.9)
			PlayErrorSound()

			if autoQTE and autoQTE.SetValue then
				pcall(function()
					autoQTE:SetValue(false)
				end)
			end

			return false
		end
	end

	MainModule.AutoQTEEnabled = autoQTEEnabled

	if autoQTEEnabled then
		local impactFrames = localPlayer.PlayerGui:FindFirstChild("ImpactFrames")

		if impactFrames then
			local tbl = {}

			impactFrames.ChildAdded:Connect(function(child)
				if child.Name ~= "OuterRingTemplate" or tbl[child] then
					return
				end
				tbl[child] = true

				task.defer(function()
					local v2 = nil

					for _, child2 in pairs(impactFrames:GetChildren()) do
						if child2.Name == "InnerTemplate" and child2.Position == child.Position and not child2:GetAttribute("Failed") then
							v2 = child2
							break
						end
					end

					if not v2 or v2:GetAttribute("Tweening") or v2:GetAttribute("Failed") then
						return
					end
					local HBGQTE = require(ReplicatedStorage.Modules.HBGQTE)

					if MainModule.AutoQTEMode == "Legit" then
						pcall(function()
							HBGQTE.Pressed(false, { Inner = v2, Outer = child, Duration = 2, StartedAt = tick(), Data = {} })
						end)
					else
						pcall(function()
							HBGQTE.Pressed(true, { Inner = v2, Outer = child, Duration = 0.1, StartedAt = tick(), Data = {} })
						end)
					end
				end)
			end)
		end
	end

	PlayToggleSound()
	return true
end

MainModule.set_auto_qte_mode = function(autoQTEMode)
	MainModule.AutoQTEMode = autoQTEMode
end

MainModule.teleport_up = function()
	MainModule._MovecheckFromAuto = true
	pcall(MainModule.HSX_MovecheckAutoStart)
	MainModule._MovecheckFromAuto = false

	task.delay(2, function()
		pcall(MainModule.HSX_MovecheckAutoStop)
	end)

	local v2 = MainModule.get_character()

	if v2 then
		local v3 = MainModule.get_root_part(v2)

		if v3 then
			v3.CFrame = v3.CFrame + Vector3.new(0, 100, 0)
			MainModule.notify("Teleport", "Up 100", 0.9)
		end
	end

	PlayToggleSound()
end

MainModule.teleport_down = function()
	MainModule._MovecheckFromAuto = true
	pcall(MainModule.HSX_MovecheckAutoStart)
	MainModule._MovecheckFromAuto = false

	task.delay(2, function()
		pcall(MainModule.HSX_MovecheckAutoStop)
	end)

	local v2 = MainModule.get_character()

	if v2 then
		local v3 = MainModule.get_root_part(v2)

		if v3 then
			v3.CFrame = v3.CFrame + Vector3.new(0, -40, 0)
			MainModule.notify("Teleport", "Down 40", 0.9)
		end
	end

	PlayToggleSound()
end

MainModule.GamePassStates = {
	PermanentGuard = false,
	GlassVision = false,
	EmotePages = false,
	CustomPlayerTag = false,
	PrivateServerPlus = false,
	FreeVIP = false,
	Lighter = false,
}

MainModule.toggle_permanent_guard = function(permanentGuard)
	MainModule.GamePassStates.PermanentGuard = permanentGuard
	localPlayer:SetAttribute("__OwnsPermGuard", permanentGuard)
	PlayToggleSound()
end

MainModule.toggle_glass_vision = function(arg)
	MainModule.GamePassStates = MainModule.GamePassStates or {}
	MainModule.GamePassStates.GlassVision = arg and true or false
	MainModule.GlassVisionEnabled = arg and true or false
	localPlayer:SetAttribute("__OwnsGlassManufacturerVision", arg and true or false)
	PlayToggleSound()
end

MainModule.toggle_emote_pages = function(emotePages)
	MainModule.GamePassStates.EmotePages = emotePages
	localPlayer:SetAttribute("__OwnsEmotePages", emotePages)
	PlayToggleSound()
end

MainModule.toggle_custom_player_tag = function(customPlayerTag)
	MainModule.GamePassStates.CustomPlayerTag = customPlayerTag
	localPlayer:SetAttribute("__OwnsCustomPlayerTag", customPlayerTag)
	PlayToggleSound()
end

MainModule.toggle_private_server_plus = function(privateServerPlus)
	MainModule.GamePassStates.PrivateServerPlus = privateServerPlus
	localPlayer:SetAttribute("__OwnsPSPlus", privateServerPlus)
	PlayToggleSound()
end

MainModule.unlock_vip = function()
	localPlayer:SetAttribute("__OwnsVIPGamepass", true)
	localPlayer:SetAttribute("__Owns2xVote", true)

	pcall(function()
		MainModule.GamePassStates.FreeVIP = true
	end)

	PlayToggleSound()
	fn2("VIP", "Unlocked", 0.9)
end

MainModule.toggle_lighter = function(arg)
	MainModule.GamePassStates = MainModule.GamePassStates or {}
	MainModule.GamePassStates.Lighter = arg and true or false
	MainModule.LighterEnabled = arg and true or false
	localPlayer:SetAttribute("HasLighter", arg and true or false)
	PlayToggleSound()
end

MainModule.LegitHitboxEnabled = false
MainModule.LegitHitboxConn = nil
MainModule.LegitHitboxParts = {}
MainModule.legit_hitbox_enabled = false
MainModule.legit_hitbox_conn = nil
MainModule.legit_hitbox_parts = {}

MainModule.toggle_legit_hitbox = function(arg)
	MainModule.legit_hitbox_enabled = arg and true or false

	if MainModule.legit_hitbox_conn then
		pcall(function()
			MainModule.legit_hitbox_conn:Disconnect()
		end)

		MainModule.legit_hitbox_conn = nil
	end

	for k, legitHitboxPart in pairs(MainModule.legit_hitbox_parts) do
		if k and k.Parent then
			pcall(function()
				k.Size = legitHitboxPart.Size
				k.CanCollide = legitHitboxPart.CanCollide
				k.Transparency = legitHitboxPart.Transparency
			end)
		end
	end

	MainModule.legit_hitbox_parts = {}
	if not arg then
		PlayToggleSound()
		return true
	end

	MainModule.legit_hitbox_conn = RunService.Heartbeat:Connect(function()
		if not MainModule.legit_hitbox_enabled then
			return
		end
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			return
		end
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character }

		for _, player in pairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					local n = humanoidRootPart2.Position - humanoidRootPart.Position
					local magnitude = n.Magnitude

					if magnitude < 0.1 then
						magnitude = 0.1
					end

					local hit = workspace:Raycast(humanoidRootPart.Position, n.Unit * math.min(magnitude, 400), raycastParams)

					if not hit or hit.Instance and hit.Instance:IsDescendantOf(player.Character) then
						if not MainModule.legit_hitbox_parts[humanoidRootPart2] then
							MainModule.legit_hitbox_parts[humanoidRootPart2] = {
								Size = humanoidRootPart2.Size,
								CanCollide = humanoidRootPart2.CanCollide,
								Transparency = humanoidRootPart2.Transparency,
							}

							humanoidRootPart2.Size = Vector3.new(8, 8, 8)
							humanoidRootPart2.CanCollide = false
							humanoidRootPart2.Transparency = 0.45
						end
					else
						local v2 = MainModule.legit_hitbox_parts[humanoidRootPart2]

						if v2 then
							humanoidRootPart2.Size = v2.Size
							humanoidRootPart2.Transparency = v2.Transparency
							humanoidRootPart2.CanCollide = v2.CanCollide
							MainModule.legit_hitbox_parts[humanoidRootPart2] = nil
						end
					end
				end
			end
		end
	end)

	PlayToggleSound()
	return true
end

MainModule.InfiniteAmmoEnabled = false
MainModule.OriginalAmmo = {}

MainModule.toggle_infinite_ammo = function(infiniteAmmoEnabled)
	MainModule.InfiniteAmmoEnabled = infiniteAmmoEnabled

	if infiniteAmmoEnabled then
		RunService.Heartbeat:Connect(function()
			if not MainModule.InfiniteAmmoEnabled then
				return
			end

			pcall(function()
				local v2 = MainModule.get_character()

				if v2 then
					for _, child in pairs(v2:GetChildren()) do
						if child:IsA("Tool") then
							for _, descendant in pairs(child:GetDescendants()) do
								if (descendant:IsA("NumberValue") or descendant:IsA("IntValue")) and (descendant.Name:lower():find("ammo") or descendant.Name:lower():find("bullet")) then
									if not MainModule.OriginalAmmo[descendant] then
										MainModule.OriginalAmmo[descendant] = descendant.Value
									end

									descendant.Value = math.huge
								end
							end
						end
					end
				end

				local backpack = localPlayer:FindFirstChild("Backpack")

				if backpack then
					for _, child in pairs(backpack:GetChildren()) do
						if child:IsA("Tool") then
							for _, descendant in pairs(child:GetDescendants()) do
								if (descendant:IsA("NumberValue") or descendant:IsA("IntValue")) and (descendant.Name:lower():find("ammo") or descendant.Name:lower():find("bullet")) then
									if not MainModule.OriginalAmmo[descendant] then
										MainModule.OriginalAmmo[descendant] = descendant.Value
									end

									descendant.Value = math.huge
								end
							end
						end
					end
				end
			end)
		end)
	else
		for k, v2 in pairs(MainModule.OriginalAmmo) do
			if k and k.Parent then
				k.Value = v2
			end
		end

		MainModule.OriginalAmmo = {}
	end

	PlayToggleSound()
end

MainModule.set_custom_player_tag = function(arg)
	local num = tonumber(arg)

	if num and num >= 0 and num <= 999 then
		local text = string.format("%03d", num)
		local live = workspace:FindFirstChild("Live")

		if live then
			local v2 = live:FindFirstChild(localPlayer.Name)

			if v2 then
				local playerTags = v2:FindFirstChild("PlayerTags")

				if playerTags then
					local back = playerTags:FindFirstChild("Back")
					local front = playerTags:FindFirstChild("Front")
					local textLabel = nil

					if back then
						local surfaceGui = back:FindFirstChild("SurfaceGui")
						textLabel = nil

						if surfaceGui then
							textLabel = surfaceGui:FindFirstChild("TextLabel")
						end
					end

					local textLabel2 = nil

					if front then
						local surfaceGui = front:FindFirstChild("SurfaceGui")
						textLabel2 = nil

						if surfaceGui then
							textLabel2 = surfaceGui:FindFirstChild("TextLabel")
						end
					end

					if textLabel and textLabel2 then
						textLabel.Text = text
						textLabel2.Text = text
					end
				end
			end
		end
	end

	PlayToggleSound()
end

MainModule.CustomPlayerTagEnabled = false
MainModule.CustomPlayerTagValue = "067"
MainModule.CustomPlayerTagConnection = nil

local function fn3(arg)
	local num = tonumber(arg)
	if num and num >= 0 and num <= 999 then
		return string.format("%03d", num)
	end
	return "000"
end

MainModule.toggle_custom_player_tag = function(customPlayerTagEnabled)
	MainModule.CustomPlayerTagEnabled = customPlayerTagEnabled

	if MainModule.CustomPlayerTagConnection then
		MainModule.CustomPlayerTagConnection:Disconnect()
		MainModule.CustomPlayerTagConnection = nil
	end

	if customPlayerTagEnabled then
		MainModule.set_custom_player_tag(MainModule.CustomPlayerTagValue)

		MainModule.CustomPlayerTagConnection = RunService.Heartbeat:Connect(function()
			if MainModule.CustomPlayerTagEnabled then
				local live = workspace:FindFirstChild("Live")

				if live then
					local v2 = live:FindFirstChild(localPlayer.Name)

					if v2 then
						local playerTags = v2:FindFirstChild("PlayerTags")

						if playerTags then
							local back = playerTags:FindFirstChild("Back")
							local front = playerTags:FindFirstChild("Front")
							local textLabel = nil

							if back then
								local surfaceGui = back:FindFirstChild("SurfaceGui")
								textLabel = nil

								if surfaceGui then
									textLabel = surfaceGui:FindFirstChild("TextLabel")
								end
							end

							local textLabel2 = nil

							if front then
								local surfaceGui = front:FindFirstChild("SurfaceGui")
								textLabel2 = nil

								if surfaceGui then
									textLabel2 = surfaceGui:FindFirstChild("TextLabel")
								end
							end

							if textLabel and textLabel2 then
								local v3 = fn3(MainModule.CustomPlayerTagValue)

								if textLabel.Text ~= v3 then
									textLabel.Text = v3
								end

								if textLabel2.Text ~= v3 then
									textLabel2.Text = v3
								end
							end
						end
					end
				end
			end
		end)
	else
		MainModule.set_custom_player_tag(0)
	end

	PlayToggleSound()
end

MainModule.set_custom_tag_value = function(arg)
	local v2 = fn3(arg)
	MainModule.CustomPlayerTagValue = v2

	if MainModule.CustomPlayerTagEnabled then
		MainModule.set_custom_player_tag(tonumber(v2))
	end
end

MainModule.AutoNextEnabled = false
MainModule.AutoNextConn = nil
MainModule.TargetPos = Vector3.new(-214.3, 186.86, 242.64)
MainModule.Radius = 80

MainModule.toggle_auto_next_game = function(autoNextEnabled)
	MainModule.AutoNextEnabled = autoNextEnabled

	if MainModule.AutoNextConn then
		MainModule.AutoNextConn:Disconnect()
		MainModule.AutoNextConn = nil
	end

	if autoNextEnabled then
		local n = 0

		MainModule.AutoNextConn = RunService.Heartbeat:Connect(function(deltaTime)
			if not MainModule.AutoNextEnabled then
				return
			end
			local character = localPlayer.Character
			local position = character and character.PrimaryPart and character.PrimaryPart.Position

			if position and (position - MainModule.TargetPos).Magnitude <= MainModule.Radius then
				n += deltaTime

				if n >= 3.4 then
					n = 0

					pcall(function()
						game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TemporaryReachedBindable"):FireServer()
					end)
				end
			else
				n = 0
			end
		end)
	end

	PlayToggleSound()
end

MainModule.NoDashPhantomCDEnabled = false
MainModule.NoDashPhantomCDConnection = nil
MainModule.NoDashPhantomCDObj = nil

MainModule.toggle_no_dash_phantom_cd = function(arg)
	MainModule.NoDashPhantomCDEnabled = arg and true or false

	if MainModule.NoDashPhantomCDConnection then
		pcall(function()
			MainModule.NoDashPhantomCDConnection:Disconnect()
		end)

		MainModule.NoDashPhantomCDConnection = nil
	end

	MainModule.NoDashPhantomCDObj = nil

	if arg then
		local v2 = nil

		pcall(function()
			for _, v3 in pairs(getgc(true)) do
				if type(v3) == "table" and rawget(v3, "CDDASHSTACKS") and rawget(v3, "StopCounter") then
					v2 = v3
					break
				end
			end
		end)

		MainModule.NoDashPhantomCDObj = v2

		if v2 then
			MainModule.NoDashPhantomCDConnection = RunService.RenderStepped:Connect(function()
				if not MainModule.NoDashPhantomCDEnabled then
					return
				end
				local noDashPhantomCDObj = MainModule.NoDashPhantomCDObj
				if not noDashPhantomCDObj then
					return
				end

				pcall(function()
					rawset(noDashPhantomCDObj, "DashCD", nil)

					if rawget(noDashPhantomCDObj, "CDDASHSTACKS") and rawget(noDashPhantomCDObj, "CDDASHSTACKS") > 1 then
						rawset(noDashPhantomCDObj, "CDDASHSTACKS", 1)
					end
				end)
			end)
		else
			MainModule.NoDashPhantomCDConnection = RunService.Heartbeat:Connect(function()
				if not MainModule.NoDashPhantomCDEnabled then
					return
				end

				if MainModule.NoDashPhantomCDObj then
					return
				end

				pcall(function()
					for _, v3 in pairs(getgc(true)) do
						if type(v3) == "table" and rawget(v3, "CDDASHSTACKS") and rawget(v3, "StopCounter") then
							MainModule.NoDashPhantomCDObj = v3

							if MainModule.NoDashPhantomCDConnection then
								pcall(function()
									MainModule.NoDashPhantomCDConnection:Disconnect()
								end)
							end

							MainModule.NoDashPhantomCDConnection = RunService.RenderStepped:Connect(function()
								if not MainModule.NoDashPhantomCDEnabled then
									return
								end
								local noDashPhantomCDObj = MainModule.NoDashPhantomCDObj
								if not noDashPhantomCDObj then
									return
								end

								pcall(function()
									rawset(noDashPhantomCDObj, "DashCD", nil)

									if rawget(noDashPhantomCDObj, "CDDASHSTACKS") and rawget(noDashPhantomCDObj, "CDDASHSTACKS") > 1 then
										rawset(noDashPhantomCDObj, "CDDASHSTACKS", 1)
									end
								end)
							end)

							break
						end
					end
				end)
			end)
		end
	end

	PlayToggleSound()
	return true
end

MainModule.FasterSprintEnabled = false
MainModule.FasterSprintLoop = nil
_G.FasterSprintEnabled = false

MainModule.toggle_faster_sprint = function(arg)
	local fasterSprintEnabled = arg and true or false
	MainModule.FasterSprintEnabled = fasterSprintEnabled
	_G.FasterSprintEnabled = fasterSprintEnabled

	if MainModule.FasterSprintLoop then
		pcall(task.cancel, MainModule.FasterSprintLoop)
		MainModule.FasterSprintLoop = nil
	end

	if fasterSprintEnabled then
		MainModule.FasterSprintLoop = task.spawn(function()
			local v2 = localPlayer

			while MainModule.FasterSprintEnabled do
				local character = v2.Character

				if character and character.Parent then
					if not character:FindFirstChild("FASTERSPRINT") then
						local folder = Instance.new("Folder")
						folder.Name = "FASTERSPRINT"
						folder.Parent = character
					end

					local delIfGoneFolder = character:FindFirstChild("DelIfGone_Folder")

					if delIfGoneFolder then
						delIfGoneFolder:Destroy()
					end

					local staminaVal = character:FindFirstChild("StaminaVal")

					if staminaVal then
						staminaVal.Value = 100
					end

					local v3 = character:GetChildren()[36]

					if v3 and not character:FindFirstChild(v3.Name) then
						local folder = Instance.new("Folder")
						folder.Name = v3.Name
						folder.Parent = character
					end
				end

				task.wait()
			end
		end)
	end

	PlayToggleSound()
	return true
end

MainModule.AmbienceEnabled = false
MainModule.motionBlur = nil
MainModule.blurAmount = 12
MainModule.blurAmplifier = 12
MainModule.lastVector = nil
MainModule.originalTimeOfDay = nil
MainModule.ambienceConnection = nil
MainModule.timeFixConnection = nil

MainModule.toggle_ambience = function(ambienceEnabled)
	MainModule.AmbienceEnabled = ambienceEnabled

	if ambienceEnabled then
		local currentCamera = workspace.CurrentCamera
		MainModule.lastVector = currentCamera.CFrame.LookVector

		if MainModule.motionBlur and MainModule.motionBlur.Parent then
			MainModule.motionBlur:Destroy()
		end

		MainModule.motionBlur = Instance.new("BlurEffect", currentCamera)
		local Lighting = game:GetService("Lighting")
		MainModule.originalTimeOfDay = Lighting.TimeOfDay
		Lighting.TimeOfDay = "22:00:00"

		if MainModule.timeFixConnection then
			MainModule.timeFixConnection:Disconnect()
		end

		MainModule.timeFixConnection = Lighting.Changed:Connect(function(arg)
			if arg == "TimeOfDay" and MainModule.AmbienceEnabled then
				Lighting.TimeOfDay = "22:00:00"
			end
		end)

		if MainModule.ambienceConnection then
			MainModule.ambienceConnection:Disconnect()
		end

		MainModule.ambienceConnection = RunService.Heartbeat:Connect(function()
			if not MainModule.AmbienceEnabled then
				return
			end
			local currentCamera2 = workspace.CurrentCamera
			if not currentCamera2 then
				return
			end

			if not MainModule.motionBlur or MainModule.motionBlur.Parent == nil then
				MainModule.motionBlur = Instance.new("BlurEffect", currentCamera2)
			end

			local lookVector = currentCamera2.CFrame.LookVector
			local blurAmount = MainModule.blurAmount
			MainModule.motionBlur.Size = math.abs((lookVector - MainModule.lastVector).magnitude) * blurAmount * MainModule.blurAmplifier / 2
			MainModule.lastVector = lookVector
		end)

		workspace.Changed:Connect(function(arg)
			if arg == "CurrentCamera" and MainModule.AmbienceEnabled then
				local currentCamera2 = workspace.CurrentCamera

				if MainModule.motionBlur and MainModule.motionBlur.Parent then
					MainModule.motionBlur.Parent = currentCamera2
				else
					MainModule.motionBlur = Instance.new("BlurEffect", currentCamera2)
				end
			end
		end)
	else
		if MainModule.motionBlur then
			MainModule.motionBlur:Destroy()
			MainModule.motionBlur = nil
		end

		if MainModule.ambienceConnection then
			MainModule.ambienceConnection:Disconnect()
			MainModule.ambienceConnection = nil
		end

		if MainModule.timeFixConnection then
			MainModule.timeFixConnection:Disconnect()
			MainModule.timeFixConnection = nil
		end

		local Lighting = game:GetService("Lighting")

		if MainModule.originalTimeOfDay then
			Lighting.TimeOfDay = MainModule.originalTimeOfDay
		end
	end

	PlayToggleSound()
end

MainModule.ExitDoorESPEnabled = false
MainModule.ExitDoorESPThread = nil
MainModule.ExitDoorESPObjects = {}
MainModule.KeyESPEnabled = MainModule.KeyESPEnabled or false
MainModule.KeyESPBoxes = MainModule.KeyESPBoxes or {}
MainModule.KeyESPConnection = MainModule.KeyESPConnection or nil

MainModule.toggle_key_esp = function(keyESPEnabled)
	local keyESP = MainModule.ToggleRefs.KeyESP

	if keyESPEnabled then
		if not MainModule.can_enable_toggle("HideAndSeek", "Key ESP", keyESP) then
			return false
		end
	end

	MainModule.KeyESPEnabled = keyESPEnabled

	if MainModule.KeyESPConnection then
		MainModule.KeyESPConnection:Disconnect()
		MainModule.KeyESPConnection = nil
	end

	for _, keyESPBoxe in pairs(MainModule.KeyESPBoxes) do
		if keyESPBoxe then
			pcall(function()
				keyESPBoxe:Destroy()
			end)
		end
	end

	MainModule.KeyESPBoxes = {}

	if keyESPEnabled then
		task.spawn(function()
			local v2 = game
			local localPlayer2 = game:GetService("Players").LocalPlayer
			local Workspace2 = v2:GetService("Workspace")
			local effects

			repeat
				effects = Workspace2:FindFirstChild("Effects")
				task.wait(0.1)
			until effects

			local tbl = {}

			local function fn4()
				local currentKeys = localPlayer2:FindFirstChild("CurrentKeys")
				if currentKeys then
					return currentKeys
				end
				local live = Workspace2:FindFirstChild("Live")

				if live then
					local v3 = live:FindFirstChild(localPlayer2.Name)

					if v3 then
						local currentKeys2 = v3:FindFirstChild("CurrentKeys")
						if currentKeys2 then
							return currentKeys2
						end
					end
				end

				return nil
			end

			local function fn5(arg)
				local v3 = fn4()
				if not v3 then
					return false
				end
				return v3:FindFirstChild(arg) ~= nil
			end

			local function createBoxHandleAdornment(adornee)
				local boxHandleAdornment = Instance.new("BoxHandleAdornment")
				boxHandleAdornment.Name = "KeyESP"
				boxHandleAdornment.Adornee = adornee
				boxHandleAdornment.Size = adornee.Size + Vector3.new(0.5, 0.5, 0.5)
				boxHandleAdornment.Color3 = Color3.fromRGB(138, 43, 226)
				boxHandleAdornment.Transparency = 0.4
				boxHandleAdornment.AlwaysOnTop = true
				boxHandleAdornment.ZIndex = 10
				boxHandleAdornment.Parent = adornee
				return boxHandleAdornment
			end

			local function fn6(arg)
				if tbl[arg] then
					if tbl[arg] and tbl[arg].Parent then
						tbl[arg]:Destroy()
					end

					tbl[arg] = nil
				end
			end

			while MainModule.KeyESPEnabled do
				for k in pairs(tbl) do
					if not k or not k.Parent then
						fn6(k)
					end
				end

				for _, child in ipairs(effects:GetChildren()) do
					if MainModule.KeyESPEnabled then
						if child:IsA("Model") and child.Name:match("^DroppedKey") then
							local str = child.Name:gsub("^DroppedKey", "")
							local primaryPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")

							if primaryPart then
								if not fn5(str) then
									if not tbl[child] and not primaryPart:FindFirstChild("KeyESP") then
										tbl[child] = createBoxHandleAdornment(primaryPart)
									end
								else
									fn6(child)
									local keyESP2 = primaryPart:FindFirstChild("KeyESP")

									if keyESP2 then
										keyESP2:Destroy()
									end
								end
							end
						end

						continue
					end

					break
				end

				task.wait(0.25)
			end

			for _, v3 in pairs(tbl) do
				if v3 then
					v3:Destroy()
				end
			end

			tbl = {}
		end)
	end

	PlayToggleSound()
	return true
end

MainModule.toggle_exit_door_esp = function(arg)
	if arg then
		if MainModule.is_game_active and not MainModule.is_game_active("HideAndSeek") then
			MainModule.notify("Exit Door ESP", "Wait for HideAndSeek!", 0.9)
			PlayErrorSound()
			MainModule.ExitDoorESPEnabled = false

			if MainModule.ToggleRefs and MainModule.ToggleRefs.ExitDoorESP and MainModule.ToggleRefs.ExitDoorESP.SetValue then
				pcall(function()
					MainModule.ToggleRefs.ExitDoorESP:SetValue(false)
				end)
			end

			return
		end
	end

	MainModule.ExitDoorESPEnabled = arg and true or false
	MainModule.ExitDoorESPObjects = MainModule.ExitDoorESPObjects or {}

	local function fn4()
		for k, exitDoorESPObject in pairs(MainModule.ExitDoorESPObjects) do
			pcall(function()
				if exitDoorESPObject.box then
					exitDoorESPObject.box:Destroy()
				end
			end)

			pcall(function()
				if exitDoorESPObject.billboard then
					exitDoorESPObject.billboard:Destroy()
				end
			end)

			MainModule.ExitDoorESPObjects[k] = nil
		end

		MainModule.ExitDoorESPObjects = {}
	end

	if MainModule.ExitDoorESPThread then
		pcall(function()
			task.cancel(MainModule.ExitDoorESPThread)
		end)

		MainModule.ExitDoorESPThread = nil
	end

	pcall(fn4)
	if not arg then
		PlayToggleSound()
		return
	end

	local function fn5(arg2)
		local ok, size = pcall(function()
			local boundingBox, v2 = arg2:GetBoundingBox()
			return v2
		end)

		size = ok and size or Vector3.new(4, 6, 2)
		local boxHandleAdornment = Instance.new("BoxHandleAdornment")
		boxHandleAdornment.Adornee = arg2.PrimaryPart or arg2:FindFirstChildWhichIsA("BasePart")
		if not boxHandleAdornment.Adornee then
			return nil
		end
		boxHandleAdornment.Size = size
		boxHandleAdornment.Color3 = Color3.fromRGB(255, 255, 0)
		boxHandleAdornment.Transparency = 0.5
		boxHandleAdornment.AlwaysOnTop = true
		boxHandleAdornment.ZIndex = 10
		boxHandleAdornment.Parent = boxHandleAdornment.Adornee
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Adornee = boxHandleAdornment.Adornee
		billboardGui.Size = UDim2.new(0, 100, 0, 50)
		billboardGui.StudsOffset = Vector3.new(0, 3, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.Parent = boxHandleAdornment.Adornee
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "EXIT DOOR"
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.Parent = billboardGui
		local tbl = { box = boxHandleAdornment, billboard = billboardGui, part = boxHandleAdornment.Adornee }
		MainModule.ExitDoorESPObjects[#MainModule.ExitDoorESPObjects + 1] = tbl
		return tbl
	end

	local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")

	if hideAndSeekMap then
		local fn6 = nil

		fn6 = function(arg2)
			for _, child in pairs(arg2:GetChildren()) do
				if child.Name == "EXITDOOR" and child:GetAttribute("ActuallyWorks") == true then
					fn5(child)
				end

				fn6(child)
			end
		end

		fn6(hideAndSeekMap)
	end

	PlayToggleSound()
end

MainModule.teleport_to_hider = function()
	MainModule._MovecheckFromAuto = true
	pcall(MainModule.HSX_MovecheckAutoStart)
	MainModule._MovecheckFromAuto = false

	task.delay(2, function()
		pcall(MainModule.HSX_MovecheckAutoStop)
	end)

	if MainModule.is_game_active and not MainModule.is_game_active("HideAndSeek") then
		pcall(function()
			fn2("HNS", "Wait for HideAndSeek!", 0.9)
		end)

		return
	end

	local character = localPlayer.Character
	if not character then
		return
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= localPlayer and MainModule.is_hider(player) and player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					humanoidRootPart.CFrame = CFrame.new(humanoidRootPart2.Position.X, humanoidRootPart2.Position.Y + 3, humanoidRootPart2.Position.Z)

					pcall(function()
						fn2("HNS", "Teleported to hider: " .. player.Name, 0.9)
					end)

					return
				end
			end
		end
	end

	pcall(function()
		fn2("HideAndSeek", "No hider's found :c", 0.9)
	end)
end

MainModule.teleport_to_seeker = function()
	MainModule._MovecheckFromAuto = true
	pcall(MainModule.HSX_MovecheckAutoStart)
	MainModule._MovecheckFromAuto = false

	task.delay(2, function()
		pcall(MainModule.HSX_MovecheckAutoStop)
	end)

	if MainModule.is_game_active and not MainModule.is_game_active("HideAndSeek") then
		pcall(function()
			fn2("HNS", "Wait for HideAndSeek!", 0.9)
		end)

		return
	end

	local character = localPlayer.Character
	if not character then
		return
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= localPlayer and MainModule.is_seeker(player) and player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 then
					humanoidRootPart.CFrame = CFrame.new(humanoidRootPart2.Position.X, humanoidRootPart2.Position.Y + 3, humanoidRootPart2.Position.Z)

					pcall(function()
						fn2("HNS", "Teleported to seeker: " .. player.Name, 0.9)
					end)

					return
				end
			end
		end
	end

	pcall(function()
		fn2("HideAndSeek", "No seeker's found :c", 0.9)
	end)
end

MainModule.SpikesKillFeature = {
	Enabled = false,
	AnimationIds = {
		"rbxassetid://105341857343164",
		"rbxassetid://95623680038308",
		"rbxassetid://106191977814264",
		"rbxassetid://79549040943367",
		"rbxassetid://138639404847153",
		"rbxassetid://81533666958052",
		"rbxassetid://118039465583394",
	},
	SpikesPosition = nil,
	PlatformHeightOffset = 20,
	ReturnDelay = 0.6,
	OriginalCFrame = nil,
	ActiveAnimation = false,
	AnimationStartTime = 0,
	AnimationConnection = nil,
	CharacterAddedConnection = nil,
	AnimationStoppedConnections = {},
	AnimationCheckConnection = nil,
	TrackedAnimations = {},
	SafetyCheckConnection = nil,
	PlatformPart = nil,
	PlatformCreated = false,
}

MainModule.toggle_spikes_kill = function(arg)
	if arg and MainModule.AutoKillHidersController and MainModule.AutoKillHidersController:IsEnabled() then
		MainModule.notify("Spikes Kill", "Disable Auto Kill Hiders before enabling manual Spikes Kill.", 3)
		local toggle = MainModule.ToggleRefs and MainModule.ToggleRefs.SpikesKill
		if toggle and toggle.SetValue then pcall(function() toggle:SetValue(false) end) end
		return
	end
	if arg and not MainModule.is_game_active("HideAndSeek") then
		MainModule.notify("Spikes Kill", "Wait for HideAndSeek!", 0.9)
		PlayErrorSound()
		MainModule.SpikesKillFeature.Enabled = false
		return
	end

	if MainModule.SpikesKillFeature.AnimationConnection then
		MainModule.SpikesKillFeature.AnimationConnection:Disconnect()
		MainModule.SpikesKillFeature.AnimationConnection = nil
	end

	if MainModule.SpikesKillFeature.CharacterAddedConnection then
		MainModule.SpikesKillFeature.CharacterAddedConnection:Disconnect()
		MainModule.SpikesKillFeature.CharacterAddedConnection = nil
	end

	if MainModule.SpikesKillFeature.SafetyCheckConnection then
		MainModule.SpikesKillFeature.SafetyCheckConnection:Disconnect()
		MainModule.SpikesKillFeature.SafetyCheckConnection = nil
	end

	if MainModule.SpikesKillFeature.AnimationCheckConnection then
		MainModule.SpikesKillFeature.AnimationCheckConnection:Disconnect()
		MainModule.SpikesKillFeature.AnimationCheckConnection = nil
	end

	for _, animationStoppedConnection in ipairs(MainModule.SpikesKillFeature.AnimationStoppedConnections) do
		pcall(function()
			animationStoppedConnection:Disconnect()
		end)
	end

	MainModule.SpikesKillFeature.AnimationStoppedConnections = {}

	if MainModule.SpikesKillFeature.PlatformPart then
		pcall(function()
			MainModule.SpikesKillFeature.PlatformPart:Destroy()
		end)

		MainModule.SpikesKillFeature.PlatformPart = nil
	end

	MainModule.SpikesKillFeature.PlatformCreated = false
	MainModule.SpikesKillFeature.OriginalCFrame = nil
	MainModule.SpikesKillFeature.ActiveAnimation = false
	MainModule.SpikesKillFeature.AnimationStartTime = 0
	MainModule.SpikesKillFeature.TrackedAnimations = {}
	MainModule.SpikesKillFeature.SpikesPosition = nil

	if not arg then
		MainModule.SpikesKillFeature.Enabled = false
		PlayToggleSound()
		return
	end

	pcall(function()
		local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
		hideAndSeekMap = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")

		if hideAndSeekMap then
			for _, child in pairs(hideAndSeekMap:GetChildren()) do
				if child:IsA("BasePart") then
					if not MainModule.SpikesKillFeature.SpikesPosition then
						MainModule.SpikesKillFeature.SpikesPosition = child.Position
					end
				end
			end
		end
	end)

	local function fn4()
		if MainModule.SpikesKillFeature.PlatformCreated then
			return
		end

		if not MainModule.SpikesKillFeature.SpikesPosition then
			return
		end

		pcall(function()
			local part = Instance.new("Part")
			part.Name = "SafetyPlatform"
			part.Size = Vector3.new(20, 5, 20)
			part.Position = MainModule.SpikesKillFeature.SpikesPosition + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
			part.Anchored = true
			part.CanCollide = true
			part.Transparency = 1
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "SafePlatform"
			boolValue.Value = true
			boolValue.Parent = part
			part.Parent = workspace
			MainModule.SpikesKillFeature.PlatformPart = part
			MainModule.SpikesKillFeature.PlatformCreated = true
		end)
	end

	local function fn5(arg2)
		if not arg2 or not arg2:FindFirstChild("HumanoidRootPart") then
			return
		end

		if not MainModule.SpikesKillFeature.PlatformCreated then
			fn4()
		end

		if MainModule.SpikesKillFeature.SpikesPosition and MainModule.SpikesKillFeature.PlatformPart then
			MainModule.SpikesKillFeature.OriginalCFrame = arg2:GetPrimaryPartCFrame()
			arg2:SetPrimaryPartCFrame(CFrame.new(MainModule.SpikesKillFeature.PlatformPart.Position + Vector3.new(0, 2.5, 0)))
		end
	end

	local function fn6(arg2)
		if not arg2 or not arg2:FindFirstChild("HumanoidRootPart") then
			return
		end

		if MainModule.SpikesKillFeature.OriginalCFrame then
			arg2:SetPrimaryPartCFrame(MainModule.SpikesKillFeature.OriginalCFrame)
			MainModule.SpikesKillFeature.OriginalCFrame = nil
		end
	end

	local function fn7(arg2)
		for _, animationId in ipairs(MainModule.SpikesKillFeature.AnimationIds) do
			if arg2 == animationId then
				return true
			end
		end

		return false
	end

	local function fn8(arg2)
		MainModule.SpikesKillFeature.AnimationConnection = arg2:WaitForChild("Humanoid").AnimationPlayed:Connect(function(arg3)
			if not MainModule.SpikesKillFeature.Enabled then
				return
			end

			if arg3.Animation and fn7(arg3.Animation.AnimationId) then
				MainModule.SpikesKillFeature.TrackedAnimations[arg3] = true

				if not MainModule.SpikesKillFeature.ActiveAnimation then
					MainModule.SpikesKillFeature.ActiveAnimation = true
					MainModule.SpikesKillFeature.AnimationStartTime = tick()
					fn5(arg2)

					local connection = arg3.Stopped:Connect(function()
						task.wait(MainModule.SpikesKillFeature.ReturnDelay)

						if MainModule.SpikesKillFeature.OriginalCFrame then
							fn6(arg2)
							MainModule.SpikesKillFeature.ActiveAnimation = false
							MainModule.SpikesKillFeature.TrackedAnimations = {}
						end
					end)

					table.insert(MainModule.SpikesKillFeature.AnimationStoppedConnections, connection)
				end
			end
		end)
	end

	local character = localPlayer.Character

	if character then
		fn8(character)
	end

	MainModule.SpikesKillFeature.CharacterAddedConnection = localPlayer.CharacterAdded:Connect(function(character2)
		task.wait(1)
		fn8(character2)
	end)

	MainModule.SpikesKillFeature.SafetyCheckConnection = RunService.Heartbeat:Connect(function()
		if not MainModule.SpikesKillFeature.Enabled then
			if MainModule.SpikesKillFeature.SafetyCheckConnection then
				MainModule.SpikesKillFeature.SafetyCheckConnection:Disconnect()
				MainModule.SpikesKillFeature.SafetyCheckConnection = nil
			end

			return
		end

		if not MainModule.is_game_active("HideAndSeek") then
			MainModule.SpikesKillFeature.Enabled = false
			PlayErrorSound()
			return
		end

		if MainModule.SpikesKillFeature.PlatformCreated and (not MainModule.SpikesKillFeature.PlatformPart or not MainModule.SpikesKillFeature.PlatformPart.Parent) then
			MainModule.SpikesKillFeature.PlatformCreated = false
			MainModule.SpikesKillFeature.PlatformPart = nil
			fn4()
		end

		local activeAnimation = MainModule.SpikesKillFeature.ActiveAnimation

		if activeAnimation then
			local animationStartTime = MainModule.SpikesKillFeature.AnimationStartTime
			activeAnimation = tick() - animationStartTime >= 10
		end

		if activeAnimation then
			local v2 = MainModule.get_character()

			if v2 and MainModule.SpikesKillFeature.OriginalCFrame then
				fn6(v2)
			end

			MainModule.SpikesKillFeature.ActiveAnimation = false
			MainModule.SpikesKillFeature.TrackedAnimations = {}
		end
	end)

	MainModule.SpikesKillFeature.Enabled = true
	PlayToggleSound()
	fn4()
end

MainModule.teleport_to_spawn = function()
	MainModule._MovecheckFromAuto = true
	pcall(MainModule.HSX_MovecheckAutoStart)
	MainModule._MovecheckFromAuto = false

	task.delay(2, function()
		pcall(MainModule.HSX_MovecheckAutoStop)
	end)

	local v2 = MainModule.get_character()

	if not v2 then
		MainModule.notify("Teleport", "Character not found", 0.9)
		PlayErrorSound()
		return
	end

	local v3 = MainModule.get_root_part(v2)

	if not v3 then
		MainModule.notify("Teleport", "Root part not found", 0.9)
		PlayErrorSound()
		return
	end

	v3.CFrame = CFrame.new(Vector3.new(196.83342, 55.9548, -90.47459))
	PlayBell()
end

MainModule.toggle_auto_escape = function(arg)
	local autoEscapeEnabled = arg and true or false
	local autoEscape = MainModule.ToggleRefs and MainModule.ToggleRefs.AutoEscape

	if autoEscapeEnabled then
		pcall(function()
			if MainModule.can_enable_toggle then
				MainModule.can_enable_toggle("HideAndSeek", "Auto Escape", autoEscape)
			end
		end)

		if not MainModule.AutoPickupEnabled then
			pcall(function()
				MainModule.toggle_auto_pickup(true)
			end)

			pcall(function()
				local toggleRefs = MainModule.ToggleRefs
				local autoPickup

				if toggleRefs then
					autoPickup = MainModule.ToggleRefs.AutoPickup or MainModule.ToggleRefs.AutoPickupKeys
				else
					autoPickup = toggleRefs
				end

				if autoPickup and autoPickup.SetValue then
					autoPickup:SetValue(true)
				end
			end)
		end
	end

	MainModule.AutoEscapeEnabled = autoEscapeEnabled

	if autoEscapeEnabled then
		task.spawn(function()
			local Players2 = game:GetService("Players")
			local Workspace2 = game:GetService("Workspace")
			local localPlayer2 = Players2.LocalPlayer
			local currentGame = Workspace2:WaitForChild("Values"):WaitForChild("CurrentGame")
			if currentGame.Value ~= "HideAndSeek" then
				MainModule.AutoEscapeEnabled = false
				return
			end
			local humanoidRootPart = (localPlayer2.Character or localPlayer2.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
			local hideAndSeekMap = Workspace2:WaitForChild("HideAndSeekMap")
			local newfixeddoors = hideAndSeekMap:WaitForChild("NEWFIXEDDOORS")
			local effects = Workspace2:WaitForChild("Effects")
			local killingParts = hideAndSeekMap:WaitForChild("KillingParts")
			local tbl = {}

			for _, descendant in ipairs(killingParts:GetDescendants()) do
				if descendant:IsA("BasePart") then
					table.insert(tbl, descendant)
				end
			end

			local tbl2 = {}

			for _, v2 in ipairs(tbl) do
				tbl2[v2] = v2.CanTouch
			end

			local function fn4()
				for _, v2 in ipairs(tbl) do
					v2.CanTouch = false
				end
			end

			local function fn5()
				for _, v2 in ipairs(tbl) do
					if tbl2[v2] ~= nil then
						v2.CanTouch = tbl2[v2]
					end
				end
			end

			local function fn6()
				return localPlayer2:FindFirstChild("CurrentKeys")
			end

			local function fn7(arg2)
				local v2 = fn6()
				return v2 and v2:FindFirstChild(arg2) ~= nil
			end

			local function fn8()
				local tbl3 = {}

				for _, v2 in ipairs({ "Circle", "Triangle", "Square" }) do
					if not fn7(v2) then
						table.insert(tbl3, v2)
					end
				end

				return tbl3
			end

			local function fn9(cFrame)
				if typeof(cFrame) == "Vector3" then
					humanoidRootPart.CFrame = CFrame.new(cFrame)
				elseif typeof(cFrame) == "CFrame" then
					humanoidRootPart.CFrame = cFrame
				end
			end

			local function fn10(arg2)
				if not arg2 or not arg2:IsA("ProximityPrompt") then
					return
				end

				if fireproximityprompt then
					pcall(function()
						fireproximityprompt(arg2)
					end)
				elseif syn and syn.proximityprompt then
					pcall(function()
						syn.proximityprompt(arg2)
					end)
				else
					local holdDuration = arg2.HoldDuration
					arg2.HoldDuration = 0

					pcall(function()
						arg2:InputHoldBegin()
						task.wait()
						arg2:InputHoldEnd()
					end)

					arg2.HoldDuration = holdDuration
				end
			end

			local function fn11()
				local tbl3 = {}

				for _, child in ipairs(newfixeddoors:GetChildren()) do
					if child:IsA("Folder") and child:FindFirstChild("EXITDOORS") then
						for _, child2 in ipairs(child.EXITDOORS:GetChildren()) do
							if child2:IsA("Model") and child2.Name == "EXITDOOR" and child2:GetAttribute("ActuallyWorks") == true then
								table.insert(tbl3, child2)
							end
						end
					end
				end

				return tbl3
			end

			local function fn12()
				local v2 = fn11()
				if #v2 == 0 then
					return nil
				end

				table.sort(v2, function(arg2, arg3)
					return arg2.Name < arg3.Name
				end)

				return v2[1]
			end

			local function fn13(arg2)
				local doorKnob = arg2:FindFirstChild("DoorKnob")
				if not doorKnob then
					return nil
				end

				for _, descendant in ipairs(doorKnob:GetDescendants()) do
					if pcall(function()
						return descendant.CFrame
					end) then
						return descendant
					end
				end

				return nil
			end

			local connection = nil

			local function fn14()
				if connection then
					connection:Disconnect()
					connection = nil
				end
			end

			local function fn15(arg2)
				if not MainModule.AutoEscapeEnabled or localPlayer2:FindFirstChild("Escaped") then
					return
				end

				if not (arg2:IsA("Model") and arg2.Name:match("^DroppedKey")) then
					return
				end
				local str = arg2.Name:gsub("^DroppedKey", "")
				if fn7(str) then
					return
				end
				local position = arg2.PrimaryPart and arg2.PrimaryPart.Position or arg2:GetPivot().Position
				fn4()
				fn9(position + Vector3.new(0, 5, 0))
				task.wait(0.1)
				fn5()
			end

			local function fn16()
				fn14()

				connection = effects.ChildAdded:Connect(function(child)
					if child:IsA("Model") and child.Name:match("^DroppedKey") then
						fn15(child)
					end
				end)
			end

			currentGame:GetPropertyChangedSignal("Value"):Connect(function()
				if MainModule.AutoEscapeEnabled and currentGame.Value ~= "HideAndSeek" then
					MainModule.AutoEscapeEnabled = false
					fn14()
				end
			end)

			fn16()

			while MainModule.AutoEscapeEnabled do
				if localPlayer2:FindFirstChild("Escaped") then
					MainModule.AutoEscapeEnabled = false
				elseif #fn8() > 0 then
					task.wait(0.5)
				else
					local v2 = fn12()

					if v2 then
						local v3 = fn13(v2)

						if v3 then
							local cframe = CFrame.lookAt(v3.CFrame.Position + v3.CFrame.LookVector * -2, v3.CFrame.Position)
							fn9(cframe)
							local circle = v2:FindFirstChild("DoorKnob") and v2.DoorKnob:FindFirstChild("Circle")
							local proximityPrompt = circle and circle:FindFirstChildOfClass("ProximityPrompt") or circle and circle:FindFirstChild("EscapePrompt")

							if proximityPrompt then
								while true do
									if localPlayer2:FindFirstChild("Escaped") then
										MainModule.AutoEscapeEnabled = false
										break
									else
										fn10(proximityPrompt)
										task.wait(0.05)
										if MainModule.AutoEscapeEnabled then
											continue
										end
										break
									end
								end
							end
						end
					end
				end

				task.wait(0.5)
			end

			fn14()
		end)
	end

	PlayToggleSound()
	return true
end

MainModule.toggle_auto_pickup = function(autoPickupEnabled)
	if autoPickupEnabled then
		if not MainModule.is_game_active("HideAndSeek") then
			MainModule.notify("Auto Pickup", "Wait for HideAndSeek!", 0.9)
			PlayErrorSound()

			if MainModule.ToggleRefs.AutoPickup then
				MainModule.ToggleRefs.AutoPickup:SetValue(false)
			end

			return false
		end
	end

	MainModule.AutoPickupEnabled = autoPickupEnabled

	if autoPickupEnabled then
		task.spawn(function()
			local Players2 = game:GetService("Players")
			local Workspace2 = game:GetService("Workspace")
			local localPlayer2 = Players2.LocalPlayer
			local values = Workspace2:FindFirstChild("Values")
			if not values then
				return
			end
			local currentGame = values:FindFirstChild("CurrentGame")

			if not currentGame or currentGame.Value ~= "HideAndSeek" then
				MainModule.AutoPickupEnabled = false

				if MainModule.ToggleRefs.AutoPickup then
					MainModule.ToggleRefs.AutoPickup:SetValue(false)
				end

				return
			end

			local humanoidRootPart = (localPlayer2.Character or localPlayer2.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")

			local function fn4()
				return localPlayer2:FindFirstChild("CurrentKeys")
			end

			local function fn5(arg)
				local v2 = fn4()
				return v2 and v2:FindFirstChild(arg) ~= nil
			end

			local function fn6()
				local tbl = {}

				for _, v2 in ipairs({ "Circle", "Triangle", "Square" }) do
					if not fn5(v2) then
						table.insert(tbl, v2)
					end
				end

				return tbl
			end

			local function fn7(arg)
				if humanoidRootPart and humanoidRootPart.Parent then
					humanoidRootPart.CFrame = CFrame.new(arg)
				end
			end

			local function fn8(arg)
				if not arg or not arg:IsA("ProximityPrompt") then
					return false
				end

				if fireproximityprompt then
					pcall(function()
						fireproximityprompt(arg)
					end)
				elseif syn and syn.proximityprompt then
					pcall(function()
						syn.proximityprompt(arg)
					end)
				else
					local holdDuration = arg.HoldDuration
					arg.HoldDuration = 0

					pcall(function()
						arg:InputHoldBegin()
						task.wait(0.05)
						arg:InputHoldEnd()
					end)

					arg.HoldDuration = holdDuration
				end

				return true
			end

			local function fn9()
				local tbl = {}
				local effects = Workspace2:FindFirstChild("Effects")

				if effects then
					for _, child in pairs(effects:GetChildren()) do
						local isModel = child:IsA("Model")

						if isModel then
							isModel = string.find(child.Name or "", "Key")
						end

						if isModel then
							local str

							if string.find(child.Name, "Circle") then
								str = "Circle"
							elseif string.find(child.Name, "Triangle") then
								str = "Triangle"
							else
								str = nil

								if string.find(child.Name, "Square") then
									str = "Square"
								end
							end

							if str then
								local primaryPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")

								if primaryPart then
									table.insert(tbl, { name = str, position = primaryPart.Position, model = child })
								end
							end
						end
					end
				end

				local hideAndSeekMap = Workspace2:FindFirstChild("HideAndSeekMap")

				if hideAndSeekMap then
					local fn10 = nil

					fn10 = function(arg)
						for _, child in pairs(arg:GetChildren()) do
							if child:IsA("Model") then
								local name = child.Name or ""

								if string.find(name, "Circle") or string.find(name, "Triangle") or string.find(name, "Square") then
									local str

									if string.find(name, "Circle") then
										str = "Circle"
									elseif string.find(name, "Triangle") then
										str = "Triangle"
									else
										str = nil

										if string.find(name, "Square") then
											str = "Square"
										end
									end

									if str then
										local primaryPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")

										if primaryPart then
											table.insert(tbl, { name = str, position = primaryPart.Position, model = child })
										end
									end
								end
							end

							fn10(child)
						end
					end

					fn10(hideAndSeekMap)
				end

				return tbl
			end

			local tbl = {}

			while MainModule.AutoPickupEnabled do
				if MainModule.is_game_active("HideAndSeek") then
					if localPlayer2:GetAttribute("IsHunter") == true then
						task.wait(1)
						continue
					elseif not localPlayer2:FindFirstChild("Escaped") then
						local v2 = fn6()

						if #v2 ~= 0 then
							local v3 = fn9()

							for _, v4 in pairs(v3) do
								if MainModule.AutoPickupEnabled then
									if table.find(v2, v4.name) and not tbl[v4.name] then
										fn7(v4.position + Vector3.new(0, 3, 0))
										task.wait(0.1)
										local proximityPrompt = nil

										if v4.model then
											proximityPrompt = v4.model:FindFirstChildOfClass("ProximityPrompt")

											if not proximityPrompt then
												for _, descendant in pairs(v4.model:GetDescendants()) do
													if descendant:IsA("ProximityPrompt") then
														proximityPrompt = descendant
														break
													end
												end
											end
										end

										if proximityPrompt then
											fn8(proximityPrompt)
											tbl[v4.name] = true
											PlayBell()
										end

										task.wait(0.3)
									end

									continue
								end

								break
							end

							task.wait(0.5)
							continue
						end
					end
				end

				break
			end

			MainModule.AutoPickupEnabled = false

			if MainModule.ToggleRefs.AutoPickup then
				MainModule.ToggleRefs.AutoPickup:SetValue(false)
			end
		end)
	end

	PlayToggleSound()
	return true
end

MainModule.teleport_random_exit = function()
	MainModule._MovecheckFromAuto = true
	pcall(MainModule.HSX_MovecheckAutoStart)
	MainModule._MovecheckFromAuto = false

	task.delay(2, function()
		pcall(MainModule.HSX_MovecheckAutoStop)
	end)

	local character = localPlayer.Character
	character = character and character:FindFirstChild("HumanoidRootPart")

	if not character then
		pcall(function()
			fn2("Teleport", "No character", 0.9)
		end)

		return
	end

	local tbl = {}
	local fn4 = nil

	fn4 = function(arg)
		if not arg then
			return
		end

		for _, child in pairs(arg:GetChildren()) do
			if child.Name == "EXITDOOR" and child:GetAttribute("ActuallyWorks") == true then
				local primaryPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)

				if primaryPart then
					table.insert(tbl, primaryPart)
				end
			end

			fn4(child)
		end
	end

	fn4(workspace:FindFirstChild("HideAndSeekMap") or workspace)

	if #tbl == 0 then
		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant.Name == "EXITDOOR" or descendant:IsA("Model") and descendant.Name:lower():find("exit") and descendant:GetAttribute("ActuallyWorks") == true then
				local primaryPart = descendant.PrimaryPart or descendant:FindFirstChildWhichIsA("BasePart", true)

				if primaryPart then
					table.insert(tbl, primaryPart)
				end
			end
		end
	end

	if #tbl == 0 then
		pcall(function()
			fn2("Teleport", "No exit doors found", 0.9)
		end)

		return
	end

	character.CFrame = CFrame.new(tbl[math.random(1, #tbl)].Position + Vector3.new(0, 4, 0))

	pcall(function()
		fn2("Teleport", "Random exit", 0.8)
	end)

	if PlayToggleSound then
		PlayToggleSound()
	end
end

MainModule.Misc = {
	ESPEnabled = false,
	ESPPlayers = true,
	ESPHiders = true,
	ESPSeekers = true,
	ESPNames = true,
	ESPDistance = true,
	ESPHighlight = true,
	ESPFillTransparency = 0.75,
	ESPOutlineTransparency = 0.2,
	ESPTextSize = 14,
}

MainModule.ESP = {
	Players = {},
	Objects = {},
	Connections = {},
	Folder = nil,
	MainConnection = nil,
	UpdateRate = 0.1,
}

MainModule.clear_player_esp = function(arg)
	if not arg then
		return
	end
	local v2 = MainModule.ESP.Players[arg]

	if v2 then
		if v2.Highlight then
			v2.Highlight.Adornee = nil

			pcall(function()
				v2.Highlight:Destroy()
			end)
		end

		if v2.Billboard then
			pcall(function()
				v2.Billboard:Destroy()
			end)
		end

		if v2.CharAddedConn then
			pcall(function()
				v2.CharAddedConn:Disconnect()
			end)

			v2.CharAddedConn = nil
		end

		if v2.DiedConn then
			pcall(function()
				v2.DiedConn:Disconnect()
			end)

			v2.DiedConn = nil
		end

		MainModule.ESP.Players[arg] = nil
	end
end

MainModule.update_player_esp = function(arg)
	if not arg or arg == localPlayer or not MainModule.Misc.ESPEnabled then
		return
	end
	local character = arg.Character
	if not character then
		MainModule.clear_player_esp(arg)
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local flag = humanoid and humanoid.Health <= 0 or character:FindFirstChild("Dead") ~= nil or arg:GetAttribute("Dead") == true or arg:GetAttribute("IsDead") == true

	if humanoid and humanoidRootPart and not flag and humanoid.Health > 0 then
		local tbl = MainModule.ESP.Players[arg]

		if not tbl then
			tbl = {
				Player = arg,
				Highlight = nil,
				Billboard = nil,
				Label = nil,
				CharAddedConn = nil,
				DiedConn = nil,
			}

			MainModule.ESP.Players[arg] = tbl

			tbl.DiedConn = humanoid.Died:Connect(function()
				if tbl.Highlight then
					tbl.Highlight.Adornee = nil
					tbl.Highlight.Enabled = false
				end

				if tbl.Billboard then
					tbl.Billboard.Enabled = false
				end
			end)
		end

		if not tbl.Highlight then
			tbl.Highlight = Instance.new("Highlight")
			tbl.Highlight.Name = arg.Name .. "_ESP"
			tbl.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			tbl.Highlight.Enabled = true
			tbl.Highlight.Parent = MainModule.ESP.Folder or CoreGui
		end

		if tbl.Highlight.Adornee ~= character then
			tbl.Highlight.Adornee = character
		end

		local color = Color3.fromRGB(0, 120, 255)

		if MainModule.is_hider and MainModule.is_hider(arg) then
			color = Color3.fromRGB(0, 255, 0)
		elseif MainModule.is_seeker and MainModule.is_seeker(arg) then
			color = Color3.fromRGB(255, 0, 0)
		end

		tbl.Highlight.FillColor = color
		tbl.Highlight.OutlineColor = color
		tbl.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
		tbl.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
		tbl.Highlight.Enabled = true

		if MainModule.Misc.ESPNames then
			if not tbl.Billboard then
				tbl.Billboard = Instance.new("BillboardGui")
				tbl.Billboard.Name = arg.Name .. "_Text"
				tbl.Billboard.AlwaysOnTop = true
				tbl.Billboard.Size = UDim2.new(0, 200, 0, 50)
				tbl.Billboard.StudsOffset = Vector3.new(0, 2.5, 0)
				tbl.Billboard.Parent = MainModule.ESP.Folder or CoreGui
				tbl.Label = Instance.new("TextLabel")
				tbl.Label.Size = UDim2.new(1, 0, 1, 0)
				tbl.Label.BackgroundTransparency = 1
				tbl.Label.TextColor3 = color
				tbl.Label.TextSize = 14
				tbl.Label.Font = Enum.Font.GothamBold
				tbl.Label.TextStrokeColor3 = Color3.new(0, 0, 0)
				tbl.Label.TextStrokeTransparency = 0.5
				tbl.Label.Parent = tbl.Billboard
			end

			if tbl.Billboard.Adornee ~= humanoidRootPart then
				tbl.Billboard.Adornee = humanoidRootPart
			end

			tbl.Billboard.Enabled = true
			tbl.Label.Text = (arg.DisplayName or arg.Name) .. "\n" .. string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
			tbl.Label.TextColor3 = color
		elseif tbl.Billboard then
			tbl.Billboard.Enabled = false
		end
	else
		local v2 = MainModule.ESP.Players[arg]

		if v2 then
			if v2.Highlight then
				v2.Highlight.Enabled = false
				v2.Highlight.Adornee = nil
			end

			if v2.Billboard then
				v2.Billboard.Enabled = false
				v2.Billboard.Adornee = nil
			end
		end
	end
end

MainModule.setup_player_esp = function(arg)
	if arg == localPlayer then
		return
	end
	MainModule.clear_player_esp(arg)

	if arg.Character then
		MainModule.update_player_esp(arg)
	end

	local connection = arg.CharacterAdded:Connect(function()
		task.wait(0.05)
		MainModule.update_player_esp(arg)
	end)

	local v2 = MainModule.ESP.Players[arg]

	if v2 then
		v2.CharAddedConn = connection
	end
end

MainModule.toggle_old_esp = function(espEnabled)
	MainModule.Misc.ESPEnabled = espEnabled

	if MainModule.ESP.MainConnection then
		MainModule.ESP.MainConnection:Disconnect()
		MainModule.ESP.MainConnection = nil
	end

	MainModule.clear_esp()

	if espEnabled then
		MainModule.ESP.Folder = Instance.new("Folder")
		MainModule.ESP.Folder.Name = "HollyScriptX_ESP"
		MainModule.ESP.Folder.Parent = CoreGui

		for _, player in pairs(Players:GetPlayers()) do
			if player ~= localPlayer then
				MainModule.setup_player_esp(player)
			end
		end

		MainModule.ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
			if MainModule.Misc.ESPEnabled then
				MainModule.setup_player_esp(player)
			end
		end)

		MainModule.ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
			MainModule.clear_player_esp(player)
		end)

		local n = 0
		local n2 = 0

		MainModule.ESP.MainConnection = RunService.Heartbeat:Connect(function(deltaTime)
			if not MainModule.Misc.ESPEnabled then
				return
			end
			n += deltaTime or 0.016
			if n < 0.15 then
				return
			end
			n = 0
			local n3 = 0

			for k in pairs(MainModule.ESP.Players) do
				n3 += 1

				if not (n3 > 8) then
					if k and k.Parent then
						MainModule.update_player_esp(k)
					else
						MainModule.clear_player_esp(k)
					end

					continue
				end

				break
			end

			if tick() - n2 > 10 then
				n2 = tick()

				for k, player in pairs(MainModule.ESP.Players) do
					local character = k and k.Character
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")

					if not character or humanoid and humanoid.Health <= 0 or character and character:FindFirstChild("Dead") or k:GetAttribute("Dead") == true then
						if player.Highlight then
							player.Highlight.Enabled = false
							player.Highlight.Adornee = nil
						end

						if player.Billboard then
							player.Billboard.Enabled = false
						end
					end
				end
			end
		end)
	end

	PlayToggleSound()
end

MainModule.clear_esp = function()
	for k in pairs(MainModule.ESP.Players) do
		MainModule.clear_player_esp(k)
	end

	MainModule.ESP.Players = {}

	if MainModule.ESP.Connections then
		for k, connection in pairs(MainModule.ESP.Connections) do
			if connection then
				pcall(function()
					connection:Disconnect()
				end)

				MainModule.ESP.Connections[k] = nil
			end
		end
	end

	if MainModule.ESP.Folder then
		pcall(function()
			MainModule.ESP.Folder:Destroy()
		end)

		MainModule.ESP.Folder = nil
	end
end

local Players2
Players2 = game:GetService("Players")
local RunService2
RunService2 = game:GetService("RunService")
local SoundService
SoundService = game:GetService("SoundService")
local localPlayer2, fn4, fn5

do
	local CoreGui2 = game:GetService("CoreGui")
	localPlayer2 = Players2.LocalPlayer
	MainModule = MainModule or {}

	local function fn6(soundId, volume)
		if not soundId or soundId == "" then
			return
		end

		pcall(function()
			game:GetService("ContentProvider"):PreloadAsync({ soundId })
		end)

		pcall(function()
			local sound = Instance.new("Sound")
			sound.SoundId = soundId
			sound.Volume = volume or 4
			sound.Looped = false
			sound.Parent = game:GetService("SoundService")
			sound:Play()

			task.delay(8, function()
				pcall(function()
					sound:Destroy()
				end)
			end)
		end)
	end

	fn4 = function()
		task.spawn(function()
			local ogg3 = ogg

			if not ogg3 or ogg3 == "" then
				pcall(function()
					local response = game:HttpGet("https://raw.githubusercontent.com/wwxohzxc1337-droid/ewngEHWIJFKELG/main/2026-09-12-03-09-48.ogg")

					if type(response) == "string" and #response > 100 and writefile then
						writefile("HSX_Toggle.ogg", response)
					end

					ogg3 = fn("HSX_Toggle.ogg")
					ogg = ogg3
				end)
			end

			fn6(ogg3, 1)
		end)
	end

	local function fn7()
		task.spawn(function()
			local ogg3 = ogg2

			if not ogg3 or ogg3 == "" then
				pcall(function()
					local response = game:HttpGet("https://raw.githubusercontent.com/wwxohzxc1337-droid/ewngEHWIJFKELG/main/2026-09-12-03-20-58.ogg")

					if type(response) == "string" and #response > 100 and writefile then
						writefile("HSX_Failed.ogg", response)
					end

					ogg3 = fn("HSX_Failed.ogg")
					ogg2 = ogg3
				end)
			end

			fn6(ogg3, 1)
		end)
	end

	fn5 = function()
		fn4()

		task.delay(0.12, function()
			fn7()
		end)
	end

	PlayToggleSound, PlayErrorSound = fn4, fn5

	local tbl = { Enabled = false, RGB = false, Cache = {}, Connection = nil }
	local newESP = CoreGui2:FindFirstChild("NewESP")

	if newESP then
		newESP:Destroy()
	end

	tbl.ScreenGui = Instance.new("ScreenGui")
	tbl.ScreenGui.Name = "NewESP"
	tbl.ScreenGui.ResetOnSpawn = false
	tbl.ScreenGui.IgnoreGuiInset = true
	tbl.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	tbl.ScreenGui.DisplayOrder = 999999
	tbl.ScreenGui.Parent = CoreGui2

	local function fn8(arg, arg2)
		if not arg or not arg2 then
			return nil
		end
		local flag = arg:GetAttribute("Hunter") == true or arg:GetAttribute("IsHunter") == true or arg2:GetAttribute("Hunter") == true or arg2:GetAttribute("IsHunter") == true
		local flag2 = arg:GetAttribute("Hider") == true or arg:GetAttribute("IsHider") == true or arg2:GetAttribute("Hider") == true or arg2:GetAttribute("IsHider") == true
		if flag then
			return "Hunter"
		end

		if flag2 then
			return "Hider"
		end
		return nil
	end

	local function fn9(arg, arg2)
		local v2 = fn8(arg, arg2)
		if v2 == "Hunter" then
			return Color3.fromRGB(255, 65, 65)
		end

		if v2 == "Hider" then
			return Color3.fromRGB(65, 145, 255)
		end

		if tbl.RGB then
			return Color3.fromHSV(os.clock() * 0.35 % 1, 0.9, 1)
		end
		return Color3.fromRGB(235, 235, 240)
	end

	local function fn10(arg)
		if arg > 0.6 then
			return Color3.fromRGB(40, 240, 80)
		end

		if arg > 0.3 then
			return Color3.fromRGB(255, 215, 40)
		end
		return Color3.fromRGB(255, 55, 55)
	end

	tbl.Hide = function(arg)
		if not arg then
			return
		end

		if arg.Box then
			arg.Box.Visible = false
		end

		if arg.Name then
			arg.Name.Visible = false
		end

		if arg.HealthText then
			arg.HealthText.Visible = false
		end

		if arg.HealthBg then
			arg.HealthBg.Visible = false
		end

		if arg.HealthBar then
			arg.HealthBar.Visible = false
		end
	end

	tbl.HideAll = function()
		for _, v2 in pairs(tbl.Cache) do
			tbl.Hide(v2)
		end
	end

	tbl.DestroyESP = function(arg)
		if not arg then
			return
		end

		pcall(function()
			if arg.Box then
				arg.Box:Destroy()
			end

			if arg.Name then
				arg.Name:Destroy()
			end

			if arg.HealthText then
				arg.HealthText:Destroy()
			end

			if arg.HealthBg then
				arg.HealthBg:Destroy()
			end

			if arg.HealthBar then
				arg.HealthBar:Destroy()
			end
		end)
	end

	tbl.ClearAll = function()
		for _, v2 in pairs(tbl.Cache) do
			tbl.DestroyESP(v2)
		end

		table.clear(tbl.Cache)
	end

	tbl.Create = function(arg)
		if tbl.Cache[arg] then
			return tbl.Cache[arg]
		end
		local tbl2 = {}
		local frame = Instance.new("Frame")
		frame.Name = "Box"
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Visible = false
		frame.ZIndex = 10
		frame.Parent = tbl.ScreenGui
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 1.5
		uiStroke.Transparency = 0
		uiStroke.Color = Color3.fromRGB(235, 235, 240)
		uiStroke.Parent = frame
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "Name"
		textLabel.BackgroundTransparency = 1
		textLabel.BorderSizePixel = 0
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = 13
		textLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
		textLabel.TextStrokeTransparency = 0.25
		textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		textLabel.TextXAlignment = Enum.TextXAlignment.Center
		textLabel.Visible = false
		textLabel.ZIndex = 11
		textLabel.Parent = tbl.ScreenGui
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "Health"
		textLabel2.BackgroundTransparency = 1
		textLabel2.BorderSizePixel = 0
		textLabel2.Font = Enum.Font.Gotham
		textLabel2.TextSize = 11
		textLabel2.TextColor3 = Color3.fromRGB(235, 235, 240)
		textLabel2.TextStrokeTransparency = 0.25
		textLabel2.TextStrokeColor3 = Color3.new(0, 0, 0)
		textLabel2.TextXAlignment = Enum.TextXAlignment.Center
		textLabel2.Visible = false
		textLabel2.ZIndex = 11
		textLabel2.Parent = tbl.ScreenGui
		local frame2 = Instance.new("Frame")
		frame2.Name = "HealthBackground"
		frame2.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
		frame2.BorderSizePixel = 0
		frame2.Visible = false
		frame2.ZIndex = 10
		frame2.Parent = tbl.ScreenGui
		local frame3 = Instance.new("Frame")
		frame3.Name = "HealthBar"
		frame3.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		frame3.BorderSizePixel = 0
		frame3.Visible = false
		frame3.ZIndex = 11
		frame3.Parent = tbl.ScreenGui
		tbl2.Box = frame
		tbl2.BoxStroke = uiStroke
		tbl2.Name = textLabel
		tbl2.HealthText = textLabel2
		tbl2.HealthBg = frame2
		tbl2.HealthBar = frame3
		tbl.Cache[arg] = tbl2
		return tbl2
	end

	local tbl2 = {
		"Head",
		"HumanoidRootPart",
		"UpperTorso",
		"LowerTorso",
		"Torso",
		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand",
		"RightUpperArm",
		"RightLowerArm",
		"RightHand",
		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot",
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
		"Left Arm",
		"Right Arm",
		"Left Leg",
		"Right Leg",
	}

	local function fn11(arg, arg2)
		local flag = false
		local huge = math.huge
		local huge2 = math.huge
		local n = -math.huge
		local n2 = -math.huge

		for _, v2 in ipairs(tbl2) do
			local v3 = arg:FindFirstChild(v2)

			if v3 and v3:IsA("BasePart") then
				local cFrame = v3.CFrame
				local size = v3.Size
				local n3 = size.X / 2
				local n4 = size.Y / 2
				local n5 = size.Z / 2
				local tbl3 = {}
				local vector = Vector3.new(-n3, -n4, -n5)
				local vector2 = Vector3.new(-n3, -n4, n5)
				local vector3 = Vector3.new(-n3, n4, -n5)
				local vector4 = Vector3.new(-n3, n4, n5)
				local vector5 = Vector3.new(n3, -n4, -n5)
				local vector6 = Vector3.new(n3, -n4, n5)
				local vector7 = Vector3.new(n3, n4, -n5)
				local vector8 = Vector3.new
				tbl3[1] = vector
				tbl3[2] = vector2
				tbl3[3] = vector3
				tbl3[4] = vector4
				tbl3[5] = vector5
				tbl3[6] = vector6
				tbl3[7] = vector7

				do
					local values = table.pack(vector8(n3, n4, n5))
					table.move(values, 1, values.n, 8, tbl3)
				end

				for _, v4 in ipairs(tbl3) do
					local v5 = cFrame:PointToWorldSpace(v4)
					local v6 = arg2:WorldToViewportPoint(v5)

					if v6.Z > 0 then
						flag = true
						huge = math.min(huge, v6.X)
						huge2 = math.min(huge2, v6.Y)
						n = math.max(n, v6.X)
						n2 = math.max(n2, v6.Y)
					end
				end
			end
		end

		if not flag then
			return nil
		end
		local n3 = n - huge
		local n4 = n2 - huge2
		if n3 < 2 or n4 < 2 then
			return nil
		end
		local n5 = math.max(2, n3 * 0.05)
		local n6 = math.max(2, n4 * 0.025)
		return huge - n5, huge2 - n6, n + n5, n2 + n6
	end

	tbl.Update = function()
		if not tbl.Enabled then
			tbl.HideAll()
			return
		end
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then
			return
		end
		local tbl3 = {}

		for _, player in ipairs(Players2:GetPlayers()) do
			if player ~= localPlayer2 then
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if character and humanoid and humanoidRootPart and humanoid.Health > 0 and humanoidRootPart.Position.Y > -50 then
					tbl3[player] = true
					local v2 = tbl.Cache[player] or tbl.Create(player)
					local v3, v4, v5, v6 = fn11(character, currentCamera)

					if v3 then
						local n = v5 - v3
						local n2 = v6 - v4
						local n3 = v3 + n / 2
						local v7 = fn9(player, character)
						local round = math.round
						v2.Box.Position = UDim2.fromOffset(math.round(v3), round(v4))
						v2.Box.Size = UDim2.fromOffset(math.max(1, math.round(n)), math.max(1, math.round(n2)))
						v2.BoxStroke.Color = v7
						v2.Box.Visible = true
						local displayName = player.DisplayName

						if not displayName or displayName == "" then
							displayName = player.Name
						end

						v2.Name.Text = displayName
						v2.Name.TextColor3 = v7
						local n4 = math.max(n + 80, 130)
						v2.Name.Size = UDim2.fromOffset(n4, 18)
						v2.Name.Position = UDim2.fromOffset(n3 - n4 / 2, v4 - 20)
						v2.Name.Visible = true
						local n5 = 0

						if humanoid.MaxHealth > 0 then
							n5 = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
						end

						local n6 = v3 - 7
						v2.HealthBg.Position = UDim2.fromOffset(n6 - 1, v4 - 1)
						v2.HealthBg.Size = UDim2.fromOffset(5, n2 + 2)
						v2.HealthBg.Visible = true
						local n7 = n2 * n5
						v2.HealthBar.Position = UDim2.fromOffset(n6, v6 - n7)
						v2.HealthBar.Size = UDim2.fromOffset(3, n7)
						v2.HealthBar.BackgroundColor3 = fn10(n5)
						v2.HealthBar.Visible = true
						v2.HealthText.Text = math.floor(humanoid.Health) .. " / " .. math.floor(humanoid.MaxHealth)
						local n8 = math.max(n + 80, 120)
						v2.HealthText.Size = UDim2.fromOffset(n8, 16)
						v2.HealthText.Position = UDim2.fromOffset(n3 - n8 / 2, v6 + 2)
						v2.HealthText.Visible = true
					else
						tbl.Hide(v2)
					end
				end
			end
		end

		for k, v2 in pairs(tbl.Cache) do
			if not tbl3[k] then
				tbl.DestroyESP(v2)
				tbl.Cache[k] = nil
			end
		end
	end

	MainModule.toggle_new_esp = function(arg)
		tbl.Enabled = arg and true or false

		if tbl.Enabled then
			if not tbl.Connection then
				local n = 0

				tbl.Connection = RunService2.Heartbeat:Connect(function(deltaTime)
					if not tbl.Enabled then
						return
					end
					n += deltaTime or 0.016
					if n < 0.15 then
						return
					end
					n = 0
					local ok, result = pcall(tbl.Update)

					if not ok then
						warn("[NewESP]", result)
					end
				end)
			end
		else
			if tbl.Connection then
				tbl.Connection:Disconnect()
				tbl.Connection = nil
			end

			tbl.HideAll()
			tbl.ClearAll()
		end

		fn4()
	end

	MainModule.toggle_esprgb = function(arg)
		tbl.RGB = arg and true or false
		fn4()
	end
end

MainModule.PlayerESPEnabled = MainModule.PlayerESPEnabled or false
MainModule.ESPRGBEnabled = MainModule.ESPRGBEnabled or false
MainModule.ESP_Mode = MainModule.ESP_Mode or "Old"

MainModule.set_esp_mode = function(espMode)
	MainModule.ESP_Mode = espMode
	MainModule.toggle_new_esp(false)

	if MainModule.toggle_old_esp then
		MainModule.toggle_old_esp(false)
	end

	if MainModule.PlayerESPEnabled then
		if espMode == "New" then
			MainModule.toggle_new_esp(true)
		elseif espMode == "Old" and MainModule.toggle_old_esp then
			MainModule.toggle_old_esp(true)
		end
	end

	fn4()
end

MainModule.toggle_player_esp = function(arg)
	MainModule.PlayerESPEnabled = arg and true or false

	if arg then
		if MainModule.ESP_Mode == "New" then
			MainModule.toggle_new_esp(true)
		elseif MainModule.toggle_old_esp then
			MainModule.toggle_old_esp(true)
		end
	else
		MainModule.toggle_new_esp(false)

		if MainModule.toggle_old_esp then
			MainModule.toggle_old_esp(false)
		end
	end

	fn4()
end

MainModule.AutoSafe = { Enabled = false, Connection = nil, HasTeleported = false, LowHPChecked = false }

MainModule.toggle_auto_safe = function(enabled)
	if MainModule.AutoSafe.Connection then
		MainModule.AutoSafe.Connection:Disconnect()
		MainModule.AutoSafe.Connection = nil
	end

	MainModule.AutoSafe.Enabled = enabled
	MainModule.AutoSafe.HasTeleported = false
	MainModule.AutoSafe.LowHPChecked = false

	if enabled then
		MainModule.AutoSafe.Connection = RunService2.Heartbeat:Connect(function()
			if not MainModule.AutoSafe.Enabled then
				if MainModule.AutoSafe.Connection then
					MainModule.AutoSafe.Connection:Disconnect()
					MainModule.AutoSafe.Connection = nil
				end

				return
			end

			local flag = false

			for _, v2 in pairs({
				"Mingle",
				"JumpRope",
				"Pentathlon",
				"GlassBridge",
				"SquidGame",
				"SkySquidGame",
				"RedLightGreenLight",
				"TugOfWar",
			}) do
				if MainModule.is_game_active(v2) then
					flag = true
					break
				end
			end

			if flag then
				return
			end
			local v2 = MainModule.get_character()

			if v2 then
				local humanoid = v2:FindFirstChildOfClass("Humanoid")

				if humanoid then
					if MainModule.is_game_active("HideAndSeek") or MainModule.is_game_active("LightsOut") or MainModule.is_game_active("LightOut") then
						if humanoid.Health <= 30 then
							if not MainModule.AutoSafe.HasTeleported then
								local humanoidRootPart = v2:FindFirstChild("HumanoidRootPart") or v2.PrimaryPart

								if humanoidRootPart then
									local position = humanoidRootPart.Position
									local vector = Vector3.new(position.X, position.Y + 150, position.Z)
									humanoidRootPart.CFrame = CFrame.new(vector)
									MainModule.AutoSafe.HasTeleported = true
									MainModule.AutoSafe.LowHPChecked = true
								end
							end
						elseif humanoid.Health > 30 and MainModule.AutoSafe.HasTeleported then
							MainModule.AutoSafe.HasTeleported = false
						end
					elseif humanoid.Health <= 30 then
						if not MainModule.AutoSafe.HasTeleported then
							local humanoidRootPart = v2:FindFirstChild("HumanoidRootPart") or v2.PrimaryPart

							if humanoidRootPart then
								local position = humanoidRootPart.Position
								local vector = Vector3.new(position.X, position.Y + 100, position.Z)
								humanoidRootPart.CFrame = CFrame.new(vector)
								MainModule.AutoSafe.HasTeleported = true
								MainModule.AutoSafe.LowHPChecked = true
							end
						end
					elseif humanoid.Health > 30 and MainModule.AutoSafe.HasTeleported then
						MainModule.AutoSafe.HasTeleported = false
					end
				end
			end
		end)
	end

	fn4()
end

MainModule.dalgona_lighter = function()
	if MainModule.is_game_active("Dalgona") then
		localPlayer2:SetAttribute("HasLighter", true)
	else
		MainModule.notify("Dalgona", "Wait for Dalgona!", 0.9)
		fn5()
	end

	fn4()
end

MainModule.AutoCollectFlashbang = false
MainModule.AutoCollectFlashbangLoop = nil

MainModule.toggle_auto_collect_flashbang = function(autoCollectFlashbang)
	MainModule.AutoCollectFlashbang = autoCollectFlashbang

	if MainModule.AutoCollectFlashbangLoop then
		task.cancel(MainModule.AutoCollectFlashbangLoop)
		MainModule.AutoCollectFlashbangLoop = nil
	end

	if autoCollectFlashbang then
		MainModule.AutoCollectFlashbangLoop = task.spawn(function()
			while MainModule.AutoCollectFlashbang do
				local v2 = MainModule.get_character()

				if v2 then
					local v3 = MainModule.get_root_part(v2)

					if v3 then
						local cFrame = v3.CFrame

						if not MainModule.has_tool("Flashbang") then
							local effects = workspace:FindFirstChild("Effects")
							local flag = false

							if effects then
								flag = false

								for _, child in pairs(effects:GetChildren()) do
									if child.Name == "DroppedFlashbang" and child:FindFirstChild("Stun Grenade") then
										v3.CFrame = child["Stun Grenade"].CFrame
										flag = true
										break
									else
										flag = false
									end
								end
							end

							if flag then
								task.wait(0.3)
								v3.CFrame = cFrame
							end
						end
					end
				end

				task.wait(0.5)
			end
		end)
	end

	fn4()
end

MainModule.AutoCollectGrenade = false
MainModule.AutoCollectGrenadeLoop = nil

MainModule.toggle_auto_collect_grenade = function(autoCollectGrenade)
	MainModule.AutoCollectGrenade = autoCollectGrenade

	if MainModule.AutoCollectGrenadeLoop then
		task.cancel(MainModule.AutoCollectGrenadeLoop)
		MainModule.AutoCollectGrenadeLoop = nil
	end

	if autoCollectGrenade then
		MainModule.AutoCollectGrenadeLoop = task.spawn(function()
			while MainModule.AutoCollectGrenade do
				local v2 = MainModule.get_character()

				if v2 then
					local v3 = MainModule.get_root_part(v2)

					if v3 then
						local cFrame = v3.CFrame

						if not MainModule.has_tool("Grenade") then
							local effects = workspace:FindFirstChild("Effects")
							local flag = false

							if effects then
								flag = false

								for _, child in pairs(effects:GetChildren()) do
									if child.Name == "DroppedGrenade" and child:FindFirstChild("Handle") then
										v3.CFrame = child.Handle.CFrame
										flag = true
										break
									else
										flag = false
									end
								end
							end

							if flag then
								task.wait(0.3)
								v3.CFrame = cFrame
							end
						end
					end
				end

				task.wait(0.5)
			end
		end)
	end

	fn4()
end

MainModule.jr_tp_start = function()
	if MainModule.is_game_active("JumpRope") then
		MainModule.safe_teleport(Vector3.new(615.2844, 192.27428, 920.9525))
		MainModule.notify("JumpRope", "Teleported to Start", 0.9)
	else
		MainModule.notify("JumpRope", "Wait for JumpRope!", 0.9)
		fn5()
	end

	fn4()
end

MainModule.jr_tp_end = function()
	if MainModule.is_game_active("JumpRope") then
		MainModule.safe_teleport(Vector3.new(720.89606, 198.62831, 921.17065))
		MainModule.notify("JumpRope", "Teleported to End", 0.9)
	else
		MainModule.notify("JumpRope", "Wait for JumpRope!", 0.9)
		fn5()
	end

	fn4()
end

MainModule.jr_delete_rope = function()
	if MainModule.is_game_active("JumpRope") then
		for _, descendant in pairs(workspace:GetDescendants()) do
			if descendant.Name == "Rope" and (descendant:IsA("Model") or descendant:IsA("Part")) then
				descendant:Destroy()
				MainModule.notify("JumpRope", "Rope deleted", 0.9)
				fn4()
				return
			end
		end

		MainModule.notify("JumpRope", "Rope not found", 0.9)
		fn5()
	else
		MainModule.notify("JumpRope", "Wait for JumpRope!", 0.9)
		fn5()
	end

	fn4()
end

MainModule.GlobalAntiFall = { Enabled = false, Platform = nil, Conn = nil }

MainModule.toggle_global_anti_fall = function(arg)
	MainModule.GlobalAntiFall.Enabled = arg and true or false

	if MainModule.GlobalAntiFall.Conn then
		pcall(function()
			MainModule.GlobalAntiFall.Conn:Disconnect()
		end)

		MainModule.GlobalAntiFall.Conn = nil
	end

	if MainModule.GlobalAntiFall.Platform then
		pcall(function()
			MainModule.GlobalAntiFall.Platform:Destroy()
		end)

		MainModule.GlobalAntiFall.Platform = nil
	end

	if not arg then
		fn4()
		return true
	end

	local function createPart()
		local getCharacter = MainModule.get_character and MainModule.get_character() or localPlayer2.Character
		local humanoidRootPart

		if getCharacter then
			humanoidRootPart = getCharacter:FindFirstChild("HumanoidRootPart") or getCharacter.PrimaryPart
		else
			humanoidRootPart = getCharacter
		end

		if not humanoidRootPart then
			return nil
		end
		local part = Instance.new("Part")
		part.Name = HttpService:GenerateGUID(false)
		part.Size = Vector3.new(12, 1, 12)
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 0.5
		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.fromRGB(100, 100, 100)
		part.CFrame = CFrame.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Y - 3.5, humanoidRootPart.Position.Z)
		part.Parent = workspace
		return part
	end

	MainModule.GlobalAntiFall.Platform = createPart()

	MainModule.GlobalAntiFall.Conn = RunService2.Heartbeat:Connect(function()
		if not MainModule.GlobalAntiFall.Enabled then
			return
		end
		local getCharacter = MainModule.get_character and MainModule.get_character() or localPlayer2.Character

		if getCharacter then
			getCharacter = getCharacter:FindFirstChild("HumanoidRootPart") or getCharacter.PrimaryPart
		end

		if not getCharacter then
			return
		end

		if not (MainModule.GlobalAntiFall.Platform and MainModule.GlobalAntiFall.Platform.Parent) then
			MainModule.GlobalAntiFall.Platform = createPart()
		end

		if MainModule.GlobalAntiFall.Platform then
			MainModule.GlobalAntiFall.Platform.CFrame = CFrame.new(getCharacter.Position.X, getCharacter.Position.Y - 3.5, getCharacter.Position.Z)
			MainModule.GlobalAntiFall.Platform.Transparency = 0.5
		end
	end)

	fn4()
	return true
end

MainModule.JumpRopeAntiFall = { Enabled = false, Platform = nil, Conn = nil }

MainModule.toggle_jump_rope_anti_fall = function(enabled)
	if enabled then
		MainModule._MovecheckFromAuto = true
		pcall(MainModule.HSX_MovecheckAutoStart)
		MainModule._MovecheckFromAuto = false
	else
		pcall(MainModule.HSX_MovecheckAutoStop)
	end

	if enabled then
		if MainModule.is_game_active and not MainModule.is_game_active("JumpRope") then
			MainModule.notify("JumpRope", "Wait for JumpRope!", 0.9)
			fn5()
			return
		end
	end

	local jumpRopeAntiFall = MainModule.ToggleRefs.JumpRopeAntiFall

	if enabled then
		if not MainModule.can_enable_toggle("JumpRope", "Anti Fall", jumpRopeAntiFall) then
			return false
		end
	end

	if MainModule.JumpRopeAntiFall.Conn then
		MainModule.JumpRopeAntiFall.Conn:Disconnect()
	end

	if MainModule.JumpRopeAntiFall.Platform then
		MainModule.JumpRopeAntiFall.Platform:Destroy()
	end

	MainModule.JumpRopeAntiFall.Enabled = enabled

	if enabled then
		local function createPart()
			local v2 = MainModule.get_character()
			if not v2 then
				return nil
			end
			local v3 = MainModule.get_root_part(v2)
			if not v3 then
				return nil
			end
			local part = Instance.new("Part")
			part.Name = HttpService:GenerateGUID(false)
			part.Size = Vector3.new(10000, 1, 10000)
			part.Position = Vector3.new(v3.Position.X, v3.Position.Y - 5, v3.Position.Z)
			part.Anchored = true
			part.CanCollide = true
			part.Transparency = 0.5
			part.Parent = workspace
			return part
		end

		MainModule.JumpRopeAntiFall.Platform = createPart()

		MainModule.JumpRopeAntiFall.Conn = RunService2.Heartbeat:Connect(function()
			if not MainModule.JumpRopeAntiFall.Enabled then
				return
			end

			if not MainModule.is_game_active("JumpRope") then
				MainModule.disable_toggle("JumpRopeAntiFall")
				return
			end

			if not (MainModule.JumpRopeAntiFall.Platform and MainModule.JumpRopeAntiFall.Platform.Parent) then
				MainModule.JumpRopeAntiFall.Platform = createPart()
			end
		end)
	end

	fn4()
	return true
end

MainModule.gb_tp_end = function()
	if MainModule.is_game_active("GlassBridge") then
		MainModule.safe_teleport(Vector3.new(-196.37247, 522.19214, -1534.2098))
		MainModule.notify("GlassBridge", "Teleported to End", 0.9)
	else
		MainModule.notify("GlassBridge", "Wait for GlassBridge!", 0.9)
		fn5()
	end

	fn4()
end

MainModule.GlassESPEnabled = false
MainModule.GlassESPConnection = nil
MainModule.GlassESPHighlighted = {}
MainModule.GlassESPOriginal = {}

MainModule.toggle_glass_esp = function(arg)
	if arg then
		if MainModule.is_game_active and not MainModule.is_game_active("GlassBridge") then
			MainModule.notify("Glass ESP", "Wait for GlassBridge!", 0.9)
			fn5()
			return
		end
	end

	local glassESP = MainModule.ToggleRefs.GlassESP

	if arg then
		if not MainModule.can_enable_toggle("GlassBridge", "Glass ESP", glassESP) then
			return false
		end
	end

	MainModule.GlassESPEnabled = arg and true or false

	if MainModule.GlassESPConnection then
		pcall(function()
			MainModule.GlassESPConnection:Disconnect()
		end)

		MainModule.GlassESPConnection = nil
	end

	for k, v2 in pairs(MainModule.GlassESPOriginal) do
		if k and k.Parent then
			pcall(function()
				k.Color = v2.Color
				k.Material = v2.Material
			end)
		end
	end

	MainModule.GlassESPOriginal = {}
	MainModule.GlassESPHighlighted = {}
	if not arg then
		fn4()
		return true
	end
	local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
	if not glassHolder then
		fn4()
		return true
	end

	local function fn6(arg2)
		if not arg2:GetAttribute("GlassPart") then
			return nil
		end
		local flag = arg2:GetAttribute("ActuallyKilling") ~= nil
		local flag2 = arg2:GetAttribute("DelayedBreaking") ~= nil
		if flag and flag2 then
			return "delayed"
		end

		if flag then
			return "fake"
		end
		return "real"
	end

	local tbl = {
		real = Color3.fromRGB(0, 255, 0),
		delayed = Color3.fromRGB(255, 200, 0),
		fake = Color3.fromRGB(255, 0, 0),
	}

	for _, descendant in ipairs(glassHolder:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant:GetAttribute("GlassPart") then
			local v2 = fn6(descendant)

			if v2 then
				if not MainModule.GlassESPOriginal[descendant] then
					MainModule.GlassESPOriginal[descendant] = { Color = descendant.Color, Material = descendant.Material }
				end

				descendant.Color = tbl[v2]
				descendant.Material = Enum.Material.Neon
				MainModule.GlassESPHighlighted[descendant] = v2
			end
		end
	end

	MainModule.GlassESPConnection = RunService2.RenderStepped:Connect(function()
		if not MainModule.GlassESPEnabled then
			return
		end

		if not glassHolder.Parent then
			if MainModule.GlassESPConnection then
				MainModule.GlassESPConnection:Disconnect()
				MainModule.GlassESPConnection = nil
			end

			return
		end

		for k, v2 in pairs(MainModule.GlassESPHighlighted) do
			if k and k.Parent then
				k.Color = tbl[v2]
				k.Material = Enum.Material.Neon
			else
				MainModule.GlassESPHighlighted[k] = nil
			end
		end
	end)

	fn4()
	return true
end

MainModule.set_title = function(currentTitleValue)
	MainModule.CurrentTitleValue = currentTitleValue

	if MainModule.TitleEnabled then
		MainModule.update_title()
	end
end

MainModule.AntiBreakEnabled = false
MainModule.AntiBreakConn = nil
MainModule.SafetyPlatforms = {}

MainModule.toggle_anti_break = function(arg)
	local antiBreakEnabled = arg and true or false
	MainModule.AntiBreakEnabled = antiBreakEnabled

	if MainModule.AntiBreakConn then
		pcall(function()
			MainModule.AntiBreakConn:Disconnect()
		end)

		MainModule.AntiBreakConn = nil
	end

	local function fn6()
		local glassBridge = Workspace:FindFirstChild("GlassBridge")
		if not glassBridge then
			return
		end
		local glassHolder = glassBridge:FindFirstChild("GlassHolder")
		if not glassHolder then
			return
		end

		for _, descendant in ipairs(glassHolder:GetDescendants()) do
			local isTouchTransmitter = descendant:IsA("TouchTransmitter")
			local pos

			if isTouchTransmitter then
				pos = isTouchTransmitter
			else
				local isProximityPrompt = descendant:IsA("ProximityPrompt")

				if isProximityPrompt then
					pos = isProximityPrompt
				else
					pos = typeof(descendant.Name) == "string" and descendant.Name:lower():find("touch")
				end
			end

			if pos then
				pcall(function()
					descendant:Destroy()
				end)
			elseif descendant:IsA("BasePart") then
				for _, child in ipairs(descendant:GetChildren()) do
					if child.ClassName == "TouchInterest" then
						pcall(function()
							child:Destroy()
						end)
					end
				end
			end
		end
	end

	if antiBreakEnabled then
		fn6()

		MainModule.AntiBreakConn = RunService2.Heartbeat:Connect(function()
			if not MainModule.AntiBreakEnabled then
				return
			end
			local now = tick()
			if now < (MainModule._AntiBreakLast or 0) + 1 then
				return
			end
			MainModule._AntiBreakLast = now
			pcall(fn6)
		end)
	end

	if fn4 then
		fn4()
	end

	return true
end

MainModule.FreezeRopeEnabled = false
MainModule.FreezeRopeConnection = nil

MainModule.toggle_freeze_rope = function(freezeRopeEnabled)
	MainModule.FreezeRopeEnabled = freezeRopeEnabled
	local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")

	if not rope then
		if MainModule.ToggleRefs.FreezeRope then
			pcall(function()
				MainModule.ToggleRefs.FreezeRope:SetValue(false)
			end)
		end

		return
	end

	if freezeRopeEnabled then
		for _, descendant in ipairs(rope:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.Velocity = Vector3.zero
				descendant.RotVelocity = Vector3.zero
			elseif descendant:IsA("Constraint") or descendant:IsA("RopeConstraint") or descendant:IsA("Motor6D") then
				descendant.Enabled = false
			end
		end
	else
		for _, descendant in ipairs(rope:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Anchored = false
			elseif descendant:IsA("Constraint") or descendant:IsA("RopeConstraint") or descendant:IsA("Motor6D") then
				descendant.Enabled = true
			end
		end
	end

	fn4()
end

MainModule.remove_balance_mini_game = function()
	local playingJumpRope = localPlayer2:FindFirstChild("PlayingJumpRope")

	if playingJumpRope then
		pcall(function()
			playingJumpRope:Destroy()
		end)

		fn4()
	else
		MainModule.notify("Jump Rope", "PlayingJumpRope not found", 0.9)
		fn5()
	end
end

MainModule.JumpRopeAntiHit = {
	Enabled = false,
	Connection = nil,
	AnimationId = "rbxassetid://105677261748140",
	AnimationDuration = 0.4,
	CurrentAnimation = nil,
	StopTimer = nil,
	WasJumping = false,
	RopeDestroyed = false,
}

MainModule.JumpRopeFakeBalance = {
	Enabled = false,
	Connection = nil,
	AnimationId = "rbxassetid://105677261748140",
	AnimationDuration = 0.4,
	CurrentAnimation = nil,
	StopTimer = nil,
	WasJumping = false,
}

MainModule.play_land_animation_fake_balance = function()
	if not MainModule.JumpRopeFakeBalance.Enabled then
		return
	end
	local v2 = MainModule.get_character()
	if not v2 then
		return
	end
	local v3 = MainModule.get_humanoid(v2)
	if not v3 then
		return
	end

	if MainModule.JumpRopeFakeBalance.CurrentAnimation then
		pcall(function()
			MainModule.JumpRopeFakeBalance.CurrentAnimation:Stop()
		end)
	end

	if MainModule.JumpRopeFakeBalance.StopTimer then
		MainModule.JumpRopeFakeBalance.StopTimer:Disconnect()
		MainModule.JumpRopeFakeBalance.StopTimer = nil
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = MainModule.JumpRopeFakeBalance.AnimationId
	MainModule.JumpRopeFakeBalance.CurrentAnimation = v3:LoadAnimation(animation)

	pcall(function()
		MainModule.JumpRopeFakeBalance.CurrentAnimation:Play()
	end)

	MainModule.JumpRopeFakeBalance.StopTimer = game:GetService("RunService").Stepped:Connect(function()
		task.wait(MainModule.JumpRopeFakeBalance.AnimationDuration)

		if MainModule.JumpRopeFakeBalance.CurrentAnimation then
			pcall(function()
				MainModule.JumpRopeFakeBalance.CurrentAnimation:Stop()
			end)

			MainModule.JumpRopeFakeBalance.CurrentAnimation = nil
		end

		if MainModule.JumpRopeFakeBalance.StopTimer then
			MainModule.JumpRopeFakeBalance.StopTimer:Disconnect()
			MainModule.JumpRopeFakeBalance.StopTimer = nil
		end
	end)
end

MainModule.setup_jump_rope_fake_balance = function()
	local v2 = MainModule.get_character()
	if not v2 then
		return
	end
	local v3 = MainModule.get_humanoid(v2)
	if not v3 then
		return
	end
	MainModule.JumpRopeFakeBalance.WasJumping = false

	v3.StateChanged:Connect(function(old, new)
		if not MainModule.JumpRopeFakeBalance.Enabled then
			return
		end

		if new == Enum.HumanoidStateType.Jumping then
			MainModule.JumpRopeFakeBalance.WasJumping = true
		end

		if MainModule.JumpRopeFakeBalance.WasJumping and (new == Enum.HumanoidStateType.Running or new == Enum.HumanoidStateType.Landed or new == Enum.HumanoidStateType.GettingUp) then
			MainModule.play_land_animation_fake_balance()
			MainModule.JumpRopeFakeBalance.WasJumping = false
		end
	end)
end

MainModule.toggle_jump_rope_fake_balance = function(enabled)
	local jumpRopeFakeBalance = MainModule.ToggleRefs.JumpRopeFakeBalance

	if enabled then
		if not MainModule.can_enable_toggle("JumpRope", "Fake Balance", jumpRopeFakeBalance) then
			return false
		end
	end

	if MainModule.JumpRopeFakeBalance.Connection then
		MainModule.JumpRopeFakeBalance.Connection:Disconnect()
		MainModule.JumpRopeFakeBalance.Connection = nil
	end

	if MainModule.JumpRopeFakeBalance.CurrentAnimation then
		pcall(function()
			MainModule.JumpRopeFakeBalance.CurrentAnimation:Stop()
		end)

		MainModule.JumpRopeFakeBalance.CurrentAnimation = nil
	end

	if MainModule.JumpRopeFakeBalance.StopTimer then
		MainModule.JumpRopeFakeBalance.StopTimer:Disconnect()
		MainModule.JumpRopeFakeBalance.StopTimer = nil
	end

	MainModule.JumpRopeFakeBalance.Enabled = enabled

	if enabled then
		MainModule.setup_jump_rope_fake_balance()

		MainModule.JumpRopeFakeBalance.Connection = RunService2.Heartbeat:Connect(function()
			if not MainModule.JumpRopeFakeBalance.Enabled then
				return
			end

			if not MainModule.is_game_active("JumpRope") then
				if MainModule.ToggleRefs.JumpRopeFakeBalance then
					pcall(function()
						MainModule.ToggleRefs.JumpRopeFakeBalance:SetValue(false)
					end)
				end

				MainModule.toggle_jump_rope_fake_balance(false)
				return
			end
		end)
	end

	fn4()
	return true
end

MainModule.disable_rope_objects = function(arg)
	if not arg then
		return
	end

	pcall(function()
		if arg:IsA("MeshPart") or arg:IsA("Part") or arg:IsA("BasePart") then
			arg.CanCollide = false
			arg.CanTouch = false
			arg.CanQuery = false
			arg.Massless = true

			if arg.TouchTransmitter then
				arg.TouchTransmitter:Destroy()
			end
		end

		if arg:IsA("Script") or arg:IsA("LocalScript") or arg:IsA("ModuleScript") then
			local str = arg.Name:lower()

			if str:find("rope") or str:find("jump") or str:find("carry") or str:find("damage") or str:find("hurt") then
				arg.Disabled = true
			end
		end

		if arg:IsA("RopeConstraint") then
			arg:Destroy()
		end

		local name = arg.Name or ""

		if name == "PlayingJumpRope" or name == "RopeCarryPrompt" then
			arg:Destroy()
		end
	end)
end

MainModule.search_and_destroy_rope = function(arg)
	if not arg then
		return
	end

	for _, descendant in pairs(arg:GetDescendants()) do
		if descendant.Name and descendant.Name:lower():find("rope") then
			MainModule.disable_rope_objects(descendant)
		end

		if descendant:IsA("RopeConstraint") then
			MainModule.disable_rope_objects(descendant)
		end

		if descendant.Name == "PlayingJumpRope" or descendant.Name == "RopeCarryPrompt" then
			MainModule.disable_rope_objects(descendant)
		end
	end
end

MainModule.destroy_all_ropes = function()
	MainModule.search_and_destroy_rope(workspace)

	pcall(function()
		MainModule.search_and_destroy_rope(game:GetService("ReplicatedStorage"))
	end)

	pcall(function()
	end)

	pcall(function()
	end)

	pcall(function()
		for _, player in pairs(Players2:GetPlayers()) do
			if player.Character then
				MainModule.search_and_destroy_rope(player.Character)
			end

			if player.PlayerGui then
				MainModule.search_and_destroy_rope(player.PlayerGui)
			end
		end
	end)

	MainModule.JumpRopeAntiHit.RopeDestroyed = true
end

MainModule.disable_damage_scripts = function()
	pcall(function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

		for _, descendant in pairs(ReplicatedStorage2:GetDescendants()) do
			if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
				local str = descendant.Name:lower()

				if str:find("rope") or str:find("jump") or str:find("carry") or str:find("damage") or str:find("hurt") then
					descendant.Disabled = true
				end
			end
		end
	end)

	pcall(function()
		local ServerStorage = game:GetService("ServerStorage")

		for _, descendant in pairs(ServerStorage:GetDescendants()) do
			if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
				local str = descendant.Name:lower()

				if str:find("rope") or str:find("jump") or str:find("carry") or str:find("damage") or str:find("hurt") then
					descendant.Disabled = true
				end
			end
		end
	end)

	pcall(function()
		local ServerScriptService = game:GetService("ServerScriptService")

		for _, descendant in pairs(ServerScriptService:GetDescendants()) do
			if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
				local str = descendant.Name:lower()

				if str:find("rope") or str:find("jump") or str:find("carry") or str:find("damage") or str:find("hurt") then
					descendant.Disabled = true
				end
			end
		end
	end)
end

MainModule.toggle_jump_rope_anti_hit = function(enabled)
	local jumpRopeAntiHit = MainModule.ToggleRefs.JumpRopeAntiHit

	if enabled then
		if not MainModule.can_enable_toggle("JumpRope", "AntiHit", jumpRopeAntiHit) then
			return false
		end
	end

	if MainModule.JumpRopeAntiHit.Connection then
		MainModule.JumpRopeAntiHit.Connection:Disconnect()
		MainModule.JumpRopeAntiHit.Connection = nil
	end

	MainModule.JumpRopeAntiHit.Enabled = enabled
	MainModule.JumpRopeAntiHit.RopeDestroyed = false

	if enabled then
		MainModule.disable_damage_scripts()
		MainModule.destroy_all_ropes()

		MainModule.JumpRopeAntiHit.Connection = RunService2.Heartbeat:Connect(function()
			if not MainModule.JumpRopeAntiHit.Enabled then
				return
			end

			if not MainModule.is_game_active("JumpRope") then
				if MainModule.ToggleRefs.JumpRopeAntiHit then
					pcall(function()
						MainModule.ToggleRefs.JumpRopeAntiHit:SetValue(false)
					end)
				end

				MainModule.toggle_jump_rope_anti_hit(false)
				return
			end

			if not MainModule.JumpRopeAntiHit.RopeDestroyed then
				MainModule.destroy_all_ropes()
			end
		end)
	end

	fn4()
	return true
end

MainModule.ToggleRefs.JumpRopeAntiHit = nil
MainModule.ToggleRefs.JumpRopeFakeBalance = nil

MainModule.ZoneKillFeature = {
	Enabled = false,
	AnimationId = "rbxassetid://105341857343164",
	ZonePosition = Vector3.new(197.7, 54.6, -96.3),
	ReturnDelay = 0.6,
	SavedCFrame = nil,
	ActiveAnimation = false,
	AnimationStartTime = 0,
	AnimationConnection = nil,
	CharacterAddedConnection = nil,
	AnimationStoppedConnections = {},
	AnimationCheckConnection = nil,
	TrackedAnimations = {},
}

MainModule.toggle_zone_kill = function(enabled)
	if enabled then
		if MainModule.is_game_active and not MainModule.is_game_active("LastDinner") then
			MainModule.notify("Zone Kill", "Wait for LastDinner!", 0.9)
			fn5()
			return
		end
	end

	local zoneKill = MainModule.ToggleRefs.ZoneKill

	if enabled then
		if not MainModule.can_enable_toggle("LastDinner", "Zone Kill", zoneKill) then
			return false
		end
	end

	MainModule.ZoneKillFeature.Enabled = enabled

	if MainModule.ZoneKillFeature.AnimationConnection then
		MainModule.ZoneKillFeature.AnimationConnection:Disconnect()
		MainModule.ZoneKillFeature.AnimationConnection = nil
	end

	if MainModule.ZoneKillFeature.CharacterAddedConnection then
		MainModule.ZoneKillFeature.CharacterAddedConnection:Disconnect()
		MainModule.ZoneKillFeature.CharacterAddedConnection = nil
	end

	if MainModule.ZoneKillFeature.AnimationCheckConnection then
		MainModule.ZoneKillFeature.AnimationCheckConnection:Disconnect()
		MainModule.ZoneKillFeature.AnimationCheckConnection = nil
	end

	for _, animationStoppedConnection in ipairs(MainModule.ZoneKillFeature.AnimationStoppedConnections) do
		pcall(function()
			animationStoppedConnection:Disconnect()
		end)
	end

	MainModule.ZoneKillFeature.AnimationStoppedConnections = {}
	MainModule.ZoneKillFeature.SavedCFrame = nil
	MainModule.ZoneKillFeature.ActiveAnimation = false
	MainModule.ZoneKillFeature.AnimationStartTime = 0
	MainModule.ZoneKillFeature.TrackedAnimations = {}
	if not enabled then
		fn4()
		return true
	end

	local function fn6()
		if not MainModule.ZoneKillFeature.Enabled then
			return
		end
		local v2 = MainModule.get_character()
		if not v2 then
			return
		end
		local v3 = MainModule.get_humanoid(v2)
		if not v3 then
			return
		end
		local playingAnimationTracks = v3:GetPlayingAnimationTracks()

		for _, playingAnimationTrack in pairs(playingAnimationTracks) do
			if playingAnimationTrack and playingAnimationTrack.Animation then
				local animationId = playingAnimationTrack.Animation.AnimationId

				if animationId and animationId == MainModule.ZoneKillFeature.AnimationId then
					local str = animationId .. "_" .. tostring(playingAnimationTrack)

					if not MainModule.ZoneKillFeature.TrackedAnimations[str] then
						MainModule.ZoneKillFeature.TrackedAnimations[str] = true

						if not MainModule.ZoneKillFeature.ActiveAnimation then
							MainModule.ZoneKillFeature.ActiveAnimation = true
							MainModule.ZoneKillFeature.AnimationStartTime = tick()
							MainModule.ZoneKillFeature.SavedCFrame = v2:GetPrimaryPartCFrame()
							v2:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))

							local connection = playingAnimationTrack.Stopped:Connect(function()
								task.wait(MainModule.ZoneKillFeature.ReturnDelay)

								if MainModule.ZoneKillFeature.SavedCFrame then
									v2:SetPrimaryPartCFrame(MainModule.ZoneKillFeature.SavedCFrame)
									MainModule.ZoneKillFeature.SavedCFrame = nil
									MainModule.ZoneKillFeature.ActiveAnimation = false
									MainModule.ZoneKillFeature.TrackedAnimations = {}
								end
							end)

							table.insert(MainModule.ZoneKillFeature.AnimationStoppedConnections, connection)
						end
					end
				end
			end
		end
	end

	local function fn7(arg)
		local humanoid = arg:WaitForChild("Humanoid", 5)
		if not humanoid then
			return
		end

		MainModule.ZoneKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(arg2)
			if not MainModule.ZoneKillFeature.Enabled then
				return
			end

			if arg2 and arg2.Animation then
				local animationId = arg2.Animation.AnimationId

				if animationId and animationId == MainModule.ZoneKillFeature.AnimationId then
					MainModule.ZoneKillFeature.TrackedAnimations[animationId .. "_" .. tostring(arg2)] = true

					if not MainModule.ZoneKillFeature.ActiveAnimation then
						MainModule.ZoneKillFeature.ActiveAnimation = true
						MainModule.ZoneKillFeature.AnimationStartTime = tick()
						MainModule.ZoneKillFeature.SavedCFrame = arg:GetPrimaryPartCFrame()
						arg:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))

						local connection = arg2.Stopped:Connect(function()
							task.wait(MainModule.ZoneKillFeature.ReturnDelay)

							if MainModule.ZoneKillFeature.SavedCFrame then
								arg:SetPrimaryPartCFrame(MainModule.ZoneKillFeature.SavedCFrame)
								MainModule.ZoneKillFeature.SavedCFrame = nil
							end

							MainModule.ZoneKillFeature.ActiveAnimation = false
							MainModule.ZoneKillFeature.TrackedAnimations = {}
						end)

						table.insert(MainModule.ZoneKillFeature.AnimationStoppedConnections, connection)
					end
				end
			end
		end)
	end

	local character = localPlayer2.Character

	if character then
		fn7(character)
	end

	MainModule.ZoneKillFeature.CharacterAddedConnection = localPlayer2.CharacterAdded:Connect(function(character2)
		task.wait(1)
		fn7(character2)
	end)

	MainModule.ZoneKillFeature.AnimationCheckConnection = RunService2.Heartbeat:Connect(function()
		if not MainModule.ZoneKillFeature.Enabled then
			return
		end
		fn6()
	end)

	fn4()
	return true
end

MainModule.VoidKillEnabled = false
MainModule.VoidKillConn = nil
MainModule.VoidKillCharConn = nil
MainModule.VoidAnimIds = { "rbxassetid://107989020363293", "rbxassetid://71619354165195" }
MainModule.VoidZonePos = Vector3.new(-95.1, 964.6, 67.6)

MainModule.toggle_void_kill = function(voidKillEnabled)
	if voidKillEnabled then
		if MainModule.is_game_active and not MainModule.is_game_active("SkySquidGame") then
			MainModule.notify("Void Kill", "Wait for SkySquidGame!", 0.9)
			fn5()
			return
		end
	end

	local voidKill = MainModule.ToggleRefs.VoidKill

	if voidKillEnabled then
		if not MainModule.can_enable_toggle("SkySquidGame", "Void Kill", voidKill) then
			return false
		end
	end

	if MainModule.VoidKillConn then
		MainModule.VoidKillConn:Disconnect()
	end

	if MainModule.VoidKillCharConn then
		MainModule.VoidKillCharConn:Disconnect()
	end

	MainModule.VoidKillEnabled = voidKillEnabled

	if voidKillEnabled then
		local function fn6(arg)
			MainModule.VoidKillConn = arg:WaitForChild("Humanoid").AnimationPlayed:Connect(function(arg2)
				if arg2.Animation and table.find(MainModule.VoidAnimIds, arg2.Animation.AnimationId) then
					local primaryPartCFrame = arg:GetPrimaryPartCFrame()
					local part = Instance.new("Part")
					part.Name = HttpService:GenerateGUID(false)
					part.Size = Vector3.new(10, 1, 10)
					part.Position = MainModule.VoidZonePos + Vector3.new(0, -4, 0)
					part.Anchored = true
					part.CanCollide = true
					part.Transparency = 1
					part.Parent = workspace
					arg:SetPrimaryPartCFrame(CFrame.new(MainModule.VoidZonePos.X, MainModule.VoidZonePos.Y, MainModule.VoidZonePos.Z))

					arg2.Stopped:Connect(function()
						task.wait(1)

						if primaryPartCFrame then
							arg:SetPrimaryPartCFrame(primaryPartCFrame)
						end

						part:Destroy()
					end)
				end
			end)
		end

		if localPlayer2.Character then
			fn6(localPlayer2.Character)
		end

		MainModule.VoidKillCharConn = localPlayer2.CharacterAdded:Connect(function(character)
			task.wait(1)
			fn6(character)
		end)
	end

	fn4()
	return true
end

MainModule.MingleVoidKillEnabled = false
MainModule.MingleConns = {}
MainModule.MingleAnimId = "rbxassetid://71318091779666"

MainModule.toggle_mingle_void_kill = function(mingleVoidKillEnabled)
	if mingleVoidKillEnabled then
		local flag = false

		pcall(function()
			local backpack = localPlayer2.Backpack
			local character = localPlayer2.Character

			if backpack and backpack:FindFirstChild("Power Hold") then
				flag = true
			end

			if character and character:FindFirstChild("Power Hold") then
				flag = true
			end

			local v2 = ipairs
			backpack = backpack and backpack:GetChildren() or {}

			for _, v3 in v2(backpack) do
				if v3:IsA("Tool") and string.lower(v3.Name):find("power hold") then
					flag = true
				end
			end

			if character then
				for _, child in ipairs(character:GetChildren()) do
					if child:IsA("Tool") and string.lower(child.Name):find("power hold") then
						flag = true
					end
				end
			end
		end)

		if not flag then
			flag = pcall

			flag(function()
				fn2("You need a power hold tool to enable this", "", 1.2)
			end)

			flag = fn4

			if flag then
				flag = fn4
				flag()
			end

			return false
		end
	end

	if mingleVoidKillEnabled then
		if MainModule.is_game_active and not MainModule.is_game_active("Mingle") then
			MainModule.notify("Mingle Void Kill", "Wait for Mingle!", 0.9)
			fn5()
			return
		end
	end

	local mingleVoidKill = MainModule.ToggleRefs.MingleVoidKill

	if mingleVoidKillEnabled then
		if not MainModule.can_enable_toggle("Mingle", "Void Kill", mingleVoidKill) then
			return false
		end
	end

	for _, mingleConn in pairs(MainModule.MingleConns) do
		pcall(function()
			mingleConn:Disconnect()
		end)
	end

	MainModule.MingleConns = {}
	MainModule.MingleVoidKillEnabled = mingleVoidKillEnabled

	if mingleVoidKillEnabled then
		local part = nil

		local function fn6(arg)
			local humanoid = arg:FindFirstChildOfClass("Humanoid") or arg:WaitForChild("Humanoid", 5)
			if not humanoid then
				return
			end

			local connection = humanoid.AnimationPlayed:Connect(function(arg2)
				if not MainModule.MingleVoidKillEnabled then
					return
				end

				if not arg2.Animation then
					return
				end

				if arg2.Animation.AnimationId ~= MainModule.MingleAnimId then
					return
				end
				local humanoidRootPart = arg:FindFirstChild("HumanoidRootPart")
				if not humanoidRootPart then
					return
				end
				local cFrame = humanoidRootPart.CFrame

				if part then
					pcall(function()
						part:Destroy()
					end)

					part = nil
				end

				part = Instance.new("Part")
				part.Name = HttpService:GenerateGUID(false)
				part.Size = Vector3.new(40, 2, 40)
				part.Position = Vector3.new(196.83342, 55.9548, -90.47459) + Vector3.new(0, -3, 0)
				part.Anchored = true
				part.CanCollide = true
				part.Transparency = 1
				part.Parent = workspace
				humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart.CFrame = CFrame.new(Vector3.new(196.83342, 55.9548, -90.47459))

				if arg.PrimaryPart then
					pcall(function()
						arg:SetPrimaryPartCFrame(CFrame.new(Vector3.new(196.83342, 55.9548, -90.47459)))
					end)
				end

				local connection = nil

				connection = arg2.Stopped:Connect(function()
					task.wait(0.6)

					if arg and arg.Parent and MainModule.MingleVoidKillEnabled then
						local humanoidRootPart2 = arg:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart2 then
							humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
							humanoidRootPart2.CFrame = cFrame

							if arg.PrimaryPart then
								pcall(function()
									arg:SetPrimaryPartCFrame(cFrame)
								end)
							end
						end
					end

					if part then
						pcall(function()
							part:Destroy()
						end)

						part = nil
					end

					if connection then
						connection:Disconnect()
					end
				end)
			end)

			table.insert(MainModule.MingleConns, connection)
		end

		if localPlayer2.Character then
			fn6(localPlayer2.Character)
		end

		table.insert(MainModule.MingleConns, localPlayer2.CharacterAdded:Connect(function(character)
			task.wait(0.5)
			fn6(character)
		end))
	end

	fn4()
	return true
end

MainModule.AutoChokeEnabled = false
MainModule.AutoChokeConnection = nil

MainModule.toggle_auto_choke = function(autoChokeEnabled)
	if autoChokeEnabled then
		if MainModule.is_game_active and not MainModule.is_game_active("Mingle") then
			MainModule.notify("Auto Choke", "Wait for Mingle!", 0.9)
			fn5()
			return
		end
	end

	local autoChoke = MainModule.ToggleRefs.AutoChoke

	if autoChokeEnabled then
		if not MainModule.can_enable_toggle("Mingle", "Auto Choke", autoChoke) then
			return false
		end
	end

	MainModule.AutoChokeEnabled = autoChokeEnabled

	if autoChokeEnabled then
		local impactFrames = localPlayer2.PlayerGui:FindFirstChild("ImpactFrames")

		if impactFrames then
			local tbl = {}

			impactFrames.ChildAdded:Connect(function(child)
				if child.Name ~= "OuterRingTemplate" or tbl[child] then
					return
				end
				tbl[child] = true

				task.defer(function()
					local v2 = nil

					for _, child2 in pairs(impactFrames:GetChildren()) do
						if child2.Name == "InnerTemplate" and child2.Position == child.Position and not child2:GetAttribute("Failed") then
							v2 = child2
							break
						end
					end

					if not v2 or v2:GetAttribute("Tweening") or v2:GetAttribute("Failed") then
						return
					end
					local HBGQTE = require(ReplicatedStorage.Modules.HBGQTE)

					pcall(function()
						HBGQTE.Pressed(false, { Inner = v2, Outer = child, Duration = 2, StartedAt = tick(), Data = {} })
					end)
				end)
			end)
		end
	end

	fn4()
	return true
end

MainModule.SkySquidAntiFall = { Enabled = false, Platform = nil, Conn = nil }

MainModule.toggle_sky_squid_anti_fall = function(enabled)
	if MainModule.SkySquidAntiFall.Conn then
		MainModule.SkySquidAntiFall.Conn:Disconnect()
	end

	if MainModule.SkySquidAntiFall.Platform then
		MainModule.SkySquidAntiFall.Platform:Destroy()
	end

	MainModule.SkySquidAntiFall.Enabled = enabled

	if enabled then
		local function createPart()
			local v2 = MainModule.get_character()
			if not v2 then
				return nil
			end
			local v3 = MainModule.get_root_part(v2)
			if not v3 then
				return nil
			end
			local part = Instance.new("Part")
			part.Name = HttpService:GenerateGUID(false)
			part.Size = Vector3.new(10000, 1, 10000)
			part.Position = Vector3.new(v3.Position.X, v3.Position.Y - 5, v3.Position.Z)
			part.Anchored = true
			part.CanCollide = true
			part.Transparency = 0.5
			part.Parent = workspace
			return part
		end

		MainModule.SkySquidAntiFall.Platform = createPart()

		MainModule.SkySquidAntiFall.Conn = RunService2.Heartbeat:Connect(function()
			if not MainModule.SkySquidAntiFall.Enabled then
				return
			end

			if not (MainModule.SkySquidAntiFall.Platform and MainModule.SkySquidAntiFall.Platform.Parent) then
				MainModule.SkySquidAntiFall.Platform = createPart()
			end
		end)
	end

	fn4()
	return true
end

MainModule.FullbrightEnabled = false
MainModule.FullbrightSettings = {}
MainModule.FullbrightConnection = nil

MainModule.toggle_fullbright = function(fullbrightEnabled)
	MainModule.FullbrightEnabled = fullbrightEnabled
	local Lighting = game:GetService("Lighting")

	if fullbrightEnabled then
		MainModule.FullbrightSettings.Brightness = Lighting.Brightness
		MainModule.FullbrightSettings.ClockTime = Lighting.ClockTime
		MainModule.FullbrightSettings.FogEnd = Lighting.FogEnd
		MainModule.FullbrightSettings.GlobalShadows = Lighting.GlobalShadows
		MainModule.FullbrightSettings.OutdoorAmbient = Lighting.OutdoorAmbient
		MainModule.FullbrightSettings.Ambient = Lighting.Ambient
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)

		if MainModule.FullbrightConnection then
			MainModule.FullbrightConnection:Disconnect()
		end

		MainModule.FullbrightConnection = Lighting.Changed:Connect(function()
			if not MainModule.FullbrightEnabled then
				return
			end
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.FogEnd = 100000
			Lighting.GlobalShadows = false
			Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
			Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		end)
	else
		for k, fullbrightSetting in pairs(MainModule.FullbrightSettings) do
			pcall(function()
				Lighting[k] = fullbrightSetting
			end)
		end

		if MainModule.FullbrightConnection then
			MainModule.FullbrightConnection:Disconnect()
			MainModule.FullbrightConnection = nil
		end
	end

	fn4()
end

MainModule.AutoCollectBandage = false
MainModule.AutoCollectBandageConnection = nil

MainModule.has_tool = function(arg)
	local v2 = MainModule.get_character()

	if v2 then
		for _, child in pairs(v2:GetChildren()) do
			if child:IsA("Tool") and child.Name == arg then
				return true
			end
		end
	end

	local backpack = localPlayer2:FindFirstChild("Backpack")

	if backpack then
		for _, child in pairs(backpack:GetChildren()) do
			if child:IsA("Tool") and child.Name == arg then
				return true
			end
		end
	end

	return false
end

MainModule.start_auto_collect_bandage = function()
	if MainModule.AutoCollectBandageConnection then
		MainModule.AutoCollectBandageConnection:Disconnect()
		MainModule.AutoCollectBandageConnection = nil
	end

	MainModule.AutoCollectBandageConnection = RunService2.Heartbeat:Connect(function()
		if not MainModule.AutoCollectBandage then
			return
		end

		if not MainModule.has_tool("Bandage") and localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart") then
			local effects = workspace:FindFirstChild("Effects")

			if effects then
				for _, child in pairs(effects:GetChildren()) do
					if child.Name == "DroppedBandage" and child:FindFirstChild("Handle") then
						local cFrame = localPlayer2.Character.HumanoidRootPart.CFrame
						localPlayer2.Character.HumanoidRootPart.CFrame = child.Handle.CFrame
						task.wait(0.3)

						if localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart") then
							localPlayer2.Character.HumanoidRootPart.CFrame = cFrame
						end

						break
					end
				end
			end
		end
	end)
end

MainModule.toggle_auto_collect_bandage = function(autoCollectBandage)
	MainModule.AutoCollectBandage = autoCollectBandage

	if autoCollectBandage then
		MainModule.start_auto_collect_bandage()
	elseif MainModule.AutoCollectBandageConnection then
		MainModule.AutoCollectBandageConnection:Disconnect()
		MainModule.AutoCollectBandageConnection = nil
	end

	fn4()
end

MainModule.RLGLEndCorner = MainModule.RLGLEndCorner or "Left Corner"

MainModule.RLGLEndPositions = {
	["Left Corner"] = Vector3.new(110, 1023, 133),
	["Right Corner"] = Vector3.new(-214.4, 1023.1, 146.7),
}

MainModule.rlgl_tp_end = function()
	if MainModule.is_game_active("RedLightGreenLight") then
		local rlglEndCorner = MainModule.RLGLEndCorner or "Left Corner"
		MainModule.safe_teleport(MainModule.RLGLEndPositions and MainModule.RLGLEndPositions[rlglEndCorner] or Vector3.new(110, 1023, 133))
		MainModule.notify("RLGL", "Teleported to " .. tostring(rlglEndCorner), 0.9)
	else
		MainModule.notify("RLGL", "Wait for RedLightGreenLight!", 0.9)
		fn5()
	end
end

MainModule.GodModeEnabled = false
MainModule.GodModeConn = nil
MainModule.GodModeOrigY = nil

MainModule.toggle_god_mode = function(arg)
	if arg then
		if MainModule.is_game_active and not MainModule.is_game_active("RedLightGreenLight") then
			MainModule.notify("God Mode", "Wait for RedLightGreenLight!", 0.9)
			fn5()
			return
		end
	end

	local godMode = MainModule.ToggleRefs.GodMode

	if arg then
		if not MainModule.can_enable_toggle("RedLightGreenLight", "God Mode", godMode) then
			return false
		end
	end

	if arg then
		if MainModule.GodModeConn then
			MainModule.GodModeConn:Disconnect()
			MainModule.GodModeConn = nil
		end

		MainModule.GodModeEnabled = true
		local v2 = MainModule.get_character()

		if not v2 then
			MainModule.notify("GodMode", "Character not found", 0.9)
			fn5()
			MainModule.GodModeEnabled = false
			return false
		end

		local humanoidRootPart = v2:FindFirstChild("HumanoidRootPart") or v2.PrimaryPart

		if humanoidRootPart then
			MainModule.GodModeOrigY = humanoidRootPart.Position.Y
			MainModule.safe_teleport(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart.Position.Y + 170, humanoidRootPart.Position.Z))
		end

		MainModule.GodModeConn = RunService2.Heartbeat:Connect(function()
			if MainModule.GodModeEnabled and not MainModule.is_game_active("RedLightGreenLight") then
				MainModule.disable_toggle("GodMode")
			end
		end)
	else
		MainModule.GodModeEnabled = false

		if MainModule.GodModeConn then
			MainModule.GodModeConn:Disconnect()
			MainModule.GodModeConn = nil
		end

		if MainModule.GodModeOrigY then
			local v2 = MainModule.get_character()

			if v2 then
				local humanoidRootPart = v2:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					MainModule.safe_teleport(Vector3.new(humanoidRootPart.Position.X, MainModule.GodModeOrigY, humanoidRootPart.Position.Z))
				end
			end
		end

		MainModule.GodModeOrigY = nil
	end

	fn4()
	return true
end

MainModule.RageAutoQTEEnabled = false
MainModule.RageAutoQTELoop = nil

MainModule.toggle_rage_auto_qte = function(rageAutoQTEEnabled)
	local rageAutoQTE = MainModule.ToggleRefs.RageAutoQTE

	if rageAutoQTEEnabled then
		if MainModule.is_xeno_executor() then
			MainModule.notify("RAGE Auto QTE", "Not supported in your executor", 0.9)
			fn5()

			if rageAutoQTE and rageAutoQTE.SetValue then
				pcall(function()
					rageAutoQTE:SetValue(false)
				end)
			end

			return false
		end
	end

	MainModule.RageAutoQTEEnabled = rageAutoQTEEnabled

	if MainModule.RageAutoQTELoop then
		task.cancel(MainModule.RageAutoQTELoop)
		MainModule.RageAutoQTELoop = nil
	end

	if rageAutoQTEEnabled then
		MainModule.RageAutoQTELoop = task.spawn(function()
			local ok, result = pcall(function()
				return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("HBGQTE"))
			end)

			if ok then
				local v2 = result

				while MainModule.RageAutoQTEEnabled do
					task.wait(0.05)

					pcall(function()
						if v2 and v2.ActiveButtons then
							for _, activeButton in pairs(v2.ActiveButtons) do
								if activeButton and activeButton.Inner and activeButton.Outer and not activeButton.Inner:GetAttribute("Tweening") and not activeButton.Inner:GetAttribute("Failed") then
									pcall(function()
										v2.Pressed(false, activeButton)
									end)
								end
							end
						end
					end)
				end

				return
			end

			MainModule.notify("RAGE Auto QTE", "Failed to load QTE module", 0.9)
			fn5()
			MainModule.RageAutoQTEEnabled = false

			if rageAutoQTE and rageAutoQTE.SetValue then
				pcall(function()
					rageAutoQTE:SetValue(false)
				end)
			end
		end)

		fn4()
	else
		fn4()
	end

	return true
end

MainModule.RemoveInjuryEnabled = false
MainModule.RemoveInjuryConn = nil

local function fn6()
	local character = localPlayer2.Character
	if not character then
		return
	end

	for _, v2 in ipairs({ "Crawling", "InjuredWalking" }) do
		local v3 = character:FindFirstChild(v2)

		if v3 then
			pcall(function()
				v3:Destroy()
			end)
		end
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		pcall(function()
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			humanoid.JumpPower = math.max(humanoid.JumpPower or 0, 50)
		end)
	end
end

MainModule.remove_injury_objects = function()
	fn6()
end

MainModule.toggle_remove_injury = function(arg)
	MainModule.RemoveInjuryEnabled = arg and true or false

	if MainModule.RemoveInjuryConn then
		pcall(function()
			MainModule.RemoveInjuryConn:Disconnect()
		end)

		MainModule.RemoveInjuryConn = nil
	end

	if MainModule.RemoveInjuryEnabled then
		fn6()

		MainModule.RemoveInjuryConn = RunService2.Heartbeat:Connect(function()
			if not MainModule.RemoveInjuryEnabled then
				return
			end

			if not MainModule._injury_last then
				MainModule._injury_last = 0
			end

			local injuryLast = MainModule._injury_last
			if tick() - injuryLast < 1 then
				return
			end
			MainModule._injury_last = tick()
			fn6()
		end)
	end

	fn4()
end

MainModule = MainModule or {}

MainModule.FireHotbarTool = function(arg)
	local localPlayer3 = Players2.LocalPlayer
	if not localPlayer3 then
		return false
	end
	local backpack = localPlayer3:FindFirstChild("Backpack")
	if not backpack then
		return false
	end
	local character = backpack:FindFirstChild(arg)

	if not character then
		character = localPlayer3.Character
		character = character and character:FindFirstChild(arg)
	end

	if not character then
		return false
	end
	local hotbar = localPlayer3.PlayerGui:FindFirstChild("Hotbar")
	if not hotbar then
		return false
	end
	local backpack2 = hotbar:FindFirstChild("Backpack")
	backpack2 = backpack2 and backpack2:FindFirstChild("Hotbar")
	if not backpack2 then
		return false
	end
	local v2 = nil

	for _, child in pairs(backpack2:GetChildren()) do
		local toolName = child:FindFirstChild("ToolName")
		if toolName and toolName.Text == arg then
			v2 = child
			break
		end
	end

	if not v2 or not getconnections then
		return false
	end

	pcall(function()
		for _, v3 in pairs(getconnections(v2.MouseButton1Down)) do
			pcall(function()
				v3:Fire()
			end)
		end

		task.wait(0.05)

		for _, v3 in pairs(getconnections(v2.MouseButton1Up)) do
			pcall(function()
				v3:Fire()
			end)
		end
	end)

	return true
end

MainModule = MainModule or {}

MainModule.EnsureFakeUltraInstinct = function()
	if type(MainModule.FakeUltraInstinct) ~= "table" then
		MainModule.FakeUltraInstinct = {}
	end

	local fakeUltraInstinct = MainModule.FakeUltraInstinct

	if fakeUltraInstinct.MaxDodges == nil then
		fakeUltraInstinct.MaxDodges = 10
	end

	if fakeUltraInstinct.Dodges == nil then
		fakeUltraInstinct.Dodges = 10
	end

	if fakeUltraInstinct.Cooldown == nil then
		fakeUltraInstinct.Cooldown = false
	end

	if fakeUltraInstinct.Equipped == nil then
		fakeUltraInstinct.Equipped = false
	end

	if fakeUltraInstinct.AnimPlaying == nil then
		fakeUltraInstinct.AnimPlaying = false
	end

	if fakeUltraInstinct.Enabled == nil then
		fakeUltraInstinct.Enabled = false
	end

	if fakeUltraInstinct.SoundId == nil then
		fakeUltraInstinct.SoundId = "rbxassetid://6732929006"
	end

	if type(fakeUltraInstinct.DodgeLabels) ~= "table" then
		fakeUltraInstinct.DodgeLabels = {}
	end

	if type(fakeUltraInstinct.Connections) ~= "table" then
		fakeUltraInstinct.Connections = {}
	end

	if type(fakeUltraInstinct.FXMap) ~= "table" then
		fakeUltraInstinct.FXMap = { 1, 2, 1, 2, 1 }
	end

	return fakeUltraInstinct
end

MainModule.FUIGetPlayer = function()
	return game:GetService("Players").LocalPlayer
end

MainModule.FUIGetEffects = function()
	local v2 = MainModule.EnsureFakeUltraInstinct()
	if v2.UIDodgeEffects then
		return v2.UIDodgeEffects
	end

	local ok, uiDodgeEffects = pcall(function()
		local modules = game:GetService("ReplicatedStorage"):FindFirstChild("Modules")
		if not modules then
			return nil
		end
		local abilityEffectsModules = modules:FindFirstChild("AbilityEffectsModules")
		if not abilityEffectsModules then
			return nil
		end
		local uiDodgeCLIENTEFFECTS = abilityEffectsModules:FindFirstChild("UIDodgeCLIENTEFFECTS")
		if not uiDodgeCLIENTEFFECTS then
			return nil
		end
		return require(uiDodgeCLIENTEFFECTS)
	end)

	if ok and type(uiDodgeEffects) == "function" then
		v2.UIDodgeEffects = uiDodgeEffects
		return uiDodgeEffects
	end
	return nil
end

MainModule.FUIGetAnimFolder = function()
	local v2 = MainModule.EnsureFakeUltraInstinct()
	if v2.AnimFolder and v2.AnimFolder.Parent then
		return v2.AnimFolder
	end

	local ok, animFolder = pcall(function()
		local animations = game:GetService("ReplicatedStorage"):FindFirstChild("Animations")
		if not animations then
			return nil
		end
		local abilities = animations:FindFirstChild("Abilities")
		if not abilities then
			return nil
		end
		return abilities:FindFirstChild("UltraInstinct")
	end)

	if ok and animFolder then
		v2.AnimFolder = animFolder
		return animFolder
	end
	return nil
end

MainModule.FUIGetChar = function()
	local v2 = MainModule.FUIGetPlayer()
	if not v2 then
		return nil
	end
	return v2.Character
end

MainModule.FUIGetAnimator = function()
	local v2 = MainModule.FUIGetChar()
	if not v2 then
		return nil
	end
	local humanoid = v2:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil
	end
	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		local animator2 = Instance.new("Animator")
		animator2.Parent = humanoid
		animator = animator2
	end

	return animator
end

MainModule.FUIGetAnimations = function()
	local v2 = MainModule.FUIGetAnimFolder()
	if not v2 then
		return {}
	end
	local tbl = {}

	for _, child in ipairs(v2:GetChildren()) do
		if child:IsA("Animation") and child.AnimationId ~= "" then
			table.insert(tbl, child)
		end
	end

	return tbl
end

MainModule.FUIStageOf = function(arg)
	if not arg then
		return 1
	end
	return tonumber(tostring(arg.Name):match("%d+")) or 1
end

MainModule.FUIPlayAura = function()
	local v2 = MainModule.FUIGetEffects()
	if not v2 then
		return
	end
	local v3 = MainModule.FUIGetChar()
	if not v3 then
		return
	end

	pcall(function()
		v2({ ModuleName = "UIDodge", Character = v3, initial = true })
	end)
end

MainModule.FUIPlayDodgeFX = function(arg)
	local v2 = MainModule.FUIGetEffects()
	if not v2 then
		return
	end
	local v3 = MainModule.FUIGetChar()
	if not v3 then
		return
	end

	pcall(function()
		v2({ ModuleName = "UIDodge", Character = v3, dodgenumber = arg, initial = false })
	end)
end

MainModule.FUIPlaySound = function()
	local v2 = MainModule.EnsureFakeUltraInstinct()
	local v3 = MainModule.FUIGetChar()
	if not v3 then
		return
	end
	local humanoidRootPart = v3:FindFirstChild("HumanoidRootPart") or v3:FindFirstChild("Head")
	if not humanoidRootPart then
		return
	end
	local sound = Instance.new("Sound")
	sound.Name = "FakeUltraInstinctSound"
	sound.SoundId = v2.SoundId
	sound.Volume = 1.5
	sound.RollOffMaxDistance = 120
	sound.Parent = humanoidRootPart

	pcall(function()
		sound:Play()
	end)

	sound.Ended:Once(function()
		sound:Destroy()
	end)
end

MainModule.FUIFindLabels = function(arg)
	local tbl = {}
	if not arg then
		return tbl
	end

	for _, descendant in ipairs(arg:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			local str = tostring(descendant.Text)

			if str:find("%d+%s*/%s*%d+") or str:lower():find("dodge") then
				table.insert(tbl, descendant)
			end
		end
	end

	return tbl
end

MainModule.FUISetupPanel = function()
	local v2 = MainModule.EnsureFakeUltraInstinct()
	if v2.Panel and v2.Panel.Parent then
		return
	end
	local v3 = MainModule.FUIGetPlayer()
	if not v3 then
		return
	end
	local playerGui = v3:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end
	local powerUIDodges = playerGui:FindFirstChild("PowerUIDodges")
	if not powerUIDodges then
		return
	end
	v2.OriginalPanel = powerUIDodges

	pcall(function()
		if powerUIDodges:IsA("ScreenGui") then
			powerUIDodges.Enabled = false
		end
	end)

	local clone = powerUIDodges:Clone()
	clone.Name = "FakeUltraInstinctDodges"

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("LocalScript") or descendant:IsA("Script") then
			descendant:Destroy()
		end
	end

	local parent

	if type(gethui) == "function" then
		local ok
		ok, parent = pcall(gethui)

		if not (ok and parent) then
			parent = playerGui
		end
	else
		parent = playerGui
	end

	clone.Parent = parent

	if clone:IsA("ScreenGui") then
		clone.Enabled = true
		clone.ResetOnSpawn = false
	end

	v2.Panel = clone
	v2.DodgeLabels = MainModule.FUIFindLabels(clone)
	MainModule.FUIUpdatePanel()
end

MainModule.FUIUpdatePanel = function()
	local v2 = MainModule.EnsureFakeUltraInstinct()
	if not v2.Panel or not v2.Panel.Parent then
		return
	end
	local text = string.format("Dodges Left: %d/%d", v2.Dodges, v2.MaxDodges)

	for _, dodgeLabel in ipairs(v2.DodgeLabels) do
		if dodgeLabel and dodgeLabel.Parent then
			pcall(function()
				dodgeLabel.Text = text
			end)
		end
	end
end

MainModule.FUIConsumeDodge = function()
	local v2 = MainModule.EnsureFakeUltraInstinct()
	v2.Dodges = math.max(v2.Dodges - 1, 0)
	MainModule.FUIUpdatePanel()

	if v2.Dodges <= 0 then
		task.delay(0.35, function()
			local v3 = MainModule.EnsureFakeUltraInstinct()
			if not v3.Enabled then
				return
			end
			v3.Dodges = v3.MaxDodges
			MainModule.FUIUpdatePanel()
		end)
	end
end

MainModule.FUIStopAnim = function()
	local v2 = MainModule.EnsureFakeUltraInstinct()

	if v2.CurrentTrack then
		pcall(function()
			v2.CurrentTrack:Stop(0.1)
			v2.CurrentTrack:Destroy()
		end)
	end

	v2.CurrentTrack = nil
	v2.AnimPlaying = false
end

MainModule.FUIPlayAll = function(arg)
	local v2 = MainModule.EnsureFakeUltraInstinct()
	if not v2.Enabled then
		return
	end
	local v3 = MainModule.FUIGetAnimations()
	if #v3 == 0 then
		return
	end
	local v4

	if #v3 == 1 then
		v4 = v3[1]
	else
		local n = 0

		while true do
			v4 = v3[math.random(1, #v3)]
			n += 1
			if not (v4 ~= v2.LastAnim or n > 10) then
				continue
			end
			break
		end
	end

	v2.LastAnim = v4
	local n = v2.FXMap[MainModule.FUIStageOf(v4)] or math.random(1, 2)
	MainModule.FUIStopAnim()
	local v5 = MainModule.FUIGetAnimator()

	if v5 then
		local ok, currentTrack = pcall(function()
			return v5:LoadAnimation(v4)
		end)

		if ok and currentTrack then
			v2.AnimPlaying = true
			v2.CurrentTrack = currentTrack
			currentTrack.Priority = Enum.AnimationPriority.Action4
			currentTrack.Looped = false

			pcall(function()
				currentTrack:Play(0.05, 1, 1)
			end)

			currentTrack.Stopped:Once(function()
				local v6 = MainModule.EnsureFakeUltraInstinct()

				if v6.CurrentTrack == currentTrack then
					pcall(function()
						currentTrack:Destroy()
					end)

					v6.CurrentTrack = nil
					v6.AnimPlaying = false
				end
			end)
		end
	end

	task.spawn(MainModule.FUIPlayAura)

	task.spawn(function()
		MainModule.FUIPlayDodgeFX(n)
	end)

	task.spawn(MainModule.FUIPlaySound)

	if arg then
		MainModule.FUIConsumeDodge()
	end
end

MainModule.FUIDoDodge = function()
	local v2 = MainModule.EnsureFakeUltraInstinct()
	if not v2.Enabled then
		return
	end

	if v2.Cooldown then
		return
	end
	v2.Cooldown = true
	MainModule.FUIPlayAll(true)

	task.delay(0.35, function()
		MainModule.EnsureFakeUltraInstinct().Cooldown = false
	end)
end

MainModule.FUICreateTool = function()
	local v2 = MainModule.EnsureFakeUltraInstinct()
	if not v2.Enabled then
		return
	end

	if v2.Tool and v2.Tool.Parent then
		return
	end
	local v3 = MainModule.FUIGetPlayer()
	if not v3 then
		return
	end
	local backpack = v3:FindFirstChildOfClass("Backpack") or v3:WaitForChild("Backpack", 5)
	if not backpack then
		return
	end
	local ultraInstinct = backpack:FindFirstChild("Ultra Instinct")
	local ultraInstinct2

	if ultraInstinct then
		ultraInstinct2 = ultraInstinct
	else
		ultraInstinct2 = v3.Character and v3.Character:FindFirstChild("Ultra Instinct")
	end

	if ultraInstinct2 then
		pcall(function()
			ultraInstinct2:Destroy()
		end)
	end

	local tool = Instance.new("Tool")
	tool.Name = "Ultra Instinct"
	tool.RequiresHandle = false
	tool.CanBeDropped = false
	tool.ToolTip = "Ultra Instinct"
	tool.Parent = backpack
	v2.Tool = tool

	table.insert(v2.Connections, tool.Equipped:Connect(function()
		local v4 = MainModule.EnsureFakeUltraInstinct()
		if not v4.Enabled then
			return
		end
		v4.Equipped = true
		MainModule.FUISetupPanel()
		task.wait(0.1)
		MainModule.FUIDoDodge()
	end))

	table.insert(v2.Connections, tool.Unequipped:Connect(function()
		MainModule.EnsureFakeUltraInstinct().Equipped = false
		MainModule.FUIStopAnim()
	end))

	table.insert(v2.Connections, tool.Activated:Connect(function()
		task.wait(0.2)
		MainModule.FUIDoDodge()
	end))
end

MainModule.FUIDestroy = function()
	local v2 = MainModule.EnsureFakeUltraInstinct()
	v2.Enabled = false
	v2.Equipped = false
	v2.Cooldown = false
	MainModule.FUIStopAnim()

	for _, connection in ipairs(v2.Connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	table.clear(v2.Connections)

	if v2.Tool then
		pcall(function()
			v2.Tool:Destroy()
		end)

		v2.Tool = nil
	end

	if v2.Panel then
		pcall(function()
			v2.Panel:Destroy()
		end)

		v2.Panel = nil
	end

	if v2.OriginalPanel then
		pcall(function()
			if v2.OriginalPanel:IsA("ScreenGui") then
				v2.OriginalPanel.Enabled = true
			end
		end)

		v2.OriginalPanel = nil
	end

	v2.DodgeLabels = {}
	v2.Dodges = v2.MaxDodges
end

MainModule.toggle_fake_ultra_instinct = function(arg)
	local v2 = MainModule.EnsureFakeUltraInstinct()

	if arg == true then
		if v2.Enabled then
			return
		end
		v2.Enabled = true
		v2.Dodges = v2.MaxDodges
		MainModule.FUICreateTool()
	else
		MainModule.FUIDestroy()
	end

	fn4()
end

do
	local v2 = MainModule.EnsureFakeUltraInstinct()

	if v2.CharacterConnection then
		pcall(function()
			v2.CharacterConnection:Disconnect()
		end)
	end

	local v3 = MainModule.FUIGetPlayer()

	if v3 then
		v2.CharacterConnection = v3.CharacterAdded:Connect(function()
			task.wait(1)
			local v4 = MainModule.EnsureFakeUltraInstinct()
			v4.Equipped = false
			v4.Cooldown = false
			v4.AnimPlaying = false
			v4.Dodges = v4.MaxDodges
			v4.Tool = nil
			v4.Panel = nil
			v4.DodgeLabels = {}
			MainModule.FUIStopAnim()

			if v4.Enabled then
				MainModule.FUICreateTool()
			end
		end)
	end
end

MainModule.PhantomDashEnabled = false
MainModule.PhantomDashKeybind = Enum.KeyCode.Q
MainModule.PhantomDashDistance = 15
MainModule.PhantomDashDuration = 0.25
MainModule.UpgradeSprintEnabled = false
MainModule.UpgradeSprintConn = nil

MainModule.toggle_upgrade_faster_sprint = function(arg)
	local upgradeSprintEnabled = arg and true or false
	MainModule.UpgradeSprintEnabled = upgradeSprintEnabled

	if MainModule.UpgradeSprintConn then
		pcall(function()
			MainModule.UpgradeSprintConn:Disconnect()
		end)

		MainModule.UpgradeSprintConn = nil
	end

	if upgradeSprintEnabled then
		local boosts = localPlayer2:FindFirstChild("Boosts")
		boosts = boosts and boosts:FindFirstChild("Faster Sprint")

		if not boosts or not boosts.Value or tonumber(boosts.Value) < 5 then
			MainModule.notify("Faster Sprint", "You dont have faster sprint lvl 5 to upgrade", 0.9)

			if fn5 then
				fn5()
			end

			MainModule.UpgradeSprintEnabled = false
			return false
		end

		MainModule.UpgradeSprintConn = RunService2.Heartbeat:Connect(function()
			if not MainModule.UpgradeSprintEnabled then
				return
			end

			pcall(function()
				local boosts2 = localPlayer2:FindFirstChild("Boosts")
				local fasterSprint = boosts2 and boosts2:FindFirstChild("Faster Sprint")

				if fasterSprint and tonumber(fasterSprint.Value) == 5 then
					fasterSprint.Value = 6
				end
			end)
		end)
	end

	if fn4 then
		fn4()
	end

	return true
end

MainModule.PhantomDashCooldown = 0.7
MainModule.PhantomDashMaxCharges = 2
MainModule.PhantomDashCurrentCharges = 2
MainModule.PhantomDashIsMoving = false
MainModule.PhantomDashSoundId = "rbxassetid://94904871279766"
MainModule.PhantomDashBackwardSoundId = "rbxassetid://99068532205349"

MainModule.PhantomDashTextures = {
	"http://www.roblox.com/asset/?id=122158926856615",
	"http://www.roblox.com/asset/?id=14005913529",
	"http://www.roblox.com/asset/?id=17888919056",
	"http://www.roblox.com/asset/?id=14695179076",
	"http://www.roblox.com/asset/?id=15431126240",
	"http://www.roblox.com/asset/?id=14045123768",
}

MainModule.PhantomDashConnection = nil
MainModule.PhantomDashKeybindConnection = nil
MainModule.PhantomDashMobileGui = nil
MainModule.PhantomDashRechargeThread = nil

do
	local function fn7(parent)
		local tbl = {}

		for i, phantomDashTexture in ipairs(MainModule.PhantomDashTextures) do
			local particleEmitter = Instance.new("ParticleEmitter")
			particleEmitter.Name = "DashDiagonalCluster_" .. i
			particleEmitter.Texture = phantomDashTexture
			particleEmitter.Color = ColorSequence.new(Color3.new(0, 0, 0))
			particleEmitter.LightEmission = 0
			particleEmitter.LightInfluence = 0
			particleEmitter.Brightness = 1
			particleEmitter.LockedToPart = false
			particleEmitter.Orientation = Enum.ParticleOrientation.FacingCamera
			particleEmitter.Rotation = NumberRange.new(45, 45)
			particleEmitter.RotSpeed = NumberRange.new(0, 0)
			particleEmitter.Speed = NumberRange.new(1, 5)
			particleEmitter.SpreadAngle = Vector2.new(20, 20)
			particleEmitter.Lifetime = NumberRange.new(0.3, 0.6)
			particleEmitter.ZOffset = 1
			local numberSequence = NumberSequence.new
			local tbl2 = {}
			local v2 = NumberSequenceKeypoint.new(0, 3.5)
			local v3 = NumberSequenceKeypoint.new(0.5, 6)
			local new = NumberSequenceKeypoint.new
			tbl2[1] = v2
			tbl2[2] = v3

			do
				local values = table.pack(new(1, 0))
				table.move(values, 1, values.n, 3, tbl2)
			end

			particleEmitter.Size = numberSequence(tbl2)
			local numberSequence2 = NumberSequence.new
			local tbl3 = {}
			local v4 = NumberSequenceKeypoint.new(0, 0)
			local v5 = NumberSequenceKeypoint.new(0.6, 0.4)
			local new2 = NumberSequenceKeypoint.new
			tbl3[1] = v4
			tbl3[2] = v5

			do
				local values = table.pack(new2(1, 1))
				table.move(values, 1, values.n, 3, tbl3)
			end

			particleEmitter.Transparency = numberSequence2(tbl3)
			particleEmitter.Parent = parent
			table.insert(tbl, particleEmitter)
		end

		return tbl
	end

	local function fn8()
		if MainModule.PhantomDashRechargeThread then
			task.cancel(MainModule.PhantomDashRechargeThread)
		end

		MainModule.PhantomDashRechargeThread = task.spawn(function()
			while MainModule.PhantomDashCurrentCharges < MainModule.PhantomDashMaxCharges do
				task.wait(MainModule.PhantomDashCooldown)
				MainModule.PhantomDashCurrentCharges = math.min(MainModule.PhantomDashMaxCharges, MainModule.PhantomDashCurrentCharges + 1)
			end

			MainModule.PhantomDashRechargeThread = nil
		end)
	end

	local function fn9()
		if MainModule.PhantomDashIsMoving or MainModule.PhantomDashCurrentCharges <= 0 then
			return
		end
		local v2 = MainModule.get_character()
		if not v2 then
			return
		end
		local v3 = MainModule.get_root_part(v2)
		local v4 = MainModule.get_humanoid(v2)
		if not v3 or not v4 then
			return
		end
		MainModule.PhantomDashIsMoving = true
		local flag = MainModule.PhantomDashCurrentCharges == MainModule.PhantomDashMaxCharges
		MainModule.PhantomDashCurrentCharges = MainModule.PhantomDashCurrentCharges - 1

		if flag then
			fn8()
		end

		local moveDirection = v4.MoveDirection
		local lookVector = v3.CFrame.LookVector
		local soundId

		if moveDirection.Magnitude > 0 then
			if moveDirection:Dot(v3.CFrame.LookVector) < -0.2 or UserInputService:IsKeyDown(Enum.KeyCode.S) then
				lookVector = -v3.CFrame.LookVector
				soundId = true
			else
				lookVector = moveDirection.Unit
				soundId = false
			end
		else
			soundId = false

			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				lookVector = -v3.CFrame.LookVector
				soundId = true
			end
		end

		soundId = soundId and MainModule.PhantomDashBackwardSoundId or MainModule.PhantomDashSoundId
		local folder = workspace:FindFirstChild(v)

		if not folder then
			folder = Instance.new("Folder")
			folder.Name = v
			folder.Parent = workspace
		end

		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Volume = 1.5
		sound.Parent = folder
		sound:Play()

		task.delay(3, function()
			if sound then
				sound:Destroy()
			end
		end)

		local v5 = fn7(v3)

		for _, v6 in ipairs(v5) do
			v6.Rate = 110
			v6.Enabled = true
		end

		local phantomDashDistance = MainModule.PhantomDashDistance or 15
		local phantomDashDuration = MainModule.PhantomDashDuration or 0.25
		local position = v3.Position
		local unit = lookVector.Unit
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { v2, workspace.Effects, workspace.Live, workspace.CurrentCamera }
		raycastParams.IgnoreWater = true
		local hit = workspace:Raycast(position + Vector3.new(0, 1.5, 0), unit * phantomDashDistance, raycastParams)

		if hit then
			phantomDashDistance = math.max(0, (hit.Position - position).Magnitude - 2)
		end

		local cFrame = v3.CFrame
		local n = cFrame - cFrame.Position
		local n2 = CFrame.new(position + unit * phantomDashDistance) * n
		local now = os.clock()
		local connection = nil

		connection = RunService2.Heartbeat:Connect(function()
			if not v3 or not v3.Parent then
				if connection then
					connection:Disconnect()
				end

				MainModule.PhantomDashIsMoving = false
				return
			end

			local n3 = math.clamp((os.clock() - now) / phantomDashDuration, 0, 1)
			v3.CFrame = cFrame:Lerp(n2, n3 * n3 * (3 - 2 * n3))

			if n3 >= 1 then
				connection:Disconnect()

				for _, v6 in ipairs(v5) do
					v6.Enabled = false
					v6.Rate = 0

					task.delay(0.6, function()
						if v6 then
							v6:Destroy()
						end
					end)
				end

				MainModule.PhantomDashIsMoving = false
			end
		end)
	end

	local function fn10()
		if MainModule.PhantomDashMobileGui then
			pcall(function()
				MainModule.PhantomDashMobileGui:Destroy()
			end)

			MainModule.PhantomDashMobileGui = nil
		end

		local playerGui = localPlayer2:FindFirstChild("PlayerGui")
		if not playerGui then
			return
		end
		local mobileSupport = playerGui:FindFirstChild("MobileSupport")
		mobileSupport = mobileSupport and mobileSupport:FindFirstChild("RollButton")
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "HSX_PhantomMobile"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 999
		screenGui.Parent = playerGui
		local clone

		if mobileSupport then
			clone = mobileSupport:Clone()
			clone.Name = "RollButton"
			clone.Visible = true
			clone.Parent = screenGui

			pcall(function()
				local attribute = localPlayer2:GetAttribute("_MobileButtonPositions")

				if attribute then
					local data = nil

					pcall(function()
						data = game:GetService("HttpService"):JSONDecode(attribute)
					end)

					if type(data) == "table" and data.RollButton then
						clone.Position = UDim2.new(unpack(data.RollButton.Position))
						clone.Size = UDim2.new(unpack(data.RollButton.Size))
					end
				end
			end)
		else
			clone = Instance.new("ImageButton")
			clone.Name = "RollButton"
			clone.Size = UDim2.new(0, 70, 0, 70)
			clone.Position = UDim2.new(1, -90, 1, -180)
			clone.BackgroundTransparency = 1
			clone.Image = "rbxassetid://134652275791867"
			clone.ImageTransparency = 0.15
			clone.Parent = screenGui
			local textLabel = Instance.new("TextLabel")
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.Text = "DASH"
			textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel.TextStrokeTransparency = 0.4
			textLabel.Font = Enum.Font.GothamBold
			textLabel.TextScaled = true
			textLabel.Parent = clone
		end

		local function fn11(arg)
			pcall(function()
				if clone:FindFirstChild("ImageLabel") then
					clone.ImageLabel.ImageTransparency = arg and 0.1 or 0.15
				end

				if clone:FindFirstChild("ImageLabelBaseHOLDING") then
					clone.ImageLabelBaseHOLDING.Visible = arg and true or false
				end
			end)
		end

		clone.MouseButton1Down:Connect(function()
			if localPlayer2:GetAttribute("MoveMobileButtons") then
				return
			end
			fn11(true)
			fn9()
		end)

		clone.MouseButton1Up:Connect(function()
			fn11(false)
		end)

		MainModule.PhantomDashMobileGui = screenGui
	end

	MainModule.toggle_phantom_dash = function(phantomDashEnabled)
		MainModule.PhantomDashEnabled = phantomDashEnabled

		if MainModule.PhantomDashConnection then
			MainModule.PhantomDashConnection:Disconnect()
			MainModule.PhantomDashConnection = nil
		end

		if MainModule.PhantomDashKeybindConnection then
			MainModule.PhantomDashKeybindConnection:Disconnect()
			MainModule.PhantomDashKeybindConnection = nil
		end

		if MainModule.PhantomDashMobileGui then
			MainModule.PhantomDashMobileGui:Destroy()
			MainModule.PhantomDashMobileGui = nil
		end

		if MainModule.PhantomDashRechargeThread then
			task.cancel(MainModule.PhantomDashRechargeThread)
			MainModule.PhantomDashRechargeThread = nil
		end

		MainModule.PhantomDashCurrentCharges = MainModule.PhantomDashMaxCharges
		MainModule.PhantomDashIsMoving = false

		if phantomDashEnabled then
			if MainModule.is_mobile() then
				fn10()
			else
				MainModule.PhantomDashKeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then
						return
					end

					if input.KeyCode == MainModule.PhantomDashKeybind then
						fn9()
					end
				end)
			end
		end

		fn4()
	end
end

MainModule.set_phantom_dash_keybind = function(phantomDashKeybind)
	MainModule.PhantomDashKeybind = phantomDashKeybind
end

MainModule.set_phantom_dash_distance = function(phantomDashDistance)
	MainModule.PhantomDashDistance = phantomDashDistance
end

MainModule.set_phantom_dash_duration = function(arg)
	MainModule.PhantomDashDuration = arg / 100
end

MainModule.set_phantom_dash_cooldown = function(phantomDashCooldown)
	MainModule.PhantomDashCooldown = phantomDashCooldown

	pcall(function()
		if shared and type(shared) == "table" then
			shared.HSX_DashCooldown = phantomDashCooldown
		end

		localPlayer2:SetAttribute("HSX_DashCooldown", phantomDashCooldown)
	end)
end

MainModule.set_phantom_dash_max_charges = function(phantomDashMaxCharges)
	MainModule.PhantomDashMaxCharges = phantomDashMaxCharges
	MainModule.PhantomDashCurrentCharges = phantomDashMaxCharges
end

MainModule.RLGLEnabled = false
MainModule.RLGLConnection = nil
MainModule.RLGLOriginalWalkSpeed = 16
MainModule.RLGLOriginalJumpPower = 50
MainModule.RLGLOriginalJumpHeight = 7.2
MainModule.RLGLWasFrozen = false
MainModule.RLGLRedLightAnimId = "rbxassetid://73083130944511"
MainModule.RLGLPointA = Vector3.new(-215, 1023, -513)
MainModule.RLGLPointB = Vector3.new(116, 1023, 82)
MainModule.RLGLMinX = math.min(MainModule.RLGLPointA.X, MainModule.RLGLPointB.X)
MainModule.RLGLMaxX = math.max(MainModule.RLGLPointA.X, MainModule.RLGLPointB.X)
MainModule.RLGLMinY = math.min(MainModule.RLGLPointA.Y, MainModule.RLGLPointB.Y) - 50
MainModule.RLGLMaxY = math.max(MainModule.RLGLPointA.Y, MainModule.RLGLPointB.Y) + 50
MainModule.RLGLMinZ = math.min(MainModule.RLGLPointA.Z, MainModule.RLGLPointB.Z)
MainModule.RLGLMaxZ = math.max(MainModule.RLGLPointA.Z, MainModule.RLGLPointB.Z)

pcall(function()
	local redLightTurn = ReplicatedStorage:FindFirstChild("Animations") and ReplicatedStorage.Animations:FindFirstChild("Games") and ReplicatedStorage.Animations.Games:FindFirstChild("RedLightGreenLight") and ReplicatedStorage.Animations.Games.RedLightGreenLight:FindFirstChild("RedLightTurn")

	if redLightTurn and redLightTurn:IsA("Animation") then
		MainModule.RLGLRedLightAnimId = redLightTurn.AnimationId
	end
end)

MainModule.getHumanoid = function()
	local character = localPlayer2.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

MainModule.getHRP = function()
	local character = localPlayer2.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

MainModule.isPlayerInZone = function()
	local v2 = MainModule.getHRP()
	if not v2 then
		return false
	end
	local position = v2.Position
	local flag = position.X >= MainModule.RLGLMinX and position.X <= MainModule.RLGLMaxX
	local flag2

	if flag then
		flag2 = position.Y >= MainModule.RLGLMinY and position.Y <= MainModule.RLGLMaxY
	else
		flag2 = flag
	end

	return flag2 and position.Z >= MainModule.RLGLMinZ and position.Z <= MainModule.RLGLMaxZ
end

MainModule.RLGLCachedAnimators = {}
MainModule.RLGLLastCacheTime = 0

MainModule.updateAnimatorCache = function()
	local now = tick()
	if now - MainModule.RLGLLastCacheTime < 0.5 then
		return
	end
	MainModule.RLGLLastCacheTime = now
	table.clear(MainModule.RLGLCachedAnimators)

	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant:IsA("Animator") then
			table.insert(MainModule.RLGLCachedAnimators, descendant)
		end
	end
end

MainModule.isRedLightActive = function()
	MainModule.updateAnimatorCache()
	local str = tostring(MainModule.RLGLRedLightAnimId)

	for i = #MainModule.RLGLCachedAnimators, 1, -1 do
		local v2 = MainModule.RLGLCachedAnimators[i]
		if not v2 or not v2.Parent then
			table.remove(MainModule.RLGLCachedAnimators, i)
			continue
		end

		for _, v3 in ipairs(v2:GetPlayingAnimationTracks()) do
			if v3.Animation and v3.IsPlaying then
				if tostring(v3.Animation.AnimationId) == str then
					return true
				end
			end
		end
	end

	return false
end

MainModule.freezePlayer = function()
	local v2 = MainModule.getHumanoid()
	local v3 = MainModule.getHRP()
	if not v2 then
		return
	end

	if not MainModule.RLGLWasFrozen then
		MainModule.RLGLOriginalWalkSpeed = v2.WalkSpeed
		MainModule.RLGLOriginalJumpPower = v2.JumpPower
		MainModule.RLGLOriginalJumpHeight = v2.JumpHeight
		MainModule.RLGLWasFrozen = true
	end

	v2:Move(Vector3.zero, false)

	if v3 then
		v3.AssemblyLinearVelocity = Vector3.new(0, v3.AssemblyLinearVelocity.Y, 0)
		v3.AssemblyAngularVelocity = Vector3.zero
	end

	v2.WalkSpeed = 0
	v2.JumpPower = 0
	v2.JumpHeight = 0
end

MainModule.unfreezePlayer = function()
	local v2 = MainModule.getHumanoid()
	if not v2 then
		return
	end
	v2.WalkSpeed = MainModule.RLGLOriginalWalkSpeed > 0 and MainModule.RLGLOriginalWalkSpeed or 16
	v2.JumpPower = MainModule.RLGLOriginalJumpPower > 0 and MainModule.RLGLOriginalJumpPower or 50
	v2.JumpHeight = MainModule.RLGLOriginalJumpHeight > 0 and MainModule.RLGLOriginalJumpHeight or 7.2
	MainModule.RLGLWasFrozen = false
end

MainModule.toggle_rlgl_stop = function(arg)
	local rlglStopEnabled = arg and true or false
	MainModule.RLGLStopEnabled = rlglStopEnabled

	if MainModule.RLGLStopConn then
		pcall(function()
			MainModule.RLGLStopConn:Disconnect()
		end)

		MainModule.RLGLStopConn = nil
	end

	if MainModule.RLGLStopTask then
		pcall(function()
			task.cancel(MainModule.RLGLStopTask)
		end)

		MainModule.RLGLStopTask = nil
	end

	pcall(function()
		local character = localPlayer2.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoid then
			humanoid.WalkSpeed = MainModule._RLGLSavedWalk or 16
			humanoid.JumpPower = MainModule._RLGLSavedJump or 50
			humanoid.JumpHeight = MainModule._RLGLSavedJumpH or humanoid.JumpHeight
			humanoid.PlatformStand = false
			humanoid.AutoRotate = true
		end

		if humanoidRootPart then
			humanoidRootPart.Anchored = false
		end

		if character then
			local v2 = pairs
			humanoid = humanoid and humanoid:GetPlayingAnimationTracks() or {}

			for _, v3 in v2(humanoid) do
				pcall(function()
					v3:AdjustSpeed(1)
				end)
			end
		end
	end)

	if not rlglStopEnabled then
		if fn4 then
			fn4()
		end

		return true
	end

	MainModule.RLGLStopTask = task.spawn(function()
		local flag = false

		while MainModule.RLGLStopEnabled do
			pcall(function()
				local flag2 = false

				if MainModule.isRedLightActive then
					flag2 = MainModule.isRedLightActive()
				end

				if MainModule.isPlayerInZone and not MainModule.isPlayerInZone() then
					flag2 = false
				end

				local character = localPlayer2.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				character = character and character:FindFirstChild("HumanoidRootPart")

				if flag2 then
					if humanoid and not flag then
						MainModule._RLGLSavedWalk = humanoid.WalkSpeed
						MainModule._RLGLSavedJump = humanoid.JumpPower
						MainModule._RLGLSavedJumpH = humanoid.JumpHeight
					end

					if humanoid then
						humanoid.WalkSpeed = 0
						humanoid.JumpPower = 0

						pcall(function()
							humanoid.JumpHeight = 0
						end)

						humanoid.PlatformStand = true
						humanoid.AutoRotate = false

						for _, v2 in pairs(humanoid:GetPlayingAnimationTracks()) do
							pcall(function()
								v2:AdjustSpeed(0)
								v2:Stop(0)
							end)
						end
					end

					if character then
						character.Anchored = true
						character.AssemblyLinearVelocity = Vector3.new()
					end

					flag = true
				elseif flag then
					if humanoid then
						humanoid.WalkSpeed = MainModule._RLGLSavedWalk or 16
						humanoid.JumpPower = MainModule._RLGLSavedJump or 50

						pcall(function()
							humanoid.JumpHeight = MainModule._RLGLSavedJumpH or 7.2
						end)

						humanoid.PlatformStand = false
						humanoid.AutoRotate = true
					end

					if character then
						character.Anchored = false
					end

					flag = false
				end
			end)

			task.wait(0.15)
		end
	end)

	if fn4 then
		fn4()
	end

	return true
end

MainModule.TugOfWarQTEMode = false
MainModule.TugOfWarQTEConnection = nil
MainModule.TugOfWarQTEUI = nil

do
	local HBGQTE = nil

	pcall(function()
		HBGQTE = require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("HBGQTE", 5))
	end)

	local function fn7()
		local playerGui = localPlayer2:FindFirstChild("PlayerGui")
		if not playerGui then
			return nil
		end
		local tugOfWarUIV2 = playerGui:FindFirstChild("TugOfWarUIV2") or playerGui:FindFirstChild("TugOfWarUI") or playerGui:FindFirstChild("TugofWarRemake")
		if tugOfWarUIV2 then
			return tugOfWarUIV2
		end
		local ui = ReplicatedStorage:FindFirstChild("UI")

		if ui then
			local tugOfWarUIV22 = ui:FindFirstChild("TugOfWarUIV2") or ui:FindFirstChild("TugOfWarUI")

			if tugOfWarUIV22 then
				local clone = tugOfWarUIV22:Clone()
				clone.Parent = playerGui
				return clone
			end
		end

		return nil
	end

	MainModule.toggle_tug_of_war_qte = function(tugOfWarQTEMode)
		MainModule.TugOfWarQTEMode = tugOfWarQTEMode

		if MainModule.TugOfWarQTEConnection then
			MainModule.TugOfWarQTEConnection:Disconnect()
			MainModule.TugOfWarQTEConnection = nil
		end

		if MainModule.TugOfWarQTEUI then
			MainModule.TugOfWarQTEUI:Destroy()
			MainModule.TugOfWarQTEUI = nil
		end

		if tugOfWarQTEMode then
			localPlayer2:SetAttribute("TugOfWarPhase", "QTE")
			workspace:SetAttribute("TugOfWarRhythmGoal", 180)
			workspace:SetAttribute("TugOfWarRush", nil)
			local v2 = fn7()

			if v2 then
				v2.Enabled = true
				MainModule.TugOfWarQTEUI = v2
				local tugOfWarQTEHandler = v2:FindFirstChild("TugOfWarQTEHandler", true) or v2:FindFirstChildWhichIsA("LocalScript", true) or v2:FindFirstChildWhichIsA("Script", true)

				if tugOfWarQTEHandler and tugOfWarQTEHandler:IsA("LocalScript") then
					tugOfWarQTEHandler.Disabled = false
				end
			end

			task.wait(0.3)
			localPlayer2:SetAttribute("TugOfWarPhase", "QTE")
			MainModule.notify("Tug of War", "QTE Mode Enabled", 0.9)
		else
			MainModule.notify("Tug of War", "QTE Mode Disabled", 0.9)
		end

		fn4()
	end

	MainModule.AutoPullV2 = MainModule.AutoPullV2 or {
		Enabled = false,
		Remote = nil,
		CapturedArgs = nil,
		Conn = nil,
		LastFire = 0,
		_hooked = false,
		_orig = nil,
	}

	local function fn8()
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")

		if remotes then
			local temporaryReachedBindable = remotes:FindFirstChild("TemporaryReachedBindable")
			if temporaryReachedBindable and temporaryReachedBindable:IsA("RemoteEvent") then
				return temporaryReachedBindable
			end
		end

		local fn9 = nil

		fn9 = function(arg, arg2)
			if arg2 > 6 then
				return nil
			end

			for _, child in ipairs(arg:GetChildren()) do
				if child:IsA("RemoteEvent") and child.Name == "TemporaryReachedBindable" then
					return child
				end
				local v2 = fn9(child, arg2 + 1)
				if v2 then
					return v2
				end
			end

			return nil
		end

		return (fn9(ReplicatedStorage, 0))
	end

	local function fn9()
		local v2 = fn8()
		if not v2 then
			return false
		end
		MainModule.AutoPullV2.Remote = v2
		if not hookfunction then
			return true
		end

		pcall(function()
			if MainModule.AutoPullV2._hooked then
				return
			end

			MainModule.AutoPullV2._orig = hookfunction(v2.FireServer, function(arg, ...)
				local v3 = table.pack(...)
				local capturedArgs = { ... }

				if arg == v2 or typeof(arg) == "Instance" and arg.Name == "TemporaryReachedBindable" then
					MainModule.AutoPullV2.CapturedArgs = capturedArgs
				end

				return MainModule.AutoPullV2._orig(arg, table.unpack(v3, 1, v3.n))
			end)

			MainModule.AutoPullV2._hooked = true
		end)

		return true
	end

	local function fn10()
		local remote = MainModule.AutoPullV2.Remote or fn8()
		if not remote then
			return
		end
		MainModule.AutoPullV2.Remote = remote
		local capturedArgs = MainModule.AutoPullV2.CapturedArgs

		if capturedArgs and #capturedArgs > 0 then
			pcall(function()
				remote:FireServer(unpack(capturedArgs))
			end)
		else
			pcall(function()
				remote:FireServer({}, {})
			end)
		end
	end

	MainModule.PingPongAutoPullConn = nil

	MainModule.toggle_tug_auto_pull_op = function(arg)
		local enabled = arg and true or false
		MainModule.AutoPullV2 = MainModule.AutoPullV2 or {}
		MainModule.AutoPullV2.Enabled = enabled

		if MainModule.AutoPullV2.Conn then
			pcall(function()
				MainModule.AutoPullV2.Conn:Disconnect()
			end)

			MainModule.AutoPullV2.Conn = nil
		end

		if MainModule.AutoPullV2._pressTask then
			pcall(function()
				task.cancel(MainModule.AutoPullV2._pressTask)
			end)

			MainModule.AutoPullV2._pressTask = nil
		end

		if not enabled then
			MainModule.AutoPullV2._didPress = false
			MainModule.AutoPullV2.CapturedArgs = nil

			if fn4 then
				fn4()
			end

			return true
		end

		MainModule.AutoPullV2._didPress = false
		MainModule.AutoPullV2.CapturedArgs = nil
		MainModule._TugOPRemoteHooked = false

		local function fn11()
			local playerGui = localPlayer2:FindFirstChild("PlayerGui")
			if not playerGui then
				return nil
			end

			for _, descendant in ipairs(playerGui:GetDescendants()) do
				if descendant.Name == "CircleBase" and descendant:FindFirstChild("Arrow") and descendant:FindFirstChild("Medium") then
					return descendant
				end
			end

			return nil
		end

		local function fn12(arg2)
			pcall(function()
				local arrow = arg2:FindFirstChild("Arrow")
				local medium = arg2:FindFirstChild("Medium")

				if arrow and medium then
					medium.Rotation = arrow.Rotation
				end
			end)
		end

		local function fn13(arg2)
			pcall(function()
				local textButton = arg2

				if arg2 then
					textButton = arg2:FindFirstChild("TextButton") or arg2:FindFirstChildWhichIsA("TextButton", true)
				end

				if textButton and firesignal then
					firesignal(textButton.MouseButton1Click)
				end
			end)

			pcall(function()
				local remotes = ReplicatedStorage:FindFirstChild("Remotes")
				remotes = remotes and remotes:FindFirstChild("TemporaryReachedBindable")

				if remotes then
					remotes:FireServer({ GameQTE = true })
					remotes:FireServer({ IHateYou = true })
				end
			end)
		end

		pcall(function()
			if fn9 then
				fn9()
			end
		end)

		MainModule.AutoPullV2._pressTask = task.spawn(function()
			local n = 0

			while true do
				if MainModule.AutoPullV2.Enabled and n < 20 then
					local v2 = fn11()

					if v2 then
						fn12(v2)
						fn13(v2)
						n += 1
					end

					if MainModule.AutoPullV2.CapturedArgs and #MainModule.AutoPullV2.CapturedArgs > 0 then
						MainModule.AutoPullV2._didPress = true
						break
					else
						task.wait(0.12)
						continue
					end
				end

				break
			end

			MainModule.AutoPullV2._didPress = true
		end)

		MainModule.AutoPullV2.Conn = RunService2.Heartbeat:Connect(function()
			if not MainModule.AutoPullV2.Enabled then
				return
			end

			if not MainModule.AutoPullV2._didPress then
				return
			end
			local now = tick()
			if now - (MainModule.AutoPullV2.LastFire or 0) < 0.04 then
				return
			end
			MainModule.AutoPullV2.LastFire = now

			if MainModule.AutoPullV2.CapturedArgs and #MainModule.AutoPullV2.CapturedArgs > 0 then
				pcall(function()
					fn10()
				end)
			else
				pcall(function()
					local remotes = ReplicatedStorage:FindFirstChild("Remotes")
					local temporaryReachedBindable = remotes and remotes:FindFirstChild("TemporaryReachedBindable")

					if temporaryReachedBindable then
						temporaryReachedBindable:FireServer({ GameQTE = true })
						temporaryReachedBindable:FireServer({ IHateYou = true })
					end
				end)
			end
		end)

		if fn4 then
			fn4()
		end

		return true
	end

	local flag = false
	local thread = nil

	local function fn11()
		flag = false

		if thread then
			task.cancel(thread)
			thread = nil
		end
	end

	MainModule.QTELetters = MainModule.QTELetters or "WASD"
	MainModule.QTESpawnSpeed = MainModule.QTESpawnSpeed or 0.5

	local function fn12()
		fn11()
		local qteLetters = MainModule.QTELetters or "WASD"
		local n = tonumber(MainModule.QTESpawnSpeed) or 0.5
		local tbl = {}

		for i = 1, #tostring(qteLetters) do
			local str = tostring(qteLetters):sub(i, i):upper()

			if str:match("[A-Z]") then
				tbl[#tbl + 1] = str
			end
		end

		if #tbl == 0 then
			fn2("QTE Buttons", "No valid letters entered", 0.9)
			return
		end
		local module = HBGQTE
		local flag2 = not module

		if flag2 then
			pcall(function()
				local modules = ReplicatedStorage:FindFirstChild("Modules")

				if modules then
					local hbgqte = modules:FindFirstChild("HBGQTE")

					if hbgqte then
						module = require(hbgqte)
					end
				end
			end)

			HBGQTE = module
		end

		if flag2 or type(module.SetUpButton) ~= "function" then
			fn2("QTE Buttons", "HBGQTE not available right now", 0.9)
			return
		end
		flag = true

		thread = task.spawn(function()
			local n2 = 1

			while flag do
				local v2 = tbl[n2]

				if not pcall(function()
					module.SetUpButton(3, v2, false, nil)
				end) then
					flag = false
					break
				else
					n2 = n2 % #tbl + 1
					task.wait(n)
				end
			end

			thread = nil
		end)
	end

	MainModule.toggle_qte_buttons = function(arg)
		if arg then
			fn12()
		else
			fn11()
		end

		fn4()
	end
end

MainModule.BalloonData = {
	ESPEnabled = false,
	TPEnabled = false,
	Tracers = {},
	Highlights = {},
	NotifiedBalloons = {},
	ProcessedPrompts = {},
}

do
	local function fn7(arg)
		if not arg or not arg:IsA("ProximityPrompt") then
			return
		end

		if fireproximityprompt then
			pcall(function()
				fireproximityprompt(arg)
			end)
		elseif syn and syn.proximityprompt then
			pcall(function()
				syn.proximityprompt(arg)
			end)
		else
			local holdDuration = arg.HoldDuration
			arg.HoldDuration = 0

			pcall(function()
				arg:InputHoldBegin()
				task.wait()
				arg:InputHoldEnd()
			end)

			arg.HoldDuration = holdDuration
		end
	end

	MainModule.toggle_balloon_teleport = function(tpEnabled)
		MainModule.BalloonData.TPEnabled = tpEnabled
		fn4()
	end

	local function fn8(arg)
		if not arg or not arg:IsA("ProximityPrompt") then
			return false
		end

		if not arg.Enabled then
			return false
		end

		if not arg.Parent then
			return false
		end

		if arg.MaxActivationDistance and arg.MaxActivationDistance <= 0 then
			return false
		end
		return true
	end

	task.spawn(function()
		while task.wait(0.2) do
			if MainModule.BalloonData.TPEnabled then
				local effects = workspace:FindFirstChild("Effects")

				if effects then
					for _, child in ipairs(effects:GetChildren()) do
						if child.Name == "Balloon" and not MainModule.BalloonData.ProcessedPrompts[child] then
							local balloonProximityPrompt = child:FindFirstChild("BalloonProximityPrompt", true) or child:FindFirstChildWhichIsA("ProximityPrompt", true)

							if balloonProximityPrompt and fn8(balloonProximityPrompt) then
								MainModule.BalloonData.ProcessedPrompts[child] = true

								task.spawn(function()
									if not (child and child.Parent and MainModule.BalloonData.TPEnabled) then
										return
									end

									if not fn8(balloonProximityPrompt) then
										MainModule.BalloonData.ProcessedPrompts[child] = nil
										return
									end
									local parent = balloonProximityPrompt.Parent:IsA("BasePart") and balloonProximityPrompt.Parent or child:FindFirstChildWhichIsA("BasePart", true)
									local v2 = MainModule.get_character()
									local v3 = v2 and MainModule.get_root_part(v2)

									if v2 and v3 and parent then
										pcall(function()
											v2:PivotTo(parent.CFrame * CFrame.new(0, 5, 0))
										end)

										task.wait(0.2)

										if fn8(balloonProximityPrompt) then
											fn7(balloonProximityPrompt)
										end
									else
										MainModule.BalloonData.ProcessedPrompts[child] = nil
									end
								end)
							end
						end
					end
				end
			end
		end
	end)
end

MainModule.create_esp_visuals = function(adornee)
	local isBasePart = adornee:IsA("BasePart") and adornee or adornee:FindFirstChildWhichIsA("BasePart", true)
	if not isBasePart then
		return
	end

	if not MainModule.BalloonData.NotifiedBalloons[adornee] then
		MainModule.BalloonData.NotifiedBalloons[adornee] = true

		if lib and fn2 then
			fn2({ Title = "Ishak Hub", Description = "Balloon detected!", Duration = 0.9 })
		end

		if fn5 then
			fn5()
		end
	end

	if not MainModule.BalloonData.Highlights[adornee] then
		local highlight = Instance.new("Highlight")
		highlight.Name = "BalloonHighlight"
		highlight.Adornee = adornee
		highlight.FillColor = Color3.fromRGB(255, 255, 255)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.Parent = adornee
		MainModule.BalloonData.Highlights[adornee] = highlight
	end

	local v2 = MainModule.get_character()

	if v2 then
		local v3 = MainModule.get_root_part(v2)

		if v3 and not MainModule.BalloonData.Tracers[isBasePart] then
			local attachment = Instance.new("Attachment", v3)
			attachment.Name = "BalloonTracerA0"
			local attachment2 = Instance.new("Attachment", isBasePart)
			attachment2.Name = "BalloonTracerA1"
			local beam = Instance.new("Beam")
			beam.Name = "BalloonTracerBeam"
			beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			beam.Width0 = 0.15
			beam.Width1 = 0.15
			beam.FaceCamera = true
			beam.Attachment0 = attachment
			beam.Attachment1 = attachment2
			beam.Parent = isBasePart
			MainModule.BalloonData.Tracers[isBasePart] = { Attachment0 = attachment, Attachment1 = attachment2, Beam = beam }
		end
	end

	adornee.AncestryChanged:Connect(function(child, parent)
		if not parent then
			MainModule.BalloonData.NotifiedBalloons[adornee] = nil
			MainModule.BalloonData.ProcessedPrompts[adornee] = nil

			if MainModule.BalloonData.Highlights[adornee] then
				pcall(function()
					MainModule.BalloonData.Highlights[adornee]:Destroy()
				end)

				MainModule.BalloonData.Highlights[adornee] = nil
			end

			if MainModule.BalloonData.Tracers[isBasePart] then
				pcall(function()
					MainModule.BalloonData.Tracers[isBasePart].Attachment0:Destroy()
					MainModule.BalloonData.Tracers[isBasePart].Attachment1:Destroy()
					MainModule.BalloonData.Tracers[isBasePart].Beam:Destroy()
				end)

				MainModule.BalloonData.Tracers[isBasePart] = nil
			end
		end
	end)
end

MainModule.toggle_balloon_esp = function(espEnabled)
	MainModule.BalloonData.ESPEnabled = espEnabled

	if not espEnabled then
		for _, highlight in pairs(MainModule.BalloonData.Highlights) do
			pcall(function()
				highlight:Destroy()
			end)
		end

		for _, tracer in pairs(MainModule.BalloonData.Tracers) do
			pcall(function()
				tracer.Attachment0:Destroy()
				tracer.Attachment1:Destroy()
				tracer.Beam:Destroy()
			end)
		end

		MainModule.BalloonData.Highlights = {}
		MainModule.BalloonData.Tracers = {}
		MainModule.BalloonData.NotifiedBalloons = {}
	end

	fn4()
end

task.spawn(function()
	while task.wait(0.5) do
		if MainModule.BalloonData.ESPEnabled then
			local effects = workspace:FindFirstChild("Effects")

			if effects then
				for _, child in ipairs(effects:GetChildren()) do
					if child.Name == "Balloon" then
						MainModule.create_esp_visuals(child)
					end
				end
			end
		end
	end
end)

MainModule.noclipEnabled = false
MainModule.noclipButton = nil
MainModule.noclipConnection = nil
MainModule.TELEPORT_DISTANCE = 13
MainModule.RAY_LENGTH = 6

MainModule.createNoclipButton = function()
	if MainModule.noclipButton then
		pcall(function()
			MainModule.noclipButton:Destroy()
		end)
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = HttpService:GenerateGUID(false)
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = localPlayer2:WaitForChild("PlayerGui")
	local textButton = Instance.new("TextButton")
	textButton.Name = HttpService:GenerateGUID(false)
	textButton.Size = UDim2.new(0, 90, 0, 90)
	textButton.Position = UDim2.new(1, -110, 0.5, -45)
	textButton.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	textButton.BackgroundTransparency = 0.25
	textButton.Text = "TP Wall"
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.TextSize = 16
	textButton.Font = Enum.Font.GothamBold
	textButton.AutoButtonColor = true
	textButton.Parent = screenGui
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(200, 200, 210)
	uiStroke.Thickness = 1.5
	uiStroke.Parent = textButton
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = textButton
	local flag = false
	local flag2 = false
	local position = nil
	local position2 = nil

	textButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			flag = true
			flag2 = false
			position = input.Position
			position2 = textButton.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not flag then
			return
		end

		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
			local n = input.Position - position

			if math.abs(n.X) > 6 or math.abs(n.Y) > 6 then
				flag2 = true
			end

			textButton.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n.X, position2.Y.Scale, position2.Y.Offset + n.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			if flag and not flag2 then
				pcall(function()
					MainModule.teleportThroughWall()
				end)
			end

			flag = false
		end
	end)

	MainModule.noclipButton = screenGui
	return screenGui
end

MainModule.ThroughWallsEnabled = false
MainModule.ThroughWallsConn = nil
MainModule.RAY_LENGTH = MainModule.RAY_LENGTH or 50
MainModule.TELEPORT_DISTANCE = MainModule.TELEPORT_DISTANCE or 8

MainModule.toggle_through_walls = function(arg)
	MainModule.ThroughWallsEnabled = arg and true or false
	MainModule.noclipEnabled = MainModule.ThroughWallsEnabled

	if MainModule.ThroughWallsConn then
		pcall(function()
			MainModule.ThroughWallsConn:Disconnect()
		end)

		MainModule.ThroughWallsConn = nil
	end

	if MainModule.noclipButton then
		pcall(function()
			MainModule.noclipButton:Destroy()
		end)

		MainModule.noclipButton = nil
	end

	if MainModule.ThroughWallsEnabled then
		MainModule.ThroughWallsConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.KeyCode == Enum.KeyCode.X then
				pcall(function()
					MainModule.teleportThroughWall()
				end)
			end
		end)

		local flag = false

		pcall(function()
			flag = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		end)

		if flag and MainModule.createNoclipButton then
			pcall(MainModule.createNoclipButton)
		end
	end

	fn4()
	return true
end

MainModule.teleportThroughWall = function()
	if not MainModule.noclipEnabled then
		return
	end
	local character = localPlayer2.Character
	if not character then
		return
	end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end
	local currentCamera = workspace.CurrentCamera
	if not currentCamera then
		return
	end
	local lookVector = currentCamera.CFrame.LookVector
	local position = humanoidRootPart.Position
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.IgnoreWater = true
	local hit = workspace:Raycast(position, lookVector * MainModule.RAY_LENGTH, raycastParams)
	local n = position + lookVector * MainModule.TELEPORT_DISTANCE

	if hit then
		n = hit.Position + lookVector * 3 + hit.Normal * 2
	end

	humanoidRootPart.CanCollide = false
	humanoidRootPart.CFrame = CFrame.new(n)
	task.wait()
	humanoidRootPart.CanCollide = true
end

MainModule.desyncHooked = false

MainModule.desyncAvailable = pcall(function()
	return raknet and raknet.add_send_hook
end)

MainModule.rakhook = function(arg)
	if arg.PacketId == 27 then
		local asBuffer = arg.AsBuffer

		if buffer and buffer.writeu32 then
			buffer.writeu32(asBuffer, 1, 4294967295)
			arg:SetData(asBuffer)
		end
	end
end

MainModule.toggle_desync = function(arg)
	local desync = MainModule.ToggleRefs.Desync

	if arg and MainModule.is_xeno_executor() then
		MainModule.notify("Desync", "Not supported in your executor", 0.9)
		fn5()

		if desync and desync.SetValue then
			pcall(function()
				desync:SetValue(false)
			end)
		end

		return false
	end

	if not MainModule.desyncAvailable then
		MainModule.notify("Desync", "Unsupported Executor", 0.9)
		fn5()

		if desync and desync.SetValue then
			pcall(function()
				desync:SetValue(false)
			end)
		end

		return false
	end

	if arg then
		if not MainModule.desyncHooked then
			pcall(function()
				raknet.add_send_hook(MainModule.rakhook)
				MainModule.desyncHooked = true
			end)
		end
	elseif MainModule.desyncHooked then
		pcall(function()
			raknet.remove_send_hook(MainModule.rakhook)
			MainModule.desyncHooked = false
		end)
	end

	fn4()
	return true
end

MainModule.spectate_player = function(arg)
	if not arg then
		return
	end

	if not arg.Character then
		MainModule.notify("Spectate", "Player has no character", 0.9)
		fn5()
		return
	end

	local humanoid = arg.Character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		fn2({ Title = "Spectate", Description = "Player is dead", Duration = 0.9 })
		fn5()
		return
	end

	workspace.CurrentCamera.CameraSubject = humanoid
	fn2({ Title = "Spectate", Description = "Spectating: " .. arg.Name, Duration = 0.9 })
	fn4()
end

MainModule.stop_spectate = function()
	local character = localPlayer2.Character

	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			workspace.CurrentCamera.CameraSubject = humanoid
			fn2({ Title = "Spectate", Description = "Stopped", Duration = 0.9 })
			fn4()
		end
	end
end

MainModule.teleport_to_player = function(arg)
	if not arg then
		return
	end

	if not arg.Character then
		fn2({ Title = "Teleport", Description = "Player has no character", Duration = 0.9 })
		fn5()
		return
	end

	local humanoidRootPart = arg.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		fn2({ Title = "Teleport", Description = "Player has no root part", Duration = 0.9 })
		fn5()
		return
	end

	local character = localPlayer2.Character
	if not character then
		return
	end
	local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart2 then
		return
	end
	humanoidRootPart2.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 3, 0))
	fn2({ Title = "Teleport", Description = "Teleported to: " .. arg.Name, Duration = 0.9 })
	fn4()
end

MainModule.getNearestPlayerAnywhere = function()
	local v2 = MainModule.get_character()
	if not v2 then
		return nil
	end
	local position = v2:FindFirstChild("HumanoidRootPart") and v2.HumanoidRootPart.Position
	if not position then
		return nil
	end
	local huge = math.huge
	local v3 = nil

	for _, player in pairs(Players2:GetPlayers()) do
		if player ~= localPlayer2 and player.Character then
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				local magnitude = (humanoidRootPart.Position - position).Magnitude

				if magnitude < huge then
					huge = magnitude
					v3 = player
				end
			end
		end
	end

	return v3
end

MainModule.teleportToNearest = function()
	MainModule._MovecheckFromAuto = true
	pcall(MainModule.HSX_MovecheckAutoStart)
	MainModule._MovecheckFromAuto = false

	task.delay(2, function()
		pcall(MainModule.HSX_MovecheckAutoStop)
	end)

	local character = localPlayer2.Character
	character = character and character:FindFirstChild("HumanoidRootPart")
	if not character then
		fn2({ Title = "Teleport", Description = "No character", Duration = 0.9 })
		return
	end
	local huge = math.huge
	local v2 = nil

	for _, player in ipairs(Players2:GetPlayers()) do
		if player ~= localPlayer2 and player.Character then
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

			if humanoidRootPart and humanoid and humanoid.Health > 0 and not player.Character:FindFirstChild("Dead") then
				local magnitude = (character.Position - humanoidRootPart.Position).Magnitude

				if magnitude < huge then
					huge = magnitude
					v2 = player
				end
			end
		end
	end

	if v2 and v2.Character then
		local humanoidRootPart = v2.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			character.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 3, 0))
			MainModule.notify("Teleport", "Teleported to: " .. v2.Name, 0.9)
			fn4()
		end
	else
		fn2({ Title = "Teleport", Description = "No player's near :c", Duration = 0.9 })
		fn5()
	end
end

MainModule.update_all_toggles_by_game = function()
	local values = Workspace:FindFirstChild("Values")
	if not values then
		return
	end
	local currentGame = values:FindFirstChild("CurrentGame")
	local value = currentGame and currentGame.Value
	MainModule.update_toggle_availability("AutoDodge", value == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.AutoDodge)
	MainModule.update_toggle_availability("InfiniteStamina", value == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.InfiniteStamina)
	MainModule.update_toggle_availability("SpikesKill", value == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.SpikesKill)
	MainModule.update_toggle_availability("AutoKillHiders", MainModule.is_game_active("HideAndSeek") and "HideAndSeek" or nil, MainModule.ToggleRefs.AutoKillHiders)
	MainModule.update_toggle_availability("AutoEscape", value == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.AutoEscape)
	MainModule.update_toggle_availability("KeyESP", value == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.KeyESP)
	MainModule.update_toggle_availability("JumpRopeAntiFall", value == "JumpRope" and "JumpRope" or nil, MainModule.ToggleRefs.JumpRopeAntiFall)
	MainModule.update_toggle_availability("GlassESP", value == "GlassBridge" and "GlassBridge" or nil, MainModule.ToggleRefs.GlassESP)
	MainModule.update_toggle_availability("AntiBreak", value == "GlassBridge" and "GlassBridge" or nil, MainModule.ToggleRefs.AntiBreak)
	MainModule.update_toggle_availability("ZoneKill", value == "LastDinner" and "LastDinner" or nil, MainModule.ToggleRefs.ZoneKill)
	MainModule.update_toggle_availability("VoidKill", value == "SkySquidGame" and "SkySquidGame" or nil, MainModule.ToggleRefs.VoidKill)
	MainModule.update_toggle_availability("SkySquidAntiFall", value == "SkySquidGame" and "SkySquidGame" or nil, MainModule.ToggleRefs.SkySquidAntiFall)
	MainModule.update_toggle_availability("MingleVoidKill", value == "Mingle" and "Mingle" or nil, MainModule.ToggleRefs.MingleVoidKill)
	MainModule.update_toggle_availability("GodMode", value == "RedLightGreenLight" and "RedLightGreenLight" or nil, MainModule.ToggleRefs.GodMode)
	MainModule.update_toggle_availability("RemoveInjury", value == "RedLightGreenLight" and "RedLightGreenLight" or nil, MainModule.ToggleRefs.RemoveInjury)
	MainModule.update_toggle_availability("RedLightHelpPlayers", MainModule.is_game_active("RedLightGreenLight") and "RedLightGreenLight" or nil, MainModule.ToggleRefs.RedLightHelpPlayers)
	MainModule.update_toggle_availability("AutoChoke", value == "Mingle" and "Mingle" or nil, MainModule.ToggleRefs.AutoChoke)
	MainModule.update_toggle_availability("AutoPickupKeys", value == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.AutoPickup)
	MainModule.update_toggle_availability("ExitDoorESP", value == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.ExitDoorESP)
	MainModule.update_toggle_availability("ESPDroppedKeys", value == "HideAndSeek" and "HideAndSeek" or nil, MainModule.ToggleRefs.ESPDroppedKeys)
	MainModule.update_toggle_availability("AutoDdakji", value == "Pentathlon" and "Pentathlon" or nil, MainModule.ToggleRefs.AutoDdakji)
	MainModule.update_toggle_availability("AutoFlyingStone", value == "Pentathlon" and "Pentathlon" or nil, MainModule.ToggleRefs.AutoFlyingStone)
	MainModule.update_toggle_availability("AutoGonggi", value == "Pentathlon" and "Pentathlon" or nil, MainModule.ToggleRefs.AutoGonggi)
	MainModule.update_toggle_availability("AutoSpinningTop", value == "Pentathlon" and "Pentathlon" or nil, MainModule.ToggleRefs.AutoSpinningTop)
	MainModule.update_toggle_availability("AutoJegi", value == "Pentathlon" and "Pentathlon" or nil, MainModule.ToggleRefs.AutoJegi)
	MainModule.update_toggle_availability("HCGlassESP", value == "GlassBridge" and "GlassBridge" or nil, MainModule.ToggleRefs.HCGlassESP)
end

MainModule.GameStateMonitor = { Connection = nil, LastGame = nil }

MainModule.GameStateMonitor.Start = function()
	if MainModule.GameStateMonitor.Connection then
		MainModule.GameStateMonitor.Connection:Disconnect()
	end

	MainModule.GameStateMonitor.Connection = RunService2.Heartbeat:Connect(function()
		local values = Workspace:FindFirstChild("Values")
		if not values then
			return
		end
		local currentGame = values:FindFirstChild("CurrentGame")
		currentGame = currentGame and currentGame.Value

		if currentGame ~= MainModule.GameStateMonitor.LastGame then
			if MainModule.GameStateMonitor.LastGame then
				MainModule.GameStateMonitor.DisableGameToggles(MainModule.GameStateMonitor.LastGame)
			end

			MainModule.GameStateMonitor.LastGame = currentGame
			MainModule.update_all_toggles_by_game()
		end
	end)
end

MainModule.GameStateMonitor.DisableGameToggles = function(arg)
	local v2 = ({
		HideAndSeek = {
			"AutoKillHiders",
			"AutoDodge",
			"InfiniteStamina",
			"SpikesKill",
			"AutoEscape",
			"KeyESP",
			"AutoPickupKeys",
			"ExitDoorESP",
			"ESPDroppedKeys",
		},
		JumpRope = { "JumpRopeAntiFall" },
		GlassBridge = { "GlassESP", "AntiBreak", "HCGlassESP" },
		LastDinner = { "ZoneKill" },
		SkySquidGame = { "VoidKill", "SkySquidAntiFall" },
		Mingle = { "MingleVoidKill", "AutoChoke" },
		RedLightGreenLight = { "GodMode", "RemoveInjury", "RedLightHelpPlayers" },
		Pentathlon = { "AutoDdakji", "AutoFlyingStone", "AutoGonggi", "AutoSpinningTop", "AutoJegi" },
	})[arg]

	if v2 then
		for _, v3 in ipairs(v2) do
			MainModule.disable_toggle(v3)
		end
	end
end

MainModule.GameStateMonitor.Start()

MainModule.teleport_to_safe_spot = function()
	MainModule._MovecheckFromAuto = true
	pcall(MainModule.HSX_MovecheckAutoStart)
	MainModule._MovecheckFromAuto = false

	task.delay(2, function()
		pcall(MainModule.HSX_MovecheckAutoStop)
	end)

	if MainModule.is_game_active("LastDinner") then
		MainModule.safe_teleport(Vector3.new(0, 100, 0))
		MainModule.notify("Last Dinner", "Teleported to Safe Spot", 0.9)
	else
		MainModule.notify("Last Dinner", "Wait for LastDinner!", 0.9)
		fn5()
	end

	fn4()
end

MainModule.toggle_vampire_vision = function(arg)
	local vampireVisionEnabled = arg and true or false
	MainModule.VampireVisionEnabled = vampireVisionEnabled
	local Lighting = game:GetService("Lighting")
	local vampireNightVision = Lighting:FindFirstChild("VampireNightVision")

	if vampireVisionEnabled then
		if not vampireNightVision then
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Name = "VampireNightVision"
			colorCorrectionEffect.Parent = Lighting
			vampireNightVision = colorCorrectionEffect
		end

		vampireNightVision.Brightness = 0.16
		vampireNightVision.Contrast = 0.06
		vampireNightVision.Saturation = -0.08
		vampireNightVision.TintColor = Color3.fromRGB(255, 236, 236)
	elseif vampireNightVision then
		vampireNightVision:Destroy()
	end

	fn4()
end

MainModule.DisableEffectsEnabled = false
MainModule.DisableEffectsConn = nil

local tbl = {
	LocalRagdolls = true,
	Plushies = true,
	SnowPileHolder = true,
	SpawnLocation = true,
	BigAdjute = true,
	Perbert = true,
	PickModelCacheFix = true,
	Won = true,
	SoundPart = true,
	QueuePartFix = true,
}

MainModule.toggle_disable_effects = function(arg)
	local disableEffectsEnabled = arg and true or false
	MainModule.DisableEffectsEnabled = disableEffectsEnabled

	if MainModule.DisableEffectsConn then
		pcall(function()
			MainModule.DisableEffectsConn:Disconnect()
		end)

		MainModule.DisableEffectsConn = nil
	end

	if disableEffectsEnabled then
		MainModule.DisableEffectsConn = RunService2.Heartbeat:Connect(function()
			if not MainModule.DisableEffectsEnabled then
				return
			end
			local effects = workspace:FindFirstChild("Effects")
			if not effects then
				return
			end

			for _, child in ipairs(effects:GetChildren()) do
				if not tbl[child.Name] then
					pcall(function()
						child:Destroy()
					end)
				end
			end
		end)
	end

	fn4()
end

task.spawn(function()
	local function fn7(child)
		if not child or not child:IsA("Tool") then
			return
		end
		local v2 = string.lower(child.Name)

		if v2:find("lightning") or v2:find("ultra instinct") or v2:find("awakening") then
			pcall(function()
				child.RequiresHandle = false
			end)
		end
	end

	local function fn8(arg)
		if not arg then
			return
		end

		for _, child in ipairs(arg:GetChildren()) do
			fn7(child)
		end
	end

	local function fn9(arg)
		if not arg then
			return
		end
		arg.ChildAdded:Connect(fn7)
		fn8(arg)
	end

	fn9(localPlayer2:FindFirstChild("Backpack"))

	localPlayer2.CharacterAdded:Connect(function(character)
		fn9(character)
		task.wait(0.5)
		fn8(localPlayer2:FindFirstChild("Backpack"))
	end)

	if localPlayer2.Character then
		fn9(localPlayer2.Character)
	end

	localPlayer2.ChildAdded:Connect(function(child)
		if child.Name == "Backpack" then
			fn9(child)
		end
	end)
end)

MainModule.AutoBecomeGuardEnabled = false
MainModule.AutoBecomeGuardTier = "Circle"
MainModule.AutoBecomeGuardTask = nil

MainModule.set_guard_tier = function(arg)
	local autoBecomeGuardTier = tostring(arg or "Circle")

	if autoBecomeGuardTier ~= "Circle" and autoBecomeGuardTier ~= "Triangle" and autoBecomeGuardTier ~= "Square" then
		autoBecomeGuardTier = "Circle"
	end

	MainModule.AutoBecomeGuardTier = autoBecomeGuardTier
end

do
	local tbl2 = {
		"buy",
		"playable",
		"one.time",
		"onetime",
		"temporary",
		"onetim",
		"time.playable",
		"time.guard",
		"playable.guard",
		"one.time.guard",
		"temporary.guard",
		"playable.one.time",
	}

	local function fn7(arg)
		local tbl3 = {}

		pcall(function()
			if arg.Text then
				table.insert(tbl3, string.lower(tostring(arg.Text)))
			end
		end)

		pcall(function()
			for _, descendant in ipairs(arg:GetDescendants()) do
				if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
					table.insert(tbl3, string.lower(tostring(descendant.Text or "")))
				end
			end
		end)

		pcall(function()
			table.insert(tbl3, string.lower(arg.Name or ""))
			local parent = arg.Parent

			for i = 1, 4 do
				if parent then
					table.insert(tbl3, string.lower(parent.Name or ""))
					parent = parent.Parent
					continue
				end

				break
			end
		end)

		return table.concat(tbl3, " ")
	end

	local function fn8(arg)
		local v2 = fn7(arg)

		for _, v3 in ipairs(tbl2) do
			if string.find(v2, v3, 1, true) then
				return true
			end
		end

		return false
	end

	local function fn9(arg)
		if not arg or fn8(arg) then
			return false
		end
		local flag = false

		pcall(function()
			if firesignal then
				pcall(firesignal, arg.MouseButton1Click)
				pcall(firesignal, arg.Activated)
				pcall(firesignal, arg.MouseButton1Down)
				pcall(firesignal, arg.MouseButton1Up)
				flag = true
			end
		end)

		pcall(function()
			if getconnections then
				for _, v2 in ipairs({ arg.MouseButton1Click, arg.Activated, arg.MouseButton1Down, arg.MouseButton1Up }) do
					if v2 then
						for _, v3 in pairs(getconnections(v2)) do
							pcall(function()
								if v3.Fire then
									v3:Fire()
								end
							end)

							flag = true
						end
					end
				end
			end
		end)

		return flag
	end

	local function fn10(arg)
		local playerGui = localPlayer2:FindFirstChild("PlayerGui")
		if not playerGui then
			return nil
		end
		local tbl3 = {}

		for _, descendant in ipairs(playerGui:GetDescendants()) do
			if descendant:IsA("GuiButton") or descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
				local tbl4 = {}
				local parent = descendant

				for i = 1, 8 do
					if not (not parent or parent == playerGui) then
						table.insert(tbl4, 1, string.lower(parent.Name or ""))
						parent = parent.Parent
						continue
					end

					break
				end

				local str = table.concat(tbl4, "/")
				local flag = true

				for _, v2 in ipairs(arg) do
					if not string.find(str, string.lower(v2), 1, true) then
						flag = false
						break
					end
				end

				if flag then
					table.insert(tbl3, descendant)
				end
			end
		end

		return tbl3
	end

	local function fn11(arg)
		local playerGui = localPlayer2:FindFirstChild("PlayerGui")
		if not playerGui then
			return {}
		end
		local tbl3 = {}

		for _, descendant in ipairs(playerGui:GetDescendants()) do
			if descendant:IsA("GuiButton") or descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
				local v2 = fn7(descendant)

				for _, v3 in ipairs(arg) do
					if string.find(v2, string.lower(v3), 1, true) then
						table.insert(tbl3, descendant)
						break
					end
				end
			end
		end

		return tbl3
	end

	local function fn12()
		local autoBecomeGuardTier = MainModule.AutoBecomeGuardTier or "Circle"

		pcall(function()
			localPlayer2:SetAttribute("__OwnsPermGuard", true)
		end)

		local tbl3 = ({
			Circle = { "worker", "circle", "tier1", "EquipTier1" },
			Triangle = { "soldier", "triangle", "tier2", "EquipTier2" },
			Square = { "manager", "square", "tier3", "EquipTier3" },
		})[autoBecomeGuardTier] or { "worker", "circle" }

		local v2 = ipairs
		local v3 = fn10
		local tbl4 = {}
		local str = tbl3[4] or "EquipTier1"
		tbl4[1] = "RankSelection"
		tbl4[2] = str

		for _, v4 in v2(v3(tbl4)) do
			fn9(v4)
		end

		for _, v4 in ipairs(tbl3) do
			for _, v5 in ipairs(fn11({ v4 })) do
				if not fn8(v5) then
					fn9(v5)
				end
			end
		end

		for _, v4 in ipairs(fn11({ "equip", "lock in", "lockin" })) do
			if not fn8(v4) then
				fn9(v4)
			end
		end

		for _, v4 in ipairs(fn10({ "RankConfirmation", "Green" })) do
			fn9(v4)
		end

		for _, v4 in ipairs(fn11({ "confirm", "lock in", "green" })) do
			if not fn8(v4) then
				fn9(v4)
			end
		end
	end

	MainModule.toggle_auto_become_guard = function(arg)
		local autoBecomeGuardEnabled = arg and true or false
		MainModule.AutoBecomeGuardEnabled = autoBecomeGuardEnabled

		if MainModule.AutoBecomeGuardTask then
			pcall(function()
				task.cancel(MainModule.AutoBecomeGuardTask)
			end)

			MainModule.AutoBecomeGuardTask = nil
		end

		if not autoBecomeGuardEnabled then
			if fn4 then
				fn4()
			end

			return
		end

		MainModule.AutoBecomeGuardTask = task.spawn(function()
			while MainModule.AutoBecomeGuardEnabled do
				if not localPlayer2:GetAttribute("IsGuard") then
					fn12()
					task.wait(0.12)
					continue
				end

				break
			end
		end)

		if fn4 then
			fn4()
		end
	end
end

MainModule.RebelGuardHitboxEnabled = false
MainModule.RebelGuardHitboxConn = nil
MainModule.RebelGuardESPEnabled = false
MainModule.RebelGuardESPConn = nil
MainModule.RebelGuardESPObjects = {}
MainModule.RebelGuardSilentEnabled = false
local fn7

do
	local function fn8(arg)
		if not arg or not arg:IsA("Model") then
			return false
		end

		if arg == localPlayer2.Character then
			return false
		end

		if Players2:GetPlayerFromCharacter(arg) then
			return false
		end

		if arg:FindFirstChild("Dead") then
			return false
		end
		local humanoid = arg:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return false
		end
		local name = arg.Name
		local v2 = string.lower(name)

		if arg:FindFirstChild("TypeOfGuard") then
			if string.find(name, "RebelGuard") or string.find(name, "FinalRebel") or string.find(name, "HallwayGuard") or string.find(v2, "aggro") or string.find(v2, "guard") or string.find(v2, "worker") or string.find(v2, "soldier") or string.find(v2, "manager") then
				return true
			end
			return true
		end

		if string.find(name, "RebelGuard") or string.find(name, "FinalRebel") or string.find(name, "HallwayGuard") or string.find(v2, "aggro") or string.find(v2, "guard") or arg:GetAttribute("IsGuard") or arg:GetAttribute("GuardTier") ~= nil or arg:FindFirstChild("Guard") then
			return true
		end
		return false
	end

	local function fn9()
		local tbl2 = {}
		local tbl3 = {}
		local live = workspace:FindFirstChild("Live")
		local npCs = workspace:FindFirstChild("NPCs")
		local characters = workspace:FindFirstChild("Characters")
		local v2 = workspace
		tbl3[1] = live
		tbl3[2] = npCs
		tbl3[3] = characters
		tbl3[4] = v2
		local tbl4 = {}

		for _, v3 in ipairs(tbl3) do
			if v3 then
				for _, child in ipairs(v3:GetChildren()) do
					if not tbl4[child] and fn8(child) then
						tbl4[child] = true
						table.insert(tbl2, child)
					end
				end

				if v3 ~= workspace then
					for _, descendant in ipairs(v3:GetDescendants()) do
						if descendant:IsA("Model") and not tbl4[descendant] and fn8(descendant) then
							tbl4[descendant] = true
							table.insert(tbl2, descendant)
						end
					end
				end
			end
		end

		return tbl2
	end

	MainModule.RebelGuardHitboxSize = MainModule.RebelGuardHitboxSize or 6
	MainModule.RebelGuardHitboxOriginals = MainModule.RebelGuardHitboxOriginals or {}

	MainModule.set_rebel_guard_hitbox_size = function(arg)
		local rebelGuardHitboxSize = tonumber(arg) or 6

		if rebelGuardHitboxSize < 2 then
			rebelGuardHitboxSize = 2
		end

		if rebelGuardHitboxSize > 30 then
			rebelGuardHitboxSize = 30
		end

		MainModule.RebelGuardHitboxSize = rebelGuardHitboxSize
	end

	local function fn10()
		for _, rebelGuardHitboxOriginal in pairs(MainModule.RebelGuardHitboxOriginals) do
			pcall(function()
				if rebelGuardHitboxOriginal.head and rebelGuardHitboxOriginal.head.Parent then
					rebelGuardHitboxOriginal.head.Size = rebelGuardHitboxOriginal.size
					rebelGuardHitboxOriginal.head.CanCollide = rebelGuardHitboxOriginal.canCollide
					rebelGuardHitboxOriginal.head.Transparency = rebelGuardHitboxOriginal.transparency or rebelGuardHitboxOriginal.head.Transparency
				end
			end)
		end

		MainModule.RebelGuardHitboxOriginals = {}
	end

	MainModule.toggle_rebel_guard_hitbox = function(arg)
		local rebelGuardHitboxEnabled = arg and true or false
		MainModule.RebelGuardHitboxEnabled = rebelGuardHitboxEnabled

		if MainModule.RebelGuardHitboxConn then
			pcall(function()
				MainModule.RebelGuardHitboxConn:Disconnect()
			end)

			MainModule.RebelGuardHitboxConn = nil
		end

		if not rebelGuardHitboxEnabled then
			fn10()

			if fn4 then
				fn4()
			end

			return true
		end

		MainModule.RebelGuardHitboxConn = RunService2.Heartbeat:Connect(function()
			if not MainModule.RebelGuardHitboxEnabled then
				return
			end
			local rebelGuardHitboxSize = MainModule.RebelGuardHitboxSize or 6
			local vector = Vector3.new(rebelGuardHitboxSize, rebelGuardHitboxSize, rebelGuardHitboxSize)
			local tbl2 = {}

			for _, v2 in ipairs(fn9()) do
				tbl2[v2] = true
				local head = v2:FindFirstChild("Head")

				if head and head:IsA("BasePart") then
					if not MainModule.RebelGuardHitboxOriginals[v2] then
						MainModule.RebelGuardHitboxOriginals[v2] = {
							head = head,
							size = head.Size,
							canCollide = head.CanCollide,
							transparency = head.Transparency,
						}
					end

					pcall(function()
						if head.Size ~= vector then
							head.Size = vector
							head.CanCollide = false
						end
					end)
				end
			end

			for k, rebelGuardHitboxOriginal in pairs(MainModule.RebelGuardHitboxOriginals) do
				if not tbl2[k] or not k.Parent or k:FindFirstChild("Dead") then
					pcall(function()
						if rebelGuardHitboxOriginal.head and rebelGuardHitboxOriginal.head.Parent then
							rebelGuardHitboxOriginal.head.Size = rebelGuardHitboxOriginal.size
							rebelGuardHitboxOriginal.head.CanCollide = rebelGuardHitboxOriginal.canCollide
						end
					end)

					MainModule.RebelGuardHitboxOriginals[k] = nil
				end
			end
		end)

		if fn4 then
			fn4()
		end

		return true
	end

	MainModule.toggle_rebel_guard_esp = function(arg)
		local rebelGuardESPEnabled = arg and true or false
		MainModule.RebelGuardESPEnabled = rebelGuardESPEnabled

		if MainModule.RebelGuardESPConn then
			pcall(function()
				MainModule.RebelGuardESPConn:Disconnect()
			end)

			MainModule.RebelGuardESPConn = nil
		end

		local function fn11()
			for k, rebelGuardESPObject in pairs(MainModule.RebelGuardESPObjects) do
				if type(rebelGuardESPObject) == "table" then
					pcall(function()
						if rebelGuardESPObject.hl then
							rebelGuardESPObject.hl:Destroy()
						end
					end)

					pcall(function()
						if rebelGuardESPObject.bb then
							rebelGuardESPObject.bb:Destroy()
						end
					end)
				else
					pcall(function()
						rebelGuardESPObject:Destroy()
					end)
				end

				MainModule.RebelGuardESPObjects[k] = nil
			end

			MainModule.RebelGuardESPObjects = {}
		end

		fn11()

		if not rebelGuardESPEnabled then
			if fn4 then
				fn4()
			end

			return true
		end

		local n = 0

		MainModule.RebelGuardESPConn = RunService2.Heartbeat:Connect(function(deltaTime)
			if not MainModule.RebelGuardESPEnabled then
				return
			end
			n += deltaTime or 0.016
			if n < 0.12 then
				return
			end
			n = 0
			local tbl2 = {}
			local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")

			for _, v2 in ipairs(fn9()) do
				tbl2[v2] = true
				local humanoidRootPart2 = v2:FindFirstChild("HumanoidRootPart") or v2.PrimaryPart

				if humanoidRootPart2 then
					local v3 = MainModule.RebelGuardESPObjects[v2]

					if not v3 then
						local highlight = Instance.new("Highlight")
						highlight.Adornee = v2
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.FillColor = Color3.fromRGB(255, 50, 50)
						highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
						highlight.FillTransparency = 0.45
						highlight.OutlineTransparency = 0
						highlight.Parent = v2
						local billboardGui = Instance.new("BillboardGui")
						billboardGui.Adornee = humanoidRootPart2
						billboardGui.AlwaysOnTop = true
						billboardGui.Size = UDim2.new(0, 120, 0, 30)
						billboardGui.StudsOffset = Vector3.new(0, 3, 0)
						billboardGui.Parent = humanoidRootPart2
						local textLabel = Instance.new("TextLabel")
						textLabel.BackgroundTransparency = 1
						textLabel.Size = UDim2.new(1, 0, 1, 0)
						textLabel.Font = Enum.Font.Oswald
						textLabel.TextSize = 14
						textLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
						textLabel.TextStrokeTransparency = 0.5
						textLabel.Text = "Guard"
						textLabel.Parent = billboardGui
						MainModule.RebelGuardESPObjects[v2] = { hl = highlight, bb = billboardGui, tl = textLabel }
					elseif v3.tl then
						local n2 = 0

						if humanoidRootPart then
							n2 = math.floor((humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude)
						end

						v3.tl.Text = "Guard [" .. tostring(n2) .. "]"
					end
				end
			end

			for k, rebelGuardESPObject in pairs(MainModule.RebelGuardESPObjects) do
				if not tbl2[k] then
					if type(rebelGuardESPObject) == "table" then
						pcall(function()
							if rebelGuardESPObject.hl then
								rebelGuardESPObject.hl:Destroy()
							end
						end)

						pcall(function()
							if rebelGuardESPObject.bb then
								rebelGuardESPObject.bb:Destroy()
							end
						end)
					else
						pcall(function()
							rebelGuardESPObject:Destroy()
						end)
					end

					MainModule.RebelGuardESPObjects[k] = nil
				end
			end
		end)

		if fn4 then
			fn4()
		end

		return true
	end

	MainModule.toggle_rebel_guard_silent = function(arg)
		MainModule.RebelGuardSilentEnabled = arg and true or false
		pcall(HSX_HookGunMath)

		if fn4 then
			fn4()
		end

		return true
	end

	MainModule.GuardAimbotEnabled = false
	MainModule.GuardAimbotConn = nil
	MainModule.GuardAimbotSpeed = 0.35

	MainModule.toggle_guard_aimbot = function(arg)
		local guardAimbotEnabled = arg and true or false
		MainModule.GuardAimbotEnabled = guardAimbotEnabled

		if MainModule.GuardAimbotConn then
			pcall(function()
				MainModule.GuardAimbotConn:Disconnect()
			end)

			MainModule.GuardAimbotConn = nil
		end

		if not guardAimbotEnabled then
			if fn4 then
				fn4()
			end

			return true
		end

		MainModule.GuardAimbotConn = RunService2.RenderStepped:Connect(function()
			if not MainModule.GuardAimbotEnabled then
				return
			end
			local currentCamera = workspace.CurrentCamera
			if not currentCamera then
				return
			end
			local v2 = HSX_ClosestRebelGuardHead and HSX_ClosestRebelGuardHead()
			if not v2 then
				return
			end
			local guardAimbotSpeed = MainModule.GuardAimbotSpeed or 0.35
			currentCamera.CFrame = currentCamera.CFrame:Lerp(CFrame.lookAt(currentCamera.CFrame.Position, v2.Position), math.clamp(guardAimbotSpeed, 0.05, 1))
		end)

		if fn4 then
			fn4()
		end

		return true
	end

	MainModule.BringGuardsEnabled = false
	MainModule.BringGuardsConn = nil
	MainModule.BringGuardsOrigins = {}

	MainModule.toggle_bring_all_guards = function(arg)
		local bringGuardsEnabled = arg and true or false
		MainModule.BringGuardsEnabled = bringGuardsEnabled

		if MainModule.BringGuardsConn then
			pcall(function()
				MainModule.BringGuardsConn:Disconnect()
			end)

			MainModule.BringGuardsConn = nil
		end

		if not bringGuardsEnabled then
			for k, bringGuardsOrigin in pairs(MainModule.BringGuardsOrigins) do
				pcall(function()
					if k and k.Parent then
						local humanoidRootPart = k:FindFirstChild("HumanoidRootPart") or k.PrimaryPart

						if humanoidRootPart then
							humanoidRootPart.CFrame = bringGuardsOrigin
						end
					end
				end)
			end

			MainModule.BringGuardsOrigins = {}

			if fn4 then
				fn4()
			end

			return true
		end

		MainModule.BringGuardsConn = RunService2.Heartbeat:Connect(function()
			if not MainModule.BringGuardsEnabled then
				return
			end
			local character = localPlayer2.Character
			character = character and character:FindFirstChild("HumanoidRootPart")
			if not character then
				return
			end
			local cFrame = character.CFrame * CFrame.new(0, 0, -8)
			local tbl2 = fn9 and fn9() or {}

			for _, v2 in ipairs(tbl2) do
				local humanoidRootPart = v2:FindFirstChild("HumanoidRootPart") or v2.PrimaryPart

				if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
					if not MainModule.BringGuardsOrigins[v2] then
						MainModule.BringGuardsOrigins[v2] = humanoidRootPart.CFrame
					end

					pcall(function()
						humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
						humanoidRootPart.CFrame = cFrame
					end)
				end
			end
		end)

		if fn4 then
			fn4()
		end

		return true
	end

	local function fn11()
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then
			return nil
		end
		local position = currentCamera.CFrame.Position
		local lookVector = currentCamera.CFrame.LookVector
		local tbl2 = {}
		local v2

		if type(HSX_IterPeaberts) == "function" then
			v2 = HSX_IterPeaberts()
		else
			local live = workspace:FindFirstChild("Live")

			if live then
				for i = 1, 10 do
					local v3 = live:FindFirstChild("EvilPeabert1_" .. i)

					if v3 then
						table.insert(tbl2, v3)
					end
				end

				v2 = tbl2
			else
				v2 = tbl2
			end
		end

		local n = -1e9
		local v3 = nil

		for _, v4 in ipairs(v2) do
			if v4 and not v4:FindFirstChild("Dead") then
				local head = v4:FindFirstChild("Head") or v4:FindFirstChild("HumanoidRootPart")
				local humanoid = v4:FindFirstChildOfClass("Humanoid")

				if head and (not humanoid or humanoid.Health > 0) then
					local n2 = head.Position - position
					local magnitude = n2.Magnitude

					if magnitude > 1 and magnitude < 5000 then
						local n3 = n2.Unit:Dot(lookVector) * 2 + 1 - math.clamp(magnitude / 5000, 0, 1)

						if n < n3 then
							n = n3
							v3 = head
						end
					end
				end
			end
		end

		return v3
	end

	local function fn12()
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then
			return nil
		end
		local position = currentCamera.CFrame.Position
		local lookVector = currentCamera.CFrame.LookVector
		local n = -1e9
		local v2 = nil

		for _, v3 in ipairs(fn9()) do
			if not v3:FindFirstChild("Dead") then
				local head = v3:FindFirstChild("Head") or v3:FindFirstChild("HumanoidRootPart")
				local humanoid = v3:FindFirstChildOfClass("Humanoid")

				if head and humanoid and humanoid.Health > 0 then
					local n2 = head.Position - position
					local magnitude = n2.Magnitude

					if magnitude > 1 and magnitude < 5000 then
						local v4 = n2.Unit:Dot(lookVector)

						if v4 >= -0.55 then
							local n3 = v4 * 2.5 + 1 - math.clamp(magnitude / 5000, 0, 1)

							if n < n3 then
								n = n3
								v2 = head
							end
						end
					end
				end
			end
		end

		return v2
	end

	MainModule.NoRecoilEnabled = false
	MainModule.SilentAimEnabled = false
	MainModule._GunMathHooked = false
	MainModule._OriginalGetBulletLookAt = nil
	MainModule._OriginalGetRayCast = nil
	MainModule.NoRecoilConnection = nil

	local function fn13()
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then
			return nil
		end
		local position = currentCamera.CFrame.Position
		local lookVector = currentCamera.CFrame.LookVector
		local Players3 = game:GetService("Players")
		local localPlayer3 = Players3.LocalPlayer
		local n = -1
		local v2 = nil

		for _, player in ipairs(Players3:GetPlayers()) do
			if player ~= localPlayer3 then
				local character = player.Character

				if character and not character:FindFirstChild("Dead") then
					local head = character:FindFirstChild("Head")
					local humanoid = character:FindFirstChildOfClass("Humanoid")

					if head and humanoid and humanoid.Health > 0 then
						local n2 = head.Position - position
						local magnitude = n2.Magnitude

						if magnitude > 2 and magnitude < 5000 then
							local v3 = n2.Unit:Dot(lookVector)

							if v3 >= -0.55 then
								local n3 = v3 * 2 + 1 - math.clamp(magnitude / 5000, 0, 1)

								if n < n3 then
									n = n3
									v2 = head
								end
							end
						end
					end
				end
			end
		end

		local live = workspace:FindFirstChild("Live")

		if live then
			for _, v3 in ipairs({
				"EvilPeabert1_1",
				"EvilPeabert1_2",
				"EvilPeabert1_3",
				"EvilPeabert1_4",
				"EvilPeabert1_5",
				"EvilPeabert1_6",
				"EvilPeabert1_7",
				"EvilPeabert1_8",
				"EvilPeabert1_9",
				"EvilPeabert1_10",
			}) do
				local v4 = live:FindFirstChild(v3)

				if v4 and not v4:FindFirstChild("Dead") then
					local head = v4:FindFirstChild("Head") or v4:FindFirstChild("HumanoidRootPart")
					local humanoid = v4:FindFirstChildOfClass("Humanoid")

					if head and (not humanoid or humanoid.Health > 0) then
						local n2 = head.Position - position
						local magnitude = n2.Magnitude

						if magnitude > 2 and magnitude < 5000 then
							local v5 = n2.Unit:Dot(lookVector)

							if v5 >= -0.55 then
								local n3 = v5 * 2 + 1 - math.clamp(magnitude / 5000, 0, 1)

								if n < n3 then
									n = n3
									v2 = head
								end
							end
						end
					end
				end
			end

			for _, child in ipairs(live:GetChildren()) do
				if string.lower(child.Name or ""):find("evilpeabert") and not child:FindFirstChild("Dead") then
					local head = child:FindFirstChild("Head") or child:FindFirstChild("HumanoidRootPart")

					if head then
						local n2 = head.Position - position
						local magnitude = n2.Magnitude

						if magnitude > 2 and magnitude < 5000 then
							local v3 = n2.Unit:Dot(lookVector)

							if v3 >= -0.55 then
								local n3 = v3 * 2 + 1 - math.clamp(magnitude / 5000, 0, 1)

								if n < n3 then
									n = n3
									v2 = head
								end
							end
						end
					end
				end
			end
		end

		return v2
	end

	local function fn14()
		if MainModule._GunMathHooked then
			return true
		end

		local ok, result = pcall(function()
			return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SharedGunMath"))
		end)

		if not ok or type(result) ~= "table" then
			return false
		end

		if not MainModule._OriginalGetBulletLookAt then
			MainModule._OriginalGetBulletLookAt = result.GetBulletLookAt
		end

		result.GetBulletLookAt = function(arg, arg2, arg3, arg4, arg5)
			arg5 = typeof(arg5) == "table" and arg5 or {}

			if MainModule.NoRecoilEnabled or MainModule.SilentAimEnabled or MainModule.RebelGuardSilentEnabled or MainModule.PeabertSilentEnabled then
				arg5.spread = 0
				arg5.IgnoreClientCheck = true
				arg4 = Vector3.zero
			end

			if MainModule.RebelGuardSilentEnabled or MainModule.SilentAimEnabled or MainModule.PeabertSilentEnabled then
				local v2 = nil

				if MainModule.RebelGuardSilentEnabled then
					v2 = fn12()
				end

				if not v2 and MainModule.PeabertSilentEnabled then
					v2 = fn11()
				end

				if not v2 and MainModule.SilentAimEnabled then
					v2 = fn13()
				end

				if v2 then
					arg3 = v2.Position
					arg5.spread = 0
					arg4 = Vector3.zero
				end
			end

			return MainModule._OriginalGetBulletLookAt(arg, arg2, arg3, arg4, arg5)
		end

		MainModule._GunMathHooked = true
		return true
	end

	local function fn15()
		local weapons = ReplicatedStorage:FindFirstChild("Weapons")
		weapons = weapons and weapons:FindFirstChild("Guns")
		if not weapons then
			return
		end

		for _, child in ipairs(weapons:GetChildren()) do
			for _, v2 in ipairs({ "Spread", "Recoil", "RecoilShake", "CameraRecoil", "CameraShake" }) do
				local v3 = child:FindFirstChild(v2, true)

				if v3 then
					pcall(function()
						if v3:IsA("NumberValue") or v3:IsA("IntValue") then
							v3.Value = 0
						elseif v3:IsA("Vector3Value") then
							v3.Value = Vector3.zero
						end
					end)
				end
			end

			pcall(function()
				child:SetAttribute("Recoil", 0)
				child:SetAttribute("RecoilShake", 0)
				child:SetAttribute("Spread", 0)
			end)
		end
	end

	MainModule.toggle_no_recoil = function(arg)
		local noRecoilEnabled = arg and true or false
		MainModule.NoRecoilEnabled = noRecoilEnabled
		pcall(fn14)

		if MainModule.NoRecoilConnection then
			pcall(function()
				MainModule.NoRecoilConnection:Disconnect()
			end)

			MainModule.NoRecoilConnection = nil
		end

		if noRecoilEnabled then
			fn15()

			MainModule.NoRecoilConnection = RunService2.Heartbeat:Connect(function()
				if not MainModule.NoRecoilEnabled then
					return
				end
				fn15()
			end)
		end

		fn4()
	end

	MainModule.EffectShooter = {
		Enabled = false,
		Connection = nil,
		LastShootTime = 0,
		ShootCooldown = 0.5,
		TrackedPlayers = {},
		TargetEffect = "GuardCanKillLockOn",
	}

	MainModule.GetLocalGun = function()
		local v2 = nil

		if localPlayer2.Character then
			v2 = nil

			for _, child in pairs(localPlayer2.Character:GetChildren()) do
				if child:IsA("Tool") and child:GetAttribute("Gun") then
					v2 = child
					break
				else
					v2 = nil
				end
			end
		end

		if not v2 and localPlayer2.Backpack then
			for _, child in pairs(localPlayer2.Backpack:GetChildren()) do
				if child:IsA("Tool") and child:GetAttribute("Gun") then
					v2 = child
					break
				end
			end
		end

		return v2
	end

	MainModule.HasTargetEffect = function(arg)
		if MainModule.SilentAimEnabled or MainModule.EffectShooter and MainModule.EffectShooter.Enabled then
			return true
		end

		if not arg or not arg.Character then
			return false
		end

		for _, descendant in pairs(arg.Character:GetDescendants()) do
			local isBillboardGui = descendant:IsA("BillboardGui")

			if isBillboardGui then
				isBillboardGui = descendant.Name == (MainModule.EffectShooter and MainModule.EffectShooter.TargetEffect or "GuardCanKillLockOn")
			end

			if isBillboardGui then
				return true
			end
		end

		return false
	end

	MainModule.ShootAtPlayer = function(arg)
		local v2 = MainModule.GetLocalGun()
		if not v2 then
			return false
		end
		local tbl2 = {}

		local tbl3 = {
			ClientRayNormal = Vector3.new(0, 1, 0),
			FiredGun = true,
			SecondaryHitTargets = {},
			ClientRayInstance = nil,
			ClientRayPosition = Vector3.zero,
			bulletCF = CFrame.new(),
			HitTargets = { [arg] = "Head" },
			bulletSizeC = Vector3.new(0.01, 0.01, 4.45),
			NoMuzzleFX = false,
			FirePosition = Vector3.zero,
		}

		tbl2[1] = v2
		tbl2[2] = tbl3

		pcall(function()
			ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient"):FireServer(unpack(tbl2))
		end)

		return true
	end

	MainModule.toggle_silent_aim = function(arg)
		local silentAimEnabled = arg and true or false
		MainModule.SilentAimEnabled = silentAimEnabled

		MainModule.EffectShooter = MainModule.EffectShooter or {
			Enabled = false,
			Connection = nil,
			LastShootTime = 0,
			ShootCooldown = 0.05,
			TargetEffect = "GuardCanKillLockOn",
		}

		MainModule.EffectShooter.Enabled = silentAimEnabled

		if MainModule.EffectShooter.Connection then
			pcall(function()
				if typeof(MainModule.EffectShooter.Connection) == "RBXScriptConnection" then
					MainModule.EffectShooter.Connection:Disconnect()
				else
					task.cancel(MainModule.EffectShooter.Connection)
				end
			end)

			MainModule.EffectShooter.Connection = nil
		end

		if not silentAimEnabled then
			if fn4 then
				fn4()
			end

			return true
		end

		MainModule.EffectShooter.Connection = task.spawn(function()
			while MainModule.EffectShooter.Enabled do
				pcall(function()
					local currentCamera = workspace.CurrentCamera
					if not currentCamera then
						return
					end
					local n = -0.35
					local v2 = nil

					for _, player in ipairs(Players2:GetPlayers()) do
						if player ~= localPlayer2 and player.Character then
							local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
							local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")

							if humanoid and humanoid.Health > 0 and head then
								local n2 = head.Position - currentCamera.CFrame.Position

								if n2.Magnitude < 400 then
									local v3 = currentCamera.CFrame.LookVector:Dot(n2.Unit)

									if n < v3 then
										n = v3
										v2 = player
									end
								end
							end
						end
					end

					if v2 and MainModule.ShootAtPlayer then
						MainModule.ShootAtPlayer(v2.Name)
					end
				end)

				task.wait(0.05)
			end
		end)

		if fn4 then
			fn4()
		end

		return true
	end

	MainModule.toggle_spikes_esp = function(arg)
		MainModule.SpikesESPEnabled = arg and true or false
		local v2 = pairs
		local spikesESPObjects = MainModule.SpikesESPObjects or {}

		for _, spikesESPObject in v2(spikesESPObjects) do
			pcall(function()
				if type(spikesESPObject) == "table" then
					for _, v3 in pairs(spikesESPObject) do
						if v3 and v3.Destroy then
							v3:Destroy()
						end
					end
				elseif spikesESPObject and spikesESPObject.Destroy then
					spikesESPObject:Destroy()
				end
			end)
		end

		MainModule.SpikesESPObjects = {}

		if MainModule.SpikesESPConn then
			pcall(function()
				MainModule.SpikesESPConn:Disconnect()
			end)

			MainModule.SpikesESPConn = nil
		end

		if MainModule.SpikesESPFolder then
			pcall(function()
				MainModule.SpikesESPFolder:Destroy()
			end)

			MainModule.SpikesESPFolder = nil
		end

		if not arg then
			if fn4 then
				fn4()
			end

			return true
		end

		local folder = Instance.new("Folder")
		folder.Name = "HSX_SpikesESP"
		folder.Parent = workspace
		MainModule.SpikesESPFolder = folder
		local tbl2 = { KillingParts = true, killingParts = true, Killingparts = true, killingparts = true }

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if tbl2[descendant.Name] or string.lower(tostring(descendant.Name)) == "killingparts" then
				local tbl3 = {}

				if descendant:IsA("BasePart") then
					table.insert(tbl3, descendant)
				else
					for _, descendant2 in ipairs(descendant:GetDescendants()) do
						if descendant2:IsA("BasePart") then
							table.insert(tbl3, descendant2)
						end
					end
				end

				for _, v3 in ipairs(tbl3) do
					if not MainModule.SpikesESPObjects[v3] then
						local highlight = Instance.new("Highlight")
						highlight.Name = "HSX_SpikeHL"
						highlight.Adornee = v3
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.FillColor = Color3.fromRGB(0, 0, 0)
						highlight.OutlineColor = Color3.fromRGB(40, 40, 40)
						highlight.FillTransparency = 0.35
						highlight.OutlineTransparency = 0
						highlight.Parent = folder
						MainModule.SpikesESPObjects[v3] = highlight
					end
				end
			end
		end

		if fn4 then
			fn4()
		end

		return true
	end

	local v2 = nil
	MainModule._PlayerStatLabels = MainModule._PlayerStatLabels or {}

	fn7 = function(arg)
		local playerStatLabels = MainModule._PlayerStatLabels
		if not playerStatLabels or not next(playerStatLabels) then
			return
		end

		local function fn16(arg2, arg3)
			local v3 = playerStatLabels[arg2]
			if not v3 then
				return
			end

			pcall(function()
				if v3.SetTitle then
					v3:SetTitle(arg3)
				elseif v3.SetDesc then
					v3:SetDesc(arg3)
				elseif v3.SetText then
					v3:SetText(arg3)
				end
			end)
		end

		if not arg or not arg.Parent then
			for k in pairs(playerStatLabels) do
				fn16(k, k:gsub("^%l", string.upper) .. ": -")
			end

			return
		end

		local attributes = arg:GetAttributes()

		local function fn17(arg2)
			local str = tostring(math.floor(tonumber(arg2) or 0)):reverse():gsub("(%d%d%d)", "%1,"):reverse()

			if str:sub(1, 1) == "," then
				str = str:sub(2)
			end

			return str
		end

		fn16("Wins", "Wins: " .. fn17(attributes._GameWins or 0))
		fn16("Money", "Money: " .. fn17(attributes._Won or 0))
		fn16("Power", "Equipped Power: " .. tostring(attributes._EquippedPower or "-"))
		fn16("GuardPower", "Guard Power: " .. tostring(attributes._EquippedGuardPower or "-"))
		fn16("Level", "Level: " .. tostring(attributes._CurrentLevel or attributes._Level or attributes.Level or 0))
		fn16("PowerSpins", "Power Spins: " .. fn17(attributes._TotalPowerSpins or 0))
		fn16("GuardSpins", "Guard Spins: " .. fn17(attributes._TotalGuardPowerSpins or 0))
		fn16("Robux", "Robux Donated: " .. fn17(attributes._TotalRobuxDonated or attributes._RobuxDonated or 0))
		fn16("VIP", "VIP: " .. (attributes.__OwnsVIPGamepass and "Yes" or "No"))
		fn16("PermGuard", "Perm Guard: " .. (attributes.__OwnsPermGuard and "Yes" or "No"))
		fn16("Lighter", "Lighter: " .. (attributes.HasLighter and "Yes" or "No"))
	end

	Players2.PlayerAdded:Connect(function()
	end)

	Players2.PlayerRemoving:Connect(function()
		if v2 and not v2.Parent then
			v2 = nil
			fn7(nil)
		end
	end)

	RunService2.Heartbeat:Connect(function()
		if v2 and v2.Parent then
			fn7(v2)
		end
	end)

	local tbl2 = {}

	local function fn16()
		tbl2 = {}

		for _, player in pairs(Players2:GetPlayers()) do
			if player ~= localPlayer2 then
				table.insert(tbl2, player.Name)
			end
		end

		if #tbl2 == 0 then
			table.insert(tbl2, "No players")
		end
	end

	fn16()
	local v3 = nil

	Players2.PlayerAdded:Connect(function()
		task.wait(0.1)
		fn16()
	end)

	Players2.PlayerRemoving:Connect(function()
		task.wait(0.1)

		if v3 and not Players2:FindFirstChild(v3.Name) then
			v3 = nil
		end

		fn16()
	end)

	MainModule.PeabertHitboxEnabled = false
	MainModule.PeabertHitboxConn = nil
	MainModule.PeabertBringEnabled = false
	MainModule.PeabertBringConn = nil

	local function fn17()
		local tbl3 = {}
		local tbl4 = {}
		local live = workspace:FindFirstChild("Live") or workspace

		for _, v4 in ipairs({
			"EvilPeabert1_1",
			"EvilPeabert1_2",
			"EvilPeabert1_3",
			"EvilPeabert1_4",
			"EvilPeabert1_5",
			"EvilPeabert1_6",
			"EvilPeabert1_7",
			"EvilPeabert1_8",
			"EvilPeabert1_9",
			"EvilPeabert1_10",
		}) do
			local v5 = live:FindFirstChild(v4)

			if v5 and not tbl4[v5] then
				tbl4[v5] = true
				table.insert(tbl3, v5)
			end
		end

		local function fn18(arg)
			if not arg then
				return
			end

			for _, descendant in ipairs(arg:GetDescendants()) do
				if descendant:IsA("Model") then
					local v4 = string.lower(descendant.Name)

					if (v4:find("evilpeabert") or v4:match("^evilpeabert1_%d+$")) and not tbl4[descendant] then
						tbl4[descendant] = true
						table.insert(tbl3, descendant)
					end
				end
			end
		end

		fn18(live)
		fn18(workspace:FindFirstChild("Effects"))
		return tbl3
	end

	MainModule.toggle_peabert_hitbox = function(arg)
		local peabertHitboxEnabled = arg and true or false
		MainModule.PeabertHitboxEnabled = peabertHitboxEnabled

		if MainModule.PeabertHitboxConn then
			pcall(function()
				MainModule.PeabertHitboxConn:Disconnect()
			end)

			MainModule.PeabertHitboxConn = nil
		end

		if peabertHitboxEnabled then
			MainModule.PeabertHitboxConn = RunService2.Heartbeat:Connect(function()
				if not MainModule.PeabertHitboxEnabled then
					return
				end

				for _, v4 in ipairs(fn17()) do
					local humanoidRootPart = v4:FindFirstChild("HumanoidRootPart") or v4.PrimaryPart

					if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
						pcall(function()
							humanoidRootPart.Size = Vector3.new(12, 12, 12)
							humanoidRootPart.Transparency = 0.7
							humanoidRootPart.CanCollide = false
						end)
					end
				end
			end)
		end

		fn4()
	end

	MainModule.toggle_peabert_bring = function(arg)
		local peabertBringEnabled = arg and true or false
		MainModule.PeabertBringEnabled = peabertBringEnabled

		if MainModule.PeabertBringConn then
			pcall(function()
				MainModule.PeabertBringConn:Disconnect()
			end)

			MainModule.PeabertBringConn = nil
		end

		if not peabertBringEnabled then
			if fn4 then
				fn4()
			end

			return true
		end

		MainModule.PeabertBringConn = RunService2.Heartbeat:Connect(function()
			if not MainModule.PeabertBringEnabled then
				return
			end
			local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end
			local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -6)

			for _, v4 in ipairs(fn17()) do
				local humanoidRootPart2 = v4:FindFirstChild("HumanoidRootPart") or v4.PrimaryPart

				if humanoidRootPart2 then
					pcall(function()
						humanoidRootPart2.CFrame = cFrame
					end)
				end
			end
		end)

		if fn4 then
			fn4()
		end

		return true
	end

	MainModule.SurgeryAutoQTEEnabled = false
	MainModule.SurgeryAutoQTEConn = nil
	MainModule.DroppedGunESPEnabled = false
	MainModule.DroppedGunESPObjects = {}
	MainModule.DroppedGunESPConn = nil
	MainModule.AutoTPDroppedGunEnabled = false
	MainModule.AutoTPDroppedGunConn = nil

	local function fn18()
		local playerGui = localPlayer2:FindFirstChild("PlayerGui")
		if not playerGui then
			return {}
		end
		local tbl3 = {}

		for _, descendant in ipairs(playerGui:GetDescendants()) do
			if descendant:IsA("GuiButton") or descendant:IsA("ImageButton") or descendant:IsA("TextButton") then
				local v4 = string.lower(descendant.Name or "")
				local parent = descendant.Parent

				if parent then
					parent = string.lower(descendant.Parent.Name or "")
				end

				parent = parent or ""

				if v4:find("qte") or v4:find("circle") or parent:find("surgery") or parent:find("qte") then
					if descendant.Visible ~= false then
						table.insert(tbl3, descendant)
					end
				end
			end
		end

		return tbl3
	end

	MainModule.toggle_surgery_auto_qte = function(arg)
		local surgeryAutoQTEEnabled = arg and true or false
		MainModule.SurgeryAutoQTEEnabled = surgeryAutoQTEEnabled

		if MainModule.SurgeryAutoQTEConn then
			pcall(function()
				if typeof(MainModule.SurgeryAutoQTEConn) == "RBXScriptConnection" then
					MainModule.SurgeryAutoQTEConn:Disconnect()
				else
					task.cancel(MainModule.SurgeryAutoQTEConn)
				end
			end)

			MainModule.SurgeryAutoQTEConn = nil
		end

		if surgeryAutoQTEEnabled then
			MainModule.SurgeryAutoQTEConn = task.spawn(function()
				while MainModule.SurgeryAutoQTEEnabled do
					for _, v4 in ipairs(fn18()) do
						pcall(function()
							if firesignal then
								pcall(firesignal, v4.MouseButton1Click)
								pcall(firesignal, v4.Activated)
								pcall(firesignal, v4.MouseButton1Down)
							end
						end)
					end

					task.wait(5)
				end
			end)
		end

		if fn4 then
			fn4()
		end

		return true
	end

	local function fn19()
		local tbl3 = {}

		local function fn20(arg)
			if not arg then
				return
			end

			if arg:IsA("Tool") or arg:IsA("Model") or arg:IsA("BasePart") then
				local v4 = string.lower(arg.Name or "")

				if v4:find("gun") or v4:find("pistol") or v4:find("surgerygun") or arg:GetAttribute("IsGun") then
					if arg:FindFirstChildWhichIsA("ProximityPrompt", true) or v4:find("gun") then
						table.insert(tbl3, arg)
					end
				end
			end
		end

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant:IsA("ProximityPrompt") then
				local v4 = string.lower(descendant.Name or "")
				local parent = descendant.Parent
				local str

				if parent then
					str = string.lower(descendant.Parent.Name or "")
				else
					str = parent
				end

				str = str or ""

				if v4:find("gun") or str:find("gun") or str:find("pistol") or descendant.ActionText and string.lower(tostring(descendant.ActionText)):find("pick") then
					table.insert(tbl3, descendant.Parent or descendant)
				end
			end

			fn20(descendant)
		end

		return tbl3
	end

	MainModule.toggle_dropped_gun_esp = function(arg)
		local droppedGunESPEnabled = arg and true or false
		MainModule.DroppedGunESPEnabled = droppedGunESPEnabled
		local v4 = pairs
		local droppedGunESPObjects = MainModule.DroppedGunESPObjects or {}

		for _, droppedGunESPObject in v4(droppedGunESPObjects) do
			pcall(function()
				if type(droppedGunESPObject) == "table" then
					if droppedGunESPObject.h then
						droppedGunESPObject.h:Destroy()
					end

					if droppedGunESPObject.bb then
						droppedGunESPObject.bb:Destroy()
					end

					if droppedGunESPObject.beam then
						droppedGunESPObject.beam:Destroy()
					end

					if droppedGunESPObject.a0 then
						droppedGunESPObject.a0:Destroy()
					end

					if droppedGunESPObject.a1 then
						droppedGunESPObject.a1:Destroy()
					end
				elseif droppedGunESPObject and droppedGunESPObject.Destroy then
					droppedGunESPObject:Destroy()
				end
			end)
		end

		MainModule.DroppedGunESPObjects = {}

		if MainModule.DroppedGunESPConn then
			pcall(function()
				if typeof(MainModule.DroppedGunESPConn) == "RBXScriptConnection" then
					MainModule.DroppedGunESPConn:Disconnect()
				else
					task.cancel(MainModule.DroppedGunESPConn)
				end
			end)

			MainModule.DroppedGunESPConn = nil
		end

		if not droppedGunESPEnabled then
			if fn4 then
				fn4()
			end

			return true
		end

		local function fn20()
			if not MainModule.DroppedGunESPEnabled then
				return
			end
			local v5 = fn19()

			for _, v6 in ipairs(v5) do
				local isBasePart = v6:IsA("BasePart") and v6 or v6:FindFirstChildWhichIsA("BasePart", true)

				if isBasePart and not MainModule.DroppedGunESPObjects[isBasePart] then
					local highlight = Instance.new("Highlight")
					v6 = v6:IsA("Model") and v6 or isBasePart
					highlight.Adornee = v6
					highlight.FillColor = Color3.fromRGB(255, 180, 0)
					highlight.OutlineColor = Color3.fromRGB(255, 220, 50)
					highlight.FillTransparency = 0.4
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.Parent = isBasePart
					local billboardGui = Instance.new("BillboardGui")
					billboardGui.Size = UDim2.new(0, 90, 0, 24)
					billboardGui.AlwaysOnTop = true
					billboardGui.Adornee = isBasePart
					billboardGui.Parent = isBasePart
					local textLabel = Instance.new("TextLabel")
					textLabel.Size = UDim2.new(1, 0, 1, 0)
					textLabel.BackgroundTransparency = 1
					textLabel.Text = "GUN"
					textLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
					textLabel.Font = Enum.Font.GothamBold
					textLabel.TextScaled = true
					textLabel.Parent = billboardGui
					local attachment = Instance.new("Attachment")
					attachment.Parent = isBasePart
					local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
					local attachment2 = Instance.new("Attachment")

					if humanoidRootPart then
						attachment2.Parent = humanoidRootPart
					end

					local beam = Instance.new("Beam")
					beam.Attachment0 = attachment
					beam.Attachment1 = attachment2
					beam.Color = ColorSequence.new(Color3.fromRGB(255, 180, 0))
					beam.Width0 = 0.12
					beam.Width1 = 0.12
					beam.FaceCamera = true
					beam.Parent = isBasePart
					MainModule.DroppedGunESPObjects[isBasePart] = { h = highlight, bb = billboardGui, beam = beam, a0 = attachment, a1 = attachment2 }
				end
			end
		end

		fn20()

		MainModule.DroppedGunESPConn = task.spawn(function()
			while MainModule.DroppedGunESPEnabled do
				pcall(fn20)
				task.wait(5)
			end
		end)

		if fn4 then
			fn4()
		end

		return true
	end

	MainModule.toggle_auto_tp_dropped_gun = function(arg)
		local autoTPDroppedGunEnabled = arg and true or false
		MainModule.AutoTPDroppedGunEnabled = autoTPDroppedGunEnabled

		if MainModule.AutoTPDroppedGunConn then
			pcall(function()
				if typeof(MainModule.AutoTPDroppedGunConn) == "RBXScriptConnection" then
					MainModule.AutoTPDroppedGunConn:Disconnect()
				else
					task.cancel(MainModule.AutoTPDroppedGunConn)
				end
			end)

			MainModule.AutoTPDroppedGunConn = nil
		end

		if not autoTPDroppedGunEnabled then
			if fn4 then
				fn4()
			end

			return true
		end

		MainModule.AutoTPDroppedGunConn = task.spawn(function()
			while MainModule.AutoTPDroppedGunEnabled do
				pcall(function()
					local v4 = fn19()
					local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
					if not humanoidRootPart then
						return
					end
					local n = 1e9
					local v5 = nil

					for _, v6 in ipairs(v4) do
						local isBasePart = v6:IsA("BasePart") and v6 or v6:FindFirstChildWhichIsA("BasePart", true)

						if isBasePart then
							local magnitude = (isBasePart.Position - humanoidRootPart.Position).Magnitude

							if magnitude < n then
								n = magnitude
								v5 = v6
							end
						end
					end

					if v5 then
						local isBasePart = v5:IsA("BasePart") and v5 or v5:FindFirstChildWhichIsA("BasePart", true)

						if isBasePart then
							humanoidRootPart.CFrame = CFrame.new(isBasePart.Position + Vector3.new(0, 3, 0))
							local proximityPrompt = v5:FindFirstChildWhichIsA("ProximityPrompt", true) or isBasePart:FindFirstChildWhichIsA("ProximityPrompt", true)

							if proximityPrompt and fireproximityprompt then
								pcall(fireproximityprompt, proximityPrompt)
							end
						end
					end
				end)

				task.wait(5)
			end
		end)

		if fn4 then
			fn4()
		end

		return true
	end

	MainModule._MovecheckAutoUsers = MainModule._MovecheckAutoUsers or 0
	MainModule._MovecheckUserEnabled = false

	MainModule.HSX_HasFasterSprint56 = function()
		local ok, result = pcall(function()
			local boosts = localPlayer2:FindFirstChild("Boosts")
			boosts = boosts and boosts:FindFirstChild("Faster Sprint")
			if not boosts then
				return false
			end

			if (tonumber(boosts.Value or boosts:GetAttribute("Level") or boosts:GetAttribute("Lvl")) or 0) >= 5 then
				return true
			end

			for _, child in ipairs(boosts:GetChildren()) do
				if child:IsA("NumberValue") or child:IsA("IntValue") then
					if tonumber(child.Value) and tonumber(child.Value) >= 5 then
						return true
					end
				end
			end

			return false
		end)

		return ok and result
	end

		MainModule.HSX_MovecheckAutoStart = function()
			if not MainModule.HSX_HasFasterSprint56() then
				return
			end
			MainModule._MovecheckAutoUsers = (MainModule._MovecheckAutoUsers or 0) + 1

			if not MainModule.MovecheckBypassEnabled then
				pcall(function()
					MainModule.toggle_movecheck_bypass(true)

					if MainModule.ToggleRefs and MainModule.ToggleRefs.MovecheckBypass then
						MainModule.ToggleRefs.MovecheckBypass:SetValue(true)
					end
				end)

				pcall(function()
					fn2("Movechecks bypass enabled automatically", "", 1)
				end)
			end
		end

	MainModule.HSX_MovecheckAutoStop = function()
		MainModule._MovecheckAutoUsers = math.max(0, (MainModule._MovecheckAutoUsers or 0) - 1)

		if MainModule._MovecheckAutoUsers <= 0 and not MainModule._MovecheckUserEnabled then
			if MainModule.MovecheckBypassEnabled then
				pcall(function()
					MainModule.toggle_movecheck_bypass(false)

					if MainModule.ToggleRefs and MainModule.ToggleRefs.MovecheckBypass then
						MainModule.ToggleRefs.MovecheckBypass:SetValue(false)
					end
				end)
			end
		end
	end

	local function fn20()
		local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
		local dashRequest = remotes and remotes:FindFirstChild("DashRequest")
		if not dashRequest then
			return
		end

		task.spawn(function()
			while MainModule.MovecheckBypassEnabled do
				pcall(function()
					dashRequest:FireServer(nil)
				end)

				task.wait(0.1)
			end
		end)
	end

	local function fn21()
		pcall(function()
			local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
			remotes = remotes and remotes:FindFirstChild("Miau")

			if remotes then
				remotes:Destroy()
			end
		end)
	end

	MainModule.OrbitKillauraEnabled = false
	MainModule.OrbitKillauraConn = nil
	MainModule.OrbitRadius = 3
	MainModule._DeathAnimId = "rbxassetid://82747596610040"
	MainModule._DeathAnimConns = MainModule._DeathAnimConns or {}

	MainModule.HSX_StartDeathAnimGuard = function(arg, arg2)
		if MainModule._DeathAnimConns[arg] then
			pcall(function()
				MainModule._DeathAnimConns[arg]:Disconnect()
			end)

			MainModule._DeathAnimConns[arg] = nil
		end

		local function fn22(arg3)
			if not arg3 then
				return
			end
			local humanoid = arg3:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return
			end

			if MainModule._DeathAnimConns[arg] then
				pcall(function()
					MainModule._DeathAnimConns[arg]:Disconnect()
				end)
			end

			MainModule._DeathAnimConns[arg] = humanoid.AnimationPlayed:Connect(function(arg4)
				local ok, result = pcall(function()
					return arg4.Animation
				end)

				if not ok or not result then
					return
				end
				local str = tostring(result.AnimationId or "")

				if str == MainModule._DeathAnimId or str:find("82747596610040") then
					if MainModule[arg] then
						MainModule[arg] = false

						pcall(function()
							if arg2 then
								arg2()
							end
						end)

						pcall(function()
							fn2("Disabled the feature to prevent die", "", 1.2)
						end)
					end
				end
			end)
		end

		fn22(localPlayer2.Character)

		MainModule._DeathAnimConns[arg .. "_ca"] = localPlayer2.CharacterAdded:Connect(function(character)
			task.wait(0.2)

			if MainModule[arg] then
				fn22(character)
			end
		end)
	end

	MainModule.HSX_StopDeathAnimGuard = function(arg)
		if MainModule._DeathAnimConns[arg] then
			pcall(function()
				MainModule._DeathAnimConns[arg]:Disconnect()
			end)

			MainModule._DeathAnimConns[arg] = nil
		end

		if MainModule._DeathAnimConns[arg .. "_ca"] then
			pcall(function()
				MainModule._DeathAnimConns[arg .. "_ca"]:Disconnect()
			end)

			MainModule._DeathAnimConns[arg .. "_ca"] = nil
		end
	end

	MainModule.OrbitSpeed = 10

	local function fn22()
		local character = localPlayer2.Character
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			return nil
		end
		local position = character.HumanoidRootPart.Position
		local huge = math.huge
		local v4 = nil

		for _, player in ipairs(Players2:GetPlayers()) do
			if player ~= localPlayer2 and player.Character then
				local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
				local humanoid = player.Character:FindFirstChild("Humanoid")

				if humanoidRootPart and humanoid and humanoid.Health > 0 and not player.Character:FindFirstChild("Dead") then
					local magnitude = (position - humanoidRootPart.Position).Magnitude

					if magnitude < huge then
						huge = magnitude
						v4 = player
					end
				end
			end
		end

		return v4
	end

	MainModule.toggle_orbit_killaura = function(arg)
		local orbitKillauraEnabled = arg and true or false

		if orbitKillauraEnabled then
			local flag = false

			pcall(function()
				flag = MainModule.is_game_active and (MainModule.is_game_active("SkySquidGame") or MainModule.is_game_active("SquidGame"))
			end)

			local flag2 = not flag

			if flag2 then
				pcall(function()
					local values = workspace:FindFirstChild("Values")
					values = values and values:FindFirstChild("CurrentGame")

					if (values and tostring(values.Value) or ""):lower():find("squid") then
						flag = true
					end
				end)
			end

			if flag2 then
				pcall(function()
					fn2("Orbit Kill Aura", "Only works in SkySquidGame / SquidGame", 1.2)
				end)

				if fn4 then
					fn4()
				end

				return false
			end
		end

		MainModule.OrbitKillauraEnabled = orbitKillauraEnabled

		if MainModule.OrbitKillauraConn then
			pcall(function()
				MainModule.OrbitKillauraConn:Disconnect()
			end)

			MainModule.OrbitKillauraConn = nil
		end

		if not orbitKillauraEnabled then
			MainModule.HSX_StopDeathAnimGuard("OrbitKillauraEnabled")

			if fn4 then
				fn4()
			end

			return true
		end

		pcall(fn21)

		MainModule.HSX_StartDeathAnimGuard("OrbitKillauraEnabled", function()
			if MainModule.OrbitKillauraConn then
				pcall(function()
					MainModule.OrbitKillauraConn:Disconnect()
				end)

				MainModule.OrbitKillauraConn = nil
			end

			pcall(function()
				if MainModule.ToggleRefs and MainModule.ToggleRefs.OrbitKillaura then
					MainModule.ToggleRefs.OrbitKillaura:SetValue(false)
				end
			end)
		end)

		MainModule.OrbitKillauraConn = RunService2.Heartbeat:Connect(function()
			if not MainModule.OrbitKillauraEnabled then
				return
			end
			local v4 = fn22()
			if not v4 or not v4.Character then
				return
			end
			local humanoidRootPart = v4.Character:FindFirstChild("HumanoidRootPart")
			local humanoid = v4.Character:FindFirstChildOfClass("Humanoid")
			if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
				return
			end
			local character = localPlayer2.Character
			if not character then
				return
			end
			local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart2 then
				return
			end
			local n = tick() * (MainModule.OrbitSpeed or 10) % 6.2831853071795862
			local orbitRadius = MainModule.OrbitRadius or 3
			local position = humanoidRootPart.Position
			local n2 = 0

			if MainModule.OrbitAntiHitEnabled then
				local tbl3 = {
					["79649041083405"] = true,
					["73242877658272"] = true,
					["85793691404836"] = true,
					["86197206792061"] = true,
					["99157505926076"] = true,
				}

				local function fn23(arg2)
					local match = tostring(arg2 or ""):match("(%d+)")
					return match and tbl3[match] or false
				end

				local flag = false

				pcall(function()
					local character2 = v4.Character
					if not character2 then
						return
					end
					local humanoid2 = character2:FindFirstChildOfClass("Humanoid")

					local function fn24(arg2)
						local v5 = pairs
						arg2 = arg2 or {}

						for _, v6 in v5(arg2) do
							local ok, result = pcall(function()
								return v6.IsPlaying
							end)

							if ok and result then
								local ok2, result2 = pcall(function()
									return v6.Animation
								end)

								if ok2 and result2 and fn23(result2.AnimationId) then
									return true
								end

								local ok3, result3 = pcall(function()
									return v6.AnimationId
								end)

								if ok3 and fn23(result3) then
									return true
								end
							end
						end

						return false
					end

					if humanoid2 then
						flag = fn24(humanoid2:GetPlayingAnimationTracks())

						if not flag then
							local animator = humanoid2:FindFirstChildOfClass("Animator")

							if animator then
								flag = fn24(animator:GetPlayingAnimationTracks())
							end
						end
					end

					if not flag then
						for _, descendant in ipairs(character2:GetDescendants()) do
							if descendant:IsA("Animation") and fn23(descendant.AnimationId) then
								flag = true
								break
							end
						end
					end
				end)

				if flag then
					n2 = 16
				end
			end

			local n3 = position.Y + n2
			humanoidRootPart2.CFrame = CFrame.new(Vector3.new(position.X + math.cos(n) * orbitRadius, n3, position.Z + math.sin(n) * orbitRadius), humanoidRootPart.Position)
		end)

		if fn4 then
			fn4()
		end

		return true
	end

	MainModule.set_orbit_radius = function(arg)
		MainModule.OrbitRadius = math.clamp(tonumber(arg) or 3, 1, 10)
	end

	MainModule.set_orbit_speed = function(arg)
		MainModule.OrbitSpeed = math.clamp(tonumber(arg) or 10, 1, 10)
	end

	MainModule.AttachTargetOPEnabled = false
	MainModule.AttachTargetOPTask = nil
	MainModule.FlingTargetEnabled = false
	MainModule.FlingTargetTask = nil
	MainModule.BypassedOpFlyEnabled = false

	MainModule.toggle_attach_target_op = function()
		if fn4 then
			fn4()
		end

		return false
	end

	MainModule.toggle_fling_target = function()
		if fn4 then
			fn4()
		end

		return false
	end

	local function fn23(arg)
		return arg and (arg:FindFirstChild("HumanoidRootPart") or arg:FindFirstChild("Torso") or arg.PrimaryPart)
	end

	MainModule._OpFly = {
		flying = false,
		keyDown = nil,
		keyUp = nil,
		m1 = nil,
		m2 = nil,
		velName = "HSX_OpFlyVel",
		gyroName = "HSX_OpFlyGyro",
		speed = 1,
	}

	MainModule.toggle_bypassed_op_fly = function(arg)
		local bypassedOpFlyEnabled = arg and true or false

		if bypassedOpFlyEnabled then
			MainModule._MovecheckFromAuto = true
			pcall(MainModule.HSX_MovecheckAutoStart)
			MainModule._MovecheckFromAuto = false
		else
			pcall(MainModule.HSX_MovecheckAutoStop)
		end

		if bypassedOpFlyEnabled then
			local flag = false

			pcall(function()
				local isGameActive = MainModule.is_game_active
				local SkySquidGame

				if isGameActive then
					SkySquidGame = MainModule.is_game_active("SkySquidGame") or MainModule.is_game_active("SquidGame")
				else
					SkySquidGame = isGameActive
				end

				flag = SkySquidGame
			end)

			local flag2 = not flag

			if flag2 then
				pcall(function()
					local values = workspace:FindFirstChild("Values")
					values = values and values:FindFirstChild("CurrentGame")

					if (values and tostring(values.Value) or ""):lower():find("squid") then
						flag = true
					end
				end)
			end

			if flag2 then
				flag = pcall

				flag(function()
					fn2("Bypassed op fly", "Only works in SkySquidGame / SquidGame", 1.2)
				end)

				flag = fn4

				if flag then
					flag = fn4
					flag()
				end

				return false
			end
		end

		MainModule.BypassedOpFlyEnabled = bypassedOpFlyEnabled
		local opFly = MainModule._OpFly

		local function fn24()
			opFly.flying = false

			if opFly.keyDown then
				pcall(function()
					opFly.keyDown:Disconnect()
				end)

				opFly.keyDown = nil
			end

			if opFly.keyUp then
				pcall(function()
					opFly.keyUp:Disconnect()
				end)

				opFly.keyUp = nil
			end

			pcall(function()
				local humanoid = localPlayer2.Character and localPlayer2.Character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.PlatformStand = false
				end
			end)
		end

		local function fn25()
			opFly.flying = false

			if opFly.m1 then
				pcall(function()
					opFly.m1:Disconnect()
				end)

				opFly.m1 = nil
			end

			if opFly.m2 then
				pcall(function()
					opFly.m2:Disconnect()
				end)

				opFly.m2 = nil
			end

			pcall(function()
				local v4 = fn23(localPlayer2.Character)

				if v4 then
					local v5 = v4:FindFirstChild(opFly.velName)

					if v5 then
						v5:Destroy()
					end

					local v6 = v4:FindFirstChild(opFly.gyroName)

					if v6 then
						v6:Destroy()
					end
				end

				local humanoid = localPlayer2.Character and localPlayer2.Character:FindFirstChildOfClass("Humanoid")

				if humanoid then
					humanoid.PlatformStand = false
				end
			end)
		end

		if not bypassedOpFlyEnabled then
			fn24()
			fn25()

			if fn4 then
				fn4()
			end

			return true
		end

		fn21()
		local flag = false

		pcall(function()
			flag = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		end)

		if flag then
			fn25()
			opFly.flying = true
			local v4 = fn23(localPlayer2.Character)

			if not v4 then
				if fn4 then
					fn4()
				end

				return false
			end

			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Name = opFly.velName
			bodyVelocity.MaxForce = Vector3.zero
			bodyVelocity.Velocity = Vector3.new()
			bodyVelocity.Parent = v4
			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.Name = opFly.gyroName
			bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			bodyGyro.P = 1000
			bodyGyro.D = 50
			bodyGyro.Parent = v4
			local ControlModule = nil

			pcall(function()
				ControlModule = require(localPlayer2.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
			end)

			opFly.m2 = RunService2.RenderStepped:Connect(function()
				if not MainModule.BypassedOpFlyEnabled then
					return
				end
				v4 = fn23(localPlayer2.Character)
				if not v4 then
					return
				end
				local v5 = v4:FindFirstChild(opFly.velName)
				local v6 = v4:FindFirstChild(opFly.gyroName)
				local humanoid = localPlayer2.Character and localPlayer2.Character:FindFirstChildOfClass("Humanoid")
				if not (v5 and v6 and humanoid) then
					return
				end
				v5.MaxForce = Vector3.new(9e9, 9e9, 9e9)
				v6.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
				humanoid.PlatformStand = true
				local currentCamera = workspace.CurrentCamera
				v6.CFrame = currentCamera.CFrame
				v5.Velocity = Vector3.new()
				local vector = Vector3.new()

				pcall(function()
					if ControlModule then
						vector = ControlModule:GetMoveVector()
					end
				end)

				local n = (opFly.speed or 1) * 50

				if vector.X ~= 0 then
					v5.Velocity = v5.Velocity + currentCamera.CFrame.RightVector * vector.X * n
				end

				if vector.Z ~= 0 then
					v5.Velocity = v5.Velocity - currentCamera.CFrame.LookVector * vector.Z * n
				end
			end)
		else
			fn24()
			local character = localPlayer2.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local v4 = fn23(character)

			if not v4 or not humanoid then
				if fn4 then
					fn4()
				end

				return false
			end

			local tbl3 = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 }
			local tbl4 = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 }
			local n = 0
			local speed = opFly.speed or 1
			opFly.flying = true
			local bodyGyro = Instance.new("BodyGyro")
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyGyro.P = 90000
			bodyGyro.Parent = v4
			bodyVelocity.Parent = v4
			bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			bodyGyro.CFrame = v4.CFrame
			bodyVelocity.Velocity = Vector3.zero
			bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

			task.spawn(function()
				while true do
					task.wait()
					local currentCamera = workspace.CurrentCamera
					humanoid.PlatformStand = true

					if tbl3.L + tbl3.R ~= 0 or tbl3.F + tbl3.B ~= 0 or tbl3.Q + tbl3.E ~= 0 then
						n = 50
					elseif n ~= 0 then
						n = 0
					end

					if tbl3.L + tbl3.R ~= 0 or tbl3.F + tbl3.B ~= 0 or tbl3.Q + tbl3.E ~= 0 then
						local position = currentCamera.CFrame.Position
						bodyVelocity.Velocity = (currentCamera.CFrame.LookVector * (tbl3.F + tbl3.B) + currentCamera.CFrame * CFrame.new(tbl3.L + tbl3.R, (tbl3.F + tbl3.B + tbl3.Q + tbl3.E) * 0.2, 0).Position - position) * n
						tbl4 = { F = tbl3.F, B = tbl3.B, L = tbl3.L, R = tbl3.R, Q = tbl3.Q, E = tbl3.E }
					elseif n ~= 0 then
						local position = currentCamera.CFrame.Position
						bodyVelocity.Velocity = (currentCamera.CFrame.LookVector * (tbl4.F + tbl4.B) + currentCamera.CFrame * CFrame.new(tbl4.L + tbl4.R, (tbl4.F + tbl4.B + tbl4.Q + tbl4.E) * 0.2, 0).Position - position) * n
					else
						bodyVelocity.Velocity = Vector3.zero
					end

					bodyGyro.CFrame = currentCamera.CFrame
					if not (not opFly.flying or not MainModule.BypassedOpFlyEnabled) then
						continue
					end
					break
				end

				pcall(function()
					bodyGyro:Destroy()
				end)

				pcall(function()
					bodyVelocity:Destroy()
				end)

				pcall(function()
					humanoid.PlatformStand = false
				end)
			end)

			opFly.keyDown = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.KeyCode == Enum.KeyCode.W then
					tbl3.F = speed
				elseif input.KeyCode == Enum.KeyCode.S then
					tbl3.B = -speed
				elseif input.KeyCode == Enum.KeyCode.A then
					tbl3.L = -speed
				elseif input.KeyCode == Enum.KeyCode.D then
					tbl3.R = speed
				elseif input.KeyCode == Enum.KeyCode.E then
					tbl3.Q = speed * 2
				elseif input.KeyCode == Enum.KeyCode.Q then
					tbl3.E = -speed * 2
				end
			end)

			opFly.keyUp = UserInputService.InputEnded:Connect(function(input)
				if input.KeyCode == Enum.KeyCode.W then
					tbl3.F = 0
				elseif input.KeyCode == Enum.KeyCode.S then
					tbl3.B = 0
				elseif input.KeyCode == Enum.KeyCode.A then
					tbl3.L = 0
				elseif input.KeyCode == Enum.KeyCode.D then
					tbl3.R = 0
				elseif input.KeyCode == Enum.KeyCode.E then
					tbl3.Q = 0
				elseif input.KeyCode == Enum.KeyCode.Q then
					tbl3.E = 0
				end
			end)
		end

		if fn4 then
			fn4()
		end

		return true
	end

	MainModule.MovecheckBypassEnabled = false
	MainModule.MovecheckBypassTask = nil

	MainModule.toggle_movecheck_bypass = function(arg)
		local movecheckBypassEnabled = arg and true or false

		if not movecheckBypassEnabled then
			MainModule._MovecheckUserEnabled = false
			MainModule._MovecheckAutoUsers = 0
		elseif not MainModule._MovecheckFromAuto then
			MainModule._MovecheckUserEnabled = true
		end

		movecheckBypassEnabled = movecheckBypassEnabled and true or false

		if movecheckBypassEnabled then
			local boosts = localPlayer2:FindFirstChild("Boosts")
			local fasterSprint = boosts and boosts:FindFirstChild("Faster Sprint")
			local n = 0

			pcall(function()
				if fasterSprint then
					n = tonumber(fasterSprint.Value) or tonumber(fasterSprint:GetAttribute("Level")) or 0

					if typeof(fasterSprint) == "Instance" then
						local level = fasterSprint:FindFirstChild("Level") or fasterSprint:FindFirstChild("Value")

						if level and level.Value then
							n = tonumber(level.Value) or n
						end
					end
				end

				local attribute = localPlayer2:GetAttribute("FasterSprintLevel") or localPlayer2:GetAttribute("FasterSprint")

				if attribute then
					n = math.max(n, tonumber(attribute) or 0)
				end
			end)

			pcall(function()
				if boosts then
					for _, child in ipairs(boosts:GetChildren()) do
						if string.find(string.lower(child.Name), "faster") then
							local n2 = tonumber(child.Value) or tonumber(child:GetAttribute("Level")) or 0

							if n < n2 then
								n = n2
							end

							if child:IsA("IntValue") or child:IsA("NumberValue") then
								if n < child.Value then
									n = child.Value
								end
							end
						end
					end
				end
			end)

			if n < 5 then
				pcall(function()
					fn2("Movechecks Bypass", "You need faster sprint lvl 5 or 6 to use this function. PS: you can easily get 5 or 6 lvl faster sprint with guard autofarm and permanent guard", 2.5)
				end)

				if MainModule.ToggleRefs and MainModule.ToggleRefs.MovecheckBypass then
					pcall(function()
						MainModule.ToggleRefs.MovecheckBypass:SetValue(false)
					end)
				end

				if fn4 then
					fn4()
				end

				return false
			end
		end

		MainModule.MovecheckBypassEnabled = movecheckBypassEnabled

		if not movecheckBypassEnabled then
			if fn4 then
				fn4()
			end

			return true
		end

		fn20()

		if fn4 then
			fn4()
		end

		return true
	end

	MainModule.PeabertSilentEnabled = false

	MainModule.toggle_peabert_silent = function(arg)
		MainModule.PeabertSilentEnabled = arg and true or false
		pcall(fn14)

		if fn4 then
			fn4()
		end

		return true
	end
end

MainModule.PeabertEnabled = false
MainModule.PeabertShotsPerTick = 15
MainModule.PeabertConnection = nil

MainModule.start_peabert_loop = function()
	if MainModule.PeabertConnection then
		MainModule.PeabertConnection:Disconnect()
		MainModule.PeabertConnection = nil
	end

	MainModule.PeabertConnection = RunService2.RenderStepped:Connect(function()
		if not MainModule.PeabertEnabled then
			return
		end
		local v2 = MainModule.get_character()
		local backpack = localPlayer2:FindFirstChild("Backpack")
		local v3 = nil

		if v2 then
			v3 = nil

			for _, child in ipairs(v2:GetChildren()) do
				if child:IsA("Tool") and (child:GetAttribute("Gun") or child:FindFirstChild("GunScript") or string.lower(child.Name):find("gun")) then
					v3 = child
					break
				else
					v3 = nil
				end
			end
		end

		if not v3 and backpack then
			for _, child in ipairs(backpack:GetChildren()) do
				if child:IsA("Tool") and (child:GetAttribute("Gun") or child:FindFirstChild("GunScript") or string.lower(child.Name):find("gun")) then
					v3 = child
					break
				end
			end
		end

		if not v3 then
			return
		end
		local tbl2 = {}
		local live = workspace:FindFirstChild("Live")

		if live then
			for i = 1, 10 do
				local str = "EvilPeabert1_" .. i
				local v4 = live:FindFirstChild(str)

				if v4 and not v4:FindFirstChild("Dead") then
					tbl2[str] = "Head"
				end
			end

			for _, child in ipairs(live:GetChildren()) do
				if not child:FindFirstChild("Dead") then
					local name = child.Name

					if name:match("^PeabertSpawn%d+$") then
						local num = tonumber(name:match("%d+"))

						if num and num >= 1 and num <= 31 then
							tbl2[name] = "Head"
						end
					end

					if name:lower():find("peabert") or name:lower():find("evilpeabert") then
						tbl2[name] = "Head"
					end
				end
			end
		end

		for _, descendant in ipairs(workspace:GetDescendants()) do
			if (descendant:IsA("Model") or descendant:IsA("BasePart")) and not descendant:FindFirstChild("Dead") then
				local name = descendant.Name

				if name:match("^EvilPeabert1_%d+$") or name:match("^PeabertSpawn%d+$") or name:lower():find("peabert") then
					tbl2[name] = "Head"
				end
			end
		end

		if next(tbl2) ~= nil then
			local remotes = ReplicatedStorage:FindFirstChild("Remotes")

			if remotes then
				local firedGunClient = remotes:FindFirstChild("FiredGunClient")

				if firedGunClient then
					if workspace:FindFirstChild("StairWalkWay") and workspace.StairWalkWay:FindFirstChild("Part") then
					end

					local tbl3 = {}

					local tbl4 = {
						ClientRayNormal = Vector3.new(0, 1, 0),
						FiredGun = true,
						SecondaryHitTargets = {},
						ClientRayInstance = Vector3.new,
						ClientRayPosition = Vector3.zero,
						bulletCF = CFrame.new(),
						HitTargets = tbl2,
						bulletSizeC = Vector3.new(0.01, 0.01, 5),
						NoMuzzleFX = true,
						FirePosition = Vector3.zero,
					}

					tbl3[1] = v3
					tbl3[2] = tbl4

					for i = 1, MainModule.PeabertShotsPerTick do
						pcall(function()
							firedGunClient:FireServer(unpack(tbl3))
						end)
					end
				end
			end
		end
	end)
end

MainModule.toggle_peabert_kill = function(peabertEnabled)
	MainModule.PeabertEnabled = peabertEnabled

	if MainModule.PeabertConnection then
		MainModule.PeabertConnection:Disconnect()
		MainModule.PeabertConnection = nil
	end

	if peabertEnabled then
		MainModule.start_peabert_loop()
	end

	fn4()
end

MainModule.set_peabert_shots_per_tick = function(peabertShotsPerTick)
	MainModule.PeabertShotsPerTick = peabertShotsPerTick
end

MainModule.FakeLightningAwakeningEnabled = false
MainModule._LA_Inited = false

MainModule.toggle_fake_lightning_awakening = function(arg)
	MainModule.FakeLightningAwakeningEnabled = arg and true or false

	if not arg then
		pcall(function()
			local backpack = localPlayer2:FindFirstChild("Backpack")

			if backpack then
				local lightningAwakening = backpack:FindFirstChild("LIGHTNING AWAKENING")

				if lightningAwakening then
					lightningAwakening:Destroy()
				end
			end

			local character = localPlayer2.Character

			if character then
				local lightningAwakening = character:FindFirstChild("LIGHTNING AWAKENING")

				if lightningAwakening then
					lightningAwakening:Destroy()
				end
			end
		end)

		fn4()
		return true
	end

	if not MainModule._LA_Inited then
		MainModule._LA_Inited = true
		MainModule._LA_Start()
	end

	fn4()
	return true
end

MainModule._LA_Start = function()
	local Players3 = game:GetService("Players")
	local RunService3 = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local Debris = game:GetService("Debris")
	local localPlayer3 = Players3.LocalPlayer
	local currentCamera = workspace.CurrentCamera
	local lightninggodawakening = ReplicatedStorage2:FindFirstChild("Effects") and ReplicatedStorage2.Effects:FindFirstChild("SetupParts") and ReplicatedStorage2.Effects.SetupParts:FindFirstChild("CustomEffectsFolders") and ReplicatedStorage2.Effects.SetupParts.CustomEffectsFolders:FindFirstChild("LIGHTNINGGODAWAKENING")
	local animations = ReplicatedStorage2:FindFirstChild("Animations")
	local lightningGodAwakening = animations and animations:FindFirstChild("Abilities") and animations.Abilities:FindFirstChild("LightningGodAwakening")
	local lightningAwakening = ReplicatedStorage2:FindFirstChild("CustomCameraModules") and ReplicatedStorage2.CustomCameraModules:FindFirstChild("LightningAwakening")
	local modules = ReplicatedStorage2:FindFirstChild("Modules")
	local Effects = nil
	local EffectsSecond = nil

	pcall(function()
		Effects = modules and modules:FindFirstChild("Effects") and require(modules.Effects)
	end)

	pcall(function()
		EffectsSecond = modules and modules:FindFirstChild("EffectsSecond") and require(modules.EffectsSecond)
	end)

	local v2 = nil

	if lightningAwakening then
		pcall(function()
			local module = require(lightningAwakening)

			if typeof(module) == "function" then
				v2 = module()
			else
				v2 = module
			end
		end)
	end

	local fov = v2 and v2.FOV
	local frames = v2 and v2.Frames

	if not fov then
		fov = {}

		for i = 1, 250 do
			fov[i] = 70
		end
	end

	if not frames then
		frames = {}

		for i = 1, 250 do
			frames[i] = { 0, 2, -8, -1, 0, 0, 0, 1, 0, 0, 0, -1 }
		end
	end

	local flag = false
	local flag2 = false
	local flag3 = false

	local function fn8(arg)
		return CFrame.new(arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8], arg[9], arg[10], arg[11], arg[12])
	end

	local function fn9(arg, parent, part0, c0)
		if not arg or not parent or not part0 then
			return nil
		end
		local clone = arg:Clone()

		if clone:IsA("BasePart") then
			clone.Anchored = false
			clone.CanCollide = false
			clone.Massless = true
			local weld = Instance.new("Weld")
			weld.Part0 = part0
			weld.Part1 = clone
			c0 = c0 or CFrame.new()
			weld.C0 = c0
			weld.Parent = clone
			clone.Parent = parent
		elseif clone:IsA("Model") then
			clone.Parent = parent

			for _, v3 in clone:GetDescendants() do
				if v3 and v3:IsA("BasePart") then
					v3.Anchored = false
					v3.CanCollide = false
					v3.Massless = true
					local weld = Instance.new("Weld")
					weld.Part0 = part0
					weld.Part1 = v3
					weld.C0 = c0 or CFrame.new()
					weld.Parent = v3
				end
			end
		end

		for _, v3 in clone:GetDescendants() do
			if v3 then
				if v3:IsA("ParticleEmitter") then
					v3.Enabled = true
				end

				if v3:IsA("PointLight") then
					v3.Enabled = true
				end
			end
		end

		return clone
	end

	local function fn10(arg)
		if not arg:FindFirstChild("HumanoidRootPart") then
			return nil
		end
		local tbl2 = {}

		for _, v3 in arg:GetDescendants() do
			tbl2[v3] = v3.Archivable
			v3.Archivable = true
		end

		local archivable = arg.Archivable
		arg.Archivable = true

		local ok, result = pcall(function()
			return arg:Clone()
		end)

		arg.Archivable = archivable

		for k, v3 in tbl2, nil, nil do
			if k and k.Parent then
				pcall(function()
					k.Archivable = v3
				end)
			end
		end

		if not ok or not result then
			return nil
		end
		result.Name = "FakeChar_LightningAwakening"
		local tbl3 = {}

		for _, v3 in result:GetDescendants() do
			if v3:IsA("Script") or v3:IsA("LocalScript") or v3:IsA("Tool") or v3:IsA("ModuleScript") then
				table.insert(tbl3, v3)
			end
		end

		for _, v3 in tbl3, nil, nil do
			pcall(function()
				if v3 and v3.Parent then
					v3:Destroy()
				end
			end)
		end

		for _, v3 in result:GetDescendants() do
			if v3 and v3:IsA("BasePart") then
				pcall(function()
					v3.CanCollide = false
					v3.CanQuery = false
					v3.CanTouch = false
					v3.Massless = true
					v3.Anchored = false
				end)
			end
		end

		local humanoidRootPart = result:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			humanoidRootPart.Anchored = true
		end

		local humanoid = result:FindFirstChildOfClass("Humanoid")

		if humanoid then
			pcall(function()
				humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
				humanoid.BreakJointsOnDeath = false
				humanoid.RequiresNeck = false
			end)
		end

		result.Parent = workspace
		return result
	end

	local function fn11(arg, arg2, arg3, cFrame, anchored, arg4, arg5, arg6, arg7)
		if arg and arg.Parent then
			for _, v3 in arg:GetDescendants() do
				if v3 and v3:IsA("BasePart") then
					pcall(function()
						v3.LocalTransparencyModifier = 0
					end)
				end
			end
		end

		if arg3 and arg3.Parent then
			pcall(function()
				arg3.Anchored = false
				arg3.CFrame = cFrame
				arg3.Anchored = anchored
				arg3.AssemblyLinearVelocity = Vector3.zero
				arg3.AssemblyAngularVelocity = Vector3.zero
			end)
		end

		pcall(function()
			local v3 = currentCamera
			local v4 = arg7
			local custom

			if arg7 then
				custom = v4
			else
				custom = Enum.CameraType.Custom
			end

			v3.CameraType = custom
			TweenService:Create(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quad), { FieldOfView = arg6 or 70 }):Play()
		end)

		if arg2 and arg2.Parent then
			pcall(function()
				arg2.WalkSpeed = arg4 and arg4 > 0 and arg4 or 16
				arg2.JumpPower = arg5 and arg5 > 0 and arg5 or 50
				arg2.JumpHeight = 7.2
				arg2.AutoRotate = true
				arg2.PlatformStand = false
				arg2.Sit = false
				arg2:ChangeState(Enum.HumanoidStateType.GettingUp)
			end)
		end
	end

	local function fn12()
		if flag or flag2 or not MainModule.FakeLightningAwakeningEnabled then
			return
		end
		local character = localPlayer3.Character
		if not character then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local head = character:FindFirstChild("Head")
		if not humanoid or not humanoidRootPart then
			return
		end
		flag = true
		flag2 = true
		local fieldOfView = currentCamera.FieldOfView
		local cameraType = currentCamera.CameraType
		local walkSpeed = humanoid.WalkSpeed
		local jumpPower = humanoid.JumpPower
		local cFrame = humanoidRootPart.CFrame
		local anchored = humanoidRootPart.Anchored
		local flag4 = false

		local function fn13()
			if flag4 then
				return
			end
			flag4 = true

			pcall(function()
				fn11(character, humanoid, humanoidRootPart, cFrame, anchored, walkSpeed, jumpPower, fieldOfView, cameraType)
			end)

			flag = false

			task.delay(3, function()
				flag2 = false
			end)
		end

		if not pcall(function()
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
			humanoid.AutoRotate = false
			local v3 = fn10(character)

			if not v3 then
				error("Failed to create fake character")
			end

			local humanoidRootPart2 = v3:FindFirstChild("HumanoidRootPart")
			local humanoid2 = v3:FindFirstChildOfClass("Humanoid")
			local head2 = v3:FindFirstChild("Head")

			if humanoidRootPart2 then
				humanoidRootPart2.CFrame = cFrame
			end

			local tbl2 = {}

			for _, v4 in {
				"Head",
				"Torso",
				"Left Arm",
				"Right Arm",
				"Left Leg",
				"Right Leg",
				"UpperTorso",
				"LowerTorso",
				"LeftUpperArm",
				"RightUpperArm",
				"LeftLowerArm",
				"RightLowerArm",
				"LeftUpperLeg",
				"RightUpperLeg",
				"LeftLowerLeg",
				"RightLowerLeg",
				"LeftHand",
				"RightHand",
				"LeftFoot",
				"RightFoot",
			}, nil, nil do
				local v5 = v3:FindFirstChild(v4)

				if v5 and v5:IsA("BasePart") then
					table.insert(tbl2, v5)
				end
			end

			local function fn14()
				local tbl3 = {}

				for _, v4 in tbl2, nil, nil do
					if v4 and typeof(v4) == "Instance" and v4.Parent then
						table.insert(tbl3, v4)
					end
				end

				return tbl3
			end

			humanoidRootPart.Anchored = true
			task.wait()
			humanoidRootPart.CFrame = cFrame * CFrame.new(0, 150, 0)
			humanoidRootPart.Anchored = true

			for _, v4 in character:GetDescendants() do
				if v4 and v4:IsA("BasePart") then
					pcall(function()
						v4.LocalTransparencyModifier = 1
					end)
				end
			end

			local connection = RunService3.Heartbeat:Connect(function()
				if v3 and v3.Parent and humanoidRootPart2 and humanoidRootPart2.Parent then
					humanoidRootPart2.CFrame = cFrame
				end
			end)

			local connection2 = RunService3.Heartbeat:Connect(function()
				if flag and humanoidRootPart and humanoidRootPart.Parent then
					humanoidRootPart.CFrame = cFrame * CFrame.new(0, 150, 0)
					humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
				end
			end)

			local v4 = nil

			if lightningGodAwakening and humanoid2 then
				pcall(function()
					local animation = Instance.new("Animation")
					animation.AnimationId = lightningGodAwakening.AnimationId
					local animator = humanoid2:FindFirstChildOfClass("Animator")

					if not animator then
						local animator2 = Instance.new("Animator")
						animator2.Parent = humanoid2
						animator = animator2
					end

					v4 = animator:LoadAnimation(animation)
					v4.Priority = Enum.AnimationPriority.Action4
					v4:Play()
				end)
			end

			local sound = nil

			if humanoidRootPart2 then
				sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://103481331692768"
				sound.Volume = 2
				sound.RollOffMaxDistance = 300
				sound.Parent = humanoidRootPart2
				sound:Play()
			end

			local n = 0.016666666666666666
			local n2 = math.min(#frames, #fov)
			local n3 = n2 * n
			currentCamera.CameraType = Enum.CameraType.Scriptable
			local now = tick()
			local connection3 = nil

			connection3 = RunService3.RenderStepped:Connect(function()
				local n4 = (tick() - now) / n
				local n5 = math.floor(n4) + 1

				if n5 > n2 then
					pcall(function()
						connection3:Disconnect()
					end)

					return
				end

				local n6 = n4 - math.floor(n4)
				local n7 = math.min(n5 + 1, n2)
				currentCamera.FieldOfView = fov[n5] + (fov[n7] - fov[n5]) * n6
				currentCamera.CFrame = cFrame * fn8(frames[n5]):Lerp(fn8(frames[n7]), n6)
			end)

			if Effects and Effects.PrepFrame then
				local tbl3 = {}
				local impactFrames = ReplicatedStorage2:FindFirstChild("ImpactFrames")

				if impactFrames then
					local lightningGod = impactFrames:FindFirstChild("LightningGod")

					if lightningGod then
						for _, v5 in lightningGod:GetDescendants() do
							if v5 and v5.ClassName == "ImageLabel" then
								table.insert(tbl3, v5.Image)
							end
						end
					end
				end

				if #tbl3 > 0 then
					task.spawn(function()
						pcall(function()
							Effects.PrepFrame({ EffectName = "PrepFrame", ImageTable = tbl3 })
						end)
					end)
				end
			end

			pcall(function()
				if lightninggodawakening and lightninggodawakening:FindFirstChild("start") then
					for _, v5 in lightninggodawakening.start:GetChildren() do
						if v5 and v5:IsA("ParticleEmitter") then
							local name = v5.Name

							for _, v6 in fn14() do
								if v6.Name ~= "Head" or name ~= "Lightning1" then
									local clone = v5:Clone()
									clone.Enabled = true
									clone.Parent = v6

									task.delay(1.52, function()
										if clone and clone.Parent then
											clone.Enabled = false
										end
									end)

									Debris:AddItem(clone, 1.6)
								end
							end
						end
					end
				end
			end)

			task.delay(1.55, function()
				if not flag then
					return
				end

				pcall(function()
					if lightninggodawakening and lightninggodawakening:FindFirstChild("Aura1") and humanoidRootPart2 and humanoidRootPart2.Parent then
						local v5 = fn9(lightninggodawakening.Aura1, v3, humanoidRootPart2, CFrame.new(-0.386, -0.425, -0.538))

						if v5 then
							task.delay(1.33, function()
								if v5 and v5.Parent then
									for _, v6 in v5:GetDescendants() do
										if v6 and v6:IsA("ParticleEmitter") then
											v6.Enabled = false
										end
									end
								end
							end)

							Debris:AddItem(v5, 2.3)
						end
					end

					if lightninggodawakening and lightninggodawakening:FindFirstChild("eyes") and head2 and head2.Parent then
						for _, v5 in lightninggodawakening.eyes:GetChildren() do
							if v5 and v5:IsA("Attachment") then
								local clone = v5:Clone()
								clone.Parent = head2

								for _, v6 in clone:GetDescendants() do
									if v6 and v6:IsA("ParticleEmitter") then
										v6.Enabled = true
									end
								end

								Debris:AddItem(clone, 2.61)
							end
						end
					end
				end)
			end)

			task.delay(2.85, function()
				if not flag then
					return
				end

				pcall(function()
					if lightninggodawakening and lightninggodawakening:FindFirstChild("Strike") and humanoidRootPart2 and humanoidRootPart2.Parent then
						local strike = lightninggodawakening.Strike
						local model = strike:FindFirstChild("Model")

						if model then
							local v5 = fn9(model, v3, humanoidRootPart2, CFrame.new(0.221, 14.591, -2.723))

							if v5 then
								Debris:AddItem(v5, 2.5)
							end
						end

						local lightningImpactGround = strike:FindFirstChild("LightningImpactGround")

						if lightningImpactGround then
							local v5 = fn9(lightningImpactGround, v3, humanoidRootPart2, CFrame.new(0.222, -0.35, -2.723))

							if v5 then
								Debris:AddItem(v5, 2.5)
								local blastLight = v5:FindFirstChild("BlastLight", true)

								if not blastLight then
									local impact = v5:FindFirstChild("Impact", true)

									if impact then
										blastLight = impact:FindFirstChild("BlastLight")
									end
								end

								if blastLight and blastLight:IsA("PointLight") then
									blastLight.Enabled = true

									task.delay(0.42, function()
										if blastLight and blastLight.Parent then
											TweenService:Create(blastLight, TweenInfo.new(0.35, Enum.EasingStyle.Linear), { Brightness = 2 }):Play()
										end
									end)
								end
							end
						end
					end

					if lightninggodawakening and lightninggodawakening:FindFirstChild("Lines1") then
						local lines1 = lightninggodawakening.Lines1

						if lines1:IsA("ParticleEmitter") then
							for _, v5 in fn14() do
								local clone = lines1:Clone()
								clone.Enabled = true
								clone.Parent = v5
								Debris:AddItem(clone, 0.8)
							end
						end
					end

					if lightninggodawakening and lightninggodawakening:FindFirstChild("AuraLightning") then
						for _, v5 in lightninggodawakening.AuraLightning:GetChildren() do
							if v5 and v5:IsA("ParticleEmitter") then
								for _, v6 in fn14() do
									local clone = v5:Clone()
									clone.Enabled = true
									clone.Parent = v6
									Debris:AddItem(clone, 0.8)
								end
							end
						end
					end

					local character2 = localPlayer3.Character

					if character2 and character2:FindFirstChild("Remotes") then
						local relay = character2.Remotes:FindFirstChild("Relay")

						if relay then
							relay:Fire({
								EffectName = "MauioShake",
								Length = 0.45,
								TweenSpeed = 0.075,
								AxisMultipliers = Vector3.new(1, 0.15, 1),
								FadeStyle = "inQuad",
								PositionStyle = "inCubic",
								Intensity = 2,
							})
						end
					end
				end)
			end)

			task.delay(2.9, function()
				if not flag then
					return
				end

				if EffectsSecond and EffectsSecond.ImpactFrames then
					pcall(function()
						EffectsSecond.ImpactFrames({ foldername = "LightningGod", displaytime = 0.015 })
					end)
				end
			end)

			task.delay(3.65, function()
				if not flag then
					return
				end

				pcall(function()
					if lightninggodawakening and lightninggodawakening:FindFirstChild("Glow") then
						local glow = lightninggodawakening.Glow

						if glow:IsA("ParticleEmitter") then
							for _, v5 in fn14() do
								local clone = glow:Clone()
								clone.Enabled = true
								clone.Parent = v5
								Debris:AddItem(clone, 0.52)
							end
						end
					end
				end)
			end)

			task.delay(n3, function()
				pcall(function()
					connection2:Disconnect()
				end)

				pcall(function()
					connection:Disconnect()
				end)

				pcall(function()
					connection3:Disconnect()
				end)

				if sound and sound.Parent then
					pcall(function()
						sound:Stop()
						sound:Destroy()
					end)
				end

				if v4 then
					pcall(function()
						v4:Stop(0.3)
					end)
				end

				fn13()

				if humanoidRootPart and humanoidRootPart.Parent then
					local sound2 = Instance.new("Sound")
					sound2.SoundId = "rbxassetid://97926606277706"
					sound2.Volume = 1.5
					sound2.RollOffMaxDistance = 300
					sound2.Parent = humanoidRootPart
					sound2:Play()
					Debris:AddItem(sound2, 10)
				end

				pcall(function()
					if lightninggodawakening and lightninggodawakening:FindFirstChild("LingeringAura") and character and character.Parent then
						for _, v5 in lightninggodawakening.LingeringAura:GetChildren() do
							if v5 and v5:IsA("ParticleEmitter") then
								for _, v6 in { "Torso", "UpperTorso", "Left Arm", "Right Arm" }, nil, nil do
									local v7 = character:FindFirstChild(v6)

									if v7 and v7:IsA("BasePart") then
										local clone = v5:Clone()
										clone.Enabled = true
										clone.Parent = v7
										Debris:AddItem(clone, 6)

										task.delay(4, function()
											if clone and clone.Parent then
												clone.Enabled = false
											end
										end)
									end
								end
							end
						end
					end
				end)

				pcall(function()
					if lightninggodawakening and lightninggodawakening:FindFirstChild("eyes") and head and head.Parent then
						for _, v5 in lightninggodawakening.eyes:GetChildren() do
							if v5 and v5:IsA("Attachment") then
								local clone = v5:Clone()
								clone.Parent = head

								for _, v6 in clone:GetDescendants() do
									if v6 and v6:IsA("ParticleEmitter") then
										v6.Enabled = true
									end
								end

								Debris:AddItem(clone, 6)

								task.delay(4, function()
									if clone and clone.Parent then
										for _, v6 in clone:GetDescendants() do
											if v6 and v6:IsA("ParticleEmitter") then
												v6.Enabled = false
											end
										end
									end
								end)
							end
						end
					end
				end)

				task.delay(0.3, function()
					if v3 and v3.Parent then
						pcall(function()
							v3:Destroy()
						end)
					end
				end)
			end)
		end) then
			fn13()
		end

		task.delay(20, function()
			if not flag4 then
				fn13()
			end
		end)
	end

	local tbl2 = {}

	local function fn13(arg)
		if not arg or tbl2[arg] then
			return
		end
		tbl2[arg] = true

		local function fn14()
			local v3 = flag3
			local v4

			if flag3 then
				v4 = v3
			else
				v4 = flag
			end

			if v4 or not MainModule.FakeLightningAwakeningEnabled then
				return
			end
			flag3 = true

			task.defer(function()
				fn12()
				task.wait(0.5)
				flag3 = false
			end)
		end

		arg.Equipped:Connect(fn14)
		arg.Activated:Connect(fn14)
	end

	local tool = Instance.new("Tool")
	tool.Name = "LIGHTNING AWAKENING"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	local part = Instance.new("Part")
	part.Name = "Handle"
	part.Size = Vector3.one
	part.Transparency = 1
	part.CanCollide = false
	part.Massless = true
	part.Parent = tool

	local function fn14()
		if not MainModule.FakeLightningAwakeningEnabled then
			return
		end
		local backpack = localPlayer3:FindFirstChild("Backpack")
		local character = localPlayer3.Character
		if not backpack then
			return
		end
		local lightningAwakening2 = backpack:FindFirstChild("LIGHTNING AWAKENING")
		character = character and character:FindFirstChild("LIGHTNING AWAKENING")

		if not lightningAwakening2 and not character then
			local clone = tool:Clone()
			clone.Parent = backpack
			fn13(clone)
		elseif lightningAwakening2 then
			fn13(lightningAwakening2)
		elseif character then
			fn13(character)
		end
	end

	localPlayer3:WaitForChild("Backpack")
	fn14()

	localPlayer3.Backpack.ChildAdded:Connect(function(child)
		if child.Name == "LIGHTNING AWAKENING" and child:IsA("Tool") then
			fn13(child)
		end
	end)

	localPlayer3.CharacterAdded:Connect(function(character)
		flag = false
		flag2 = false
		flag3 = false
		tbl2 = {}

		pcall(function()
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.FieldOfView = 70
		end)

		task.wait(1)
		fn14()

		character.ChildAdded:Connect(function(child)
			if child.Name == "LIGHTNING AWAKENING" and child:IsA("Tool") then
				fn13(child)
			end
		end)
	end)
end

MainModule.ESPPowersEnabled = false
MainModule.ESPPowersDrawings = {}
MainModule.ESPPowersConnection = nil

MainModule.clear_esp_powers = function()
	for _, espPowersDrawing in pairs(MainModule.ESPPowersDrawings) do
		pcall(function()
			if espPowersDrawing.Remove then
				espPowersDrawing:Remove()
			elseif espPowersDrawing.Destroy then
				espPowersDrawing:Destroy()
			end
		end)
	end

	MainModule.ESPPowersDrawings = {}

	if MainModule.ESPPowersConnection then
		pcall(function()
			MainModule.ESPPowersConnection:Disconnect()
		end)

		MainModule.ESPPowersConnection = nil
	end
end

MainModule.toggle_esp_powers = function(arg)
	MainModule.ESPPowersEnabled = arg and true or false
	MainModule.clear_esp_powers()

	if not arg then
		if fn4 then
			fn4()
		end

		return true
	end

	local function fn8(arg2)
		if not arg2 then
			return nil
		end
		local tbl2 = { "_EquippedPower", "EquippedPower", "Power", "CurrentPower", "Ability" }

		for _, v2 in ipairs(tbl2) do
			local attribute = arg2:GetAttribute(v2)
			if attribute ~= nil and attribute ~= false and attribute ~= "" and attribute ~= 0 then
				return tostring(attribute)
			end
		end

		local character = arg2.Character

		if character then
			for _, v2 in ipairs(tbl2) do
				local attribute = character:GetAttribute(v2)
				if attribute ~= nil and attribute ~= false and attribute ~= "" and attribute ~= 0 then
					return tostring(attribute)
				end
			end

			for _, descendant in ipairs(character:GetDescendants()) do
				if descendant.Name == "_EquippedPower" or descendant.Name == "EquippedPower" or descendant.Name == "Power" then
					if descendant:IsA("StringValue") or descendant:IsA("NumberValue") then
						return tostring(descendant.Value)
					end
					local attribute = descendant:GetAttribute("Value") or descendant:GetAttribute("Name")
					if attribute then
						return tostring(attribute)
					end
				end
			end
		end

		return nil
	end

	MainModule.ESPPowersConnection = RunService2.RenderStepped:Connect(function()
		if not MainModule.ESPPowersEnabled then
			return
		end
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then
			return
		end
		local tbl2 = {}

		for _, player in ipairs(Players2:GetPlayers()) do
			if player ~= localPlayer2 and player.Character then
				local v2 = fn8(player)

				if v2 then
					local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")

					if head then
						local v3, v4 = currentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.2, 0))
						local userId = player.UserId
						tbl2[userId] = true
						local text = MainModule.ESPPowersDrawings[userId]

						if not text then
							text = Drawing.new("Text")
							text.Center = true
							text.Outline = true
							text.Size = 16
							text.Font = 2
							text.Color = Color3.fromRGB(255, 255, 255)
							text.OutlineColor = Color3.fromRGB(0, 0, 0)
							MainModule.ESPPowersDrawings[userId] = text
						end

						if v4 and v3.Z > 0 then
							text.Visible = true
							text.Position = Vector2.new(v3.X, v3.Y)
							text.Text = v2
						else
							text.Visible = false
						end
					end
				end
			end
		end

		for k, espPowersDrawing in pairs(MainModule.ESPPowersDrawings) do
			if not tbl2[k] then
				pcall(function()
					if espPowersDrawing.Remove then
						espPowersDrawing:Remove()
					end
				end)

				MainModule.ESPPowersDrawings[k] = nil
			end
		end
	end)

	if fn4 then
		fn4()
	end

	return true
end

MainModule.PeabertESPEnabled = false
MainModule.PeabertESPHighlights = {}
MainModule.PeabertESPTracers = {}
MainModule.PeabertESPConnection = nil
MainModule.PeabertTargetsCache = {}
MainModule.PeabertLastScan = 0

do
	local function fn8()
		for _, peabertESPHighlight in pairs(MainModule.PeabertESPHighlights) do
			pcall(function()
				if peabertESPHighlight and peabertESPHighlight.Parent then
					peabertESPHighlight:Destroy()
				end
			end)
		end

		MainModule.PeabertESPHighlights = {}

		for _, peabertESPTracer in pairs(MainModule.PeabertESPTracers) do
			pcall(function()
				if peabertESPTracer.Remove then
					peabertESPTracer:Remove()
				elseif peabertESPTracer.Destroy then
					peabertESPTracer:Destroy()
				end
			end)
		end

		MainModule.PeabertESPTracers = {}
	end

	local function fn9(arg)
		if not arg then
			return false
		end

		if arg:FindFirstChild("Dead") then
			return false
		end
		local str = arg.Name:lower()
		if str == "freepeabert" or str:find("freepeabert") then
			return true
		end
		local flag = false

		pcall(function()
			flag = arg:GetAttribute("FREEPEABERT") or arg:GetAttribute("FreePeabert")
		end)

		if flag then
			return true
		end

		if str:match("^peabert%d+$") then
			return true
		end

		if str:match("^peabert_%d+$") then
			return true
		end

		if str:match("^evilpeabert1_%d+$") then
			return true
		end

		if str:match("^peabertspawn%d+$") then
			return true
		end

		if str:match("^peabertshattered%d+$") then
			return true
		end

		if str:match("^peabertcrack%d+$") then
			return true
		end

		if str == "peabert" or str:find("peabert") and not str:find("esp") then
			return true
		end
		return false
	end

	local function fn10(arg)
		if arg:IsA("BasePart") then
			return arg
		end

		if arg:IsA("Model") then
			return arg.PrimaryPart or arg:FindFirstChild("HumanoidRootPart") or arg:FindFirstChild("Head") or arg:FindFirstChildWhichIsA("BasePart")
		end
		return arg:FindFirstChildWhichIsA("BasePart")
	end

	local function fn11()
		local peabertTargetsCache = {}
		local tbl2 = {}

		local function fn12(arg)
			if not arg or tbl2[arg] then
				return
			end

			if not fn9(arg) then
				return
			end
			local v2 = fn10(arg)
			if not v2 then
				return
			end
			tbl2[arg] = true
			table.insert(peabertTargetsCache, { Object = arg, Part = v2, Name = arg.Name })
		end

		local live = workspace:FindFirstChild("Live")

		if live then
			for i = 1, 10 do
				fn12(live:FindFirstChild("FREEPEABERT"))
				fn12(live:FindFirstChild("FreePeabert"))
				fn12(live:FindFirstChild("FreePeabert" .. i))
				fn12(live:FindFirstChild("Peabert" .. i))
				fn12(live:FindFirstChild("Peabert_" .. i))
				fn12(live:FindFirstChild("EvilPeabert1_" .. i))
				fn12(live:FindFirstChild("PeabertSpawn" .. i))
			end

			for _, child in ipairs(live:GetChildren()) do
				local str = child.Name:lower()

				if str:find("peabert") or str:find("freepeabert") then
					fn12(child)
				end
			end
		end

		for _, child in ipairs(workspace:GetChildren()) do
			if child.Name:lower():find("peabert") then
				fn12(child)

				for _, child2 in ipairs(child:GetChildren()) do
					fn12(child2)
				end
			end
		end

		MainModule.PeabertTargetsCache = peabertTargetsCache
		MainModule.PeabertLastScan = tick()
	end

	MainModule.start_peabert_esp = function()
		if MainModule.PeabertESPEnabled then
			return
		end
		MainModule.PeabertESPEnabled = true
		fn8()
		fn11()

		MainModule.PeabertESPConnection = RunService2.Heartbeat:Connect(function()
			if not MainModule.PeabertESPEnabled then
				return
			end
			local peabertLastScan = MainModule.PeabertLastScan

			if tick() - peabertLastScan > 2.5 then
				fn11()
			end

			local currentCamera = workspace.CurrentCamera
			local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
			local tbl2 = {}
			local vector2 = Vector2.new(0, 0)

			if currentCamera then
				vector2 = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y)
			end

			if humanoidRootPart and currentCamera then
				local v2 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position)
				vector2 = Vector2.new(v2.X, v2.Y)
			end

			for _, v2 in ipairs(MainModule.PeabertTargetsCache) do
				local part = v2.Part
				local str = tostring(v2.Object)

				if part and part.Parent then
					tbl2[str] = true
					local v3 = MainModule.PeabertESPHighlights[str]

					if not v3 or not v3.Parent then
						local highlight = Instance.new("Highlight")
						highlight.Name = "PeabertHighlight"
						highlight.FillColor = Color3.fromRGB(255, 105, 180)
						highlight.OutlineColor = Color3.fromRGB(255, 182, 193)
						highlight.FillTransparency = 0.4
						highlight.OutlineTransparency = 0
						local object = v2.Object:IsA("Model") and v2.Object or part
						highlight.Adornee = object
						highlight.Parent = object
						MainModule.PeabertESPHighlights[str] = highlight
					else
						v3.Adornee = v2.Object:IsA("Model") and v2.Object or part
					end

					local magnitude = humanoidRootPart and (part.Position - humanoidRootPart.Position).Magnitude or 0
					local line = MainModule.PeabertESPTracers[str]

					if magnitude > 500 then
						if line then
							line.Visible = false
						end
					else
						if not line then
							line = Drawing.new("Line")
							line.Thickness = 1.5
							line.Color = Color3.fromRGB(255, 105, 180)
							line.Transparency = 1
							MainModule.PeabertESPTracers[str] = line
						end

						if currentCamera then
							local v4, v5 = currentCamera:WorldToViewportPoint(part.Position)

							if v5 and v4.Z > 0 then
								line.Visible = true
								line.From = vector2
								line.To = Vector2.new(v4.X, v4.Y)
							else
								line.Visible = false
							end
						end
					end
				end
			end

			for k, peabertESPHighlight in pairs(MainModule.PeabertESPHighlights) do
				if not tbl2[k] then
					pcall(function()
						if peabertESPHighlight and peabertESPHighlight.Parent then
							peabertESPHighlight:Destroy()
						end
					end)

					MainModule.PeabertESPHighlights[k] = nil
				end
			end

			for k, peabertESPTracer in pairs(MainModule.PeabertESPTracers) do
				if not tbl2[k] then
					pcall(function()
						if peabertESPTracer.Remove then
							peabertESPTracer:Remove()
						end
					end)

					MainModule.PeabertESPTracers[k] = nil
				end
			end
		end)

		if fn4 then
			fn4()
		end

		return true
	end

	MainModule.stop_peabert_esp = function()
		if not MainModule.PeabertESPEnabled then
			return
		end
		MainModule.PeabertESPEnabled = false

		if MainModule.PeabertESPConnection then
			pcall(function()
				MainModule.PeabertESPConnection:Disconnect()
			end)

			MainModule.PeabertESPConnection = nil
		end

		fn8()

		if fn4 then
			fn4()
		end
	end

	MainModule.toggle_peabert_esp = function(arg)
		if arg then
			return MainModule.start_peabert_esp()
		end
		MainModule.stop_peabert_esp()
		return true
	end

	MainModule.tp_to_peaberts = function()
		local character = localPlayer2.Character
		if not character then
			return
		end
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			return
		end
		fn11()
		local peabertTargetsCache = MainModule.PeabertTargetsCache

		if #peabertTargetsCache == 0 then
			if MainModule.notify then
				MainModule.notify("Peabert TP", "No Peaberts found on map!", 1.5)
			end

			return
		end

		local huge = math.huge
		local v2 = nil

		for _, v3 in ipairs(peabertTargetsCache) do
			local part = v3.Part

			if part and part.Parent then
				local str = v3.Name:lower()
				local n

				if str:find("freepeabert") or str == "freepeabert" then
					n = 0
				else
					local match = str:match("^peabert%d+$") or str:match("^peabert_%d+$")
					n = 2

					if match then
						n = 1
					end
				end

				local n2 = (part.Position - humanoidRootPart.Position).Magnitude + n * 0.001

				if n2 < huge then
					huge = n2
					v2 = part
				end
			end
		end

		if not v2 then
			if MainModule.notify then
				MainModule.notify("Peabert TP", "No Peaberts found on map!", 1.5)
			end

			return
		end

		humanoidRootPart.CFrame = CFrame.new(v2.Position + Vector3.new(0, 4, 0))

		if MainModule.notify then
			MainModule.notify("Peabert TP", "Teleported to Peabert!", 1.2)
		end
	end
end

MainModule.AddVisualItemsEnabled = false
MainModule.AddVisualItemsConnection = nil
MainModule.AutoWinEnabled = false
MainModule.AutoWinConnection = nil
MainModule.AutoWinTriggered = {}
MainModule.CurrentGame = nil
MainModule.GameStartTime = nil
MainModule.LastNotifTime = 0
MainModule.AutoWinHunterFeatures = false

MainModule.set_auto_win_hunter_features = function(arg)
	local autoWinHunterFeatures = arg and true or false
	if MainModule.AutoWinHunterFeatures == autoWinHunterFeatures then
		return
	end
	MainModule.AutoWinHunterFeatures = autoWinHunterFeatures

	if MainModule.FaceTargetModule and MainModule.FaceTargetModule.Enabled ~= autoWinHunterFeatures then
		MainModule.toggle_face_target(autoWinHunterFeatures)
	end

	if MainModule.SpikesKillFeature and MainModule.SpikesKillFeature.Enabled ~= autoWinHunterFeatures then
		MainModule.toggle_spikes_kill(autoWinHunterFeatures)
	end

	MainModule.toggle_noclip(autoWinHunterFeatures)

	if MainModule.ToggleRefs then
		if MainModule.ToggleRefs.FaceTarget then
			MainModule.ToggleRefs.FaceTarget:SetValue(autoWinHunterFeatures)
		end

		if MainModule.ToggleRefs.SpikesKill then
			MainModule.ToggleRefs.SpikesKill:SetValue(autoWinHunterFeatures)
		end

		if MainModule.ToggleRefs.Noclip then
			MainModule.ToggleRefs.Noclip:SetValue(autoWinHunterFeatures)
		end
	end
end

MainModule.cleanup_auto_win_game = function(arg)
	if arg == "HideAndSeek" then
		MainModule.set_auto_win_hunter_features(false)
	end

	if arg ~= "TugOfWar" then
	end
end

MainModule.auto_win = function()
	if not MainModule.AutoWinEnabled then
		return
	end
	local now = tick()
	local values = Workspace:FindFirstChild("Values")
	if not values then
		return
	end
	local currentGame = values:FindFirstChild("CurrentGame")
	if not currentGame then
		return
	end
	local currentGame2 = currentGame.Value
	if not currentGame2 or currentGame2 == "" then
		return
	end

	if currentGame2 ~= MainModule.CurrentGame then
		local currentGame3 = MainModule.CurrentGame

		if currentGame3 then
			MainModule.cleanup_auto_win_game(currentGame3)
		end

		MainModule.CurrentGame = currentGame2
		MainModule.GameStartTime = now

		MainModule.AutoWinTriggered = {
			Main = false,
			HunterStarted = false,
			HunterStopped = false,
			RebelStarted = false,
			TugOfWarStarted = false,
		}

		return
	end

	if not MainModule.GameStartTime then
		MainModule.GameStartTime = now
		return
	end
	local n = now - MainModule.GameStartTime
	local autoWinTriggered = MainModule.AutoWinTriggered

	if currentGame2 == "TugOfWar" or currentGame2 == "TugofWar" then
		if not autoWinTriggered.TugOfWarStarted then
			autoWinTriggered.TugOfWarStarted = true

			if not MainModule.TugOfWarUltraFastPull then
				pcall(function()
					MainModule.toggle_tug_of_war_ultra_fast_pull(true)
				end)
			end

			fn4()
		end

		return
	end

	local v2 = MainModule.get_character()
	if not v2 then
		return
	end
	local v3 = MainModule.get_root_part(v2)
	if not v3 then
		return
	end

	if currentGame2 == "RedLightGreenLight" then
		if not autoWinTriggered.Main and n >= 15 then
			autoWinTriggered.Main = true
			MainModule.safe_teleport(Vector3.new(-214.4, 1023.1, 146.7))
			fn4()
		end
	elseif currentGame2 == "Dalgona" then
		if not autoWinTriggered.Main and n >= 25 then
			autoWinTriggered.Main = true
			MainModule.shitahhdalgonaez()
			fn4()
		end
	elseif currentGame2 == "LightsOut" or currentGame2 == "LightOut" then
		if not autoWinTriggered.Main and n >= 15 then
			autoWinTriggered.Main = true
			local position = v3.Position
			MainModule.safe_teleport(Vector3.new(position.X, position.Y + 100, position.Z))
			fn4()
		end
	elseif currentGame2 == "HideAndSeek" then
		local v4 = MainModule.is_hider(localPlayer2)
		local v5 = MainModule.is_seeker(localPlayer2)

		if v4 then
			if not autoWinTriggered.Main and n >= 15 then
				autoWinTriggered.Main = true
				local position = v3.Position
				MainModule.safe_teleport(Vector3.new(position.X, position.Y + 200, position.Z))
				fn4()
			end
		elseif v5 then
			if not autoWinTriggered.HunterStarted and n >= 25 then
				autoWinTriggered.HunterStarted = true
				MainModule.set_auto_win_hunter_features(true)
				fn4()
			end

			if autoWinTriggered.HunterStarted and not autoWinTriggered.HunterStopped and n >= 145 then
				autoWinTriggered.HunterStopped = true
				MainModule.set_auto_win_hunter_features(false)
				fn4()
			end
		end
	elseif currentGame2 == "JumpRope" then
		if not autoWinTriggered.Main and n >= 15 then
			autoWinTriggered.Main = true
			MainModule.safe_teleport(Vector3.new(720.89606, 198.62831, 921.17065))
			fn4()
		end
	elseif currentGame2 == "GlassBridge" then
		if not autoWinTriggered.Main and n >= 15 then
			autoWinTriggered.Main = true
			MainModule.safe_teleport(Vector3.new(-196.37247, 522.19214, -1534.2098))
			fn4()
		end
	elseif currentGame2 == "Rebel" then
		if not autoWinTriggered.RebelStarted then
			autoWinTriggered.RebelStarted = true
			local position = v3.Position
			MainModule.safe_teleport(Vector3.new(position.X, position.Y + 100, position.Z))
			fn4()
		end
	end
end

MainModule.toggle_auto_win = function(arg)
	local autoWinEnabled = arg and true or false
	MainModule.AutoWinEnabled = autoWinEnabled

	if MainModule.AutoWinConnection then
		MainModule.AutoWinConnection:Disconnect()
		MainModule.AutoWinConnection = nil
	end

	if not autoWinEnabled then
		MainModule.cleanup_auto_win_game(MainModule.CurrentGame)
		MainModule.set_auto_win_hunter_features(false)
	end

	MainModule.AutoWinTriggered = {}
	MainModule.CurrentGame = nil
	MainModule.GameStartTime = nil
	MainModule.LastNotifTime = 0

	if autoWinEnabled then
		MainModule.AutoWinConnection = RunService2.Heartbeat:Connect(function()
			MainModule.auto_win()
		end)
	end

	fn4()
	return true
end

getgenv().Time = 3
getgenv().Head = { 1095708 }
getgenv().Hand = { 3141364957 }
getgenv().Torso = { 2222720521 }

do
	local function fn8()
		local currentCamera = workspace.CurrentCamera

		if currentCamera and currentCamera.CameraSubject then
			local cameraSubject = currentCamera.CameraSubject
			if cameraSubject and cameraSubject:IsA("Humanoid") then
				return cameraSubject.Parent
			end
		end

		for _, child in pairs(workspace:GetChildren()) do
			if child:FindFirstChild("Humanoid") and child:FindFirstChild("Head") then
				if not string.find(child.Name:lower(), "badpreload") and not string.find(child.Name:lower(), "preload") then
					return child
				end
			end
		end

		return nil
	end

	local function fn9(arg, part0)
		local ok, result = pcall(function()
			return game:GetObjects("rbxassetid://" .. tostring(arg))[1]
		end)

		if ok and result then
			local handle = result:FindFirstChild("Handle")

			if handle then
				local attachment = handle:FindFirstChildOfClass("Attachment")

				if attachment then
					local v2 = part0:FindFirstChild(attachment.Name)

					if v2 then
						local weld = Instance.new("Weld")
						weld.Part0 = part0
						weld.Part1 = handle
						weld.C0 = v2.CFrame
						weld.C1 = attachment.CFrame
						weld.Parent = handle
					else
						local weld = Instance.new("Weld")
						weld.Part0 = part0
						weld.Part1 = handle
						weld.C0 = CFrame.new()
						weld.C1 = CFrame.new()
						weld.Parent = handle
					end
				else
					local weld = Instance.new("Weld")
					weld.Part0 = part0
					weld.Part1 = handle
					weld.C0 = CFrame.new()
					weld.C1 = CFrame.new()
					weld.Parent = handle
				end

				handle.CanCollide = false
				result.Parent = part0.Parent
				MainModule._HSXVisualAdded = MainModule._HSXVisualAdded or {}
				table.insert(MainModule._HSXVisualAdded, result)
			end
		end
	end

	local function fn10(arg)
		local head = arg:FindFirstChild("Head")
		if not head then
			return
		end
		head.Transparency = 1
		head.CanCollide = false
		local decal = head:FindFirstChildOfClass("Decal")

		if decal then
			decal:Destroy()
		end

		for _, child in ipairs(head:GetChildren()) do
			if child:IsA("SpecialMesh") or child:IsA("CharacterMesh") then
				child:Destroy()
			end
		end

		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = Enum.MeshType.FileMesh
		specialMesh.MeshId = "rbxassetid://1095708"
		specialMesh.Scale = Vector3.new(0.001, 0.001, 0.001)
		specialMesh.Parent = head
	end

	local function fn11()
		local v2 = fn8()
		if not v2 then
			return
		end

		if v2:FindFirstChild("Head") then
			for _, v3 in ipairs(getgenv().Head) do
				fn9(v3, v2.Head)
				task.wait(0.3)
			end
		end

		local upperTorso = v2:FindFirstChild("UpperTorso") or v2:FindFirstChild("Torso")

		if upperTorso then
			for _, v3 in ipairs(getgenv().Torso) do
				fn9(v3, upperTorso)
				task.wait(0.3)
			end
		end

		local rightHand = v2:FindFirstChild("RightHand") or v2:FindFirstChild("LeftHand") or v2:FindFirstChild("Right Arm") or v2:FindFirstChild("Left Arm")

		if rightHand and getgenv().Hand then
			for _, v3 in ipairs(getgenv().Hand) do
				fn9(v3, rightHand)
				task.wait(0.3)
			end
		end

		fn10(v2)
	end

	MainModule._HSXVisualAdded = MainModule._HSXVisualAdded or {}

	local function fn12()
		for _, v2 in ipairs(MainModule._HSXVisualAdded) do
			pcall(function()
				if v2 and v2.Parent then
					v2:Destroy()
				end
			end)
		end

		MainModule._HSXVisualAdded = {}
	end

	MainModule.toggle_visual_items = function(addVisualItemsEnabled)
		MainModule.AddVisualItemsEnabled = addVisualItemsEnabled

		if MainModule.AddVisualItemsConnection then
			MainModule.AddVisualItemsConnection:Disconnect()
			MainModule.AddVisualItemsConnection = nil
		end

		if addVisualItemsEnabled then
			fn11()

			MainModule.AddVisualItemsConnection = localPlayer2.CharacterAdded:Connect(function()
				task.wait(1)

				if MainModule.AddVisualItemsEnabled then
					fn11()
				end
			end)
		else
			fn12()
		end

		fn4()
	end
end

local flag
flag = false

do
	local tbl2 = {}
	local tbl3 = {}

	local function fn8(arg)
		if arg.Name:lower():find("wall") then
			return true
		end

		if arg.Size.Y > arg.Size.X or arg.Size.Y > arg.Size.Z then
			return true
		end
		return false
	end

	local function fn9(arg)
		local str = arg.Name:lower()
		if str:find("floor") or str:find("ground") or str:find("plate") then
			return true
		end

		if arg.Size.Y < arg.Size.X and arg.Size.Y < arg.Size.Z then
			return true
		end
		return false
	end

	local function fn10(arg)
		if not arg:IsA("BasePart") then
			return
		end
		local character = localPlayer2.Character
		if character and arg:IsDescendantOf(character) then
			return
		end

		if tbl2[arg] == nil then
			tbl2[arg] = arg.CanCollide
		end

		if flag then
			if fn9(arg) then
				arg.CanCollide = true
			elseif fn8(arg) then
				arg.CanCollide = false
			end
		else
			arg.CanCollide = tbl2[arg]
		end
	end

	local function fn11()
		for _, descendant in ipairs(Workspace:GetDescendants()) do
			fn10(descendant)
		end
	end

	local function fn12()
		flag = true
		fn11()

		table.insert(tbl3, Workspace.DescendantAdded:Connect(function(descendant)
			if flag then
				fn10(descendant)
			end
		end))
	end

	local function fn13()
		flag = false

		for _, v2 in ipairs(tbl3) do
			pcall(function()
				v2:Disconnect()
			end)
		end

		table.clear(tbl3)

		for k, v2 in pairs(tbl2) do
			if k and k.Parent then
				pcall(function()
					k.CanCollide = v2
				end)
			end
		end

		table.clear(tbl2)
	end

	MainModule.toggle_noclip = function(arg)
		if arg then
			MainModule._MovecheckFromAuto = true
			pcall(MainModule.HSX_MovecheckAutoStart)
			MainModule._MovecheckFromAuto = false
		else
			pcall(MainModule.HSX_MovecheckAutoStop)
		end

		if arg then
			fn12()
		else
			fn13()
		end

		fn4()
		return true
	end
end

MainModule.FreeCam = {
	Enabled = false,
	Camera = nil,
	OriginalCameraType = nil,
	OriginalCameraSubject = nil,
	OriginalCFrame = nil,
	Speed = 10,
	Sensitivity = 0.25,
	Keys = { W = false, S = false, A = false, D = false, Q = false, E = false },
	Connection = nil,
	HeartbeatConnection = nil,
	InputBegan = nil,
	InputEnded = nil,
	Yaw = 0,
	Pitch = 0,
}

MainModule.set_free_cam_speed = function(arg)
	MainModule.FreeCam.Speed = tonumber(arg) or 10
end

MainModule.toggle_free_cam = function(arg)
	if arg then
		if MainModule.FreeCam.Enabled then
			return
		end
		MainModule.FreeCam.Enabled = true
		local currentCamera = workspace.CurrentCamera
		local character = localPlayer2.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		MainModule.FreeCam.OriginalCameraType = currentCamera.CameraType
		MainModule.FreeCam.OriginalCameraSubject = currentCamera.CameraSubject
		MainModule.FreeCam.OriginalCFrame = currentCamera.CFrame
		MainModule.FreeCam.Camera = currentCamera

		if humanoidRootPart then
			MainModule.FreeCam.OriginalPosition = humanoidRootPart.CFrame
		end

		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = MainModule.FreeCam.OriginalCFrame
		local lookVector = currentCamera.CFrame.LookVector
		MainModule.FreeCam.Yaw = math.atan2(-lookVector.X, -lookVector.Z)
		MainModule.FreeCam.Pitch = math.asin(math.clamp(lookVector.Y, -1, 1))

		pcall(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		end)

		pcall(function()
			UserInputService.MouseIconEnabled = false
		end)

		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.AutoRotate = false
				humanoid.PlatformStand = true
			end

			if humanoidRootPart then
				humanoidRootPart.Anchored = true
			end
		end

		local function fn8()
			if not MainModule.FreeCam.Enabled then
				return
			end
			local camera = MainModule.FreeCam.Camera
			if not camera then
				return
			end
			local mouseDelta = UserInputService:GetMouseDelta()
			local sensitivity = MainModule.FreeCam.Sensitivity or 0.25
			MainModule.FreeCam.Yaw = MainModule.FreeCam.Yaw - mouseDelta.X * sensitivity * 0.012
			MainModule.FreeCam.Pitch = math.clamp(MainModule.FreeCam.Pitch - mouseDelta.Y * sensitivity * 0.012, -1.45, 1.45)
			local cframe = CFrame.fromEulerAnglesYXZ(MainModule.FreeCam.Pitch, MainModule.FreeCam.Yaw, 0)
			local position = camera.CFrame.Position
			local vector = Vector3.zero

			if MainModule.FreeCam.Keys.W then
				vector = Vector3.zero + cframe.LookVector
			end

			if MainModule.FreeCam.Keys.S then
				vector -= cframe.LookVector
			end

			if MainModule.FreeCam.Keys.D then
				vector += cframe.RightVector
			end

			if MainModule.FreeCam.Keys.A then
				vector -= cframe.RightVector
			end

			if MainModule.FreeCam.Keys.Q then
				vector -= Vector3.new(0, 1, 0)
			end

			if MainModule.FreeCam.Keys.E then
				vector += Vector3.new(0, 1, 0)
			end

			if vector.Magnitude > 0 then
				position += vector.Unit * (MainModule.FreeCam.Speed or 10)
			end

			camera.CFrame = CFrame.new(position) * cframe
		end

		local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			local keyCode = input.KeyCode

			if keyCode == Enum.KeyCode.W then
				MainModule.FreeCam.Keys.W = true
			elseif keyCode == Enum.KeyCode.S then
				MainModule.FreeCam.Keys.S = true
			elseif keyCode == Enum.KeyCode.A then
				MainModule.FreeCam.Keys.A = true
			elseif keyCode == Enum.KeyCode.D then
				MainModule.FreeCam.Keys.D = true
			elseif keyCode == Enum.KeyCode.Q then
				MainModule.FreeCam.Keys.Q = true
			elseif keyCode == Enum.KeyCode.E then
				MainModule.FreeCam.Keys.E = true
			elseif keyCode == Enum.KeyCode.LeftShift then
				MainModule.FreeCam.Speed = (MainModule.FreeCam.Speed or 10) * 2
			elseif keyCode == Enum.KeyCode.LeftControl then
				MainModule.FreeCam.Speed = math.max(1, (MainModule.FreeCam.Speed or 10) * 0.4)
			end
		end)

		local connection2 = UserInputService.InputEnded:Connect(function(input)
			local keyCode = input.KeyCode

			if keyCode == Enum.KeyCode.W then
				MainModule.FreeCam.Keys.W = false
			elseif keyCode == Enum.KeyCode.S then
				MainModule.FreeCam.Keys.S = false
			elseif keyCode == Enum.KeyCode.A then
				MainModule.FreeCam.Keys.A = false
			elseif keyCode == Enum.KeyCode.D then
				MainModule.FreeCam.Keys.D = false
			elseif keyCode == Enum.KeyCode.Q then
				MainModule.FreeCam.Keys.Q = false
			elseif keyCode == Enum.KeyCode.E then
				MainModule.FreeCam.Keys.E = false
			elseif keyCode == Enum.KeyCode.LeftShift or keyCode == Enum.KeyCode.LeftControl then
				MainModule.FreeCam.Speed = MainModule.FreeCam._BaseSpeed or MainModule.FreeCam.Speed or 10
			end
		end)

		MainModule.FreeCam._BaseSpeed = MainModule.FreeCam.Speed
		MainModule.FreeCam.Connection = RunService2.RenderStepped:Connect(fn8)
		MainModule.FreeCam.InputBegan = connection
		MainModule.FreeCam.InputEnded = connection2
		fn2("FreeCam", "Mouse look + WASD/QE | Shift fast / Ctrl slow", 0.9)
	else
		if not MainModule.FreeCam.Enabled then
			return
		end
		MainModule.FreeCam.Enabled = false

		if MainModule.FreeCam.Connection then
			MainModule.FreeCam.Connection:Disconnect()
			MainModule.FreeCam.Connection = nil
		end

		if MainModule.FreeCam.InputBegan then
			MainModule.FreeCam.InputBegan:Disconnect()
			MainModule.FreeCam.InputBegan = nil
		end

		if MainModule.FreeCam.InputEnded then
			MainModule.FreeCam.InputEnded:Disconnect()
			MainModule.FreeCam.InputEnded = nil
		end

		pcall(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end)

		pcall(function()
			UserInputService.MouseIconEnabled = true
		end)

		local camera = MainModule.FreeCam.Camera

		if camera then
			camera.CameraType = MainModule.FreeCam.OriginalCameraType or Enum.CameraType.Custom

			if MainModule.FreeCam.OriginalCameraSubject then
				camera.CameraSubject = MainModule.FreeCam.OriginalCameraSubject
			end
		end

		local character = localPlayer2.Character

		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid.AutoRotate = true
				humanoid.PlatformStand = false
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				humanoidRootPart.Anchored = false

				if MainModule.FreeCam.OriginalPosition then
					humanoidRootPart.CFrame = MainModule.FreeCam.OriginalPosition
				end
			end
		end
	end

	fn4()
end

MainModule.QuicksilverEnabled = false
MainModule.QuicksilverFolder = nil

MainModule.toggle_quicksilver = function(arg)
	local quicksilverEnabled = arg and true or false
	MainModule.QuicksilverEnabled = quicksilverEnabled

	if quicksilverEnabled then
		MainModule._MovecheckFromAuto = true
		pcall(MainModule.HSX_MovecheckAutoStart)
		MainModule._MovecheckFromAuto = false
	else
		pcall(MainModule.HSX_MovecheckAutoStop)
	end

	if quicksilverEnabled then
		pcall(function()
			local live = Workspace:FindFirstChild("Live") or Workspace:WaitForChild("Live", 5)
			if not live then
				return
			end
			local v2 = live:FindFirstChild(localPlayer2.Name) or live:WaitForChild(localPlayer2.Name, 5)
			if not v2 then
				return
			end
			local isWallyWest = v2:FindFirstChild("IsWallyWest")

			if isWallyWest then
				isWallyWest:Destroy()
			end

			local folder = Instance.new("Folder")
			folder.Name = "IsWallyWest"
			folder.Parent = v2
			MainModule.QuicksilverFolder = folder
		end)

		fn2("Quicksilver", "Enabled", 0.8)
	else
		pcall(function()
			if MainModule.QuicksilverFolder and MainModule.QuicksilverFolder.Parent then
				MainModule.QuicksilverFolder:Destroy()
			end

			MainModule.QuicksilverFolder = nil
			local live = Workspace:FindFirstChild("Live")
			live = live and live:FindFirstChild(localPlayer2.Name)

			if live then
				local isWallyWest = live:FindFirstChild("IsWallyWest")

				if isWallyWest then
					isWallyWest:Destroy()
				end
			end
		end)

		fn2("Quicksilver", "Disabled", 0.8)
	end

	fn4()
	return true
end

MainModule.RemoveAnniversaryEnabled = false
MainModule.RemoveAnniversaryTask = nil

MainModule.AnniversaryFolders = {
	"GameplayLobbyForAnniversary",
	"RedLightGreenLightAnniversary",
	"JumpropeAnniversary",
	"Anniversary",
	"LobbyAnniversary",
	"MapAnniversary",
	"HideAndSeekAnniversary",
	"DalgonaAnniversary",
	"SkySquidGameAnniversary",
	"SquidGameAnniversary",
	"GlassBridgeAnniversary",
	"TugOfWarAnniversary",
	"LightsOutEffectBind",
}

local function fn8()
	for _, anniversaryFolder in ipairs(MainModule.AnniversaryFolders) do
		local v2 = workspace:FindFirstChild(anniversaryFolder)

		if v2 then
			pcall(function()
				v2:Destroy()
			end)
		end
	end

	local effects = workspace:FindFirstChild("Effects")

	if effects then
		local bloodSplatter = effects:FindFirstChild("BloodSplatter")

		if bloodSplatter then
			pcall(function()
				bloodSplatter:Destroy()
			end)
		end
	end
end

MainModule.toggle_remove_anniversary = function(arg)
	local removeAnniversaryEnabled = arg and true or false
	MainModule.RemoveAnniversaryEnabled = removeAnniversaryEnabled

	if MainModule.RemoveAnniversaryTask then
		task.cancel(MainModule.RemoveAnniversaryTask)
		MainModule.RemoveAnniversaryTask = nil
	end

	if removeAnniversaryEnabled then
		fn8()

		MainModule.RemoveAnniversaryTask = task.spawn(function()
			while MainModule.RemoveAnniversaryEnabled do
				task.wait(10)
				if MainModule.RemoveAnniversaryEnabled then
					fn8()
					continue
				end
				break
			end

			MainModule.RemoveAnniversaryTask = nil
		end)

		fn2("Anniversary", "Anniversary objects removed", 0.8)
	else
		fn2("Anniversary", "Anniversary objects removal disabled", 0.8)
	end

	fn4()
	return true
end

MainModule.FakeExploiterEnabled = false

MainModule.FakeExploiter = {
	isActive = false,
	currentTarget = nil,
	fakeChar = nil,
	hideConn = nil,
	seqTask = nil,
	originalNametag = nil,
	nametagParent = nil,
	watchdog = nil,
}

local tbl2 = {
	Startup = "rbxassetid://135801672920476",
	Sprint = "rbxassetid://82609803681213",
	Jump = "rbxassetid://130659228300247",
	Fall = "rbxassetid://112693580156198",
}

MainModule.FakeExploiter_getNearest = function()
	local character = localPlayer2.Character
	character = character and character:FindFirstChild("HumanoidRootPart")
	if not character then
		return nil
	end
	local huge = math.huge
	local v2 = nil

	for _, player in ipairs(Players2:GetPlayers()) do
		if player ~= localPlayer2 and player.Character then
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
			local humanoid = player.Character:FindFirstChild("Humanoid")

			if humanoidRootPart and humanoid and humanoid.Health > 0 then
				local magnitude = (humanoidRootPart.Position - character.Position).Magnitude

				if magnitude < huge then
					huge = magnitude
					v2 = player
				end
			end
		end
	end

	return v2
end

MainModule.FakeExploiter_setHidden = function(arg, arg2)
	if not arg then
		return
	end

	for _, descendant in ipairs(arg:GetDescendants()) do
		if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") then
			if descendant.Name ~= "Player_Nametag" and not descendant:FindFirstAncestor("Player_Nametag") then
				descendant.LocalTransparencyModifier = arg2 and 1 or 0
			end
		elseif descendant:IsA("Accessory") then
			local handle = descendant:FindFirstChild("Handle")

			if handle then
				handle.LocalTransparencyModifier = arg2 and 1 or 0
			end
		end
	end
end

MainModule.FakeExploiter_findNametag = function(arg)
	if not arg then
		return nil
	end
	local torso = arg:FindFirstChild("Torso") or arg:FindFirstChild("UpperTorso")

	if torso then
		local playerNametag = torso:FindFirstChild("Player_Nametag")
		if playerNametag then
			return playerNametag, torso
		end
	end

	for _, descendant in ipairs(arg:GetDescendants()) do
		if descendant.Name == "Player_Nametag" then
			return descendant, descendant.Parent
		end
	end

	return nil, nil
end

MainModule.FakeExploiter_moveNametag = function(arg, arg2)
	local fakeExploiter = MainModule.FakeExploiter
	local v2, v3 = MainModule.FakeExploiter_findNametag(arg)
	if not v2 or not arg2 then
		return
	end
	fakeExploiter.originalNametag = v2
	fakeExploiter.nametagParent = v3
	local torso = arg2:FindFirstChild("Torso") or arg2:FindFirstChild("UpperTorso")
	if not torso then
		return
	end
	v2.Parent = torso
end

MainModule.FakeExploiter_restoreNametag = function()
	local fakeExploiter = MainModule.FakeExploiter

	if fakeExploiter.originalNametag and fakeExploiter.nametagParent and fakeExploiter.originalNametag.Parent then
		pcall(function()
			fakeExploiter.originalNametag.Parent = fakeExploiter.nametagParent
		end)
	end

	fakeExploiter.originalNametag = nil
	fakeExploiter.nametagParent = nil
end

MainModule.FakeExploiter_turnOff = function()
	local fakeExploiter = MainModule.FakeExploiter
	fakeExploiter.isActive = false

	if fakeExploiter.seqTask then
		task.cancel(fakeExploiter.seqTask)
		fakeExploiter.seqTask = nil
	end

	if fakeExploiter.hideConn then
		fakeExploiter.hideConn:Disconnect()
		fakeExploiter.hideConn = nil
	end

	if fakeExploiter.watchdog then
		fakeExploiter.watchdog:Disconnect()
		fakeExploiter.watchdog = nil
	end

	MainModule.FakeExploiter_restoreNametag()

	if fakeExploiter.currentTarget and fakeExploiter.currentTarget.Character then
		MainModule.FakeExploiter_setHidden(fakeExploiter.currentTarget.Character, false)
	end

	if fakeExploiter.fakeChar and fakeExploiter.fakeChar.Parent then
		fakeExploiter.fakeChar:Destroy()
	end

	fakeExploiter.currentTarget = nil
	fakeExploiter.fakeChar = nil
end

MainModule.FakeExploiter_activate = function()
	local fakeExploiter = MainModule.FakeExploiter
	local character = localPlayer2.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		MainModule.FakeExploiter_turnOff()
		return
	end

	if not fakeExploiter.currentTarget then
		MainModule.FakeExploiter_turnOff()
		return
	end
	local character2 = fakeExploiter.currentTarget.Character
	if not character2 then
		MainModule.FakeExploiter_turnOff()
		return
	end
	local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart2 then
		MainModule.FakeExploiter_turnOff()
		return
	end
	local archivable = character2.Archivable
	character2.Archivable = true
	fakeExploiter.fakeChar = character2:Clone()
	character2.Archivable = archivable

	for _, descendant in ipairs(fakeExploiter.fakeChar:GetDescendants()) do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") then
			descendant:Destroy()
		elseif descendant.Name == "Player_Nametag" then
			descendant:Destroy()
		end
	end

	local humanoidRootPart3 = fakeExploiter.fakeChar:FindFirstChild("HumanoidRootPart")
	local humanoid = fakeExploiter.fakeChar:FindFirstChild("Humanoid")

	if not humanoidRootPart3 or not humanoid then
		fakeExploiter.fakeChar:Destroy()
		MainModule.FakeExploiter_turnOff()
		return
	end

	humanoidRootPart3.Anchored = true
	humanoidRootPart3.CFrame = humanoidRootPart2.CFrame
	fakeExploiter.fakeChar.Parent = workspace
	MainModule.FakeExploiter_moveNametag(character2, fakeExploiter.fakeChar)
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

	local function fn9(animationId)
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		return animator:LoadAnimation(animation)
	end

	local v2 = fn9(tbl2.Startup)
	local v3 = fn9(tbl2.Sprint)
	local v4 = fn9(tbl2.Jump)
	local v5 = fn9(tbl2.Fall)
	v2.Priority = Enum.AnimationPriority.Action4
	v3.Priority = Enum.AnimationPriority.Action4
	v4.Priority = Enum.AnimationPriority.Action4
	v5.Priority = Enum.AnimationPriority.Action4

	fakeExploiter.hideConn = RunService2.RenderStepped:Connect(function()
		if fakeExploiter.currentTarget and fakeExploiter.currentTarget.Character then
			MainModule.FakeExploiter_setHidden(fakeExploiter.currentTarget.Character, true)
		end
	end)

	fakeExploiter.seqTask = task.spawn(function()
		v2:Play()
		task.wait(0.4)
		v2:Stop(0.2)
		v3:Play()
		local n = 0

		while true do
			if n < 2.5 and fakeExploiter.isActive then
				local v6 = task.wait()
				n += v6

				if not (not humanoidRootPart or not humanoidRootPart.Parent or not humanoidRootPart3 or not humanoidRootPart3.Parent) then
					humanoidRootPart3.CFrame = CFrame.lookAt(humanoidRootPart3.Position, humanoidRootPart.Position + Vector3.new(math.sin(n * 10) * 16, 0, math.cos(n * 10) * 16) + Vector3.new(0, 0.1, 0)) * CFrame.new(0, 0, -55 * v6)
					local rotation = humanoidRootPart3.CFrame.Rotation
					humanoidRootPart3.CFrame = CFrame.new(humanoidRootPart3.Position.X, humanoidRootPart.Position.Y, humanoidRootPart3.Position.Z) * rotation
					continue
				end
			end

			break
		end

		v3:Stop(0.2)
		v4:Play()
		local n2 = 0

		while true do
			if n2 < 0.45 and fakeExploiter.isActive then
				local v6 = task.wait()
				n2 += v6
				if not (not humanoidRootPart3 or not humanoidRootPart3.Parent) then
					humanoidRootPart3.CFrame = humanoidRootPart3.CFrame * CFrame.new(0, 28 * v6, -12 * v6)
					continue
				end
			end

			break
		end

		v4:Stop(0.2)
		v5:Play()
		local n3 = 0

		while fakeExploiter.isActive do
			local v6 = task.wait()
			n3 += v6 * 6

			if not (not humanoidRootPart or not humanoidRootPart.Parent or not humanoidRootPart3 or not humanoidRootPart3.Parent) then
				local n4 = 18 + math.sin(n3 * 1.5) * 8
				local n5 = 8 + math.cos(n3 * 1.2) * 5
				humanoidRootPart3.CFrame = CFrame.lookAt(humanoidRootPart3.Position, humanoidRootPart.Position + Vector3.new(math.sin(n3 * 1.2) * n4, n5, math.cos(n3 * 1.2) * n4)) * CFrame.new(0, 0, -70 * v6)
				continue
			end

			break
		end
	end)

	fakeExploiter.watchdog = RunService2.Heartbeat:Connect(function()
		if fakeExploiter.isActive and fakeExploiter.currentTarget then
			if not fakeExploiter.currentTarget.Parent or not fakeExploiter.currentTarget.Character or not fakeExploiter.currentTarget.Character:FindFirstChild("HumanoidRootPart") then
				MainModule.FakeExploiter_turnOff()
			end
		end
	end)
end

MainModule.toggle_fake_exploiter = function(arg)
	local fakeExploiterEnabled = arg and true or false
	MainModule.FakeExploiterEnabled = fakeExploiterEnabled

	if fakeExploiterEnabled then
		local v2 = MainModule.FakeExploiter_getNearest()

		if not v2 then
			MainModule.FakeExploiterEnabled = false
			fn5()
			return false
		end

		MainModule.FakeExploiter.isActive = true
		MainModule.FakeExploiter.currentTarget = v2
		MainModule.FakeExploiter_activate()
	else
		MainModule.FakeExploiter_turnOff()
	end

	fn4()
	return true
end

MainModule.CustomLevelEnabled = false
MainModule.CustomLevelValue = 1
MainModule.CustomLevelConnection = nil

MainModule.toggle_custom_level = function(customLevelEnabled)
	MainModule.CustomLevelEnabled = customLevelEnabled

	if MainModule.CustomLevelConnection then
		MainModule.CustomLevelConnection:Disconnect()
		MainModule.CustomLevelConnection = nil
	end

	if customLevelEnabled then
		localPlayer2:SetAttribute("_CurrentLevel", MainModule.CustomLevelValue)

		MainModule.CustomLevelConnection = RunService2.Heartbeat:Connect(function()
			if MainModule.CustomLevelEnabled then
				localPlayer2:SetAttribute("_CurrentLevel", MainModule.CustomLevelValue)
			end
		end)
	end

	fn4()
end

MainModule.set_custom_level = function(arg)
	local num = tonumber(arg)

	if num and num >= 1 and num <= 999999 then
		MainModule.CustomLevelValue = math.floor(num)

		if MainModule.CustomLevelEnabled then
			localPlayer2:SetAttribute("_CurrentLevel", MainModule.CustomLevelValue)
		end
	else
		MainModule.notify("Custom Level", "Invalid number (1-999999)", 0.9)
		fn5()
	end
end

MainModule.set_all_level_attributes = function(arg)
	local num = tonumber(arg)

	if num and num >= 1 then
		for _, v2 in ipairs({ "_CurrentLevel", "CurrentLevel", "_Level", "Level" }) do
			pcall(function()
				localPlayer2:SetAttribute(v2, math.floor(num))
			end)
		end

		if MainModule.CustomLevelEnabled then
			MainModule.CustomLevelValue = math.floor(num)
		end

		fn4()
	else
		fn5()
	end
end

MainModule.CustomWinstreakEnabled = false
MainModule.CustomWinstreakValue = 0
MainModule.CustomWinstreakConnection = nil

MainModule.toggle_custom_winstreak = function(customWinstreakEnabled)
	MainModule.CustomWinstreakEnabled = customWinstreakEnabled

	if MainModule.CustomWinstreakConnection then
		MainModule.CustomWinstreakConnection:Disconnect()
		MainModule.CustomWinstreakConnection = nil
	end

	if customWinstreakEnabled then
		localPlayer2:SetAttribute("_ConsecutiveWins", MainModule.CustomWinstreakValue)

		MainModule.CustomWinstreakConnection = RunService2.Heartbeat:Connect(function()
			if MainModule.CustomWinstreakEnabled then
				localPlayer2:SetAttribute("_ConsecutiveWins", MainModule.CustomWinstreakValue)
			end
		end)
	end

	fn4()
end

MainModule.set_custom_winstreak = function(arg)
	local num = tonumber(arg)

	if num and num >= 0 and num <= 999999 then
		MainModule.CustomWinstreakValue = math.floor(num)

		if MainModule.CustomWinstreakEnabled then
			localPlayer2:SetAttribute("_ConsecutiveWins", MainModule.CustomWinstreakValue)
		end
	else
		MainModule.notify("Custom Winstreak", "Invalid number (0-999999)", 0.9)
		fn5()
	end
end

MainModule.set_all_winstreak_attributes = function(arg)
	local num = tonumber(arg)

	if num and num >= 0 then
		for _, v2 in ipairs({ "_ConsecutiveWins" }) do
			pcall(function()
				localPlayer2:SetAttribute(v2, math.floor(num))
			end)
		end

		if MainModule.CustomWinstreakEnabled then
			MainModule.CustomWinstreakValue = math.floor(num)
		end

		MainModule.notify("Winstreak", "Set to: " .. math.floor(num), 0.9)
	else
		MainModule.notify("Winstreak", "Invalid number!", 0.9)
		fn5()
	end
end

local tbl3

tbl3 = {
	{
		Name = "JumpMaxxing",
		AnimId = "rbxassetid://117992339950574",
		SoundId = "rbxassetid://101111943336616",
		Volume = 5,
	},
	{
		Name = "Catch Catch",
		AnimId = "rbxassetid://110575780667276",
		SoundId = { "rbxassetid://139710162629738", "rbxassetid://109474708805441" },
		Volume = 5,
	},
	{
		Name = "Triple T dance",
		AnimId = "rbxassetid://87099414813526",
		SoundId = "rbxassetid://134846418381928",
		Volume = 5,
	},
	{
		Name = "AVGN",
		AnimId = "rbxassetid://123450801218845",
		SoundId = "rbxassetid://74497095127038",
		Volume = 5,
	},
	{
		Name = "Bubble pop electric",
		AnimId = "rbxassetid://75245548704974",
		SoundId = "rbxassetid://140344891172315",
		Volume = 5,
	},
	{
		Name = "Dream Journal",
		AnimId = "rbxassetid://117325441970867",
		SoundId = "rbxassetid://88476306353688",
		Volume = 10,
	},
	{
		Name = "Otsukare Summer",
		AnimId = "rbxassetid://134888005420629",
		SoundId = "rbxassetid://127332409398776",
		Volume = 3,
	},
	{
		Name = "Spite",
		AnimId = "rbxassetid://100382123964355",
		SoundId = "rbxassetid://90513005423910",
		Volume = 5,
	},
	{
		Name = "Posing Time",
		AnimId = "rbxassetid://89240795237958",
		SoundId = "rbxassetid://113259086406604",
		Volume = 5,
	},
	{
		Name = "Shuffle",
		AnimId = "rbxassetid://113121578988536",
		SoundId = "rbxassetid://127426881747595",
		Volume = 5,
	},
	{
		Name = "Yare Yare",
		AnimId = "rbxassetid://86642655479570",
		SoundId = "rbxassetid://128193072645447",
		Volume = 5,
	},
	{
		Name = "My Perfect Victory",
		AnimId = "rbxassetid://110501561372722",
		SoundId = "rbxassetid://104280886491008",
		Volume = 5,
	},
	{
		Name = "Fate Of Both Worlds",
		AnimId = "rbxassetid://114244682550258",
		SoundId = "rbxassetid://103081000050688",
		Volume = 5,
	},
	{
		Name = "Peanut of Butter House",
		AnimId = "rbxassetid://108074529570331",
		SoundId = "rbxassetid://95893903149232",
		Volume = 5,
	},
	{
		Name = "Cat Hands",
		AnimId = "rbxassetid://87331103640233",
		SoundId = "rbxassetid://126527049854337",
		Volume = 5,
	},
	{
		Name = "The System",
		AnimId = "rbxassetid://117978762262770",
		SoundId = "rbxassetid://73318799732606",
		Volume = 5,
	},
	{ Name = "Gear 5", AnimId = "rbxassetid://107815350238463", SoundId = nil, Volume = 5 },
	{
		Name = "Mingle Dance",
		AnimId = "rbxassetid://99559083669885",
		SoundId = "rbxassetid://89379201770587",
		Volume = 5,
	},
	{
		Name = "Metro Dance",
		AnimId = "rbxassetid://104701586795462",
		SoundId = "rbxassetid://95730226592096",
		Volume = 5,
	},
	{
		Name = "Funeral for the living",
		AnimId = "rbxassetid://123297701965318",
		SoundId = "rbxassetid://105930820096344",
		Volume = 5,
	},
	{
		Name = "Cartwheel",
		AnimId = "rbxassetid://131418698864660",
		SoundId = "rbxassetid://18911882091",
		Volume = 5,
	},
	{
		Name = "Lively Walk",
		AnimId = "rbxassetid://99556634315867",
		SoundId = "rbxassetid://16706317921",
		Volume = 5,
	},
	{
		Name = "Dance of nights",
		AnimId = "rbxassetid://100183800468181",
		SoundId = "rbxassetid://133365635431929",
		Volume = 5,
	},
	{
		Name = "Sonic run",
		AnimId = "rbxassetid://120151271879240",
		SoundId = "rbxassetid://131594734029433",
		Volume = 5,
	},
	{
		Name = "Khabilame",
		AnimId = "rbxassetid://133158883386630",
		SoundId = "rbxassetid://131852145461258",
		Volume = 5,
	},
	{
		Name = "Mii swing",
		AnimId = "rbxassetid://111293910946685",
		SoundId = "rbxassetid://121596432073446",
		Volume = 5,
	},
	{
		Name = "Jackpot",
		AnimId = "rbxassetid://90063856357375",
		SoundId = "rbxassetid://96528255406149",
		Volume = 5,
	},
	{
		Name = "Scuba",
		AnimId = "rbxassetid://125809050313880",
		SoundId = "rbxassetid://78439444151879",
		Volume = 5,
	},
	{
		Name = "Crying",
		AnimId = "rbxassetid://96313533433486",
		SoundId = "rbxassetid://18151791880",
		Volume = 5,
	},
	{
		Name = "Ogame",
		AnimId = "rbxassetid://117778295104747",
		SoundId = "rbxassetid://122457089809687",
		Volume = 5,
	},
	{
		Name = "Blue Shirt Kid",
		AnimId = "rbxassetid://83396620848313",
		SoundId = "rbxassetid://115875415839739",
		Volume = 5,
	},
	{ Name = "Zepelli", AnimId = "rbxassetid://135418027114658", SoundId = nil, Volume = 5 },
	{
		Name = "Woke Up The World",
		AnimId = "rbxassetid://130106286443990",
		SoundId = "rbxassetid://0275579621574",
		Volume = 5,
	},
	{
		Name = "Mask",
		AnimId = "rbxassetid://102176887169297",
		SoundId = "rbxassetid://97952595881264",
		Volume = 5,
	},
}

local stopEmote, playEmote

do
	local v2 = nil
	local tbl4 = nil
	local flag2 = false
	local v3 = nil

	stopEmote = function()
		if v2 then
			pcall(function()
				v2:Stop()
			end)

			v2 = nil
		end

		if tbl4 then
			if type(tbl4) == "table" then
				for _, v4 in ipairs(tbl4) do
					pcall(function()
						v4:Stop()
					end)

					pcall(function()
						v4:Destroy()
					end)
				end
			else
				pcall(function()
					tbl4:Stop()
				end)

				pcall(function()
					tbl4:Destroy()
				end)
			end

			tbl4 = nil
		end

		flag2 = false

		if v3 then
			(nil):SetText("Play Emote")
		end
	end

	playEmote = function(arg)
		stopEmote()
		if not arg or not arg.AnimId then
			return
		end
		local v4 = MainModule.get_humanoid(MainModule.get_character())
		if not v4 then
			return
		end
		local animation = Instance.new("Animation")
		animation.AnimationId = arg.AnimId

		local ok, result = pcall(function()
			return v4:LoadAnimation(animation)
		end)

		if not ok or not result then
			return
		end
		v2 = result

		pcall(function()
			result.Looped = true
		end)

		result:Play()

		if arg.SoundId then
			local soundId = arg.SoundId
			local tbl5

			if type(soundId) == "string" then
				tbl5 = { soundId }
			else
				tbl5 = soundId
			end

			if type(tbl5) == "table" then
				tbl4 = {}

				for _, v5 in ipairs(tbl5) do
					if type(v5) == "string" and v5 ~= "" then
						local sound = Instance.new("Sound")
						sound.SoundId = v5
						sound.Volume = arg.Volume or 5
						sound.Looped = true
						sound.Parent = SoundService

						pcall(function()
							sound:Play()
						end)

						table.insert(tbl4, sound)
					end
				end
			end
		end

		flag2 = true
		fn4()
	end
end

local tbl4
tbl4 = {}

for _, v2 in ipairs(tbl3) do
	table.insert(tbl4, v2.Name)
end

local function fn9()
	MainModule.stopEmote = stopEmote
	MainModule.playEmote = playEmote

	if MainModule.is_mobile() then
		for _, v2 in ipairs(tbl3) do
			v2.Volume = 3
		end
	end
end

fn9()

MainModule.cleanup_everything = function()
	if MainModule.AutoKillHidersController then
		pcall(function() MainModule.AutoKillHidersController:Destroy() end)
		MainModule.AutoKillHidersController = nil
	end
	if MainModule.LightsOutHoverController then
		pcall(function() MainModule.LightsOutHoverController:Destroy() end)
		MainModule.LightsOutHoverController = nil
	end
	if MainModule.HelpPlayersController then
		pcall(function() MainModule.HelpPlayersController:Destroy() end)
		MainModule.HelpPlayersController = nil
	end
	if MainModule.PromptInteraction then
		pcall(function() MainModule.PromptInteraction:Destroy() end)
		MainModule.PromptInteraction = nil
	end
	MainModule.toggle_auto_win(false)
	MainModule.toggle_fly(false, true)
	MainModule.ToggleESP(false)
	MainModule.toggle_speed_hack(false)
	MainModule.toggle_remove_stun(false)
	MainModule.toggle_fov(false)
	MainModule.toggle_fullbright(false)
	MainModule.toggle_ambience(false)
	MainModule.toggle_rapid_fire(false)
	MainModule.toggle_infinite_ammo(false)
	MainModule.toggle_auto_next_game(false)
	MainModule.toggle_auto_safe(false)
	MainModule.toggle_auto_dodge(false)
	MainModule.toggle_auto_escape(false)
	MainModule.toggle_auto_pickup(false)
	MainModule.ToggleFreeGuard(false)
	MainModule.toggle_face_target(false)
	MainModule.toggle_god_mode(false)
	MainModule.toggle_remove_injury(false)
	MainModule.toggle_anti_break(false)
	MainModule.toggle_jump_rope_anti_fall(false)
	MainModule.toggle_glass_esp(false)
	MainModule.toggle_spikes_kill(false)
	MainModule.toggle_spikes_platform_teleport(false)
	MainModule.toggle_key_esp(false)
	MainModule.toggle_exit_door_esp(false)
	MainModule.ToggleEspGuards(false)
	MainModule.toggle_sky_squid_anti_fall(false)
	MainModule.toggle_void_kill(false)
	MainModule.toggle_mingle_void_kill(false)

	pcall(function()
		if MainModule.toggle_faster_sprint then
			MainModule.toggle_faster_sprint(false)
		end
	end)

	MainModule.toggle_zone_kill(false)
	MainModule.toggle_auto_choke(false)
	MainModule.ToggleInfiniteStamina(false)
	MainModule.toggle_desync(false)
	MainModule.stopEmote()

	if MainModule.AutoWinConnection then
		MainModule.AutoWinConnection:Disconnect()
		MainModule.AutoWinConnection = nil
	end

	pcall(function()
		if MainModule.Rebel and MainModule.Rebel.Connection then
			MainModule.Rebel.Connection:Disconnect()
			MainModule.Rebel.Connection = nil
		end
	end)

	if MainModule.Fly.Connection then
		MainModule.Fly.Connection:Disconnect()
		MainModule.Fly.Connection = nil
	end

	if MainModule.Fly.BodyVelocity then
		MainModule.Fly.BodyVelocity:Destroy()
		MainModule.Fly.BodyVelocity = nil
	end

	if MainModule.SpeedHackLoop then
		task.cancel(MainModule.SpeedHackLoop)
		MainModule.SpeedHackLoop = nil
	end

	if MainModule.FOVConnection then
		MainModule.FOVConnection:Disconnect()
		MainModule.FOVConnection = nil
	end

	if MainModule.FullbrightConnection then
		MainModule.FullbrightConnection:Disconnect()
		MainModule.FullbrightConnection = nil
	end

	if MainModule.ambienceConnection then
		MainModule.ambienceConnection:Disconnect()
		MainModule.ambienceConnection = nil
	end

	if MainModule.timeFixConnection then
		MainModule.timeFixConnection:Disconnect()
		MainModule.timeFixConnection = nil
	end

	if MainModule.motionBlur then
		MainModule.motionBlur:Destroy()
		MainModule.motionBlur = nil
	end

	if MainModule.AutoDodge.HeartbeatConnection then
		MainModule.AutoDodge.HeartbeatConnection:Disconnect()
		MainModule.AutoDodge.HeartbeatConnection = nil
	end

	for _, connection in pairs(MainModule.AutoDodge.Connections) do
		if connection then
			pcall(function()
				connection:Disconnect()
			end)
		end
	end

	MainModule.AutoDodge.Connections = {}

	if MainModule.AutoDodge.Remote and MainModule.AutoDodge.OriginalFireServer then
		pcall(function()
			MainModule.AutoDodge.Remote.FireServer = MainModule.AutoDodge.OriginalFireServer
		end)
	end

	if MainModule.AutoEscapeConnection then
		MainModule.AutoEscapeConnection:Disconnect()
		MainModule.AutoEscapeConnection = nil
	end

	for _, safetyPlatform in pairs(MainModule.SafetyPlatforms) do
		if safetyPlatform then
			pcall(function()
				safetyPlatform:Destroy()
			end)
		end
	end

	MainModule.SafetyPlatforms = {}

	if MainModule.AntiBreakConn then
		MainModule.AntiBreakConn:Disconnect()
		MainModule.AntiBreakConn = nil
	end

	if MainModule.JumpRopeAntiFall.Conn then
		MainModule.JumpRopeAntiFall.Conn:Disconnect()
		MainModule.JumpRopeAntiFall.Conn = nil
	end

	if MainModule.JumpRopeAntiFall.Platform then
		MainModule.JumpRopeAntiFall.Platform:Destroy()
		MainModule.JumpRopeAntiFall.Platform = nil
	end

	pcall(function()
		local glassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")

		if glassHolder then
			for _, child in pairs(glassHolder:GetChildren()) do
				for _, child2 in pairs(child:GetChildren()) do
					if child2:IsA("Model") then
						for _, descendant in pairs(child2:GetDescendants()) do
							if descendant:IsA("BasePart") and descendant:GetAttribute("GlassPart") then
								descendant.Color = Color3.fromRGB(163, 162, 165)
								descendant.Material = Enum.Material.Glass
								descendant.Transparency = 0
							end
						end
					end
				end
			end
		end
	end)

	for k, modifiedPart in pairs(MainModule.ModifiedParts) do
		if k and k.Parent then
			pcall(function()
				k.Size = modifiedPart.Size
				k.CanCollide = modifiedPart.CanCollide
				k.Transparency = modifiedPart.Transparency
			end)
		end
	end

	MainModule.ModifiedParts = {}

	for k, originalFireRate in pairs(MainModule.OriginalFireRates) do
		if k and k.Parent then
			pcall(function()
				k.Value = originalFireRate
			end)
		end
	end

	MainModule.OriginalFireRates = {}

	for k, v2 in pairs(MainModule.OriginalAmmo) do
		if k and k.Parent then
			pcall(function()
				k.Value = v2
			end)
		end
	end

	MainModule.OriginalAmmo = {}
	local v2 = MainModule.get_character()

	if v2 then
		local v3 = MainModule.get_humanoid(v2)

		if v3 then
			pcall(function()
				v3.WalkSpeed = 16
			end)
		end
	end

	MainModule.clear_esp()

	if MainModule.EspGuardsThread then
		task.cancel(MainModule.EspGuardsThread)
		MainModule.EspGuardsThread = nil
	end

	for _, espGuardsBoxe in pairs(MainModule.EspGuardsBoxes) do
		if espGuardsBoxe then
			pcall(function()
				espGuardsBoxe:Destroy()
			end)
		end
	end

	MainModule.EspGuardsBoxes = {}

	if MainModule.ExitDoorESPThread then
		task.cancel(MainModule.ExitDoorESPThread)
		MainModule.ExitDoorESPThread = nil
	end

	for _, exitDoorESPObject in pairs(MainModule.ExitDoorESPObjects) do
		if exitDoorESPObject then
			pcall(function()
				exitDoorESPObject:Destroy()
			end)
		end
	end

	MainModule.ExitDoorESPObjects = {}

	for _, keyESPBoxe in pairs(MainModule.KeyESPBoxes) do
		if keyESPBoxe then
			pcall(function()
				keyESPBoxe:Destroy()
			end)
		end
	end

	MainModule.KeyESPBoxes = {}

	if MainModule.KeyESPConnection then
		MainModule.KeyESPConnection:Disconnect()
		MainModule.KeyESPConnection = nil
	end

	if MainModule.SpikesKillFeature.PlatformPart then
		pcall(function()
			MainModule.SpikesKillFeature.PlatformPart:Destroy()
		end)

		MainModule.SpikesKillFeature.PlatformPart = nil
	end

	if MainModule.SpikesKillFeature.AnimationConnection then
		MainModule.SpikesKillFeature.AnimationConnection:Disconnect()
		MainModule.SpikesKillFeature.AnimationConnection = nil
	end

	if MainModule.SpikesKillFeature.CharacterAddedConnection then
		MainModule.SpikesKillFeature.CharacterAddedConnection:Disconnect()
		MainModule.SpikesKillFeature.CharacterAddedConnection = nil
	end

	if MainModule.SpikesKillFeature.SafetyCheckConnection then
		MainModule.SpikesKillFeature.SafetyCheckConnection:Disconnect()
		MainModule.SpikesKillFeature.SafetyCheckConnection = nil
	end

	if MainModule.SpikesKillFeature.AnimationCheckConnection then
		MainModule.SpikesKillFeature.AnimationCheckConnection:Disconnect()
		MainModule.SpikesKillFeature.AnimationCheckConnection = nil
	end

	for _, animationStoppedConnection in pairs(MainModule.SpikesKillFeature.AnimationStoppedConnections) do
		pcall(function()
			animationStoppedConnection:Disconnect()
		end)
	end

	MainModule.SpikesKillFeature.AnimationStoppedConnections = {}

	if MainModule.SpikesPlatformTeleport.Platform then
		pcall(function()
			MainModule.SpikesPlatformTeleport.Platform:Destroy()
		end)

		MainModule.SpikesPlatformTeleport.Platform = nil
	end

	if MainModule.SpikesPlatformTeleport.Connection then
		MainModule.SpikesPlatformTeleport.Connection:Disconnect()
		MainModule.SpikesPlatformTeleport.Connection = nil
	end

	if MainModule.ZoneKillFeature.AnimationConnection then
		MainModule.ZoneKillFeature.AnimationConnection:Disconnect()
		MainModule.ZoneKillFeature.AnimationConnection = nil
	end

	if MainModule.ZoneKillFeature.CharacterAddedConnection then
		MainModule.ZoneKillFeature.CharacterAddedConnection:Disconnect()
		MainModule.ZoneKillFeature.CharacterAddedConnection = nil
	end

	if MainModule.ZoneKillFeature.AnimationCheckConnection then
		MainModule.ZoneKillFeature.AnimationCheckConnection:Disconnect()
		MainModule.ZoneKillFeature.AnimationCheckConnection = nil
	end

	for _, animationStoppedConnection in pairs(MainModule.ZoneKillFeature.AnimationStoppedConnections) do
		pcall(function()
			animationStoppedConnection:Disconnect()
		end)
	end

	MainModule.ZoneKillFeature.AnimationStoppedConnections = {}

	if MainModule.VoidKillConn then
		MainModule.VoidKillConn:Disconnect()
		MainModule.VoidKillConn = nil
	end

	if MainModule.VoidKillCharConn then
		MainModule.VoidKillCharConn:Disconnect()
		MainModule.VoidKillCharConn = nil
	end

	for _, mingleConn in pairs(MainModule.MingleConns) do
		pcall(function()
			mingleConn:Disconnect()
		end)
	end

	MainModule.MingleConns = {}

	if MainModule.SkySquidAntiFall.Platform then
		pcall(function()
			MainModule.SkySquidAntiFall.Platform:Destroy()
		end)

		MainModule.SkySquidAntiFall.Platform = nil
	end

	if MainModule.SkySquidAntiFall.Conn then
		MainModule.SkySquidAntiFall.Conn:Disconnect()
		MainModule.SkySquidAntiFall.Conn = nil
	end

	for k, guardOriginalSize in pairs(MainModule.GuardOriginalSizes) do
		if k and k.Parent then
			pcall(function()
				k.Size = guardOriginalSize
			end)
		end
	end

	MainModule.GuardOriginalSizes = {}

	if MainModule.StaminaConns then
		for _, staminaConn in pairs(MainModule.StaminaConns) do
			pcall(function()
				staminaConn:Disconnect()
			end)
		end

		MainModule.StaminaConns = {}
	end

	if MainModule.GameStateMonitor.Connection then
		MainModule.GameStateMonitor.Connection:Disconnect()
		MainModule.GameStateMonitor.Connection = nil
	end

	if MainModule.noclipButton then
		pcall(function()
			MainModule.noclipButton:Destroy()
		end)

		MainModule.noclipButton = nil
	end

	if MainModule.noclipConnection then
		MainModule.noclipConnection:Disconnect()
		MainModule.noclipConnection = nil
	end

	if MainModule.attachConnection then
		MainModule.attachConnection:Disconnect()
		MainModule.attachConnection = nil
	end

	if MainModule.autoSearchConnection then
		MainModule.autoSearchConnection:Disconnect()
		MainModule.autoSearchConnection = nil
	end

	MainModule.destroySquares()

	if MainModule.CurrentBodyVelocity then
		MainModule.CurrentBodyVelocity:Destroy()
		MainModule.CurrentBodyVelocity = nil
	end

	if MainModule.FaceTargetModule.Connection then
		MainModule.FaceTargetModule.Connection:Disconnect()
		MainModule.FaceTargetModule.Connection = nil
	end

	MainModule.FaceTargetModule.Enabled = false
	MainModule.FullbrightEnabled = false
	MainModule.RemoveStunEnabled = false
	MainModule.AutoWinEnabled = false
	MainModule.AutoDodge.Enabled = false
	MainModule.AutoDodge.ActiveAnimations = {}
	MainModule.AutoDodge.LastAnimationStartTime = {}
	MainModule.AutoDodge.LastDodgeTime = 0
	local Lighting = game:GetService("Lighting")

	if MainModule.FullbrightSettings.Brightness then
		Lighting.Brightness = MainModule.FullbrightSettings.Brightness
		Lighting.ClockTime = MainModule.FullbrightSettings.ClockTime
		Lighting.FogEnd = MainModule.FullbrightSettings.FogEnd
		Lighting.GlobalShadows = MainModule.FullbrightSettings.GlobalShadows
		Lighting.OutdoorAmbient = MainModule.FullbrightSettings.OutdoorAmbient
		Lighting.Ambient = MainModule.FullbrightSettings.Ambient
	end

	pcall(function()
		workspace.CurrentCamera.FieldOfView = 70
	end)

	MainModule.Fly.Enabled = false
	MainModule.Fly.Speed = 50
	MainModule.SpeedHackEnabled = false
	MainModule.SpeedValue = 39
	MainModule.FOVEnabled = false
	MainModule.FOVValue = 120
	MainModule.AmbienceEnabled = false
	MainModule.RapidFireEnabled = false
	MainModule.InfiniteAmmoEnabled = false
	MainModule.AutoNextEnabled = false
	MainModule.AutoSafe.Enabled = false
	MainModule.AutoSafe.HasTeleported = false
	MainModule.AutoSafe.LowHPChecked = false
	MainModule.AutoEscapeEnabled = false
	MainModule.AutoPickupEnabled = false
	MainModule.FreeGuardSettings.Enabled = false
	MainModule.GodModeEnabled = false
	MainModule.RemoveInjuryEnabled = false
	MainModule.AntiBreakEnabled = false
	MainModule.JumpRopeAntiFall.Enabled = false
	MainModule.GlassESPEnabled = false
	MainModule.SpikesKillFeature.Enabled = false
	MainModule.SpikesPlatformTeleport.Enabled = false
	MainModule.KeyESPEnabled = false
	MainModule.ExitDoorESPEnabled = false
	MainModule.EspGuardsEnabled = false
	MainModule.SkySquidAntiFall.Enabled = false
	MainModule.VoidKillEnabled = false
	MainModule.MingleVoidKillEnabled = false
	MainModule.ZoneKillFeature.Enabled = false
	MainModule.AutoChokeEnabled = false
	MainModule.InfStaminaActive = false
	MainModule.noclipEnabled = false

	for _, v3 in ipairs({
		"toggle_free_cam",
		"toggle_noclip",
		"toggle_phantom_dash",
		"toggle_peabert_kill",
		"toggle_hide_nickname",
		"toggle_hide_all_nicknames",
		"toggle_custom_gravity",
		"toggle_custom_jump_power",
		"toggle_infinite_jump",
		"toggle_quicksilver",
		"toggle_parkour_artist",
		"toggle_visual_items",
		"toggle_free_title",
		"toggle_permanent_guard",
		"toggle_custom_player_tag",
		"toggle_private_server_plus",
		"toggle_lighter",
		"toggle_glass_vision",
		"toggle_player_esp",
		"toggle_esprgb",
		"toggle_auto_skip",
		"toggle_auto_vote",
		"toggle_auto_collect_bandage",
		"toggle_auto_collect_flashbang",
		"toggle_auto_collect_grenade",
		"toggle_rage_auto_qte",
		"toggle_legit_auto_qte",
		"toggle_auto_win",
		"toggle_auto_next_game",
		"toggle_auto_safe",
		"toggle_speed_hack",
		"toggle_fly",
		"toggle_fov",
		"toggle_fullbright",
		"toggle_no_cooldown_proximity",
		"toggle_custom_win",
		"toggle_custom_level",
	}) do
		local v4 = MainModule[v3]

		if type(v4) == "function" then
			pcall(function()
				v4(false)
			end)
		end
	end

	if MainModule.KeybindConns then
		for _, keybindConn in pairs(MainModule.KeybindConns) do
			pcall(function()
				keybindConn:Disconnect()
			end)
		end

		MainModule.KeybindConns = {}
	end

	pcall(function()
		if MainModule.toggle_free_cam then
			MainModule.toggle_free_cam(false)
		end

		if MainModule.toggle_noclip then
			MainModule.toggle_noclip(false)
		end

		if MainModule.toggle_phantom_dash then
			MainModule.toggle_phantom_dash(false)
		end

		if MainModule.toggle_peabert_kill then
			MainModule.toggle_peabert_kill(false)
		end
	end)

	cursorVisible = false

	pcall(function()
		if _G.HollyScriptX_CursorDrawings then
			for _, hollyScriptXCursorDrawing in ipairs(_G.HollyScriptX_CursorDrawings) do
				pcall(function()
					hollyScriptXCursorDrawing.Visible = false

					if hollyScriptXCursorDrawing.Remove then
						hollyScriptXCursorDrawing:Remove()
					end
				end)
			end
		end

		if _G.HollyScriptX_CursorConnections then
			for _, hollyScriptXCursorConnection in ipairs(_G.HollyScriptX_CursorConnections) do
				pcall(function()
					hollyScriptXCursorConnection:Disconnect()
				end)
			end
		end
	end)

	pcall(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end)

	pcall(function()
		UserInputService.MouseIconEnabled = true
	end)
end

task.defer(function()
	task.wait(0.5)

	pcall(function()
		if MainModule.update_all_toggles_by_game then
			MainModule.update_all_toggles_by_game()
		end
	end)
end)

-- Removed an undefined ambient webhook invocation from the upstream startup code.

lib.CornerRadius = 12

pcall(function()
	if type(lib.SetCornerRadius) == "function" then
		lib:SetCornerRadius(12)
	end
end)

lib.CornerRadius = 12
local v2

v2 = lib:CreateWindow({
	Title = "Ishak Hub",
	Icon = png or "rbxassetid://0",
	Center = true,
	Footer = "discord.gg/hollyscriptx-1504482964661076098 | Ink Game",
	Resizable = true,
	AutoShow = true,
	ShowCustomCursor = false,
	ToggleKeybind = Enum.KeyCode.Z,
	AlwaysOnTop = true,
	Acrylic = true,
})

pcall(function()
	if lib.SetAlwaysOnTop then
		lib:SetAlwaysOnTop(true)
	end

	if lib.ToggleAcrylic then
		lib:ToggleAcrylic(true)
	end

	if lib.SetAcrylic then
		lib:SetAcrylic(true)
	end

	if type(lib.Acrylic) ~= "nil" then
		lib.Acrylic = true
	end
end)

task.defer(function()
	pcall(function()
		local tbl5 = {}

		if lib.ScreenGui then
			table.insert(tbl5, lib.ScreenGui)
		end

		if typeof(v2) == "table" and v2.Root then
			table.insert(tbl5, v2.Root)
		end

		for _, v3 in ipairs(tbl5) do
			if typeof(v3) == "Instance" then
				for _, descendant in ipairs(v3:GetDescendants()) do
					if descendant:IsA("UICorner") then
						descendant.CornerRadius = UDim.new(0, 12)
					end
				end

				v3.DescendantAdded:Connect(function(descendant)
					if descendant:IsA("UICorner") then
						task.defer(function()
							pcall(function()
								descendant.CornerRadius = UDim.new(0, 12)
							end)
						end)
					end
				end)
			end
		end
	end)
end)

pcall(function()
	if lib.KeybindFrame then
		lib.KeybindFrame.Visible = false
	end
end)

if _G.HollyScriptX_CursorConnections then
	for _, hollyScriptXCursorConnection in ipairs(_G.HollyScriptX_CursorConnections) do
		pcall(function()
			hollyScriptXCursorConnection:Disconnect()
		end)
	end
end

_G.HollyScriptX_CursorConnections = {}

if _G.HollyScriptX_CursorDrawings then
	for _, hollyScriptXCursorDrawing in ipairs(_G.HollyScriptX_CursorDrawings) do
		pcall(function()
			if hollyScriptXCursorDrawing.Remove then
				hollyScriptXCursorDrawing:Remove()
			end
		end)
	end
end

_G.HollyScriptX_CursorDrawings = {}

pcall(function()
	local playerGui = localPlayer2:FindFirstChild("PlayerGui")

	if playerGui then
		local hollyScriptXCursor = playerGui:FindFirstChild("HollyScriptX_Cursor")

		if hollyScriptXCursor then
			hollyScriptXCursor:Destroy()
		end
	end
end)

do
	local color = Color3.fromRGB(225, 225, 230)
	local color2 = Color3.fromRGB(0, 0, 0)
	local color3 = Color3.fromRGB(225, 225, 230)
	local n = 7
	local n2 = 13
	local n3 = 1.8
	cursorVisible = true
	local tbl5 = {}

	for i = 1, 4 do
		local line = Drawing.new("Line")
		line.Color = color2
		line.Thickness = 7
		line.Transparency = 1
		line.Visible = true
		table.insert(tbl5, line)
		table.insert(_G.HollyScriptX_CursorDrawings, line)
	end

	local tbl6 = {}

	for i = 1, 4 do
		local line = Drawing.new("Line")
		line.Color = color
		line.Thickness = 3.5
		line.Transparency = 1
		line.Visible = true
		table.insert(tbl6, line)
		table.insert(_G.HollyScriptX_CursorDrawings, line)
	end

	local text = Drawing.new("Text")
	text.Text = "Ishak Hub"
	text.Color = color3
	text.Size = 22
	text.Center = true
	text.Outline = true
	text.OutlineColor = color2
	text.Font = Drawing.Fonts.Plex
	text.Transparency = 1
	text.Visible = true
	table.insert(_G.HollyScriptX_CursorDrawings, text)

	local connection = RunService2.RenderStepped:Connect(function()
		if not cursorVisible then
			for _, hollyScriptXCursorDrawing in pairs(_G.HollyScriptX_CursorDrawings) do
				hollyScriptXCursorDrawing.Visible = false
			end

			return
		end

		local mouseLocation = UserInputService:GetMouseLocation()
		local x = mouseLocation.X
		local y = mouseLocation.Y
		local n4 = tick() * n3

		for i = 1, 4 do
			local n5 = n4 + (i - 1) * 1.5707963267948966
			local v3 = math.cos(n5)
			local v4 = math.sin(n5)
			local vector2 = Vector2.new(x + v3 * n, y + v4 * n)
			local vector22 = Vector2.new(x + v3 * (n + n2), y + v4 * (n + n2))
			tbl5[i].From = vector2
			tbl5[i].To = vector22
			tbl5[i].Visible = true
			tbl6[i].From = vector2
			tbl6[i].To = vector22
			tbl6[i].Visible = true
		end

		text.Position = Vector2.new(x, y + 32)
		text.Visible = true
	end)

	table.insert(_G.HollyScriptX_CursorConnections, connection)
end

MainModule.guiCreated = true
_G.HSX_Window = v2
local addTab = v2.AddTab

v2.Tab = function(arg, arg2)
	local tbl5 = arg2 or {}
	local v3 = addTab(v2, tbl5.Title or "Tab", tbl5.Icon)
	local v4 = MainModule.wrapTab(v3)
	v4._raw = v3
	return v4
end

v2.AddTab = function(arg, arg2, arg3)
	local v3 = addTab(v2, arg2, arg3)
	local v4 = MainModule.wrapTab(v3)
	v4._raw = v3
	return v4
end

v2.SetToggleKey = function(arg, toggleKeybind)
	pcall(function()
		lib.ToggleKeybind = toggleKeybind
	end)
end

v2.Destroy = function()
	pcall(function()
		lib:Unload()
	end)
end

v2.ToggleTransparency = function()
end

v2.SetTheme = function()
end

lib:SetDPIScale(100)

task.defer(function()
	for i in ipairs(MainModule.pendingNotifications) do
	end

	MainModule.pendingNotifications = {}
end)

local fn10

fn10 = function(arg, ...)
	if type(arg) ~= "function" then
		return
	end
	local tbl5 = { ... }

	task.spawn(function()
		local ok, result = pcall(arg, table.unpack(tbl5))

		if ok then
		end
	end)
end

MainModule.LightsOutSafe = { Enabled = false, SavedCFrame = nil, Wall = nil }

MainModule.toggle_lights_out_safezone = function(arg)
	local enabled = arg and true or false
	MainModule.LightsOutSafe.Enabled = enabled
	local getCharacter = MainModule.get_character and MainModule.get_character() or localPlayer2.Character
	local humanoidRootPart

	if getCharacter then
		humanoidRootPart = getCharacter:FindFirstChild("HumanoidRootPart") or getCharacter.PrimaryPart
	else
		humanoidRootPart = getCharacter
	end

	if enabled then
		if humanoidRootPart then
			MainModule.LightsOutSafe.SavedCFrame = humanoidRootPart.CFrame

			pcall(function()
				humanoidRootPart.CFrame = CFrame.new(178, 56, 50)
				MainModule.notify("lights out tp", "teleported success", 0.9)
			end)
		end

		fn4()
		return true
	end

	if humanoidRootPart and MainModule.LightsOutSafe.SavedCFrame then
		pcall(function()
			humanoidRootPart.CFrame = MainModule.LightsOutSafe.SavedCFrame
			MainModule.notify("lights out tp", "teleported back success", 0.9)
		end)
	end

	MainModule.LightsOutSafe.SavedCFrame = nil
	fn4()
	return true
end

do
	local v3 = v2:Tab({ Title = "Information", Icon = "info", Desc = "Discord information" }):Section({ Title = "Discord", Icon = "message-circle", Opened = true })
	local v4 = v3:Paragraph({ Title = "Server: ..." })
	local v5 = v3:Paragraph({ Title = "Total Members: ..." })
	local v6 = v3:Paragraph({ Title = "Online Members: ..." })

	v3:Button({
		Title = "Copy Discord Invite",
		Callback = function()
			pcall(function()
				setclipboard("https://discord.gg/hollyscriptx-1504482964661076098")
			end)

			fn2("Discord", "ok copied link", 1.2)
		end,
	})

	task.spawn(function()
		for _, v7 in ipairs({ "hsx", "fBTP3ry53Q" }) do
			local ok, result = pcall(function()
				return game:HttpGet("https://discord.com/api/v10/invites/" .. v7 .. "?with_counts=true")
			end)

			if ok and result then
				local ok2, result2 = pcall(function()
					return HttpService:JSONDecode(result)
				end)

				if ok2 and result2 and result2.guild then
					pcall(function()
						v4:SetTitle("Server: " .. tostring(result2.guild.name))
						v5:SetTitle("Members: " .. tostring(result2.approximate_member_count or "?"))
						v6:SetTitle("Online: " .. tostring(result2.approximate_presence_count or "?"))
					end)

					break
				end
			end
		end
	end)
end

MainModule.Keybinds = MainModule.Keybinds or {}
MainModule.KeybindConns = MainModule.KeybindConns or {}
MainModule.KeybindUI = MainModule.KeybindUI or {}
MainModule._KeybindPress = MainModule._KeybindPress or {}
MainModule._KeybindToggleRefs = MainModule._KeybindToggleRefs or {}
MainModule._KeybindIgnoreUntil = 0
MainModule._KeybindSetting = false

MainModule.HSXNormalizeKey = function(arg)
	if arg == nil then
		return "None"
	end

	if typeof(arg) == "EnumItem" then
		return arg.Name
	end

	if type(arg) == "boolean" then
		return "None"
	end
	local str = tostring(arg)
	if str == "" or str == "nil" or str == "Nil" or str == "true" or str == "false" then
		return "None"
	end
	local str2 = str:gsub("^Enum%.KeyCode%.", ""):gsub("^KeyCode%.", "")
	local match = str2:match("([%w_]+)$") or str2
	if match == "" then
		return "None"
	end
	return match
end

if not MainModule._KeybindDispatcher then
	MainModule._KeybindDispatcher = UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if UserInputService:GetFocusedTextBox() then
			return
		end

		if MainModule._KeybindSetting then
			return
		end

		if tick() < (MainModule._KeybindIgnoreUntil or 0) then
			return
		end
		local name = input.KeyCode and input.KeyCode.Name
		if not name or name == "Unknown" then
			return
		end
		local keybindPress = MainModule._KeybindPress or {}
		local keybinds = MainModule.Keybinds or {}

		for k, keybind in pairs(keybinds) do
			if k ~= "Menu" then
				local v3 = MainModule.HSXNormalizeKey(keybind)

				if v3 ~= "None" and v3 ~= "" and string.lower(v3) == string.lower(name) then
					local v4 = keybindPress[k]

					if type(v4) == "function" then
						MainModule._KeybindLastFire = MainModule._KeybindLastFire or {}
						local now = tick()

						if (MainModule._KeybindLastFire[k] or 0) + 0.15 <= now then
							MainModule._KeybindLastFire[k] = now

							task.spawn(function()
								pcall(v4)
							end)
						end
					end
				end
			end
		end
	end)
end

MainModule.HSXRegisterKeybind = function(arg, arg2, arg3)
	if arg3 then
		MainModule._KeybindPress[arg] = arg3
	end

	if arg2 ~= nil then
		MainModule.Keybinds[arg] = MainModule.HSXNormalizeKey(arg2)
	end
end

MainModule.HSXSyncKeybindUI = function(arg, arg2)
	local v3 = MainModule.HSXNormalizeKey(arg2)
	MainModule._KeybindSetting = true
	local keybindUI = MainModule.KeybindUI and MainModule.KeybindUI[arg]

	if keybindUI then
		for _, v4 in ipairs(keybindUI) do
			pcall(function()
				if v4.SetValue then
					v4:SetValue(v3)
				elseif v4.Set then
					v4:Set(v3)
				end
			end)
		end
	end

	local settingsKeybindEls = MainModule._SettingsKeybindEls and MainModule._SettingsKeybindEls[arg]

	if settingsKeybindEls then
		pcall(function()
			if settingsKeybindEls.SetValue then
				settingsKeybindEls:SetValue(v3)
			elseif settingsKeybindEls.Set then
				settingsKeybindEls:Set(v3)
			end
		end)
	end

	pcall(function()
		local options = lib.Options and (lib.Options[arg .. "Key"] or lib.Options["SettingsKB_" .. arg])

		if options and options.SetValue then
			options:SetValue(v3)
		end
	end)

	task.defer(function()
		task.wait(0.08)
		MainModule._KeybindSetting = false
	end)
end

MainModule.HSXSetKeybind = function(arg, arg2)
	local v3 = MainModule.HSXNormalizeKey(arg2)
	if MainModule.Keybinds[arg] == v3 then
		MainModule.HSXSyncKeybindUI(arg, v3)
		return
	end
	MainModule.Keybinds[arg] = v3
	MainModule._KeybindIgnoreUntil = tick() + 0.12

	if MainModule._KeybindPress[arg] then
		MainModule.HSXRegisterKeybind(arg, v3, MainModule._KeybindPress[arg])
	end

	MainModule.HSXSyncKeybindUI(arg, v3)
end

MainModule._ToggleStates = MainModule._ToggleStates or {}
MainModule._KeybindMenuRefs = MainModule._KeybindMenuRefs or {}
MainModule.ConfigRegistry = MainModule.ConfigRegistry or {}

MainModule.HSXRegisterConfig = function(arg, arg2, arg3, arg4, arg5)
	if not arg then
		return
	end
	MainModule.ConfigRegistry[arg] = { get = arg2, set = arg3, kind = arg4 or "toggle", ref = arg5 }
end

MainModule.HSXTrackToggle = function(arg, arg2, arg3, arg4)
	MainModule._AllToggleRefs = MainModule._AllToggleRefs or {}
	MainModule._ConfigGetters = MainModule._ConfigGetters or {}
	MainModule._ConfigSetters = MainModule._ConfigSetters or {}
	MainModule._AllToggleRefs[arg] = arg2

	if arg3 then
		MainModule._ConfigGetters[arg] = arg3
	end

	if arg4 then
		MainModule._ConfigSetters[arg] = arg4
	end
end

MainModule.HSXForceToggleVisual = function(arg, arg2)
	if not arg then
		return
	end
	local value = arg2 and true or false

	pcall(function()
		if arg.Set then
			arg:Set(value)
		end
	end)

	pcall(function()
		if arg.SetValue then
			arg:SetValue(value)
		end
	end)

	pcall(function()
		if arg.SetState then
			arg:SetState(value)
		end
	end)

	pcall(function()
		arg.Value = value
	end)

	pcall(function()
		if arg.Update then
			arg:Update(value)
		end
	end)

	pcall(function()
		if arg.UIElements and arg.UIElements.Main then
			local main = arg.UIElements.Main

			if main.Set then
				main:Set(value)
			end
		end
	end)

	pcall(function()
		if type(arg) == "table" and arg.__type == "Toggle" and arg.Set then
			arg:Set(value)
		end
	end)
end

MainModule.HSXSetToggleUI = function(arg, arg2)
	local flag2 = arg2 and true or false
	MainModule._ToggleStates[arg] = flag2
	if MainModule._SuppressUI then
		return
	end
	MainModule._SuppressUI = true
	local tbl5 = {}
	local tbl6 = {}
	local keybindToggleRefs = MainModule._KeybindToggleRefs and MainModule._KeybindToggleRefs[arg]
	local allToggleRefs = MainModule._AllToggleRefs and MainModule._AllToggleRefs[arg]
	local tog_ = MainModule._KeybindMenuRefs and MainModule._KeybindMenuRefs[arg] and MainModule._KeybindMenuRefs[arg].tog
	tbl6[1] = keybindToggleRefs
	tbl6[2] = allToggleRefs
	tbl6[3] = tog_

	if MainModule.ConfigRegistry and MainModule.ConfigRegistry[arg] and MainModule.ConfigRegistry[arg].ref then
		table.insert(tbl6, MainModule.ConfigRegistry[arg].ref)
	end

	for _, v3 in ipairs(tbl6) do
		if v3 and not tbl5[v3] then
			tbl5[v3] = true
			MainModule.HSXForceToggleVisual(v3, flag2)
		end
	end

	MainModule._SuppressUI = false
end

MainModule.HSXToggle = function(arg, arg2)
	local id = arg2.Id or arg2.Title
	local callback = arg2.Callback
	local v3 = nil

	v3 = arg:Toggle({
		Title = arg2.Title,
		Desc = arg2.Desc or arg2.Tooltip,
		Value = arg2.Value or false,
		Callback = function(arg3)
			if MainModule._SuppressUI then
				local toggleStates = MainModule._ToggleStates
				local v4 = id
				arg3 = arg3 and true
				toggleStates[v4] = arg3 or false
				return
			end

			MainModule._ToggleStates[id] = arg3 and true or false
			local flag2 = true

			if callback then
				local ok, result = pcall(callback, arg3)

				if ok and result == false then
					flag2 = false
				end

				if not ok then
					flag2 = false
				end
			end

			if flag2 == false then
				MainModule._ToggleStates[id] = false
				MainModule._SuppressUI = true

				pcall(function()
					if v3.Set then
						v3:Set(false)
					elseif v3.SetValue then
						v3:SetValue(false)
					end
				end)

				MainModule._SuppressUI = false
			end
		end,
	})

	MainModule.HSXTrackToggle(id, v3, function()
		return MainModule._ToggleStates[id] == true
	end, function(arg3)
		MainModule._ToggleStates[id] = arg3 and true or false
		if callback then
			return callback(arg3)
		end
		return true
	end)

	return v3
end

MainModule.HSXToggleWithKey = function(arg, arg2, arg3, arg4, arg5, arg6, arg7)
	MainModule._KeybindToggleTitles = MainModule._KeybindToggleTitles or {}
	MainModule._KeybindToggleTitles[arg3] = arg2
	MainModule.Keybinds = MainModule.Keybinds or {}
	MainModule._KeybindPress = MainModule._KeybindPress or {}

	if MainModule.Keybinds[arg3] == nil then
		MainModule.Keybinds[arg3] = arg4 and arg4 ~= "" and arg4 or "None"
	end

	local v3 = MainModule.Keybinds[arg3]
	MainModule._AllToggleRefs = MainModule._AllToggleRefs or {}
	MainModule._KeybindToggleRefs = MainModule._KeybindToggleRefs or {}

	local v4 = arg:Toggle({
		Title = arg2,
		Desc = arg7 or arg2,
		Value = false,
		Callback = function(arg8)
			if MainModule._SuppressUI then
				local toggleStates = MainModule._ToggleStates
				local v4 = arg3
				arg8 = arg8 and true
				toggleStates[v4] = arg8 or false
				return
			end

			if arg6(arg8) == false then
				MainModule._SuppressUI = true

				pcall(function()
					if tog.Set then
						tog:Set(false)
					elseif tog.SetValue then
						tog:SetValue(false)
					end
				end)

				MainModule._SuppressUI = false
				MainModule._ToggleStates[arg3] = false
				return
			end

			MainModule._ToggleStates[arg3] = arg8 and true or false
		end,
	})

	local function fn11()
		local flag2 = false

		pcall(function()
			flag2 = arg5()
		end)

		local flag3 = not flag2
		if arg6(flag3) == false then
			MainModule.HSXSetToggleUI(arg3, false)
			return
		end
		MainModule._ToggleStates[arg3] = flag3
		MainModule.HSXSetToggleUI(arg3, flag3)
		local flag4 = false

		pcall(function()
			flag4 = arg5()
		end)

		pcall(fn4)
	end

	MainModule._KeybindPress[arg3] = fn11
	MainModule.HSXRegisterKeybind(arg3, v3, fn11)

	pcall(function()
		local str = v3 and v3 ~= "" and v3 ~= "None" and v3 or "None"

		if v4.AddKeyPicker then
			local v5 = v4:AddKeyPicker(arg3 .. "Key", {
				Default = str,
				Mode = "Toggle",
				Text = arg2,
				SyncToggleState = false,
				NoUI = false,
				Callback = function(arg8)
					if MainModule._KeybindSetting then
						return
					end
					local v5 = MainModule.HSXNormalizeKey(arg8)
					MainModule._KeybindIgnoreUntil = tick() + 0.12
					MainModule.Keybinds[arg3] = v5
					MainModule.HSXRegisterKeybind(arg3, v5, fn11)
				end,
				Clicked = function()
					fn11()
				end,
			})

			MainModule.KeybindUI = MainModule.KeybindUI or {}
			MainModule.KeybindUI[arg3] = MainModule.KeybindUI[arg3] or {}

			if v5 then
				table.insert(MainModule.KeybindUI[arg3], v5)
			end
		elseif arg.Keybind then
			local v5 = arg:Keybind({
				Title = arg2 .. " Keybind",
				Value = str,
				Callback = function(arg8)
					if MainModule._KeybindSetting then
						return
					end
					local v5 = MainModule.HSXNormalizeKey(arg8)
					MainModule.Keybinds[arg3] = v5
					MainModule.HSXRegisterKeybind(arg3, v5, fn11)
				end,
			})

			MainModule.KeybindUI = MainModule.KeybindUI or {}
			MainModule.KeybindUI[arg3] = MainModule.KeybindUI[arg3] or {}

			if v5 then
				table.insert(MainModule.KeybindUI[arg3], v5)
			end
		end
	end)

	MainModule._KeybindToggleRefs[arg3] = v4
	MainModule._AllToggleRefs[arg3] = v4

	MainModule.HSXRegisterConfig(arg3, function()
		local ok, result = pcall(arg5)
		if ok then
			return result and true or false
		end
		return MainModule._ToggleStates[arg3] == true
	end, function(arg8)
		local v5 = arg6(arg8)
		MainModule._ToggleStates[arg3] = v5 ~= false and (arg8 and true or false) or false
		MainModule.HSXSetToggleUI(arg3, MainModule._ToggleStates[arg3])
		return v5
	end, "toggle", v4)

	return v4
end

MainModule.HSXCollapse = function(arg, arg2)
	if not arg then
		return
	end
	local visible = not arg2

	if type(arg) == "table" then
		if pcall(function()
			if type(arg.SetVisible) == "function" then
				arg:SetVisible(visible)
			elseif arg.Visible ~= nil then
				arg.Visible = visible
			end
		end) then
			return
		end
	end

	if typeof(arg) == "Instance" and arg:IsA("GuiObject") then
		arg.Visible = visible
	end
end

MainModule.HSXShowHide = function(arg, arg2)
	MainModule.HSXCollapse(arg, not arg2)
end

MainModule._SliderStates = MainModule._SliderStates or {}
MainModule._SliderRefs = MainModule._SliderRefs or {}
MainModule._SliderSetters = MainModule._SliderSetters or {}
MainModule._SliderLinks = MainModule._SliderLinks or {}

MainModule.HSXBindSlider = function(arg, arg2)
	local id = arg2.Id or arg2.Title

	local tbl5 = {
		el = nil,
		value = arg2.defaultValue or arg2.Value and arg2.Value.Default or 0,
		id = id,
		parentId = arg2.ParentId,
	}

	MainModule._SliderStates[id] = tbl5.value

	tbl5.el = arg:Slider({
		Title = arg2.Title,
		Value = { Min = arg2.Value.Min, Max = arg2.Value.Max, Default = tbl5.value or arg2.Value.Default },
		Step = arg2.Step,
		Callback = function(value)
			tbl5.value = value
			MainModule._SliderStates[id] = value

			if arg2.Callback then
				arg2.Callback(value)
			end
		end,
	})

	MainModule._SliderRefs[id] = tbl5
	MainModule._SliderSetters[id] = arg2.Callback

	if arg2.ParentId then
		MainModule._SliderLinks[arg2.ParentId] = MainModule._SliderLinks[arg2.ParentId] or {}
		table.insert(MainModule._SliderLinks[arg2.ParentId], tbl5)
	end

	MainModule.HSXRegisterConfig(id, function()
		return MainModule._SliderStates[id]
	end, function(value)
		MainModule._SliderStates[id] = value
		tbl5.value = value

		if arg2.Callback then
			pcall(arg2.Callback, value)
		end

		pcall(function()
			if tbl5.el then
				if tbl5.el.SetValue then
					tbl5.el:SetValue(value)
				elseif tbl5.el.Set then
					tbl5.el:Set(value)
				end
			end
		end)
	end, "slider", tbl5)

	pcall(function()
		if tbl5.el and tbl5.el.SetVisible then
			tbl5.el:SetVisible(false)
		end
	end)

	tbl5.ensure = function(arg3)
		local flag2 = arg3 and true or false

		pcall(function()
			if tbl5.el and tbl5.el.SetVisible then
				tbl5.el:SetVisible(flag2)
			elseif tbl5.el then
				MainModule.HSXCollapse(tbl5.el, not flag2)
			end
		end)

		if flag2 and tbl5.el then
			pcall(function()
				if tbl5.el.SetValue then
					tbl5.el:SetValue(tbl5.value)
				elseif tbl5.el.Set then
					tbl5.el:Set(tbl5.value)
				end
			end)
		end
	end

	return tbl5
end

MainModule.UISlider = function(arg, arg2)
	local id = arg2.Id or arg2.Title
	local callback = arg2.Callback
	local default = arg2.Default or arg2.Value and arg2.Value.Default or 0
	MainModule._SliderStates[id] = default

	local v3 = arg:Slider({
		Title = arg2.Title,
		Desc = arg2.Desc,
		Value = arg2.Value or { Min = 0, Max = 100, Default = default },
		Step = arg2.Step or 1,
		Callback = function(arg3)
			MainModule._SliderStates[id] = arg3

			if callback then
				pcall(callback, arg3)
			end
		end,
	})

	MainModule.HSXRegisterConfig(id, function()
		return MainModule._SliderStates[id]
	end, function(arg3)
		MainModule._SliderStates[id] = arg3

		if callback then
			pcall(callback, arg3)
		end

		pcall(function()
			if v3 and v3.Set then
				v3:Set(arg3)
			end
		end)
	end, "slider", v3)

	return v3
end

MainModule.UIInput = function(arg, arg2)
	local id = arg2.Id or arg2.Title
	local callback = arg2.Callback
	MainModule._InputStates = MainModule._InputStates or {}
	MainModule._InputStates[id] = arg2.Value or ""

	local v3 = arg:Input({
		Title = arg2.Title,
		Desc = arg2.Desc,
		Value = arg2.Value or "",
		Callback = function(arg3)
			MainModule._InputStates[id] = arg3

			if callback then
				pcall(callback, arg3)
			end
		end,
	})

	MainModule.HSXRegisterConfig(id, function()
		return MainModule._InputStates[id]
	end, function(arg3)
		MainModule._InputStates[id] = arg3

		if callback then
			pcall(callback, arg3)
		end

		pcall(function()
			if v3 and v3.Set then
				v3:Set(arg3)
			end
		end)
	end, "value", v3)

	return v3
end

MainModule.UIDropdown = function(arg, arg2)
	local id = arg2.Id or arg2.Title
	local callback = arg2.Callback
	MainModule._DropdownStates = MainModule._DropdownStates or {}
	MainModule._DropdownStates[id] = arg2.Value

	local v3 = arg:Dropdown({
		Title = arg2.Title,
		Desc = arg2.Desc,
		Values = arg2.Values,
		Value = arg2.Value,
		Callback = function(arg3)
			MainModule._DropdownStates[id] = arg3

			if callback then
				pcall(callback, arg3)
			end
		end,
	})

	MainModule.HSXRegisterConfig(id, function()
		return MainModule._DropdownStates[id]
	end, function(arg3)
		MainModule._DropdownStates[id] = arg3

		if callback then
			pcall(callback, arg3)
		end

		pcall(function()
			if v3 and v3.Set then
				v3:Set(arg3)
			elseif v3.Select then
				v3:Select(arg3)
			end
		end)
	end, "value", v3)

	return v3
end

MainModule.UICheckbox = function(arg, arg2)
	local tbl5 = arg2 or {}
	if not arg then
		return nil
	end

	if type(arg) == "table" and arg.Checkbox then
		return arg:Checkbox(tbl5)
	end
	return MainModule.UIToggle(arg, tbl5)
end

MainModule.UIToggle = function(arg, arg2)
	local tbl5 = arg2 or {}
	if not arg then
		return nil
	end
	local id = tbl5.Id or tbl5.Title and tostring(tbl5.Title):gsub("%s+", "") or "T" .. tostring(math.random(1, 99999))
	local callback = tbl5.Callback

	local v3 = arg:Toggle({
		Title = tbl5.Title,
		Desc = tbl5.Desc or tbl5.Tooltip,
		Value = tbl5.Value or false,
		Callback = function(arg3)
			if MainModule._SuppressUI then
				MainModule._ToggleStates = MainModule._ToggleStates or {}
				local toggleStates = MainModule._ToggleStates
				local v3 = id
				arg3 = arg3 and true or false
				toggleStates[v3] = arg3
				return
			end

			MainModule._ToggleStates = MainModule._ToggleStates or {}
			MainModule._ToggleStates[id] = arg3 and true or false

			if callback then
				pcall(callback, arg3)
			end
		end,
	})

	if MainModule.ToggleRefs then
		MainModule.ToggleRefs[id] = v3
	end

	MainModule._AllToggleRefs = MainModule._AllToggleRefs or {}
	MainModule._AllToggleRefs[id] = v3
	return v3
end

do
	local v3 = v2:Tab({ Title = "Games", Icon = "gamepad-2", Desc = "All minigame features" })
	local v4 = v3:Section({ Title = "Red Light Green Light", Icon = "traffic-cone", Opened = true })

	MainModule.UIToggle(v4, {
		Id = "RemoveInjury",
		Title = "Remove Injury",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_remove_injury, arg)
		end,
	})

	MainModule.UICheckbox(v4, {
		Id = "JumpWhileCrawling",
		Title = "Enable Jump while crawling",
		Desc = "Allows jumping even in Crawling state",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_jump_while_crawling, arg)
		end,
	})

	MainModule.UIDropdown(v4, {
		Title = "End Corner",
		Desc = "Left Corner or Right Corner for Teleport to End",
		Values = { "Left Corner", "Right Corner" },
		Value = "Left Corner",
		Callback = function(rlglEndCorner)
			MainModule.RLGLEndCorner = rlglEndCorner
		end,
	})

	v4:Button({
		Title = "Teleport to End",
		Callback = function()
			fn10(MainModule.rlgl_tp_end)
		end,
	})

-- Insert inside the existing Red Light Green Light section (v4).
do
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
    local nextRescueAt = 0
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

    local function isGameActive()
        if type(config.IsGameActive) == "function" then
            local ok, result = pcall(config.IsGameActive)
            return ok and result == true
        end
        return currentGame() == "RedLightGreenLight"
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
        if not isGameActive() then stop(true); return false end
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
        local prompt, releaseHold, releaseLease, dropContext
        local releaseFailed, promptConsumed = false, false
        local moved, reachedFinish = false, false
        local function releaseInteraction()
            -- Clear each callback before invoking it: cancellation/error cleanup is idempotent.
            local endHold, endLease = releaseHold, releaseLease
            releaseHold, releaseLease = nil, nil
            if endHold then
                local released, result = pcall(endHold)
                if not released or result == false then releaseFailed = true end
            end
            if endLease then
                local released, result = pcall(endLease)
                if not released or result == false then releaseFailed = true end
            end
            return not releaseFailed
        end
        local function pickupState(checkPrompt, checkRange)
            if not active(token, localCharacter) then return "cancelled" end
            if alive(player) ~= character then return "target" end
            -- Pickup can remove the injury marker and disable/remove its prompt.
            -- Only physical character linkage proves that this client is carrying the target.
            local owner = carrier(player, targetRoot)
            if owner == localPlayer then return "confirmed" end
            if owner then return "taken" end
            if not prompt.Parent or not prompt.Enabled then
                promptConsumed = true
                if checkPrompt then return "prompt" end
            end
            -- Injury/prompt removal can replicate before the carry joint. A consumed
            -- prompt permits only bounded waiting; it never establishes pickup proof.
            if not injured(player, character) and not promptConsumed then return "recovered" end
            if checkRange then
                local _, position = promptLocation(prompt, targetRoot)
                if distance(localRoot.Position, position) > (tonumber(prompt.MaxActivationDistance) or 10) then
                    return "range"
                end
            end
            return nil
        end
        local ok, outcome = pcall(function()
            if not finishCFrame() then return "finish" end
            if not active(token, localCharacter) then return "cancelled" end
            prompt = rescuePrompt(player, character)
            if not prompt then return "prompt" end
            if carrier(player, targetRoot) then return "taken" end
            if config.BeforePickup then
                local captured, context = pcall(config.BeforePickup)
                if captured then dropContext = context end
                if not active(token, localCharacter) then return "cancelled" end
                if alive(player) ~= character then return "target" end
                if carrier(player, targetRoot) then return "taken" end
                if not injured(player, character) then return "recovered" end
                if not prompt.Parent or not prompt.Enabled then return "prompt" end
            end
            local approach = promptLocation(prompt, targetRoot)
            moved = true
            if not teleport(localRoot, approach) then return "teleport" end
            waitFor(0.1)
            local state = pickupState(true, true)
            if state and state ~= "confirmed" then return state end
            local confirmed = state == "confirmed"
            if not confirmed then
                local duration = tonumber(prompt.HoldDuration)
                if config.AcquirePrompt then
                    local lease = config.AcquirePrompt(prompt)
                    if type(lease) ~= "table" or type(lease.Release) ~= "function" then
                        return "interaction"
                    end
                    releaseLease = lease.Release
                    duration = tonumber(lease.Duration)
                end
                if not duration or duration ~= duration or duration < 0 then return "holdlength" end
                if duration == 0 then duration = tonumber(config.FallbackHoldDuration) or 2 end
                -- Do not silently shorten a real prompt's required hold duration.
                if duration ~= duration or duration <= 0 or duration > 30 then return "holdlength" end
                releaseHold = function() prompt:InputHoldEnd() end
                if config.BeginHold then
                    local endHold = config.BeginHold(prompt)
                    if type(endHold) ~= "function" then return "interaction" end
                    releaseHold = endHold
                else
                    prompt:InputHoldBegin()
                end
                local holdDeadline = clock() + duration + 0.15
                while true do
                    state = pickupState(true, true)
                    if state == "confirmed" then confirmed = true; break end
                    -- A consumed prompt can precede replication of the carry joint.
                    -- Release input now, then use the same bounded confirmation window.
                    if state == "prompt" then break end
                    if state then return state end
                    local remaining = holdDeadline - clock()
                    if remaining <= 0 then break end
                    waitFor(math.min(0.05, remaining))
                end
            end
            -- Always release the held input and restore the lease before moving to the finish.
            if not releaseInteraction() then return "interaction" end
            local deadline = clock() + (tonumber(config.PickupTimeout) or 2.5)
            while not confirmed do
                state = pickupState(false, true)
                if state == "confirmed" then confirmed = true; break end
                if state then return state end
                local remaining = deadline - clock()
                if remaining <= 0 then break end
                waitFor(math.min(0.05, remaining))
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
                    if config.DropPlayer then
                        local function rescueActive()
                            return active(token, localCharacter)
                        end
                        local function stillCarrying()
                            return rescueActive() and alive(player) == character
                                and carrier(player, targetRoot) == localPlayer
                                and distance(localRoot.Position, destination.Position) <= 12
                                and distance(targetRoot.Position, destination.Position) <= 12
                                and distance(targetRoot.Position, localRoot.Position) <= 12
                        end
                        if stillCarrying() then
                            -- The host may activate only a verified game-owned release control.
                            -- Its errors must not undo an already confirmed rescue.
                            pcall(config.DropPlayer, dropContext, stillCarrying, rescueActive)
                            local releaseDeadline = clock() + 1
                            while rescueActive() and stillCarrying() do
                                local remaining = releaseDeadline - clock()
                                if remaining <= 0 then break end
                                waitFor(math.min(0.05, remaining))
                            end
                            if stillCarrying() then
                                notice("Help Players: release the player using the checkmark at the bottom right; automatic release was not confirmed.")
                            end
                        end
                    end
                    return "success"
                end
                waitFor(0.05)
            end
            return "follow"
        end)

        -- Cooperative cancellation always reaches this cleanup, including a throwing prompt API.
        releaseInteraction()
        if not ok then outcome = "error" end
        -- A cancelled controller must never move a new character or a new round.
        if moved and not reachedFinish and active(token, localCharacter) then
            teleport(localRoot, origin)
        end
        if outcome == "success" then
            completed[character] = true
            nextRescueAt = clock() + (tonumber(config.CycleDelay) or 5)
            return true, outcome
        end
        retryAt[character] = clock() + (config.RetryDelay or 5)
        if outcome == "finish" then notice("Help Players: the automatic Teleport to End destination is unavailable.")
        elseif outcome == "follow" then notice("Help Players: pickup confirmed, but arrival with the player was not confirmed.")
        elseif outcome ~= "cancelled" and outcome ~= "taken" then
            notice("Help Players: rescue was not confirmed; the attempt stopped.")
        end
        return false, outcome
    end

    function controller:Step(token)
        token = token or generation
        if busy or not active(token, enabledCharacter) then return false, "inactive" end
        if clock() < nextRescueAt then return false, "cooldown" end
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
        if not isGameActive() or (library and library.Unloaded) then
            notice("Help Players is available during Red Light Green Light.")
            syncToggle()
            return false
        end
        local character, humanoid = alive(localPlayer)
        if not character then syncToggle(); return false end
        if not finishCFrame() then
            notice("Help Players: the automatic Teleport to End destination is unavailable.")
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
            if not isGameActive() then stop(true) end
        end)
    end

    toggle = config.Group:AddToggle("RedLightHelpPlayers", {
        Text = "Help Players",
        Default = false,
        Tooltip = "Hold the pickup interaction, confirm the carried player, then use Teleport to End automatically. Wait five seconds between rescues.",
        Callback = function(value)
            if not syncingToggle then controller:SetEnabled(value) end
        end,
    })
    return controller
end
    end)()
    local createDropInteraction = (function()
-- Conservative local GUI adapter. The host supplies activation and confirms separation afterward.
-- Unknown game UI intentionally produces no click rather than guessing an image, key, or remote.
return function(config)
    local adapter, owner = {}, {}

    local function read(instance, property)
        if not instance then return nil end
        local ok, value = pcall(function() return instance[property] end)
        if ok then return value end
        return nil
    end

    local function isA(instance, className)
        if not instance then return false end
        local ok, value = pcall(function() return instance:IsA(className) end)
        return ok and value == true
    end

    local function descendants(instance)
        local ok, values = pcall(function() return instance:GetDescendants() end)
        if ok and type(values) == "table" then return values end
        return nil
    end

    local function playerGui()
        local gui = read(config.LocalPlayer, "PlayerGui")
        if gui then return gui end
        local ok, result = pcall(function()
            return config.LocalPlayer:FindFirstChildOfClass("PlayerGui")
                or config.LocalPlayer:FindFirstChild("PlayerGui")
        end)
        if ok then return result end
        return nil
    end

    local function excluded(instance)
        if type(config.IsExcluded) ~= "function" then return false end
        local ok, result = pcall(config.IsExcluded, instance)
        return not ok or result == true
    end

    local function visiblePath(instance, boundary)
        local current, seen = instance, {}
        while current and not seen[current] do
            seen[current] = true
            if excluded(current) or read(current, "Visible") == false
                or read(current, "Enabled") == false or read(current, "Interactable") == false then
                return false
            end
            if current == boundary then return true end
            current = read(current, "Parent")
        end
        return false
    end

    local function visible(button, gui)
        return isA(button, "GuiButton") and visiblePath(button, gui)
    end

    local function normalize(value)
        return tostring(value or ""):lower():gsub("[^a-z0-9]", "")
    end

    local dropNames = {
        drop = true, dropbutton = true, buttondrop = true,
        dropplayer = true, dropplayerbutton = true, buttondropplayer = true,
        dropcarriedplayer = true, dropcarriedplayerbutton = true,
        putdown = true, putdownbutton = true, buttonputdown = true,
        putdownplayer = true, putdownplayerbutton = true,
        release = true, releasebutton = true, buttonrelease = true,
        releaseplayer = true, releaseplayerbutton = true,
        carrydrop = true, carrydropbutton = true, dropcarry = true, dropcarrybutton = true,
    }
    local carryNames = {
        carry = true, carrying = true, carryplayer = true, carriedplayer = true,
        carryingplayer = true, playercarry = true, playercarrying = true,
        charactercarry = true,
    }
    local carrySuffixes = { "gui", "frame", "panel", "container", "controls", "menu", "ui", "hud", "widget", "screen" }
    for base in pairs(table.clone(carryNames)) do
        for _, suffix in ipairs(carrySuffixes) do carryNames[base .. suffix] = true end
    end

    local function checkText(value)
        if type(value) ~= "string" then return false end
        local text = value:gsub("<[^>]->", ""):match("^%s*(.-)%s*$")
        return text == "✓" or text == "✔" or text == "☑"
    end

    local function hasCheckmark(button)
        if checkText(read(button, "Text")) then return true end
        for _, item in ipairs(descendants(button) or {}) do
            if visiblePath(item, button) and checkText(read(item, "Text")) then return true end
        end
        return false
    end

    local function trustedIdentity(button, context)
        local current, carryContext = button, false
        for depth = 0, 3 do
            if not current then break end
            local name, text = normalize(read(current, "Name")), normalize(read(current, "Text"))
            if dropNames[name] or dropNames[text] then return true end
            if depth > 0 and (carryNames[name] or carryNames[text]) then carryContext = true end
            current = read(current, "Parent")
        end
        return carryContext and not context.VisibleButtons[button] and hasCheckmark(button)
    end

    local function dimensions(size)
        local x, y = read(size, "X"), read(size, "Y")
        if type(x) ~= "number" or type(y) ~= "number" or x ~= x or y ~= y
            or x <= 0 or y <= 0 or x == math.huge or y == math.huge then
            return nil
        end
        return x, y
    end

    local function preferredViewport()
        if type(config.GetViewportSize) ~= "function" then return nil end
        local ok, size = pcall(config.GetViewportSize)
        if ok and dimensions(size) then return size end
        return nil
    end

    local function bottomRight(button, gui, preferred)
        local viewport = preferred
        if not viewport and dimensions(read(gui, "AbsoluteSize")) then viewport = read(gui, "AbsoluteSize") end
        if not viewport then
            local current = read(button, "Parent")
            while current and current ~= gui do
                if isA(current, "ScreenGui") and dimensions(read(current, "AbsoluteSize")) then
                    viewport = read(current, "AbsoluteSize")
                    break
                end
                current = read(current, "Parent")
            end
        end
        local width, height = dimensions(viewport)
        local sizeX, sizeY = dimensions(read(button, "AbsoluteSize"))
        local position = read(button, "AbsolutePosition")
        local x, y = read(position, "X"), read(position, "Y")
        if not width or not sizeX or type(x) ~= "number" or type(y) ~= "number" then return false end
        local centerX, centerY = x + sizeX / 2, y + sizeY / 2
        return centerX >= width / 2 and centerX <= width and centerY >= height / 2 and centerY <= height
    end

    local function guard(callback)
        if type(callback) ~= "function" then return false end
        local ok, value = pcall(callback)
        return ok and value == true
    end

    function adapter:Capture()
        local context = { Owner = owner, VisibleButtons = setmetatable({}, { __mode = "k" }), Valid = false }
        local gui = playerGui()
        local items = gui and descendants(gui)
        if not items then return context end
        context.Gui = gui
        context.Valid = true
        for _, item in ipairs(items) do
            if visible(item, gui) then context.VisibleButtons[item] = true end
        end
        return context
    end

    function adapter:Drop(context, isCarrying, isActive)
        if not guard(isActive) then return false, "inactive" end
        if not guard(isCarrying) then return false, "notcarrying" end
        if type(context) ~= "table" or context.Owner ~= owner or not context.Valid then
            return false, "snapshot"
        end
        if type(config.Activate) ~= "function" then return false, "unsupported" end
        local gui = playerGui()
        if not gui or gui ~= context.Gui then return false, "snapshot" end
        local items = descendants(gui)
        if not items then return false, "missing" end
        local viewport, candidate = preferredViewport(), nil
        for _, item in ipairs(items) do
            if visible(item, gui) and bottomRight(item, gui, viewport) and trustedIdentity(item, context) then
                if candidate then return false, "ambiguous" end
                candidate = item
            end
        end
        if not candidate then return false, "missing" end
        if not visible(candidate, gui) or not bottomRight(candidate, gui, viewport)
            or not trustedIdentity(candidate, context) then
            return false, "missing"
        end
        if not guard(isActive) then return false, "inactive" end
        if not guard(isCarrying) then return false, "notcarrying" end
        local ok, result = pcall(config.Activate, candidate)
        if not ok or result == false then return false, "activation" end
        return true, "activated"
    end

    return adapter
end
    end)()
    local dropInteraction = createDropInteraction({
        LocalPlayer = localPlayer,
        GetViewportSize = function()
            local camera = Workspace.CurrentCamera
            return camera and camera.ViewportSize
        end,
        IsExcluded = function(instance)
            return lib.ScreenGui and instance:IsDescendantOf(lib.ScreenGui)
        end,
        Activate = function(button)
            if type(firesignal) ~= "function" then return false end
            local signal = button.MouseButton1Click
            if type(getconnections) == "function" then
                local clickOK, clickListeners = pcall(getconnections, signal)
                local activatedOK, activatedListeners = pcall(getconnections, button.Activated)
                if clickOK and activatedOK and type(clickListeners) == "table"
                    and type(activatedListeners) == "table" and #clickListeners == 0
                    and #activatedListeners > 0 then
                    firesignal(button.Activated, nil, 1)
                    return true
                end
            end
            firesignal(signal)
            return true
        end,
    })

    if MainModule.HelpPlayersController then
        pcall(function() MainModule.HelpPlayersController:Destroy() end)
    end

    local helpPlayersController = createHelpPlayers({
        Players = Players,
        Workspace = Workspace,
        LocalPlayer = localPlayer,
        Library = lib,
        Group = v4,
        IsGameActive = function()
            return MainModule.is_game_active("RedLightGreenLight")
        end,
        FinishCFrame = function()
            local positions = MainModule.RLGLEndPositions
            local position = positions and positions[MainModule.RLGLEndCorner or "Left Corner"]
            return position and CFrame.new(position)
        end,
        Teleport = function(root, destination)
            local character = localPlayer.Character
            local currentRoot = character and character:FindFirstChild("HumanoidRootPart")
            if not character or not character.Parent or root ~= currentRoot or not root.Parent then
                return false
            end
            return MainModule.safe_teleport(destination.Position)
        end,
        AcquirePrompt = function(prompt)
            local broker = MainModule.PromptInteraction
            local lease = broker and broker:Acquire(prompt)
            if lease and lease.Duration == 0 then
                -- A previous script may have lost the native duration by setting it to zero.
                -- Use an actual two-second local hold; the lease restores the recorded value.
                local adjusted = pcall(function() prompt.HoldDuration = 2 end)
                if not adjusted then lease.Release(); return nil end
                lease.Duration = 2
            end
            return lease
        end,
        CycleDelay = 5,
        BeforePickup = function() return dropInteraction:Capture() end,
        DropPlayer = function(context, isCarrying, isActive)
            local deadline = os.clock() + 1
            while isActive() and isCarrying() do
                local activated, reason = dropInteraction:Drop(context, isCarrying, isActive)
                if activated or reason ~= "missing" or os.clock() >= deadline then
                    return activated, reason
                end
                task.wait(0.05)
            end
            return false
        end,
        Notify = function(message)
            MainModule.notify("Help Players", message, 4)
        end,
    })

    MainModule.HelpPlayersController = helpPlayersController

    if type(lib.OnUnload) == "function" then
        lib:OnUnload(function()
            helpPlayersController:Destroy()
        end)
    end
end

	MainModule.UIToggle(v4, {
		Id = "GodMode",
		Title = "God Mode",
		Desc = "Teleports you high up to avoid being shooted by bullets",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_god_mode, arg)
		end,
	})

	MainModule.UIToggle(v4, {
		Id = "AutoStopRedLight",
		Title = "Auto Stop on Red Light",
		Desc = "Automatically freezes your character when Red Light is active to avoid getting shot, and unfreezes when Green Light is active",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_rlgl_stop, arg)
		end,
	})

	local v5 = v3:Section({ Title = "Lights Out", Icon = "moon", Opened = true })

-- Insert inside the existing Lights Out section (v5).
do
    local createLightsOutHover = (function()
-- Optional, round-aware hover. Owns only its attachment/constraint; never changes global gravity.
return function(config)
    local player = config.LocalPlayer or (config.Players and config.Players.LocalPlayer)
    local world, library = config.Workspace, config.Library
    local clock = config.Clock or os.clock
    local controller = {}
    local enabled, destroyed, stepping, syncing = false, false, false, false
    local generation, retryAt, lastNotice = 0, 0, -math.huge
    local hover, heartbeat, toggle
    local connections = {}
    local requestedHeight = tonumber(config.Height)
    if not requestedHeight or requestedHeight ~= requestedHeight then requestedHeight = 18 end
    local height = math.clamp(requestedHeight, 4, 40)

    local function disconnect(connection)
        if connection then pcall(function() connection:Disconnect() end) end
    end

    local function stopHover()
        local previous = hover
        hover = nil
        if previous then
            disconnect(previous.DeathConnection)
            pcall(previous.Cleanup)
        end
    end

    local function notice(message)
        if clock() - lastNotice < 5 then return end
        lastNotice = clock()
        if config.Notify then pcall(config.Notify, message) end
    end

    local function syncToggle()
        if syncing or not toggle or not toggle.SetValue then return end
        syncing = true
        pcall(function() toggle:SetValue(enabled) end)
        syncing = false
    end

    local function gameActive()
        if config.IsGameActive then
            local ok, result = pcall(config.IsGameActive)
            return ok and result == true
        end
        local values = world and world:FindFirstChild("Values")
        local gameValue = values and values:FindFirstChild("CurrentGame")
        local name = gameValue and gameValue.Value
        return name == "LightsOut" or name == "LightOut"
    end

    local function alive()
        local character = player and player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not character or not character.Parent or not root or not root.Parent
            or not humanoid or humanoid.Health <= 0 or character:FindFirstChild("Dead") then
            return nil
        end
        return character, root, humanoid
    end

    local function movementBusy()
        if not config.IsMovementBusy then return false end
        local ok, result = pcall(config.IsMovementBusy)
        -- Fail closed if the host cannot establish who owns character movement.
        return not ok or result == true
    end

    local function defaultStartHover(_, root, offset)
        local attachment, alignment
        local cleaned = false
        local function cleanup()
            if cleaned then return end
            cleaned = true
            if alignment then pcall(function() alignment:Destroy() end) end
            if attachment then pcall(function() attachment:Destroy() end) end
        end
        local ok, err = pcall(function()
            attachment = Instance.new("Attachment")
            attachment.Name = "IshakLightsOutHoverAttachment"
            attachment.Parent = root
            alignment = Instance.new("AlignPosition")
            alignment.Name = "IshakLightsOutHover"
            alignment.Mode = Enum.PositionAlignmentMode.OneAttachment
            alignment.Attachment0 = attachment
            alignment.Position = root.Position + Vector3.new(0, offset, 0)
            alignment.ApplyAtCenterOfMass = true
            alignment.RigidityEnabled = false
            alignment.MaxForce = math.max(root.AssemblyMass * world.Gravity * 8, 50000)
            alignment.MaxVelocity = 24
            alignment.Responsiveness = 20
            alignment.Parent = root
        end)
        if not ok then cleanup(); error(err) end
        return cleanup
    end

    local function step()
        if destroyed or not enabled then stopHover(); return false end
        if library and library.Unloaded then controller:Destroy(); return false end
        if not gameActive() then stopHover(); return false end
        local character, root, humanoid = alive()
        if not character or movementBusy() then stopHover(); return false end
        if hover then
            if hover.Character == character and hover.Root == root and hover.Humanoid == humanoid then return true end
            stopHover()
        end
        if clock() < retryAt then return false end
        local token = generation
        local ok, cleanup = pcall(config.StartHover or defaultStartHover, character, root, height)
        if not ok or type(cleanup) ~= "function" then
            retryAt = clock() + 1
            notice("Auto Hover could not start; it will retry during Lights Out.")
            return false
        end
        -- An adapter may synchronously cancel, unload, replace the character, or end the round.
        local currentCharacter, currentRoot, currentHumanoid = alive()
        if destroyed or not enabled or (library and library.Unloaded) or generation ~= token
            or currentCharacter ~= character or currentRoot ~= root or currentHumanoid ~= humanoid
            or not gameActive() or movementBusy() then
            pcall(cleanup)
            return false
        end
        local current = {Character = character, Root = root, Humanoid = humanoid, Cleanup = cleanup}
        hover = current
        if humanoid.Died then
            current.DeathConnection = humanoid.Died:Connect(function()
                if hover == current then stopHover() end
            end)
        end
        return true
    end

    function controller:Step()
        if stepping then return false end
        stepping = true
        local ok, result = pcall(step)
        stepping = false
        if not ok then
            stopHover()
            retryAt = clock() + 1
            notice("Auto Hover paused after a character update error.")
            return false
        end
        return result
    end

    function controller:SetEnabled(value)
        if not value then
            enabled = false
            generation += 1
            disconnect(heartbeat)
            heartbeat = nil
            stopHover()
            syncToggle()
            return false
        end
        if destroyed or (library and library.Unloaded) then syncToggle(); return false end
        if enabled then return true end
        local signal = config.RunService and config.RunService.Heartbeat
        if not signal then
            notice("Auto Hover needs the character update service.")
            syncToggle()
            return false
        end
        enabled = true
        generation += 1
        retryAt = 0
        local ok, connection = pcall(function()
            return signal:Connect(function() controller:Step() end)
        end)
        if not ok or not connection then
            enabled = false
            stopHover()
            syncToggle()
            notice("Auto Hover could not subscribe to character updates.")
            return false
        end
        heartbeat = connection
        syncToggle()
        controller:Step()
        return true
    end

    function controller:Stop()
        self:SetEnabled(false)
    end

    function controller:Destroy()
        if destroyed then return end
        destroyed = true
        self:SetEnabled(false)
        for _, connection in ipairs(connections) do disconnect(connection) end
        connections = {}
    end

    if player and player.CharacterRemoving then
        connections[#connections + 1] = player.CharacterRemoving:Connect(function(character)
            if hover and hover.Character == character then stopHover() end
        end)
    end
    if player and player.CharacterAdded then
        connections[#connections + 1] = player.CharacterAdded:Connect(function() stopHover() end)
    end
    if config.Group then
        toggle = config.Group:AddToggle("LightsOutAutoHover", {
            Text = "Auto Hover",
            Default = false,
            Tooltip = "Automatically rise and hover during Lights Out. Arm before the round; manual flight takes priority.",
            Callback = function(value)
                if not syncing then controller:SetEnabled(value) end
            end,
        })
    end
    return controller
end
    end)()
    if MainModule.LightsOutHoverController then
        pcall(function() MainModule.LightsOutHoverController:Destroy() end)
    end
    local hoverController = createLightsOutHover({
        LocalPlayer = localPlayer,
        Workspace = Workspace,
        RunService = RunService,
        Library = lib,
        Group = v5,
        Height = 18,
        IsGameActive = function()
            return MainModule.is_game_active("LightsOut") or MainModule.is_game_active("LightOut")
        end,
        IsMovementBusy = function()
            return (MainModule.Fly and MainModule.Fly.Enabled == true)
                or MainModule.BypassedOpFlyEnabled == true
                or (MainModule.LightsOutSafe and MainModule.LightsOutSafe.Enabled == true)
                or MainModule.PlayerAttachEnabled == true
                or MainModule.AutoWinEnabled == true
        end,
        Notify = function(message) MainModule.notify("Auto Hover", message, 4) end,
    })
    MainModule.LightsOutHoverController = hoverController
    if type(lib.OnUnload) == "function" then
        lib:OnUnload(function() hoverController:Destroy() end)
    end
end

	MainModule.UIToggle(v5, {
		Id = "LightsOutSafezone",
		Title = "Safezone TP",
		Desc = "Teleports you to the safezone where you cannot get hit from other players, after disabling you will be returned to your position (Also works in hns as a hider).",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_lights_out_safezone, arg)
		end,
	})

	MainModule.UICheckbox(v5, {
		Id = "VampireVision",
		Title = "Vampire Lightning",
		Desc = "Vampire night vision color correction in Lights Out",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_vampire_vision, arg)
		end,
	})

	local v6 = v3:Section({ Title = "Dalgona & Pentathlon", Icon = "cookie", Opened = true })

	MainModule.UIToggle(v6, {
		Id = "FreeLighter",
		Title = "Free Lighter",
		Desc = "Gives you a lighter for the Dalgona game",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.dalgona_lighter, arg)
		end,
	})

	MainModule.UIToggle(v6, {
		Id = "AutoRelaxBreathing",
		Title = "Auto Relax Breathing",
		Desc = "Auto Q to reduce fear in Dalgona",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_dalgona_auto_relax, arg)
		end,
	})

	v6:Button({
		Title = "Anti Crack",
		Desc = "Prevents your cookie from cracks so u cant die",
		Callback = function()
			fn10(MainModule.AntiCrack)
		end,
	})

	v6:Button({
		Title = "Complete Dalgona Shape",
		Callback = function()
			MainModule.shitahhdalgonaez()
		end,
	})

	MainModule.UIToggle(v6, {
		Id = "AutoDdakji",
		Title = "Auto Ddakji",
		Desc = "Auto throw Ddakji with perfect coords by using remote",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_ddakji, arg)
		end,
	})

	MainModule.UIToggle(v6, {
		Id = "AutoFlyingStone",
		Title = "Auto Flying Stone",
		Desc = "Auto throw rock in perfect zone by using remote",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_flying_stone, arg)
		end,
	})

	MainModule.UIToggle(v6, {
		Id = "AutoGonggi",
		Title = "Auto Gonggi",
		Desc = "Auto grab all pieces by using remote",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_gonggi, arg)
		end,
	})

	MainModule.UIToggle(v6, {
		Id = "AutoSpinningTop",
		Title = "Auto Spinning Top",
		Desc = "Auto spin and aim by using remote",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_spinning_top, arg)
		end,
	})

	MainModule.UIToggle(v6, {
		Id = "AutoJegi",
		Title = "Auto Jegi",
		Desc = "Auto completes jegi by using remote",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_jegi, arg)
		end,
	})

	local v7 = v3:Section({ Title = "Hide And Seek", Icon = "eye-off", Opened = true })

-- Insert inside the existing Hide And Seek section (v7).
do
    local createAutoKillHiders = (function()
-- HNS controller: observed combo animations trigger the existing spikes route.
-- The host supplies real tools, movement, animation signals and owned platform resources.
return function(config)
    local waitFor = config.Wait or task.wait
    local spawn = config.Spawn or task.spawn
    local clock = config.Clock or os.clock
    local player, workspace = config.LocalPlayer, config.Workspace
    local controller = {}
    local enabled, destroyed, busy, workerRunning = false, false, false, false
    local generation, activeAttempt, enabledCharacter = 0, nil, nil
    local enabledGameInstance, enabledGameValue, enabledMap
    local retryAt = setmetatable({}, { __mode = "k" })
    local attempts, kills, lastResult = 0, 0, nil
    local nextNotice = 0

    local function child(instance, name)
        return instance and instance:FindFirstChild(name)
    end

    local function attribute(instance, name)
        if not instance or type(instance.GetAttribute) ~= "function" then return nil end
        local ok, value = pcall(function() return instance:GetAttribute(name) end)
        return ok and value or nil
    end

    local function markedDead(subject, character)
        return character and child(character, "Dead") ~= nil
            or subject and subject.Character == character
                and (attribute(subject, "Dead") == true or attribute(subject, "IsDead") == true)
    end

    local function alive(subject)
        local character = subject and subject.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = child(character, "HumanoidRootPart")
        if not character or not character.Parent or not humanoid or humanoid.Health <= 0
            or not root or not root.Parent or markedDead(subject, character) then return nil end
        return character, humanoid, root
    end

    local function check(callback, ...)
        if type(callback) ~= "function" then return false end
        local ok, value = pcall(callback, ...)
        return ok and value == true
    end

    local function gameActive()
        return check(config.IsGameActive)
    end

    local function movementAllowed()
        return not config.CanMove or check(config.CanMove)
    end

    local function gameStamp()
        local value = child(child(workspace, "Values"), "CurrentGame")
        return value, value and value.Value, child(workspace, "HideAndSeekMap")
    end

    local function sameRound(context)
        if not gameActive() then return false end
        local instance, value, map = gameStamp()
        return instance == context.gameInstance and value == context.gameValue and map == context.map
    end

    local function notice(message)
        if clock() < nextNotice then return end
        nextNotice = clock() + 5
        pcall(function()
            if config.Notify then config.Notify(message)
            elseif config.Library and config.Library.Notify then config.Library:Notify(message, 4) end
        end)
    end

    local function knife(character)
        local ok, tool = pcall(config.FindKnife, character)
        if not ok or not tool or not tool.Parent then return nil end
        if tool.Parent ~= character and tool.Parent ~= child(player, "Backpack") then return nil end
        local valid, result = pcall(function() return tool:IsA("Tool") end)
        return valid and result and tool or nil
    end

    local function validLocal(context)
        local character, humanoid = alive(player)
        if character ~= context.character then return false end
        if humanoid.Health < context.lastHealth then context.hurt = true; return false end
        context.lastHealth = humanoid.Health
        return not context.cleaned and enabled and not destroyed and generation == context.generation
            and not (config.Library and config.Library.Unloaded)
            and sameRound(context) and movementAllowed()
            and check(config.IsSeeker, player)
            and knife(context.character) == context.tool
    end

    local function mayReturn(context)
        return context.moved and alive(player) == context.character and sameRound(context) and movementAllowed()
    end

    local function disconnect(connection)
        if connection then pcall(function() connection:Disconnect() end) end
    end

    local function finish(context)
        if context.cleaned then return end
        context.cleaned = true
        for _, connection in ipairs(context.connections) do disconnect(connection) end
        context.connections = {}
        if mayReturn(context) then
            local ok, result = pcall(config.Teleport, context.root, context.origin)
            if not ok or result ~= true then
                context.returnFailed = true
                notice("Could not return to the saved position; Auto Kill Hiders stopped.")
            end
        end
        if context.spikes and type(context.spikes.Cleanup) == "function" then
            pcall(context.spikes.Cleanup)
        end
        if activeAttempt == context then activeAttempt = nil end
    end

    local function stop()
        local changed = enabled
        enabled = false
        enabledCharacter = nil
        generation += 1
        if activeAttempt then finish(activeAttempt) end
        if changed and config.OnEnabledChanged then pcall(config.OnEnabledChanged, false) end
    end

    local function targetAlive(context)
        return alive(context.target) == context.targetCharacter and check(config.IsHider, context.target)
            and not check(config.IsSeeker, context.target)
    end

    local function targetDied(context)
        return context.targetHumanoid.Health <= 0 or markedDead(context.target, context.targetCharacter)
    end

    local function spikesValid(context)
        local resource = context.spikes
        return resource and resource.Destination
            and (not resource.IsValid or check(resource.IsValid))
    end

    local function move(context, destination)
        if not validLocal(context) or not destination then return false end
        -- Mark before the adapter call: an adapter can move and then throw.
        context.moved = true
        return config.Teleport(context.root, destination) == true and validLocal(context)
    end

    local function attempt(context)
        context.spikes = config.PrepareSpikes()
        if context.cleaned then
            if context.spikes and context.spikes.Cleanup then pcall(context.spikes.Cleanup) end
            return "cancelled"
        end
        if not spikesValid(context) or not validLocal(context) then return "unavailable" end
        local animationConnection = config.ConnectAnimation(context.character, function(track)
            if not context.attackIssued or context.combo or not validLocal(context)
                or not check(config.IsCombo, track) then return end
            context.combo = track
            if track.Stopped and type(track.Stopped.Connect) == "function" then
                local connection = track.Stopped:Connect(function()
                    if not context.cleaned and context.stoppedAt == nil then context.stoppedAt = clock() end
                end)
                table.insert(context.connections, connection)
            end
            local ok, playing = pcall(function() return track.IsPlaying end)
            if ok and playing == false then context.stoppedAt = clock() end
        end)
        if not animationConnection then return "unavailable" end
        if context.cleaned then disconnect(animationConnection); return "cancelled" end
        table.insert(context.connections, animationConnection)
        local deadline = clock() + (config.ApproachTimeout or 4)
        local nextAttack = -math.huge
        while clock() < deadline and not context.combo do
            if not validLocal(context) or not targetAlive(context) or not spikesValid(context) then return "cancelled" end
            local _, _, targetRoot = alive(context.target)
            if not move(context, config.BehindCFrame(targetRoot)) then return "movement failed" end
            if clock() >= nextAttack then
                context.attackIssued = true
                nextAttack = clock() + (config.AttackInterval or 0.5)
                if config.Attack(context.tool) ~= true then return "attack unavailable" end
            end
            if not context.combo then waitFor(0.05) end
        end
        if not context.combo then return "no combo" end
        if not validLocal(context) or not spikesValid(context) then return "cancelled" end
        if not move(context, context.spikes.Destination) then return "movement failed" end
        local comboDeadline = clock() + (config.ComboTimeout or 10)
        while clock() < comboDeadline do
            if not validLocal(context) or not spikesValid(context) then return "cancelled" end
            if context.stoppedAt and clock() >= context.stoppedAt + (config.ReturnDelay or 0.6) then break end
            waitFor(0.05)
        end
        return targetDied(context) and "confirmed kill" or "unconfirmed"
    end

    local function nearest(root)
        local best, bestCharacter, bestHumanoid, distance = nil, nil, nil, math.huge
        for _, other in ipairs(config.Players:GetPlayers()) do
            if other ~= player and (retryAt[other] or 0) <= clock() and check(config.IsHider, other)
                and not check(config.IsSeeker, other) then
                local character, humanoid, otherRoot = alive(other)
                if character then
                    local candidate = (otherRoot.Position - root.Position).Magnitude
                    if candidate < distance then
                        best, bestCharacter, bestHumanoid, distance = other, character, humanoid, candidate
                    end
                end
            end
        end
        return best, bestCharacter, bestHumanoid
    end

    function controller:Step()
        if busy or not enabled or destroyed then return false end
        local character, humanoid, root = alive(player)
        local tool = character and knife(character)
        local gameInstanceNow, gameValueNow, mapNow = gameStamp()
        if not character or humanoid.Health <= (config.MinHealth or 20)
            or character ~= enabledCharacter or not tool or not gameActive()
            or gameInstanceNow ~= enabledGameInstance or gameValueNow ~= enabledGameValue or mapNow ~= enabledMap
            or not check(config.IsSeeker, player)
            or not movementAllowed() or config.Library and config.Library.Unloaded then
            stop()
            notice("Auto Kill Hiders needs a seeker with a knife and more than 20 HP in Hide And Seek; turn off conflicting movement features.")
            return false
        end
        local target, targetCharacter, targetHumanoid = nearest(root)
        if not target then return false end
        busy = true
        attempts += 1
        local gameInstance, gameValue, map = gameStamp()
        local context = {
            generation = generation, character = character, root = root, tool = tool,
            target = target, targetCharacter = targetCharacter, targetHumanoid = targetHumanoid,
            origin = root.CFrame, gameInstance = gameInstance, gameValue = gameValue, map = map,
            lastHealth = humanoid.Health,
            connections = {}, moved = false, cleaned = false, attackIssued = false,
        }
        activeAttempt = context
        local ok, result = pcall(attempt, context)
        finish(context)
        busy = false
        retryAt[target] = clock() + (config.RetryDelay or 3)
        lastResult = ok and result or "error"
        if ok and result == "confirmed kill" then kills += 1 end
        if not ok or context.returnFailed or context.hurt then
            stop()
            if not ok then notice("Auto Kill Hiders stopped after an interaction error.") end
            if context.hurt then notice("Damage detected; returned and stopped Auto Kill Hiders.") end
        elseif not gameActive() or alive(player) ~= character or not movementAllowed() or not check(config.IsSeeker, player) then
            stop()
        end
        return ok and result == "confirmed kill"
    end

    function controller:SetEnabled(value)
        if destroyed then return false end
        if not value then stop(); return true end
        if enabled then return true end
        local character, humanoid = alive(player)
        if not character or humanoid.Health <= (config.MinHealth or 20)
            or not knife(character) or not gameActive() or not check(config.IsSeeker, player)
            or not movementAllowed() or config.Library and config.Library.Unloaded then
            notice("Auto Kill Hiders needs a seeker with a knife and more than 20 HP in Hide And Seek; turn off conflicting movement features.")
            return false
        end
        enabled = true
        enabledCharacter = character
        enabledGameInstance, enabledGameValue, enabledMap = gameStamp()
        generation += 1
        if config.OnEnabledChanged then pcall(config.OnEnabledChanged, true) end
        if not workerRunning then
            workerRunning = true
            local ok = pcall(spawn, function()
                local workerOk = pcall(function()
                    while enabled and not destroyed do
                        controller:Step()
                        if enabled then waitFor(0.1) end
                    end
                end)
                workerRunning = false
                if not workerOk then stop(); busy = false end
            end)
            if not ok then workerRunning = false; stop(); return false end
        end
        return true
    end

    function controller:IsEnabled() return enabled end
    function controller:GetState()
        return { Enabled = enabled, Busy = busy, WorkerRunning = workerRunning,
            Attempts = attempts, Kills = kills, LastResult = lastResult }
    end
    function controller:Destroy()
        if destroyed then return end
        stop()
        destroyed = true
        retryAt = setmetatable({}, { __mode = "k" })
    end
    return controller
end
    end)()

    if MainModule.AutoKillHidersController then
        pcall(function() MainModule.AutoKillHidersController:Destroy() end)
    end

    local function canMove()
        return not (MainModule.SpikesKillFeature and MainModule.SpikesKillFeature.Enabled)
            and not (MainModule.Fly and MainModule.Fly.Enabled)
            and not MainModule.PlayerAttachEnabled
            and not MainModule.BypassedOpFlyEnabled
            and not MainModule.AutoWinEnabled
    end

    local function currentCharacter()
        local character = localPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if character and character.Parent and humanoid and humanoid.Health > 0
            and root and root.Parent == character then
            return character, humanoid, root
        end
        return nil
    end

    local function isActiveSeeker()
        return MainModule.is_game_active("HideAndSeek")
            and MainModule.is_seeker(localPlayer) and canMove()
    end

    local function isKnife(tool)
        if not tool or not tool.Parent or not tool:IsA("Tool") then return false end
        local name = tostring(tool.Name):lower():gsub("[^%w]", "")
        return name:find("knife", 1, true) ~= nil or name:find("dagger", 1, true) ~= nil
    end

    local function belongsToPlayer(tool, character)
        local backpack = localPlayer:FindFirstChildOfClass("Backpack")
        return tool.Parent == character
            or (backpack and backpack.Parent == localPlayer and tool.Parent == backpack)
    end

    local function findKnife(character)
        local current = currentCharacter()
        if not current or (character and character ~= current) then return nil end
        for _, tool in ipairs(current:GetChildren()) do
            if isKnife(tool) then return tool end
        end
        local backpack = localPlayer:FindFirstChildOfClass("Backpack")
        if backpack and backpack.Parent == localPlayer then
            for _, tool in ipairs(backpack:GetChildren()) do
                if isKnife(tool) then return tool end
            end
        end
        return nil
    end

    local function attack(tool)
        local character, humanoid = currentCharacter()
        if not character or not isActiveSeeker() or not isKnife(tool)
            or not belongsToPlayer(tool, character) or tool.Enabled == false then
            return false
        end
        if tool.Parent ~= character then
            local equipped = pcall(function() humanoid:EquipTool(tool) end)
            if not equipped then return false end
        end
        if localPlayer.Character ~= character or not character.Parent
            or humanoid.Health <= 0 or tool.Parent ~= character
            or tool.Enabled == false or not isActiveSeeker() then
            return false
        end
        -- The game-specific knife protocol is not available in the source hub.
        -- Send a normal Tool request; a combo event, not this return value,
        -- is the controller's confirmation that the attack animation started.
        local activated = pcall(function() tool:Activate() end)
        local released = pcall(function() tool:Deactivate() end)
        return activated and released
    end

    local function prepareSpikes()
        if not currentCharacter() or not isActiveSeeker() then return nil end
        local map = Workspace:FindFirstChild("HideAndSeekMap")
        local killingParts = map and map:FindFirstChild("KillingParts")
        if not map or map.Parent ~= Workspace or not killingParts then return nil end
        local spike
        for _, child in ipairs(killingParts:GetChildren()) do
            if child:IsA("BasePart") then spike = child; break end
        end
        if not spike then return nil end
        local platform
        local prepared, context = pcall(function()
            platform = Instance.new("Part")
            platform.Name = "Ishak_HiderSafetyPlatform"
            platform.Size = Vector3.new(20, 5, 20)
            platform.Anchored = true
            platform.CanCollide = true
            platform.Transparency = 1
            platform.Position = spike.Position + Vector3.new(0, 20, 0)
            platform.Parent = Workspace
            local cleaned = false
            return {
                Destination = CFrame.new(platform.Position + Vector3.new(0, 2.5, 0)),
                IsValid = function()
                    return not cleaned and map.Parent == Workspace
                        and Workspace:FindFirstChild("HideAndSeekMap") == map
                        and killingParts.Parent == map
                        and map:FindFirstChild("KillingParts") == killingParts
                        and spike.Parent == killingParts and platform.Parent == Workspace
                end,
                Cleanup = function()
                    if cleaned then return true end
                    local removed = pcall(function() platform:Destroy() end)
                    if removed then cleaned = true end
                    return removed
                end,
            }
        end)
        if not prepared then
            if platform then pcall(function() platform:Destroy() end) end
            return nil
        end
        return context
    end

    local function connectAnimation(character, callback)
        if character ~= localPlayer.Character or not character or not character.Parent then return nil end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return nil end
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            local connected, connection = pcall(function() return animator.AnimationPlayed:Connect(callback) end)
            if connected and connection then return connection end
        end
        local connected, connection = pcall(function() return humanoid.AnimationPlayed:Connect(callback) end)
        return connected and connection or nil
    end

    local function animationId(value)
        local text = tostring(value or ""):lower()
        return text:match("^rbxassetid://(%d+)$") or text:match("^(%d+)$")
    end

    local function isCombo(track)
        local ok, id = pcall(function()
            return track and track.Animation and animationId(track.Animation.AnimationId)
        end)
        if not ok or not id then return false end
        local feature = MainModule.SpikesKillFeature
        for _, known in ipairs(feature and feature.AnimationIds or {}) do
            if animationId(known) == id then return true end
        end
        return false
    end

    local toggle
    local syncing = false
    local function syncEnabled(enabled)
        if not toggle or syncing or toggle.Value == enabled then return end
        syncing = true
        pcall(function() toggle:SetValue(enabled) end)
        syncing = false
    end

    local controller = createAutoKillHiders({
        Players = Players,
        Workspace = Workspace,
        LocalPlayer = localPlayer,
        Library = lib,
        IsGameActive = function() return MainModule.is_game_active("HideAndSeek") end,
        IsSeeker = function(player) return MainModule.is_seeker(player) end,
        IsHider = function(player) return MainModule.is_hider(player) end,
        CanMove = canMove,
        FindKnife = findKnife,
        Attack = attack,
        BehindCFrame = function(root) return root.CFrame * CFrame.new(0, 0, 2.5) end,
        PrepareSpikes = prepareSpikes,
        ConnectAnimation = connectAnimation,
        IsCombo = isCombo,
        Teleport = function(root, destination)
            local character, _, currentRoot = currentCharacter()
            if not character or root ~= currentRoot or not isActiveSeeker() then return false end
            local moved, accepted = pcall(MainModule.safe_teleport, destination.Position)
            if not moved or accepted ~= true then return false end
            local afterCharacter, _, afterRoot = currentCharacter()
            if afterCharacter ~= character or afterRoot ~= root or not isActiveSeeker() then return false end
            -- safe_teleport accepts a position and discards rotation. Retain the
            -- target's facing for the approach and the saved facing on return.
            local oriented = pcall(function() root.CFrame = destination end)
            return oriented
        end,
        OnEnabledChanged = syncEnabled,
        Notify = function(message) MainModule.notify("Auto Kill Hiders", message, 4) end,
    })
    MainModule.AutoKillHidersController = controller
    toggle = v7:AddToggle("AutoKillHiders", {
        Text = "Auto Kill Hiders",
        Default = false,
        Tooltip = "Seeker only: approaches the nearest hider, requests a normal knife attack, then follows the existing Spikes Kill combo timing. Live-game knife behavior is unverified.",
        Callback = function(enabled)
            if syncing then return end
            local accepted = controller:SetEnabled(enabled)
            if not accepted then syncEnabled(controller:IsEnabled()) end
        end,
    })
    syncEnabled(controller:IsEnabled())
    if type(lib.OnUnload) == "function" then
        lib:OnUnload(function() controller:Destroy() end)
    end
end

	MainModule.UIToggle(v7, {
		Id = "FasterSprint",
		Title = "Infinite Faster Sprint & Stamina",
		Desc = "Allows you to use infinite faster sprint for hider with infinite stamina",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_faster_sprint, arg)
		end,
	})

	v7:Button({
		Title = "Teleport To Spawn",
		Callback = function()
			fn10(MainModule.teleport_to_spawn)
		end,
	})

	v7:Button({
		Title = "Teleport To Hider",
		Callback = function()
			fn10(MainModule.teleport_to_hider)
		end,
	})

	MainModule.Keybinds = MainModule.Keybinds or {}
	MainModule._KeybindPress = MainModule._KeybindPress or {}

	if MainModule.Keybinds.TpHider == nil then
		MainModule.Keybinds.TpHider = "None"
	end

	MainModule._KeybindPress.TpHider = function()
		fn10(MainModule.teleport_to_hider)
	end

	MainModule.HSXRegisterKeybind("TpHider", MainModule.Keybinds.TpHider, MainModule._KeybindPress.TpHider)

	pcall(function()
		v7:Keybind({
			Id = "TpHiderKey",
			Title = "Tp Hider Keybind",
			Value = MainModule.Keybinds.TpHider or "None",
			NoUI = true,
			Callback = function(arg)
				local v8 = MainModule.HSXNormalizeKey(arg)
				MainModule.Keybinds.TpHider = v8
				MainModule.HSXRegisterKeybind("TpHider", v8, MainModule._KeybindPress.TpHider)
				MainModule.HSXSyncKeybindUI("TpHider", v8)
			end,
		})
	end)

	v7:Button({
		Title = "Teleport To Seeker",
		Callback = function()
			fn10(MainModule.teleport_to_seeker)
		end,
	})

	if MainModule.Keybinds.TpSeeker == nil then
		MainModule.Keybinds.TpSeeker = "None"
	end

	MainModule._KeybindPress.TpSeeker = function()
		fn10(MainModule.teleport_to_seeker)
	end

	MainModule.HSXRegisterKeybind("TpSeeker", MainModule.Keybinds.TpSeeker, MainModule._KeybindPress.TpSeeker)

	pcall(function()
		v7:Keybind({
			Id = "TpSeekerKey",
			Title = "Tp Seeker Keybind",
			Value = MainModule.Keybinds.TpSeeker or "None",
			NoUI = true,
			Callback = function(arg)
				local v8 = MainModule.HSXNormalizeKey(arg)
				MainModule.Keybinds.TpSeeker = v8
				MainModule.HSXRegisterKeybind("TpSeeker", v8, MainModule._KeybindPress.TpSeeker)
				MainModule.HSXSyncKeybindUI("TpSeeker", v8)
			end,
		})
	end)

	MainModule.UIToggle(v7, {
		Id = "AutoEscape",
		Title = "Auto Escape",
		Desc = "Automatically teleports to every dropped keys and after to escape door and automatically escapes",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_escape, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "AutoPickupKeys",
		Title = "Auto Pickup Keys",
		Desc = "Automatically teleports to all dropped keys for hider",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_pickup, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "ESPDroppedKeys",
		Title = "ESP Dropped Keys",
		Desc = "Shows all dropped keys for hider",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_key_esp, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "ESPExitDoors",
		Title = "ESP Exit Doors",
		Desc = "Shows all exit doors",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_exit_door_esp, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "ESPSpikes",
		Title = "ESP Spikes",
		Desc = "Highlights all spikes on map (black)",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_spikes_esp, arg)
		end,
	})

	MainModule.HSXToggleWithKey(v7, "Auto Dodge", "AutoDodge", "None", function()
		return MainModule.AutoDodge and MainModule.AutoDodge.Enabled
	end, function(arg)
		return MainModule.toggle_auto_dodge(arg)
	end, "Automatically uses DODGE! when being attacked, You need to use DODGE! before enable")

	MainModule.UIToggle(v7, {
		Id = "SpikesKill",
		Title = "Spikes Kill",
		Desc = "Teleport players to spikes by animation",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_spikes_kill, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "TeleportToSpikes",
		Title = "Teleport To Spikes",
		Desc = "Teleports you to random spikes, to prevent die you need to disable spikes first",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_spikes_platform_teleport, arg)
		end,
	})

	v7:Button({
		Title = "Teleport Random Exit",
		Callback = function()
			fn10(MainModule.teleport_random_exit)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "AntiSpikes",
		Title = "Anti-Spikes",
		Desc = "Creates a platform above spikes to avoid being killed.",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_anti_spikes, arg)
		end,
	})

	local v8 = v3:Section({ Title = "Tug Of War", Icon = "swords", Opened = true })

	MainModule.UIToggle(v8, {
		Id = "AntiMissQTE",
		Title = "Anti Miss QTE",
		Desc = "never miss Tug QTE",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_tug_of_war_auto_qte_miss, arg)
		end,
	})

	MainModule.UIToggle(v8, {
		Id = "AutoPullOP",
		Title = "Auto Pull (OP)",
		Desc = "wins tug of war in 6-7 secs (legit + op)",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_tug_auto_pull_op, arg)
		end,
	})

	local v9 = v3:Section({ Title = "Jump Rope", Icon = "activity", Opened = true })

	MainModule.UIToggle(v9, {
		Id = "AntiFall",
		Title = "Anti Fall",
		Desc = "Creates platform to prevent falling",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_jump_rope_anti_fall, arg)
		end,
	})

	MainModule.UIToggle(v9, {
		Id = "AntiHit",
		Title = "AntiHit",
		Desc = "Avoid rope hits",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_jump_rope_anti_hit, arg)
		end,
	})

	MainModule.UIToggle(v9, {
		Id = "FakeBalance",
		Title = "Fake Balance",
		Desc = "Fake balance animation",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_jump_rope_fake_balance, arg)
		end,
	})

	MainModule.UIToggle(v9, {
		Id = "FreezeRope",
		Title = "Freeze Rope",
		Desc = "Freeze jump rope",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_freeze_rope, arg)
		end,
	})

	v9:Button({
		Title = "Remove Balance Mini Game",
		Callback = function()
			fn10(MainModule.remove_balance_mini_game)
		end,
	})

	v9:Button({
		Title = "Remove Rope",
		Callback = function()
			fn10(MainModule.jr_delete_rope)
		end,
	})

	v9:Button({
		Title = "Teleport to Start",
		Callback = function()
			fn10(MainModule.jr_tp_start)
		end,
	})

	v9:Button({
		Title = "Teleport to End",
		Callback = function()
			fn10(MainModule.jr_tp_end)
		end,
	})

	local v10 = v3:Section({ Title = "Glass Bridge", Icon = "layers", Opened = true })

	MainModule.UIToggle(v10, {
		Id = "GlassESP",
		Title = "Glass ESP",
		Desc = "Green = safe, Yellow = delayed, Red = breakable",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_glass_esp, arg)
		end,
	})

	MainModule.UICheckbox(v10, {
		Id = "DashInGB",
		Title = "Enable Dash in GB",
		Desc = "Requires lvl 5 faster sprint",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_dash_in_gb, arg)
		end,
	})

	MainModule.UIToggle(v10, {
		Id = "AntiBreak",
		Title = "AntiBreak Glass",
		Desc = "Prevents glass from breaking",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_anti_break, arg)
		end,
	})

	MainModule.UISlider(v10, {
		Title = "ESP Transparency",
		Value = { Min = 0, Max = 100, Default = 40 },
		Step = 1,
		Callback = function(arg)
			fn10(MainModule.set_glass_esp_transparency, arg)
		end,
	})

	v10:Button({
		Title = "Teleport to End",
		Callback = function()
			fn10(MainModule.gb_tp_end)
		end,
	})

	MainModule.UIToggle(v10, {
		Id = "HCGlassESP",
		Title = "HC Glass ESP",
		Desc = "Highlight correct glass ( red breakable , green = safe _",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_hc_glass_esp, arg)
		end,
	})

	local v11 = v3:Section({ Title = "Rebel", Icon = "swords", Opened = true })

	MainModule.UIToggle(v11, {
		Id = "RebelGuardHitbox",
		Title = "Hitbox Guards",
		Desc = "Expand NPC guard hitboxes",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_rebel_guard_hitbox, arg)
		end,
	})

	MainModule.UISlider(v11, {
		Id = "RebelGuardHitboxSize",
		Title = "Hitbox Size",
		Value = { Min = 2, Max = 30, Default = 6 },
		Step = 1,
		Callback = function(arg)
			if MainModule.set_rebel_guard_hitbox_size then
				MainModule.set_rebel_guard_hitbox_size(arg)
			end
		end,
	})

	MainModule.UIToggle(v11, {
		Id = "RebelGuardESP",
		Title = "ESP Guards",
		Desc = "Highlight NPC guards",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_rebel_guard_esp, arg)
		end,
	})

	MainModule.UIToggle(v11, {
		Id = "RebelGuardSilent",
		Title = "Silent Aim Guards",
		Desc = "Silent aim on NPC guards",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_rebel_guard_silent, arg)
		end,
	})

	MainModule.UIToggle(v11, {
		Id = "GuardAimbot",
		Title = "Guards NPCs Aimbot",
		Desc = "Camera aimbot on NPC guards",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_guard_aimbot, arg)
		end,
	})

	MainModule.UIToggle(v11, {
		Id = "BringAllGuards",
		Title = "Bring all guards",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_bring_all_guards, arg)
		end,
	})

	MainModule.UIToggle(v3:Section({ Title = "Mingle", Icon = "users", Opened = true }), {
		Id = "VoidKill",
		Title = "Void Kill",
		Desc = "Teleports you into the void upon using choke on someone and after tps you back",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_mingle_void_kill, arg)
		end,
	})

	local v12 = v3:Section({ Title = "Last Dinner", Icon = "utensils", Opened = true })

	MainModule.UIToggle(v12, {
		Id = "ZoneKill",
		Title = "Zone Kill",
		Desc = "Brings enemy into players lobby where zone is killing them, after it you will be returned to your position. Also requires knife and land backstab",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_zone_kill, arg)
		end,
	})

	v12:Button({
		Title = "Teleport To Safe Spot",
		Callback = function()
			fn10(MainModule.teleport_to_safe_spot)
		end,
	})

	local v13 = v3:Section({ Title = "SkySquid & SquidGame", Icon = "cloud", Opened = true })

	MainModule.UIToggle(v13, {
		Id = "AutoTeleportOnFall",
		Title = "Auto Teleport on Fall",
		Desc = "Teleport u to the platform up when fall so u cant fall",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_respawn_on_fall, arg)
		end,
	})

	MainModule.UIToggle(v13, {
		Title = "Void Kill",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_void_kill, arg)
		end,
	})

	MainModule.UIToggle(v13, {
		Title = "Anti Fall",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_sky_squid_anti_fall, arg)
		end,
	})

	pcall(function()
		if v13.AddDivider then
			v13:AddDivider()
		elseif v13._raw and v13._raw.AddDivider then
			v13._raw:AddDivider()
		elseif v13.Paragraph then
			v13:Paragraph({ Title = "â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€" })
		end
	end)

	MainModule.HSXToggleWithKey(v13, "Orbit Kill Aura", "OrbitKillaura", "None", function()
		return MainModule.OrbitKillauraEnabled
	end, function(arg)
		return MainModule.toggle_orbit_killaura(arg)
	end, "Orbit around nearest enemy")

	MainModule.UIToggle(v13, {
		Id = "OrbitAntiHit",
		Title = "AntiHit (TP)",
		Desc = "teleports u up while orbit killaura is enabled when someone trying to hit you",
		Value = false,
		Callback = function(arg)
			MainModule.OrbitAntiHitEnabled = arg and true or false

			if fn4 then
				fn4()
			end
		end,
	})

	MainModule.UISlider(v13, {
		Title = "Orbit Radius",
		Value = { Min = 1, Max = 10, Default = 3 },
		Step = 1,
		Callback = function(arg)
			fn10(MainModule.set_orbit_radius, arg)
		end,
	})

	MainModule.UISlider(v13, {
		Title = "Orbit Speed",
		Value = { Min = 1, Max = 10, Default = 10 },
		Step = 1,
		Callback = function(arg)
			fn10(MainModule.set_orbit_speed, arg)
		end,
	})

	MainModule.UIToggle(v13, {
		Id = "BypassedOpFly",
		Title = "Bypassed op fly (works fine in mobile)",
		Desc = "bypassed flight from infinite yield and works fine on mobile",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_bypassed_op_fly, arg)
		end,
	})
end

do
	local v3 = v2:Tab({ Title = "Powers & Surgery", Icon = "zap", Desc = "powers + surgery" })
	local v4 = v3:Section({ Title = "Fake Powers", Icon = "sparkles", Opened = true })

	MainModule.UIToggle(v4, {
		Id = "FakeUltraInstinct",
		Title = "Give Fake Ultra Instinct",
		Desc = "Give visual ultra instinct ability.",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_fake_ultra_instinct, arg)
		end,
	})

	MainModule.UIToggle(v4, {
		Id = "FakeLGPowerHold",
		Title = "Give Fake LG PowerHold",
		Desc = "Load Fake LG PowerHold",
		Value = false,
		Callback = function(arg)
			MainModule.FakeLGPowerHoldEnabled = arg and true or false

			if arg then
				pcall(function()
					loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/95b3b990b427dd37b00222b35e7a6e5d.lua"))()
				end)

				fn2("Fake LG PowerHold", "Enabled", 0.9)
			end
		end,
	})

	MainModule.UIToggle(v4, {
		Id = "FakeLightningAwakening",
		Title = "Give Fake Lightning Awakening",
		Desc = "Gives Lightning awakening power (tool)",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_fake_lightning_awakening, arg)
		end,
	})

	MainModule.UIToggle(v4, {
		Id = "Quicksilver",
		Title = "Free Quicksilver",
		Desc = "Gives Free Quicksilver power (anticheat can tp you back)",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_quicksilver, arg)
		end,
	})

	MainModule.UIToggle(v4, {
		Id = "ParkourArtist",
		Title = "Parkour Artist",
		Desc = "gives free parkour artist power (c is slide for pc)",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_parkour_artist, arg)
		end,
	})

	local hsxBindSlider = nil
	local hsxBindSlider2 = nil
	local v5 = nil
	local v6 = nil

	MainModule.UIToggle(v4, {
		Id = "PhantomDash",
		Title = "Phantom Dash",
		Desc = "Phantom step ability for free works on pc and mobile",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_phantom_dash, arg)

			if hsxBindSlider then
				hsxBindSlider.ensure(arg)
			end

			if hsxBindSlider2 then
				hsxBindSlider2.ensure(arg)
			end

			if v5 then
				v5.ensure(arg)
			end

			if v6 then
				v6.ensure(arg)
			end
		end,
	})

	hsxBindSlider = MainModule.HSXBindSlider

	hsxBindSlider = hsxBindSlider(v4, {
		ParentId = "PhantomDash",
		Title = "Dash Distance",
		Value = { Min = 5, Max = 50, Default = 15 },
		Step = 1,
		defaultValue = 15,
		Callback = function(arg)
			fn10(MainModule.set_phantom_dash_distance, arg)
		end,
	})

	hsxBindSlider2 = MainModule.HSXBindSlider

	hsxBindSlider2 = hsxBindSlider2(v4, {
		ParentId = "PhantomDash",
		Title = "Dash Duration",
		Value = { Min = 10, Max = 100, Default = 25 },
		Step = 1,
		defaultValue = 25,
		Callback = function(arg)
			fn10(MainModule.set_phantom_dash_duration, arg)
		end,
	})

	v5 = MainModule.HSXBindSlider(v4, {
		ParentId = "PhantomDash",
		Title = "Charge Cooldown",
		Value = { Min = 0.5, Max = 5, Default = 1 },
		Step = 0.1,
		defaultValue = 1,
		Callback = function(arg)
			fn10(MainModule.set_phantom_dash_cooldown, arg)
		end,
	})

	v6 = MainModule.HSXBindSlider(v4, {
		ParentId = "PhantomDash",
		Title = "Max Charges",
		Value = { Min = 1, Max = 5, Default = 2 },
		Step = 1,
		defaultValue = 2,
		Callback = function(arg)
			fn10(MainModule.set_phantom_dash_max_charges, arg)
		end,
	})

	local v7 = v3:Section({ Title = "Powers", Icon = "eye", Opened = true })

	MainModule.UIToggle(v7, {
		Id = "ESPPowers",
		Title = "Powers ESP",
		Desc = "shows power name above players head",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_esp_powers, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "AutoUltraInstinct",
		Title = "Auto Ultra Instinct",
		Desc = "Auto Dodge with Real Ultra Instinct",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_ultra_instinct, arg)
		end,
	})

	local v8 = v3:Section({ Title = "Surgery", Icon = "syringe", Opened = true })

	MainModule.UIToggle(v8, {
		Id = "DroppedGunESP",
		Title = "ESP + Tracers Dropped Gun",
		Desc = "ESP and tracers on dropped surgery gun",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_dropped_gun_esp, arg)
		end,
	})

	MainModule.UIToggle(v8, {
		Id = "AutoTPDroppedGun",
		Title = "Auto TP To Dropped Gun",
		Desc = "Teleport to dropped gun and fire proximity prompt",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_tp_dropped_gun, arg)
		end,
	})
end

local v3 = v2:Tab({ Title = "Combat", Icon = "swords", Desc = "PVP / ESP / attach" }):Section({ Title = "Combat", Icon = "swords", Opened = true })

MainModule.HSXToggleWithKey(v3, "Player Attach", "PlayerAttach", "None", function()
	return MainModule.PlayerAttachEnabled
end, function(arg)
	return MainModule.toggle_player_attach(arg)
end, "Attaches you to nearest player (uses Face Target)")

MainModule.HSXToggleWithKey(v3, "Face Target", "FaceTarget", "None", function()
	return MainModule.FaceTargetModule and MainModule.FaceTargetModule.Enabled
end, function(arg)
	fn10(MainModule.toggle_face_target, arg)
	return true
end, "Always face target")

MainModule.UIToggle(v3, {
	Id = "Desync",
	Title = "Desync",
	Desc = "Network desync (good executor required) idont think its works because roblox patched shi",
	Value = false,
	Callback = function(arg)
		fn10(MainModule.toggle_desync, arg)
	end,
})

MainModule.UIToggle(v3, {
	Id = "PlayersESP",
	Title = "Players ESP",
	Desc = "ESP for all non dead players (works in hns aswell seeker is red and hider is green)",
	Value = false,
	Callback = function(arg)
		MainModule.PlayerESPEnabled = arg and true or false
		fn10(MainModule.toggle_player_esp, arg)
	end,
})

MainModule.UIDropdown(v3, {
	Title = "ESP Mode",
	Desc = "New or Old ESP mode",
	Values = { "New", "Old" },
	Value = "Old",
	Callback = function(arg)
		fn10(MainModule.set_esp_mode, arg)
	end,
})

MainModule.UIToggle(v3, {
	Id = "ESPRGBMode",
	Title = "ESP RGB Mode",
	Desc = "Rainbow ESP box",
	Value = false,
	Callback = function(arg)
		MainModule.ESPRGBEnabled = arg and true or false
		fn10(MainModule.toggle_esprgb, arg)
		fn4()
	end,
})

MainModule.HSXToggleWithKey(v3, "AntiStun", "AntiStun", "None", function()
	return MainModule.RemoveStunEnabled
end, function(arg)
	fn10(MainModule.toggle_remove_stun, arg)
	return true
end, "Remove stun effects")

MainModule.BiggestThreatHighlight = nil
MainModule.BiggestThreatConnection = nil
MainModule.BiggestThreatEnabled = false

MainModule._GetPlayerWins = function(arg)
	local n = 0

	pcall(function()
		local attribute = arg:GetAttribute("_GameWins") or arg:GetAttribute("GameWins") or arg:GetAttribute("Wins")

		if type(attribute) == "number" then
			n = attribute
		end
	end)

	pcall(function()
		local leaderstats = arg:FindFirstChild("leaderstats")

		if leaderstats then
			local wins = leaderstats:FindFirstChild("Wins") or leaderstats:FindFirstChild("wins") or leaderstats:FindFirstChild("Victories")

			if wins and typeof(wins.Value) == "number" then
				n = math.max(n, wins.Value)
			end
		end
	end)

	pcall(function()
		local values = arg:FindFirstChild("Values")

		if values then
			local wins = values:FindFirstChild("Wins") or values:FindFirstChild("_GameWins")

			if wins and typeof(wins.Value) == "number" then
				n = math.max(n, wins.Value)
			end
		end
	end)

	return n
end

MainModule.FindBiggestThreat = function()
	local n = -1
	local v4 = nil

	for _, player in ipairs(Players2:GetPlayers()) do
		if player ~= localPlayer2 then
			local v5 = MainModule._GetPlayerWins(player)

			if n < v5 then
				n = v5
				v4 = player
			end
		end
	end

	return v4, n
end

MainModule.clear_biggest_threat = function()
	if MainModule.BiggestThreatHighlight then
		pcall(function()
			MainModule.BiggestThreatHighlight:Destroy()
		end)

		MainModule.BiggestThreatHighlight = nil
	end

	if MainModule.BiggestThreatConnection then
		pcall(function()
			MainModule.BiggestThreatConnection:Disconnect()
		end)

		MainModule.BiggestThreatConnection = nil
	end
end

MainModule.toggle_biggest_threat = function(arg)
	local biggestThreatEnabled = arg and true or false
	MainModule.BiggestThreatEnabled = biggestThreatEnabled
	MainModule.clear_biggest_threat()
	if not biggestThreatEnabled then
		fn4()
		return true
	end

	local function fn11()
		local v4, v5 = MainModule.FindBiggestThreat()
		MainModule.clear_biggest_threat()
		if not v4 then
			fn2("Biggest Threat", "No players found", 0.9)
			return
		end
		fn2("Biggest Threat", tostring(v4.DisplayName or v4.Name) .. " â€” " .. tostring(v5) .. " wins", 1.5)
		local character = v4.Character

		if character then
			local highlight = Instance.new("Highlight")
			highlight.Name = "HSX_BiggestThreat"
			highlight.FillColor = Color3.fromRGB(255, 50, 50)
			highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
			highlight.FillTransparency = 0.55
			highlight.OutlineTransparency = 0
			highlight.Adornee = character
			highlight.Parent = character
			MainModule.BiggestThreatHighlight = highlight
		end

		MainModule.BiggestThreatConnection = v4.CharacterAdded:Connect(function(character2)
			if not MainModule.BiggestThreatEnabled then
				return
			end
			task.wait(0.2)

			if MainModule.BiggestThreatHighlight then
				pcall(function()
					MainModule.BiggestThreatHighlight:Destroy()
				end)
			end

			local highlight = Instance.new("Highlight")
			highlight.Name = "HSX_BiggestThreat"
			highlight.FillColor = Color3.fromRGB(255, 50, 50)
			highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
			highlight.FillTransparency = 0.55
			highlight.OutlineTransparency = 0
			highlight.Adornee = character2
			highlight.Parent = character2
			MainModule.BiggestThreatHighlight = highlight
		end)
	end

	fn11()

	task.spawn(function()
		while MainModule.BiggestThreatEnabled do
			task.wait(8)

			if MainModule.BiggestThreatEnabled then
				fn11()
			end
		end
	end)

	fn4()
	return true
end

do
	local v4 = v2:Tab({ Title = "Players", Icon = "users", Desc = "Teleport, spectate & stats" })
	local v5 = v4:Section({ Title = "Players", Icon = "users", Opened = true })

	MainModule.UIToggle(v5, {
		Id = "BiggestThreat",
		Title = "Biggest Threat",
		Desc = "Highlight player with most wins on server and shows a notify with nick and wins count",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_biggest_threat, arg)
		end,
	})

	local v6 = nil
	local v7 = nil

	local function fn11()
		local tbl5 = {}

		for _, player in ipairs(Players2:GetPlayers()) do
			if player ~= localPlayer2 then
				table.insert(tbl5, player.Name)
			end
		end

		if #tbl5 == 0 then
			table.insert(tbl5, "No players")
		end

		return tbl5
	end

	local v8 = MainModule.UIDropdown(v5, {
		Title = "Select Player",
		Desc = "Pick a player to TP / spectate / view stats",
		Values = fn11(),
		Value = "No players",
		Callback = function(arg)
			v6 = arg
			v7 = Players2:FindFirstChild(arg)
			_G.HSX_SelectedPlayer = v7
			fn7(v7)
		end,
	})

	task.spawn(function()
		while true do
			task.wait(2)

			pcall(function()
				if v8 and v8.Refresh then
					v8:Refresh(fn11())
				elseif v8 and v8.SetValues then
					v8:SetValues(fn11())
				end
			end)
		end
	end)

	v5:Button({
		Title = "Teleport to Selected",
		Desc = "TP to any selected player",
		Callback = function()
			local v9 = v6 and Players2:FindFirstChild(v6)

			if v9 then
				fn10(MainModule.teleport_to_player, v9)
			end
		end,
	})

	MainModule._KeybindPress.TpSelected = function()
		local v9 = v6 and Players2:FindFirstChild(v6)

		if v9 then
			fn10(MainModule.teleport_to_player, v9)
			fn2("Teleport", "To " .. tostring(v6), 0.8)
		else
			fn2("Teleport", "you didnt selected a player", 0.8)
			fn5()
		end
	end

	MainModule.Keybinds.TpSelected = MainModule.Keybinds.TpSelected or "None"
	MainModule.HSXRegisterKeybind("TpSelected", MainModule.Keybinds.TpSelected, MainModule._KeybindPress.TpSelected)

	v5:Button({
		Title = "Spectate Selected",
		Desc = "Spectate selected player",
		Callback = function()
			local v9 = v6 and Players2:FindFirstChild(v6)

			if v9 then
				fn10(MainModule.spectate_player, v9)
			end
		end,
	})

	v5:Button({
		Title = "Stop Spectating",
		Callback = function()
			fn10(MainModule.stop_spectate)
		end,
	})

	v5:Button({
		Title = "Teleport to Nearest",
		Callback = function()
			fn10(MainModule.teleportToNearest)
		end,
	})

	MainModule.Keybinds = MainModule.Keybinds or {}
	MainModule._KeybindPress = MainModule._KeybindPress or {}
	MainModule.Keybinds.TpNearest = MainModule.Keybinds.TpNearest or "G"

	MainModule._KeybindPress.TpNearest = function()
		fn10(MainModule.teleportToNearest)
	end

	MainModule.HSXRegisterKeybind("TpNearest", MainModule.Keybinds.TpNearest, MainModule._KeybindPress.TpNearest)

	pcall(function()
		local tpNearest = MainModule.Keybinds.TpNearest or "G"

		if tpNearest == "" or tpNearest == "None" then
			tpNearest = "G"
		end

		MainModule.Keybinds.TpNearest = tpNearest
		MainModule.HSXRegisterKeybind("TpNearest", tpNearest, MainModule._KeybindPress.TpNearest)
		local v9 = nil
		local raw = v5._raw or v5

		pcall(function()
			if type(raw.AddLabel) == "function" then
				v9 = raw:AddLabel("Tp Nearest Keybind")
			end
		end)

		local TpNearestKey

		if v9 then
			if v9.AddKeyPicker then
				TpNearestKey = v9:AddKeyPicker("TpNearestKey", {
					Default = tpNearest,
					Mode = "Hold",
					Text = "Tp Nearest",
					NoUI = false,
					Callback = function(arg)
						local v10 = MainModule.HSXNormalizeKey(arg)
						if not v10 or v10 == "" then
							return
						end
						MainModule.Keybinds.TpNearest = v10
						MainModule.HSXRegisterKeybind("TpNearest", v10, MainModule._KeybindPress.TpNearest)
					end,
					Changed = function(arg)
						local v10 = MainModule.HSXNormalizeKey(arg)
						if not v10 or v10 == "" then
							return
						end
						MainModule.Keybinds.TpNearest = v10
						MainModule.HSXRegisterKeybind("TpNearest", v10, MainModule._KeybindPress.TpNearest)
					end,
				})
			else
				v5:Keybind({
					Id = "TpNearestKey",
					Title = "Tp Nearest Keybind",
					Value = tpNearest,
					NoUI = false,
					Callback = function(arg)
						local v10 = MainModule.HSXNormalizeKey(arg)
						if not v10 or v10 == "" then
							return
						end
						MainModule.Keybinds.TpNearest = v10
						MainModule.HSXRegisterKeybind("TpNearest", v10, MainModule._KeybindPress.TpNearest)
					end,
				})

				TpNearestKey = nil
			end
		else
			v5:Keybind({
				Id = "TpNearestKey",
				Title = "Tp Nearest Keybind",
				Value = tpNearest,
				NoUI = false,
				Callback = function(arg)
					local v10 = MainModule.HSXNormalizeKey(arg)
					if not v10 or v10 == "" then
						return
					end
					MainModule.Keybinds.TpNearest = v10
					MainModule.HSXRegisterKeybind("TpNearest", v10, MainModule._KeybindPress.TpNearest)
				end,
			})

			TpNearestKey = nil
		end

		if TpNearestKey then
			MainModule.KeybindUI = MainModule.KeybindUI or {}
			MainModule.KeybindUI.TpNearest = MainModule.KeybindUI.TpNearest or {}
			table.insert(MainModule.KeybindUI.TpNearest, TpNearestKey)
		end
	end)

	MainModule.UIToggle(v5, {
		Id = "SpectateMode",
		Title = "Spectate Mode",
		Desc = "Allows spectating after winning a game",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_spectate_mode, arg)
		end,
	})

	local v9 = v4:Section({ Title = "Player Stats", Icon = "bar-chart-3", Opened = true })
	MainModule._PlayerStatLabels = {}

	for _, v10 in ipairs({
		"Wins",
		"Money",
		"Power",
		"GuardPower",
		"Level",
		"PowerSpins",
		"GuardSpins",
		"Robux",
		"VIP",
		"PermGuard",
		"Lighter",
	}) do
		MainModule._PlayerStatLabels[v10] = v9:Paragraph({ Title = v10 .. ": -" })
	end
end

do
	local v4 = v2:Tab({ Title = "Guards", Icon = "shield", Desc = "Gun tools" })
	local v5 = v4:Section({ Title = "Guns", Icon = "crosshair", Opened = true })

	MainModule.UIToggle(v5, {
		Id = "RapidFire",
		Title = "Rapid Fire",
		Desc = "Remove fire rate limit",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_rapid_fire, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "NoRecoil",
		Title = "No Recoil & Spread",
		Desc = "No Recoil & Spread",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_no_recoil, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "SilentAim",
		Title = "Silent Aim",
		Desc = "Wide FOV head lock on closest look target",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_silent_aim, arg)
		end,
	})

	MainModule.HSXToggleWithKey(v5, "Infinite Ammo", "InfAmmo", "None", function()
		return MainModule.InfiniteAmmoEnabled
	end, function(arg)
		fn10(MainModule.toggle_infinite_ammo, arg)
		return true
	end)

	MainModule.UIToggle(v5, {
		Id = "ArcadeAutoFarm",
		Title = "Auto Farm",
		Desc = "23M per 15-20secs for nothing (OP) and you get over 1.5b in a whole game",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_arcade_auto_farm, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "AutoPunch",
		Title = "Auto Punch Machine",
		Desc = "When you play punch game with enabled toggle you will dont need to click anything it will complete the game automatically",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_punch, arg)
		end,
	})

	local v6 = v4:Section({ Title = "Utilities", Icon = "wrench", Opened = true })

	MainModule.UIToggle(v6, {
		Id = "PermanentGuard",
		Title = "Free Permanent Guard",
		Desc = "Permanent guard gamepass unlock",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_permanent_guard, arg)
		end,
	})

	MainModule.UICheckbox(v6, {
		Id = "AutoBecomeGuard",
		Title = "Auto Become Guard",
		Desc = "Auto enroll as selected guard tier",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_become_guard, arg)
		end,
	})

	MainModule.UIDropdown(v6, {
		Title = "Select a guard tier to become",
		Values = { "Circle", "Triangle", "Square" },
		Value = "Circle",
		Callback = function(arg)
			fn10(MainModule.set_guard_tier, arg)
		end,
	})
end

do
	local v4 = v2:Tab({ Title = "Main", Icon = "warehouse", Desc = "Movement & misc" })
	local v5 = v4:Section({ Title = "Boosts", Icon = "zap", Opened = true })

	MainModule.UIToggle(v5, {
		Id = "NoDashPhantomCD",
		Title = "No Dash + Phantom Dash CD",
		Desc = "Removes dash and phantom dash cooldown",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_no_dash_phantom_cd, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "UpgradeFasterSprint",
		Title = "Upgrade Faster Sprint 5 to 6",
		Desc = "If you have Faster Sprint level 5 it becomes 6 and you can use chargeable dash",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_upgrade_faster_sprint, arg)
		end,
	})

	MainModule.UISlider(v5, {
		Id = "PhantomDashCooldownSlider",
		Title = "Phantom / Dash Cooldown",
		Desc = "Cooldown seconds for phantom dash charges",
		Value = { Min = 0.1, Max = 5, Default = 0.7 },
		Step = 0.1,
		Callback = function(arg)
			fn10(MainModule.set_phantom_dash_cooldown, arg)
		end,
	})

	MainModule.UISlider(v5, {
		Id = "PhantomDashDistanceSlider",
		Title = "Phantom Dash Distance",
		Desc = "How far phantom dash travels",
		Value = { Min = 5, Max = 50, Default = 15 },
		Step = 1,
		Callback = function(arg)
			fn10(MainModule.set_phantom_dash_distance, arg)
		end,
	})

	local hsxBindSlider = nil

	MainModule.UIToggle(v5, {
		Id = "SpeedHack",
		Title = "Speed Hack",
		Desc = "Increase your character speed",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_speed_hack, arg)

			if hsxBindSlider then
				hsxBindSlider.ensure(arg)
			end
		end,
	})

	hsxBindSlider = MainModule.HSXBindSlider

	hsxBindSlider = hsxBindSlider(v5, {
		ParentId = "SpeedHack",
		Id = "SpeedValue",
		Title = "Speed Value",
		Value = { Min = 16, Max = 50, Default = 39 },
		Step = 1,
		defaultValue = 39,
		Callback = function(arg)
			fn10(MainModule.set_speed_value, arg)
		end,
	})

	local v6 = nil

	MainModule.HSXToggleWithKey(v5, "Free Cam", "FreeCam", "None", function()
		return MainModule.FreeCam and MainModule.FreeCam.Enabled
	end, function(arg)
		fn10(MainModule.toggle_free_cam, arg)

		if v6 then
			v6.ensure(arg)
		end

		return true
	end)

	v6 = MainModule.HSXBindSlider(v5, {
		ParentId = "FreeCam",
		Id = "FreeCamSpeed",
		Title = "Free Cam Speed",
		Value = { Min = 1, Max = 50, Default = 10 },
		Step = 1,
		defaultValue = 10,
		Callback = function(baseSpeed)
			MainModule.FreeCam._BaseSpeed = baseSpeed
			fn10(MainModule.set_free_cam_speed, baseSpeed)
		end,
	})

	local hsxBindSlider2 = nil

	MainModule.UIToggle(v5, {
		Id = "CustomJumpPower",
		Title = "Custom Jump Power",
		Desc = "Changes your jump power",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_custom_jump_power, arg)

			if hsxBindSlider2 then
				hsxBindSlider2.ensure(arg)
			end
		end,
	})

	hsxBindSlider2 = MainModule.HSXBindSlider

	hsxBindSlider2 = hsxBindSlider2(v5, {
		ParentId = "CustomJumpPower",
		Id = "JumpPower",
		Title = "Jump Power",
		Value = { Min = 20, Max = 200, Default = 50 },
		Step = 1,
		defaultValue = 50,
		Callback = function(arg)
			fn10(MainModule.set_custom_jump_power, arg)
		end,
	})

	local hsxBindSlider3 = nil

	MainModule.UIToggle(v5, {
		Id = "CustomGravity",
		Title = "Custom Gravity",
		Desc = "Changes game gravity",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_custom_gravity, arg)

			if hsxBindSlider3 then
				hsxBindSlider3.ensure(arg)
			end
		end,
	})

	hsxBindSlider3 = MainModule.HSXBindSlider

	hsxBindSlider3 = hsxBindSlider3(v5, {
		ParentId = "CustomGravity",
		Id = "Gravity",
		Title = "Gravity",
		Value = { Min = 50, Max = 500, Default = 196.2 },
		Step = 0.1,
		defaultValue = 196.2,
		Callback = function(arg)
			fn10(MainModule.set_custom_gravity, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "InfiniteJump",
		Title = "Infinite Jump",
		Desc = "Allows your character to infinite jumps",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_infinite_jump, arg)
		end,
	})

	local v7 = v4:Section({ Title = "Misc", Icon = "wrench", Opened = true })

	pcall(function()
		if v7.Paragraph then
			v7:Paragraph({ Title = "Movechecks feature requires faster sprint lvl 5" })
		elseif v7._raw and v7._raw.AddLabel then
			v7._raw:AddLabel("Movechecks feature requires faster sprint lvl 5")
		end
	end)

	MainModule.UIToggle(v7, {
		Id = "MovecheckBypass",
		Title = "Movechecks Bypass",
		Desc = "it bypasses EVERY CHECKS like teleport, fly, speedhack AND OTHERS it works on every function and every game",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_movecheck_bypass, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "ThroughWalls",
		Title = "TP Through Walls",
		Desc = "Press X to teleport through wall in look direction",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_through_walls, arg)
		end,
	})

	local hsxBindSlider4 = nil

	MainModule.UIToggle(v7, {
		Id = "FOVChanger",
		Title = "FOV Changer",
		Desc = "Increase your field of view",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_fov, arg)

			if hsxBindSlider4 then
				hsxBindSlider4.ensure(arg)
			end
		end,
	})

	hsxBindSlider4 = MainModule.HSXBindSlider

	hsxBindSlider4 = hsxBindSlider4(v7, {
		ParentId = "FOVChanger",
		Id = "FOV",
		Title = "FOV",
		Value = { Min = 70, Max = 120, Default = 120 },
		Step = 1,
		defaultValue = 120,
		Callback = function(arg)
			fn10(MainModule.set_fov, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "Fullbright",
		Title = "Fullbright",
		Desc = "Makes everything bright whenever i enable it i want to fack my eyes",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_fullbright, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "InstantInteract",
		Title = "Instant Interact",
		Desc = "No proximity prompt cooldown",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_no_cooldown_proximity, arg)
		end,
	})

	local v8 = nil

	MainModule.HSXToggleWithKey(v7, "Flight", "Flight", "None", function()
		return MainModule.Fly and MainModule.Fly.Enabled
	end, function(arg)
		fn10(MainModule.toggle_fly, arg)

		if v8 then
			v8.ensure(arg)
		end

		return true
	end)

	v8 = MainModule.HSXBindSlider(v7, {
		ParentId = "Flight",
		Id = "FlySpeed",
		Title = "Fly Speed",
		Value = { Min = 10, Max = 200, Default = 50 },
		Step = 1,
		defaultValue = 50,
		Callback = function(arg)
			fn10(MainModule.set_fly_speed, arg)
		end,
	})

	MainModule.HSXToggleWithKey(v7, "Noclip", "Noclip", "None", function()
		return flag
	end, function(arg)
		return MainModule.toggle_noclip(arg)
	end, "Walk through walls")

	MainModule.UIToggle(v7, {
		Id = "HideOwnNickname",
		Title = "Hide Own Nametag",
		Desc = "Hide your nametag above ur head its very helpful if u want stream or smht",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_hide_nickname, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "HideAllNicknames",
		Title = "Hide All Nametags",
		Desc = "Hide all players nametags above head",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_hide_all_nicknames, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "GiveVisualItems",
		Title = "Give Visual Items",
		Desc = "Visual items (headless stuff and other shii)",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_visual_items, arg)
		end,
	})

	local v9 = v4:Section({ Title = "Custom", Icon = "pencil", Opened = true })
	MainModule.ClothesColorEnabled = MainModule.ClothesColorEnabled or false
	MainModule.VFXColorEnabled = MainModule.VFXColorEnabled or false
	MainModule.ClothesColor = MainModule.ClothesColor or Color3.fromRGB(255, 255, 255)
	MainModule.VFXColor = MainModule.VFXColor or Color3.fromRGB(0, 255, 255)
	MainModule.UniformColorValue = MainModule.UniformColorValue or MainModule.ClothesColor
	MainModule.SetUniformSkinEnabled = MainModule.ClothesColorEnabled
	MainModule.FakeSettings = MainModule.FakeSettings or { ["Custom Clothing Color"] = false, ["Custom Ability Color"] = false }

	MainModule.UIToggle(v9, {
		Id = "CustomUniformColor",
		Title = "Custom Clothes Color",
		Desc = "set your custom clothing color like with vip",
		Value = MainModule.ClothesColorEnabled,
		Callback = function(clothesColorEnabled)
			if MainModule.toggle_custom_uniform_color then
				MainModule.toggle_custom_uniform_color(clothesColorEnabled)
			else
				MainModule.ClothesColorEnabled = clothesColorEnabled

				if MainModule.UpdateVIPClothes then
					MainModule.UpdateVIPClothes()
				end
			end
		end,
	})

	pcall(function()
		v9:Colorpicker({
			Title = "Clothes Color",
			Default = MainModule.ClothesColor or Color3.fromRGB(255, 255, 255),
			Callback = function(clothesColor)
				if MainModule.set_uniform_color then
					MainModule.set_uniform_color(clothesColor)
				else
					MainModule.ClothesColor = clothesColor

					if MainModule.ClothesColorEnabled and MainModule.UpdateVIPClothes then
						MainModule.UpdateVIPClothes()
					end
				end
			end,
		})
	end)

	MainModule.UIToggle(v9, {
		Id = "CustomVFXColor",
		Title = "Custom VFX Color",
		Desc = "u can change vfx color like with vip",
		Value = MainModule.VFXColorEnabled,
		Callback = function(vfxColorEnabled)
			MainModule.VFXColorEnabled = vfxColorEnabled

			if MainModule.UpdateVIPVFX then
				MainModule.UpdateVIPVFX()
			end
		end,
	})

	pcall(function()
		v9:Colorpicker({
			Title = "VFX Color",
			Default = MainModule.VFXColor or Color3.fromRGB(0, 255, 255),
			Callback = function(vfxColor)
				MainModule.VFXColor = vfxColor

				if MainModule.VFXColorEnabled and MainModule.UpdateVIPVFX then
					MainModule.UpdateVIPVFX()
				end
			end,
		})
	end)

	MainModule.UIToggle(v9, {
		Id = "CustomWins",
		Title = "Custom Wins",
		Desc = "Spoof displayed win count (visual)",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_custom_win, arg)
		end,
	})

	MainModule.UIInput(v9, {
		Title = "Custom Win Value",
		Desc = "Type a number",
		Value = "67",
		Callback = function(arg)
			fn10(MainModule.set_custom_win, tonumber(arg) or 0)
		end,
	})

	MainModule.UIToggle(v9, {
		Id = "CustomWinstreak",
		Title = "Custom Winstreak",
		Desc = "Spoof ur winstreak in leaderboard (visual)",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_custom_winstreak, arg)
		end,
	})

	MainModule.UIInput(v9, {
		Title = "Custom Winstreak Value",
		Desc = "Type a number",
		Value = "0",
		Callback = function(arg)
			fn10(MainModule.set_custom_winstreak, tonumber(arg) or 0)
		end,
	})

	MainModule.UIToggle(v9, {
		Id = "CustomLevel",
		Title = "Custom Level",
		Desc = "Spoof ur level in leaderboard (visual)",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_custom_level, arg)
		end,
	})

	MainModule.UIInput(v9, {
		Title = "Custom Level Value",
		Desc = "Type a number",
		Value = "1",
		Callback = function(arg)
			if MainModule.set_custom_level then
				fn10(MainModule.set_custom_level, tonumber(arg) or 1)
			end
		end,
	})

	if not MainModule.InitSettingDataSpoof then
		MainModule.InitSettingDataSpoof = function()
			local ok, settingData = pcall(function()
				local effects = ReplicatedStorage:FindFirstChild("Effects")
				if not effects then
					return nil
				end
				local modules = effects:FindFirstChild("Modules")
				if not modules then
					return nil
				end
				local settingData = modules:FindFirstChild("SettingData")
				if not settingData then
					return nil
				end
				return require(settingData)
			end)

			if not ok or type(settingData) ~= "table" then
				return
			end
			MainModule._SettingData = settingData
			local fakeSettings = MainModule.FakeSettings
			local updateGameTables = nil

			updateGameTables = function(arg)
				for k, v10 in pairs(arg) do
					if k == "Custom Clothing Color" then
						arg[k] = fakeSettings["Custom Clothing Color"]
					elseif k == "Custom Ability Color" then
						arg[k] = fakeSettings["Custom Ability Color"]
					elseif typeof(v10) == "table" and v10 ~= arg then
						updateGameTables(v10)
					end
				end
			end

			MainModule._updateGameTables = updateGameTables

			for k, v10 in pairs(settingData) do
				if typeof(v10) == "function" then
					local v11 = v10

					settingData[k] = function(arg, ...)
						local v12 = table.pack(...)
						local tbl5 = { ... }
						if typeof(arg) == "string" and fakeSettings[arg] ~= nil then
							return fakeSettings[arg]
						end

						if typeof(tbl5[1]) == "string" and fakeSettings[tbl5[1]] ~= nil then
							return fakeSettings[tbl5[1]]
						end
						return v11(arg, table.unpack(v12, 1, v12.n))
					end
				end
			end
		end
	end

	task.spawn(function()
		pcall(MainModule.InitSettingDataSpoof)
	end)

	if not MainModule.UpdateVIPClothes then
		MainModule.UpdateVIPClothes = function()
			MainModule.FakeSettings["Custom Clothing Color"] = MainModule.ClothesColorEnabled

			pcall(function()
				if MainModule._updateGameTables and MainModule._SettingData then
					MainModule._updateGameTables(MainModule._SettingData)
				end
			end)

			local clothesColor = MainModule.ClothesColor or Color3.fromRGB(255, 255, 255)
			MainModule.UniformColorValue = clothesColor
			MainModule.SetUniformSkinEnabled = MainModule.ClothesColorEnabled
			_G.UniformColorValue = clothesColor
			_G.SetUniformSkinEnabled = MainModule.ClothesColorEnabled

			pcall(function()
				if MainModule.ClothesColorEnabled then
					localPlayer2:SetAttribute("ClothingColor", clothesColor)
					localPlayer2:SetAttribute("UniformColorValue", clothesColor)
					localPlayer2:SetAttribute("ClothingColorToggle", true)
					localPlayer2:SetAttribute("SetUniformSkinEnabled", true)
				else
					localPlayer2:SetAttribute("ClothingColor", nil)
					localPlayer2:SetAttribute("UniformColorValue", nil)
					localPlayer2:SetAttribute("ClothingColorToggle", false)
					localPlayer2:SetAttribute("SetUniformSkinEnabled", false)
				end
			end)
		end
	end

	if not MainModule.toggle_custom_uniform_color then
		MainModule.toggle_custom_uniform_color = function(arg)
			MainModule.ClothesColorEnabled = arg and true or false
			MainModule.UpdateVIPClothes()

			if fn4 then
				fn4()
			end

			return true
		end

		MainModule.toggle_clothes_color = MainModule.toggle_custom_uniform_color
	end

	if not MainModule.set_uniform_color then
		MainModule.set_uniform_color = function(clothesColor)
			if typeof(clothesColor) == "Color3" then
				MainModule.ClothesColor = clothesColor

				if MainModule.ClothesColorEnabled then
					MainModule.UpdateVIPClothes()
				end
			end
		end
	end

	if not MainModule.UpdateVIPVFX then
		MainModule.UpdateVIPVFX = function()
			MainModule.FakeSettings["Custom Ability Color"] = MainModule.VFXColorEnabled

			pcall(function()
				if MainModule._updateGameTables and MainModule._SettingData then
					MainModule._updateGameTables(MainModule._SettingData)
				end
			end)
		end
	end

	local v10 = v4:Section({ Title = "Emotes", Icon = "music", Opened = true })
	local v11 = tbl4[1] or nil

	local v12 = MainModule.UIDropdown(v10, {
		Title = "Select Emote",
		Desc = "Choose an emote to play",
		Values = tbl4,
		Value = tbl4[1] or "None",
		Callback = function(arg)
			v11 = arg
		end,
	})

	MainModule.UIInput(v10, {
		Title = "Search Emote",
		Value = "",
		Callback = function(arg)
			if not tbl4 then
				return
			end
			local tbl5 = {}

			if arg and arg ~= "" then
				for _, v13 in ipairs(tbl4) do
					if string.lower(v13):find(string.lower(arg), 1, true) then
						table.insert(tbl5, v13)
					end
				end
			else
				tbl5 = tbl4
			end

			if #tbl5 == 0 then
				tbl5 = { "No results" }
			end

			pcall(function()
				if v12.Refresh then
					v12:Refresh(tbl5)
				elseif v12.SetValues then
					v12:SetValues(tbl5)
				end
			end)
		end,
	})

	v10:Button({
		Title = "Play Emote",
		Desc = "Play selected emote (it also plays the sound of emote btw)",
		Callback = function()
			local v13 = ipairs
			local tbl5 = tbl3 or {}
			local v14 = nil

			for _, v15 in v13(tbl5) do
				if v15.Name == v11 then
					v14 = v15
					break
				else
					v14 = nil
				end
			end

			if v14 then
				playEmote(v14)
			else
				fn2("Emote", "Select an emote", 0.8)
			end
		end,
	})

	v10:Button({
		Title = "Stop Emote",
		Desc = "Stop current emote",
		Callback = function()
			stopEmote()
			fn2("Emote", "Stopped", 0.6)
		end,
	})
end

do
	local v4 = v2:Tab({ Title = "MainExtras", Icon = "star", Desc = "Anniversary + Admin Abuse" })
	local v5 = v4:Section({ Title = "Anniversary", Icon = "party-popper", Opened = true })

	MainModule.UIToggle(v5, {
		Id = "PeabertESP",
		Title = "Peabert ESP",
		Desc = "ESP + Tracers on peaberts that gives power rolls.",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_peabert_esp, arg)
		end,
	})

	v5:Button({
		Title = "TP to Peabert",
		Desc = "Teleport to nearest peabert",
		Callback = function()
			fn10(MainModule.tp_to_peaberts)
		end,
	})

	local v6 = v4:Section({ Title = "Admin Abuse Tools", Icon = "shield-alert", Opened = true })

	MainModule.UICheckbox(v6, {
		Id = "PeabertHitbox",
		Title = "Expand Peabert Hitboxes",
		Desc = "Expand hitboxes on Evil Peaberts",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_peabert_hitbox, arg)
		end,
	})

	MainModule.UICheckbox(v6, {
		Id = "PeabertBring",
		Title = "Bring all peaberts",
		Desc = "Brings Evil Peaberts to you",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_peabert_bring, arg)
		end,
	})

	MainModule.UIToggle(v6, {
		Id = "PeabertSilent",
		Title = "Silent Aim Peaberts",
		Desc = "Silent aim on Evil Peaberts",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_peabert_silent, arg)
		end,
	})
end

do
	local v4 = v2:Tab({ Title = "Extras", Icon = "sparkles", Desc = "Auto features & more" })
	local v5 = v4:Section({ Title = "Auto Features", Icon = "bot", Opened = true })

	MainModule.UIToggle(v5, {
		Id = "AutoWin",
		Title = "Auto Win",
		Desc = "Automatically teleports to end/safezone in RLGL, Dalgona, Light's out, HideAndSeek (Only Hider), JumpRope, GlassBridge",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_win, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "AutoNextGame",
		Title = "Auto Next Game",
		Desc = "Automatically teleports you to the next game",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_next_game, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "SafePlaceLowHealth",
		Title = "Safe Place on Low Health",
		Desc = "Teleports you to 100 blocks up when you have 30 HP or lowest",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_safe, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "AutoSkipDialogues",
		Title = "Auto Skip Dialogues",
		Desc = "Skip dialogue prompts",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_skip, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "AutoCollectBandage",
		Title = "Auto Collect Bandage",
		Desc = "Auto teleport u to the bandage if you dont have one",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_collect_bandage, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "AutoCollectFlashbang",
		Title = "Auto Collect Flashbang",
		Desc = "Auto teleport u to the flashbang if you dont have one",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_collect_flashbang, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "AutoCollectGrenade",
		Title = "Auto Collect Grenade",
		Desc = "Auto teleport u to the grenade if you dont have one",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_collect_grenade, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "AutoVote",
		Title = "Auto Vote",
		Desc = "Auto vote keep/stop",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_vote, arg)
		end,
	})

	MainModule.UIDropdown(v5, {
		Title = "Vote Option",
		Values = { "KeepPlaying", "StopPlaying" },
		Value = "KeepPlaying",
		Callback = function(arg)
			fn10(MainModule.set_vote_option, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "RageAutoQTE",
		Title = "RAGE Auto QTE",
		Desc = "Auto pressing QTE when they are spawn",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_rage_auto_qte, arg)
		end,
	})

	MainModule.UIToggle(v5, {
		Id = "LegitAutoQTE",
		Title = "Legit Auto QTE",
		Desc = "Normally pressing auto QTE in timing",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_legit_auto_qte, arg)
		end,
	})

	local v6 = v4:Section({ Title = "Misc Extras", Icon = "sparkles", Opened = true })

	MainModule.UICheckbox(v6, {
		Id = "DisableEffects",
		Title = "Disable Effects",
		Desc = "Disables all effects in the game, blood and others",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_disable_effects, arg)
		end,
	})

	MainModule.UICheckbox(v6, {
		Id = "ForcePowersSkySquid",
		Title = "Enable Powers in Sky Squid, Squid Game",
		Desc = "Keeps powers enabled in SkySquidGame / SquidGame",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_force_powers_sky_squid, arg)
		end,
	})

	MainModule.UIToggle(v6, {
		Id = "RemoveAnniversaryDecor",
		Title = "Remove Anniversary Decor",
		Desc = "Deletes all anniversary decorations to prevent lags on bad devices",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_remove_anniversary, arg)
		end,
	})

	MainModule.UIToggle(v6, {
		Id = "FakeExploiter",
		Title = "Fake Exploiter",
		Desc = "makes nearest target flying and using speedhack ONLY FOR YOU so you can report them in ink support",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_fake_exploiter, arg)
		end,
	})

	MainModule.UIToggle(v6, {
		Id = "AutoThrow",
		Title = "Auto Throw",
		Desc = "F / mobile button throw + face target helper",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_auto_throw, arg)
		end,
	})

	MainModule.UIToggle(v6, {
		Id = "TugOfWarQTE",
		Title = "Enable Tug of War QTE",
		Desc = "enables tug of war qte good if you want to test or just to practice",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_tug_of_war_qte, arg)
		end,
	})

	MainModule.UIToggle(v6, {
		Id = "Ambience",
		Title = "Ambience",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_ambience, arg)
		end,
	})

	MainModule.UIToggle(v6, {
		Id = "AntiFall",
		Title = "Anti Fall",
		Desc = "Semi-transparent platform under you (works everywhere)",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_global_anti_fall, arg)
		end,
	})

	v6:Button({
		Title = "Teleport Up 100",
		Callback = function()
			fn10(MainModule.teleport_up)
		end,
	})

	v6:Button({
		Title = "Teleport Down 40",
		Callback = function()
			fn10(MainModule.teleport_down)
		end,
	})

	local uiDropdown = nil

	MainModule.UIToggle(v6, {
		Id = "FreeTitle",
		Title = "Free Title",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_free_title, arg)
			MainModule.HSXShowHide(uiDropdown, arg)
		end,
	})

	uiDropdown = MainModule.UIDropdown

	uiDropdown = uiDropdown(v6, {
		Title = "Select Title",
		Values = {
			"Manipulator",
			"Rich Millionaire",
			"Rich Billionaire",
			"Fallen Angel",
			"Zeus",
			"Content Creator",
			"Aura Farmer",
			"The Recruiter",
			"Tanos",
			"The Glass Maker",
			"Frontman",
			"Squidder",
			"Game VIP",
			"Sackboy",
			"Him",
			"Honeycomb Artist",
			"The Chosen One",
			"Game Developer",
			"Game Administrator",
			"The Strongest",
			"The Perfect Lifeform",
			"Mastermind",
			"King of Curses",
			"Escape Artist",
			"Protagonist",
		},
		Value = "Rich Billionaire",
		Callback = function(arg)
			fn10(MainModule.set_title, arg)
		end,
	})

	MainModule.HSXShowHide(uiDropdown, false)
	local v7 = v4:Section({ Title = "Free Gamepasses", Icon = "gift", Opened = true })

	v7:Button({
		Title = "Free VIP",
		Callback = function()
			fn10(MainModule.unlock_vip)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "PermanentGuard",
		Title = "Permanent Guard",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_permanent_guard, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "CustomPlayerTag",
		Title = "Custom Player Tag",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_custom_player_tag, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "PrivateServerPlus",
		Title = "Private Server Plus",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_private_server_plus, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "Lighter",
		Title = "Lighter",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_lighter, arg)
		end,
	})

	MainModule.UIToggle(v7, {
		Id = "GlassVision",
		Title = "Glass Vision",
		Value = false,
		Callback = function(arg)
			fn10(MainModule.toggle_glass_vision, arg)
		end,
	})
end

do
	local v4 = v2:Tab({ Title = "Settings", Icon = "settings", Desc = "Menu, configs, themes" })
	local raw = v4._raw or v4
	local v5 = v4:Section({ Title = "Menu", Icon = "menu", Opened = true })

	pcall(function()
		local raw2 = v5._raw or v5

		if raw2.AddToggle then
			raw2:AddToggle("CustomCursor", {
				Text = "Custom Cursor",
				Default = true,
				Tooltip = "Enable/Disable custom Ishak Hub cursor",
				Callback = function(arg)
					cursorVisible = arg and true or false
					fn4()
				end,
			})
		elseif v5.Toggle then
			v5:Toggle({
				Title = "Custom Cursor",
				Desc = "Enable/Disable custom Ishak Hub cursor",
				Value = true,
				Callback = function(arg)
					cursorVisible = arg and true or false
					fn4()
				end,
			})
		end
	end)

	v5:Dropdown({
		Title = "Notification Side",
		Values = { "Left", "Right" },
		Value = "Right",
		Callback = function(arg)
			pcall(function()
				lib:SetNotifySide(arg)
			end)
		end,
	})

	v5:Toggle({
		Title = "Always On Top",
		Desc = "Keep Ishak Hub above other UI",
		Value = true,
		Callback = function(arg)
			pcall(function()
				if lib.SetAlwaysOnTop then
					lib:SetAlwaysOnTop(arg and true or false)
				elseif lib.AlwaysOnTop ~= nil then
					lib.AlwaysOnTop = arg and true or false
				end

				if v2 and v2.SetAlwaysOnTop then
					v2:SetAlwaysOnTop(arg and true or false)
				end
			end)
		end,
	})

	v5:Toggle({
		Title = "Background Blur",
		Desc = "Acrylic/blur behind the menu when open",
		Value = true,
		Callback = function(arg)
			pcall(function()
				if lib.ToggleAcrylic then
					lib:ToggleAcrylic(arg and true or false)
				elseif lib.SetAcrylic then
					lib:SetAcrylic(arg and true or false)
				elseif lib.Acrylic ~= nil then
					lib.Acrylic = arg and true or false
				end

				if lib.BackgroundBlur ~= nil then
					lib.BackgroundBlur = arg and true or false
				end
			end)
		end,
	})

	pcall(function()
		MainModule.Keybinds = MainModule.Keybinds or {}
		MainModule.Keybinds.Menu = MainModule.Keybinds.Menu or "Z"
		local menu = MainModule.Keybinds.Menu

		if not menu or menu == "" or menu == "None" then
			menu = "Z"
		end

		local raw2 = v5._raw or v5
		local addLabel = raw2.AddLabel and raw2:AddLabel("Menu bind") or nil
		local addKeyPicker = addLabel and addLabel.AddKeyPicker
		local MenuKeybind = nil

		if addKeyPicker then
			MenuKeybind = addLabel:AddKeyPicker("MenuKeybind", { Default = menu, Mode = "Toggle", Text = "Menu keybind", NoUI = true })
		end

		if lib.Options and lib.Options.MenuKeybind then
			lib.ToggleKeybind = lib.Options.MenuKeybind
		elseif MenuKeybind then
			lib.ToggleKeybind = MenuKeybind
		elseif Enum.KeyCode[menu] then
			lib.ToggleKeybind = Enum.KeyCode[menu]
		else
			lib.ToggleKeybind = Enum.KeyCode.Z
		end
	end)

	v5:Dropdown({
		Title = "DPI Scale",
		Values = { "50", "75", "80", "85", "90", "100", "125", "150", "175", "200" },
		Value = "100",
		Callback = function(arg)
			lib:SetDPIScale(tonumber(arg) or 100)
			fn4()
		end,
	})

	v5:Button({
		Title = "Unload Script",
		Callback = function()
			pcall(function()
				if MainModule.cleanup_everything then
					MainModule.cleanup_everything()
				end
			end)

			cursorVisible = false

			pcall(function()
				if _G.HollyScriptX_CursorDrawings then
					for _, hollyScriptXCursorDrawing in ipairs(_G.HollyScriptX_CursorDrawings) do
						pcall(function()
							hollyScriptXCursorDrawing.Visible = false

							if hollyScriptXCursorDrawing.Remove then
								hollyScriptXCursorDrawing:Remove()
							end
						end)
					end
				end
			end)

			pcall(function()
				if v2 and v2.Destroy then
					v2:Destroy()
				end
			end)

			pcall(function()
				if lib and lib.Unload then
					lib:Unload()
				end
			end)

			fn2("Ishak Hub", "Unloaded", 0.8)
		end,
	})

	v4:Section({ Title = "Keybinds", Icon = "keyboard", Opened = true }):Toggle({
		Title = "Show Keybinds Menu",
		Desc = "Show keybinds panel",
		Value = false,
		Callback = function(arg)
			pcall(function()
				if lib.KeybindFrame then
					lib.KeybindFrame.Visible = arg and true or false
				end
			end)
		end,
	})

	pcall(function()
		lib2:SetLibrary(lib)
		lib2:SetFolder("HollyScriptX")
		lib2:ApplyToTab(raw)
	end)

	pcall(function()
		lib3:SetLibrary(lib)
		lib3:IgnoreThemeSettings()
		lib3:SetIgnoreIndexes({ "MenuKeybind" })
		lib3:SetFolder("HollyScriptX")
		lib3:BuildConfigSection(raw)
		lib3:LoadAutoloadConfig()

		task.defer(function()
			task.wait(0.5)

			pcall(function()
				local toggleRefs = MainModule.ToggleRefs or MainModule._AllToggleRefs or {}

				local function fn11(arg)
					local v6 = toggleRefs[arg]
					if not v6 then
						return false
					end
					local value = nil

					pcall(function()
						if v6.Value ~= nil then
							value = v6.Value
						elseif v6.Get then
							value = v6:Get()
						elseif type(v6) == "table" and v6.Value ~= nil then
							value = v6.Value
						end
					end)

					return value and true or false
				end

				if fn11("PlayersESP") or fn11("NewESP") or fn11("OldESP") then
					if MainModule.toggle_new_esp and (fn11("PlayersESP") or fn11("NewESP")) then
						MainModule.toggle_new_esp(false)
						task.wait(0.05)
						MainModule.toggle_new_esp(true)
					end

					if MainModule.toggle_old_esp and fn11("OldESP") then
						MainModule.toggle_old_esp(false)
						task.wait(0.05)
						MainModule.toggle_old_esp(true)
					end

					pcall(function()
						local playersESP = toggleRefs.PlayersESP

						if playersESP and playersESP.SetValue then
							playersESP:SetValue(false)
							task.wait(0.05)
							playersESP:SetValue(true)
						end
					end)
				end
			end)
		end)
	end)
end

pcall(function()
	local menu = MainModule.Keybinds and MainModule.Keybinds.Menu or "Z"

	if v2.SetToggleKey and Enum.KeyCode[menu] then
		v2:SetToggleKey(Enum.KeyCode[menu])
	end
end)

-- The Discord information tab retains its explicit copy-invite button.

pcall(function()
	if lib.Options and lib.Options.MenuKeybind then
		lib.ToggleKeybind = lib.Options.MenuKeybind
	end
end)

task.spawn(function()
	pcall(function()
		local CoreGui2 = game:GetService("CoreGui")
		local hsxAlertSound = CoreGui2:FindFirstChild("HSX_AlertSound") or Instance.new("Sound")
		hsxAlertSound.SoundId = "rbxassetid://12222030"
		hsxAlertSound.Volume = 1
		hsxAlertSound.Name = "HSX_AlertSound"
		hsxAlertSound.Parent = CoreGui2

		local function fn11()
			pcall(function()
				if hsxAlertSound.IsLoaded then
					hsxAlertSound:Play()
				else
					hsxAlertSound.Loaded:Wait()
					hsxAlertSound:Play()
				end
			end)
		end

		task.wait(0.6)

		pcall(function()
			if lib and lib.Notify then
				local ok, result = pcall(function()
					return require(ReplicatedStorage.Modules.Effects)
				end)

				if ok and result and result.AnnouncementTween then
					result.AnnouncementTween({
						AnnouncementOneLine = true,
						FasterTween = true,
						DisplayTime = 4,
						AnnouncementDisplayText = "Ishak Hub - Successfully executed!",
					})
				elseif lib and lib.Notify then
					lib:Notify("Ishak Hub - Successfully executed!", 4)
				end
			elseif fn2 then
				fn2("Ishak Hub", "Successfully executed!", 4)
			end
		end)

		fn11()
		task.wait(4.2)

		pcall(function()
			if lib and lib.Notify then
				local ok, result = pcall(function()
					return require(ReplicatedStorage.Modules.Effects)
				end)

				if ok and result and result.AnnouncementTween then
					result.AnnouncementTween({
						AnnouncementOneLine = true,
						FasterTween = true,
						DisplayTime = 5,
						AnnouncementDisplayText = "Join discord.gg/fBTP3ry53Q for OP Scripts",
					})
				elseif lib and lib.Notify then
					lib:Notify("Join discord.gg/fBTP3ry53Q for OP Scripts", 5)
				end
			elseif fn2 then
				fn2("Ishak Hub", "Join discord.gg/fBTP3ry53Q for OP Scripts and more", 5)
			end
		end)

		fn11()
	end)
end)
