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
	Player = Player or Emulators.Player.new({
		Name = "BloxyTek",
		DisplayName = "Cutie",
		UserId = 21450341,
		AccountAge = 18,
	}),
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

return Carbon
