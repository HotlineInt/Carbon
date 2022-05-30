local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Emulators = {
	Player = require(script.Emulation.Player),
}
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
	Log = require(script.Tier0.Logger),
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

function Carbon:RegisterModule(Module: table | ModuleScript)
	assert(
		type(Module) == "table" or Module:IsA("ModuleScript"),
		"The provided module must be a Table or ModuleScript."
	)

	if type(Module) == "table" then
		self.Log:Log(
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
		table.insert(self.Pools, function(Delta: number)
			Module:Update(Delta)
		end)
	end
end

function Carbon:Start() end

return Carbon
