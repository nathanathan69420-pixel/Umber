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
_rl0[1] = {}
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
					_rl0[1][Name] = Source
					Pending -= 1
					return
				end
			end
		end
		task.spawn(function()
			local Success, Result = pcall(game.HttpGet, game, Url)
			if Success then
				_rl0[1][Name] = Result
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
	local _sc_s1 = not _rl0[1].Library or not _rl0[1].ThemeManager
	if _sc_s1 or not _rl0[1].SaveManager then
		warn("Umber: could not download Obsidian.")
		return
	end
end
_rl0[2] = _rl0[1].Library
if FsReady() then
	local Ok, Exists = pcall(isfile, CacheFolder .. "/molto.lua")
	if Ok and Exists then
		local Escaped = ("https://raw.githubusercontent.com/notpoiu/Molto/refs/heads/main/source.lua"):gsub("%.", "%%.")
		local Patched = _rl0[2]:gsub(Escaped, "readfile('Umber/cache/molto.lua')", 1)
		if Patched ~= _rl0[2] then
			_rl0[2] = Patched
		end
	end
end
local Library = loadstring(_rl0[2])()
task.wait()
_rl0[3] = loadstring(_rl0[1].ThemeManager)()
task.wait()
_rl0[4] = loadstring(_rl0[1].SaveManager)()
_rl0[5] = Library.Options
local LibraryToggles = Library.Toggles
_rl0[6] = game.RunService
local Lighting = game.Lighting
_rl0[7] = game.Stats
_rl0[8] = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
getgenv().UmberBuild = "1121-1831"
_rl0[9] = Library:CreateWindow({ Title = "Umber", Footer = "v0.4", NotifySide = "Right", Font = Enum.Font.Gotham })
_rl0[3]:SetLibrary(Library)
_rl0[3]:SetFolder("Umber")
_rl0[3]:SetDefaultTheme({ FontFace = "Gotham", FontColor = "ffffff", MainColor = "4d3b27", AccentColor = "a45b26",
	BackgroundColor = "6f472d", OutlineColor = "282828", BackgroundImage = ""
})
_rl0[10] = { Main = _rl0[9]:AddTab("Main", "home"), Player = _rl0[9]:AddTab("Player", "user"),
	Visuals = _rl0[9]:AddTab("Visuals", "eye"), Misc = _rl0[9]:AddTab("Misc", "sun"),
	Combat = _rl0[9]:AddTab("Combat", "swords"), Class = _rl0[9]:AddTab("Class Features", "hammer"),
	Settings = _rl0[9]:AddTab("Settings", "settings")
}
_rl0[11] = { "Welcome to Umber, %s", "Greetings, %s", "Good to see you, %s", "Umber is ready, %s",
	"Back again, %s?"
}
_rl0[12] = string.format(_rl0[11][math.random(#_rl0[11])], LocalPlayer.DisplayName)
_rl0[13] = string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=150&h=150", tostring(LocalPlayer.UserId))
_rl0[14] = 0
local function Breathe()
	local Now = os.clock()
	if Now - _rl0[14] < 0.02 then
		return
	end
	_rl0[14] = Now
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
	local AboutGroup = Pace(_rl0[10].Main:AddGroupbox({ Name = "About", Side = "Left", IconName = "circle-user" }))
	AboutGroup:AddImage("AboutAvatar", { Image = _rl0[13], Height = 72, ScaleType = Enum.ScaleType.Fit })
	AboutGroup:AddLabel({ Text = string.format("%s (@%s)", LocalPlayer.DisplayName, LocalPlayer.Name), DoesWrap = true,
		Size = 16
	})
	AboutGroup:AddLabel({ Text = _rl0[12], DoesWrap = true, Size = 14 })
end
local Connections = {}
local Tracked = {}
local SurgeonTracked = {}
local Visuals = {}
local FuseMarks = {}
_rl0[15] = {}
_rl0[16] = {}
local SupplyHighlights = setmetatable({}, { __mode = "k" })
_rl0[17] = { Camera = nil, Position = Vector3.new(), Look = Vector3.new(), Viewport = Vector2.new(), Now = 0 }
local ChargeSpeed = false
local ChargeValue = 55
local Unloaded = false
_rl0[18] = 1 / 60
local VisualAccumulator = 0
_rl0[19] = 0
local EspIdle = false
_rl0[20] = false
_rl0[21] = { "ThrowSpeed", "ThrowPower", "ProjectileSpeed", "LaunchSpeed", "MuzzleVelocity", "GrenadeSpeed" }
_rl0[22] = { "HasFuse", "FuseTimer", "NumFuseBones", "NoUnderhand" }
_rl0[23] = { ["Hand Mortar"] = true, ["Tar Bottle"] = true, Grenade = true, ["Improved Grenade"] = true }
_rl0[24] = 5
_rl0[25] = 0.05
local DangerColor = Color3.fromRGB(255, 70, 70)
_rl0[26] = Color3.fromRGB(255, 170, 80)
_rl0[27] = LocalPlayer:GetMouse()
local HitboxConfig = { Enabled = false, Size = 5, Part = "All", IgnoreBarrel = false, Show = false, Transparency = 0.9 }
local MeleeConfig = { AutoHeadshot = false, Chance = 100, SwingSpeed = 1, SwingSpeedEnabled = false }
_rl0[28] = { AutoJump = false }
local ClassConfig = { AutoBuild = false, BuildPriority = "Closest Building", ShoveExpander = false, ShoveRadius = 5,
	ShoveShow = false, ShoveTransparency = 95, AutoPlay = false
}
local MusicianState = { Instrument = nil, Tool = nil, Beat = nil, NextScan = 0 }
local ThrowableConfig = { Timer = false, MortarTimer = false, Trajectory = false }
_rl0[29] = { NoRecoil = false }
local PanicConfig = { Enabled = false, Saved = {} }
_rl0[30] = { "SilentAim", "HitboxExpander", "MeleeAutoHeadshot", "MeleeSwingSpeedEnabled", "ShoveExpander" }
local AimConfig = { 
	Silent = { Enabled = false,
		Types = { Shambler = true, Runner = true, Bomber = true, Sapper = true, Igniter = true, Cuirassier = true,
			Crawler = true, Headless = true, ["Big Boy"] = true
		},
		 FOV = 80, ShowFOV = false, Chams = false
	}
}
local WorldConfig = { Fullbright = false, NoFog = false }
local MiscConfig = { NoFallDamage = false, AntiBrokenLegs = false, Waypoints = false,
	WaypointColor = Color3.fromRGB(120, 200, 255)
}
local ZombieConfig = { Enabled = false, Types = { All = true }, Box = true, BoxStyle = "Box",
	BoxColor = Color3.fromRGB(164, 91, 38), Chams = false, ChamsColor = Color3.fromRGB(200, 80, 40),
	Tracers = false, TracerColor = Color3.fromRGB(164, 91, 38), Names = false,
	NameColor = Color3.fromRGB(255, 255, 255), NameStyle = "Text", Health = false,
	HealthColor = Color3.fromRGB(235, 235, 235), HealthStyle = "Both", Distance = true,
	BomberTimer = true, BomberTimerColor = Color3.fromRGB(255, 90, 60), BomberTimerPosition = "Bottom",
	BomberTimerOffsetX = 0, BomberTimerOffsetY = 0, BlastRadius = true,
	BlastRadiusColor = Color3.fromRGB(255, 90, 60)
}
_rl0[31] = { { Key = "Normal", Display = "Shambler", Color = Color3.fromRGB(120, 220, 120) },
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
_rl0[32] = {}
_rl0[33] = { "All" }
for _, Kind in ipairs(_rl0[31]) do
	ZombieColors[Kind.Key] = Kind.Color
	_rl0[32][Kind.Key] = Kind.Display
	table.insert(_rl0[33], Kind.Display)
end
local PlayerConfig = { Enabled = false, Box = true, BoxColor = Color3.fromRGB(120, 200, 130), Chams = false,
	ChamsColor = Color3.fromRGB(120, 200, 130), Tracers = false,
	TracerColor = Color3.fromRGB(120, 200, 130), Names = false,
	NameColor = Color3.fromRGB(255, 255, 255), NameStyle = "Text", Health = false,
	HealthColor = Color3.fromRGB(235, 235, 235), HealthStyle = "Both", Distance = true, Infection = true,
	InfectionColor = Color3.fromRGB(190, 70, 70), Grabbed = true,
	GrabbedColor = Color3.fromRGB(255, 70, 70), Pinned = true,
	PinnedColor = Color3.fromRGB(255, 170, 60), Burning = false,
	BurningColor = Color3.fromRGB(255, 130, 40), BrokenLegs = false,
	BrokenLegsColor = Color3.fromRGB(180, 180, 255), BoxStyle = "Box", Target = "Other Players",
	Alerts = false
}
local SurgeonConfig = { Enabled = false, Threshold = 30, Color = Color3.fromRGB(255, 90, 90), Box = true,
	BoxColor = Color3.fromRGB(255, 90, 90), BoxStyle = "Box", Chams = false,
	ChamsColor = Color3.fromRGB(255, 90, 90), SuppliesESP = false,
	SuppliesColor = Color3.fromRGB(255, 210, 90), AutoHeal = false, Mode = "Legit", MaxDistance = 40,
	Avoid = true
}
_rl0[34] = { Head = { Head = true }, Torso = { Torso = true },
	Legs = { ["Left Leg"] = true, ["Right Leg"] = true }, HumanoidRootPart = { HumanoidRootPart = true }
}
_rl0[35] = { RunnerTackle = "Tackled", RunnerAttack = "Pinned", RunnerClaw = "Clawed",
	RunnerVomit = "Vomited On", SapperBlocked = "Sapper Block", CuirassierImpale = "Impaled"
}
local WorldOriginal = { Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
	Brightness = Lighting.Brightness, FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd
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
		FogRestore.Start = Lighting.FogStart
		FogRestore.End = Lighting.FogEnd
	end
	if Lighting.FogStart ~= 0 then
		Lighting.FogStart = 0
	end
	if Lighting.FogEnd ~= 100000 then
		Lighting.FogEnd = 100000
	end
	local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
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
	Lighting.FogStart = FogRestore.Start
	Lighting.FogEnd = FogRestore.End
	FogCaptured = false
	for Atmosphere, Entry in AtmosphereOriginal do
		if Atmosphere.Parent then
			Atmosphere.Density = Entry.Density
			Atmosphere.Haze = Entry.Haze
		end
	end
	table.clear(AtmosphereOriginal)
end
local ApplyingWorld = false
local function ApplyWorldLighting()
	if Unloaded then
		return
	end
	ApplyingWorld = true
	if WorldConfig.Fullbright then
		Lighting.Ambient = Color3.new(1, 1, 1)
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
		Lighting.Brightness = 3
	else
		Lighting.Ambient = WorldOriginal.Ambient
		Lighting.OutdoorAmbient = WorldOriginal.OutdoorAmbient
		Lighting.Brightness = WorldOriginal.Brightness
	end
	if WorldConfig.NoFog then
		ClearFog()
	else
		RestoreFog()
	end
	ApplyingWorld = false
end
local function RestoreWorldLighting()
	ApplyingWorld = true
	Lighting.Ambient = WorldOriginal.Ambient
	Lighting.OutdoorAmbient = WorldOriginal.OutdoorAmbient
	Lighting.Brightness = WorldOriginal.Brightness
	RestoreFog()
	ApplyingWorld = false
end
do
	local function ForceWorldLighting()
		if Unloaded or ApplyingWorld then
			return
		end
		ApplyingWorld = true
		if WorldConfig.Fullbright then
			if Lighting.Ambient ~= Color3.new(1, 1, 1) then
				Lighting.Ambient = Color3.new(1, 1, 1)
			end
			if Lighting.OutdoorAmbient ~= Color3.new(1, 1, 1) then
				Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
			end
			if Lighting.Brightness ~= 3 then
				Lighting.Brightness = 3
			end
		end
		if WorldConfig.NoFog then
			ClearFog()
		end
		ApplyingWorld = false
	end
	local AtmosphereWatched = setmetatable({}, { __mode = "k" })
	local function WatchAtmosphere()
		local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
		if not Atmosphere or AtmosphereWatched[Atmosphere] then
			return
		end
		AtmosphereWatched[Atmosphere] = true
		table.insert(Connections, Atmosphere:GetPropertyChangedSignal("Density"):Connect(ForceWorldLighting))
		table.insert(Connections, Atmosphere:GetPropertyChangedSignal("Haze"):Connect(ForceWorldLighting))
	end
	for _, Property in ipairs({ "Ambient", "OutdoorAmbient", "Brightness", "FogStart", "FogEnd" }) do
		table.insert(Connections, Lighting:GetPropertyChangedSignal(Property):Connect(ForceWorldLighting))
	end
	table.insert(Connections, Lighting.ChildAdded:Connect(function(Child)
		if Child:IsA("Atmosphere") then
			WatchAtmosphere()
			ForceWorldLighting()
		end
	end))
	WatchAtmosphere()
end
_rl0[36] = 0
local function GuardWorldFog()
	local WorldOverridden = Unloaded
	if not Unloaded then
		WorldOverridden = not (WorldConfig.NoFog or WorldConfig.Fullbright)
	end
	if WorldOverridden then
		return
	end
	local Now = time()
	if Now - _rl0[36] < 0.25 then
		return
	end
	_rl0[36] = Now
	if WorldConfig.Fullbright then
		Lighting.Ambient = Color3.new(1, 1, 1)
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
		Lighting.Brightness = 3
	end
	if WorldConfig.NoFog then
		ClearFog()
	end
end
local function EnsureEnabled(Name)
	if _rl0[20] then
		return
	end
	local Toggle = LibraryToggles[Name]
	if Toggle and not Toggle.Value then
		Toggle:SetValue(true)
	end
end
local function Track(Connection)
	table.insert(Connections, Connection)
	return Connection
end
local SuppressedConnections = {}
local function ConnectionSource(Connection)
	local Ok, Source = pcall(function()
		return debug.info(Connection.Function, "s")
	end)
	if Ok and type(Source) == "string" then
		return Source
	end
	return nil
end
local function SuppressConnection(Signal, Needle)
	if typeof(getconnections) ~= "function" then
		return
	end
	for _, Connection in ipairs(getconnections(Signal)) do
		local Source = ConnectionSource(Connection)
		if Source and string.find(Source, Needle, 1, true) and Connection.Enabled then
			pcall(function()
				Connection:Disable()
			end)
			table.insert(SuppressedConnections, Connection)
		end
	end
end
local function RestoreSuppressed()
	for _, Connection in ipairs(SuppressedConnections) do
		pcall(function()
			Connection:Enable()
		end)
	end
	table.clear(SuppressedConnections)
end
local RecoilSuppressed = {}
local function SetNoRecoil(Enabled)
	if typeof(getconnections) ~= "function" then
		return
	end
	if not Enabled then
		for _, Connection in ipairs(RecoilSuppressed) do
			pcall(function()
				Connection:Enable()
			end)
		end
		table.clear(RecoilSuppressed)
		return
	end
	local Event = game:GetService("ReplicatedStorage"):FindFirstChild("RecoilEvent")
	if not Event or not Event:IsA("BindableEvent") then
		return
	end
	for _, Connection in ipairs(getconnections(Event.Event)) do
		if Connection.Enabled then
			pcall(function()
				Connection:Disable()
			end)
			table.insert(RecoilSuppressed, Connection)
		end
	end
end
local function ApplyCharacterGuards(Restore)
	if Restore ~= false then
		RestoreSuppressed()
	end
	if Unloaded then
		return
	end
	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local UserStates = Character and Character:FindFirstChild("UserStates")
	if MiscConfig.NoFallDamage and Humanoid then
		SuppressConnection(Humanoid.FreeFalling, "LandingSystem")
	end
	if MiscConfig.AntiBrokenLegs and UserStates then
		local BrokenLegs = UserStates:FindFirstChild("BrokenLegs")
		if BrokenLegs then
			SuppressConnection(BrokenLegs.Changed, "StateManagerComponent")
			SuppressConnection(BrokenLegs:GetAttributeChangedSignal("Impaled"), "StateManagerComponent")
		end
	end
end
Track(LocalPlayer.CharacterAdded:Connect(function()
	task.delay(0.8, ApplyCharacterGuards)
end))
do
	local SpeedModifier
	_rl0[69] = Drawing.Fonts and Drawing.Fonts.Plex or 2
	local TextBase = setmetatable({}, { __mode = "k" })
	local EspScale = 1
	_rl0[70] = Vector2.new(-1, -1)
	local function ComputeEspScale()
		local Camera = workspace.CurrentCamera
		local _sc1 = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
		local Viewport = _sc1
		local Scale = math.clamp(720 / math.max(_sc1.Y, 1), 1, 1.6)
		if game:GetService("UserInputService").TouchEnabled then
			Scale = math.max(Scale, 1.5)
		end
		return Scale, Viewport
	end
	local function RefreshEspScale()
		local Scale, Viewport = ComputeEspScale()
		if Scale == EspScale and Viewport == _rl0[70] then
			return EspScale
		end
		EspScale = Scale
		_rl0[70] = Viewport
		for Text, Base in TextBase do
			pcall(function()
				Text.Size = math.floor(Base * Scale + 0.5)
			end)
		end
		return EspScale
	end
	local function Scaled(Value)
		return math.floor(Value * EspScale + 0.5)
	end
	local function HealthTint(Fraction)
		local Green = Color3.fromRGB(90, 205, 105)
		local Amber = Color3.fromRGB(240, 190, 70)
		local Red = Color3.fromRGB(230, 70, 70)
		if Fraction >= 0.5 then
			return Amber:Lerp(Green, (Fraction - 0.5) * 2)
		end
		return Red:Lerp(Amber, Fraction * 2)
	end
	local WaypointArrow = Drawing.new("Triangle")
	WaypointArrow.Filled = true
	WaypointArrow.Thickness = 1
	WaypointArrow.Visible = false
	local WaypointText = Drawing.new("Text")
	TextBase[WaypointText] = 12
	WaypointText.Size = Scaled(12)
	WaypointText.Font = _rl0[69]
	WaypointText.Center = true
	WaypointText.Outline = true
	WaypointText.OutlineColor = Color3.new(0, 0, 0)
	WaypointText.Visible = false
	local WaypointDist = Drawing.new("Text")
	TextBase[WaypointDist] = 10
	WaypointDist.Size = Scaled(10)
	WaypointDist.Font = _rl0[69]
	WaypointDist.Center = true
	WaypointDist.Outline = true
	WaypointDist.OutlineColor = Color3.new(0, 0, 0)
	WaypointDist.Transparency = 1
	WaypointDist.Visible = false
	_rl0[40] = 0
	_rl0[38] = {}
	local function ObjectiveGameplay()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local GameStates = ReplicatedStorage:FindFirstChild("GameStates")
		return GameStates and GameStates:FindFirstChild("Gameplay")
	end
	local function ObjectiveLabel()
		local Gameplay = ObjectiveGameplay()
		local _sc1 = Gameplay and Gameplay:FindFirstChild("Objective")
		local Objective = _sc1
		if _sc1 and Objective:IsA("StringValue") and Objective.Value ~= "" then
			return Objective.Value
		end
		return "Objective"
	end
	local function ObjectiveTarget()
		local Gameplay = ObjectiveGameplay()
		if not Gameplay then
			return nil
		end
		local Objective = Gameplay:FindFirstChild("Objective")
		local _sc1 = Objective and Objective:FindFirstChild("HighlightedObject")
		local Highlighted = _sc1
		local _sc2 = _sc1 and Highlighted:IsA("ObjectValue") and Highlighted.Value
		local Target = _sc2
		if not _sc2 then
			local Anyways = Gameplay:FindFirstChild("UseCAnyways")
			local _sc3 = Anyways and Anyways:FindFirstChild("ObjectToTarget")
			local ToTarget = _sc3
			Target = _sc3 and ToTarget:IsA("ObjectValue") and ToTarget.Value
		end
		return Target
	end
	local function ObjectivePosition(Target)
		if not Target then
			return nil
		end
		if Target:IsA("BasePart") then
			return Target.Position
		end
		if Target:IsA("Model") then
			local Primary = Target.PrimaryPart
			if Primary then
				return Primary.Position
			end
			local Ok, Center = pcall(function()
				return Target:GetBoundingBox().Position
			end)
			if Ok then
				return Center
			end
		end
		local Part = Target:FindFirstChildWhichIsA("BasePart", true)
		return Part and Part.Position
	end
	local function UpdateWaypoints()
		WaypointArrow.Visible = false
		WaypointText.Visible = false
		WaypointDist.Visible = false
		if not MiscConfig.Waypoints or Unloaded then
			return
		end
		local Character = LocalPlayer.Character
		local _sc1 = Character and Character:FindFirstChild("HumanoidRootPart")
		local Root = _sc1
		local Camera = workspace.CurrentCamera
		if not (_sc1 and Camera) then
			return
		end
		local Target = ObjectiveTarget()
		local Position = ObjectivePosition(Target)
		if not Position then
			return
		end
		local Point = Position + Vector3.new(0, 3, 0)
		local Screen, OnScreen = Camera:WorldToViewportPoint(Point)
		local Viewport = Camera.ViewportSize
		local Center = Vector2.new(Viewport.X * 0.5, Viewport.Y * 0.5)
		local Direction = Vector2.new(Screen.X, Screen.Y) - Center
		if Screen.Z <= 0 then
			Direction = -Direction
		end
		if Direction.Magnitude < 1 then
			Direction = Vector2.new(0, -1)
		end
		Direction = Direction.Unit
		local Margin = 48
		local HalfWidth = math.max(16, Viewport.X * 0.5 - 48)
		local HalfHeight = math.max(16, Viewport.Y * 0.5 - 48)
		local _sc2 = OnScreen
			and Screen.X > Margin
			and Screen.Y > Margin
			and Screen.X < Viewport.X - Margin
			and Screen.Y < Viewport.Y - Margin
		local Perp = Vector2.new(-Direction.Y, Direction.X)
		local Anchor, NameY, DistY
		if _sc2 then
			Anchor = Vector2.new(Screen.X, Screen.Y)
			WaypointArrow.PointA = Anchor + Vector2.new(0, -3)
			WaypointArrow.PointB = Anchor + Vector2.new(6, -13)
			WaypointArrow.PointC = Anchor + Vector2.new(-6, -13)
			NameY = Anchor.Y - 44
			DistY = Anchor.Y - 28
		else
			local Scale = math.huge
			if math.abs(Direction.X) > 0.001 then
				Scale = math.min(Scale, HalfWidth / math.abs(Direction.X))
			end
			if math.abs(Direction.Y) > 0.001 then
				Scale = math.min(Scale, HalfHeight / math.abs(Direction.Y))
			end
			Anchor = Center + Direction * Scale
			WaypointArrow.PointA = Anchor + Direction * 10
			WaypointArrow.PointB = Anchor - Direction * 3 + Perp * 6
			WaypointArrow.PointC = Anchor - Direction * 3 - Perp * 6
			local Inset = Anchor - Direction * 40
			NameY = Inset.Y
			DistY = Inset.Y + Scaled(14)
		end
		local Color = MiscConfig.WaypointColor
		local Distance = math.floor((Position - Root.Position).Magnitude + 0.5)
		local OverlapsESP = false
		for _, Box in ipairs(_rl0[38]) do
			if math.abs(Box.X - Anchor.X) < 45 and Anchor.Y > Box.Y - 70 and Anchor.Y < Box.Y + 45 then
				OverlapsESP = true
				break
			end
		end
		WaypointArrow.Color = Color
		WaypointArrow.Visible = true
		local ObjectiveName = ObjectiveLabel()
		if #ObjectiveName > 32 then
			ObjectiveName = string.sub(ObjectiveName, 1, 31) .. "..."
		end
		local LabelX = math.clamp(Anchor.X, Scaled(80), Viewport.X - Scaled(80))
		WaypointText.Color = Color
		WaypointText.Text = string.upper(ObjectiveName)
		WaypointText.Visible = ObjectiveName ~= ""
		WaypointText.Position = Vector2.new(LabelX, math.clamp(NameY, Scaled(14), Viewport.Y - Scaled(40)))
		WaypointDist.Color = Color
		WaypointDist.Text = string.format("%dm", Distance)
		WaypointDist.Position = Vector2.new(LabelX, math.clamp(DistY, Scaled(28), Viewport.Y - Scaled(26)))
		WaypointDist.Visible = not OverlapsESP
	end
	local AlertPool = {}
	local AlertWeakPercent = 30
	local function EnsureAlert(Index)
		local Entry = AlertPool[Index]
		if Entry then
			return Entry
		end
		local Arrow = Drawing.new("Triangle")
		Arrow.Filled = true
		Arrow.Thickness = 1
		Arrow.Visible = false
		local Text = Drawing.new("Text")
		TextBase[Text] = 11
		Text.Size = Scaled(11)
		Text.Font = _rl0[69]
		Text.Center = true
		Text.Outline = true
		Text.OutlineColor = Color3.new(0, 0, 0)
		Text.Visible = false
		local Entry_s1 = { Arrow = Arrow, Text = Text }
		AlertPool[Index] = Entry_s1
		return Entry_s1
	end
	local function UpdateAlertMarkers()
		local Used = 0
		local Camera = workspace.CurrentCamera
		local Character = LocalPlayer.Character
		local Root = Character and Character:FindFirstChild("HumanoidRootPart")
		if PlayerConfig.Alerts and PlayerConfig.Enabled and Camera and Root and not Unloaded then
			local Viewport = Camera.ViewportSize
			local Center = Vector2.new(Viewport.X * 0.5, Viewport.Y * 0.5)
			local Container = workspace:FindFirstChild("Players")
			for _, Model in if Container then Container:GetChildren() else {} do
				if not Model:IsA("Model") then
					continue
				end
				local Player = Players:GetPlayerFromCharacter(Model)
				local Humanoid = Model:FindFirstChildOfClass("Humanoid")
				local TargetRoot = Model:FindFirstChild("HumanoidRootPart")
				if not (Player and Player ~= LocalPlayer and Humanoid and TargetRoot and Humanoid.Health > 0) then
					continue
				end
				local UserStates = Model:FindFirstChild("UserStates")
				local _sc5 = UserStates and UserStates:FindFirstChild("Infected")
				local InfectedValue = _sc5
				local _sc6 = if _sc5 and typeof(InfectedValue.Value) == "number" then InfectedValue.Value / 100 else 0
				local Infection = _sc6
				local Weak = Humanoid.Health / math.max(Humanoid.MaxHealth, 1) * 100 <= AlertWeakPercent
				local _sc8 = _sc6 >= 0.4 and Infection <= 0.85
				if not (Weak or _sc8) then
					continue
				end
				local Screen, OnScreen = Camera:WorldToViewportPoint(TargetRoot.Position + Vector3.new(0, 3, 0))
				local Margin = 48
				local Direction = Vector2.new(Screen.X, Screen.Y) - Center
				if Screen.Z <= 0 then
					Direction = -Direction
				end
				if Direction.Magnitude < 1 then
					Direction = Vector2.new(0, -1)
				end
				Direction = Direction.Unit
				local Perp = Vector2.new(-Direction.Y, Direction.X)
				local _sc9 = OnScreen
					and Screen.X > Margin
					and Screen.Y > Margin
					and Screen.X < Viewport.X - Margin
					and Screen.Y < Viewport.Y - Margin
				local Anchor, LabelY
				Used += 1
				local Entry = EnsureAlert(Used)
				if _sc9 then
					Anchor = Vector2.new(Screen.X, Screen.Y)
					Entry.Arrow.PointA = Anchor + Vector2.new(0, -3)
					Entry.Arrow.PointB = Anchor + Vector2.new(6, -13)
					Entry.Arrow.PointC = Anchor + Vector2.new(-6, -13)
					LabelY = Anchor.Y - Scaled(20)
				else
					local HalfWidth = math.max(16, Viewport.X * 0.5 - Margin)
					local HalfHeight = math.max(16, Viewport.Y * 0.5 - Margin)
					local Scale = math.huge
					if math.abs(Direction.X) > 0.001 then
						Scale = math.min(Scale, HalfWidth / math.abs(Direction.X))
					end
					if math.abs(Direction.Y) > 0.001 then
						Scale = math.min(Scale, HalfHeight / math.abs(Direction.Y))
					end
					Anchor = Center + Direction * Scale
					Entry.Arrow.PointA = Anchor + Direction * 10
					Entry.Arrow.PointB = Anchor - Direction * 3 + Perp * 6
					Entry.Arrow.PointC = Anchor - Direction * 3 - Perp * 6
					LabelY = (Anchor - Direction * Scaled(26)).Y
				end
				local Color = if Weak then DangerColor else PlayerConfig.InfectionColor
				local _sc11 = if Weak then string.format("%s  %d HP", Player.DisplayName, math.ceil(Humanoid.Health)) else string.format("%s  %d%%", Player.DisplayName, math.floor(Infection * 100 + 0.5))
				Entry.Arrow.Color = Color
				Entry.Arrow.Visible = true
				Entry.Text.Color = Color
				Entry.Text.Text = string.upper(_sc11)
				Entry.Text.Position = Vector2.new(math.clamp(Anchor.X, Scaled(80), Viewport.X - Scaled(80)), math.clamp(LabelY, Scaled(14), Viewport.Y - Scaled(20)))
				Entry.Text.Visible = true
			end
		end
		for Index = Used + 1, #AlertPool do
			local Entry = AlertPool[Index]
			Entry.Arrow.Visible = false
			Entry.Text.Visible = false
		end
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
		local Character = LocalPlayer.Character
		if not Character then
			return
		end
		local UserStates = Character:FindFirstChild("UserStates")
		local _sc2 = UserStates and UserStates:FindFirstChild("SpeedController")
		local Module = _sc2
		local Success, Result = false, nil
		if _sc2 then
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
	_rl0[39] = false
	local function SpoofGrabPosition()
		if Unloaded or not _rl0[39] then
			return
		end
		local Character = LocalPlayer.Character
		local _sc1 = Character and Character:FindFirstChildOfClass("Humanoid")
		local Humanoid = _sc1
		if not _sc1 then
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
		local _sc1_s1 = Animations:FindFirstChild("SwingRight") ~= nil or Animations:FindFirstChild("SwingDown") ~= nil
		return _sc1_s1 or Animations:FindFirstChild("Thrust") ~= nil
	end
	local MeleeToolCache = setmetatable({}, { __mode = "k" })
	local function ApplySwingSpeed()
		if Unloaded then
			return
		end
		if PanicConfig.Enabled then
			ClearSwingBuffs()
			return
		end
		if not MeleeConfig.SwingSpeedEnabled or MeleeConfig.SwingSpeed <= 1 then
			return
		end
		local Character = LocalPlayer.Character
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
	_rl0[71] = LocalPlayer.Character
	if _rl0[71] then
		_rl0[71]:SetAttribute("SwingSpeedScalar", nil)
	end
	local NearPlane = 0.1
	local ProjectCorners = table.create(8)
	local ProjectDepth = table.create(8)
	local ProjectEdges = { { 1, 2 }, { 3, 4 }, { 1, 3 }, { 2, 4 }, { 5, 6 }, { 7, 8 }, { 5, 7 }, { 6, 8 }, { 1, 5 }, { 2, 6 },
		{ 3, 7 }, { 4, 8 }
	}
	local function BodyBounds(Model)
		local Min, Max
		local Parts = 0
		for _, Part in Model:GetChildren() do
			if Part:IsA("BasePart") then
				local Half = Part.Size * 0.5
				local Low = Part.Position - Half
				local High = Part.Position + Half
				Parts += 1
				if Min then
					Min = Vector3.new(math.min(Min.X, Low.X), math.min(Min.Y, Low.Y), math.min(Min.Z, Low.Z))
					Max = Vector3.new(math.max(Max.X, High.X), math.max(Max.Y, High.Y), math.max(Max.Z, High.Z))
				else
					Min = Low
					Max = High
				end
			end
		end
		if Parts < 3 then
			return nil
		end
		return Min, Max
	end
	local function ProjectModel(Model, Camera)
		local Min, Max = BodyBounds(Model)
		local BoxCFrame, BoxSize
		if Min then
			BoxSize = Max - Min
			BoxCFrame = CFrame.new((Min + Max) * 0.5)
		else
			local Success
			Success, BoxCFrame, BoxSize = pcall(Model.GetBoundingBox, Model)
			if not Success then
				return nil
			end
		end
		local MinX = math.huge
		local MinY = math.huge
		local MaxX = -math.huge
		local MaxY = -math.huge
		local Visible = false
		local AllFront = true
		for Index = 0, 7 do
			local SideIndex = Index % 2
			local _sc1 = math.floor(Index / 2) % 2 == 0 and 0.5 or -0.5
			local World = BoxCFrame
				* Vector3.new(
					BoxSize.X * (SideIndex == 0 and 0.5 or -0.5),
					BoxSize.Y * _sc1,
					BoxSize.Z * (Index < 4 and 0.5 or -0.5)
				)
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
		TextBase[Text] = TextSize
		Text.Size = Scaled(TextSize)
		Text.Font = _rl0[69]
		Text.Center = true
		Text.Outline = true
		Text.OutlineColor = Color3.new(0, 0, 0)
		Text.Visible = false
		return Text
	end
	_rl0[37] = setmetatable({}, { __mode = "k" })
	local function Set(Target, Prop, Value)
		local Memo = _rl0[37][Target]
		if not Memo then
			Memo = {}
			_rl0[37][Target] = Memo
		end
		if Memo[Prop] ~= Value then
			Memo[Prop] = Value
			Target[Prop] = Value
		end
	end
	local function MakeEntry(Kind)
		local Outline = Drawing.new("Square")
		Outline.Filled = false
		Outline.Thickness = 1
		Outline.Color = Color3.new(0, 0, 0)
		Outline.Transparency = 1
		Outline.Visible = false
		local Fill = Drawing.new("Square")
		Fill.Filled = true
		Fill.Thickness = 1
		Fill.Transparency = 0.15
		Fill.Visible = false
		local Box = Drawing.new("Square")
		Box.Filled = false
		Box.Thickness = 1
		Box.Transparency = 1
		Box.Visible = false
		local HpBack = Drawing.new("Square")
		HpBack.Filled = true
		HpBack.Color = Color3.new(0, 0, 0)
		HpBack.Transparency = 0.5
		HpBack.Visible = false
		local HpFill = Drawing.new("Square")
		HpFill.Filled = true
		HpFill.Visible = false
		local Tracer = Drawing.new("Line")
		Tracer.Thickness = 1
		Tracer.Transparency = 0.6
		Tracer.Visible = false
		local Entry = { Kind = Kind, Fill = Fill, Box = Box, Outline = Outline, HpBack = HpBack, HpFill = HpFill,
			Corners = nil, NameText = CreateText(12), DistText = CreateText(10), HealthText = CreateText(10),
			TimerText = CreateText(11), Tracer = Tracer, StatusTexts = {}, Highlight = nil, Suppressed = {},
			Gui = nil, Humanoid = nil, Root = nil, SuppressTarget = nil, SuppressAt = 0, SlowAt = 0,
			StatusAt = 0, FuseAt = 0, DistColor = Color3.fromRGB(190, 190, 190)
		}
		if Kind ~= "zombie" then
			for Index = 1, 5 do
				Entry.StatusTexts[Index] = CreateText(10)
			end
		end
		return Entry
	end
	local function EnsureCorners(Entry)
		local Corners = Entry.Corners
		if Corners then
			return Corners
		end
		local CornerLines = {}
		for Index = 1, 8 do
			local Line = Drawing.new("Line")
			Line.Thickness = 3
			Line.Visible = false
			CornerLines[Index] = Line
		end
		Entry.Corners = CornerLines
		return CornerLines
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
		for _, Object in { Entry.Fill, Entry.Box, Entry.Outline, Entry.HpBack, Entry.HpFill, Entry.NameText, Entry.DistText,
			Entry.HealthText, Entry.TimerText, Entry.Tracer
		} do
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
	_rl0[72] = 0
	local function GetEntry(Model, Kind, Store)
		local TrackedStore = Store or Tracked
		local Entry = TrackedStore[Model]
		if Entry and Entry.Kind ~= Kind then
			DestroyEntry(Entry)
			Entry = nil
		end
		if not Entry then
			if _rl0[72] <= 0 then
				return nil
			end
			_rl0[72] -= 1
			Entry = MakeEntry(Kind)
			TrackedStore[Model] = Entry
		end
		return Entry
	end
	local function EnsureGui(Entry, Model)
		if Entry.Gui and Entry.Gui.Holder and Entry.Gui.Holder.Parent then
			return Entry.Gui
		end
		local _sc2_s1 = Model:FindFirstChild("Head") or Model:FindFirstChild("HumanoidRootPart")
		local Head = _sc2_s1
		if not _sc2_s1 then
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
		local StatusLabel = Instance.new("TextLabel")
		StatusLabel.Name = "Status"
		StatusLabel.BackgroundTransparency = 1
		StatusLabel.Font = Enum.Font.GothamBold
		StatusLabel.TextSize = 12
		StatusLabel.TextColor3 = Color3.new(1, 1, 1)
		StatusLabel.Size = UDim2.new(1, 0, 0, 14)
		StatusLabel.Visible = false
		StatusLabel.Parent = Holder
		Entry.Gui = { Holder = Holder, NameLabel = NameLabel, StatusLabel = StatusLabel }
		return Entry.Gui
	end
	local function RefreshVisuals()
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
				local _t3896 = _rl0[35][Pin.Value]
				insert(Statuses, { Text = _t3896 or Pin.Value, Color = PlayerConfig.PinnedColor })
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
		Set(Entry.Outline, "Visible", false)
		Set(Entry.HpBack, "Visible", false)
		Set(Entry.HpFill, "Visible", false)
		for Index = 1, 8 do
			local _sc1 = Entry.Corners and Entry.Corners[Index]
			local CornerLine = _sc1
			if _sc1 then
				Set(CornerLine, "Visible", false)
			end
		end
		Set(Entry.NameText, "Visible", false)
		Set(Entry.DistText, "Visible", false)
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
		local _sc1 = Cached and Cached.Humanoid
		local HumanoidInstance = _sc1
		if not _sc1 or not HumanoidInstance.Parent then
			HumanoidInstance = Model:FindFirstChildOfClass("Humanoid")
		end
		if not HumanoidInstance or HumanoidInstance.Health <= 0 then
			return
		end
		local _sc4 = Cached and Cached.Root
		local Root = _sc4
		if not _sc4 or not Root.Parent then
			Root = Model:FindFirstChild("HumanoidRootPart")
		end
		local _sc6 = Root and Root.Position
		local RootPos = _sc6
		local Distance = 0
		if _sc6 then
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
			local _sc8 = Cached and Cached.Kind == Kind and Cached.ZLabel and View.Now - Cached.SlowAt < 1
			if _sc8 then
				Type = Cached.ZType
				Label = Cached.ZLabel
			else
				Type = Model:GetAttribute("Type")
				local _sc8 = Type == nil and Model.Name
				local TypeName = _sc8
				if not _sc8 then
					TypeName = _rl0[32][Type] or tostring(Type)
				end
				Label = TypeName
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
			local _sc8 = Far and math.floor(Distance / 5) * 5
			local FinalDistance = _sc8
			Distance = if _sc8 then FinalDistance else math.floor(Distance)
		end
		local DistLabel = string.format("%dm", Distance)
		local GuiLabel = if Config.Distance then string.format("%s [%dm]", Label, Distance) else Label
		local Style = Config.BoxStyle or "Box"
		local ShowBox = Config.Box and Style ~= "Corner"
		local ShowFill = ShowBox and Style == "Filled Box"
		local ShowCorners = Config.Box and Style == "Corner" and not Far
		local Corners = Entry.Corners
		Set(Entry.Box, "Visible", ShowBox)
		Set(Entry.Outline, "Visible", ShowBox)
		Set(Entry.Fill, "Visible", ShowFill)
		if ShowCorners then
			local CornerSet = Corners
			Corners = if Corners then CornerSet else EnsureCorners(Entry)
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
				Set(Entry.Outline, "Color", Color3.new(0, 0, 0))
				Set(Entry.Outline, "Position", Position - Vector2.new(1, 1))
				Set(Entry.Outline, "Size", Size + Vector2.new(2, 2))
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
					local _sc10 = Index <= 2 and 1 or -1
					local OriginX = X + ((Index == 1 or Index == 3) and 1 or -1) * 1.5
					local OriginY = Y + _sc10 * 1.5
					local Horizontal = Corners[Index * 2 - 1]
					local Vertical = Corners[Index * 2]
					Set(Horizontal, "Color", BoxColor)
					Set(Horizontal, "From", Vector2.new(OriginX, OriginY))
					Set(Horizontal, "To", Vector2.new(X + ((Index == 1 or Index == 3) and 1 or -1) * Length, OriginY))
					Set(Vertical, "Color", BoxColor)
					Set(Vertical, "From", Vector2.new(OriginX, OriginY))
					Set(Vertical, "To", Vector2.new(OriginX, Y + _sc10 * Length))
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
			local ShowName = Config.Names and (Config.NameStyle == "Text" or Config.NameStyle == "Both")
			local Names = Config.Names
			if Names then
				Names = Config.NameStyle == "GUI" or Config.NameStyle == "Both"
			end
			local ShowGuiName = Names
			local ShowDist = Config.Distance
			local HealthStyle = Config.HealthStyle
			if HealthStyle == "GUI" then
				HealthStyle = "Both"
			end
			local ShowBar = Config.Health and (HealthStyle == "Bar" or HealthStyle == "Both")
			local ShowHealthText = Config.Health and (HealthStyle == "Text" or HealthStyle == "Both")
			local StackY = MinY - Scaled(4)
			local HealthY, DistY, NameY
			if ShowHealthText then
				StackY -= Scaled(10)
				HealthY = StackY
			end
			if ShowDist then
				StackY -= Scaled(11)
				DistY = StackY
			end
			if ShowName then
				StackY -= Scaled(13)
				NameY = StackY
			end
			Set(Entry.NameText, "Visible", ShowName)
			if ShowName then
				Set(Entry.NameText, "Text", string.upper(Label))
				Set(Entry.NameText, "Color", Config.NameColor)
				Set(Entry.NameText, "Position", Vector2.new(CenterX, NameY))
			end
			table.insert(_rl0[38], Vector2.new(CenterX, MinY))
			Set(Entry.DistText, "Visible", ShowDist)
			if ShowDist then
				Set(Entry.DistText, "Color", Entry.DistColor)
				Set(Entry.DistText, "Position", Vector2.new(CenterX, DistY))
				if Entry.DistValue ~= Distance then
					Entry.DistValue = Distance
					Set(Entry.DistText, "Text", DistLabel)
				end
			end
			Set(Entry.HpBack, "Visible", ShowBar)
			Set(Entry.HpFill, "Visible", ShowBar)
			if ShowBar then
				local Height = math.max(4, MaxY - MinY)
				local MaxHealth = HumanoidInstance.MaxHealth
				local _sc11 = if MaxHealth > 0 then math.clamp(HumanoidInstance.Health / MaxHealth, 0, 1) else 0
				local BarX = math.floor(MinX) - 7
				local FillHeight = math.max(0, Height * _sc11)
				Set(Entry.HpBack, "Transparency", 0.62)
				Set(Entry.HpBack, "Position", Vector2.new(BarX - 1, MinY - 1))
				Set(Entry.HpBack, "Size", Vector2.new(6, Height + 2))
				Set(Entry.HpFill, "Color", HealthTint(_sc11))
				Set(Entry.HpFill, "Position", Vector2.new(BarX, MaxY - FillHeight))
				Set(Entry.HpFill, "Size", Vector2.new(4, FillHeight))
			end
			Set(Entry.HealthText, "Visible", ShowHealthText)
			if ShowHealthText then
				Set(Entry.HealthText, "Color", Config.HealthColor)
				Set(Entry.HealthText, "Position", Vector2.new(CenterX, HealthY))
				if Entry.HPValue ~= HumanoidInstance.Health then
					Entry.HPValue = HumanoidInstance.Health
					Set(Entry.HealthText, "Text", string.format("%d HP", math.ceil(HumanoidInstance.Health)))
				end
			end
			if ShowGuiName then
				EnsureGui(Entry, Model)
			end
			if Entry.Gui and Entry.Gui.Holder and Entry.Gui.Holder.Parent then
				local NameLabel = Entry.Gui.NameLabel
				Set(NameLabel, "Visible", ShowGuiName)
				local NameHeight = Scaled(16)
				Set(NameLabel, "TextSize", Scaled(13))
				Set(NameLabel, "Size", UDim2.new(1, 0, 0, NameHeight))
				if ShowGuiName then
					Set(NameLabel, "Text", GuiLabel)
					Set(NameLabel, "TextColor3", Config.NameColor)
				end
				local StatusLabel = Entry.Gui.StatusLabel
				local StatusText = ""
				local StatusColor = Config.NameColor
				if Config.Infection then
					local UserStates = Model:FindFirstChild("UserStates")
					local _sc13 = UserStates and UserStates:FindFirstChild("Infected")
					local Infected = _sc13
					if _sc13 and typeof(Infected.Value) == "number" and Infected.Value > 0 then
						StatusText = string.format("Infection %d%%", math.floor(Infected.Value + 0.5))
						StatusColor = Config.InfectionColor
					end
				end
				local ShowGuiStatus = StatusText ~= "" and ShowGuiName
				Set(StatusLabel, "Text", StatusText)
				Set(StatusLabel, "TextColor3", StatusColor)
				Set(StatusLabel, "TextSize", Scaled(12))
				Set(StatusLabel, "Size", UDim2.new(1, 0, 0, Scaled(14)))
				Set(StatusLabel, "Position", UDim2.fromOffset(0, NameHeight + Scaled(2)))
				Set(StatusLabel, "Visible", ShowGuiStatus)
				local _sc13 = ShowGuiStatus
				local Holder = Entry.Gui.Holder
				local fromOffset = UDim2.fromOffset
				local _t5085 = Scaled(150)
				local _t5092 = NameHeight + Scaled(2)
				if ShowGuiStatus then
					local Set_v1 = Set
					local UDim2_v1 = UDim2
					local Scaled_v1 = Scaled
					local Scaled_v2 = Scaled
					_sc13 = Scaled(16)
				end
				Set(Holder, "Size", fromOffset(_t5085, _t5092 + (_sc13 or 0)))
				Set(Entry.Gui.Holder, "Enabled", ShowGuiName)
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
			local _sc9 = Entry.SuppressTarget ~= Target
			_sc9 = _sc9 or View.Now - (Entry.SuppressAt or 0) >= 0.25
			if _sc9 then
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
					TimerX, TimerY = CenterX, MinY - 34
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
		RefreshEspScale()
		table.clear(_rl0[38])
		local _sc1_s1 = ZombieConfig.Enabled or PlayerConfig.Enabled
		if not (_sc1_s1 or SurgeonConfig.Enabled) then
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
		_rl0[72] = 12
		if ZombieConfig.Enabled then
			RefreshVisuals()
		end
		local Camera = workspace.CurrentCamera
		if not Camera then
			return
		end
		local CamCF = Camera.CFrame
		local View = _rl0[17]
		_rl0[17].Camera = Camera
		View.Position = CamCF.Position
		View.Look = CamCF.LookVector
		View.Viewport = Camera.ViewportSize
		View.Now = os.clock()
		local Seen = _rl0[15]
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
				local Target = PlayerConfig.Target
				local Character = LocalPlayer.Character
				for _, Model in Container:GetChildren() do
					if Model:IsA("Model") then
						local IsSelf = Model == Character
						if IsSelf and Target ~= "Other Players" or not IsSelf and Target ~= "Self" then
							RenderModel(Model, "player", Seen, View)
						end
					end
				end
			end
		end
		local SurgeonSeenThis = _rl0[16]
		table.clear(SurgeonSeenThis)
		if SurgeonConfig.Enabled then
			local Container = workspace:FindFirstChild("Players")
			if Container then
				local Threshold = SurgeonConfig.Threshold
				for _, Model in Container:GetChildren() do
					if Model:IsA("Model") and Model ~= LocalPlayer.Character then
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
	end
	local function IsBarrel(Agent)
		if not Agent then
			return false
		end
		return Agent:GetAttribute("Type") == "Barrel"
	end
	local BlastSpheres = setmetatable({}, { __mode = "k" })
	_rl0[41] = 0
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
		if not ZombieConfig.Enabled or not ZombieConfig.BlastRadius then
			if next(BlastSpheres) then
				for Model in BlastSpheres do
					DestroyBlastSphere(Model)
				end
			end
			return
		end
		local Now = time()
		if Now - _rl0[41] < 0.1 then
			return
		end
		_rl0[41] = Now
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
	_rl0[73] = 0
	local function RefreshHitboxParts()
		local Now = time()
		if Now - _rl0[73] < 0.05 then
			return
		end
		_rl0[73] = Now
		local Camera = workspace.CurrentCamera
		local Container = workspace:FindFirstChild("Zombies")
		local Names = _rl0[34][HitboxConfig.Part]
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
		_rl0[73] = 0
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
		local _sc1 = Type and _rl0[32][Type] or Model.Name
		return Config.Types[_sc1] == true
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
	_rl0[74] = 0
	_rl0[42] = 0
	local SilentTargetPosition
	local ShoveRoot
	local SilentTargetModel
	_rl0[43] = 0
	local function SampleSilentTarget()
		local Now = time()
		if Now - _rl0[43] < 1 / 30 then
			return
		end
		_rl0[43] = Now
		if Now - _rl0[42] > 1 then
			_rl0[42] = Now
			local Ok, Value = pcall(function()
				return LocalPlayer:GetNetworkPing()
			end)
			if Ok and typeof(Value) == "number" then
				if Value > 1 then
					Value = Value / 1000
				end
				_rl0[74] = math.clamp(Value, 0, 0.4)
			else
				Ok, Value = pcall(function()
					local Item = _rl0[7].Network.ServerStatsItem["Data Ping"]
					return Item and Item:GetValue()
				end)
				if Ok and typeof(Value) == "number" then
					_rl0[74] = math.clamp(Value / 1000, 0, 0.4)
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
		local _sc1_s1 = Root and Root.AssemblyLinearVelocity or Vector3.zero
		SilentTargetPosition = Target.Position + _sc1_s1 * (_rl0[74] * 0.5)
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
	_rl0[75] = Color3.fromRGB(255, 170, 80)
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
		UpdateFOVCircle("Silent", AimConfig.Silent, _rl0[75])
		if TargetChams and not TargetChams.Parent then
			TargetChams = nil
		end
		if AimConfig.Silent.Enabled and AimConfig.Silent.Chams and SilentTargetModel and SilentTargetModel.Parent then
			if not TargetChams then
				TargetChams = Instance.new("Highlight")
				TargetChams.Name = "UmberTargetChams"
				TargetChams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			end
			TargetChams.FillColor = _rl0[75]
			TargetChams.OutlineColor = _rl0[75]
			TargetChams.FillTransparency = 0.5
			TargetChams.OutlineTransparency = 0
			TargetChams.Parent = SilentTargetModel
		elseif TargetChams then
			TargetChams.Parent = nil
		end
	end
	local function MakeHeadshot(Result, Origin, Direction)
		local Part = Result.Instance
		local _sc1_s1 = not Part or not Part.Parent
		if _sc1_s1 or Part.Parent.Name ~= "m_Zombie" or Part.Name == "Head" then
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
			local Expanded_v1 = Expanded
			if Expanded then
				Expanded_v1 = not Result or Expanded.Distance < Result.Distance
			end
			if Expanded_v1 then
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
		local _sc1 = OldNamecall
		if if OldNamecall then _sc1 else typeof(hookmetamethod) ~= "function" then
			return
		end
		local Previous
		local Busy = false
		local Success, Result = pcall(function()
			return hookmetamethod(game, "__namecall", function(Self, ...)
				if Busy then
					return Previous(Self, ...)
				end
				local Method = getnamecallmethod()
				if Method == "FireServer" then
					local Args = table.pack(...)
					local Original = Args[3]
					local NewAim = Original
					Busy = true
					pcall(function()
						if AimConfig.Silent.Enabled
							and Args[1] == "Fire"
							and typeof(Original) == "Vector3"
							and SilentTargetPosition
						then
							NewAim = SilentTargetPosition
						elseif ClassConfig.ShoveExpander
							and Args[1] == "FeedbackStun"
							and typeof(Original) == "Vector3"
							and ShoveRoot
						then
							local Center = ShoveRoot.Position + ShoveRoot.CFrame.LookVector * 2
							if (Original - Center).Magnitude > 3 then
								NewAim = Center
							end
						end
					end)
					Busy = false
					if NewAim ~= Original then
						Args[3] = NewAim
					end
					return Previous(Self, table.unpack(Args, 1, Args.n))
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
						Busy = true
						Ok, Resolved = pcall(ProcessMeleeRay, Origin, Direction, Params, Built)
						Busy = false
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
		if PanicConfig.Enabled then
			RemoveHitboxHook()
			return
		end
		local _sc1_s1 = HitboxConfig.Enabled or MeleeConfig.AutoHeadshot
		if _sc1_s1 or AimConfig.Silent.Enabled or ClassConfig.ShoveExpander then
			InstallHitboxHook()
		else
			RemoveHitboxHook()
		end
	end
	local function ApplyPanic(On)
		if PanicConfig.Enabled == On then
			return
		end
		PanicConfig.Enabled = On
		if On then
			local Saved = {}
			for _, Name in ipairs(_rl0[30]) do
				local Toggle = LibraryToggles[Name]
				Saved[Name] = Toggle ~= nil and Toggle.Value == true
			end
			PanicConfig.Saved = Saved
			for _, Name in ipairs(_rl0[30]) do
				local Toggle = LibraryToggles[Name]
				if Toggle and Toggle.Value then
					Toggle:SetValue(false)
				end
			end
		else
			local Saved = PanicConfig.Saved
			PanicConfig.Saved = {}
			for _, Name in ipairs(_rl0[30]) do
				if Saved[Name] then
					local Toggle = LibraryToggles[Name]
					if Toggle and not Toggle.Value then
						Toggle:SetValue(true)
					end
				end
			end
		end
		SyncHook()
		ApplySwingSpeed()
	end
	local SurgeonState
	do
		local HitboxVisuals = {}
		_rl0[76] = 0
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
			if Now - _rl0[76] < 0.05 then
				return
			end
			_rl0[76] = Now
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
		_rl0[77] = 0
		local TimerColorHot = Color3.fromRGB(255, 70, 70)
		local TimerColorCold = Color3.fromRGB(255, 170, 80)
		local TrajectoryLines
		local TrajectoryMark
		local TrajectorySegments = 72
		local LearnedThrowSpeed = {}
		local ThrowFilter = RaycastParams.new()
		ThrowFilter.FilterType = Enum.RaycastFilterType.Exclude
		_rl0[83] = {}
		local function ClearProjectileTimers()
			for _, Entry in ProjectileTimers do
				pcall(function()
					Entry.Text:Remove()
				end)
			end
			table.clear(ProjectileTimers)
		end
		local function LearnProjectileSpeed(Projectile)
			local Character = LocalPlayer.Character
			local _sc1 = Character and Character:FindFirstChildOfClass("Tool")
			local Tool = _sc1
			if not _sc1 then
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
			local Character = LocalPlayer.Character
			local _sc2 = Character and Character:FindFirstChild("HumanoidRootPart")
			local Root = _sc2
			if typeof(Start) ~= "Vector3" or not _sc2 then
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
			if Now - _rl0[77] < 1 / 30 then
				return
			end
			_rl0[77] = Now
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
		_rl0[78] = 0
		local function IsFuseLit(Tool)
			local Lit = Tool:GetAttribute("FuseLit")
			return Lit == true or Lit == "true"
		end
		local function GetMortarAnchor(Tool)
			local Reference = Tool:FindFirstChild("ModelReference")
			local _sc1 = Reference and Reference.Value
			local Model = _sc1
			if _sc1 and Model.Parent then
				local Grenade = Model:FindFirstChild("Grenade")
				if Grenade and Grenade:IsA("Model") then
					return Grenade:GetPivot().Position, Grenade
				end
				return Model:GetPivot().Position, Model
			end
			return nil, nil
		end
		local MortarHighlight
		local function ClearMortarHighlight()
			if MortarHighlight then
				pcall(function()
					MortarHighlight:Destroy()
				end)
			end
			MortarHighlight = nil
			_rl0[84] = nil
		end
		local function UpdateMortarHighlight(Model, Remaining)
			if not Model or not Model.Parent then
				ClearMortarHighlight()
				return
			end
			if _rl0[84] ~= Model then
				ClearMortarHighlight()
				local Highlight = Instance.new("Highlight")
				Highlight.Name = "UmberMortarChams"
				Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				Highlight.FillTransparency = 0.55
				Highlight.OutlineTransparency = 0
				Highlight.Parent = Model
				MortarHighlight = Highlight
				_rl0[84] = Model
			end
			local TimerColor = Remaining < 1 and DangerColor or _rl0[26]
			MortarHighlight.FillColor = TimerColor
			MortarHighlight.OutlineColor = TimerColor
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
			local Character = LocalPlayer.Character
			local _sc1 = Character and Character:FindFirstChildOfClass("Tool")
			local Tool = _sc1
			if not _sc1 or not IsFuseLit(Tool) then
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
			local Remaining = _rl0[24] - (workspace:GetServerTimeNow() - MortarFuse.Started)
			if Remaining <= 0 then
				ClearMortarHighlight()
				if MortarFuseText then
					Set(MortarFuseText, "Visible", false)
				end
				return
			end
			local Now = time()
			if Now - _rl0[78] < 0.05 then
				return
			end
			_rl0[78] = Now
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
			Set(MortarFuseText, "Color", Remaining < 1 and DangerColor or _rl0[26])
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
				local Vector3_new = Vector3.new
				local _sc1 = DeltaY < 0 and -Speed
				return Vector3_new(0, _sc1 or DeltaY > 0 and Speed or 0, 0)
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
		_rl0[79] = 0
		local function IsThrowableTool(Tool)
			if _rl0[23][Tool.Name] or LearnedThrowSpeed[Tool.Name] then
				return true
			end
			local Configuration = Tool:FindFirstChild("Configuration")
			if not Configuration then
				return false
			end
			for _, Name in ipairs(_rl0[22]) do
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
				for _, Name in ipairs(_rl0[21]) do
					local Value = Configuration:GetAttribute(Name)
					if typeof(Value) == "number" and Value >= 10 then
						return Value
					end
				end
			end
			return LearnedThrowSpeed[Tool.Name] or 55
		end
		local MobilePlayer
		_rl0[80] = 0
		local function IsMobilePlayer()
			local Now = time()
			if MobilePlayer ~= nil and Now - _rl0[80] < 2 then
				return MobilePlayer
			end
			_rl0[80] = Now
			MobilePlayer = LocalPlayer:GetAttribute("Mobile") == true
			if not MobilePlayer then
				local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
				MobilePlayer = PlayerGui ~= nil and PlayerGui:FindFirstChild("MobileGui") ~= nil
			end
			if not MobilePlayer then
				MobilePlayer = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
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
			local _sc2_s1 = Character:FindFirstChild("RightHand") or Character:FindFirstChild("Right Arm")
			return _sc2_s1 or Character:FindFirstChild("HumanoidRootPart")
		end
		local function UpdateTrajectory()
			if not ThrowableConfig.Trajectory then
				HideTrajectory()
				return
			end
			local Now = time()
			if Now - _rl0[79] < 1 / 30 then
				return
			end
			_rl0[79] = Now
			local Character = LocalPlayer.Character
			local _sc1 = Character and Character:FindFirstChildOfClass("Tool")
			local Tool = _sc1
			local Camera = workspace.CurrentCamera
			if not _sc1 or not Camera then
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
				local Target = _rl0[27].Hit.Position
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
			local Step = _rl0[25]
			local Count = 0
			local Hit = false
			_rl0[83][1] = Character
			_rl0[83][2] = Camera
			ThrowFilter.FilterDescendantsInstances = _rl0[83]
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
		do
			local function BindCharacter()
				SpeedModifier = nil
				ApplySwingSpeed()
				ApplyChargeSpeed()
				local Character = LocalPlayer.Character
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
							if not _rl0[28].AutoJump then
								return
							end
							local _sc3 = SwingTrack and SwingTrack.Name
							if _sc3 ~= "SwingRight"
								and _sc3 ~= "SwingLeft"
								and _sc3 ~= "SwingDown"
								and _sc3 ~= "Thrust"
								and _sc3 ~= "ChargeSwingLeft"
								and _sc3 ~= "ChargeSwingRight"
							then
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
							local _sc4_s1 = not Humanoid or Humanoid.Health <= 0
							if _sc4_s1 or Humanoid.FloorMaterial == Enum.Material.Air then
								return
							end
							local OkPower, CurrentPower = pcall(function()
								return Humanoid.JumpPower
							end)
							local _sc6_s1 = not OkPower or typeof(CurrentPower) ~= "number"
							local _sc7 = _sc6_s1 or CurrentPower <= 0
							local WasZero = _sc7
							if _sc7 then
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
			Track(LocalPlayer.CharacterAdded:Connect(BindCharacter))
			BindCharacter()
		end
		_rl0[81] = 0
		do
			local function UpdateAutoBuild()
				if not ClassConfig.AutoBuild or Unloaded then
					return
				end
				local Now = tick()
				if Now - _rl0[81] < 0.5 then
					return
				end
				_rl0[81] = Now
				local Character = LocalPlayer.Character
				local _sc1 = Character and Character:FindFirstChild("HumanoidRootPart")
				local Root = _sc1
				if not _sc1 then
					return
				end
				local Backpack = LocalPlayer:FindFirstChild("Backpack")
				local _sc2 = Backpack and Backpack:FindFirstChild("Hammer") or Character:FindFirstChild("Hammer")
				local Hammer = _sc2
				if not _sc2 then
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
								if OkValue
									and typeof(Value) == "number"
									and OkMax
									and typeof(Max) == "number"
									and Max > 0
								then
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
				local Character = LocalPlayer.Character
				local _sc1 = Character and Character:FindFirstChild("HumanoidRootPart")
				local Root = _sc1
				local Center
				local Radius = 1
				ShoveRoot = _sc1
				if ClassConfig.ShoveShow and not Unloaded then
					local _sc2 = Character and Character:FindFirstChildOfClass("Tool")
					local Tool = _sc2
					local CanShove = false
					local Stock = 3
					if _sc2 then
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
				local HitCenter = Center or Vector3.zero
				UpdateBubbleSphere("UmberShoveHitbox", Center ~= nil, HitCenter, Radius, Color3.fromRGB(255, 90, 90), ClassConfig.ShoveTransparency / 100)
			end
			SurgeonState = { Target = nil, Path = nil, Waypoints = nil, Index = 1, Goal = nil, RepathAt = 0, HealAt = 0,
				HealTarget = nil, HealHealth = nil, Threats = nil, ThreatsAt = 0, SuppliesAt = 0
			}
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
				local Character = LocalPlayer.Character
				local _sc1 = Character and Character:FindFirstChild("HumanoidRootPart")
				local Root = _sc1
				local Container = workspace:FindFirstChild("Players")
				if not (_sc1 and Container) then
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
				local _sc3_s1 = not SurgeonState.Waypoints or Now - SurgeonState.RepathAt >= 0.5
				if _sc3_s1 or Shift > 4 then
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
				local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
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
			_rl0[82] = { Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Down }
			local function SurgeonUserMoving()
				for _, Key in ipairs(_rl0[82]) do
					if UserInputService:IsKeyDown(Key) then
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
				local Character = LocalPlayer.Character
				local Root = Character and Character:FindFirstChild("HumanoidRootPart")
				local _sc2 = Character and Character:FindFirstChildOfClass("Humanoid")
				local Humanoid = _sc2
				if not (Root and _sc2) or Humanoid.Health <= 0 then
					return
				end
				local Target = SurgeonState.Target
				if Target then
					local TargetHumanoid = Target.Humanoid
					local _sc4_s1 = not Target.Model.Parent or not Target.Root.Parent
					local TargetInvalid = _sc4_s1
					if (if _sc4_s1 or not TargetHumanoid then TargetInvalid or not TargetHumanoid else TargetHumanoid.Health <= 0)
						or TargetHumanoid.Health >= TargetHumanoid.MaxHealth
					then
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
			_rl0[85] = { Fife = true, FifeNew = true, Drum = true, Drums = true }
			local function FindInstrument(Tool)
				if typeof(filtergc) ~= "function" then
					return nil
				end
				local Ok, List = pcall(filtergc, "table", { Keys = { "tracker", "songSource" } }, false)
				if not Ok or typeof(List) ~= "table" then
					return nil
				end
				for _, Entry in ipairs(List) do
					if rawget(Entry, "tool") == Tool and typeof(rawget(Entry, "tracker")) == "table" then
						return Entry
					end
				end
				return nil
			end
			local function PlayInstrument(Entry)
				pcall(function()
					Entry:activate()
				end)
			end
			local function UpdateMusician()
				local _sc1 = Unloaded
				if if Unloaded then _sc1 else not ClassConfig.AutoPlay then
					MusicianState.Instrument = nil
					MusicianState.Tool = nil
					return
				end
				local Character = LocalPlayer.Character
				local _sc2 = Character and Character:FindFirstChildOfClass("Tool")
				local Tool = _sc2
				if not _sc2 or not _rl0[85][Tool.Name] then
					MusicianState.Instrument = nil
					MusicianState.Tool = nil
					return
				end
				if MusicianState.Tool ~= Tool then
					MusicianState.Tool = Tool
					MusicianState.Instrument = nil
					MusicianState.Beat = nil
					MusicianState.NextScan = 0
				end
				local Entry = MusicianState.Instrument
				if not Entry then
					local Clock = os.clock()
					if Clock < MusicianState.NextScan then
						return
					end
					MusicianState.NextScan = Clock + 1
					Entry = FindInstrument(Tool)
					MusicianState.Instrument = Entry
					if not Entry then
						return
					end
				end
				local Tracker = rawget(Entry, "tracker")
				if typeof(Tracker) ~= "table" then
					return
				end
				if not rawget(Entry, "playing") then
					MusicianState.Beat = nil
					return
				end
				local NextBeat = rawget(Tracker, "nextBeat")
				local LastBeat = rawget(Tracker, "lastBeat")
				if typeof(NextBeat) ~= "number" or typeof(LastBeat) ~= "number" then
					return
				end
				if NextBeat <= 0 or LastBeat <= 0 then
					return
				end
				if tick() >= NextBeat and MusicianState.Beat ~= NextBeat then
					MusicianState.Beat = NextBeat
					PlayInstrument(Entry)
				end
			end
			local function UpdateFrame(Delta)
				UpdateMusician()
				GuardWorldFog()
				UpdateSilentAim()
				UpdateAutoBuild()
				UpdateSurgeon(Delta)
				VisualAccumulator += Delta
				if VisualAccumulator < _rl0[18] then
					return
				end
				VisualAccumulator = VisualAccumulator % _rl0[18]
				UpdateESP()
				UpdateHitboxVisuals()
				UpdateThrowables()
				UpdateBlastRings()
				UpdateShoveVisual()
				UpdateWaypoints()
				UpdateAlertMarkers()
			end
			Track(_rl0[6].RenderStepped:Connect(UpdateFrame))
		end
		do
			local function UpdateHeartbeat()
				ApplySwingSpeed()
				SpoofGrabPosition()
				if (MiscConfig.AntiBrokenLegs or MiscConfig.NoFallDamage) and os.clock() >= _rl0[40] then
					_rl0[40] = os.clock() + 1
					ApplyCharacterGuards(false)
				end
				if _rl0[29].NoRecoil and os.clock() >= _rl0[19] then
					_rl0[19] = os.clock() + 1
					SetNoRecoil(true)
				end
			end
			Track(_rl0[6].Heartbeat:Connect(UpdateHeartbeat))
		end
		local function Cleanup()
			Unloaded = true
			for _, Connection in Connections do
				if Connection.Connected then
					Connection:Disconnect()
				end
			end
			table.clear(Connections)
			RestoreSuppressed()
			SetNoRecoil(false)
			pcall(function()
				WaypointArrow:Destroy()
				WaypointText:Destroy()
				WaypointDist:Destroy()
				for _, Entry in AlertPool do
					Entry.Arrow:Destroy()
					Entry.Text:Destroy()
				end
				table.clear(AlertPool)
			end)
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
			local Character = LocalPlayer.Character
			if Character then
				pcall(function()
					Character:SetAttribute("SwingSpeedScalar", nil)
				end)
			end
			getgenv().UmberUnload = nil
		end
		Library:OnUnload(Cleanup)
	end
	getgenv().UmberUnload = function()
		Library:Unload()
	end
	do
		_rl0[86] = Pace(_rl0[10].Main:AddGroupbox({ Name = "Safety", Side = "Right", IconName = "shield" }))
		_rl0[86]:AddToggle("PanicSwitch", { Text = "Panic Switch",
			Tooltip = "Drops every cheat that talks to the server and removes the hook. Switching it off puts back exactly what was on.",
			Default = false,
			["Callback"] = function(Value)
				ApplyPanic(Value)
			end
		})
		_rl0[86]:AddLabel({ Text = "Silent Aim, Hitbox Expander, Auto Headshot, Swing Speed and Shove Expander.",
			DoesWrap = true, Size = 12
		})
	end
	_rl0[45] = Pace(_rl0[10].Player:AddGroupbox({ Name = "Movement", Side = "Left", IconName = "footprints" }))
	_rl0[45]:AddToggle("WalkSpeedToggle", { Text = "Walkspeed Toggle",
		Tooltip = "Borrows the game's Charge speed buff so your speed holds through swings and reloads.",
		Default = false,
		["Callback"] = function(Value)
			ChargeSpeed = Value
			ApplyChargeSpeed()
		end
	})
	_rl0[45]:AddSlider("WalkSpeedValue", { AllowRightClickInput = true, Text = "Walk Speed",
		Tooltip = "How fast you move while the toggle is on.", Default = 55, Min = 16, Max = 70,
		Rounding = 0,
		["Callback"] = function(Value)
			ChargeValue = Value
			if ChargeSpeed then
				ApplyChargeSpeed()
			end
		end
	})
	_rl0[46] = Pace(_rl0[10].Player:AddGroupbox({ Name = "Protection", Side = "Right", IconName = "shield" }))
	_rl0[46]:AddToggle("AntiGrab", { Text = "Anti Grab", Tooltip = "Moves you out of grab range on paper so shamblers can't latch on.",
		Default = false,
		["Callback"] = function(Value)
			_rl0[39] = Value
		end
	})
	_rl0[47] = Pace(_rl0[10].Visuals:AddGroupbox({ Name = "ESP", Side = "Left", IconName = "scan-eye" }))
	_rl0[47]:AddToggle("ZombieESP", { Text = "Zombie ESP", Tooltip = "Turns on all the zombie visuals.", Default = false,
		["Callback"] = function(Value)
			ZombieConfig.Enabled = Value
		end
	})
	_rl0[47]:AddToggle("PlayerESP", { Text = "Player ESP", Tooltip = "Turns on all the player visuals.", Default = false,
		["Callback"] = function(Value)
			PlayerConfig.Enabled = Value
		end
	})
	_rl0[47]:AddDropdown("PlayerESPTarget", { Values = { "Other Players", "Self", "Both" }, Default = "Other Players", Text = "Player ESP Target",
		Tooltip = "Who the player ESP draws.",
		["Callback"] = function(Value)
			PlayerConfig.Target = Value
		end
	})
	_rl0[48] = Pace(_rl0[10].Visuals:AddGroupbox({ Name = "Zombie ESP Options", Side = "Left", IconName = "crosshair" }))
	_rl0[48]:AddDropdown("ZombieType", { Values = _rl0[33], Default = { "All" }, Text = "Zombie Type",
		Tooltip = "Only draw the types you tick.", Multi = true,
		["Callback"] = function(Value)
			local Types = {}
			for Key in Value do
				Types[Key] = true
			end
			ZombieConfig.Types = Types
		end
	})
	_rl0[48]:AddToggle("ZombieBox", { Text = "Box", Tooltip = "Box around each zombie.", Default = true,
		["Callback"] = function(Value)
			ZombieConfig.Box = Value
			if Value then
				EnsureEnabled("ZombieESP")
			end
		end
	})
	_rl0[48]:AddDropdown("ZombieBoxStyle", { Values = { "Box", "Corner", "Filled Box" }, Default = "Box", Text = "Box Style",
		Tooltip = "Plain box, corner brackets, or a filled box.",
		["Callback"] = function(Value)
			ZombieConfig.BoxStyle = Value
		end
	})
	_rl0[48]:AddToggle("ZombieChams", { Text = "Chams", Tooltip = "Colours the zombie itself.", Default = false,
		["Callback"] = function(Value)
			ZombieConfig.Chams = Value
			if Value then
				EnsureEnabled("ZombieESP")
			end
		end
	})
	_rl0[48]:AddToggle("ZombieTracers", { Text = "Tracers", Tooltip = "Line from your screen to them.", Default = false,
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
	_rl0[48]:AddToggle("ZombieNames", { Text = "Names", Tooltip = "Zombie type above the box.", Default = false,
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
	_rl0[48]:AddDropdown("ZombieNameStyle", { Values = { "Text", "GUI", "Both" }, Default = "Text", Text = "Name Display",
		Tooltip = "Text draws it, GUI is a label.",
		["Callback"] = function(Value)
			ZombieConfig.NameStyle = Value
		end
	})
	_rl0[48]:AddToggle("ZombieHealth", { Text = "Health Bar", Tooltip = "Health number and/or bar.", Default = false,
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
	_rl0[48]:AddDropdown("ZombieHealthStyle", { Values = { "Bar", "Text", "Both" }, Default = "Both", Text = "Health Display",
		Tooltip = "Bar hugs the box, Text is the number above the name, Both shows both.",
		["Callback"] = function(Value)
			ZombieConfig.HealthStyle = Value
		end
	})
	_rl0[48]:AddToggle("ZombieDistance", { Text = "Show Distance", Tooltip = "Distance in studs under the name.", Default = true,
		["Callback"] = function(Value)
			ZombieConfig.Distance = Value
		end
	})
	_rl0[48]:AddToggle("ZombieBomberTimer", { Text = "Bomber Timer", Tooltip = "Countdown before a bomber blows up.", Default = true,
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
	_rl0[48]:AddDropdown("ZombieBomberTimerPosition", { Values = { "Bottom", "Top", "Center", "Left", "Right" }, Default = "Bottom",
		Text = "Timer Position", Tooltip = "Where the countdown sits.",
		["Callback"] = function(Value)
			ZombieConfig.BomberTimerPosition = Value
		end
	})
	_rl0[48]:AddSlider("ZombieBomberTimerOffsetX", { AllowRightClickInput = true, Text = "Timer Offset X", Tooltip = "Nudge the timer left or right.",
		Default = 0, Min = -400, Max = 400, Rounding = 0,
		["Callback"] = function(Value)
			ZombieConfig.BomberTimerOffsetX = Value
		end
	})
	_rl0[48]:AddSlider("ZombieBomberTimerOffsetY", { AllowRightClickInput = true, Text = "Timer Offset Y", Tooltip = "Nudge the timer up or down.",
		Default = 0, Min = -400, Max = 400, Rounding = 0,
		["Callback"] = function(Value)
			ZombieConfig.BomberTimerOffsetY = Value
		end
	})
	_rl0[48]:AddToggle("ZombieBlastRadius", { Text = "Bomber Blast Radius",
		Tooltip = "Draws the explosion circle while a bomber is about to blow.", Default = true,
		["Callback"] = function(Value)
			ZombieConfig.BlastRadius = Value
		end
	}):AddColorPicker("ZombieBlastRadiusColor", { Default = Color3.fromRGB(255, 90, 60), Title = "Blast Radius Color",
		["Callback"] = function(Value)
			ZombieConfig.BlastRadiusColor = Value
		end
	})
	_rl0[49] = Pace(_rl0[10].Visuals:AddGroupbox({ Name = "Zombie Colors", Side = "Left", IconName = "palette" }))
	_rl0[60] = _rl0[49]:AddLabel("Shambler")
	_rl0[60]:AddColorPicker("ZombieColorNormal", { Default = ZombieColors.Normal, Title = "Shambler Color",
		["Callback"] = function(Value)
			ZombieColors.Normal = Value
		end
	})
	Library:AddTooltip("Box and chams colour for shamblers.", nil, _rl0[60].TextLabel)
	_rl0[61] = _rl0[49]:AddLabel("Runner")
	_rl0[61]:AddColorPicker("ZombieColorFast", { Default = ZombieColors.Fast, Title = "Runner Color",
		["Callback"] = function(Value)
			ZombieColors.Fast = Value
		end
	})
	Library:AddTooltip("Box and chams colour for runners.", nil, _rl0[61].TextLabel)
	_rl0[62] = _rl0[49]:AddLabel("Bomber")
	_rl0[62]:AddColorPicker("ZombieColorBarrel", { Default = ZombieColors.Barrel, Title = "Bomber Color",
		["Callback"] = function(Value)
			ZombieColors.Barrel = Value
		end
	})
	Library:AddTooltip("Box and chams colour for bombers.", nil, _rl0[62].TextLabel)
	_rl0[63] = _rl0[49]:AddLabel("Sapper")
	_rl0[63]:AddColorPicker("ZombieColorSapper", { Default = ZombieColors.Sapper, Title = "Sapper Color",
		["Callback"] = function(Value)
			ZombieColors.Sapper = Value
		end
	})
	Library:AddTooltip("Box and chams colour for sappers.", nil, _rl0[63].TextLabel)
	_rl0[64] = _rl0[49]:AddLabel("Igniter")
	_rl0[64]:AddColorPicker("ZombieColorIgniter", { Default = ZombieColors.Igniter, Title = "Igniter Color",
		["Callback"] = function(Value)
			ZombieColors.Igniter = Value
		end
	})
	Library:AddTooltip("Box and chams colour for igniters.", nil, _rl0[64].TextLabel)
	_rl0[65] = _rl0[49]:AddLabel("Cuirassier")
	_rl0[65]:AddColorPicker("ZombieColorCuirassier", { Default = ZombieColors.Cuirassier, Title = "Cuirassier Color",
		["Callback"] = function(Value)
			ZombieColors.Cuirassier = Value
		end
	})
	Library:AddTooltip("Box and chams colour for cuirassiers.", nil, _rl0[65].TextLabel)
	_rl0[66] = _rl0[49]:AddLabel("Crawler")
	_rl0[66]:AddColorPicker("ZombieColorCrawler", { Default = ZombieColors.Crawler, Title = "Crawler Color",
		["Callback"] = function(Value)
			ZombieColors.Crawler = Value
		end
	})
	Library:AddTooltip("Box and chams colour for crawlers.", nil, _rl0[66].TextLabel)
	_rl0[67] = _rl0[49]:AddLabel("Headless")
	_rl0[67]:AddColorPicker("ZombieColorHeadless", { Default = ZombieColors.Headless, Title = "Headless Color",
		["Callback"] = function(Value)
			ZombieColors.Headless = Value
		end
	})
	Library:AddTooltip("Box and chams colour for headless.", nil, _rl0[67].TextLabel)
	_rl0[68] = _rl0[49]:AddLabel("Big Boy")
	_rl0[68]:AddColorPicker("ZombieColorBigBoy", { Default = ZombieColors.BigBoy, Title = "Big Boy Color",
		["Callback"] = function(Value)
			ZombieColors.BigBoy = Value
		end
	})
	Library:AddTooltip("Box and chams colour for big boys.", nil, _rl0[68].TextLabel)
	_rl0[50] = Pace(_rl0[10].Visuals:AddGroupbox({ Name = "Player ESP Options", Side = "Right", IconName = "users" }))
	_rl0[50]:AddToggle("PlayerBox", { Text = "Box", Tooltip = "Box around each player.", Default = true,
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
	_rl0[50]:AddDropdown("PlayerBoxStyle", { Values = { "Box", "Corner", "Filled Box" }, Default = "Box", Text = "Box Style",
		Tooltip = "Plain box, corner brackets, or a filled box.",
		["Callback"] = function(Value)
			PlayerConfig.BoxStyle = Value
		end
	})
	_rl0[50]:AddToggle("PlayerChams", { Text = "Chams", Tooltip = "Colours the player model.", Default = false,
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
	_rl0[50]:AddToggle("PlayerTracers", { Text = "Tracers", Tooltip = "Line from your screen to them.", Default = false,
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
	_rl0[50]:AddToggle("PlayerNames", { Text = "Names", Tooltip = "Display name above the box.", Default = false,
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
	_rl0[50]:AddDropdown("PlayerNameStyle", { Values = { "Text", "GUI", "Both" }, Default = "Text", Text = "Name Display",
		Tooltip = "Text draws it, GUI is a label.",
		["Callback"] = function(Value)
			PlayerConfig.NameStyle = Value
		end
	})
	_rl0[50]:AddToggle("PlayerHealth", { Text = "Health Bar", Tooltip = "Health number and/or bar.", Default = false,
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
	_rl0[50]:AddDropdown("PlayerHealthStyle", { Values = { "Bar", "Text", "Both" }, Default = "Both", Text = "Health Display",
		Tooltip = "Bar hugs the box, Text is the number above the name, Both shows both.",
		["Callback"] = function(Value)
			PlayerConfig.HealthStyle = Value
		end
	})
	_rl0[50]:AddToggle("PlayerAlerts", { Text = "Weak / Infected Alerts",
		Tooltip = "Shows an arrow towards teammates who are badly hurt or badly infected.", Default = false,
		["Callback"] = function(Value)
			PlayerConfig.Alerts = Value
			if Value then
				EnsureEnabled("PlayerESP")
			end
		end
	})
	_rl0[50]:AddToggle("PlayerDistance", { Text = "Show Distance", Tooltip = "Distance in studs under the name.", Default = true,
		["Callback"] = function(Value)
			PlayerConfig.Distance = Value
		end
	})
	_rl0[50]:AddDivider()
	_rl0[44] = { 
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
	for _, Status in ipairs(_rl0[44]) do
		_rl0[50]:AddToggle("Player" .. Status.Key, { Text = Status.Text, Tooltip = Status.Tooltip, Default = Status.Default,
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
	_rl0[51] = Pace(_rl0[10].Visuals:AddGroupbox({ Name = "Throwables", Side = "Right", IconName = "bomb" }))
	_rl0[51]:AddToggle("ThrowableTimer", { Text = "Throwable Timer",
		Tooltip = "Counts down how long a thrown explosive has before it goes off.", Default = false,
		["Callback"] = function(Value)
			ThrowableConfig.Timer = Value
		end
	})
	_rl0[51]:AddToggle("ThrowableHandMortarTimer", { Text = "Hand Mortar Timer",
		Tooltip = "Counts down the fuse on the grenade lit inside the hand mortar.", Default = false,
		["Callback"] = function(Value)
			ThrowableConfig.MortarTimer = Value
		end
	})
	_rl0[51]:AddToggle("ThrowableTrajectory", { Text = "Projectile Trajectory",
		Tooltip = "Shows the real arc of your grenade, tar bottle or hand mortar. On mobile it previews the camera aim the game actually uses.",
		Default = false,
		["Callback"] = function(Value)
			ThrowableConfig.Trajectory = Value
		end
	})
	_rl0[52] = Pace(_rl0[10].Misc:AddGroupbox({ Name = "Lighting", Side = "Left", IconName = "sun" }))
	_rl0[52]:AddToggle("WorldFullbright", { Text = "Fullbright", Tooltip = "Lights up the whole map.", Default = false,
		["Callback"] = function(Value)
			WorldConfig.Fullbright = Value
			ApplyWorldLighting()
		end
	})
	_rl0[52]:AddToggle("WorldNoFog", { Text = "No Fog", Tooltip = "Clears the fog so you can see further.", Default = false,
		["Callback"] = function(Value)
			WorldConfig.NoFog = Value
			ApplyWorldLighting()
		end
	})
	_rl0[59] = Pace(_rl0[10].Misc:AddGroupbox({ Name = "Character", Side = "Right", IconName = "user" }))
	_rl0[59]:AddToggle("MiscNoFallDamage", { Text = "No Fall Damage", Tooltip = "Blocks the game's fall damage and landing stumble.",
		Default = false,
		["Callback"] = function(Value)
			MiscConfig.NoFallDamage = Value
			ApplyCharacterGuards()
		end
	})
	_rl0[59]:AddToggle("MiscAntiBrokenLegs", { Text = "Anti Broken Legs", Tooltip = "Blocks the broken-legs crawl state so you keep moving.",
		Default = false,
		["Callback"] = function(Value)
			MiscConfig.AntiBrokenLegs = Value
			ApplyCharacterGuards()
		end
	})
	_rl0[59]:AddToggle("MiscWaypoints", { Text = "Objective Waypoints", Tooltip = "Marks the current objective so you can find it.",
		Default = false,
		["Callback"] = function(Value)
			MiscConfig.Waypoints = Value
			UpdateWaypoints()
		end
	}):AddColorPicker("MiscWaypointColor", { Default = Color3.fromRGB(120, 200, 255), Title = "Waypoint Color",
		["Callback"] = function(Value)
			MiscConfig.WaypointColor = Value
		end
	})
	_rl0[53] = Pace(_rl0[10].Combat:AddGroupbox({ Name = "Hitbox Expander", Side = "Left", IconName = "expand" }))
	_rl0[53]:AddToggle("HitboxExpander", { Text = "Hitbox Expander", Tooltip = "Bigger hit area on your swings.", Default = false,
		["Callback"] = function(Value)
			HitboxConfig.Enabled = Value
			SyncHook()
		end
	})
	_rl0[53]:AddSlider("HitboxExpanderSize", { AllowRightClickInput = true, Text = "Hitbox Expander Size",
		Tooltip = "How much bigger that area is.", Default = 5, Min = 1, Max = 10, Rounding = 0,
		["Callback"] = function(Value)
			HitboxConfig.Size = Value
		end
	})
	_rl0[53]:AddDropdown("HitboxExpanderPart", { Values = { "All", "Head", "Torso", "Legs", "HumanoidRootPart" }, Default = "All",
		Text = "Hitbox Part", Tooltip = "Which parts get the bigger hit area.",
		["Callback"] = function(Value)
			HitboxConfig.Part = Value
			InvalidateHitboxParts()
		end
	})
	_rl0[53]:AddToggle("HitboxIgnoreBarrel", { Text = "Ignore Bombers/Barrel", Tooltip = "Skips bombers so you don't pop them.", Default = false,
		["Callback"] = function(Value)
			HitboxConfig.IgnoreBarrel = Value
			InvalidateHitboxParts()
		end
	})
	_rl0[53]:AddToggle("HitboxShow", { Text = "Show Hitboxes", Tooltip = "Draws the hit area so you can see it.", Default = false,
		["Callback"] = function(Value)
			HitboxConfig.Show = Value
		end
	})
	_rl0[53]:AddSlider("HitboxTransparency", { AllowRightClickInput = true, Text = "Hitbox Transparency",
		Tooltip = "How faded the hitboxes are. 90 is barely visible.", Default = 90, Min = 0, Max = 100,
		Rounding = 0, Suffix = "%",
		["Callback"] = function(Value)
			HitboxConfig.Transparency = Value / 100
		end
	})
	_rl0[54] = Pace(_rl0[10].Combat:AddGroupbox({ Name = "Firearms", Side = "Left", IconName = "crosshair" }))
	_rl0[54]:AddToggle("SilentAim", { Text = "Silent Aim", Tooltip = "Shots go to the zombie in the circle instead of where you aim.",
		Default = false,
		["Callback"] = function(Value)
			AimConfig.Silent.Enabled = Value
			SyncHook()
		end
	})
	_rl0[54]:AddToggle("SilentAimShowFOV", { Text = "Show FOV", Tooltip = "Draws the silent aim circle.", Default = false,
		["Callback"] = function(Value)
			AimConfig.Silent.ShowFOV = Value
		end
	})
	_rl0[54]:AddToggle("SilentChams", { Text = "Chams on Target", Tooltip = "Highlights the zombie Silent Aim is currently locked onto.",
		Default = false,
		["Callback"] = function(Value)
			AimConfig.Silent.Chams = Value
		end
	})
	_rl0[54]:AddSlider("SilentAimFOV", { AllowRightClickInput = true, Text = "FOV Size",
		Tooltip = "How far from your crosshair it will look. 360 covers the screen.", Default = 80, Min = 0,
		Max = 360, Rounding = 0,
		["Callback"] = function(Value)
			AimConfig.Silent.FOV = Value
		end
	})
	_rl0[54]:AddDropdown("SilentAimTypes", { Values = _rl0[33], Default = _rl0[33], Text = "Zombie Types",
		Tooltip = "Which zombies silent aim goes for. All targets every zombie.", Multi = true,
		["Callback"] = function(Value)
			local Types = {}
			for Key in Value do
				Types[Key] = true
			end
			AimConfig.Silent.Types = Types
		end
	})
	_rl0[54]:AddToggle("NoRecoil", { Text = "No Recoil", Tooltip = "Stops the camera kick after each shot.", Default = false,
		["Callback"] = function(Value)
			_rl0[29].NoRecoil = Value
			SetNoRecoil(Value)
		end
	})
	_rl0[55] = Pace(_rl0[10].Combat:AddGroupbox({ Name = "Melee", Side = "Right", IconName = "target" }))
	_rl0[55]:AddToggle("MeleeAutoHeadshot", { Text = "Auto Headshot", Tooltip = "Turns your hits into headshots.", Default = false,
		["Callback"] = function(Value)
			MeleeConfig.AutoHeadshot = Value
			SyncHook()
		end
	})
	_rl0[55]:AddSlider("MeleeHeadshotChance", { AllowRightClickInput = true, Text = "Headshot Chance", Tooltip = "Odds a hit lands as a headshot.",
		Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = "%",
		["Callback"] = function(Value)
			MeleeConfig.Chance = Value
		end
	})
	_rl0[55]:AddToggle("MeleeSwingSpeedEnabled", { Text = "Swing Speed", Tooltip = "Turns the multiplier below on.", Default = false,
		["Callback"] = function(Value)
			MeleeConfig.SwingSpeedEnabled = Value
			ClearSwingBuffs()
			ApplySwingSpeed()
		end
	})
	_rl0[55]:AddSlider("MeleeSwingSpeed", { AllowRightClickInput = true, Text = "Swing Speed Multiplier",
		Tooltip = "How many times faster you swing.", Default = 1, Min = 1, Max = 5, Rounding = 1,
		Suffix = "x",
		["Callback"] = function(Value)
			MeleeConfig.SwingSpeed = Value
			ClearSwingBuffs()
			ApplySwingSpeed()
		end
	})
	_rl0[56] = Pace(_rl0[10].Combat:AddGroupbox({ Name = "Legit", Side = "Right", IconName = "chevron-up" }))
	_rl0[56]:AddToggle("AutoJumpOnAttack", { Text = "Auto Jump On Attack",
		Tooltip = "Jumps with the game jump power whenever you swing your melee weapon.", Default = false,
		["Callback"] = function(Value)
			_rl0[28].AutoJump = Value
		end
	})
	_rl0[57] = Pace(_rl0[10].Class:AddGroupbox({ Name = "Sapper", Side = "Left", IconName = "hammer" }))
	_rl0[57]:AddToggle("AutoBuild", { Text = "Auto Build", Tooltip = "Automatically repairs damaged sapper buildings near you.",
		Default = false,
		["Callback"] = function(Value)
			ClassConfig.AutoBuild = Value
		end
	})
	_rl0[57]:AddDropdown("AutoBuildPriority", { Values = { "Closest Building", "Lowest Health Building" }, Default = "Closest Building",
		Text = "Priority", Tooltip = "Which damaged building gets repaired first.",
		["Callback"] = function(Value)
			ClassConfig.BuildPriority = Value
		end
	})
	_rl0[57]:AddDivider()
	_rl0[57]:AddToggle("ShoveExpander", { Text = "Shove Hitbox Expander", Tooltip = "Makes the shove hit area bigger.", Default = false,
		["Callback"] = function(Value)
			ClassConfig.ShoveExpander = Value
			SyncHook()
		end
	})
	_rl0[57]:AddSlider("ShoveRadius", { AllowRightClickInput = true, Text = "Shove Hitbox Size", Tooltip = "How far the shove can reach.",
		Default = 5, Min = 1, Max = 15, Rounding = 0, Suffix = "st",
		["Callback"] = function(Value)
			ClassConfig.ShoveRadius = Value
		end
	})
	_rl0[57]:AddToggle("ShoveShow", { Text = "Show Shove Hitbox", Tooltip = "Draws the shove hit area so you can see it.",
		Default = false,
		["Callback"] = function(Value)
			ClassConfig.ShoveShow = Value
		end
	})
	_rl0[57]:AddSlider("ShoveTransparency", { AllowRightClickInput = true, Text = "Shove Hitbox Transparency",
		Tooltip = "How faded the hitbox is. 90 is barely visible.", Default = 95, Min = 0, Max = 100,
		Rounding = 0, Suffix = "%",
		["Callback"] = function(Value)
			ClassConfig.ShoveTransparency = Value
		end
	})
	do
		local function ApplySurgeonStyle(Style)
			SurgeonConfig.Style = Style
			SurgeonConfig.Chams = Style == "Chams"
			SurgeonConfig.Box = Style ~= "Chams"
			SurgeonConfig.BoxStyle = Style == "Corner Box" and "Corner" or Style
		end
		_rl0[58] = Pace(_rl0[10].Class:AddGroupbox({ Name = "Surgeon", Side = "Left", IconName = "heart" }))
		_rl0[58]:AddToggle("SurgeonLowHealth", { Text = "Low Health Players", Tooltip = "Highlights teammates below the health threshold.",
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
		_rl0[58]:AddSlider("SurgeonThreshold", { AllowRightClickInput = true, Text = "Low Health Threshold",
			Tooltip = "Players at or below this health percentage get highlighted.", Default = 30, Min = 5,
			Max = 100, Rounding = 0, Suffix = "%",
			["Callback"] = function(Value)
				SurgeonConfig.Threshold = Value
			end
		})
		_rl0[58]:AddDropdown("SurgeonStyle", { Values = { "Chams", "Box", "Corner Box", "Filled Box" }, Default = "Box", Text = "Highlight Style",
			Tooltip = "How low health teammates are drawn.",
			["Callback"] = function(Value)
				ApplySurgeonStyle(Value)
			end
		})
	end
	_rl0[58]:AddToggle("SurgeonSupplies", { Text = "Supplies ESP", Tooltip = "Highlights dropped medical supplies on the ground.",
		Default = false,
		["Callback"] = function(Value)
			SurgeonConfig.SuppliesESP = Value
		end
	}):AddColorPicker("SurgeonSuppliesColor", { Default = Color3.fromRGB(255, 210, 90), Title = "Supplies Color",
		["Callback"] = function(Value)
			SurgeonConfig.SuppliesColor = Value
		end
	})
	_rl0[58]:AddDivider()
	_rl0[58]:AddToggle("SurgeonAutoHeal", { Text = "Auto Heal", Tooltip = "Walks to the most hurt teammate and heals them.", Default = false,
		["Callback"] = function(Value)
			SurgeonConfig.AutoHeal = Value
			SurgeonState.Target = nil
			SurgeonState.Waypoints = nil
			SurgeonState.Goal = nil
			if not Value then
				local Character = LocalPlayer.Character
				local Root = Character and Character:FindFirstChild("HumanoidRootPart")
				local _sc2 = Character and Character:FindFirstChildOfClass("Humanoid")
				local Humanoid = _sc2
				if Root and _sc2 then
					Humanoid:MoveTo(Root.Position)
				end
			end
		end
	})
	_rl0[58]:AddDropdown("SurgeonMode", { Values = { "Legit", "Blatant" }, Default = "Legit", Text = "Mode",
		Tooltip = "Legit walks with pathfinding. Blatant flies straight to them.",
		["Callback"] = function(Value)
			SurgeonConfig.Mode = Value
		end
	})
	_rl0[58]:AddSlider("SurgeonDistance", { AllowRightClickInput = true, Text = "Max Distance",
		Tooltip = "How far away a teammate can be before it stops looking.", Default = 40, Min = 10,
		Max = 150, Rounding = 0, Suffix = "st",
		["Callback"] = function(Value)
			SurgeonConfig.MaxDistance = Value
		end
	})
	_rl0[58]:AddToggle("SurgeonAvoid", { Text = "Avoid Zombies", Tooltip = "Keeps the path out of zombie and bomber blast range.",
		Default = true,
		["Callback"] = function(Value)
			SurgeonConfig.Avoid = Value
		end
	})
	MusicianGroup = Pace(_rl0[10].Class:AddGroupbox({ Name = "Musician", Side = "Right", IconName = "music" }))
	MusicianGroup:AddToggle("AutoPlayInstrument", { Text = "Auto Play Fife/Drum",
		Tooltip = "Hits every beat for a perfect score once you start a song yourself.", Default = false,
		["Callback"] = function(Value)
			ClassConfig.AutoPlay = Value
			MusicianState.Instrument = nil
			MusicianState.Tool = nil
			MusicianState.NextScan = 0
		end
	})
end
local MenuSettingsGroup = Pace(_rl0[10].Settings:AddGroupbox({ Side = "Left", Name = "Menu", IconName = "wrench" }))
MenuSettingsGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu",
	Tooltip = "Shows the keybind list on screen.",
	["Callback"] = function(Value)
		Library.KeybindFrame.Visible = Value
	end
})
MenuSettingsGroup:AddToggle("KeybindMenuVisibilityControl", { Default = false, Text = "Keybind Menu Visibility", Tooltip = "Adds a gear to the keybind list.",
	["Callback"] = function(Value)
		Library.KeybindMenu:SetVisibilityControl(Value)
	end
})
MenuSettingsGroup:AddToggle("ShowCustomCursor", { Text = "Custom Cursor", Tooltip = "Swaps out the mouse cursor.", Default = Library.ShowCustomCursor,
	["Callback"] = function(Value)
		Library.ShowCustomCursor = Value
	end
})
MenuSettingsGroup:AddToggle("AlwaysOnTop", { Text = "Always On Top", Tooltip = "Keeps the menu above other windows.",
	Default = _rl0[9].AlwaysOnTop,
	["Callback"] = function(Value)
		_rl0[9]:SetAlwaysOnTop(Value)
	end
})
MenuSettingsGroup:AddDropdown("NotificationSide", { Values = { "Left", "Right" }, Default = "Right", Text = "Notification Side",
	Tooltip = "Where notifications pop up.",
	["Callback"] = function(Value)
		Library:SetNotifySide(Value)
	end
})
MenuSettingsGroup:AddDropdown("DPIDropdown", { Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" }, Default = "100%",
	Text = "DPI Scale", Tooltip = "Scales the whole menu.",
	["Callback"] = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)
		Library:SetDPIScale(DPI)
	end
})
MenuSettingsGroup:AddSlider("UICornerSlider", { AllowRightClickInput = true, Text = "Corner Radius", Tooltip = "How round the menu corners are.",
	Default = Library.CornerRadius, Min = 0, Max = 20, Rounding = 0,
	["Callback"] = function(Value)
		_rl0[9]:SetCornerRadius(Value)
	end
})
MenuSettingsGroup:AddDivider()
MenuSettingsGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuSettingsGroup:AddButton({ Text = "Unload",
	["Func"] = function()
		Library:Unload()
	end,
	 Tooltip = "Closes the menu and undoes everything."
})
Library.ToggleKeybind = _rl0[5].MenuKeybind
_rl0[4]:SetLibrary(Library)
_rl0[4]:IgnoreThemeSettings()
_rl0[4]:SetIgnoreIndexes({ "MenuKeybind" })
_rl0[4]:SetFolder("Umber/Default")
Breathe()
_rl0[4]:BuildConfigSection(_rl0[10].Settings)
Breathe()
_rl0[3]:ApplyToTab(_rl0[10].Settings)
Breathe()
_rl0[20] = true
_rl0[4]:LoadAutoloadConfig()
_rl0[20] = false
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
