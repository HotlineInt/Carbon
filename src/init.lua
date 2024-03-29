local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Emulators = {
	Player = require(script:WaitForChild("Emulation").Player),
}
local ModuleLoader = require(script.ModuleLoader)
local Log = require(script:WaitForChild("Tier0"):WaitForChild("Logger"))
local Carbon = {
	-- backwards compatibility:
	Framework = script:WaitForChild("Interop"),
	-- but you should be using this instead of Framework
	Interop = script:WaitForChild("Interop"),
	Tier0 = script:WaitForChild("Tier0"),
	Emulation = script:WaitForChild("Emulation"),
	Network = script:WaitForChild("Network"),
	Util = script:WaitForChild("Util"),
	Data = script:WaitForChild("Data"),
	Vendor = script:WaitForChild("Vendor"),
	UI = script:WaitForChild("UI"),
	EntitySystem = script:WaitForChild("EntitySystem"),
	AudioSystem = script:WaitForChild("AudioSystem"),
	Player = Player
		-- emulate the player here for server access
		-- ! DO NOT USE EMULATORS IN PRODUCTION !
		or Emulators.Player.new({
			Name = "UNKNOWN+DN",
			DisplayName = "Unknown",
			UserId = 1,
			AccountAge = 999999999999,
		}),
	Instance = script,
	Modules = {},
	Pools = {
		CharacterAdded = {},
		RenderUpdate = {},
		TickUpdate = {},

		-- UNUSED: Reserved for CUI UI Updates
		UIUpdate = {},
	},
}

function Carbon:GetPlayer(Name: string): Player
	if Name == nil then
		return Player
	end
	local FoundPlayer = Players:FindFirstChild(Name)

	return FoundPlayer
		or Player
		or Emulators.Player.new({
			Name = "ROBLOX",
			DisplayName = "c_unload_pl",
			UserId = 1,
			AccountAge = 16,
		})
end

function Carbon:IsStudio(): boolean
	return RunService:IsStudio()
end

function Carbon:GetEnv(): "Server" | "Client"
	if RunService:IsServer() then
		return "Server"
	elseif RunService:IsClient() then
		return "Client"
	end
end

function Carbon:RegisterModule(Module: {} | ModuleScript): nil
	assert(
		type(Module) == "table" or Module:IsA("ModuleScript"),
		"The provided module must be a Table or ModuleScript."
	)

	if type(Module) == "table" then
		Log:Log(
			"WARNING: Registering a module by table reference is not recommended and will remove its key in Carbon.Modules. Provide the ModuleScript instead.",
			self.Log.InfoType.Warning
		)
		table.insert(self.Modules, Module)
	else
		local Key = Module.Name
		assert(self.Modules[Key] == nil, "The module already exists.")
		Module = require(Module)

		-- FIXME: find a way to make this work &
		--self.Modules[Key] = Module
		table.insert(self.Modules, Module)
	end

	if Module["Update"] then
		table.insert(self.Pools.RenderUpdate, function(Delta: number)
			Module:Update(Delta)
		end)
	end

	if Module["Tick"] then
		table.insert(self.Pools.TickUpdate, function(Delta: number)
			Module:Tick(Delta)
		end)
	end
end

function Carbon:RegisterFromFolder(Folder: Folder, Recursive: boolean)
	local Modules = if Recursive then Folder:GetDescendants() else Folder:GetChildren()

	for _, Module in pairs(Modules) do
		self:RegisterModule(Module)
	end
end

function Carbon:Start(WaitForModuleLoad: boolean): nil
	local Env = self:GetEnv()
	Log:Log("Starting Carbon", Log.InfoType.Debug)

	if Env == "Client" then
		Player.CharacterAdded:Connect(function(Character)
			for _, Module in pairs(self.Pools.CharacterAdded) do
				task.spawn(function()
					Module:OnCharacterAdded(Character)
				end)
			end
		end)
	end
	local ModulesLoaded = 0

	-- Module Load
	for _, Module in pairs(self.Modules) do
		local function LoadModule()
			ModuleLoader(self, Module)
			if Env == "Client" then
				if Module["OnCharacterAdded"] then
					-- insert into characteradded pool
					table.insert(self.Pools.CharacterAdded, Module)
				end
			end

			if Module["Load"] then
				Module:Load()
			end

			ModulesLoaded += 1
		end

		if WaitForModuleLoad then
			LoadModule()
		else
			task.spawn(LoadModule)
		end
	end

	if Env == "Client" then
		RunService.RenderStepped:Connect(function(DeltaTime: number)
			for _, Update in pairs(self.Pools.RenderUpdate) do
				Update(DeltaTime)
			end
		end)

		RunService.Heartbeat:Connect(function(DeltaTime: number)
			for _, Updater in pairs(self.Pools.UIUpdate) do
				Updater(DeltaTime)
			end
		end)
	else
		RunService.Heartbeat:Connect(function(deltaTime)
			for _, Update in pairs(self.Pools.TickUpdate) do
				Update(deltaTime)
			end
		end)
	end

	Log:Log(string.format("Loaded %d modules", ModulesLoaded), Log.InfoType.Debug)
	Log:Log("Finished starting Carbon", Log.InfoType.Debug)
end

return Carbon
