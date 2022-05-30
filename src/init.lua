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
		assert(self.Modules[Key], "The module already exists.")

		self.Modules[Key] = require(Module)
	end

	if Module["Update"] then
		table.insert(self.Pools.RenderUpdate, function(Delta: number)
			Module:Update(Delta)
		end)
	end
end

function Carbon:Start()
	Log:Log("Starting Carbon", Log.InfoType.Debug)

	-- Module Load
	for _, Module in pairs(self.Modules) do
		if Module["Load"] then
			Module:Load()
		end
	end

	RunService.RenderStepped:Connect(function(DeltaTime: number)
		for _, Update in pairs(self.Pools.RenderUpdate) do
			Update(DeltaTime)
		end
	end)

	Log:Log("Finished starting Carbon", Log.InfoType.Debug)
end

return Carbon
