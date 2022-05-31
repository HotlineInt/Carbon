-- Centwork.lua - contact@shiroko.me - 2022/05/30
-- Description: Carbon Network System (Centwork)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventFolder = ReplicatedStorage:FindFirstChild("Events")
if not EventFolder then
	EventFolder = Instance.new("Folder", ReplicatedStorage)
	EventFolder.Name = "Events"
end

local EventClass = require(script.Event)

local Network = {
	Events = {},
}

function Network:CreateEvent(Name: string, Type: EventType)
	local Event = Instance.new(Type, EventFolder)
	Event.Name = Name
	local Class = EventClass.new(Event)
	table.insert(self.Events, Class)

	return Class
end

function Network:GetEvent(Name: string)
	for _, Event in pairs(EventFolder:GetChildren()) do
		if Event.Name == Name then
			return EventClass.new(Event)
		end
	end
end

return Network
