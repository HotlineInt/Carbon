local Carbon = require(script.Parent.Parent.Parent)
export type EventType = RemoteEvent | RemoteFunction

local Event = {}
Event.__index = Event

function Event.new(RobloxEvent: EventType)
	return setmetatable({
		Name = RobloxEvent.Name,
		Event = RobloxEvent,
		Type = RobloxEvent.ClassName,
	}, Event)
end

function Event:On(Callback)
	local RunningEnv = Carbon:GetEnv()
	local ToConnect = "OnServerEvent"

	if RunningEnv == "Client" then
		-- do the same for client
		if self.Type == "RemoteEvent" then
			ToConnect = "OnClientEvent"
		else
			ToConnect = "OnClientFunction"
		end
	elseif RunningEnv == "Server" then
		if self.Type == "RemoteEvent" then
			ToConnect = "OnServerEvent"
		else
			ToConnect = "OnServerInvoke"
		end
	end

	return self.Event[ToConnect]:Connect(Callback)
end

return Event
