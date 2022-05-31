local Folder = require(script.Parent.Folder)
local Player = {
	Name = "Roblox",
	DisplayName = "Roblox",
	UserId = 1,
	AccountAge = 0,
	Backpack = Folder(),
}
Player.__index = Player

function Player.new(Props: {})
	return setmetatable(Props, Player)
end

function Player:SetAccountAge(Age: number)
	self.AccountAge = Age
end

function Player:IsA(ClassName: string)
	return "Player"
end

function Player:GetNetworkPing()
	return math.random(1, 5000)
end

return Player
