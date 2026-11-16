local _rl0 = {}
local Players = game.Players
do
	local JoinDeadline = tick() + 15
	while tick() < JoinDeadline do
		local Current = Players.LocalPlayer
		if Current and Current:FindFirstChild("PlayerGui") then
			break
		end
		task.wait()
	end
end
do
	local JoinedPlayer = Players.LocalPlayer
	if not JoinedPlayer or not JoinedPlayer:FindFirstChild("PlayerGui") then
		warn("Umber: join a game before running this script.")
		return
	end
end
do
	local PreviousUnload = getgenv().UmberUnload
	if typeof(PreviousUnload) == "function" then
		pcall(PreviousUnload)
	end
end
do
	local PreviousLibrary = getgenv().Library
	if PreviousLibrary
		and PreviousLibrary.Unload
		and PreviousLibrary.Options
		and PreviousLibrary.Options.WalkSpeedToggle
		and PreviousLibrary.Options.ZombieType
	then
		pcall(function()
			PreviousLibrary:Unload()
		end)
	end
end
local Sources = {}
local Pending = 3
local CacheFolder = "Umber/cache"
local CacheFiles = { Library = CacheFolder .. "/library_v1.lua", ThemeManager = CacheFolder .. "/thememanager_v1.lua",
	SaveManager = CacheFolder .. "/savemanager_v1.lua"
}
local function FsReady()
	return typeof(isfolder) == "function"
		and typeof(makefolder) == "function"
		and typeof(isfile) == "function"
		and typeof(readfile) == "function"
		and typeof(writefile) == "function"
end
local function EnsureCacheFolder()
	if FsReady() then
		pcall(function()
			if not isfolder("Umber") then
				makefolder("Umber")
			end
			if not isfolder(CacheFolder) then
				makefolder(CacheFolder)
			end
		end)
	end
end
do
	local function Fetch(Name, Url)
		if FsReady() then
			local Ok, Exists = pcall(isfile, CacheFiles[Name])
			if Ok and Exists then
				local Success, Source = pcall(readfile, CacheFiles[Name])
				if Success and type(Source) == "string" and #Source > 0 then
					Sources[Name] = Source
					Pending -= 1
					return
				end
			end
		end
		task.spawn(function()
			local Success, Result = pcall(game.HttpGet, game, Url)
			if Success then
				Sources[Name] = Result
				EnsureCacheFolder()
				pcall(writefile, CacheFiles[Name], Result)
			end
			Pending -= 1
		end)
	end
	Fetch("Library", "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua")
	Fetch("ThemeManager", "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua")
	Fetch("SaveManager", "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua")
end
do
	local FetchDeadline = tick() + 15
	while Pending > 0 and tick() < FetchDeadline do
		task.wait()
	end
end
do
	local _sc3_s1 = not Sources.Library or not Sources.ThemeManager
	if _sc3_s1 or not Sources.SaveManager then
		warn("Umber: could not download Obsidian.")
		return
	end
end
_rl0[1] = Sources.Library
if FsReady() then
	local Ok, Exists = pcall(isfile, CacheFolder .. "/molto.lua")
	if Ok and Exists then
		local Escaped = ("https://raw.githubusercontent.com/notpoiu/Molto/refs/heads/main/source.lua"):gsub("%.", "%%.")
		local Patched = _rl0[1]:gsub(Escaped, "readfile('Umber/cache/molto.lua')", 1)
		if Patched ~= _rl0[1] then
			_rl0[1] = Patched
		end
	end
end
local Library = loadstring(_rl0[1])()
task.wait()
_rl0[2] = loadstring(Sources.ThemeManager)()
task.wait()
_rl0[3] = loadstring(Sources.SaveManager)()
_rl0[4] = Library.Options
_rl0[5] = Library.Toggles
_rl0[6] = game.RunService
local _Lighting = game.Lighting
_rl0[7] = game.Stats
_rl0[8] = game:GetService("PathfindingService")
local _UserInputService = game:GetService("UserInputService")
local _LocalPlayer = Players.LocalPlayer
local Window = Library:CreateWindow({ Title = "Umber", Footer = "v0.3", NotifySide = "Right", Font = Enum.Font.Gotham })
_rl0[2]:SetLibrary(Library)
_rl0[2]:SetFolder("Umber")
_rl0[2]:SetDefaultTheme({ FontFace = "Gotham", FontColor = "ffffff", MainColor = "4d3b27", AccentColor = "a45b26",
	BackgroundColor = "6f472d", OutlineColor = "282828", BackgroundImage = ""
})
_rl0[9] = { Main = Window:AddTab("Main", "home"), Player = Window:AddTab("Player", "user"),
	Visuals = Window:AddTab("Visuals", "eye"), World = Window:AddTab("World", "sun"),
	Combat = Window:AddTab("Combat", "swords"), Class = Window:AddTab("Class Features", "hammer"),
	Settings = Window:AddTab("Settings", "settings")
}
_rl0[10] = { "Welcome to Umber, %s", "Greetings, %s", "Good to see you, %s", "Umber is ready, %s",
	"Back again, %s?"
}
_rl0[11] = string.format(_rl0[10][math.random(#_rl0[10])], _LocalPlayer.DisplayName)
_rl0[12] = string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=150&h=150", tostring(_LocalPlayer.UserId))
local LastBreathe = 0
local function Breathe()
	local Now = os.clock()
	if Now - LastBreathe < 0.02 then
		return
	end
	LastBreathe = Now
	task.wait()
end
local function Pace(Group)
	return setmetatable({}, { 
		["__index"] = function(_, Key)
			local Value = Group[Key]
			if typeof(Value) ~= "function" then
				return Value
			end
			return function(_, ...)
				local Result = Value(Group, ...)
				Breathe()
				return Result
			end
		end
	})
end
do
	local AboutGroup = Pace(_rl0[9].Main:AddGroupbox({ Name = "About", Side = "Left", IconName = "circle-user" }))
	AboutGroup:AddImage("AboutAvatar", { Image = _rl0[12], Height = 72, ScaleType = Enum.ScaleType.Fit })
	AboutGroup:AddLabel({ Text = string.format("%s (@%s)", _LocalPlayer.DisplayName, _LocalPlayer.Name), DoesWrap = true,
		Size = 16
	})
	AboutGroup:AddLabel({ Text = _rl0[11], DoesWrap = true, Size = 14 })
end
local Connections = {}
local Tracked = {}
local SurgeonTracked = {}
local Visuals = {}
local FuseMarks = {}
_rl0[13] = {}
_rl0[14] = {}
local SupplyHighlights = setmetatable({}, { __mode = "k" })
local RenderView = { Camera = nil, Position = Vector3.new(), Look = Vector3.new(), Viewport = Vector2.new(), Now = 0 }
local SpeedModifier
local ChargeSpeed = false
local ChargeValue = 55
local Unloaded = false
local LastESPUpdate = 0
local LastESPInterval = 1 / 30
local LastESPStep = 1
local ESPEMA = 0
local ESPStepAt = { 0.0015, 0.003, 0.005 }
_rl0[15] = { 30, 20, 15, 10 }
local LastVisualRefresh = 0
local EspIdle = false
_rl0[16] = false
local HttpService = game:GetService("HttpService")
local UserCountUrl = "https://umber-counter.nathanathan69420.workers.dev/ping"
local RequestFn = typeof(request) == "function" and request
	or typeof(http_request) == "function" and http_request
	or typeof(syn) == "table" and typeof(syn.request) == "function" and syn.request
	or nil
_rl0[17], _rl0[18] = pcall(function()
	return HttpService:GenerateGUID(false)
end)
_rl0[19] = _rl0[17] and typeof(_rl0[18]) == "string" and _rl0[18]
local SessionId = if _rl0[19] then _rl0[19] else tostring(math.random(100000, 999999)) .. tostring(os.clock())
local function SendUserCount(Event)
	if UserCountUrl == "" or not RequestFn or not SessionId then
		return
	end
	task.spawn(function()
		pcall(function()
			RequestFn({ Url = UserCountUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode({ id = SessionId, event = Event })
			})
		end)
	end)
end
task.spawn(function()
	SendUserCount("join")
	while not Unloaded do
		task.wait(300)
		if not Unloaded then
			SendUserCount("ping")
		end
	end
end)
local HitboxConfig = { Enabled = false, Size = 5, Part = "All", IgnoreBarrel = false, Show = false, Transparency = 0.9 }
local MeleeConfig = { AutoHeadshot = false, Chance = 100, SwingSpeed = 1, SwingSpeedEnabled = false }
local KillAuraConfig = { Enabled = false, Range = 8, Speed = 1, Show = false, Part = "All" }
local KillAuraPartGroups = { Head = { Head = true }, Torso = { Torso = true, HumanoidRootPart = true },
	Arms = { ["Right Arm"] = true, ["Left Arm"] = true },
	Legs = { ["Right Leg"] = true, ["Left Leg"] = true }, HumanoidRootPart = { HumanoidRootPart = true }
}
local LegitConfig = { AutoJump = false }
local ClassConfig = { AutoBuild = false, BuildPriority = "Closest Building", ShoveExpander = false, ShoveRadius = 5,
	ShoveShow = false, ShoveTransparency = 95
}
local ThrowableConfig = { Timer = false, MortarTimer = false, Trajectory = false }
local AimConfig = { 
	Silent = { Enabled = false,
		Types = { Shambler = true, Runner = true, Bomber = true, Sapper = true, Igniter = true, Cuirassier = true,
			Crawler = true, Headless = true, ["Big Boy"] = true
		},
		 FOV = 80, ShowFOV = false, Chams = false
	}
}
local WorldOriginal = { Ambient = _Lighting.Ambient, OutdoorAmbient = _Lighting.OutdoorAmbient,
	Brightness = _Lighting.Brightness, FogStart = _Lighting.FogStart, FogEnd = _Lighting.FogEnd
}
local AtmosphereOriginal = setmetatable({}, { __mode = "k" })
local FogRestore = { Start = WorldOriginal.FogStart, End = WorldOriginal.FogEnd }
local FogCaptured = false
local function CaptureAtmosphere(Atmosphere)
	local Entry = AtmosphereOriginal[Atmosphere]
	if not Entry then
		Entry = { Density = Atmosphere.Density, Haze = Atmosphere.Haze }
		AtmosphereOriginal[Atmosphere] = Entry
	end
	return Entry
end
local function ClearFog()
	if not FogCaptured then
		FogCaptured = true
		FogRestore.Start = _Lighting.FogStart
		FogRestore.End = _Lighting.FogEnd
	end
	if _Lighting.FogStart ~= 0 then
		_Lighting.FogStart = 0
	end
	if _Lighting.FogEnd ~= 100000 then
		_Lighting.FogEnd = 100000
	end
	local Atmosphere = _Lighting:FindFirstChildOfClass("Atmosphere")
	if Atmosphere then
		CaptureAtmosphere(Atmosphere)
		if Atmosphere.Density ~= 0 then
			Atmosphere.Density = 0
		end
		if Atmosphere.Haze ~= 0 then
			Atmosphere.Haze = 0
		end
	end
end
local function RestoreFog()
	if not FogCaptured then
		return
	end
	_Lighting.FogStart = FogRestore.Start
	_Lighting.FogEnd = FogRestore.End
	FogCaptured = false
	for Atmosphere, Entry in AtmosphereOriginal do
		if Atmosphere.Parent then
			Atmosphere.Density = Entry.Density
			Atmosphere.Haze = Entry.Haze
		end
	end
	table.clear(AtmosphereOriginal)
end
local WorldConfig = { Fullbright = false, NoFog = false }
local function ApplyWorldLighting()
	if Unloaded then
		return
	end
	if WorldConfig.Fullbright then
		_Lighting.Ambient = Color3.new(1, 1, 1)
		_Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
		_Lighting.Brightness = 3
	else
		_Lighting.Ambient = WorldOriginal.Ambient
		_Lighting.OutdoorAmbient = WorldOriginal.OutdoorAmbient
		_Lighting.Brightness = WorldOriginal.Brightness
	end
	if WorldConfig.NoFog then
		ClearFog()
	else
		RestoreFog()
	end
end
local function RestoreWorldLighting()
	_Lighting.Ambient = WorldOriginal.Ambient
	_Lighting.OutdoorAmbient = WorldOriginal.OutdoorAmbient
	_Lighting.Brightness = WorldOriginal.Brightness
	RestoreFog()
end
local LastFogGuard = 0
local function GuardWorldFog()
	local _sc11 = Unloaded
	if not Unloaded then
		_sc11 = not (WorldConfig.NoFog or WorldConfig.Fullbright)
	end
	if _sc11 then
		return
	end
	local Now = time()
	if Now - LastFogGuard < 0.25 then
		return
	end
	LastFogGuard = Now
	if WorldConfig.Fullbright then
		_Lighting.Ambient = Color3.new(1, 1, 1)
		_Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
		_Lighting.Brightness = 3
	end
	if WorldConfig.NoFog then
		ClearFog()
	end
end
local ZombieConfig = { Enabled = false, Types = { All = true }, Box = true, BoxStyle = "Box",
	BoxColor = Color3.fromRGB(164, 91, 38), Chams = false, ChamsColor = Color3.fromRGB(200, 80, 40),
	Tracers = false, TracerColor = Color3.fromRGB(164, 91, 38), Names = false,
	NameColor = Color3.fromRGB(255, 255, 255), NameStyle = "Text", Health = false,
	HealthColor = Color3.fromRGB(90, 200, 90), HealthStyle = "Text", Distance = true, BomberTimer = true,
	BomberTimerColor = Color3.fromRGB(255, 90, 60), BomberTimerPosition = "Bottom",
	BomberTimerOffsetX = 0, BomberTimerOffsetY = 0, BlastRadius = true,
	BlastRadiusColor = Color3.fromRGB(255, 90, 60)
}
_rl0[20] = { { Key = "Normal", Display = "Shambler", Color = Color3.fromRGB(120, 220, 120) },
	{ Key = "Fast", Display = "Runner", Color = Color3.fromRGB(80, 190, 255) },
	{ Key = "Barrel", Display = "Bomber", Color = Color3.fromRGB(255, 130, 60) },
	{ Key = "Sapper", Display = "Sapper", Color = Color3.fromRGB(255, 220, 90) },
	{ Key = "Igniter", Display = "Igniter", Color = Color3.fromRGB(200, 110, 255) },
	{ Key = "Cuirassier", Display = "Cuirassier", Color = Color3.fromRGB(100, 230, 200) },
	{ Key = "Crawler", Display = "Crawler", Color = Color3.fromRGB(255, 120, 200) },
	{ Key = "Headless", Display = "Headless", Color = Color3.fromRGB(235, 235, 235) },
	{ Key = "BigBoy", Display = "Big Boy", Color = Color3.fromRGB(255, 70, 70) }
}
local ZombieColors = {}
local ZombieNames = {}
_rl0[21] = { "All" }
for _, Kind in ipairs(_rl0[20]) do
	ZombieColors[Kind.Key] = Kind.Color
	ZombieNames[Kind.Key] = Kind.Display
	table.insert(_rl0[21], Kind.Display)
end
local PlayerConfig = { Enabled = false, Box = true, BoxColor = Color3.fromRGB(120, 200, 130), Chams = false,
	ChamsColor = Color3.fromRGB(120, 200, 130), Tracers = false,
	TracerColor = Color3.fromRGB(120, 200, 130), Names = false,
	NameColor = Color3.fromRGB(255, 255, 255), NameStyle = "Text", Health = false,
	HealthColor = Color3.fromRGB(90, 200, 90), HealthStyle = "Text", Distance = true, Infection = true,
	InfectionColor = Color3.fromRGB(190, 70, 70), Grabbed = true,
	GrabbedColor = Color3.fromRGB(255, 70, 70), Pinned = true,
	PinnedColor = Color3.fromRGB(255, 170, 60), Burning = false,
	BurningColor = Color3.fromRGB(255, 130, 40), BrokenLegs = false,
	BrokenLegsColor = Color3.fromRGB(180, 180, 255), BoxStyle = "Box"
}
local SurgeonConfig = { Enabled = false, Threshold = 30, Color = Color3.fromRGB(255, 90, 90), Box = true,
	BoxColor = Color3.fromRGB(255, 90, 90), BoxStyle = "Box", Chams = false,
	ChamsColor = Color3.fromRGB(255, 90, 90), SuppliesESP = false,
	SuppliesColor = Color3.fromRGB(255, 210, 90), AutoHeal = false, Mode = "Legit", MaxDistance = 40,
	Avoid = true
}
_rl0[22] = { Head = { Head = true }, Torso = { Torso = true },
	Legs = { ["Left Leg"] = true, ["Right Leg"] = true }, HumanoidRootPart = { HumanoidRootPart = true }
}
_rl0[23] = { RunnerTackle = "Tackled", RunnerAttack = "Pinned", RunnerClaw = "Clawed",
	RunnerVomit = "Vomited On", SapperBlocked = "Sapper Block", CuirassierImpale = "Impaled"
}
local function EnsureEnabled(Name)
	if _rl0[16] then
		return
	end
	local Toggle = _rl0[5][Name]
	if Toggle and not Toggle.Value then
		Toggle:SetValue(true)
	end
end
local function Track(Connection)
	table.insert(Connections, Connection)
	return Connection
end
local ChargeRetries = 0
local function ClearChargeSpeed()
	if SpeedModifier and SpeedModifier.Parent then
		SpeedModifier:Destroy()
	end
	SpeedModifier = nil
	ChargeRetries = 0
end
local function ApplyChargeSpeed()
	if Unloaded then
		return
	end
	if not ChargeSpeed then
		ClearChargeSpeed()
		return
	end
	if SpeedModifier and SpeedModifier.Parent then
		SpeedModifier.Value = ChargeValue
		ChargeRetries = 0
		return
	end
	SpeedModifier = nil
	local Character = _LocalPlayer.Character
	if not Character then
		return
	end
	local UserStates = Character:FindFirstChild("UserStates")
	local _sc12 = UserStates and UserStates:FindFirstChild("SpeedController")
	local Module = _sc12
	local Success, Result = false, nil
	if _sc12 then
		Success, Result = pcall(require, Module)
	end
	if Success then
		local Added, Modifier = pcall(function()
			return Result.AddModifier("Charge", ChargeValue, 100)
		end)
		if Added and typeof(Modifier) == "Instance" then
			SpeedModifier = Modifier
			ChargeRetries = 0
			Track(Modifier.Destroying:Connect(function()
				SpeedModifier = nil
				task.defer(ApplyChargeSpeed)
			end))
			return
		end
	end
	if ChargeRetries < 20 then
		ChargeRetries += 1
		task.delay(0.25, ApplyChargeSpeed)
	end
end
local AntiGrabEnabled = false
local function SpoofGrabPosition()
	if Unloaded or not AntiGrabEnabled then
		return
	end
	local Character = _LocalPlayer.Character
	local _sc11 = Character and Character:FindFirstChildOfClass("Humanoid")
	local Humanoid = _sc11
	if not _sc11 then
		return
	end
	Humanoid:Move(Vector3.new(0, 100000, 0))
end
local SwingBuffs = setmetatable({}, { __mode = "k" })
local function ClearSwingBuffs()
	for Tool, Buff in SwingBuffs do
		if Buff.Parent == Tool then
			Buff:Destroy()
		end
	end
	table.clear(SwingBuffs)
end
local function IsMeleeTool(Tool)
	local Animations = Tool:FindFirstChild("Animations")
	if not Animations then
		return false
	end
	local _sc11_s1 = Animations:FindFirstChild("SwingRight") ~= nil or Animations:FindFirstChild("SwingDown") ~= nil
	return _sc11_s1 or Animations:FindFirstChild("Thrust") ~= nil
end
local MeleeToolCache = setmetatable({}, { __mode = "k" })
local function ApplySwingSpeed()
	if Unloaded then
		return
	end
	if not MeleeConfig.SwingSpeedEnabled or MeleeConfig.SwingSpeed <= 1 then
		return
	end
	local Character = _LocalPlayer.Character
	if not Character then
		return
	end
	local Tool = Character:FindFirstChildOfClass("Tool")
	if not Tool then
		return
	end
	local IsMelee = MeleeToolCache[Tool]
	if IsMelee == nil then
		IsMelee = IsMeleeTool(Tool)
		MeleeToolCache[Tool] = IsMelee
	end
	if not IsMelee then
		return
	end
	local Buff = SwingBuffs[Tool]
	if not Buff or Buff.Parent ~= Tool then
		Buff = Tool:FindFirstChild("SwingSpeedBuff")
		if not Buff then
			Buff = Instance.new("NumberValue")
			Buff.Name = "SwingSpeedBuff"
			Buff.Parent = Tool
		end
		SwingBuffs[Tool] = Buff
	end
	local Target = (MeleeConfig.SwingSpeed - 1) / 0.35
	if Buff.Value ~= Target then
		Buff.Value = Target
	end
end
do
	local ExistingCharacter = _LocalPlayer.Character
	if ExistingCharacter then
		ExistingCharacter:SetAttribute("SwingSpeedScalar", nil)
	end
end
local NearPlane = 0.1
local ProjectCorners = table.create(8)
local ProjectDepth = table.create(8)
local ProjectEdges = { { 1, 2 }, { 3, 4 }, { 1, 3 }, { 2, 4 }, { 5, 6 }, { 7, 8 }, { 5, 7 }, { 6, 8 }, { 1, 5 }, { 2, 6 },
	{ 3, 7 }, { 4, 8 }
}
local function ProjectModel(Model, Camera)
	local Success, BoxCFrame, BoxSize = pcall(Model.GetBoundingBox, Model)
	if not Success then
		return nil
	end
	local MinX = math.huge
	local MinY = math.huge
	local MaxX = -math.huge
	local MaxY = -math.huge
	local Visible = false
	local AllFront = true
	for Index = 0, 7 do
		local _t1642 = Index % 2
		local _sc12 = math.floor(Index / 2) % 2 == 0 and 0.5 or -0.5
		local _sc13 = Index < 4 and 0.5 or -0.5
		local World = BoxCFrame
			* Vector3.new(BoxSize.X * (_t1642 == 0 and 0.5 or -0.5), BoxSize.Y * _sc12, BoxSize.Z * _sc13)
		local Point = Camera:WorldToViewportPoint(World)
		ProjectCorners[Index + 1] = World
		ProjectDepth[Index + 1] = Point.Z
		if Point.Z <= NearPlane then
			AllFront = false
		end
		if Point.Z > NearPlane then
			Visible = true
			MinX = math.min(MinX, Point.X)
			MaxX = math.max(MaxX, Point.X)
			MinY = math.min(MinY, Point.Y)
			MaxY = math.max(MaxY, Point.Y)
		end
	end
	if not AllFront then
		for Index = 1, 12 do
			local Edge = ProjectEdges[Index]
			local A = ProjectCorners[Edge[1]]
			local B = ProjectCorners[Edge[2]]
			local DepthA = ProjectDepth[Edge[1]]
			local DepthB = ProjectDepth[Edge[2]]
			if DepthA > NearPlane ~= (DepthB > NearPlane) then
				local Point = Camera:WorldToViewportPoint(A + (B - A) * ((NearPlane - DepthA) / (DepthB - DepthA)))
				if Point.Z > 0 then
					Visible = true
					MinX = math.min(MinX, Point.X)
					MaxX = math.max(MaxX, Point.X)
					MinY = math.min(MinY, Point.Y)
					MaxY = math.max(MaxY, Point.Y)
				end
			end
		end
	end
	if not Visible then
		return nil
	end
	return MinX, MinY, MaxX, MaxY
end
local function CreateText(TextSize)
	local Text = Drawing.new("Text")
	Text.Size = TextSize
	Text.Center = true
	Text.Outline = true
	Text.OutlineColor = Color3.new(0, 0, 0)
	Text.Visible = false
	return Text
end
local WriteCache = setmetatable({}, { __mode = "k" })
local function Set(Target, Prop, Value)
	local Memo = WriteCache[Target]
	if not Memo then
		Memo = {}
		WriteCache[Target] = Memo
	end
	if Memo[Prop] ~= Value then
		Memo[Prop] = Value
		Target[Prop] = Value
	end
end
local function MakeEntry(Kind)
	local Fill = Drawing.new("Square")
	Fill.Filled = true
	Fill.Thickness = 1
	Fill.Transparency = 0.9
	Fill.Visible = false
	local Box = Drawing.new("Square")
	Box.Filled = false
	Box.Thickness = 1
	Box.Visible = false
	local Tracer = Drawing.new("Line")
	Tracer.Thickness = 1
	Tracer.Visible = false
	local Entry = { Kind = Kind, Fill = Fill, Box = Box, Corners = nil, NameText = CreateText(14),
		HealthText = CreateText(13), TimerText = CreateText(14), Tracer = Tracer, StatusTexts = {},
		Highlight = nil, Suppressed = {}, Gui = nil, Humanoid = nil, Root = nil, SuppressTarget = nil,
		SuppressAt = 0, SlowAt = 0, StatusAt = 0, FuseAt = 0
	}
	if Kind ~= "zombie" then
		for Index = 1, 5 do
			Entry.StatusTexts[Index] = CreateText(13)
		end
	end
	return Entry
end
local function EnsureCorners(Entry)
	local Corners = Entry.Corners
	if Corners then
		return Corners
	end
	local Corners_s1 = {}
	for Index = 1, 8 do
		local Line = Drawing.new("Line")
		Line.Thickness = 2
		Line.Visible = false
		Corners_s1[Index] = Line
	end
	Entry.Corners = Corners_s1
	return Corners_s1
end
local function RestoreHighlights(Entry)
	for Highlight in Entry.Suppressed do
		if not Highlight.Parent then
			Entry.Suppressed[Highlight] = nil
		end
	end
	for Highlight, Enabled in Entry.Suppressed do
		if Highlight.Parent then
			Highlight.Enabled = Enabled
		end
	end
	table.clear(Entry.Suppressed)
	Entry.SuppressTarget = nil
end
local function SuppressHighlights(Entry, Model, Ours)
	for Highlight in Entry.Suppressed do
		if not Highlight.Parent then
			Entry.Suppressed[Highlight] = nil
		end
	end
	for _, Child in Model:GetChildren() do
		if Child:IsA("Highlight") and Child ~= Ours and Child.Name ~= "UmberTargetChams" then
			if Entry.Suppressed[Child] == nil then
				Entry.Suppressed[Child] = Child.Enabled
			end
			Child.Enabled = false
		end
	end
end
local function DestroyEntry(Entry)
	RestoreHighlights(Entry)
	for _, Object in { Entry.Fill, Entry.Box, Entry.NameText, Entry.HealthText, Entry.TimerText, Entry.Tracer } do
		pcall(function()
			Object:Remove()
		end)
	end
	for _, Line in Entry.Corners or {} do
		pcall(function()
			Line:Remove()
		end)
	end
	for _, Text in Entry.StatusTexts do
		pcall(function()
			Text:Remove()
		end)
	end
	if Entry.Highlight then
		pcall(function()
			Entry.Highlight:Destroy()
		end)
	end
	if Entry.Gui and Entry.Gui.Holder then
		pcall(function()
			Entry.Gui.Holder:Destroy()
		end)
	end
end
local EntryBudget = 0
local function GetEntry(Model, Kind, Store)
	local TrackedStore = Store or Tracked
	local Entry = TrackedStore[Model]
	if Entry and Entry.Kind ~= Kind then
		DestroyEntry(Entry)
		Entry = nil
	end
	if not Entry then
		if EntryBudget <= 0 then
			return nil
		end
		EntryBudget -= 1
		Entry = MakeEntry(Kind)
		TrackedStore[Model] = Entry
	end
	return Entry
end
local function EnsureGui(Entry, Model)
	if Entry.Gui and Entry.Gui.Holder and Entry.Gui.Holder.Parent then
		return Entry.Gui
	end
	local _sc12_s1 = Model:FindFirstChild("Head") or Model:FindFirstChild("HumanoidRootPart")
	local Head = _sc12_s1
	if not _sc12_s1 then
		return nil
	end
	local Holder = Instance.new("BillboardGui")
	Holder.Name = "UmberESP"
	Holder.AlwaysOnTop = true
	Holder.LightInfluence = 0
	Holder.ResetOnSpawn = false
	Holder.Size = UDim2.fromOffset(150, 34)
	Holder.StudsOffset = Vector3.new(0, 2.4, 0)
	Holder.Parent = Head
	local NameLabel = Instance.new("TextLabel")
	NameLabel.Name = "Name"
	NameLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	NameLabel.BackgroundTransparency = 0.35
	NameLabel.BorderSizePixel = 0
	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.TextSize = 13
	NameLabel.TextColor3 = Color3.new(1, 1, 1)
	NameLabel.Size = UDim2.new(1, 0, 0, 16)
	NameLabel.Visible = false
	NameLabel.Parent = Holder
	local HealthBack = Instance.new("Frame")
	HealthBack.Name = "HealthBack"
	HealthBack.BackgroundColor3 = Color3.new(0, 0, 0)
	HealthBack.BackgroundTransparency = 0.35
	HealthBack.BorderSizePixel = 0
	HealthBack.Size = UDim2.new(1, 0, 0, 6)
	HealthBack.Visible = false
	HealthBack.Parent = Holder
	local HealthFill = Instance.new("Frame")
	HealthFill.Name = "HealthFill"
	HealthFill.BackgroundColor3 = Color3.fromRGB(90, 200, 90)
	HealthFill.BorderSizePixel = 0
	HealthFill.Size = UDim2.fromScale(1, 1)
	HealthFill.Parent = HealthBack
	Entry.Gui = { Holder = Holder, NameLabel = NameLabel, HealthBack = HealthBack, HealthFill = HealthFill }
	return Entry.Gui
end
local function RefreshVisuals(Now)
	if Now - LastVisualRefresh < 0.1 then
		return
	end
	LastVisualRefresh = Now
	table.clear(Visuals)
	local Camera = workspace.CurrentCamera
	if not Camera then
		return
	end
	for _, Child in Camera:GetChildren() do
		local Orig = Child:FindFirstChild("Orig")
		if Orig and Orig:IsA("ObjectValue") and Orig.Value then
			Visuals[Orig.Value] = Child
		end
	end
end
local function GetVisual(Model)
	local Visual = Visuals[Model]
	if Visual and Visual.Parent then
		return Visual
	end
	local Ref = Model:FindFirstChild("ClientRef")
	if Ref and Ref:IsA("ObjectValue") and Ref.Value then
		return Ref.Value
	end
	return Model
end
local function EnsureHighlight(Entry, Target)
	if Entry.Highlight and Entry.Highlight.Parent == Target then
		return Entry.Highlight
	end
	if Entry.Highlight then
		pcall(function()
			Entry.Highlight:Destroy()
		end)
	end
	local Highlight = Instance.new("Highlight")
	Highlight.Name = "UmberChams"
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.FillTransparency = 0.55
	Highlight.OutlineTransparency = 0.1
	Highlight.Parent = Target
	Entry.Highlight = Highlight
	return Highlight
end
local function GetPlayerLabel(Model)
	local Player = Players:FindFirstChild(Model.Name)
	if Player then
		return Player.DisplayName
	end
	return Model.Name
end
local function GetStatuses(Model)
	local Statuses = {}
	local UserStates = Model:FindFirstChild("UserStates")
	if not UserStates then
		return Statuses
	end
	if PlayerConfig.Infection then
		local Infected = UserStates:FindFirstChild("Infected")
		if Infected and typeof(Infected.Value) == "number" and Infected.Value > 0 then
			table.insert(Statuses, { Text = string.format("Infection %d%%", math.floor(Infected.Value + 0.5)),
				Color = PlayerConfig.InfectionColor
			})
		end
	end
	if PlayerConfig.Grabbed then
		local Grabbed = UserStates:FindFirstChild("Grabbed")
		if Grabbed and typeof(Grabbed.Value) == "number" and Grabbed.Value > 0 then
			table.insert(Statuses, { Text = "Grabbed", Color = PlayerConfig.GrabbedColor })
		end
	end
	if PlayerConfig.Pinned then
		local Pin = UserStates:FindFirstChild("Pin")
		if Pin and typeof(Pin.Value) == "string" and Pin.Value ~= "None" and Pin.Value ~= "" then
			local insert = table.insert
			local _sc12 = _rl0[23][Pin.Value]
			insert(Statuses, { Text = _sc12 or Pin.Value, Color = PlayerConfig.PinnedColor })
		end
	end
	if PlayerConfig.Burning then
		local Burning = Model:GetAttribute("Burning")
		if Burning and Burning ~= 0 then
			table.insert(Statuses, { Text = "Burning", Color = PlayerConfig.BurningColor })
		end
	end
	if PlayerConfig.BrokenLegs then
		local BrokenLegs = UserStates:FindFirstChild("BrokenLegs")
		if BrokenLegs and BrokenLegs.Value then
			table.insert(Statuses, { Text = "Broken Legs", Color = PlayerConfig.BrokenLegsColor })
		end
	end
	return Statuses
end
local function GetFuseRemaining(Model)
	local State = Model:FindFirstChild("State")
	if not (State and State:GetChildren()[1]) then
		FuseMarks[Model] = nil
		return nil
	end
	local Started = FuseMarks[Model]
	if not Started then
		Started = os.clock()
		FuseMarks[Model] = Started
	end
	return math.max(0, 3.5 - (os.clock() - Started))
end
local function HideEntry(Entry)
	Set(Entry.Fill, "Visible", false)
	Set(Entry.Box, "Visible", false)
	for Index = 1, 8 do
		local _sc11 = Entry.Corners and Entry.Corners[Index]
		local Line = _sc11
		if _sc11 then
			Set(Line, "Visible", false)
		end
	end
	Set(Entry.NameText, "Visible", false)
	Set(Entry.HealthText, "Visible", false)
	Set(Entry.TimerText, "Visible", false)
	Set(Entry.Tracer, "Visible", false)
	for _, Text in Entry.StatusTexts do
		Set(Text, "Visible", false)
	end
	if Entry.Highlight then
		Set(Entry.Highlight, "Enabled", false)
	end
	RestoreHighlights(Entry)
	if Entry.Gui and Entry.Gui.Holder then
		Set(Entry.Gui.Holder, "Enabled", false)
	end
end
local function RenderModel(Model, Kind, Seen, View, Store)
	local Config
	if Kind == "zombie" then
		Config = ZombieConfig
	elseif Kind == "lowhealth" then
		Config = SurgeonConfig
	else
		Config = PlayerConfig
	end
	local TrackedStore = Store or Tracked
	if not Config.Enabled then
		return
	end
	local Cached = TrackedStore[Model]
	local _sc11 = Cached and Cached.Humanoid
	local HumanoidInstance = _sc11
	if not _sc11 or not HumanoidInstance.Parent then
		HumanoidInstance = Model:FindFirstChildOfClass("Humanoid")
	end
	if not HumanoidInstance or HumanoidInstance.Health <= 0 then
		return
	end
	local _sc14 = Cached and Cached.Root
	local Root = _sc14
	if not _sc14 or not Root.Parent then
		Root = Model:FindFirstChild("HumanoidRootPart")
	end
	local _sc16 = Root and Root.Position
	local RootPos = _sc16
	local Distance = 0
	if _sc16 then
		local ToRoot = RootPos - View.Position
		if ToRoot:Dot(View.Look) < -2 then
			return
		end
		Distance = ToRoot.Magnitude
		if Kind == "zombie" and Distance > 350 then
			return
		end
	end
	local Far = Kind == "zombie" and Distance > 150
	local Label, Type
	if Kind == "zombie" then
		local _sc18 = Cached and Cached.Kind == Kind and Cached.ZLabel and View.Now - Cached.SlowAt < 1
		if _sc18 then
			Type = Cached.ZType
			Label = Cached.ZLabel
		else
			Type = Model:GetAttribute("Type")
			local _sc19 = Type == nil and Model.Name
			local _sc18 = _sc19
			if not _sc19 then
				_sc18 = ZombieNames[Type] or tostring(Type)
			end
			Label = _sc18
		end
		local Types = ZombieConfig.Types
		if not Types.All and not Types[Label] then
			return
		end
	else
		Label = if Cached and Cached.Kind == Kind and Cached.ZLabel and View.Now - Cached.SlowAt < 1 then Cached.ZLabel else GetPlayerLabel(Model)
	end
	local MinX, MinY, MaxX, MaxY = ProjectModel(Model, View.Camera)
	if not MinX then
		return
	end
	local Entry = GetEntry(Model, Kind, TrackedStore)
	if not Entry then
		return
	end
	Entry.Humanoid = HumanoidInstance
	Entry.Root = Root
	Seen[Model] = true
	if View.Now - Entry.SlowAt >= 1 then
		Entry.SlowAt = View.Now
		Entry.ZLabel = Label
		Entry.ZType = Kind == "zombie" and Type or nil
		if Config.Health then
			Entry.MaxHealth = HumanoidInstance.MaxHealth
		end
	end
	local CenterX = (MinX + MaxX) * 0.5
	if RootPos then
		local _sc19 = Far and math.floor(Distance / 5) * 5
		local _sc18 = _sc19
		Distance = if _sc19 then _sc18 else math.floor(Distance)
	end
	if Config.Distance then
		Label = string.format("%s [%dm]", Label, Distance)
	end
	local Style = Config.BoxStyle or "Box"
	local ShowBox = Config.Box and Style ~= "Corner"
	local ShowFill = ShowBox and Style == "Filled Box"
	local ShowCorners = Config.Box and Style == "Corner" and not Far
	local Corners = Entry.Corners
	Set(Entry.Box, "Visible", ShowBox)
	Set(Entry.Fill, "Visible", ShowFill)
	if ShowCorners then
		local _sc18 = Corners
		Corners = if Corners then _sc18 else EnsureCorners(Entry)
	end
	if Corners then
		for Index = 1, 8 do
			Set(Corners[Index], "Visible", ShowCorners)
		end
	end
	if Config.Box then
		local BoxColor = Config.BoxColor
		if Kind == "zombie" then
			BoxColor = ZombieColors[Type] or Config.BoxColor
		end
		if ShowBox then
			local Position = Vector2.new(MinX, MinY)
			local Size = Vector2.new(MaxX - MinX, MaxY - MinY)
			Set(Entry.Box, "Color", BoxColor)
			Set(Entry.Box, "Position", Position)
			Set(Entry.Box, "Size", Size)
			if ShowFill then
				Set(Entry.Fill, "Color", BoxColor)
				Set(Entry.Fill, "Position", Position)
				Set(Entry.Fill, "Size", Size)
			end
		end
		if ShowCorners then
			local Length = math.clamp(math.min(MaxX - MinX, MaxY - MinY) * 0.25, 4, 18)
			local Left = MinX
			local Right = MaxX
			local Top = MinY
			local Bottom = MaxY
			for Index = 1, 4 do
				local X = (Index == 1 or Index == 3) and Left or Right
				local Y = Index <= 2 and Top or Bottom
				local _sc19 = Index <= 2 and 1 or -1
				local Horizontal = Corners[Index * 2 - 1]
				local Vertical = Corners[Index * 2]
				Set(Horizontal, "Color", BoxColor)
				Set(Horizontal, "From", Vector2.new(X, Y))
				Set(Horizontal, "To", Vector2.new(X + ((Index == 1 or Index == 3) and 1 or -1) * Length, Y))
				Set(Vertical, "Color", BoxColor)
				Set(Vertical, "From", Vector2.new(X, Y))
				Set(Vertical, "To", Vector2.new(X, Y + _sc19 * Length))
			end
		end
	end
	if Config.Tracers then
		Set(Entry.Tracer, "Visible", true)
		Set(Entry.Tracer, "Color", Config.TracerColor)
		Set(Entry.Tracer, "From", Vector2.new(View.Viewport.X * 0.5, View.Viewport.Y))
		Set(Entry.Tracer, "To", Vector2.new(CenterX, MaxY))
	else
		Set(Entry.Tracer, "Visible", false)
	end
	do
		local ShowTextName = Config.Names and (Config.NameStyle == "Text" or Config.NameStyle == "Both")
		local ShowGuiName = Config.Names and (Config.NameStyle == "GUI" or Config.NameStyle == "Both")
		local Health = Config.Health
		if Health then
			Health = Config.HealthStyle == "Text" or Config.HealthStyle == "Both"
		end
		local ShowTextHealth = Health
		local Health_v2 = Config.Health
		if Health_v2 then
			Health_v2 = Config.HealthStyle == "GUI" or Config.HealthStyle == "Both"
		end
		local ShowGuiHealth = Health_v2
		Set(Entry.NameText, "Visible", ShowTextName)
		if ShowTextName then
			Set(Entry.NameText, "Text", Label)
			Set(Entry.NameText, "Color", Config.NameColor)
			Set(Entry.NameText, "Position", Vector2.new(CenterX, MinY - 18))
		end
		Set(Entry.HealthText, "Visible", ShowTextHealth)
		if ShowTextHealth then
			Set(Entry.HealthText, "Color", Config.HealthColor)
			Set(Entry.HealthText, "Position", Vector2.new(CenterX, MinY - (ShowTextName and 34 or 18)))
			if Entry.HPText ~= HumanoidInstance.Health then
				Entry.HPText = HumanoidInstance.Health
				Set(Entry.HealthText, "Text", string.format("%d HP", math.ceil(HumanoidInstance.Health)))
			end
		end
		if ShowGuiName or ShowGuiHealth then
			EnsureGui(Entry, Model)
		end
		if Entry.Gui and Entry.Gui.Holder and Entry.Gui.Holder.Parent then
			local NameLabel = Entry.Gui.NameLabel
			local HealthBack = Entry.Gui.HealthBack
			local HealthFill = Entry.Gui.HealthFill
			Set(NameLabel, "Visible", ShowGuiName)
			Set(HealthBack, "Visible", ShowGuiHealth)
			if ShowGuiName then
				Set(NameLabel, "Text", Label)
				Set(NameLabel, "TextColor3", Config.NameColor)
			end
			if ShowGuiHealth then
				Set(HealthFill, "BackgroundColor3", Config.HealthColor)
				Set(HealthBack, "Position", UDim2.fromOffset(0, ShowGuiName and 18 or 0))
				local MaxHealth = Entry.MaxHealth
				if not MaxHealth then
					MaxHealth = HumanoidInstance.MaxHealth
					Entry.MaxHealth = MaxHealth
				end
				if Entry.HPBar ~= HumanoidInstance.Health then
					Entry.HPBar = HumanoidInstance.Health
					Set(HealthFill, "Size", UDim2.fromScale(math.clamp(HumanoidInstance.Health / MaxHealth, 0, 1), 1))
				end
			end
			Set(Entry.Gui.Holder, "Size", UDim2.fromOffset(150, (ShowGuiName and 18 or 0) + (ShowGuiHealth and 8 or 0)))
			Set(Entry.Gui.Holder, "Enabled", ShowGuiName or ShowGuiHealth)
		elseif Entry.Gui and Entry.Gui.Holder then
			Set(Entry.Gui.Holder, "Enabled", false)
		end
	end
	if Config.Chams then
		local Target = GetVisual(Model)
		local Highlight = EnsureHighlight(Entry, Target)
		local HighlightColor = Config.ChamsColor
		if Kind == "zombie" then
			HighlightColor = ZombieColors[Type] or Config.ChamsColor
		end
		Set(Highlight, "FillColor", HighlightColor)
		Set(Highlight, "OutlineColor", HighlightColor)
		Set(Highlight, "Enabled", true)
		local _sc28 = Entry.SuppressTarget ~= Target
		_sc28 = _sc28 or View.Now - (Entry.SuppressAt or 0) >= 0.25
		if _sc28 then
			Entry.SuppressTarget = Target
			Entry.SuppressAt = View.Now
			SuppressHighlights(Entry, Target, Highlight)
		end
	else
		if Entry.Highlight then
			Set(Entry.Highlight, "Enabled", false)
		end
		RestoreHighlights(Entry)
	end
	if Kind == "zombie" then
		local Remaining
		if Config.BomberTimer and Type == "Barrel" then
			if View.Now - Entry.FuseAt >= 0.25 then
				Entry.FuseAt = View.Now
				local Fresh = GetFuseRemaining(Model)
				if Fresh then
					Entry.FuseLeft = Fresh
					Entry.FuseStamp = os.clock()
				else
					Entry.FuseLeft = nil
				end
			end
			if Entry.FuseLeft then
				Remaining = math.max(0, Entry.FuseLeft - (os.clock() - Entry.FuseStamp))
			end
		end
		Set(Entry.TimerText, "Visible", Remaining ~= nil)
		if Remaining then
			local TimerX, TimerY
			if Config.BomberTimerPosition == "Top" then
				TimerX, TimerY = CenterX, MinY - 18
			elseif Config.BomberTimerPosition == "Center" then
				TimerX, TimerY = CenterX, (MinY + MaxY) * 0.5
			elseif Config.BomberTimerPosition == "Left" then
				TimerX, TimerY = MinX - 6, (MinY + MaxY) * 0.5
			elseif Config.BomberTimerPosition == "Right" then
				TimerX, TimerY = MaxX + 6, (MinY + MaxY) * 0.5
			else
				TimerX, TimerY = CenterX, MaxY + 4
			end
			Set(Entry.TimerText, "Text", string.format("%.1fs", Remaining))
			Set(Entry.TimerText, "Color", Config.BomberTimerColor)
			Set(Entry.TimerText, "Position", Vector2.new(TimerX + Config.BomberTimerOffsetX, TimerY + Config.BomberTimerOffsetY))
		end
	end
	if Kind == "player" then
		local Statuses = Entry.StatusCache
		if not Statuses or View.Now - Entry.StatusAt >= 0.25 then
			Entry.StatusAt = View.Now
			Statuses = GetStatuses(Model)
			Entry.StatusCache = Statuses
		end
		for Index = 1, #Entry.StatusTexts do
			local StatusText = Entry.StatusTexts[Index]
			local Status = Statuses[Index]
			if Status then
				Set(StatusText, "Visible", true)
				Set(StatusText, "Text", Status.Text)
				Set(StatusText, "Color", Status.Color)
				Set(StatusText, "Position", Vector2.new(CenterX, MaxY + 4 + (Index - 1) * 14))
			else
				Set(StatusText, "Visible", false)
			end
		end
	end
end
local function UpdateESP()
	if Unloaded then
		return
	end
	local _sc11_s1 = ZombieConfig.Enabled or PlayerConfig.Enabled
	if not (_sc11_s1 or SurgeonConfig.Enabled) then
		for Model, Entry in Tracked do
			if not Model.Parent then
				DestroyEntry(Entry)
				Tracked[Model] = nil
				FuseMarks[Model] = nil
			elseif not EspIdle then
				HideEntry(Entry)
			end
		end
		for Model, Entry in SurgeonTracked do
			if not Model.Parent then
				DestroyEntry(Entry)
				SurgeonTracked[Model] = nil
			elseif not EspIdle then
				HideEntry(Entry)
			end
		end
		EspIdle = true
		return
	end
	EspIdle = false
	local Now = time()
	if Now - LastESPUpdate < LastESPInterval then
		return
	end
	LastESPUpdate = Now
	EntryBudget = 12
	local StartClock = os.clock()
	if ZombieConfig.Enabled then
		RefreshVisuals(Now)
	end
	local Camera = workspace.CurrentCamera
	if not Camera then
		return
	end
	local CamCF = Camera.CFrame
	local View = RenderView
	RenderView.Camera = Camera
	View.Position = CamCF.Position
	View.Look = CamCF.LookVector
	View.Viewport = Camera.ViewportSize
	View.Now = Now
	local Seen = _rl0[13]
	table.clear(Seen)
	if ZombieConfig.Enabled then
		local Container = workspace:FindFirstChild("Zombies")
		if Container then
			for _, Model in Container:GetChildren() do
				if Model:IsA("Model") then
					RenderModel(Model, "zombie", Seen, View)
				end
			end
		end
	end
	if PlayerConfig.Enabled then
		local Container = workspace:FindFirstChild("Players")
		if Container then
			for _, Model in Container:GetChildren() do
				if Model:IsA("Model") and Model ~= _LocalPlayer.Character then
					RenderModel(Model, "player", Seen, View)
				end
			end
		end
	end
	local SurgeonSeenThis = _rl0[14]
	table.clear(SurgeonSeenThis)
	if SurgeonConfig.Enabled then
		local Container = workspace:FindFirstChild("Players")
		if Container then
			local Threshold = SurgeonConfig.Threshold
			for _, Model in Container:GetChildren() do
				if Model:IsA("Model") and Model ~= _LocalPlayer.Character then
					local Humanoid = Model:FindFirstChildOfClass("Humanoid")
					if Humanoid
						and Humanoid.Health > 0
						and Humanoid.Health / math.max(Humanoid.MaxHealth, 1) * 100 <= Threshold
					then
						RenderModel(Model, "lowhealth", SurgeonSeenThis, View, SurgeonTracked)
					end
				end
			end
		end
	end
	for Model, Entry in Tracked do
		if Seen[Model] then
			continue
		end
		if Model.Parent then
			HideEntry(Entry)
		else
			DestroyEntry(Entry)
			Tracked[Model] = nil
			FuseMarks[Model] = nil
		end
	end
	for Model, Entry in SurgeonTracked do
		if SurgeonSeenThis[Model] then
			continue
		end
		if Model.Parent then
			HideEntry(Entry)
		else
			DestroyEntry(Entry)
			SurgeonTracked[Model] = nil
		end
	end
	local UpdateCost = os.clock() - StartClock
	ESPEMA = ESPEMA + (UpdateCost - ESPEMA) * 0.25
	local Step = 1
	while Step < 4 and ESPEMA >= ESPStepAt[Step] do
		Step += 1
	end
	if Step > LastESPStep then
		LastESPStep = Step
	elseif Step < LastESPStep and ESPEMA < ESPStepAt[LastESPStep - 1] * 0.75 then
		LastESPStep = Step
	end
	LastESPInterval = 1 / _rl0[15][LastESPStep]
end
local function IsBarrel(Agent)
	if not Agent then
		return false
	end
	return Agent:GetAttribute("Type") == "Barrel"
end
local BlastSpheres = setmetatable({}, { __mode = "k" })
local LastBlastRing = 0
local BlastSeen = {}
local function DestroyBlastSphere(Model)
	local Part = BlastSpheres[Model]
	if Part then
		pcall(function()
			Part:Destroy()
		end)
		BlastSpheres[Model] = nil
	end
end
local function UpdateBlastRings()
	if Unloaded then
		return
	end
	if not ZombieConfig.BlastRadius then
		if next(BlastSpheres) then
			for Model in BlastSpheres do
				DestroyBlastSphere(Model)
			end
		end
		return
	end
	local Now = time()
	if Now - LastBlastRing < 0.05 then
		return
	end
	LastBlastRing = Now
	local Camera = workspace.CurrentCamera
	local Container = workspace:FindFirstChild("Zombies")
	if not Camera or not Container then
		return
	end
	table.clear(BlastSeen)
	local NewBudget = 2
	for _, Model in Container:GetChildren() do
		if not (Model:IsA("Model") and IsBarrel(Model) and GetFuseRemaining(Model)) then
			continue
		end
		BlastSeen[Model] = true
		if not BlastSpheres[Model] then
			if NewBudget <= 0 then
				continue
			end
			NewBudget -= 1
		end
		local Radius = Model:GetAttribute("BlastRadius")
		if typeof(Radius) ~= "number" then
			Radius = 10
		end
		local BoxCFrame, BoxSize = Model:GetBoundingBox()
		local Center = Vector3.new(BoxCFrame.Position.X, BoxCFrame.Position.Y - BoxSize.Y * 0.5 + Radius * 0.45, BoxCFrame.Position.Z)
		local Part = BlastSpheres[Model]
		if not (Part and Part.Parent == Camera) then
			if Part then
				pcall(function()
					Part:Destroy()
				end)
			end
			Part = Instance.new("Part")
			Part.Name = "UmberBlastRadius"
			Part.Shape = Enum.PartType.Ball
			Part.Material = Enum.Material.ForceField
			Part.Anchored = true
			Part.CanCollide = false
			Part.CanQuery = false
			Part.CanTouch = false
			Part.CastShadow = false
			Part.Parent = Camera
			BlastSpheres[Model] = Part
		end
		Set(Part, "Color", ZombieConfig.BlastRadiusColor)
		Set(Part, "Transparency", 0.45)
		Set(Part, "Size", Vector3.new(Radius * 2, Radius * 2, Radius * 2))
		Set(Part, "CFrame", CFrame.new(Center))
	end
	for Model in BlastSpheres do
		if not BlastSeen[Model] then
			DestroyBlastSphere(Model)
		end
	end
end
local HitboxParts = {}
local HitboxPartsStamp = 0
local function RefreshHitboxParts()
	local Now = time()
	if Now - HitboxPartsStamp < 0.05 then
		return
	end
	HitboxPartsStamp = Now
	local Camera = workspace.CurrentCamera
	local Container = workspace:FindFirstChild("Zombies")
	local Names = _rl0[22][HitboxConfig.Part]
	local List = {}
	if Camera and Container then
		local Matched = {}
		for _, Child in Camera:GetChildren() do
			local Orig = Child:FindFirstChild("Orig")
			if Orig and Orig:IsA("ObjectValue") and Orig.Value and Orig.Value:IsDescendantOf(Container) then
				Matched[Child] = Orig.Value
			end
		end
		for _, Model in Container:GetChildren() do
			local Ref = Model:FindFirstChild("ClientRef")
			if Ref and Ref:IsA("ObjectValue") and Ref.Value and Ref.Value.Parent == Camera then
				Matched[Ref.Value] = Matched[Ref.Value] or Model
			end
		end
		for Visual, Agent in Matched do
			if HitboxConfig.IgnoreBarrel and IsBarrel(Agent) then
				continue
			end
			for _, Part in Visual:GetChildren() do
				if Part:IsA("BasePart") then
					if not Names or Names[Part.Name] then
						table.insert(List, Part)
					end
				end
			end
		end
	end
	HitboxParts = List
end
local function InvalidateHitboxParts()
	HitboxPartsStamp = 0
end
local function FindExpandedHit(Origin, Direction, Filter)
	local Length = Direction.Magnitude
	if Length <= 0 then
		return nil
	end
	local Unit = Direction / Length
	local Radius = HitboxConfig.Size * 0.5
	local BestPart, BestPoint
	local BestAlong = math.huge
	local BestCost = math.huge
	local BestNormalDir
	local BestExtent = 0
	for Index = 1, #HitboxParts do
		local Part = HitboxParts[Index]
		if table.find(Filter, Part) then
			continue
		end
		local Along = (Part.Position - Origin):Dot(Unit)
		if not (Along >= -Radius and Along <= Length + Radius) then
			continue
		end
		local Clamped = math.clamp(Along, 0, Length)
		local Point = Origin + Unit * Clamped
		local Perp = Part.Position - Point
		local Gap = Perp.Magnitude
		local Bound = math.max(Part.Size.X, Part.Size.Y, Part.Size.Z) * 0.5
		if not (Gap <= Radius + Bound) then
			continue
		end
		local Extent = 0
		local NormalDir
		if Gap > 0.0001 then
			NormalDir = Perp / Gap
			local Frame = Part.CFrame
			Extent = math.abs(NormalDir:Dot(Frame.RightVector)) * Part.Size.X * 0.5
				+ math.abs(NormalDir:Dot(Frame.UpVector)) * Part.Size.Y * 0.5
				+ math.abs(NormalDir:Dot(Frame.LookVector)) * Part.Size.Z * 0.5
		end
		local Cost = Clamped + Gap
		if Gap <= Radius + Extent and Cost < BestCost then
			BestPart = Part
			BestPoint = Point
			BestAlong = Clamped
			BestCost = Cost
			BestNormalDir = NormalDir
			BestExtent = Extent
		end
	end
	if not BestPart then
		return nil
	end
	local Normal = -Unit
	local Position = BestPoint
	if BestNormalDir then
		Position = BestPart.Position - BestNormalDir * BestExtent
		Normal = -BestNormalDir
	end
	return { Instance = BestPart, Position = Position, Normal = Normal, Distance = BestAlong,
		Material = Enum.Material.Plastic
	}
end
local OldNamecall
local FOVCircles = {}
local function GetFOVRadius(Camera, FOV)
	local Size = Camera.ViewportSize
	if FOV >= 179 then
		return math.sqrt(Size.X * Size.X + Size.Y * Size.Y)
	end
	local Half = math.tan(math.rad(math.clamp(FOV, 0, 179) * 0.5))
	local ScreenHalf = math.tan(math.rad(Camera.FieldOfView * 0.5))
	if ScreenHalf <= 0 then
		return 0
	end
	return Half / ScreenHalf * Size.Y * 0.5
end
local function IsAimType(Config, Model)
	if Config.Types.All then
		return true
	end
	local Type = Model:GetAttribute("Type")
	local _sc11 = Type and ZombieNames[Type] or Model.Name
	return Config.Types[_sc11] == true
end
local function GetAimPart(Model)
	local Head = Model:FindFirstChild("Head")
	if Head and Head:IsA("BasePart") then
		return Head
	end
	local Root = Model:FindFirstChild("HumanoidRootPart")
	if Root and Root:IsA("BasePart") then
		return Root
	end
end
local function PickAimTarget(Config)
	local Camera = workspace.CurrentCamera
	local Container = workspace:FindFirstChild("Zombies")
	if not Camera or not Container then
		return nil
	end
	local Center = Camera.ViewportSize * 0.5
	local Radius = GetFOVRadius(Camera, Config.FOV)
	local Best, BestDistance
	for _, Model in Container:GetChildren() do
		if Model:IsA("Model") then
			local Humanoid = Model:FindFirstChildOfClass("Humanoid")
			if Humanoid and Humanoid.Health > 0 and IsAimType(Config, Model) then
				local Part = GetAimPart(Model)
				if Part then
					local Screen, OnScreen = Camera:WorldToViewportPoint(Part.Position)
					if OnScreen then
						local Distance = (Vector2.new(Screen.X, Screen.Y) - Center).Magnitude
						if Distance <= Radius then
							if not BestDistance or Distance < BestDistance then
								Best = { Model = Model, Position = Part.Position }
								BestDistance = Distance
							end
						end
					end
				end
			end
		end
	end
	return Best
end
local CachedPing = 0
local LastPingSample = 0
local SilentTargetPosition
local ShoveRoot
local SilentTargetModel
local LastSilentSample = 0
local function SampleSilentTarget()
	local Now = time()
	if Now - LastSilentSample < 1 / 30 then
		return
	end
	LastSilentSample = Now
	if Now - LastPingSample > 1 then
		LastPingSample = Now
		local Ok, Value = pcall(function()
			return _LocalPlayer:GetNetworkPing()
		end)
		if Ok and typeof(Value) == "number" then
			if Value > 1 then
				Value = Value / 1000
			end
			CachedPing = math.clamp(Value, 0, 0.4)
		else
			Ok, Value = pcall(function()
				local Item = _rl0[7].Network.ServerStatsItem["Data Ping"]
				return Item and Item:GetValue()
			end)
			if Ok and typeof(Value) == "number" then
				CachedPing = math.clamp(Value / 1000, 0, 0.4)
			end
		end
	end
	if not AimConfig.Silent.Enabled then
		SilentTargetPosition = nil
		SilentTargetModel = nil
		return
	end
	local Target = PickAimTarget(AimConfig.Silent)
	if not Target then
		SilentTargetPosition = nil
		SilentTargetModel = nil
		return
	end
	local Root = Target.Model:FindFirstChild("HumanoidRootPart")
	local _sc11_s1 = Root and Root.AssemblyLinearVelocity or Vector3.zero
	SilentTargetPosition = Target.Position + _sc11_s1 * (CachedPing * 0.5)
	SilentTargetModel = Target.Model.Parent and GetVisual(Target.Model) or nil
end
local function EnsureFOVCircle(Name)
	local Circle = FOVCircles[Name]
	if not Circle then
		Circle = Drawing.new("Circle")
		Circle.Thickness = 1
		Circle.Filled = false
		Circle.NumSides = 64
		Circle.Transparency = 0.55
		Circle.Visible = false
		FOVCircles[Name] = Circle
	end
	return Circle
end
local SilentAimColor = Color3.fromRGB(255, 170, 80)
local TargetChams
local function UpdateFOVCircle(Name, Config, Color)
	if not Config.Enabled or not Config.ShowFOV then
		local Hidden = FOVCircles[Name]
		if Hidden then
			Set(Hidden, "Visible", false)
		end
		return
	end
	local Circle = EnsureFOVCircle(Name)
	local Camera = workspace.CurrentCamera
	if not Camera then
		Set(Circle, "Visible", false)
		return
	end
	Set(Circle, "Visible", true)
	Set(Circle, "Position", Camera.ViewportSize * 0.5)
	Set(Circle, "Radius", GetFOVRadius(Camera, Config.FOV))
	Set(Circle, "Color", Color)
end
local function UpdateSilentAim()
	if Unloaded then
		return
	end
	SampleSilentTarget()
	UpdateFOVCircle("Silent", AimConfig.Silent, SilentAimColor)
	if TargetChams and not TargetChams.Parent then
		TargetChams = nil
	end
	if AimConfig.Silent.Enabled and AimConfig.Silent.Chams and SilentTargetModel and SilentTargetModel.Parent then
		if not TargetChams then
			TargetChams = Instance.new("Highlight")
			TargetChams.Name = "UmberTargetChams"
			TargetChams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		end
		TargetChams.FillColor = SilentAimColor
		TargetChams.OutlineColor = SilentAimColor
		TargetChams.FillTransparency = 0.5
		TargetChams.OutlineTransparency = 0
		TargetChams.Parent = SilentTargetModel
	elseif TargetChams then
		TargetChams.Parent = nil
	end
end
local function MakeHeadshot(Result, Origin, Direction)
	local Part = Result.Instance
	local _sc11_s1 = not Part or not Part.Parent
	local _sc11_s2 = _sc11_s1 or Part.Parent.Name ~= "m_Zombie"
	if _sc11_s2 or Part.Name == "Head" then
		return nil
	end
	if math.random() * 100 > MeleeConfig.Chance then
		return nil
	end
	local Head = Part.Parent:FindFirstChild("Head")
	if not Head or not Head:IsA("BasePart") then
		return nil
	end
	local Length = Direction.Magnitude
	local Normal = Vector3.new(0, 1, 0)
	if Length > 0 then
		Normal = -Direction / Length
	end
	return { Instance = Head, Position = Head.Position, Normal = Normal,
		Distance = (Head.Position - Origin).Magnitude, Material = Enum.Material.Plastic
	}
end
local function ProcessMeleeRay(Origin, Direction, Params, Built)
	if typeof(Params) ~= "RaycastParams" or Params.CollisionGroup ~= "Raycast" then
		return Built
	end
	local Filter = Params.FilterDescendantsInstances
	if not Filter or not rawequal(Filter[1], workspace:FindFirstChild("Zombies")) then
		return Built
	end
	local Result = Built
	if HitboxConfig.Enabled then
		RefreshHitboxParts()
		local Expanded = FindExpandedHit(Origin, Direction, Filter)
		local _sc13 = Expanded
		if Expanded then
			_sc13 = not Result or Expanded.Distance < Result.Distance
		end
		if _sc13 then
			Result = Expanded
		end
	end
	if Result and MeleeConfig.AutoHeadshot then
		local Headshot = MakeHeadshot(Result, Origin, Direction)
		if Headshot then
			Result = Headshot
		end
	end
	return Result
end
local function InstallHitboxHook()
	local _sc11 = OldNamecall
	if if OldNamecall then _sc11 else typeof(hookmetamethod) ~= "function" then
		return
	end
	local Previous
	local Success, Result = pcall(function()
		return hookmetamethod(game, "__namecall", function(Self, ...)
			local Method = getnamecallmethod()
			if Method == "FireServer" then
				local Args = table.pack(...)
				if AimConfig.Silent.Enabled
					and Args[1] == "Fire"
					and typeof(Args[3]) == "Vector3"
					and SilentTargetPosition
				then
					Args[3] = SilentTargetPosition
					return Previous(Self, table.unpack(Args, 1, Args.n))
				end
				if ClassConfig.ShoveExpander
					and Args[1] == "FeedbackStun"
					and typeof(Args[3]) == "Vector3"
					and ShoveRoot
				then
					local Center = ShoveRoot.Position + ShoveRoot.CFrame.LookVector * 2
					if (Args[3] - Center).Magnitude > 3 then
						Args[3] = Center
					end
					return Previous(Self, table.unpack(Args, 1, Args.n))
				end
				return Previous(Self, ...)
			end
			if Self ~= workspace then
				return Previous(Self, ...)
			end
			if Method == "GetPartBoundsInRadius" then
				if ClassConfig.ShoveExpander then
					local Args = table.pack(...)
					local Params = Args[3]
					local OkType, FilterType = pcall(function()
						return Params.FilterType
					end)
					if OkType and FilterType == Enum.RaycastFilterType.Include then
						local OkList, List = pcall(function()
							return Params.FilterDescendantsInstances
						end)
						local Radius = Args[2]
						local HasCamera = false
						if OkList and typeof(List) == "table" then
							local Camera = workspace.CurrentCamera
							for _, Entry in ipairs(List) do
								if rawequal(Entry, Camera) then
									HasCamera = true
									break
								end
							end
						end
						if HasCamera
							and typeof(Radius) == "number"
							and Radius <= 5
							and Radius < ClassConfig.ShoveRadius
						then
							Args[2] = ClassConfig.ShoveRadius
							pcall(function()
								Params.MaxParts = math.max(Params.MaxParts, 200)
							end)
							return Previous(Self, table.unpack(Args, 1, Args.n))
						end
					end
				end
				return Previous(Self, ...)
			end
			if Method ~= "Raycast" then
				return Previous(Self, ...)
			end
			if typeof(checkcaller) == "function" and checkcaller() then
				return Previous(Self, ...)
			end
			do
				local Origin, Direction, Params = ...
				local Built = Previous(Self, ...)
				local Ok = true
				local Resolved = Built
				if typeof(Params) == "RaycastParams" and Params.CollisionGroup == "Raycast" then
					Ok, Resolved = pcall(ProcessMeleeRay, Origin, Direction, Params, Built)
				end
				if Ok and Resolved then
					return Resolved
				end
				return Built
			end
		end)
	end)
	if Success and typeof(Result) == "function" then
		OldNamecall = Result
		Previous = Result
	end
end
local function RemoveHitboxHook()
	if OldNamecall then
		local Original = OldNamecall
		OldNamecall = nil
		pcall(function()
			hookmetamethod(game, "__namecall", Original)
		end)
	end
end
local function SyncHook()
	local _sc11_s1 = HitboxConfig.Enabled or MeleeConfig.AutoHeadshot
	local _sc11_s2 = _sc11_s1 or AimConfig.Silent.Enabled
	if _sc11_s2 or ClassConfig.ShoveExpander then
		InstallHitboxHook()
	else
		RemoveHitboxHook()
	end
end
local HitboxVisuals = {}
_rl0[24] = 0
local function ClearHitboxVisuals()
	for _, Box in HitboxVisuals do
		pcall(function()
			Box:Destroy()
		end)
	end
	table.clear(HitboxVisuals)
end
local function ShowBox(Part)
	local Box = HitboxVisuals[Part]
	if not Box or Box.Parent ~= Part then
		Box = Instance.new("BoxHandleAdornment")
		Box.Name = "UmberHitbox"
		Box.Adornee = Part
		Box.Color3 = Color3.fromRGB(255, 170, 80)
		Box.AlwaysOnTop = true
		Box.Parent = Part
		HitboxVisuals[Part] = Box
	end
	local Pad = 0
	if HitboxConfig.Enabled then
		Pad = HitboxConfig.Size
	end
	Set(Box, "Size", Part.Size + Vector3.new(Pad, Pad, Pad))
	Set(Box, "Transparency", HitboxConfig.Transparency)
end
local function UpdateHitboxVisuals()
	if Unloaded then
		return
	end
	local Now = time()
	if Now - _rl0[24] < 0.05 then
		return
	end
	_rl0[24] = Now
	if not HitboxConfig.Show then
		if next(HitboxVisuals) then
			ClearHitboxVisuals()
		end
		return
	end
	RefreshHitboxParts()
	local Seen = {}
	for Index = 1, #HitboxParts do
		local Part = HitboxParts[Index]
		Seen[Part] = true
		ShowBox(Part)
	end
	for Part, Box in HitboxVisuals do
		if not Seen[Part] then
			pcall(function()
				Box:Destroy()
			end)
			HitboxVisuals[Part] = nil
		end
	end
end
local ProjectileTimers = setmetatable({}, { __mode = "k" })
_rl0[25] = 0
local TimerColorHot = Color3.fromRGB(255, 70, 70)
local TimerColorCold = Color3.fromRGB(255, 170, 80)
local TrajectoryLines
local TrajectoryMark
local TrajectorySegments = 72
_rl0[26] = 0.05
local LearnedThrowSpeed = {}
_rl0[27] = { "ThrowSpeed", "ThrowPower", "ProjectileSpeed", "LaunchSpeed", "MuzzleVelocity", "GrenadeSpeed" }
_rl0[28] = { "HasFuse", "FuseTimer", "NumFuseBones", "NoUnderhand" }
_rl0[29] = { ["Hand Mortar"] = true, ["Tar Bottle"] = true, Grenade = true, ["Improved Grenade"] = true }
_rl0[30] = _LocalPlayer:GetMouse()
local ThrowFilter = RaycastParams.new()
ThrowFilter.FilterType = Enum.RaycastFilterType.Exclude
local ThrowIgnore = {}
local function ClearProjectileTimers()
	for _, Entry in ProjectileTimers do
		pcall(function()
			Entry.Text:Remove()
		end)
	end
	table.clear(ProjectileTimers)
end
local function LearnProjectileSpeed(Projectile)
	local Character = _LocalPlayer.Character
	local _sc11 = Character and Character:FindFirstChildOfClass("Tool")
	local Tool = _sc11
	if not _sc11 then
		return
	end
	local Name = Tool.Name
	if Projectile:IsA("BasePart") then
		local Speed = Projectile.AssemblyLinearVelocity.Magnitude
		if Speed >= 10 and Speed <= 400 then
			LearnedThrowSpeed[Name] = Speed
		end
		return
	end
	if not Projectile:IsA("ValueBase") then
		return
	end
	local First = Projectile.Value
	if typeof(First) ~= "Vector3" then
		return
	end
	task.spawn(function()
		task.wait(0.1)
		if not Projectile.Parent then
			return
		end
		local Second = Projectile.Value
		if typeof(Second) ~= "Vector3" then
			return
		end
		local Speed = (Second - First).Magnitude / 0.1
		if Speed >= 10 and Speed <= 400 then
			LearnedThrowSpeed[Name] = Speed
		end
	end)
end
local function TrackProjectile(Projectile)
	if Unloaded then
		return
	end
	LearnProjectileSpeed(Projectile)
	if not ThrowableConfig.Timer then
		return
	end
	if not Projectile:IsA("ValueBase") or ProjectileTimers[Projectile] then
		return
	end
	local Fuse = Projectile:GetAttribute("FuseTimer")
	if typeof(Fuse) ~= "number" then
		return
	end
	local Start = Projectile:GetAttribute("Start")
	local Character = _LocalPlayer.Character
	local _sc12 = Character and Character:FindFirstChild("HumanoidRootPart")
	local Root = _sc12
	if typeof(Start) ~= "Vector3" or not _sc12 then
		return
	end
	if (Start - Root.Position).Magnitude > 12 then
		return
	end
	ProjectileTimers[Projectile] = { Text = CreateText(14), Fuse = Fuse, Started = time() }
end
local function UntrackProjectile(Projectile)
	local Entry = ProjectileTimers[Projectile]
	if not Entry then
		return
	end
	pcall(function()
		Entry.Text:Remove()
	end)
	ProjectileTimers[Projectile] = nil
end
local function UpdateProjectileTimers(Now)
	if not ThrowableConfig.Timer then
		if next(ProjectileTimers) then
			ClearProjectileTimers()
		end
		return
	end
	if Now - _rl0[25] < 1 / 30 then
		return
	end
	_rl0[25] = Now
	local Camera = workspace.CurrentCamera
	if not Camera then
		return
	end
	for Projectile, Entry in ProjectileTimers do
		if not Projectile.Parent then
			UntrackProjectile(Projectile)
		else
			local Remaining = Entry.Fuse - (Now - Entry.Started)
			local Screen
			if typeof(Projectile.Value) == "Vector3" then
				Screen = Camera:WorldToViewportPoint(Projectile.Value)
			end
			if Screen and Remaining > 0 and Screen.Z > 0 then
				Set(Entry.Text, "Visible", true)
				Set(Entry.Text, "Text", string.format("%.1f", Remaining))
				Set(Entry.Text, "Color", Remaining < 1 and TimerColorHot or TimerColorCold)
				Set(Entry.Text, "Position", Vector2.new(Screen.X, Screen.Y - 20))
			else
				Set(Entry.Text, "Visible", false)
			end
		end
	end
end
local MortarFuseText
local MortarFuse
_rl0[31] = 5
_rl0[32] = Color3.fromRGB(255, 70, 70)
_rl0[33] = Color3.fromRGB(255, 170, 80)
_rl0[34] = 0
local function IsFuseLit(Tool)
	local Lit = Tool:GetAttribute("FuseLit")
	return Lit == true or Lit == "true"
end
local function GetMortarAnchor(Tool)
	local Reference = Tool:FindFirstChild("ModelReference")
	local _sc11 = Reference and Reference.Value
	local Model = _sc11
	if _sc11 and Model.Parent then
		local Grenade = Model:FindFirstChild("Grenade")
		if Grenade and Grenade:IsA("Model") then
			return Grenade:GetPivot().Position, Grenade
		end
		return Model:GetPivot().Position, Model
	end
	return nil, nil
end
local MortarHighlight
local MortarHighlightModel
local function ClearMortarHighlight()
	if MortarHighlight then
		pcall(function()
			MortarHighlight:Destroy()
		end)
	end
	MortarHighlight = nil
	MortarHighlightModel = nil
end
local function UpdateMortarHighlight(Model, Remaining)
	if not Model or not Model.Parent then
		ClearMortarHighlight()
		return
	end
	if MortarHighlightModel ~= Model then
		ClearMortarHighlight()
		local Highlight = Instance.new("Highlight")
		Highlight.Name = "UmberMortarChams"
		Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		Highlight.FillTransparency = 0.55
		Highlight.OutlineTransparency = 0
		Highlight.Parent = Model
		MortarHighlight = Highlight
		MortarHighlightModel = Model
	end
	local Color = Remaining < 1 and _rl0[32] or _rl0[33]
	MortarHighlight.FillColor = Color
	MortarHighlight.OutlineColor = Color
	MortarHighlight.Enabled = true
end
local function UpdateMortarFuse()
	if not ThrowableConfig.MortarTimer then
		MortarFuse = nil
		ClearMortarHighlight()
		if MortarFuseText then
			Set(MortarFuseText, "Visible", false)
		end
		return
	end
	local Character = _LocalPlayer.Character
	local _sc11 = Character and Character:FindFirstChildOfClass("Tool")
	local Tool = _sc11
	if not _sc11 or not IsFuseLit(Tool) then
		MortarFuse = nil
		ClearMortarHighlight()
		if MortarFuseText then
			Set(MortarFuseText, "Visible", false)
		end
		return
	end
	if not MortarFuse or MortarFuse.Tool ~= Tool then
		MortarFuse = { Tool = Tool, Started = workspace:GetServerTimeNow() }
	end
	local Remaining = _rl0[31] - (workspace:GetServerTimeNow() - MortarFuse.Started)
	if Remaining <= 0 then
		ClearMortarHighlight()
		if MortarFuseText then
			Set(MortarFuseText, "Visible", false)
		end
		return
	end
	local Now = time()
	if Now - _rl0[34] < 0.05 then
		return
	end
	_rl0[34] = Now
	if not MortarFuseText then
		MortarFuseText = CreateText(20)
	end
	local Camera = workspace.CurrentCamera
	if not Camera then
		return
	end
	local Center = Camera.ViewportSize * 0.5
	local Position = Vector2.new(Center.X, Center.Y + 70)
	local Anchor, Model = GetMortarAnchor(Tool)
	UpdateMortarHighlight(Model, Remaining)
	if Anchor then
		local Screen, OnScreen = Camera:WorldToViewportPoint(Anchor)
		if OnScreen then
			Position = Vector2.new(Screen.X, Screen.Y)
		end
	end
	Set(MortarFuseText, "Visible", true)
	Set(MortarFuseText, "Text", string.format("%.1f", Remaining))
	Set(MortarFuseText, "Color", Remaining < 1 and _rl0[32] or _rl0[33])
	Set(MortarFuseText, "Position", Position)
end
local function EnsureTrajectoryLines()
	if TrajectoryLines then
		return TrajectoryLines
	end
	TrajectoryLines = {}
	for Index = 1, TrajectorySegments do
		local Line = Drawing.new("Line")
		Line.Thickness = 2
		Line.Visible = false
		TrajectoryLines[Index] = Line
	end
	TrajectoryMark = Drawing.new("Square")
	TrajectoryMark.Filled = true
	TrajectoryMark.Thickness = 1
	TrajectoryMark.Visible = false
	return TrajectoryLines
end
local function HideTrajectory()
	if TrajectoryMark then
		Set(TrajectoryMark, "Visible", false)
	end
	if not TrajectoryLines then
		return
	end
	for Index = 1, TrajectorySegments do
		Set(TrajectoryLines[Index], "Visible", false)
	end
end
local function ProjectTrajectory(Camera, From, To)
	local ScreenFrom = Camera:WorldToViewportPoint(From)
	local ScreenTo = Camera:WorldToViewportPoint(To)
	if ScreenFrom.Z <= 0 and ScreenTo.Z <= 0 then
		return nil
	end
	if ScreenFrom.Z <= 0 then
		local Delta = ScreenTo.Z - ScreenFrom.Z
		if Delta <= 0.001 then
			return nil
		end
		ScreenFrom = Camera:WorldToViewportPoint(From:Lerp(To, math.clamp((0.05 - ScreenFrom.Z) / Delta, 0, 1)))
	elseif ScreenTo.Z <= 0 then
		local Delta = ScreenFrom.Z - ScreenTo.Z
		if Delta <= 0.001 then
			return nil
		end
		ScreenTo = Camera:WorldToViewportPoint(To:Lerp(From, math.clamp((0.05 - ScreenTo.Z) / Delta, 0, 1)))
	end
	return Vector2.new(ScreenFrom.X, ScreenFrom.Y), Vector2.new(ScreenTo.X, ScreenTo.Y)
end
local function SolveThrow(Start, Target, Speed)
	local DeltaX = Target.X - Start.X
	local DeltaZ = Target.Z - Start.Z
	local DeltaY = Target.Y - Start.Y
	local Flat = DeltaX * DeltaX + DeltaZ * DeltaZ
	local Gravity = -workspace.Gravity
	local Speed2 = Speed * Speed
	if Flat <= 0 then
		return Vector3.new(0, DeltaY < 0 and -Speed or DeltaY > 0 and Speed or 0, 0)
	end
	local Scale = Flat / (2 * (Flat + DeltaY * DeltaY))
	local Root = Speed2 * (2 * Gravity * DeltaY + Speed2) - Gravity * Gravity * Flat
	if Root <= 0 then
		return nil
	end
	local SqrtRoot = math.sqrt(Root)
	local High = Scale * (Gravity * DeltaY + Speed2 + SqrtRoot)
	if High < 0 or Speed2 - High < 0 then
		return nil
	end
	local FlatRoot = math.sqrt(Flat)
	local Vertical = math.sqrt(Speed2 - High)
	if not (Gravity * Flat / (2 * Speed2) < DeltaY) then
		Vertical = -Vertical
	end
	return Vector3.new(DeltaX / FlatRoot * math.sqrt(High), Vertical, DeltaZ / FlatRoot * math.sqrt(High))
end
local TrajectoryColor = Color3.fromRGB(255, 170, 80)
local TrajectoryColorEnd = Color3.fromRGB(255, 240, 170)
_rl0[35] = 0
local function IsThrowableTool(Tool)
	if _rl0[29][Tool.Name] or LearnedThrowSpeed[Tool.Name] then
		return true
	end
	local Configuration = Tool:FindFirstChild("Configuration")
	if not Configuration then
		return false
	end
	for _, Name in ipairs(_rl0[28]) do
		if Configuration:GetAttribute(Name) ~= nil then
			return true
		end
	end
	return false
end
local function GetThrowSpeed(Tool)
	if not IsThrowableTool(Tool) then
		return nil
	end
	local Configuration = Tool:FindFirstChild("Configuration")
	if Configuration then
		for _, Name in ipairs(_rl0[27]) do
			local Value = Configuration:GetAttribute(Name)
			if typeof(Value) == "number" and Value >= 10 then
				return Value
			end
		end
	end
	return LearnedThrowSpeed[Tool.Name] or 55
end
local MobilePlayer
_rl0[36] = 0
local function IsMobilePlayer()
	local Now = time()
	if MobilePlayer ~= nil and Now - _rl0[36] < 2 then
		return MobilePlayer
	end
	_rl0[36] = Now
	MobilePlayer = _LocalPlayer:GetAttribute("Mobile") == true
	if not MobilePlayer then
		local PlayerGui = _LocalPlayer:FindFirstChildOfClass("PlayerGui")
		MobilePlayer = PlayerGui ~= nil and PlayerGui:FindFirstChild("MobileGui") ~= nil
	end
	if not MobilePlayer then
		MobilePlayer = _UserInputService.TouchEnabled and not _UserInputService.MouseEnabled
	end
	return MobilePlayer
end
local function GetThrowOrigin(Tool, Character)
	local Ref = Tool:FindFirstChild("HandleWeldRef")
	if Ref and Ref:IsA("ObjectValue") then
		local Weld = Ref.Value
		if Weld and Weld.Part1 then
			return Weld.Part1
		end
	end
	local _sc12_s1 = Character:FindFirstChild("RightHand") or Character:FindFirstChild("Right Arm")
	return _sc12_s1 or Character:FindFirstChild("HumanoidRootPart")
end
local function UpdateTrajectory()
	if not ThrowableConfig.Trajectory then
		HideTrajectory()
		return
	end
	local Now = time()
	if Now - _rl0[35] < 1 / 30 then
		return
	end
	_rl0[35] = Now
	local Character = _LocalPlayer.Character
	local _sc11 = Character and Character:FindFirstChildOfClass("Tool")
	local Tool = _sc11
	local Camera = workspace.CurrentCamera
	if not _sc11 or not Camera then
		HideTrajectory()
		return
	end
	local Speed = GetThrowSpeed(Tool)
	if not Speed then
		HideTrajectory()
		return
	end
	local Origin = GetThrowOrigin(Tool, Character)
	if not Origin then
		HideTrajectory()
		return
	end
	local Velocity
	if IsMobilePlayer() then
		Velocity = Camera.CFrame.LookVector * Speed
	else
		local Target = _rl0[30].Hit.Position
		if typeof(Target) ~= "Vector3" then
			HideTrajectory()
			return
		end
		Velocity = SolveThrow(Origin.Position, Target, Speed)
		if not Velocity then
			local Direction = Target - Origin.Position
			if Direction.Magnitude < 0.1 then
				Direction = Camera.CFrame.LookVector
			end
			Velocity = Direction.Unit * Speed
		end
	end
	local Lines = EnsureTrajectoryLines()
	local Gravity = Vector3.new(0, -workspace.Gravity, 0)
	local Point = Origin.Position
	local Step = _rl0[26]
	local Count = 0
	local Hit = false
	ThrowIgnore[1] = Character
	ThrowIgnore[2] = Camera
	ThrowFilter.FilterDescendantsInstances = ThrowIgnore
	for Index = 1, TrajectorySegments do
		local Next = Point + Velocity * Step + Gravity * (0.5 * Step * Step)
		local Result = workspace:Raycast(Point, Next - Point, ThrowFilter)
		Velocity += Gravity * Step
		if Result then
			Next = Result.Position
			Hit = true
		end
		local ScreenFrom, ScreenTo = ProjectTrajectory(Camera, Point, Next)
		local Line = Lines[Index]
		local Alpha = Index / TrajectorySegments
		if ScreenFrom then
			Set(Line, "Visible", true)
			Set(Line, "Color", TrajectoryColor:Lerp(TrajectoryColorEnd, Alpha))
			Set(Line, "Thickness", 3 - Alpha * 1.5)
			Set(Line, "From", ScreenFrom)
			Set(Line, "To", ScreenTo)
		else
			Set(Line, "Visible", false)
		end
		Count = Index
		Point = Next
		if Result then
			break
		end
	end
	for Index = Count + 1, TrajectorySegments do
		Set(Lines[Index], "Visible", false)
	end
	if TrajectoryMark then
		local Screen = Camera:WorldToViewportPoint(Point)
		if Screen.Z > 0 then
			local Size = Hit and 9 or 5
			Set(TrajectoryMark, "Visible", true)
			Set(TrajectoryMark, "Color", TrajectoryColorEnd)
			Set(TrajectoryMark, "Transparency", Hit and 0.05 or 0.5)
			Set(TrajectoryMark, "Position", Vector2.new(Screen.X - Size * 0.5, Screen.Y - Size * 0.5))
			Set(TrajectoryMark, "Size", Vector2.new(Size, Size))
		else
			Set(TrajectoryMark, "Visible", false)
		end
	end
end
local function UpdateThrowables()
	if Unloaded then
		return
	end
	local Now = time()
	UpdateProjectileTimers(Now)
	UpdateMortarFuse()
	UpdateTrajectory()
end
task.spawn(function()
	local Folder = workspace:WaitForChild("Projectiles", 60)
	if Unloaded or not Folder then
		return
	end
	Track(Folder.ChildAdded:Connect(TrackProjectile))
	Track(Folder.ChildRemoved:Connect(UntrackProjectile))
end)
local BubbleSpheres = {}
local function Cleanup()
	Unloaded = true
	SendUserCount("left")
	for _, Connection in Connections do
		if Connection.Connected then
			Connection:Disconnect()
		end
	end
	table.clear(Connections)
	for _, Entry in Tracked do
		DestroyEntry(Entry)
	end
	for _, Entry in SurgeonTracked do
		DestroyEntry(Entry)
	end
	for _, Highlight in SupplyHighlights do
		pcall(function()
			Highlight:Destroy()
		end)
	end
	table.clear(SupplyHighlights)
	table.clear(SurgeonTracked)
	table.clear(Tracked)
	table.clear(Visuals)
	table.clear(FuseMarks)
	ESPEMA = 0
	LastESPStep = 1
	LastESPInterval = 1 / 30
	ClearHitboxVisuals()
	RemoveHitboxHook()
	ClearProjectileTimers()
	HideTrajectory()
	ClearMortarHighlight()
	MortarFuse = nil
	if MortarFuseText then
		pcall(function()
			MortarFuseText:Remove()
		end)
		MortarFuseText = nil
	end
	for Model in BlastSpheres do
		DestroyBlastSphere(Model)
	end
	for _, Circle in FOVCircles do
		pcall(function()
			Circle:Remove()
		end)
	end
	table.clear(FOVCircles)
	for _, Part in BubbleSpheres do
		pcall(function()
			Part:Destroy()
		end)
	end
	table.clear(BubbleSpheres)
	RestoreWorldLighting()
	if TrajectoryLines then
		for _, Line in TrajectoryLines do
			pcall(function()
				Line:Remove()
			end)
		end
		TrajectoryLines = nil
	end
	ClearChargeSpeed()
	ClearSwingBuffs()
	if TargetChams then
		pcall(function()
			TargetChams:Destroy()
		end)
		TargetChams = nil
	end
	SilentTargetModel = nil
	local Character = _LocalPlayer.Character
	if Character then
		pcall(function()
			Character:SetAttribute("SwingSpeedScalar", nil)
		end)
	end
	getgenv().UmberUnload = nil
end
do
	local function BindCharacter()
		SpeedModifier = nil
		ApplySwingSpeed()
		ApplyChargeSpeed()
		local Character = _LocalPlayer.Character
		if Character then
			Track(Character.ChildAdded:Connect(function(Child)
				if Child:IsA("Tool") then
					ApplySwingSpeed()
				end
			end))
			task.spawn(function()
				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				local Deadline = tick() + 10
				while not Humanoid and tick() < Deadline do
					task.wait(0.1)
					Humanoid = Character:FindFirstChildOfClass("Humanoid")
				end
				if not Humanoid then
					return
				end
				local Animator = Humanoid:FindFirstChildOfClass("Animator")
				local Deadline_s1 = tick() + 10
				while not Animator and tick() < Deadline_s1 do
					task.wait(0.1)
					Animator = Humanoid:FindFirstChildOfClass("Animator")
				end
				if not Animator then
					return
				end
				Track(Animator.AnimationPlayed:Connect(function(SwingTrack)
					if not LegitConfig.AutoJump then
						return
					end
					local _sc13 = SwingTrack and SwingTrack.Name
					if _sc13 ~= "SwingRight" and _sc13 ~= "SwingDown" and _sc13 ~= "Thrust" then
						return
					end
					local Tool = Character:FindFirstChildOfClass("Tool")
					if not Tool then
						return
					end
					local IsMelee = MeleeToolCache[Tool]
					if IsMelee == nil then
						IsMelee = IsMeleeTool(Tool)
						MeleeToolCache[Tool] = IsMelee
					end
					if not IsMelee then
						return
					end
					local _sc14_s1 = not Humanoid or Humanoid.Health <= 0
					if _sc14_s1 or Humanoid.FloorMaterial == Enum.Material.Air then
						return
					end
					local OkPower, CurrentPower = pcall(function()
						return Humanoid.JumpPower
					end)
					local _sc15_s1 = not OkPower or typeof(CurrentPower) ~= "number"
					local _sc15_s2 = _sc15_s1 or CurrentPower <= 0
					local WasZero = _sc15_s2
					if _sc15_s2 then
						pcall(function()
							Humanoid.JumpPower = 30
						end)
					end
					Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					if WasZero then
						task.delay(0.15, function()
							pcall(function()
								Humanoid.JumpPower = 0
							end)
						end)
					end
				end))
			end)
		end
	end
	Track(_LocalPlayer.CharacterAdded:Connect(BindCharacter))
	BindCharacter()
end
_rl0[37] = 0
local function UpdateAutoBuild()
	if not ClassConfig.AutoBuild or Unloaded then
		return
	end
	local Now = tick()
	if Now - _rl0[37] < 0.5 then
		return
	end
	_rl0[37] = Now
	local Character = _LocalPlayer.Character
	local _sc11 = Character and Character:FindFirstChild("HumanoidRootPart")
	local Root = _sc11
	if not _sc11 then
		return
	end
	local Backpack = _LocalPlayer:FindFirstChild("Backpack")
	local _sc12 = Backpack and Backpack:FindFirstChild("Hammer") or Character:FindFirstChild("Hammer")
	local Hammer = _sc12
	if not _sc12 then
		return
	end
	local Remote = Hammer:FindFirstChild("RemoteEvent")
	if not Remote then
		return
	end
	local Container = workspace:FindFirstChild("Buildings")
	if not Container then
		return
	end
	local RootPos = Root.Position
	local Best
	local BestKey = math.huge
	for _, Health in ipairs(Container:GetDescendants()) do
		if not (Health.Name == "BuildingHealth" or Health.Name == "ConstructHealth") then
			continue
		end
		local Building = Health.Parent
		if not Building then
			continue
		end
		local Hitbox = Building:FindFirstChild("Hitbox")
		local Anchor = Hitbox or Building
		local Ok, Pos = pcall(function()
			if Anchor:IsA("BasePart") then
				return Anchor.Position
			end
			return Anchor:GetPivot().Position
		end)
		if Ok and Pos then
			local Distance = (Pos - RootPos).Magnitude
			if Distance <= 15 then
				local Key = Distance
				if ClassConfig.BuildPriority == "Lowest Health Building" then
					local OkValue, Value = pcall(function()
						return Health.Value
					end)
					local OkMax, Max = pcall(function()
						return Health:GetAttribute("MaxHealth")
					end)
					if OkValue and typeof(Value) == "number" and OkMax and typeof(Max) == "number" and Max > 0 then
						if Value >= Max then
							continue
						end
						Key = Value / Max
					end
				end
				if Key < BestKey then
					BestKey = Key
					Best = Health
				end
			end
		end
	end
	if Best then
		Remote:FireServer("Repair", Best)
	end
end
local function UpdateBubbleSphere(Name, Enabled, Center, Radius, Color, Transparency)
	local Part = BubbleSpheres[Name]
	if not Enabled or Unloaded then
		if Part then
			Set(Part, "CFrame", CFrame.new(0, -500, 0))
		end
		return
	end
	local Camera = workspace.CurrentCamera
	if not Camera then
		return
	end
	if not (Part and Part.Parent == Camera) then
		if Part then
			pcall(function()
				Part:Destroy()
			end)
		end
		Part = Instance.new("Part")
		Part.Name = Name
		Part.Shape = Enum.PartType.Ball
		Part.Material = Enum.Material.ForceField
		Part.Color = Color
		Part.Anchored = true
		Part.CanCollide = false
		Part.CanQuery = false
		Part.CanTouch = false
		Part.CastShadow = false
		Part.Parent = Camera
		BubbleSpheres[Name] = Part
	end
	Set(Part, "Transparency", math.clamp(Transparency, 0.01, 1))
	Set(Part, "Size", Vector3.new(Radius * 2, Radius * 2, Radius * 2))
	Set(Part, "CFrame", CFrame.new(Center))
end
local function UpdateShoveVisual()
	local Character = _LocalPlayer.Character
	local _sc11 = Character and Character:FindFirstChild("HumanoidRootPart")
	local Root = _sc11
	local Center
	local Radius = 1
	ShoveRoot = _sc11
	if ClassConfig.ShoveShow and not Unloaded then
		local _sc12 = Character and Character:FindFirstChildOfClass("Tool")
		local Tool = _sc12
		local CanShove = false
		local Stock = 3
		if _sc12 then
			local Configuration = Tool:FindFirstChild("Configuration")
			if Configuration then
				local Ok, Value = pcall(function()
					return Configuration:GetAttribute("CanShove")
				end)
				if Ok and Value then
					CanShove = true
					local OkRadius, Radius = pcall(function()
						return Configuration:GetAttribute("ShoveHitboxRadius")
					end)
					if OkRadius and typeof(Radius) == "number" then
						Stock = Radius
					end
				end
			end
		end
		if CanShove and Root then
			Radius = ClassConfig.ShoveExpander and math.max(Stock, ClassConfig.ShoveRadius) or Stock
			Center = Root.Position + Root.CFrame.LookVector * 2
		end
	end
	local _sc12 = Center
	if not Center then
		local UpdateBubbleSphere_v1 = UpdateBubbleSphere
		_sc12 = Vector3.zero
	end
	UpdateBubbleSphere("UmberShoveHitbox", Center ~= nil, _sc12, Radius, Color3.fromRGB(255, 90, 90), ClassConfig.ShoveTransparency / 100)
end
local function GetKillAuraRange()
	local Character = _LocalPlayer.Character
	local _sc11 = Character and Character:FindFirstChildOfClass("Tool")
	local Tool = _sc11
	local Limit = 5
	if _sc11 then
		local Configuration = Tool:FindFirstChild("Configuration")
		if Configuration then
			local Ok, Value = pcall(function()
				return Configuration:GetAttribute("LimitRange")
			end)
			if Ok and typeof(Value) == "number" and Value > 0 then
				Limit = Value
			end
		end
	end
	return math.min(KillAuraConfig.Range, Limit)
end
local function UpdateKillAuraVisual()
	local Character = _LocalPlayer.Character
	local _sc11 = Character and Character:FindFirstChild("HumanoidRootPart")
	local Root = _sc11
	if not _sc11 or Unloaded then
		UpdateBubbleSphere("UmberKillAura", false, Vector3.zero, 1, Color3.fromRGB(170, 90, 255), 0.9)
		return
	end
	UpdateBubbleSphere("UmberKillAura", KillAuraConfig.Show, Root.Position, math.max(GetKillAuraRange(), 0.5), Color3.fromRGB(170, 90, 255), 0.9)
end
_rl0[38] = 0
local function CollectKillAuraTargets(Character, Root, Tool)
	local _sc11 = Tool and Tool:FindFirstChild("RemoteEvent")
	local Remote = _sc11
	if not _sc11 then
		return nil, nil, nil
	end
	local Container = workspace:FindFirstChild("Zombies")
	if not Container then
		return nil, nil, nil
	end
	local Origin = Root.Position
	local Range = GetKillAuraRange()
	local Targets = {}
	for _, Model in ipairs(Container:GetChildren()) do
		local ZombieHumanoid = Model:FindFirstChildOfClass("Humanoid")
		if not (ZombieHumanoid and ZombieHumanoid.Health > 0) then
			continue
		end
		local Ref = Model:FindFirstChild("ClientRef")
		local _sc13 = Ref and Ref:IsA("ObjectValue") and Ref.Value
		local Visual = _sc13
		if not _sc13 then
			continue
		end
		local Group = KillAuraConfig.Part ~= "All" and KillAuraPartGroups[KillAuraConfig.Part] or nil
		local BestPart, BestDistance
		for _, Part in ipairs(Visual:GetDescendants()) do
			if Part:IsA("BasePart") and Part.Transparency < 0.95 then
				if not Group or Group[Part.Name] then
					local Distance = (Part.Position - Origin).Magnitude
					if Distance > 0.5 then
						if not BestDistance or Distance < BestDistance then
							BestPart = Part
							BestDistance = Distance
						end
					end
				end
			end
		end
		if BestPart and BestDistance <= Range then
			table.insert(Targets, { Model = Model, Part = BestPart, Distance = BestDistance })
		end
	end
	table.sort(Targets, function(A, B)
		return A.Distance < B.Distance
	end)
	return Remote, Targets, Container
end
local function SendKillAuraHits(Character, Root, Remote, Container, Targets, Cap)
	local Origin = Root.Position
	local Sent = 0
	for _, Target in ipairs(Targets) do
		if Sent >= Cap then
			break
		end
		local Pos = Target.Part.Position
		local Direction = (Pos - Origin).Unit
		local OkBlock, Blocked = pcall(function()
			local RayParams = RaycastParams.new()
			RayParams.FilterType = Enum.RaycastFilterType.Exclude
			RayParams.FilterDescendantsInstances = { Character, Container, workspace.CurrentCamera }
			return workspace:Raycast(Origin, Direction * Target.Distance, RayParams) ~= nil
		end)
		if OkBlock and not Blocked then
			pcall(function()
				Remote:FireServer("HitZombieM", Target.Model, Pos, Target.Part.Name == "Head", Direction * 25, Target.Part.Name, -Direction)
			end)
			Sent += 1
		end
	end
end
local function UpdateKillAura()
	if not KillAuraConfig.Enabled or Unloaded then
		return
	end
	local Character = _LocalPlayer.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")
	local _sc12 = Character and Character:FindFirstChildOfClass("Humanoid")
	local Humanoid = _sc12
	if not Root or not _sc12 or Humanoid.Health <= 0 then
		return
	end
	local Tool = Character:FindFirstChildOfClass("Tool")
	if not Tool then
		return
	end
	local IsMelee = MeleeToolCache[Tool]
	if IsMelee == nil then
		IsMelee = IsMeleeTool(Tool)
		MeleeToolCache[Tool] = IsMelee
	end
	if not IsMelee then
		return
	end
	local Now = tick()
	local Interval = 0.5
	local Cap = 5
	local Configuration = Tool:FindFirstChild("Configuration")
	if Configuration then
		local OkDeal, Deal = pcall(function()
			return Configuration:GetAttribute("DealTime")
		end)
		local OkSwing, Swing = pcall(function()
			return Configuration:GetAttribute("SwingTime")
		end)
		local OkHits, Hits = pcall(function()
			return Configuration:GetAttribute("MaxHits")
		end)
		if OkDeal and typeof(Deal) == "number" then
			Interval = Deal
		end
		if OkSwing and typeof(Swing) == "number" and Swing > Interval then
			Interval = Swing
		end
		if OkHits and typeof(Hits) == "number" and Hits > 0 then
			Cap = math.floor(Hits)
		end
	end
	Interval = Interval / math.max(KillAuraConfig.Speed, 0.05)
	if Interval < 0.1 then
		Interval = 0.1
	end
	if Now - _rl0[38] < Interval then
		return
	end
	_rl0[38] = Now
	local Remote = CollectKillAuraTargets(Character, Root, Tool)
	if not Remote then
		return
	end
	pcall(function()
		Remote:FireServer("PrepareSwing")
	end)
	task.delay(0.2, function()
		local _sc14 = Unloaded
		if if Unloaded then _sc14 else not KillAuraConfig.Enabled then
			return
		end
		local FreshCharacter = _LocalPlayer.Character
		local FreshRoot = FreshCharacter and FreshCharacter:FindFirstChild("HumanoidRootPart")
		local _sc16 = FreshCharacter and FreshCharacter:FindFirstChildOfClass("Tool")
		local FreshTool = _sc16
		if not FreshRoot or not _sc16 or not IsMeleeTool(FreshTool) then
			return
		end
		pcall(function()
			Remote:FireServer("Swing", "Thrust")
		end)
		local FreshRemote, FreshTargets, FreshContainer = CollectKillAuraTargets(FreshCharacter, FreshRoot, FreshTool)
		if FreshRemote and FreshTargets then
			SendKillAuraHits(FreshCharacter, FreshRoot, FreshRemote, FreshContainer, FreshTargets, Cap)
		end
	end)
end
local SurgeonState = { Target = nil, Path = nil, Waypoints = nil, Index = 1, Goal = nil, RepathAt = 0, HealAt = 0,
	HealTarget = nil, HealHealth = nil, Threats = nil, ThreatsAt = 0, SuppliesAt = 0
}
do
	local function UpdateSuppliesESP()
		local Now = os.clock()
		if Now - SurgeonState.SuppliesAt < 0.4 then
			return
		end
		SurgeonState.SuppliesAt = Now
		local Enabled = SurgeonConfig.SuppliesESP
		for Part, Highlight in SupplyHighlights do
			if not Enabled or not Part.Parent then
				pcall(function()
					Highlight:Destroy()
				end)
				SupplyHighlights[Part] = nil
			end
		end
		if not Enabled then
			return
		end
		local Color = SurgeonConfig.SuppliesColor
		for _, Part in workspace:GetChildren() do
			if Part.Name == "SupplyVisualizer" and Part:IsA("BasePart") then
				local Highlight = SupplyHighlights[Part]
				if not Highlight or not Highlight.Parent then
					Highlight = Instance.new("Highlight")
					Highlight.Name = "UmberSupplies"
					Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					Highlight.FillTransparency = 0.45
					Highlight.OutlineTransparency = 0
					Highlight.Parent = Part
					SupplyHighlights[Part] = Highlight
				end
				Highlight.FillColor = Color
				Highlight.OutlineColor = Color
				Highlight.Enabled = true
			end
		end
	end
	local function SurgeonTarget()
		local Character = _LocalPlayer.Character
		local _sc11 = Character and Character:FindFirstChild("HumanoidRootPart")
		local Root = _sc11
		local Container = workspace:FindFirstChild("Players")
		if not (_sc11 and Container) then
			return nil
		end
		local Best
		local BestScore = math.huge
		local RootPos = Root.Position
		local Limit = SurgeonConfig.MaxDistance
		for _, Model in ipairs(Container:GetChildren()) do
			if Model:IsA("Model") and Model ~= Character then
				local Humanoid = Model:FindFirstChildOfClass("Humanoid")
				local TargetRoot = Model:FindFirstChild("HumanoidRootPart")
				if Humanoid and TargetRoot and Humanoid.Health > 0 and Humanoid.Health < Humanoid.MaxHealth then
					local Distance = (TargetRoot.Position - RootPos).Magnitude
					if Distance <= Limit then
						local Score = Humanoid.Health / math.max(Humanoid.MaxHealth, 1) * 100 + Distance * 0.15
						if Score < BestScore then
							BestScore = Score
							Best = { Model = Model, Humanoid = Humanoid, Root = TargetRoot }
						end
					end
				end
			end
		end
		return Best
	end
	local function SurgeonThreats()
		local Container = workspace:FindFirstChild("Zombies")
		if not Container then
			return nil
		end
		local Threats = {}
		for _, Model in ipairs(Container:GetChildren()) do
			local Humanoid = Model:FindFirstChildOfClass("Humanoid")
			if Humanoid and Humanoid.Health > 0 then
				local OkPos, Position = pcall(function()
					return Model:GetPivot().Position
				end)
				if OkPos and Position then
					local Kind = Model:GetAttribute("Type")
					local Radius = 10
					if Kind == "Barrel" then
						local Blast = Model:GetAttribute("BlastRadius")
						Radius = if typeof(Blast) == "number" then Blast + 4 else 13
					end
					table.insert(Threats, { Model = Model, Type = Kind, Position = Position, Radius = Radius })
				end
			end
		end
		return Threats
	end
	local function SurgeonSteer(Goal, Threats)
		if not SurgeonConfig.Avoid or not Threats then
			return Goal
		end
		local Steer = Goal
		for _, Threat in ipairs(Threats) do
			local Offset = Steer - Threat.Position
			local Distance = Offset.Magnitude
			if Distance < Threat.Radius then
				if Distance < 0.1 then
					Offset = Vector3.new(1, 0, 0)
				end
				Steer = Threat.Position + Offset.Unit * Threat.Radius
			end
		end
		return Steer
	end
	local function SurgeonPath(Root, Goal)
		local Path = SurgeonState.Path
		if not Path then
			local OkPath, Created = pcall(function()
				return _rl0[8]:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, AgentJumpHeight = 7, AgentMaxSlope = 50 })
			end)
			if not OkPath or not Created then
				return nil
			end
			Path = Created
			SurgeonState.Path = Path
		end
		local Ok = pcall(function()
			Path:ComputeAsync(Root.Position, Goal)
		end)
		if not Ok or Path.Status ~= Enum.PathStatus.Success then
			return nil
		end
		return Path:GetWaypoints()
	end
	local function SurgeonMoveLegit(Root, Humanoid, Target)
		local Now = os.clock()
		if Now - SurgeonState.ThreatsAt >= 0.25 then
			SurgeonState.ThreatsAt = Now
			SurgeonState.Threats = SurgeonThreats()
		end
		local Threats = SurgeonState.Threats
		local Goal = Target.Root.Position
		if (Goal - Root.Position).Magnitude <= 2.2 then
			Humanoid:MoveTo(Root.Position)
			return
		end
		local Shift = SurgeonState.Goal and (Goal - SurgeonState.Goal).Magnitude or math.huge
		local Waypoints
		local _sc13_s1 = not SurgeonState.Waypoints or Now - SurgeonState.RepathAt >= 0.5
		if _sc13_s1 or Shift > 4 then
			SurgeonState.RepathAt = Now
			SurgeonState.Goal = Goal
			Waypoints = SurgeonPath(Root, SurgeonSteer(Goal, Threats))
			if Waypoints then
				SurgeonState.Waypoints = Waypoints
				SurgeonState.Index = 2
			else
				SurgeonState.Waypoints = nil
			end
		end
		Waypoints = SurgeonState.Waypoints
		if not Waypoints then
			Humanoid:MoveTo(Goal)
			return
		end
		local Index = SurgeonState.Index
		if Index > #Waypoints then
			Humanoid:MoveTo(Goal)
			return
		end
		local Waypoint = Waypoints[Index]
		local WaypointPos = Waypoint.Position
		local Flat = Vector3.new(WaypointPos.X, Root.Position.Y, WaypointPos.Z)
		if (Flat - Root.Position).Magnitude < 2.5 then
			Index += 1
			SurgeonState.Index = Index
			if Index > #Waypoints then
				return
			end
			Waypoint = Waypoints[Index]
			WaypointPos = Waypoint.Position
		end
		Humanoid:MoveTo(WaypointPos)
		if Waypoint.Action == Enum.PathWaypointAction.Jump then
			Humanoid.Jump = true
		end
	end
	local function SurgeonMoveBlatant(Root, Target, Delta)
		local Goal = Target.Root.Position
		local Flat = Vector3.new(Goal.X, Root.Position.Y, Goal.Z)
		local Offset = Flat - Root.Position
		local Distance = Offset.Magnitude
		if Distance <= 2.2 then
			return
		end
		local Step = math.min(Distance - 2, 70 * Delta)
		local Next = Root.Position + Offset.Unit * Step
		Root.CFrame = CFrame.new(Next) * (Root.CFrame - Root.CFrame.Position)
	end
	local function SurgeonHeal(Root, Character, Target, Now)
		if Now - SurgeonState.HealAt < 0.7 then
			return
		end
		SurgeonState.HealAt = Now
		if (Target.Root.Position - Root.Position).Magnitude > 3 then
			return
		end
		local Health = Target.Humanoid.Health
		if SurgeonState.HealTarget == Target.Model and Health > (SurgeonState.HealHealth or -1) then
			SurgeonState.HealHealth = Health
			return
		end
		local Backpack = _LocalPlayer:FindFirstChildOfClass("Backpack")
		local Med = Character:FindFirstChild("Medical Supplies")
			or Backpack and Backpack:FindFirstChild("Medical Supplies")
		if not Med then
			return
		end
		if Med.Parent ~= Character then
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				pcall(function()
					Humanoid:EquipTool(Med)
				end)
			end
			return
		end
		local Remote = Med:FindFirstChild("RemoteEvent")
		if not Remote then
			return
		end
		pcall(function()
			Remote:FireServer("SendRequest", Target.Humanoid)
		end)
		SurgeonState.HealTarget = Target.Model
		SurgeonState.HealHealth = Health
	end
	_rl0[39] = { Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Down }
	local function SurgeonUserMoving()
		for _, Key in ipairs(_rl0[39]) do
			if _UserInputService:IsKeyDown(Key) then
				return true
			end
		end
		return false
	end
	local function UpdateSurgeon(Delta)
		if Unloaded then
			return
		end
		UpdateSuppliesESP()
		if not SurgeonConfig.AutoHeal then
			SurgeonState.Target = nil
			SurgeonState.Waypoints = nil
			return
		end
		local Character = _LocalPlayer.Character
		local Root = Character and Character:FindFirstChild("HumanoidRootPart")
		local _sc12 = Character and Character:FindFirstChildOfClass("Humanoid")
		local Humanoid = _sc12
		if not (Root and _sc12) or Humanoid.Health <= 0 then
			return
		end
		local Target = SurgeonState.Target
		if Target then
			local TargetHumanoid = Target.Humanoid
			local _sc14_s1 = not Target.Model.Parent or not Target.Root.Parent
			local _sc14_s2 = _sc14_s1 or not TargetHumanoid
			local _sc14_s3 = _sc14_s2 or TargetHumanoid.Health <= 0
			if _sc14_s3 or TargetHumanoid.Health >= TargetHumanoid.MaxHealth then
				Target = nil
			end
		end
		if not Target then
			Target = SurgeonTarget()
			SurgeonState.Target = Target
			SurgeonState.Waypoints = nil
			SurgeonState.Goal = nil
		end
		if not Target then
			Humanoid:MoveTo(Root.Position)
			return
		end
		if not SurgeonUserMoving() then
			if SurgeonConfig.Mode == "Blatant" then
				SurgeonMoveBlatant(Root, Target, Delta)
			else
				SurgeonMoveLegit(Root, Humanoid, Target)
			end
		end
		SurgeonHeal(Root, Character, Target, os.clock())
	end
	local function UpdateFrame(Delta)
		UpdateESP()
		UpdateHitboxVisuals()
		UpdateThrowables()
		UpdateBlastRings()
		GuardWorldFog()
		UpdateSilentAim()
		UpdateAutoBuild()
		UpdateShoveVisual()
		UpdateKillAuraVisual()
		UpdateKillAura()
		UpdateSurgeon(Delta)
	end
	Track(_rl0[6].RenderStepped:Connect(UpdateFrame))
end
Track(_rl0[6].Heartbeat:Connect(SpoofGrabPosition))
Track(_rl0[6].Heartbeat:Connect(ApplySwingSpeed))
Library:OnUnload(Cleanup)
getgenv().UmberUnload = function()
	Library:Unload()
end
do
	_rl0[40] = Pace(_rl0[9].Player:AddGroupbox({ Name = "Movement", Side = "Left", IconName = "footprints" }))
	_rl0[40]:AddToggle("WalkSpeedToggle", { Text = "Walkspeed Toggle",
		Tooltip = "Borrows the game's Charge speed buff so your speed holds through swings and reloads.",
		Default = false,
		["Callback"] = function(Value)
			ChargeSpeed = Value
			ApplyChargeSpeed()
		end
	})
	_rl0[40]:AddSlider("WalkSpeedValue", { AllowRightClickInput = true, Text = "Walk Speed",
		Tooltip = "How fast you move while the toggle is on.", Default = 55, Min = 16, Max = 70,
		Rounding = 0,
		["Callback"] = function(Value)
			ChargeValue = Value
			if ChargeSpeed then
				ApplyChargeSpeed()
			end
		end
	})
end
do
	_rl0[41] = Pace(_rl0[9].Player:AddGroupbox({ Name = "Protection", Side = "Right", IconName = "shield" }))
	_rl0[41]:AddToggle("AntiGrab", { Text = "Anti Grab", Tooltip = "Moves you out of grab range on paper so shamblers can't latch on.",
		Default = false,
		["Callback"] = function(Value)
			AntiGrabEnabled = Value
		end
	})
end
do
	_rl0[42] = Pace(_rl0[9].Visuals:AddGroupbox({ Name = "ESP", Side = "Left", IconName = "scan-eye" }))
	_rl0[42]:AddToggle("ZombieESP", { Text = "Zombie ESP", Tooltip = "Turns on all the zombie visuals.", Default = false,
		["Callback"] = function(Value)
			ZombieConfig.Enabled = Value
		end
	})
	_rl0[42]:AddToggle("PlayerESP", { Text = "Player ESP", Tooltip = "Turns on all the player visuals.", Default = false,
		["Callback"] = function(Value)
			PlayerConfig.Enabled = Value
		end
	})
end
do
	_rl0[43] = Pace(_rl0[9].Visuals:AddGroupbox({ Name = "Zombie ESP Options", Side = "Left", IconName = "crosshair" }))
	_rl0[43]:AddDropdown("ZombieType", { Values = _rl0[21], Default = { "All" }, Text = "Zombie Type",
		Tooltip = "Only draw the types you tick.", Multi = true,
		["Callback"] = function(Value)
			local Types = {}
			for Key in Value do
				Types[Key] = true
			end
			ZombieConfig.Types = Types
		end
	})
	_rl0[43]:AddToggle("ZombieBox", { Text = "Box", Tooltip = "Box around each zombie.", Default = true,
		["Callback"] = function(Value)
			ZombieConfig.Box = Value
			if Value then
				EnsureEnabled("ZombieESP")
			end
		end
	})
	_rl0[43]:AddDropdown("ZombieBoxStyle", { Values = { "Box", "Corner", "Filled Box" }, Default = "Box", Text = "Box Style",
		Tooltip = "Plain box, corner brackets, or a filled box.",
		["Callback"] = function(Value)
			ZombieConfig.BoxStyle = Value
		end
	})
	_rl0[43]:AddToggle("ZombieChams", { Text = "Chams", Tooltip = "Colours the zombie itself.", Default = false,
		["Callback"] = function(Value)
			ZombieConfig.Chams = Value
			if Value then
				EnsureEnabled("ZombieESP")
			end
		end
	})
	_rl0[43]:AddToggle("ZombieTracers", { Text = "Tracers", Tooltip = "Line from your screen to them.", Default = false,
		["Callback"] = function(Value)
			ZombieConfig.Tracers = Value
			if Value then
				EnsureEnabled("ZombieESP")
			end
		end
	}):AddColorPicker("ZombieTracersColor", { Default = Color3.fromRGB(164, 91, 38), Title = "Tracer Color",
		["Callback"] = function(Value)
			ZombieConfig.TracerColor = Value
		end
	})
	_rl0[43]:AddToggle("ZombieNames", { Text = "Names", Tooltip = "Zombie type above the box.", Default = false,
		["Callback"] = function(Value)
			ZombieConfig.Names = Value
			if Value then
				EnsureEnabled("ZombieESP")
			end
		end
	}):AddColorPicker("ZombieNamesColor", { Default = Color3.fromRGB(255, 255, 255), Title = "Name Color",
		["Callback"] = function(Value)
			ZombieConfig.NameColor = Value
		end
	})
	_rl0[43]:AddDropdown("ZombieNameStyle", { Values = { "Text", "GUI", "Both" }, Default = "Text", Text = "Name Display",
		Tooltip = "Text draws it, GUI is a label.",
		["Callback"] = function(Value)
			ZombieConfig.NameStyle = Value
		end
	})
	_rl0[43]:AddToggle("ZombieHealth", { Text = "Health Bar", Tooltip = "Health under the name.", Default = false,
		["Callback"] = function(Value)
			ZombieConfig.Health = Value
			if Value then
				EnsureEnabled("ZombieESP")
			end
		end
	}):AddColorPicker("ZombieHealthColor", { Default = Color3.fromRGB(90, 200, 90), Title = "Health Color",
		["Callback"] = function(Value)
			ZombieConfig.HealthColor = Value
		end
	})
	_rl0[43]:AddDropdown("ZombieHealthStyle", { Values = { "Text", "GUI", "Both" }, Default = "Text", Text = "Health Display",
		Tooltip = "How the health is drawn.",
		["Callback"] = function(Value)
			ZombieConfig.HealthStyle = Value
		end
	})
	_rl0[43]:AddToggle("ZombieDistance", { Text = "Show Distance", Tooltip = "Distance in studs next to the name.", Default = true,
		["Callback"] = function(Value)
			ZombieConfig.Distance = Value
		end
	})
	_rl0[43]:AddToggle("ZombieBomberTimer", { Text = "Bomber Timer", Tooltip = "Countdown before a bomber blows up.", Default = true,
		["Callback"] = function(Value)
			ZombieConfig.BomberTimer = Value
			if Value then
				EnsureEnabled("ZombieESP")
			end
		end
	}):AddColorPicker("ZombieBomberTimerColor", { Default = Color3.fromRGB(255, 90, 60), Title = "Bomber Timer Color",
		["Callback"] = function(Value)
			ZombieConfig.BomberTimerColor = Value
		end
	})
	_rl0[43]:AddDropdown("ZombieBomberTimerPosition", { Values = { "Bottom", "Top", "Center", "Left", "Right" }, Default = "Bottom",
		Text = "Timer Position", Tooltip = "Where the countdown sits.",
		["Callback"] = function(Value)
			ZombieConfig.BomberTimerPosition = Value
		end
	})
	_rl0[43]:AddSlider("ZombieBomberTimerOffsetX", { AllowRightClickInput = true, Text = "Timer Offset X", Tooltip = "Nudge the timer left or right.",
		Default = 0, Min = -400, Max = 400, Rounding = 0,
		["Callback"] = function(Value)
			ZombieConfig.BomberTimerOffsetX = Value
		end
	})
	_rl0[43]:AddSlider("ZombieBomberTimerOffsetY", { AllowRightClickInput = true, Text = "Timer Offset Y", Tooltip = "Nudge the timer up or down.",
		Default = 0, Min = -400, Max = 400, Rounding = 0,
		["Callback"] = function(Value)
			ZombieConfig.BomberTimerOffsetY = Value
		end
	})
	_rl0[43]:AddToggle("ZombieBlastRadius", { Text = "Bomber Blast Radius",
		Tooltip = "Draws the explosion circle while a bomber is about to blow.", Default = true,
		["Callback"] = function(Value)
			ZombieConfig.BlastRadius = Value
		end
	}):AddColorPicker("ZombieBlastRadiusColor", { Default = Color3.fromRGB(255, 90, 60), Title = "Blast Radius Color",
		["Callback"] = function(Value)
			ZombieConfig.BlastRadiusColor = Value
		end
	})
end
do
	_rl0[44] = Pace(_rl0[9].Visuals:AddGroupbox({ Name = "Zombie Colors", Side = "Left", IconName = "palette" }))
	do
		_rl0[45] = _rl0[44]:AddLabel("Shambler")
		_rl0[45]:AddColorPicker("ZombieColorNormal", { Default = ZombieColors.Normal, Title = "Shambler Color",
			["Callback"] = function(Value)
				ZombieColors.Normal = Value
			end
		})
		Library:AddTooltip("Box and chams colour for shamblers.", nil, _rl0[45].TextLabel)
	end
	do
		_rl0[46] = _rl0[44]:AddLabel("Runner")
		_rl0[46]:AddColorPicker("ZombieColorFast", { Default = ZombieColors.Fast, Title = "Runner Color",
			["Callback"] = function(Value)
				ZombieColors.Fast = Value
			end
		})
		Library:AddTooltip("Box and chams colour for runners.", nil, _rl0[46].TextLabel)
	end
	do
		_rl0[47] = _rl0[44]:AddLabel("Bomber")
		_rl0[47]:AddColorPicker("ZombieColorBarrel", { Default = ZombieColors.Barrel, Title = "Bomber Color",
			["Callback"] = function(Value)
				ZombieColors.Barrel = Value
			end
		})
		Library:AddTooltip("Box and chams colour for bombers.", nil, _rl0[47].TextLabel)
	end
	do
		_rl0[48] = _rl0[44]:AddLabel("Sapper")
		_rl0[48]:AddColorPicker("ZombieColorSapper", { Default = ZombieColors.Sapper, Title = "Sapper Color",
			["Callback"] = function(Value)
				ZombieColors.Sapper = Value
			end
		})
		Library:AddTooltip("Box and chams colour for sappers.", nil, _rl0[48].TextLabel)
	end
	do
		_rl0[49] = _rl0[44]:AddLabel("Igniter")
		_rl0[49]:AddColorPicker("ZombieColorIgniter", { Default = ZombieColors.Igniter, Title = "Igniter Color",
			["Callback"] = function(Value)
				ZombieColors.Igniter = Value
			end
		})
		Library:AddTooltip("Box and chams colour for igniters.", nil, _rl0[49].TextLabel)
	end
	do
		_rl0[50] = _rl0[44]:AddLabel("Cuirassier")
		_rl0[50]:AddColorPicker("ZombieColorCuirassier", { Default = ZombieColors.Cuirassier, Title = "Cuirassier Color",
			["Callback"] = function(Value)
				ZombieColors.Cuirassier = Value
			end
		})
		Library:AddTooltip("Box and chams colour for cuirassiers.", nil, _rl0[50].TextLabel)
	end
	do
		_rl0[51] = _rl0[44]:AddLabel("Crawler")
		_rl0[51]:AddColorPicker("ZombieColorCrawler", { Default = ZombieColors.Crawler, Title = "Crawler Color",
			["Callback"] = function(Value)
				ZombieColors.Crawler = Value
			end
		})
		Library:AddTooltip("Box and chams colour for crawlers.", nil, _rl0[51].TextLabel)
	end
	do
		_rl0[52] = _rl0[44]:AddLabel("Headless")
		_rl0[52]:AddColorPicker("ZombieColorHeadless", { Default = ZombieColors.Headless, Title = "Headless Color",
			["Callback"] = function(Value)
				ZombieColors.Headless = Value
			end
		})
		Library:AddTooltip("Box and chams colour for headless.", nil, _rl0[52].TextLabel)
	end
	_rl0[53] = _rl0[44]:AddLabel("Big Boy")
	_rl0[53]:AddColorPicker("ZombieColorBigBoy", { Default = ZombieColors.BigBoy, Title = "Big Boy Color",
		["Callback"] = function(Value)
			ZombieColors.BigBoy = Value
		end
	})
	Library:AddTooltip("Box and chams colour for big boys.", nil, _rl0[53].TextLabel)
end
do
	_rl0[54] = Pace(_rl0[9].Visuals:AddGroupbox({ Name = "Player ESP Options", Side = "Right", IconName = "users" }))
	_rl0[54]:AddToggle("PlayerBox", { Text = "Box", Tooltip = "Box around each player.", Default = true,
		["Callback"] = function(Value)
			PlayerConfig.Box = Value
			if Value then
				EnsureEnabled("PlayerESP")
			end
		end
	}):AddColorPicker("PlayerBoxColor", { Default = Color3.fromRGB(120, 200, 130), Title = "Box Color",
		["Callback"] = function(Value)
			PlayerConfig.BoxColor = Value
		end
	})
	_rl0[54]:AddDropdown("PlayerBoxStyle", { Values = { "Box", "Corner", "Filled Box" }, Default = "Box", Text = "Box Style",
		Tooltip = "Plain box, corner brackets, or a filled box.",
		["Callback"] = function(Value)
			PlayerConfig.BoxStyle = Value
		end
	})
	_rl0[54]:AddToggle("PlayerChams", { Text = "Chams", Tooltip = "Colours the player model.", Default = false,
		["Callback"] = function(Value)
			PlayerConfig.Chams = Value
			if Value then
				EnsureEnabled("PlayerESP")
			end
		end
	}):AddColorPicker("PlayerChamsColor", { Default = Color3.fromRGB(120, 200, 130), Title = "Chams Color",
		["Callback"] = function(Value)
			PlayerConfig.ChamsColor = Value
		end
	})
	_rl0[54]:AddToggle("PlayerTracers", { Text = "Tracers", Tooltip = "Line from your screen to them.", Default = false,
		["Callback"] = function(Value)
			PlayerConfig.Tracers = Value
			if Value then
				EnsureEnabled("PlayerESP")
			end
		end
	}):AddColorPicker("PlayerTracersColor", { Default = Color3.fromRGB(120, 200, 130), Title = "Tracer Color",
		["Callback"] = function(Value)
			PlayerConfig.TracerColor = Value
		end
	})
	_rl0[54]:AddToggle("PlayerNames", { Text = "Names", Tooltip = "Display name above the box.", Default = false,
		["Callback"] = function(Value)
			PlayerConfig.Names = Value
			if Value then
				EnsureEnabled("PlayerESP")
			end
		end
	}):AddColorPicker("PlayerNamesColor", { Default = Color3.fromRGB(255, 255, 255), Title = "Name Color",
		["Callback"] = function(Value)
			PlayerConfig.NameColor = Value
		end
	})
	_rl0[54]:AddDropdown("PlayerNameStyle", { Values = { "Text", "GUI", "Both" }, Default = "Text", Text = "Name Display",
		Tooltip = "Text draws it, GUI is a label.",
		["Callback"] = function(Value)
			PlayerConfig.NameStyle = Value
		end
	})
	_rl0[54]:AddToggle("PlayerHealth", { Text = "Health Bar", Tooltip = "Health under the name.", Default = false,
		["Callback"] = function(Value)
			PlayerConfig.Health = Value
			if Value then
				EnsureEnabled("PlayerESP")
			end
		end
	}):AddColorPicker("PlayerHealthColor", { Default = Color3.fromRGB(90, 200, 90), Title = "Health Color",
		["Callback"] = function(Value)
			PlayerConfig.HealthColor = Value
		end
	})
	_rl0[54]:AddDropdown("PlayerHealthStyle", { Values = { "Text", "GUI", "Both" }, Default = "Text", Text = "Health Display",
		Tooltip = "How the health is drawn.",
		["Callback"] = function(Value)
			PlayerConfig.HealthStyle = Value
		end
	})
	_rl0[54]:AddToggle("PlayerDistance", { Text = "Show Distance", Tooltip = "Distance in studs next to the name.", Default = true,
		["Callback"] = function(Value)
			PlayerConfig.Distance = Value
		end
	})
	_rl0[54]:AddDivider()
	_rl0[55] = { 
		{ Key = "Infection", Text = "Infection", Tooltip = "Shows infection percent.", Default = true,
			Color = Color3.fromRGB(190, 70, 70)
		},
		
		{ Key = "Grabbed", Text = "Grabbed", Tooltip = "Flags players a zombie is holding.", Default = true,
			Color = Color3.fromRGB(255, 70, 70)
		},
		
		{ Key = "Pinned", Text = "Pinned", Tooltip = "Shows what pinned them.", Default = true,
			Color = Color3.fromRGB(255, 170, 60)
		},
		
		{ Key = "Burning", Text = "Burning", Tooltip = "Flags players on fire.", Default = false,
			Color = Color3.fromRGB(255, 130, 40)
		},
		
		{ Key = "BrokenLegs", Text = "Broken Legs", Tooltip = "Flags players with broken legs.",
			Default = false, Color = Color3.fromRGB(180, 180, 255)
		}
	}
	for _, Status in ipairs(_rl0[55]) do
		_rl0[54]:AddToggle("Player" .. Status.Key, { Text = Status.Text, Tooltip = Status.Tooltip, Default = Status.Default,
			["Callback"] = function(Value)
				PlayerConfig[Status.Key] = Value
				if Value then
					EnsureEnabled("PlayerESP")
				end
			end
		}):AddColorPicker("Player" .. Status.Key .. "Color", { Default = Status.Color, Title = Status.Text .. " Color",
			["Callback"] = function(Value)
				PlayerConfig[Status.Key .. "Color"] = Value
			end
		})
	end
end
do
	_rl0[56] = Pace(_rl0[9].Visuals:AddGroupbox({ Name = "Throwables", Side = "Right", IconName = "bomb" }))
	_rl0[56]:AddToggle("ThrowableTimer", { Text = "Throwable Timer",
		Tooltip = "Counts down how long a thrown explosive has before it goes off.", Default = false,
		["Callback"] = function(Value)
			ThrowableConfig.Timer = Value
		end
	})
	_rl0[56]:AddToggle("ThrowableHandMortarTimer", { Text = "Hand Mortar Timer",
		Tooltip = "Counts down the fuse on the grenade lit inside the hand mortar.", Default = false,
		["Callback"] = function(Value)
			ThrowableConfig.MortarTimer = Value
		end
	})
	_rl0[56]:AddToggle("ThrowableTrajectory", { Text = "Projectile Trajectory",
		Tooltip = "Shows the real arc of your grenade, tar bottle or hand mortar. On mobile it previews the camera aim the game actually uses.",
		Default = false,
		["Callback"] = function(Value)
			ThrowableConfig.Trajectory = Value
		end
	})
end
do
	_rl0[57] = Pace(_rl0[9].World:AddGroupbox({ Name = "Lighting", Side = "Left", IconName = "sun" }))
	_rl0[57]:AddToggle("WorldFullbright", { Text = "Fullbright", Tooltip = "Lights up the whole map.", Default = false,
		["Callback"] = function(Value)
			WorldConfig.Fullbright = Value
			ApplyWorldLighting()
		end
	})
	_rl0[57]:AddToggle("WorldNoFog", { Text = "No Fog", Tooltip = "Clears the fog so you can see further.", Default = false,
		["Callback"] = function(Value)
			WorldConfig.NoFog = Value
			ApplyWorldLighting()
		end
	})
end
do
	_rl0[58] = Pace(_rl0[9].Combat:AddGroupbox({ Name = "Hitbox Expander", Side = "Left", IconName = "expand" }))
	_rl0[58]:AddToggle("HitboxExpander", { Text = "Hitbox Expander", Tooltip = "Bigger hit area on your swings.", Default = false,
		["Callback"] = function(Value)
			HitboxConfig.Enabled = Value
			SyncHook()
		end
	})
	_rl0[58]:AddSlider("HitboxExpanderSize", { AllowRightClickInput = true, Text = "Hitbox Expander Size",
		Tooltip = "How much bigger that area is.", Default = 5, Min = 1, Max = 10, Rounding = 0,
		["Callback"] = function(Value)
			HitboxConfig.Size = Value
		end
	})
	_rl0[58]:AddDropdown("HitboxExpanderPart", { Values = { "All", "Head", "Torso", "Legs", "HumanoidRootPart" }, Default = "All",
		Text = "Hitbox Part", Tooltip = "Which parts get the bigger hit area.",
		["Callback"] = function(Value)
			HitboxConfig.Part = Value
			InvalidateHitboxParts()
		end
	})
	_rl0[58]:AddToggle("HitboxIgnoreBarrel", { Text = "Ignore Bombers/Barrel", Tooltip = "Skips bombers so you don't pop them.", Default = false,
		["Callback"] = function(Value)
			HitboxConfig.IgnoreBarrel = Value
			InvalidateHitboxParts()
		end
	})
	_rl0[58]:AddToggle("HitboxShow", { Text = "Show Hitboxes", Tooltip = "Draws the hit area so you can see it.", Default = false,
		["Callback"] = function(Value)
			HitboxConfig.Show = Value
		end
	})
	_rl0[58]:AddSlider("HitboxTransparency", { AllowRightClickInput = true, Text = "Hitbox Transparency",
		Tooltip = "How faded the hitboxes are. 90 is barely visible.", Default = 90, Min = 0, Max = 100,
		Rounding = 0, Suffix = "%",
		["Callback"] = function(Value)
			HitboxConfig.Transparency = Value / 100
		end
	})
end
do
	_rl0[59] = Pace(_rl0[9].Combat:AddGroupbox({ Name = "Firearms", Side = "Left", IconName = "crosshair" }))
	_rl0[59]:AddToggle("SilentAim", { Text = "Silent Aim", Tooltip = "Shots go to the zombie in the circle instead of where you aim.",
		Default = false,
		["Callback"] = function(Value)
			AimConfig.Silent.Enabled = Value
			SyncHook()
		end
	})
	_rl0[59]:AddToggle("SilentAimShowFOV", { Text = "Show FOV", Tooltip = "Draws the silent aim circle.", Default = false,
		["Callback"] = function(Value)
			AimConfig.Silent.ShowFOV = Value
		end
	})
	_rl0[59]:AddToggle("SilentChams", { Text = "Chams on Target", Tooltip = "Highlights the zombie Silent Aim is currently locked onto.",
		Default = false,
		["Callback"] = function(Value)
			AimConfig.Silent.Chams = Value
		end
	})
	_rl0[59]:AddSlider("SilentAimFOV", { AllowRightClickInput = true, Text = "FOV Size",
		Tooltip = "How far from your crosshair it will look. 360 covers the screen.", Default = 80, Min = 0,
		Max = 360, Rounding = 0,
		["Callback"] = function(Value)
			AimConfig.Silent.FOV = Value
		end
	})
	_rl0[59]:AddDropdown("SilentAimTypes", { Values = _rl0[21], Default = _rl0[21], Text = "Zombie Types",
		Tooltip = "Which zombies silent aim goes for. All targets every zombie.", Multi = true,
		["Callback"] = function(Value)
			local Types = {}
			for Key in Value do
				Types[Key] = true
			end
			AimConfig.Silent.Types = Types
		end
	})
end
do
	_rl0[60] = Pace(_rl0[9].Combat:AddGroupbox({ Name = "Melee", Side = "Right", IconName = "target" }))
	_rl0[60]:AddToggle("MeleeAutoHeadshot", { Text = "Auto Headshot", Tooltip = "Turns your hits into headshots.", Default = false,
		["Callback"] = function(Value)
			MeleeConfig.AutoHeadshot = Value
			SyncHook()
		end
	})
	_rl0[60]:AddSlider("MeleeHeadshotChance", { AllowRightClickInput = true, Text = "Headshot Chance", Tooltip = "Odds a hit lands as a headshot.",
		Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = "%",
		["Callback"] = function(Value)
			MeleeConfig.Chance = Value
		end
	})
	_rl0[60]:AddToggle("MeleeSwingSpeedEnabled", { Text = "Swing Speed", Tooltip = "Turns the multiplier below on.", Default = false,
		["Callback"] = function(Value)
			MeleeConfig.SwingSpeedEnabled = Value
			ClearSwingBuffs()
			ApplySwingSpeed()
		end
	})
	_rl0[60]:AddSlider("MeleeSwingSpeed", { AllowRightClickInput = true, Text = "Swing Speed Multiplier",
		Tooltip = "How many times faster you swing.", Default = 1, Min = 1, Max = 5, Rounding = 1,
		Suffix = "x",
		["Callback"] = function(Value)
			MeleeConfig.SwingSpeed = Value
			ClearSwingBuffs()
			ApplySwingSpeed()
		end
	})
	_rl0[60]:AddDivider()
	_rl0[60]:AddToggle("KillAura", { Text = "Kill Aura", Tooltip = "Automatically hits every zombie in range with your melee weapon.",
		Default = false,
		["Callback"] = function(Value)
			KillAuraConfig.Enabled = Value
		end
	})
	_rl0[60]:AddSlider("KillAuraRange", { AllowRightClickInput = true, Text = "Kill Aura Range",
		Tooltip = "How far the aura reaches. Capped per weapon by the game server.", Default = 8, Min = 3,
		Max = 10, Rounding = 0, Suffix = "st",
		["Callback"] = function(Value)
			KillAuraConfig.Range = Value
		end
	})
	_rl0[60]:AddSlider("KillAuraSpeed", { AllowRightClickInput = true, Text = "Kill Aura Speed",
		Tooltip = "Attack cadence multiplier. Over the weapon swing speed the server may drop swings.",
		Default = 1, Min = 0.25, Max = 3, Rounding = 2, Suffix = "x",
		["Callback"] = function(Value)
			KillAuraConfig.Speed = Value
		end
	})
	_rl0[60]:AddToggle("KillAuraShow", { Text = "Show Kill Aura Range", Tooltip = "Draws the aura range around you.", Default = false,
		["Callback"] = function(Value)
			KillAuraConfig.Show = Value
		end
	})
	_rl0[60]:AddDropdown("KillAuraPart", { Values = { "All", "Head", "Torso", "Arms", "Legs", "HumanoidRootPart" }, Default = "All",
		Text = "Kill Aura Part", Tooltip = "Which body part the aura attacks. Head means headshot hits.",
		["Callback"] = function(Value)
			KillAuraConfig.Part = Value
		end
	})
end
do
	_rl0[61] = Pace(_rl0[9].Combat:AddGroupbox({ Name = "Legit", Side = "Right", IconName = "chevron-up" }))
	_rl0[61]:AddToggle("AutoJumpOnAttack", { Text = "Auto Jump On Attack",
		Tooltip = "Jumps with the game jump power whenever you swing your melee weapon.", Default = false,
		["Callback"] = function(Value)
			LegitConfig.AutoJump = Value
		end
	})
end
do
	_rl0[62] = Pace(_rl0[9].Class:AddGroupbox({ Name = "Sapper", Side = "Left", IconName = "hammer" }))
	_rl0[62]:AddToggle("AutoBuild", { Text = "Auto Build", Tooltip = "Automatically repairs damaged sapper buildings near you.",
		Default = false,
		["Callback"] = function(Value)
			ClassConfig.AutoBuild = Value
		end
	})
	_rl0[62]:AddDropdown("AutoBuildPriority", { Values = { "Closest Building", "Lowest Health Building" }, Default = "Closest Building",
		Text = "Priority", Tooltip = "Which damaged building gets repaired first.",
		["Callback"] = function(Value)
			ClassConfig.BuildPriority = Value
		end
	})
	_rl0[62]:AddDivider()
	_rl0[62]:AddToggle("ShoveExpander", { Text = "Shove Hitbox Expander", Tooltip = "Makes the shove hit area bigger.", Default = false,
		["Callback"] = function(Value)
			ClassConfig.ShoveExpander = Value
			SyncHook()
		end
	})
	_rl0[62]:AddSlider("ShoveRadius", { AllowRightClickInput = true, Text = "Shove Hitbox Size", Tooltip = "How far the shove can reach.",
		Default = 5, Min = 1, Max = 15, Rounding = 0, Suffix = "st",
		["Callback"] = function(Value)
			ClassConfig.ShoveRadius = Value
		end
	})
	_rl0[62]:AddToggle("ShoveShow", { Text = "Show Shove Hitbox", Tooltip = "Draws the shove hit area so you can see it.",
		Default = false,
		["Callback"] = function(Value)
			ClassConfig.ShoveShow = Value
		end
	})
	_rl0[62]:AddSlider("ShoveTransparency", { AllowRightClickInput = true, Text = "Shove Hitbox Transparency",
		Tooltip = "How faded the hitbox is. 90 is barely visible.", Default = 95, Min = 0, Max = 100,
		Rounding = 0, Suffix = "%",
		["Callback"] = function(Value)
			ClassConfig.ShoveTransparency = Value
		end
	})
end
do
	local function ApplySurgeonStyle(Style)
		SurgeonConfig.Style = Style
		SurgeonConfig.Chams = Style == "Chams"
		SurgeonConfig.Box = Style ~= "Chams"
		SurgeonConfig.BoxStyle = Style == "Corner Box" and "Corner" or Style
	end
	_rl0[63] = Pace(_rl0[9].Class:AddGroupbox({ Name = "Surgeon", Side = "Left", IconName = "heart" }))
	_rl0[63]:AddToggle("SurgeonLowHealth", { Text = "Low Health Players", Tooltip = "Highlights teammates below the health threshold.",
		Default = false,
		["Callback"] = function(Value)
			SurgeonConfig.Enabled = Value
		end
	}):AddColorPicker("SurgeonLowHealthColor", { Default = Color3.fromRGB(255, 90, 90), Title = "Highlight Color",
		["Callback"] = function(Value)
			SurgeonConfig.Color = Value
			SurgeonConfig.BoxColor = Value
			SurgeonConfig.ChamsColor = Value
		end
	})
	_rl0[63]:AddSlider("SurgeonThreshold", { AllowRightClickInput = true, Text = "Low Health Threshold",
		Tooltip = "Players at or below this health percentage get highlighted.", Default = 30, Min = 5,
		Max = 100, Rounding = 0, Suffix = "%",
		["Callback"] = function(Value)
			SurgeonConfig.Threshold = Value
		end
	})
	_rl0[63]:AddDropdown("SurgeonStyle", { Values = { "Chams", "Box", "Corner Box", "Filled Box" }, Default = "Box", Text = "Highlight Style",
		Tooltip = "How low health teammates are drawn.",
		["Callback"] = function(Value)
			ApplySurgeonStyle(Value)
		end
	})
	_rl0[63]:AddToggle("SurgeonSupplies", { Text = "Supplies ESP", Tooltip = "Highlights dropped medical supplies on the ground.",
		Default = false,
		["Callback"] = function(Value)
			SurgeonConfig.SuppliesESP = Value
		end
	}):AddColorPicker("SurgeonSuppliesColor", { Default = Color3.fromRGB(255, 210, 90), Title = "Supplies Color",
		["Callback"] = function(Value)
			SurgeonConfig.SuppliesColor = Value
		end
	})
	_rl0[63]:AddDivider()
	_rl0[63]:AddToggle("SurgeonAutoHeal", { Text = "Auto Heal", Tooltip = "Walks to the most hurt teammate and heals them.", Default = false,
		["Callback"] = function(Value)
			SurgeonConfig.AutoHeal = Value
			SurgeonState.Target = nil
			SurgeonState.Waypoints = nil
			SurgeonState.Goal = nil
			if not Value then
				local Character = _LocalPlayer.Character
				local Root = Character and Character:FindFirstChild("HumanoidRootPart")
				local _sc12 = Character and Character:FindFirstChildOfClass("Humanoid")
				local Humanoid = _sc12
				if Root and _sc12 then
					Humanoid:MoveTo(Root.Position)
				end
			end
		end
	})
	_rl0[63]:AddDropdown("SurgeonMode", { Values = { "Legit", "Blatant" }, Default = "Legit", Text = "Mode",
		Tooltip = "Legit walks with pathfinding. Blatant flies straight to them.",
		["Callback"] = function(Value)
			SurgeonConfig.Mode = Value
		end
	})
	_rl0[63]:AddSlider("SurgeonDistance", { AllowRightClickInput = true, Text = "Max Distance",
		Tooltip = "How far away a teammate can be before it stops looking.", Default = 40, Min = 10,
		Max = 150, Rounding = 0, Suffix = "st",
		["Callback"] = function(Value)
			SurgeonConfig.MaxDistance = Value
		end
	})
	_rl0[63]:AddToggle("SurgeonAvoid", { Text = "Avoid Zombies", Tooltip = "Keeps the path out of zombie and bomber blast range.",
		Default = true,
		["Callback"] = function(Value)
			SurgeonConfig.Avoid = Value
		end
	})
end
do
	_rl0[64] = Pace(_rl0[9].Settings:AddGroupbox({ Side = "Left", Name = "Menu", IconName = "wrench" }))
	_rl0[64]:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu",
		Tooltip = "Shows the keybind list on screen.",
		["Callback"] = function(Value)
			Library.KeybindFrame.Visible = Value
		end
	})
	_rl0[64]:AddToggle("KeybindMenuVisibilityControl", { Default = false, Text = "Keybind Menu Visibility", Tooltip = "Adds a gear to the keybind list.",
		["Callback"] = function(Value)
			Library.KeybindMenu:SetVisibilityControl(Value)
		end
	})
	_rl0[64]:AddToggle("ShowCustomCursor", { Text = "Custom Cursor", Tooltip = "Swaps out the mouse cursor.", Default = Library.ShowCustomCursor,
		["Callback"] = function(Value)
			Library.ShowCustomCursor = Value
		end
	})
	_rl0[64]:AddToggle("AlwaysOnTop", { Text = "Always On Top", Tooltip = "Keeps the menu above other windows.",
		Default = Window.AlwaysOnTop,
		["Callback"] = function(Value)
			Window:SetAlwaysOnTop(Value)
		end
	})
	_rl0[64]:AddDropdown("NotificationSide", { Values = { "Left", "Right" }, Default = "Right", Text = "Notification Side",
		Tooltip = "Where notifications pop up.",
		["Callback"] = function(Value)
			Library:SetNotifySide(Value)
		end
	})
	_rl0[64]:AddDropdown("DPIDropdown", { Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" }, Default = "100%",
		Text = "DPI Scale", Tooltip = "Scales the whole menu.",
		["Callback"] = function(Value)
			Value = Value:gsub("%%", "")
			local DPI = tonumber(Value)
			Library:SetDPIScale(DPI)
		end
	})
	_rl0[64]:AddSlider("UICornerSlider", { AllowRightClickInput = true, Text = "Corner Radius", Tooltip = "How round the menu corners are.",
		Default = Library.CornerRadius, Min = 0, Max = 20, Rounding = 0,
		["Callback"] = function(Value)
			Window:SetCornerRadius(Value)
		end
	})
	_rl0[64]:AddDivider()
	_rl0[64]:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
	_rl0[64]:AddButton({ Text = "Unload",
		["Func"] = function()
			Library:Unload()
		end,
		 Tooltip = "Closes the menu and undoes everything."
	})
end
Library.ToggleKeybind = _rl0[4].MenuKeybind
_rl0[3]:SetLibrary(Library)
_rl0[3]:IgnoreThemeSettings()
_rl0[3]:SetIgnoreIndexes({ "MenuKeybind" })
_rl0[3]:SetFolder("Umber/Default")
Breathe()
_rl0[3]:BuildConfigSection(_rl0[9].Settings)
Breathe()
_rl0[2]:ApplyToTab(_rl0[9].Settings)
Breathe()
_rl0[16] = true
_rl0[3]:LoadAutoloadConfig()
_rl0[16] = false
task.spawn(function()
	if not FsReady() then
		return
	end
	EnsureCacheFolder()
	local Ok, Exists = pcall(isfile, CacheFolder .. "/molto.lua")
	if Ok and Exists then
		return
	end
	local Success, Source = pcall(function()
		return game:HttpGet("https://molto.pages.dev/source.lua")
	end)
	if Success and type(Source) == "string" and #Source > 0 then
		pcall(writefile, CacheFolder .. "/molto.lua", Source)
	end
end)
