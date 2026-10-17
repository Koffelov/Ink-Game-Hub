local cloneref = (cloneref or clonereference or function(instance: any)
	return instance
end)
local clonefunction = (clonefunction or copyfunction or function(func)
	return func
end)

local HttpService: HttpService = cloneref(game:GetService("HttpService"))

--// Fix is_____ functions for shitsploits, those functions should never error, only return a boolean. (why is this still a problem in the big 2026)
local isfolder, isfile, listfiles = isfolder, isfile, listfiles
local isfolder_copy, isfile_copy, listfiles_copy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)
local isfolder_success, isfolder_error = pcall(function()
	return isfolder_copy("test" .. tostring(math.random(1000000, 9999999)))
end)


if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
	isfolder = function(folder)
		local success, data = pcall(isfolder_copy, folder)
		return (if success then data else false)
	end

	isfile = function(file)
		local success, data = pcall(isfile_copy, file)
		return (if success then data else false)
	end

	listfiles = function(folder)
		local success, data = pcall(listfiles_copy, folder)
		return (if success then data else {})
	end
end

--// Theme Manager
local SchemeIndexes = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }

local ThemeManager = {
	Library = nil,

	Folder = "Obsidian",

	AppliedToTab = false,
	DefaultThemeName = nil,

	BuiltInThemes = {
		["Default"] = { 1, { FontColor = "ffffff", MainColor = "191919", AccentColor = "7d55ff", BackgroundColor = "0f0f0f", OutlineColor = "282828", BackgroundImage = "" } },
		["BBot"] = { 2, { FontColor = "ffffff", MainColor = "1e1e1e", AccentColor = "7e48a3", BackgroundColor = "232323", OutlineColor = "141414", BackgroundImage = "" } },
		["Fatality"] = { 3, { FontColor = "ffffff", MainColor = "1e1842", AccentColor = "c50754", BackgroundColor = "191335", OutlineColor = "3c355d", BackgroundImage = "" } },
		["Jester"] = { 4, { FontColor = "ffffff", MainColor = "242424", AccentColor = "db4467", BackgroundColor = "1c1c1c", OutlineColor = "373737", BackgroundImage = "" } },
		["Mint"] = { 5, { FontColor = "ffffff", MainColor = "242424", AccentColor = "3db488", BackgroundColor = "1c1c1c", OutlineColor = "373737", BackgroundImage = "" } },
		["Tokyo Night"] = { 6, { FontColor = "ffffff", MainColor = "191925", AccentColor = "6759b3", BackgroundColor = "16161f", OutlineColor = "323232", BackgroundImage = "" } },
		["Ubuntu"] = { 7, { FontColor = "ffffff", MainColor = "3e3e3e", AccentColor = "e2581e", BackgroundColor = "323232", OutlineColor = "191919", BackgroundImage = "" } },
		["Quartz"] = { 8, { FontColor = "ffffff", MainColor = "232330", AccentColor = "426e87", BackgroundColor = "1d1b26", OutlineColor = "27232f", BackgroundImage = "" } },
		["Nord"] = { 9, { FontColor = "eceff4", MainColor = "3b4252", AccentColor = "88c0d0", BackgroundColor = "2e3440", OutlineColor = "4c566a", BackgroundImage = "" } },
		["Dracula"] = { 10, { FontColor = "f8f8f2", MainColor = "44475a", AccentColor = "ff79c6", BackgroundColor = "282a36", OutlineColor = "6272a4", BackgroundImage = "" } },
		["Monokai"] = { 11, { FontColor = "f8f8f2", MainColor = "272822", AccentColor = "f92672", BackgroundColor = "1e1f1c", OutlineColor = "49483e", BackgroundImage = "" } },
		["Gruvbox"] = { 12, { FontColor = "ebdbb2", MainColor = "3c3836", AccentColor = "fb4934", BackgroundColor = "282828", OutlineColor = "504945", BackgroundImage = "" } },
		["Solarized"] = { 13, { FontColor = "839496", MainColor = "073642", AccentColor = "cb4b16", BackgroundColor = "002b36", OutlineColor = "586e75", BackgroundImage = "" } },
		["Catppuccin"] = { 14, { FontColor = "d9e0ee", MainColor = "302d41", AccentColor = "f5c2e7", BackgroundColor = "1e1e2e", OutlineColor = "575268", BackgroundImage = "" } },
		["One Dark"] = { 15, { FontColor = "abb2bf", MainColor = "282c34", AccentColor = "c678dd", BackgroundColor = "21252b", OutlineColor = "5c6370", BackgroundImage = "" } },
		["Cyberpunk"] = { 16, { FontColor = "f9f9f9", MainColor = "262335", AccentColor = "00ff9f", BackgroundColor = "1a1a2e", OutlineColor = "413c5e", BackgroundImage = "" } },
		["Oceanic Next"] = { 17, { FontColor = "d8dee9", MainColor = "1b2b34", AccentColor = "6699cc", BackgroundColor = "16232a", OutlineColor = "343d46", BackgroundImage = "" } },
		["Material"] = { 18, { FontColor = "eeffff", MainColor = "212121", AccentColor = "82aaff", BackgroundColor = "151515", OutlineColor = "424242", BackgroundImage = "" } },
		["Discord"] = { 19, { FontColor = "ffffff", MainColor = "1a1a1e", AccentColor = "5865f2", BackgroundColor = "1a1a1e", OutlineColor = "292a2d", BackgroundImage = "" } },
	},

	Fonts = {
		"Antique",
		"Arcade",
		"Arial",
		"ArialBold",
		"Bodoni",
		"BuilderSans",
		"Cartoon",
		"Code",
		"Fantasy",
		"Garamond",
		"Gotham",
		"GothamBlack",
		"GothamBold",
		"GothamMedium",
		"Highway",
		"JosefinSans",
		"Jura",
		"Legacy",
		"LuckiestGuy",
		"Merriweather",
		"Nunito",
		"Roboto",
		"RobotoCondensed",
		"RobotoMono",
		"SciFi",
		"SourceSans",
		"SourceSansBold",
		"SourceSansItalic",
		"Ubuntu"
	}
}

function ThemeManager:SetLibrary(Library)
	ThemeManager.Library = Library
end

--// Helpers \\--
local function Trim(Text: string)
	return Text:match("^%s*(.-)%s*$")
end

local function IsStringEmpty(String: string): boolean
	return if typeof(String) == "string" then Trim(String) == "" else true
end

local function IsValidFolderPath(Name: string): boolean
	return typeof(Name) == "string" and (
		Trim(Name) ~= "" and
		not Name:match("^%s*$") and
		not Name:find('[<>:"|%?%*%z]')
	)
end

--// Folder helper \\--
local function SplitPath(Path: string): {string}
	local Result = {}
	local Current = ""

	for Part in string.gmatch(Path, "[^/]+") do
		Current = if Current == "" then Part else (Current .. "/" .. Part)
		table.insert(Result, Current)
	end

	return Result
end

local function GetFolderPath(): false | string
	if IsStringEmpty(ThemeManager.Folder) then
		return false
	end

	return string.format("%s/themes", ThemeManager.Folder)
end

local GetCurrentThemesPath = GetFolderPath

--// Files helper \\--
local function GetThemePath(ThemeName: string): false | string
	local CurrentThemesPath = GetCurrentThemesPath()
	return if CurrentThemesPath == false then false else string.format("%s/%s.json", CurrentThemesPath, ThemeName)
end

local function DoesThemeExist(ThemeName: string, IncludeBuiltIn: boolean?): boolean
	if IncludeBuiltIn ~= false and ThemeManager.BuiltInThemes[ThemeName] then
		return true
	end

	local ThemePath = GetThemePath(ThemeName)
	return if ThemePath == false then false else isfile(ThemePath)
end

local function GetDefaultThemePath(): false | string
	local CurrentThemesPath = GetCurrentThemesPath()
	return if CurrentThemesPath == false then false else string.format("%s/default.txt", CurrentThemesPath)
end

--// Folders \\--
function ThemeManager:GetPaths(): {string}
	local FolderPath = GetFolderPath()
	return if FolderPath == false then {} else SplitPath(FolderPath)
end

function ThemeManager:BuildFolderTree(SkipWhenCreated: boolean?)
	local Paths = ThemeManager:GetPaths()
	if #Paths == 0 then
		return false
	end

	if SkipWhenCreated == true then
		if isfolder(Paths[1]) then
			return true
		end
	end

	for _, Path in Paths do
		if isfolder(Path) then continue end
		makefolder(Path)
	end

	return true
end

function ThemeManager:CheckFolderTree()
	return ThemeManager:BuildFolderTree(true)
end

function ThemeManager:SetFolder(Folder: string)
	assert(IsValidFolderPath(Folder), "Invalid path provided")

	ThemeManager.Folder = Folder
	ThemeManager:BuildFolderTree()
end

--// Theme Management \\--
function ThemeManager:ReloadCustomThemes()
	local SettingsPath = GetCurrentThemesPath()
	if SettingsPath == false then
		return {}
	end

	local SuccessList, Files = pcall(listfiles, SettingsPath)
	if not (SuccessList and typeof(Files) == "table") then
		ThemeManager.Library:Notify({
			Title = "Error",
			Description = string.format("Failed to load theme list: %s", tostring(Files)),
			Icon = "circle-x",
		})
		return {}
	end

	local FileNames = {}
	for _, FilePath in Files do
		local RawFileName = FilePath:match("(.+)%..+$")
		if not RawFileName then continue end

		local Position = RawFileName:gsub("\\", "/"):find("/[^/]*$")
		local FileName = Position and RawFileName:sub(Position + 1) or RawFileName
		if not FileName or FileName == "default" then continue end

		table.insert(FileNames, FileName)
	end

	return FileNames
end

function ThemeManager:GetCustomTheme(ThemeName: string): any
	if IsStringEmpty(ThemeName) then
		return nil
	end

	local ThemePath = GetThemePath(ThemeName)
	if ThemePath == false or not isfile(ThemePath) then
		return nil
	end

	local SuccessRead, Content = pcall(readfile, ThemePath)
	if not SuccessRead then
		return nil
	end

	local SuccessDecode, Decoded = pcall(HttpService.JSONDecode, HttpService, Content)
	if not SuccessDecode or typeof(Decoded) ~= "table" then
		return nil
	end

	return Decoded
end

function ThemeManager:SaveCustomTheme(ThemeName: string): (boolean, string?)
	if IsStringEmpty(ThemeName) then
		return false, "Invalid theme name provided"
	end

	if string.lower(ThemeName) == "default" then
		return false, "Invalid theme name provided"
	end

	local ThemePath = GetThemePath(ThemeName)
	if ThemePath == false then
		return false, "Invalid theme name provided"
	end

	ThemeManager:CheckFolderTree()

	local Library = ThemeManager.Library
	local ThemeData = {
		FontFace = Library.Options.FontFace.Value,
		BackgroundImage = Library.Options.BackgroundImage.Value,
		BackgroundImageEnabled = if Library.Toggles.BackgroundImageEnabled then Library.Toggles.BackgroundImageEnabled.Value else false,
		WindowGlow = if Library.Toggles.WindowGlow then Library.Toggles.WindowGlow.Value else false,
	}

	for _, SchemeIndex in SchemeIndexes do
		ThemeData[SchemeIndex] = Library.Options[SchemeIndex].Value:ToHex()
	end

	local SuccessEncode, EncodedData = pcall(HttpService.JSONEncode, HttpService, ThemeData)
	if not SuccessEncode then
		return false, "Failed to encode data"
	end

	local SuccessWrite, ErrorMessage = pcall(writefile, ThemePath, EncodedData)
	if not SuccessWrite then
		return false, "Failed to write theme file: " .. tostring(ErrorMessage)
	end

	return true
end

function ThemeManager:Delete(ThemeName: string): (boolean, string?)
	if IsStringEmpty(ThemeName) then
		return false, "No theme is selected"
	end

	local ThemePath = GetThemePath(ThemeName)
	if ThemePath == false or not isfile(ThemePath) then
		return false, "Theme file does not exist"
	end

	local SuccessDelete, ErrorMessage = pcall(delfile, ThemePath)
	if not SuccessDelete then
		return false, "Failed to delete theme file: " .. tostring(ErrorMessage)
	end

	if ThemeName == ThemeManager.DefaultThemeName then
		ThemeManager:DeleteDefaultTheme()
	end

	return true
end

function ThemeManager:ExportTheme(ThemeName: string): (boolean, string?)
	if IsStringEmpty(ThemeName) then
		return false, "No theme is selected"
	end

	local ThemePath = GetThemePath(ThemeName)
	if ThemePath == false or not isfile(ThemePath) then
		return false, "Theme file does not exist"
	end

	local SuccessRead, Content = pcall(readfile, ThemePath)
	if not SuccessRead then
		return false, "Failed to read theme file"
	end

	return true, Content
end

function ThemeManager:ImportTheme(ThemeData: string): (boolean, string?)
	if IsStringEmpty(ThemeData) then
		return false, "No theme data provided"
	end

	local SuccessDecode, Decoded = pcall(HttpService.JSONDecode, HttpService, ThemeData)
	if not SuccessDecode or typeof(Decoded) ~= "table" then
		return false, "Invalid JSON data"
	end

	local Library = ThemeManager.Library

	for Index, Value in Decoded do
		if Index == "FontFace" then
			if Enum.Font[Value] then
				Library:SetFont(Enum.Font[Value])
				if Library.Options.FontFace then
					Library.Options.FontFace:SetValue(Value)
				end
			end
		elseif Index == "BackgroundImage" then
			Library:SetBackgroundImage(Value)
			if Library.Options.BackgroundImage then
				Library.Options.BackgroundImage:SetValue(Value)
			end
		elseif Index == "BackgroundImageEnabled" then
			if Library.Toggles.BackgroundImageEnabled then
				Library.Toggles.BackgroundImageEnabled:SetValue(Value == true)
			end
			if Library.SetBackgroundImageEnabled then
				Library:SetBackgroundImageEnabled(Value == true)
			end
		elseif Index == "WindowGlow" then
			if Library.Toggles.WindowGlow then
				Library.Toggles.WindowGlow:SetValue(Value == true)
			end
			if Library.SetGlow then
				Library:SetGlow(Value == true)
			end
		elseif table.find(SchemeIndexes, Index) then
			local Color = Color3.fromHex(Value)
			Library.Scheme[Index] = Color
			if Library.Options[Index] then
				Library.Options[Index]:SetValueRGB(Color)
			end
		end
	end

	ThemeManager:ThemeUpdate()
	return true
end

--// Default Theme \\--
function ThemeManager:GetDefaultTheme(): (string, boolean, string?)
	ThemeManager:CheckFolderTree()

	local DefaultThemePath = GetDefaultThemePath()
	if DefaultThemePath == false then
		return "none", false, "Invalid path provided"
	end

	if not isfile(DefaultThemePath) then
		return "none", false, "Default theme is not set"
	end

	local SuccessRead, DefaultThemeName = pcall(readfile, DefaultThemePath)
	if not (SuccessRead and typeof(DefaultThemeName) == "string") then
		return "none", false, DefaultThemeName
	end

	local ThemeExists = DoesThemeExist(DefaultThemeName, true)
	if not ThemeExists then
		return "none", false, "Theme file not found"
	end

	ThemeManager.DefaultThemeName = DefaultThemeName
	return DefaultThemeName, true
end

function ThemeManager:SetDefaultTheme(Theme: any)
	assert(ThemeManager.Library, "Library is not set, call ThemeManager:SetLibrary(Library) first.")
	assert(not ThemeManager.AppliedToTab, "Cannot set default theme after applying ThemeManager to a tab!")

	local Library = ThemeManager.Library
	local DefaultThemeData = ThemeManager.BuiltInThemes["Default"][2]

	local LibraryScheme = {}
	local FinalTheme = {}

	for _, SchemeIndex in SchemeIndexes do
		local IndexData = Theme[SchemeIndex]
		local IndexType = typeof(IndexData)

		if IndexType == "Color3" then
			LibraryScheme[SchemeIndex] = IndexData
			FinalTheme[SchemeIndex] = string.format("#%s", IndexData:ToHex())
		elseif IndexType == "string" then
			LibraryScheme[SchemeIndex] = Color3.fromHex(IndexData)
			FinalTheme[SchemeIndex] = if IndexData:sub(1, 1) == "#" then IndexData else string.format("#%s", IndexData)
		else
			local Value = DefaultThemeData[SchemeIndex]
			LibraryScheme[SchemeIndex] = Color3.fromHex(Value)
			FinalTheme[SchemeIndex] = Value
		end
	end

	local FontFace = Theme["FontFace"]
	local FontFaceType = typeof(FontFace)

	if FontFaceType == "EnumItem" then
		LibraryScheme.Font = Font.fromEnum(FontFace)
		FinalTheme.FontFace = FontFace.Name
	elseif FontFaceType == "string" then
		LibraryScheme.Font = Font.fromEnum(Enum.Font[FontFace] :: Enum.Font)
		FinalTheme.FontFace = FontFace
	else
		LibraryScheme.Font = Font.fromEnum(Enum.Font.Code)
		FinalTheme.FontFace = "Code"
	end

	for _, DefaultSchemeColor in { "RedColor", "DestructiveColor", "DarkColor", "WhiteColor" } do
		LibraryScheme[DefaultSchemeColor] = Library.Scheme[DefaultSchemeColor]
	end

	Library.Scheme = LibraryScheme
	ThemeManager.BuiltInThemes["Default"] = { 1, FinalTheme }

	Library:UpdateColorsUsingRegistry()
end

function ThemeManager:SaveDefault(ThemeName: string): (boolean, string?)
	if IsStringEmpty(ThemeName) then
		return false, "No theme is selected"
	end

	ThemeManager:CheckFolderTree()

	local DefaultThemePath = GetDefaultThemePath()
	if DefaultThemePath == false then
		return false, "Invalid path provided"
	end

	if not DoesThemeExist(ThemeName, true) then
		return false, "Theme does not exist"
	end

	local SuccessWrite, ErrorMessage = pcall(writefile, DefaultThemePath, ThemeName)
	if not SuccessWrite then
		return false, ErrorMessage
	end

	ThemeManager.DefaultThemeName = ThemeName
	return true
end

function ThemeManager:LoadDefault()
	local ThemeName, Success, FetchErrorMessage = ThemeManager:GetDefaultTheme()
	if not Success or FetchErrorMessage then
		if FetchErrorMessage ~= "Default theme is not set" then
			ThemeManager.Library:Notify({
				Title = "Error",
				Description = string.format("Failed to apply default theme: %s", FetchErrorMessage),
				Icon = "circle-x",
			})
		end
		return
	end

	if not ThemeManager:GetCustomTheme(ThemeName) then
		ThemeManager.Library.Options.ThemeManager_ThemeList:SetValue(ThemeName)
		return
	end

	local SuccessLoad, LoadErrorMessage = ThemeManager:ApplyTheme(ThemeName)
	if not SuccessLoad then
		ThemeManager.Library:Notify({
			Title = "Error",
			Description = string.format("Failed to apply default theme: %s", LoadErrorMessage),
			Icon = "circle-x",
		})
		return
	end

	ThemeManager.Library:Notify({
		Title = "Default Theme Applied",
		Description = string.format("Successfully applied default theme %q.", ThemeName),
		Time = 3,
		Icon = "circle-check"
	})
end

function ThemeManager:DeleteDefaultTheme(): (boolean, string?)
	ThemeManager:CheckFolderTree()

	local DefaultThemePath = GetDefaultThemePath()
	if DefaultThemePath == false then
		return false, "Invalid path provided"
	end

	if not isfile(DefaultThemePath) then
		return false, "Default theme is not set"
	end

	local SuccessDelete, ErrorMessage = pcall(delfile, DefaultThemePath)
	if not SuccessDelete then
		return false, ErrorMessage
	end

	ThemeManager.DefaultThemeName = nil
	return true
end

--// Apply Theme \\--
function ThemeManager:ThemeUpdate()
	local Library = ThemeManager.Library

	for _, SchemeIndex in SchemeIndexes do
		local Element = Library.Options[SchemeIndex]
		if not Element then continue end
		Library.Scheme[SchemeIndex] = Element.Value
	end

	Library:UpdateColorsUsingRegistry()
end

function ThemeManager:ApplyTheme(ThemeName: string)
	if IsStringEmpty(ThemeName) then
		return false, "No theme is selected"
	end

	local CustomThemeData = ThemeManager:GetCustomTheme(ThemeName)
	local Data = CustomThemeData or ThemeManager.BuiltInThemes[ThemeName]

	if not Data then
		return false, "Theme not found"
	end

	local Library = ThemeManager.Library
	local ThemeData = CustomThemeData or Data[2]

	for Index, Value in ThemeData do
		if Index == "VideoLink" then continue end

		local Element = Library.Options[Index]
		local FinalValue = Value

		if Index == "FontFace" then
			ThemeManager.Library:SetFont(Enum.Font[FinalValue])
		elseif Index == "BackgroundImage" then
			ThemeManager.Library:SetBackgroundImage(FinalValue)
		elseif Index == "BackgroundImageEnabled" then
			if Library.Toggles.BackgroundImageEnabled then
				Library.Toggles.BackgroundImageEnabled:SetValue(Value == true)
			end
			if Library.SetBackgroundImageEnabled then
				Library:SetBackgroundImageEnabled(Value == true)
			end
		elseif Index == "WindowGlow" then
			if Library.Toggles.WindowGlow then
				Library.Toggles.WindowGlow:SetValue(Value == true)
			end
			if Library.SetGlow then
				Library:SetGlow(Value == true)
			end
		else
			FinalValue = Color3.fromHex(Value)
			Library.Scheme[Index] = FinalValue
		end

		if Element then
			Element:SetValue(FinalValue)
		end
	end

	ThemeManager:ThemeUpdate()
	return true
end

--// GUI \\--
function ThemeManager:CreateThemeManager(Themesbox: any)
	assert(ThemeManager.Library, "Library is not set, call ThemeManager:SetLibrary(Library) first.")

	local BuiltInThemesNames = {}
	for Name, _ThemeData in ThemeManager.BuiltInThemes do
		table.insert(BuiltInThemesNames, Name)
	end

	local CustomThemeList, CustomThemeName, ThemeList, FontFace, BackgroundImage, ThemeJSONInput, DefaultThemeLabel

	local function RefreshList()
		CustomThemeList:SetValues(ThemeManager:ReloadCustomThemes())
		CustomThemeList:SetValue(nil)
		ThemeList:SetValues(BuiltInThemesNames)
	end

	local function RefreshDefaultThemeLabel()
		local DefaultThemeName = ThemeManager:GetDefaultTheme()
		DefaultThemeLabel:SetText(string.format("Current default theme: %s", DefaultThemeName))
		if CustomThemeList then
			RefreshList()
		end
	end

	table.sort(BuiltInThemesNames, function(a, b)
		return ThemeManager.BuiltInThemes[a][1] < ThemeManager.BuiltInThemes[b][1]
	end)

	local function CreateColorOption(Text, SchemeIndex)
		Themesbox:AddLabel(Text):AddColorPicker(SchemeIndex, {
			Default = ThemeManager.Library.Scheme[SchemeIndex]
		})
		return ThemeManager.Library.Options[SchemeIndex]
	end

	--// Color Options
	local BackgroundColor = CreateColorOption("Background Color", "BackgroundColor")
	local MainColor = CreateColorOption("Main Color", "MainColor")
	local AccentColor = CreateColorOption("Accent Color", "AccentColor")
	local OutlineColor = CreateColorOption("Outline Color", "OutlineColor")
	local FontColor = CreateColorOption("Font Color", "FontColor")

	Themesbox:AddToggle("BackgroundImageEnabled", {
		Text = "Enable Background Image",
		Default = ThemeManager.Library.Scheme.BackgroundImageEnabled or false
	})

	Themesbox:AddInput("BackgroundImage", {
		Text = "Background Image",
		Default = "",
		Finished = true,
		ClearTextOnFocus = false,
		ClearTextOnBlur = false
	})

	Themesbox:AddToggle("WindowGlow", {
		Text = "Window Glow",
		Default = ThemeManager.Library.Scheme.WindowGlow or false
	})

	Themesbox:AddDropdown("FontFace", {
		Text = "Font Face",
		Default = "Code",
		Values = ThemeManager.Fonts,
		AllowNull = false,
		Multi = false
	})

	Themesbox:AddDivider()

	--// Built-in Themes
	Themesbox:AddDropdown("ThemeManager_ThemeList", {
		Text = "Theme List",
		Values = BuiltInThemesNames,
		AllowNull = true,
		Multi = false,

		FormatDisplayValue = function(Value: any)
			if Value ~= "Default" and Value == ThemeManager.DefaultThemeName then
				return string.format("%s (Default)", Value)
			end
			return Value
		end,
		FormatListValue = function(Value: any)
			if Value ~= "Default" and Value == ThemeManager.DefaultThemeName then
				return string.format("%s (Default)", Value)
			end
			return Value
		end
	})

	Themesbox:AddButton("Set as Default", function()
		local ThemeName = ThemeList.Value
		if IsStringEmpty(ThemeName) then
			ThemeManager.Library:Notify({
				Title = "No Theme Selected",
				Description = "Please select a theme first.",
				Time = 3,
				Icon = "triangle-alert"
			})
			return
		end

		local Success, ErrorMessage = ThemeManager:SaveDefault(ThemeName)
		if not Success then
			ThemeManager.Library:Notify({
				Title = "Error",
				Description = string.format("Failed to set default theme: %s", ErrorMessage),
				Icon = "circle-x"
			})
			return
		end

		ThemeManager.Library:Notify({
			Title = "Default Theme Set",
			Description = string.format("Successfully set default theme to %q.", ThemeName),
			Time = 3,
			Icon = "circle-check"
		})
		RefreshDefaultThemeLabel()
	end)

	Themesbox:AddDivider()

	--// Create Custom Theme
	CustomThemeName = Themesbox:AddInput("ThemeManager_CustomThemeName", {
		Text = "Custom Theme Name"
	})

	Themesbox:AddButton("Create Theme", function()
		local Name = CustomThemeName.Value
		if IsStringEmpty(Name) then
			ThemeManager.Library:Notify({
				Title = "Empty Theme Name",
				Description = "Theme name cannot be empty.",
				Time = 3,
				Icon = "triangle-alert"
			})
			return
		end

		if string.lower(Name) == "default" then
			ThemeManager.Library:Notify({
				Title = "Invalid Theme Name",
				Description = "Theme name cannot be \"default\".",
				Time = 3,
				Icon = "triangle-alert"
			})
			return
		end

		local Success, ErrorMessage = ThemeManager:SaveCustomTheme(Name)
		if not Success then
			ThemeManager.Library:Notify({
				Title = "Error",
				Description = string.format("Failed to create theme %q: %s", Name, ErrorMessage),
				Icon = "circle-x"
			})
			return
		end

		ThemeManager.Library:Notify({
			Title = "Theme Created",
			Description = string.format("Successfully created theme %q.", Name),
			Time = 3,
			Icon = "circle-check"
		})
		RefreshList()
	end)

	Themesbox:AddDivider()

	--// Custom Themes Management
	CustomThemeList = Themesbox:AddDropdown("ThemeManager_CustomThemeList", {
		Text = "Custom Themes",
		Values = ThemeManager:ReloadCustomThemes(),
		AllowNull = true,
		Multi = false,

		FormatDisplayValue = function(Value: any)
			if Value == ThemeManager.DefaultThemeName then
				return string.format("%s (Default)", Value)
			end
			return Value
		end,
		FormatListValue = function(Value: any)
			if Value == ThemeManager.DefaultThemeName then
				return string.format("%s (Default)", Value)
			end
			return Value
		end
	})

	Themesbox:AddButton("Load", function()
		local Name = CustomThemeList.Value
		if IsStringEmpty(Name) then
			ThemeManager.Library:Notify({
				Title = "No Theme Selected",
				Description = "Please select a theme first.",
				Time = 3,
				Icon = "triangle-alert"
			})
			return
		end

		local Success, ErrorMessage = ThemeManager:ApplyTheme(Name)
		if not Success then
			ThemeManager.Library:Notify({
				Title = "Error",
				Description = string.format("Failed to load theme %q: %s", Name, ErrorMessage),
				Icon = "circle-x"
			})
			return
		end

		ThemeManager.Library:Notify({
			Title = "Theme Loaded",
			Description = string.format("Successfully loaded theme %q.", Name),
			Time = 3,
			Icon = "circle-check"
		})
	end):AddButton({
		Text = "Overwrite",
		DoubleClick = true,
		Func = function()
			local Name = CustomThemeList.Value
			if IsStringEmpty(Name) then
				ThemeManager.Library:Notify({
					Title = "No Theme Selected",
					Description = "Please select a theme first.",
					Time = 3,
					Icon = "triangle-alert"
				})
				return
			end

			local Success, ErrorMessage = ThemeManager:SaveCustomTheme(Name)
			if not Success then
				ThemeManager.Library:Notify({
					Title = "Error",
					Description = string.format("Failed to overwrite theme %q: %s", Name, ErrorMessage),
					Icon = "circle-x"
				})
				return
			end

			ThemeManager.Library:Notify({
				Title = "Theme Overwritten",
				Description = string.format("Successfully overwrote theme %q.", Name),
				Time = 3,
				Icon = "circle-check"
			})
		end
	})

	Themesbox:AddButton({
		Text = "Delete",
		DoubleClick = true,
		Func = function()
			local Name = CustomThemeList.Value
			if IsStringEmpty(Name) then
				ThemeManager.Library:Notify({
					Title = "No Theme Selected",
					Description = "Please select a theme first.",
					Time = 3,
					Icon = "triangle-alert"
				})
				return
			end

			local Success, ErrorMessage = ThemeManager:Delete(Name)
			if not Success then
				ThemeManager.Library:Notify({
					Title = "Error",
					Description = string.format("Failed to delete theme %q: %s", Name, ErrorMessage),
					Icon = "circle-x"
				})
				return
			end

			ThemeManager.Library:Notify({
				Title = "Theme Deleted",
				Description = string.format("Successfully deleted theme %q.", Name),
				Time = 3,
				Icon = "circle-check"
			})
			RefreshDefaultThemeLabel()
		end
	}):AddButton("Export", function()
		local Name = CustomThemeList.Value
		if IsStringEmpty(Name) then
			ThemeManager.Library:Notify({
				Title = "No Theme Selected",
				Description = "Please select a theme first.",
				Time = 3,
				Icon = "triangle-alert"
			})
			return
		end

		local Success, Data = ThemeManager:ExportTheme(Name)
		if not Success then
			ThemeManager.Library:Notify({
				Title = "Error",
				Description = string.format("Failed to export theme: %s", Data),
				Icon = "circle-x"
			})
			return
		end

		ThemeJSONInput:SetValue(Data)
		if setclipboard then
			setclipboard(Data)
			ThemeManager.Library:Notify({
				Title = "Copied to Clipboard",
				Description = string.format("Successfully exported theme %q to clipboard.", Name),
				Time = 3,
				Icon = "circle-check"
			})
		else
			ThemeManager.Library:Notify({
				Title = "Theme Exported",
				Description = "Theme has been exported to the JSON field.",
				Time = 3,
				Icon = "circle-check"
			})
		end
	end)

	Themesbox:AddButton("Refresh List", RefreshList)

	Themesbox:AddDivider()

	DefaultThemeLabel = Themesbox:AddLabel("Current default theme: none", true)

	Themesbox:AddButton("Set as Default", function()
		local Name = CustomThemeList.Value
		if IsStringEmpty(Name) then
			ThemeManager.Library:Notify({
				Title = "No Theme Selected",
				Description = "Please select a theme first.",
				Time = 3,
				Icon = "triangle-alert"
			})
			return
		end

		local Success, ErrorMessage = ThemeManager:SaveDefault(Name)
		if not Success then
			ThemeManager.Library:Notify({
				Title = "Error",
				Description = string.format("Failed to set default theme: %s", ErrorMessage),
				Icon = "circle-x"
			})
			return
		end

		ThemeManager.Library:Notify({
			Title = "Default Theme Set",
			Description = string.format("Successfully set default theme to %q.", Name),
			Time = 3,
			Icon = "circle-check"
		})
		RefreshDefaultThemeLabel()
	end):AddButton({
		Text = "Reset Default",
		DoubleClick = true,
		Func = function()
			local Success, ErrorMessage = ThemeManager:DeleteDefaultTheme()
			if not Success then
				ThemeManager.Library:Notify({
					Title = "Error",
					Description = string.format("Failed to reset default theme: %s", ErrorMessage),
					Icon = "circle-x"
				})
				return
			end

			ThemeManager.Library:Notify({
				Title = "Default Theme Reset",
				Description = "Successfully reset the default theme.",
				Time = 3,
				Icon = "circle-check"
			})
			RefreshDefaultThemeLabel()
		end
	})

	Themesbox:AddDivider()

	--// Import / Export JSON
	ThemeJSONInput = Themesbox:AddInput("ThemeManager_JSON", {
		Text = "Theme JSON"
	})

	Themesbox:AddButton({
		Text = "Import Theme",
		DoubleClick = true,
		Func = function()
			local ThemeJSON = ThemeJSONInput.Value
			if IsStringEmpty(ThemeJSON) then
				ThemeManager.Library:Notify({
					Title = "Empty JSON",
					Description = "Theme JSON cannot be empty.",
					Time = 3,
					Icon = "triangle-alert"
				})
				return
			end

			local Success, ErrorMessage = ThemeManager:ImportTheme(ThemeJSON)
			if not Success then
				ThemeManager.Library:Notify({
					Title = "Error",
					Description = string.format("Failed to import theme: %s", ErrorMessage),
					Icon = "circle-x"
				})
				return
			end

			ThemeManager.Library:Notify({
				Title = "Theme Imported",
				Description = "Successfully imported the theme.",
				Time = 3,
				Icon = "circle-check"
			})
		end
	})

	--// Set Variables
	CustomThemeList, CustomThemeName, ThemeList, FontFace, BackgroundImage =
		ThemeManager.Library.Options.ThemeManager_CustomThemeList,
		ThemeManager.Library.Options.ThemeManager_CustomThemeName,
		ThemeManager.Library.Options.ThemeManager_ThemeList,
		ThemeManager.Library.Options.FontFace,
		ThemeManager.Library.Options.BackgroundImage

	--// Handlers
	ThemeList:OnChanged(function()
		ThemeManager:ApplyTheme(ThemeList.Value)
	end)

	local function UpdateTheme()
		ThemeManager:ThemeUpdate()
	end

	BackgroundColor:OnChanged(UpdateTheme)
	MainColor:OnChanged(UpdateTheme)
	AccentColor:OnChanged(UpdateTheme)
	OutlineColor:OnChanged(UpdateTheme)
	FontColor:OnChanged(UpdateTheme)

	FontFace:OnChanged(function(Value)
		ThemeManager.Library:SetFont(Enum.Font[Value])
	end)

	BackgroundImage:OnChanged(function(Value)
		ThemeManager.Library:SetBackgroundImage(Value)
	end)

	if ThemeManager.Library.Toggles.BackgroundImageEnabled then
		ThemeManager.Library.Toggles.BackgroundImageEnabled:OnChanged(function(Value)
			if ThemeManager.Library.SetBackgroundImageEnabled then
				ThemeManager.Library:SetBackgroundImageEnabled(Value)
			end
			ThemeManager.Library:UpdateColorsUsingRegistry()
		end)
	end

	if ThemeManager.Library.Toggles.WindowGlow then
		ThemeManager.Library.Toggles.WindowGlow:OnChanged(function(Value)
			if ThemeManager.Library.SetGlow then
				ThemeManager.Library:SetGlow(Value)
			end
			ThemeManager.Library:UpdateColorsUsingRegistry()
		end)
	end

	--// Load default
	ThemeManager:LoadDefault()
	ThemeManager.AppliedToTab = true
	RefreshDefaultThemeLabel()

	return Themesbox
end

function ThemeManager:CreateGroupBox(Tab: any, IconName: string)
	return Tab:AddGroupbox({
        Side = "Left",
        Name = "Themes",
        IconName = IconName or "paintbrush",
    })
end

function ThemeManager:ApplyToTab(Tab: any, IconName: string)
	local Groupbox = ThemeManager:CreateGroupBox(Tab, IconName)
	return ThemeManager:CreateThemeManager(Groupbox)
end

function ThemeManager:AddThemeOptions(Tab: any, IconName: string)
	ThemeManager:ApplyToTab(Tab, IconName)
end

function ThemeManager:ApplyToGroupbox(Groupbox: any)
	return ThemeManager:CreateThemeManager(Groupbox)
end

ThemeManager:BuildFolderTree()

getgenv().ObsidianThemeManager = ThemeManager
return ThemeManager
