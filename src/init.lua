local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Emulators = {
	Player = require(script.Emulation.Player),
}
local Log = require(script.Tier0.Logger)
local Carbon = {
	Tier0 = script:WaitForChild("Tier0"),
	Emulation = script:WaitForChild("Emulation"),
	Network = script:WaitForChild("Network"),
	Util = script:WaitForChild("Util"),
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
	},
}

function Carbon:GetPlayer(Name: string)
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

function Carbon:IsStudio()
	return RunService:IsStudio()
end

function Carbon:GetEnv()
	if RunService:IsServer() then
		return "Server"
	elseif RunService:IsClient() then
		return "Client"
	end
end

function Carbon:RegisterModule(Module: table | ModuleScript)
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
end

function Carbon:Start()
	Log:Log("Starting Carbon", Log.InfoType.Debug)

	Player.CharacterAdded:Connect(function(Character)
		for _, Module in pairs(self.Pools.CharacterAdded) do
			Module:OnCharacterAdded(Character)
		end
	end)
	local ModulesLoaded = 0

	-- Module Load
	for _, Module in pairs(self.Modules) do
		task.spawn(function()
			if Module["OnCharacterAdded"] then
				-- insert into characteradded pool
				table.insert(self.Pools.CharacterAdded, Module)
			end

			if Module["Load"] then
				Module:Load()
			end

			ModulesLoaded += 1
		end)
	end

	RunService.RenderStepped:Connect(function(DeltaTime: number)
		for _, Update in pairs(self.Pools.RenderUpdate) do
			Update(DeltaTime)
		end
	end)

	Log:Log(string.format("Loaded %d modules", ModulesLoaded), Log.InfoType.Debug)
	Log:Log("Finished starting Carbon", Log.InfoType.Debug)
end

return Carbon
