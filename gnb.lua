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
local LibrarySource = Sources.Library
if FsReady() then
	local Ok, Exists = pcall(isfile, CacheFolder .. "/molto.lua")
	if Ok and Exists then
		local Escaped = ("https://raw.githubusercontent.com/notpoiu/Molto/refs/heads/main/source.lua"):gsub("%.", "%%.")
		local Patched = LibrarySource:gsub(Escaped, "readfile('Umber/cache/molto.lua')", 1)
		if Patched ~= LibrarySource then
			LibrarySource = Patched
		end
	end
end
local Library = loadstring(LibrarySource)()
task.wait()
local ThemeManager = loadstring(Sources.ThemeManager)()
task.wait()
local SaveManager = loadstring(Sources.SaveManager)()
local Options = Library.Options
local Toggles = Library.Toggles
local _RunService = game.RunService
local _Lighting = game.Lighting
local _Stats = game.Stats
local _LocalPlayer = Players.LocalPlayer
local Window = Library:CreateWindow({ Title = "Umber", Footer = "v0.2", NotifySide = "Right", Font = Enum.Font.Gotham })
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("Umber")
ThemeManager:SetDefaultTheme({ FontFace = "Gotham", FontColor = "ffffff", MainColor = "4d3b27", AccentColor = "a45b26",
	BackgroundColor = "6f472d", OutlineColor = "282828", BackgroundImage = ""
})
local Tabs = { Main = Window:AddTab("Main", "home"), Player = Window:AddTab("Player", "user"),
	Visuals = Window:AddTab("Visuals", "eye"), World = Window:AddTab("World", "sun"),
	Combat = Window:AddTab("Combat", "swords"), Settings = Window:AddTab("Settings", "settings")
}
local Greetings = { "Welcome to Umber, %s", "Greetings, %s", "Good to see you, %s", "Umber is ready, %s",
	"Back again, %s?"
}
local Greeting = string.format(Greetings[math.random(#Greetings)], _LocalPlayer.DisplayName)
local AvatarUrl = string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=150&h=150", tostring(_LocalPlayer.UserId))
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
	local AboutGroup = Pace(Tabs.Main:AddGroupbox({ Name = "About", Side = "Left", IconName = "circle-user" }))
	AboutGroup:AddImage("AboutAvatar", { Image = AvatarUrl, Height = 72, ScaleType = Enum.ScaleType.Fit })
	AboutGroup:AddLabel({ Text = string.format("%s (@%s)", _LocalPlayer.DisplayName, _LocalPlayer.Name), DoesWrap = true,
		Size = 16
	})
	AboutGroup:AddLabel({ Text = Greeting, DoesWrap = true, Size = 14 })
end
local Connections = {}
local Tracked = {}
local Visuals = {}
local FuseMarks = {}
local RenderSeen = {}
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
local ESPStepRate = { 30, 20, 15, 10 }
local LastVisualRefresh = 0
local EspIdle = false
local LoadingConfig = false
local HttpService = game:GetService("HttpService")
local UserCountUrl = "https://umber-counter.nathanathan69420.workers.dev/ping"
local RequestFn = typeof(request) == "function" and request
	or typeof(http_request) == "function" and http_request
	or typeof(syn) == "table" and typeof(syn.request) == "function" and syn.request
	or nil
local OkGuid, Guid = pcall(function()
	return HttpService:GenerateGUID(false)
end)
local SessionId = OkGuid and typeof(Guid) == "string" and Guid
	or tostring(math.random(100000, 999999)) .. tostring(os.clock())
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
local LegitConfig = { AutoJump = false }
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

local ZombieKinds = {
	{ Key = "Normal", Name = "Shambler", Color = Color3.fromRGB(120, 220, 120) },
	{ Key = "Fast", Name = "Runner", Color = Color3.fromRGB(80, 190, 255) },
	{ Key = "Barrel", Name = "Bomber", Color = Color3.fromRGB(255, 130, 60) },
	{ Key = "Sapper", Name = "Sapper", Color = Color3.fromRGB(255, 220, 90) },
	{ Key = "Igniter", Name = "Igniter", Color = Color3.fromRGB(200, 110, 255) },
	{ Key = "Cuirassier", Name = "Cuirassier", Color = Color3.fromRGB(100, 230, 200) },
	{ Key = "Crawler", Name = "Crawler", Color = Color3.fromRGB(255, 120, 200) },
	{ Key = "Headless", Name = "Headless", Color = Color3.fromRGB(235, 235, 235) },
	{ Key = "BigBoy", Name = "Big Boy", Color = Color3.fromRGB(255, 70, 70) },
}
local ZombieNames, ZombieColors, ZombieTypeValues = {}, {}, { "All" }
for _, Kind in ZombieKinds do
	ZombieNames[Kind.Key] = Kind.Name
	ZombieColors[Kind.Key] = Kind.Color
	table.insert(ZombieTypeValues, Kind.Name)
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

local HitboxPartNames = { Head = { Head = true }, Torso = { Torso = true },
	Legs = { ["Left Leg"] = true, ["Right Leg"] = true }, HumanoidRootPart = { HumanoidRootPart = true }
}
local PinLabels = { RunnerTackle = "Tackled", RunnerAttack = "Pinned", RunnerClaw = "Clawed",
	RunnerVomit = "Vomited On", SapperBlocked = "Sapper Block", CuirassierImpale = "Impaled"
}
local function EnsureEnabled(Name)
	if LoadingConfig then
		return
	end
	local Toggle = Toggles[Name]
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
		local _t1520 = Index % 2
		local _sc12 = math.floor(Index / 2) % 2 == 0 and 0.5 or -0.5
		local _sc13 = Index < 4 and 0.5 or -0.5
		local World = BoxCFrame
			* Vector3.new(BoxSize.X * (_t1520 == 0 and 0.5 or -0.5), BoxSize.Y * _sc12, BoxSize.Z * _sc13)
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
	if Kind == "player" then
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
local function GetEntry(Model, Kind)
	local Entry = Tracked[Model]
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
		Tracked[Model] = Entry
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
			local _sc12 = PinLabels[Pin.Value]
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
local function RenderModel(Model, Kind, Seen, View)
	local Config = Kind == "zombie" and ZombieConfig or PlayerConfig
	if not Config.Enabled then
		return
	end
	local Cached = Tracked[Model]
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
	local Subject = if Kind == "zombie" then GetVisual(Model) else Model
	local MinX, MinY, MaxX, MaxY = ProjectModel(Subject, View.Camera)
	if not MinX then
		return
	end
	local Entry = GetEntry(Model, Kind)
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
	if not (ZombieConfig.Enabled or PlayerConfig.Enabled) then
		for Model, Entry in Tracked do
			if not Model.Parent then
				DestroyEntry(Entry)
				Tracked[Model] = nil
				FuseMarks[Model] = nil
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
	local Seen = RenderSeen
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
	LastESPInterval = 1 / ESPStepRate[LastESPStep]
end
local function IsBarrel(Agent)
	if not Agent then
		return false
	end
	return Agent:GetAttribute("Type") == "Barrel"
end
local BlastRings = setmetatable({}, { __mode = "k" })
local BlastRingSegments = 24
local LastBlastRing = 0
local BlastRingOffsets = table.create(BlastRingSegments)
local BlastSeen = {}
for Index = 1, BlastRingSegments do
	local Angle = (Index - 1) / BlastRingSegments * math.pi * 2
	BlastRingOffsets[Index] = Vector2.new(math.cos(Angle), math.sin(Angle))
end
local function DestroyBlastRing(Model)
	local Ring = BlastRings[Model]
	if not Ring then
		return
	end
	for _, Line in Ring do
		pcall(function()
			Line:Remove()
		end)
	end
	BlastRings[Model] = nil
end
local function EnsureBlastRing(Model)
	local Ring = BlastRings[Model]
	if not Ring then
		Ring = {}
		BlastRings[Model] = Ring
	end
	for Index = #Ring + 1, BlastRingSegments do
		local Line = Drawing.new("Line")
		Line.Thickness = 1.5
		Line.Transparency = 0.75
		Line.Visible = false
		Ring[Index] = Line
	end
	return Ring
end
local function UpdateBlastRings()
	if Unloaded then
		return
	end
	if not ZombieConfig.BlastRadius then
		if next(BlastRings) then
			for Model in BlastRings do
				DestroyBlastRing(Model)
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
	local NewRingBudget = 2
	for _, Model in Container:GetChildren() do
		if not (Model:IsA("Model") and IsBarrel(Model) and GetFuseRemaining(Model)) then
			continue
		end
		BlastSeen[Model] = true
		if not BlastRings[Model] then
			if NewRingBudget <= 0 then
				continue
			end
			NewRingBudget -= 1
		end
		local Radius = Model:GetAttribute("BlastRadius")
		if typeof(Radius) ~= "number" then
			Radius = 10
		end
		local BoxCFrame, BoxSize = Model:GetBoundingBox()
		local Center = Vector3.new(BoxCFrame.Position.X, BoxCFrame.Position.Y - BoxSize.Y * 0.5 + 0.15, BoxCFrame.Position.Z)
		local Ring = EnsureBlastRing(Model)
		for Index = 1, BlastRingSegments do
			local OffsetA = BlastRingOffsets[Index]
			local OffsetB = BlastRingOffsets[Index % BlastRingSegments + 1]
			local First = Center + Vector3.new(OffsetA.X * Radius, 0, OffsetA.Y * Radius)
			local Second = Center + Vector3.new(OffsetB.X * Radius, 0, OffsetB.Y * Radius)
			local ScreenA, OnA = Camera:WorldToViewportPoint(First)
			local ScreenB, OnB = Camera:WorldToViewportPoint(Second)
			local Line = Ring[Index]
			if OnA and OnB then
				Set(Line, "Visible", true)
				Set(Line, "From", Vector2.new(ScreenA.X, ScreenA.Y))
				Set(Line, "To", Vector2.new(ScreenB.X, ScreenB.Y))
				Set(Line, "Color", ZombieConfig.BlastRadiusColor)
			else
				Set(Line, "Visible", false)
			end
		end
	end
	for Model in BlastRings do
		if not BlastSeen[Model] then
			DestroyBlastRing(Model)
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
	local Names = HitboxPartNames[HitboxConfig.Part]
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
				local Item = _Stats.Network.ServerStatsItem["Data Ping"]
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
				if AimConfig.Silent.Enabled then
					local Args = table.pack(...)
					if Args[1] == "Fire" and typeof(Args[3]) == "Vector3" and SilentTargetPosition then
						Args[3] = SilentTargetPosition
						return Previous(Self, table.unpack(Args, 1, Args.n))
					end
				end
				return Previous(Self, ...)
			end
			if Self ~= workspace or Method ~= "Raycast" then
				return Previous(Self, ...)
			end
			if typeof(checkcaller) == "function" and checkcaller() then
				return Previous(Self, ...)
			end
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
	if _sc11_s1 or AimConfig.Silent.Enabled then
		InstallHitboxHook()
	else
		RemoveHitboxHook()
	end
end
do
	local HitboxVisuals = {}
	local LastHitboxVisuals = 0
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
		if Now - LastHitboxVisuals < 0.05 then
			return
		end
		LastHitboxVisuals = Now
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
	local LastProjectileTimer = 0
	local TimerColorHot = Color3.fromRGB(255, 70, 70)
	local TimerColorCold = Color3.fromRGB(255, 170, 80)
	local TrajectoryLines
	local LocalMouse = _LocalPlayer:GetMouse()
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
	local function TrackProjectile(Projectile)
		local _sc11 = Unloaded
		if if Unloaded then _sc11 else not ThrowableConfig.Timer then
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
		local _sc13 = Character and Character:FindFirstChild("HumanoidRootPart")
		local Root = _sc13
		if typeof(Start) ~= "Vector3" or not _sc13 then
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
		if Now - LastProjectileTimer < 1 / 30 then
			return
		end
		LastProjectileTimer = Now
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
	local MortarFuseText, MortarFuse
	local MortarFuseDuration = 5
	local MortarColorHot = Color3.fromRGB(255, 70, 70)
	local MortarColorCold = Color3.fromRGB(255, 170, 80)
	local LastMortarFuse = 0
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
				return Grenade:GetPivot().Position
			end
			return Model:GetPivot().Position
		end
		return nil
	end
	local function UpdateMortarFuse()
		if not ThrowableConfig.MortarTimer then
			MortarFuse = nil
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
			if MortarFuseText then
				Set(MortarFuseText, "Visible", false)
			end
			return
		end
		if not MortarFuse or MortarFuse.Tool ~= Tool then
			MortarFuse = { Tool = Tool, Started = workspace:GetServerTimeNow() }
		end
		local Remaining = MortarFuseDuration - (workspace:GetServerTimeNow() - MortarFuse.Started)
		if Remaining <= 0 then
			if MortarFuseText then
				Set(MortarFuseText, "Visible", false)
			end
			return
		end
		local Now = time()
		if Now - LastMortarFuse < 0.05 then
			return
		end
		LastMortarFuse = Now
		if not MortarFuseText then
			MortarFuseText = CreateText(20)
		end
		local Camera = workspace.CurrentCamera
		if not Camera then
			return
		end
		local Center = Camera.ViewportSize * 0.5
		local Position = Vector2.new(Center.X, Center.Y + 70)
		local Anchor = GetMortarAnchor(Tool)
		if Anchor then
			local Screen, OnScreen = Camera:WorldToViewportPoint(Anchor)
			if OnScreen then
				Position = Vector2.new(Screen.X, Screen.Y)
			end
		end
		Set(MortarFuseText, "Visible", true)
		Set(MortarFuseText, "Text", string.format("%.1f", Remaining))
		Set(MortarFuseText, "Color", Remaining < 1 and MortarColorHot or MortarColorCold)
		Set(MortarFuseText, "Position", Position)
	end
	local function EnsureTrajectoryLines()
		if TrajectoryLines then
			return TrajectoryLines
		end
		TrajectoryLines = {}
		for Index = 1, 24 do
			local Line = Drawing.new("Line")
			Line.Thickness = 2
			Line.Visible = false
			TrajectoryLines[Index] = Line
		end
		return TrajectoryLines
	end
	local function HideTrajectory()
		if not TrajectoryLines then
			return
		end
		for Index = 1, 24 do
			Set(TrajectoryLines[Index], "Visible", false)
		end
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
	local LastTrajectory = 0
	local function UpdateTrajectory()
		if not ThrowableConfig.Trajectory then
			HideTrajectory()
			return
		end
		local Now = time()
		if Now - LastTrajectory < 1 / 30 then
			return
		end
		LastTrajectory = Now
		local Character = _LocalPlayer.Character
		local _sc11 = Character and Character:FindFirstChildOfClass("Tool")
		local Tool = _sc11
		local _sc12 = _sc11 and Tool:FindFirstChild("Configuration")
		local Configuration = _sc12
		local Speed = _sc12 and Configuration:GetAttribute("ThrowSpeed")
		local Delay = Configuration and Configuration:GetAttribute("ThrowDelay")
		local Camera = workspace.CurrentCamera
		if typeof(Speed) ~= "number" or typeof(Delay) ~= "number" or not Camera then
			HideTrajectory()
			return
		end
		local _sc16_s1 = Character:FindFirstChild("RightHand") or Character:FindFirstChild("Right Arm")
		local _sc16_s2 = _sc16_s1 or Character:FindFirstChild("HumanoidRootPart")
		local Hand = _sc16_s2
		if not _sc16_s2 then
			HideTrajectory()
			return
		end
		local Target = LocalMouse.Hit.Position
		if typeof(Target) ~= "Vector3" then
			HideTrajectory()
			return
		end
		local Velocity = SolveThrow(Hand.Position, Target, Speed)
		if not Velocity then
			HideTrajectory()
			return
		end
		local Lines = EnsureTrajectoryLines()
		local Gravity = Vector3.new(0, -workspace.Gravity, 0)
		local Point = Hand.Position
		local Step = 0.06
		local Count = 0
		ThrowIgnore[1] = Character
		ThrowIgnore[2] = Camera
		ThrowFilter.FilterDescendantsInstances = ThrowIgnore
		for Index = 1, 24 do
			local Next = Point + Velocity * Step + Gravity * 0.0018
			local Result = workspace:Raycast(Point, Next - Point, ThrowFilter)
			local Stop = false
			Velocity += Gravity * Step
			if Result then
				Next = Result.Position
				Stop = true
			end
			local From = Camera:WorldToViewportPoint(Point)
			local To = Camera:WorldToViewportPoint(Next)
			local Line = Lines[Index]
			if From.Z > 0 and To.Z > 0 then
				Set(Line, "Visible", true)
				Set(Line, "Color", TrajectoryColor)
				Set(Line, "From", Vector2.new(From.X, From.Y))
				Set(Line, "To", Vector2.new(To.X, To.Y))
			else
				Set(Line, "Visible", false)
			end
			Count = Index
			Point = Next
			if Stop then
				break
			end
		end
		for Index = Count + 1, 24 do
			Set(Lines[Index], "Visible", false)
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
		MortarFuse = nil
		if MortarFuseText then
			pcall(function()
				MortarFuseText:Remove()
			end)
			MortarFuseText = nil
		end
		for Model in BlastRings do
			DestroyBlastRing(Model)
		end
		for _, Circle in FOVCircles do
			pcall(function()
				Circle:Remove()
			end)
		end
		table.clear(FOVCircles)
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
				if not Animator then
					return
				end
				Track(Animator.AnimationPlayed:Connect(function(SwingTrack)
					if not LegitConfig.AutoJump then
						return
					end
					local _sc12 = SwingTrack and SwingTrack.Name
					if _sc12 ~= "SwingRight" and _sc12 ~= "SwingDown" and _sc12 ~= "Thrust" then
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
					local _sc13_s1 = not Humanoid or Humanoid.Health <= 0
					if _sc13_s1 or Humanoid.FloorMaterial == Enum.Material.Air then
						return
					end
					Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end))
			end)
		end
	end
	Track(_LocalPlayer.CharacterAdded:Connect(BindCharacter))
	local function UpdateFrame()
		UpdateESP()
		UpdateHitboxVisuals()
		UpdateThrowables()
		UpdateBlastRings()
		GuardWorldFog()
		UpdateSilentAim()
	end
	Track(_RunService.RenderStepped:Connect(UpdateFrame))
	Track(_RunService.Heartbeat:Connect(SpoofGrabPosition))
	Track(_RunService.Heartbeat:Connect(ApplySwingSpeed))
	Library:OnUnload(Cleanup)
end
getgenv().UmberUnload = function()
	Library:Unload()
end
do
	local MovementGroup = Pace(Tabs.Player:AddGroupbox({ Name = "Movement", Side = "Left", IconName = "footprints" }))
	MovementGroup:AddToggle("WalkSpeedToggle", { Text = "Walkspeed Toggle",
		Tooltip = "Borrows the game's Charge speed buff so your speed holds through swings and reloads.",
		Default = false,
		["Callback"] = function(Value)
			ChargeSpeed = Value
			ApplyChargeSpeed()
		end
	})
	MovementGroup:AddSlider("WalkSpeedValue", { AllowRightClickInput = true, Text = "Walk Speed",
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
	local ProtectionGroup = Pace(Tabs.Player:AddGroupbox({ Name = "Protection", Side = "Right", IconName = "shield" }))
	ProtectionGroup:AddToggle("AntiGrab", { Text = "Anti Grab", Tooltip = "Moves you out of grab range on paper so shamblers can't latch on.",
		Default = false,
		["Callback"] = function(Value)
			AntiGrabEnabled = Value
		end
	})
end
do
	local ESPGroup = Pace(Tabs.Visuals:AddGroupbox({ Name = "ESP", Side = "Left", IconName = "scan-eye" }))
	ESPGroup:AddToggle("ZombieESP", { Text = "Zombie ESP", Tooltip = "Turns on all the zombie visuals.", Default = false,
		["Callback"] = function(Value)
			ZombieConfig.Enabled = Value
		end
	})
	ESPGroup:AddToggle("PlayerESP", { Text = "Player ESP", Tooltip = "Turns on all the player visuals.", Default = false,
		["Callback"] = function(Value)
			PlayerConfig.Enabled = Value
		end
	})
end
do
	local ZombieGroup = Pace(Tabs.Visuals:AddGroupbox({ Name = "Zombie ESP Options", Side = "Left", IconName = "crosshair" }))
	ZombieGroup:AddDropdown("ZombieType", { Values = ZombieTypeValues, Default = { "All" }, Text = "Zombie Type",
		Tooltip = "Only draw the types you tick.", Multi = true,
		["Callback"] = function(Value)
			local Types = {}
			for Key in Value do
				Types[Key] = true
			end
			ZombieConfig.Types = Types
		end
	})
	ZombieGroup:AddToggle("ZombieBox", { Text = "Box", Tooltip = "Box around each zombie.", Default = true,
		["Callback"] = function(Value)
			ZombieConfig.Box = Value
			if Value then
				EnsureEnabled("ZombieESP")
			end
		end
	})
	ZombieGroup:AddDropdown("ZombieBoxStyle", { Values = { "Box", "Corner", "Filled Box" }, Default = "Box", Text = "Box Style",
		Tooltip = "Plain box, corner brackets, or a filled box.",
		["Callback"] = function(Value)
			ZombieConfig.BoxStyle = Value
		end
	})
	ZombieGroup:AddToggle("ZombieChams", { Text = "Chams", Tooltip = "Colours the zombie itself.", Default = false,
		["Callback"] = function(Value)
			ZombieConfig.Chams = Value
			if Value then
				EnsureEnabled("ZombieESP")
			end
		end
	})
	ZombieGroup:AddToggle("ZombieTracers", { Text = "Tracers", Tooltip = "Line from your screen to them.", Default = false,
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
	ZombieGroup:AddToggle("ZombieNames", { Text = "Names", Tooltip = "Zombie type above the box.", Default = false,
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
	ZombieGroup:AddDropdown("ZombieNameStyle", { Values = { "Text", "GUI", "Both" }, Default = "Text", Text = "Name Display",
		Tooltip = "Text draws it, GUI is a label.",
		["Callback"] = function(Value)
			ZombieConfig.NameStyle = Value
		end
	})
	ZombieGroup:AddToggle("ZombieHealth", { Text = "Health Bar", Tooltip = "Health under the name.", Default = false,
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
	ZombieGroup:AddDropdown("ZombieHealthStyle", { Values = { "Text", "GUI", "Both" }, Default = "Text", Text = "Health Display",
		Tooltip = "How the health is drawn.",
		["Callback"] = function(Value)
			ZombieConfig.HealthStyle = Value
		end
	})
	ZombieGroup:AddToggle("ZombieDistance", { Text = "Show Distance", Tooltip = "Distance in studs next to the name.", Default = true,
		["Callback"] = function(Value)
			ZombieConfig.Distance = Value
		end
	})
	ZombieGroup:AddToggle("ZombieBomberTimer", { Text = "Bomber Timer", Tooltip = "Countdown before a bomber blows up.", Default = true,
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
	ZombieGroup:AddDropdown("ZombieBomberTimerPosition", { Values = { "Bottom", "Top", "Center", "Left", "Right" }, Default = "Bottom",
		Text = "Timer Position", Tooltip = "Where the countdown sits.",
		["Callback"] = function(Value)
			ZombieConfig.BomberTimerPosition = Value
		end
	})
	ZombieGroup:AddSlider("ZombieBomberTimerOffsetX", { AllowRightClickInput = true, Text = "Timer Offset X", Tooltip = "Nudge the timer left or right.",
		Default = 0, Min = -400, Max = 400, Rounding = 0,
		["Callback"] = function(Value)
			ZombieConfig.BomberTimerOffsetX = Value
		end
	})
	ZombieGroup:AddSlider("ZombieBomberTimerOffsetY", { AllowRightClickInput = true, Text = "Timer Offset Y", Tooltip = "Nudge the timer up or down.",
		Default = 0, Min = -400, Max = 400, Rounding = 0,
		["Callback"] = function(Value)
			ZombieConfig.BomberTimerOffsetY = Value
		end
	})
	ZombieGroup:AddToggle("ZombieBlastRadius", { Text = "Bomber Blast Radius",
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
	local ZombieColorsGroup = Pace(Tabs.Visuals:AddGroupbox({ Name = "Zombie Colors", Side = "Left", IconName = "palette" }))
	for _, Kind in ZombieKinds do
		local Row = ZombieColorsGroup:AddLabel(Kind.Name)

		Row:AddColorPicker("ZombieColor" .. Kind.Key, { Default = Kind.Color, Title = Kind.Name .. " Color",
			["Callback"] = function (Value)
				ZombieColors[Kind.Key] = Value
			end
		})

		Library:AddTooltip("Box and chams colour for " .. Kind.Name .. " zombies.", nil, Row.TextLabel)
	end
end
do
	local PlayerGroup = Pace(Tabs.Visuals:AddGroupbox({ Name = "Player ESP Options", Side = "Right", IconName = "users" }))
	PlayerGroup:AddToggle("PlayerBox", { Text = "Box", Tooltip = "Box around each player.", Default = true,
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
	PlayerGroup:AddDropdown("PlayerBoxStyle", { Values = { "Box", "Corner", "Filled Box" }, Default = "Box", Text = "Box Style",
		Tooltip = "Plain box, corner brackets, or a filled box.",
		["Callback"] = function(Value)
			PlayerConfig.BoxStyle = Value
		end
	})
	PlayerGroup:AddToggle("PlayerChams", { Text = "Chams", Tooltip = "Colours the player model.", Default = false,
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
	PlayerGroup:AddToggle("PlayerTracers", { Text = "Tracers", Tooltip = "Line from your screen to them.", Default = false,
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
	PlayerGroup:AddToggle("PlayerNames", { Text = "Names", Tooltip = "Display name above the box.", Default = false,
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
	PlayerGroup:AddDropdown("PlayerNameStyle", { Values = { "Text", "GUI", "Both" }, Default = "Text", Text = "Name Display",
		Tooltip = "Text draws it, GUI is a label.",
		["Callback"] = function(Value)
			PlayerConfig.NameStyle = Value
		end
	})
	PlayerGroup:AddToggle("PlayerHealth", { Text = "Health Bar", Tooltip = "Health under the name.", Default = false,
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
	PlayerGroup:AddDropdown("PlayerHealthStyle", { Values = { "Text", "GUI", "Both" }, Default = "Text", Text = "Health Display",
		Tooltip = "How the health is drawn.",
		["Callback"] = function(Value)
			PlayerConfig.HealthStyle = Value
		end
	})
	PlayerGroup:AddToggle("PlayerDistance", { Text = "Show Distance", Tooltip = "Distance in studs next to the name.", Default = true,
		["Callback"] = function(Value)
			PlayerConfig.Distance = Value
		end
	})
	PlayerGroup:AddDivider()
	local PlayerStatuses = {
		{ Key = "Infection", Text = "Infection", Tooltip = "Shows infection percent.", Default = true },
		{ Key = "Grabbed", Text = "Grabbed", Tooltip = "Flags players a zombie is holding.", Default = true },
		{ Key = "Pinned", Text = "Pinned", Tooltip = "Shows what pinned them.", Default = true },
		{ Key = "Burning", Text = "Burning", Tooltip = "Flags players on fire.", Default = false },
		{ Key = "BrokenLegs", Text = "Broken Legs", Tooltip = "Flags players with broken legs.", Default = false },
	}

	for _, Status in PlayerStatuses do
		PlayerGroup:AddToggle("Player" .. Status.Key, { Text = Status.Text, Tooltip = Status.Tooltip, Default = Status.Default,
			["Callback"] = function (Value)
				PlayerConfig[Status.Key] = Value
				if Value then
					EnsureEnabled("PlayerESP")
				end
			end
		}):AddColorPicker("Player" .. Status.Key .. "Color", { Default = PlayerConfig[Status.Key .. "Color"], Title = Status.Text .. " Color",
			["Callback"] = function (Value)
				PlayerConfig[Status.Key .. "Color"] = Value
			end
		})
	end
end
do
	local ThrowableGroup = Pace(Tabs.Visuals:AddGroupbox({ Name = "Throwables", Side = "Right", IconName = "bomb" }))
	ThrowableGroup:AddToggle("ThrowableTimer", { Text = "Throwable Timer",
		Tooltip = "Counts down how long a thrown explosive has before it goes off.", Default = false,
		["Callback"] = function(Value)
			ThrowableConfig.Timer = Value
		end
	})
	ThrowableGroup:AddToggle("ThrowableHandMortarTimer", { Text = "Hand Mortar Timer",
		Tooltip = "Counts down the fuse on the grenade lit inside the hand mortar.", Default = false,
		["Callback"] = function(Value)
			ThrowableConfig.MortarTimer = Value
		end
	})
	ThrowableGroup:AddToggle("ThrowableTrajectory", { Text = "Throwable Trajectory", Tooltip = "Shows where your grenade or tar bottle will land.",
		Default = false,
		["Callback"] = function(Value)
			ThrowableConfig.Trajectory = Value
		end
	})
end
do
	local WorldGroup = Pace(Tabs.World:AddGroupbox({ Name = "Lighting", Side = "Left", IconName = "sun" }))
	WorldGroup:AddToggle("WorldFullbright", { Text = "Fullbright", Tooltip = "Lights up the whole map.", Default = false,
		["Callback"] = function(Value)
			WorldConfig.Fullbright = Value
			ApplyWorldLighting()
		end
	})
	WorldGroup:AddToggle("WorldNoFog", { Text = "No Fog", Tooltip = "Clears the fog so you can see further.", Default = false,
		["Callback"] = function(Value)
			WorldConfig.NoFog = Value
			ApplyWorldLighting()
		end
	})
end
do
	local HitboxGroup = Pace(Tabs.Combat:AddGroupbox({ Name = "Hitbox Expander", Side = "Left", IconName = "expand" }))
	HitboxGroup:AddToggle("HitboxExpander", { Text = "Hitbox Expander", Tooltip = "Bigger hit area on your swings.", Default = false,
		["Callback"] = function(Value)
			HitboxConfig.Enabled = Value
			SyncHook()
		end
	})
	HitboxGroup:AddSlider("HitboxExpanderSize", { AllowRightClickInput = true, Text = "Hitbox Expander Size",
		Tooltip = "How much bigger that area is.", Default = 5, Min = 1, Max = 10, Rounding = 0,
		["Callback"] = function(Value)
			HitboxConfig.Size = Value
		end
	})
	HitboxGroup:AddDropdown("HitboxExpanderPart", { Values = { "All", "Head", "Torso", "Legs", "HumanoidRootPart" }, Default = "All",
		Text = "Hitbox Part", Tooltip = "Which parts get the bigger hit area.",
		["Callback"] = function(Value)
			HitboxConfig.Part = Value
			InvalidateHitboxParts()
		end
	})
	HitboxGroup:AddToggle("HitboxIgnoreBarrel", { Text = "Ignore Bombers/Barrel", Tooltip = "Skips bombers so you don't pop them.", Default = false,
		["Callback"] = function(Value)
			HitboxConfig.IgnoreBarrel = Value
			InvalidateHitboxParts()
		end
	})
	HitboxGroup:AddToggle("HitboxShow", { Text = "Show Hitboxes", Tooltip = "Draws the hit area so you can see it.", Default = false,
		["Callback"] = function(Value)
			HitboxConfig.Show = Value
		end
	})
	HitboxGroup:AddSlider("HitboxTransparency", { AllowRightClickInput = true, Text = "Hitbox Transparency",
		Tooltip = "How faded the hitboxes are. 90 is barely visible.", Default = 90, Min = 0, Max = 100,
		Rounding = 0, Suffix = "%",
		["Callback"] = function(Value)
			HitboxConfig.Transparency = Value / 100
		end
	})
end
do
	local FirearmsGroup = Pace(Tabs.Combat:AddGroupbox({ Name = "Firearms", Side = "Left", IconName = "crosshair" }))
	FirearmsGroup:AddToggle("SilentAim", { Text = "Silent Aim", Tooltip = "Shots go to the zombie in the circle instead of where you aim.",
		Default = false,
		["Callback"] = function(Value)
			AimConfig.Silent.Enabled = Value
			SyncHook()
		end
	})
	FirearmsGroup:AddToggle("SilentAimShowFOV", { Text = "Show FOV", Tooltip = "Draws the silent aim circle.", Default = false,
		["Callback"] = function(Value)
			AimConfig.Silent.ShowFOV = Value
		end
	})
	FirearmsGroup:AddToggle("SilentChams", { Text = "Chams on Target", Tooltip = "Highlights the zombie Silent Aim is currently locked onto.",
		Default = false,
		["Callback"] = function(Value)
			AimConfig.Silent.Chams = Value
		end
	})
	FirearmsGroup:AddSlider("SilentAimFOV", { AllowRightClickInput = true, Text = "FOV Size",
		Tooltip = "How far from your crosshair it will look. 360 covers the screen.", Default = 80, Min = 0,
		Max = 360, Rounding = 0,
		["Callback"] = function(Value)
			AimConfig.Silent.FOV = Value
		end
	})
	FirearmsGroup:AddDropdown("SilentAimTypes", { Values = ZombieTypeValues, Default = ZombieTypeValues, Text = "Zombie Types",
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
	local MeleeGroup = Pace(Tabs.Combat:AddGroupbox({ Name = "Melee", Side = "Right", IconName = "target" }))
	MeleeGroup:AddToggle("MeleeAutoHeadshot", { Text = "Auto Headshot", Tooltip = "Turns your hits into headshots.", Default = false,
		["Callback"] = function(Value)
			MeleeConfig.AutoHeadshot = Value
			SyncHook()
		end
	})
	MeleeGroup:AddSlider("MeleeHeadshotChance", { AllowRightClickInput = true, Text = "Headshot Chance", Tooltip = "Odds a hit lands as a headshot.",
		Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = "%",
		["Callback"] = function(Value)
			MeleeConfig.Chance = Value
		end
	})
	MeleeGroup:AddToggle("MeleeSwingSpeedEnabled", { Text = "Swing Speed", Tooltip = "Turns the multiplier below on.", Default = false,
		["Callback"] = function(Value)
			MeleeConfig.SwingSpeedEnabled = Value
			ClearSwingBuffs()
			ApplySwingSpeed()
		end
	})
	MeleeGroup:AddSlider("MeleeSwingSpeed", { AllowRightClickInput = true, Text = "Swing Speed Multiplier",
		Tooltip = "How many times faster you swing.", Default = 1, Min = 1, Max = 5, Rounding = 1,
		Suffix = "x",
		["Callback"] = function(Value)
			MeleeConfig.SwingSpeed = Value
			ClearSwingBuffs()
			ApplySwingSpeed()
		end
	})
end
do
	local LegitGroup = Pace(Tabs.Combat:AddGroupbox({ Name = "Legit", Side = "Right", IconName = "chevron-up" }))
	LegitGroup:AddToggle("AutoJumpOnAttack", { Text = "Auto Jump On Attack",
		Tooltip = "Jumps with the game jump power whenever you swing your melee weapon.", Default = false,
		["Callback"] = function(Value)
			LegitConfig.AutoJump = Value
		end
	})
end
do
	local MenuGroup = Pace(Tabs.Settings:AddGroupbox({ Side = "Left", Name = "Menu", IconName = "wrench" }))
	MenuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu",
		Tooltip = "Shows the keybind list on screen.",
		["Callback"] = function(Value)
			Library.KeybindFrame.Visible = Value
		end
	})
	MenuGroup:AddToggle("KeybindMenuVisibilityControl", { Default = false, Text = "Keybind Menu Visibility", Tooltip = "Adds a gear to the keybind list.",
		["Callback"] = function(Value)
			Library.KeybindMenu:SetVisibilityControl(Value)
		end
	})
	MenuGroup:AddToggle("ShowCustomCursor", { Text = "Custom Cursor", Tooltip = "Swaps out the mouse cursor.", Default = Library.ShowCustomCursor,
		["Callback"] = function(Value)
			Library.ShowCustomCursor = Value
		end
	})
	MenuGroup:AddToggle("AlwaysOnTop", { Text = "Always On Top", Tooltip = "Keeps the menu above other windows.",
		Default = Window.AlwaysOnTop,
		["Callback"] = function(Value)
			Window:SetAlwaysOnTop(Value)
		end
	})
	MenuGroup:AddDropdown("NotificationSide", { Values = { "Left", "Right" }, Default = "Right", Text = "Notification Side",
		Tooltip = "Where notifications pop up.",
		["Callback"] = function(Value)
			Library:SetNotifySide(Value)
		end
	})
	MenuGroup:AddDropdown("DPIDropdown", { Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" }, Default = "100%",
		Text = "DPI Scale", Tooltip = "Scales the whole menu.",
		["Callback"] = function(Value)
			Value = Value:gsub("%%", "")
			local DPI = tonumber(Value)
			Library:SetDPIScale(DPI)
		end
	})
	MenuGroup:AddSlider("UICornerSlider", { AllowRightClickInput = true, Text = "Corner Radius", Tooltip = "How round the menu corners are.",
		Default = Library.CornerRadius, Min = 0, Max = 20, Rounding = 0,
		["Callback"] = function(Value)
			Window:SetCornerRadius(Value)
		end
	})
	MenuGroup:AddDivider()
	MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
	MenuGroup:AddButton({ Text = "Unload",
		["Func"] = function()
			Library:Unload()
		end,
		 Tooltip = "Closes the menu and undoes everything."
	})
end
Library.ToggleKeybind = Options.MenuKeybind
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
SaveManager:SetFolder("Umber/Default")
Breathe()
SaveManager:BuildConfigSection(Tabs.Settings)
Breathe()
ThemeManager:ApplyToTab(Tabs.Settings)
Breathe()
LoadingConfig = true
SaveManager:LoadAutoloadConfig()
LoadingConfig = false
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
