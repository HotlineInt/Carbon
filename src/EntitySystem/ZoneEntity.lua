-- Represents a Entity with a Zone.
-- Works like Triggers in Source/Source2/Unity

local Carbon = require(game:GetService("ReplicatedStorage"):WaitForChild("Carbon"))
local ZonePlus = require(Carbon.Vendor.ZonePlus)

local Class = require(script.Parent.Parent.Util.Class)
local Entity = require(script.Parent.Entity)

local ZoneEntity, Base = Class("ZoneEntity", Entity)

function ZoneEntity:__init(Instance: Instance)
	self.Properties = {
		Enabled = false,
	}
	Base.__init(self, Instance, self.Properties)

	self.ClassName = "ZoneEntity"
	self.Zone = ZonePlus.new(Instance)

	-- Connect Zone events
	print("Connecting zones")
	self.Janitor:Add(self.Zone.playerEntered:Connect(function(Player: Player)
		if not self:GetProperty("Enabled"):GetValue() then
			return
		end
		self:OnPlayerEnter(Player)
	end))

	self.Janitor:Add(self.Zone.playerExited:Connect(function(Player: Player)
		if not self:GetProperty("Enabled"):GetValue() then
			return
		end
		self:OnPlayerExit(Player)
	end))

	if Carbon:GetEnv() == "Client" then
		self.Janitor:Add(self.Zone.localPlayerEntered:Connect(function()
			if not self:GetProperty("Enabled"):GetValue() then
				return
			end
			self:OnLocalPlayerEnter()
		end))

		self.Janitor:Add(self.Zone.localPlayerExited:Connect(function()
			if not self:GetProperty("Enabled"):GetValue() then
				return
			end
			self:OnLocalPlayerExit()
		end))
	end
end

-- Gets called when a `Player` enters the zone.
function ZoneEntity:OnPlayerEnter(Player: Player)
	print("Found Player:", Player)
end

-- Gets called when a `Player` exits the zone.
function ZoneEntity:OnPlayerExit(Player: Player)
	print("Fuck You:", Player)
end

-- Gets called when the local player enters the zone.
-- Does not work on the server.
function ZoneEntity:OnLocalPlayerEnter()
	print("Hey nerd")
end

-- Gets called when the local player exits the zone.
-- Does not work on server.
function ZoneEntity:OnLocalPlayerExit()
	print("Bye nerd")
end

-- Gets every player in the zone.
function ZoneEntity:GetPlayers()
	return self.Zone:getPlayers()
end

-- Gets every `BasePart` in the zone.
function ZoneEntity:GetParts()
	return self.Zone:getParts()
end

-- Gets every `Item` in the zone.
function ZoneEntity:GetItems()
	return self.Zone:getItems()
end

-- Gets a `Player` inside the zone.
function ZoneEntity:GetPlayer(Player: Player): Player | nil
	return self.Zone:findPlayer(Player)
end

-- Gets a `BasePart` inside the zone.
function ZoneEntity:Findpart(Part: BasePart): BasePart | nil
	return self.Zone:findPart(Part)
end

function ZoneEntity:Destroy()
	self.Zone:destroy()
	Base.Destroy(self)
end

return ZoneEntity
