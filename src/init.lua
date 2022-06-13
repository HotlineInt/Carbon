local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Emulators = {
	Player = require(script:WaitForChild("Emulation").Player),
}
local Log = require(script:WaitForChild("Tier0"):WaitForChild("Logger"))
local Carbon = {
	Framework = script:WaitForChild("Framework"),
	Tier0 = script:WaitForChild("Tier0"),
	Emulation = script:WaitForChild("Emulation"),
	Network = script:WaitForChild("Network"),
	Util = script:WaitForChild("Util"),
	Data = script:WaitForChild("Data"),
	Vendor = script:WaitForChild("Vendor"),
	UI = script:WaitForChild("UI"),
	Player = Player or Emulators.Player.new({
		Name = "BloxyTek",
		DisplayName = "Cutie",
		UserId = 21450341,
		AccountAge = 18,
	}),
	Modules = {},
	Pools = {
		CharacterAdded = {},
		RenderUpdate = {},
		TickUpdate = {},
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
			Name = "BloxyTek",
			DisplayName = "Cutie",
			UserId = 21450341,
			AccountAge = 500,
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

		self.Modules[Key] = Module
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

function Carbon:Start(): nil
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
		task.spawn(function()
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
		end)
	end

	if Env == "Client" then
		RunService.RenderStepped:Connect(function(DeltaTime: number)
			for _, Update in pairs(self.Pools.RenderUpdate) do
				Update(DeltaTime)
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
