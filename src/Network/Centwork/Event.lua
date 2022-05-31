local Carbon = require(script.Parent.Parent.Parent)
local RunningEnv = Carbon:GetEnv()
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

function Event:Fire(...)
	local Event = self.Event

	if RunningEnv == "Client" then
		if Event:IsA("RemoteEvent") then
			Event:FireServer(...)
		else
			Event:InvokeServer(...)
		end
	elseif RunningEnv == "Server" then
		if Event:IsA("RemoteEvent") then
			Event:FireClient(...)
		else
			Event:InvokeClient(...)
		end
	end
end

function Event:FireAllClients(...)
	if self.Event:IsA("RemoteFunction") then
		error("This only works for RemoteEvents")
	end

	return self.Event:FireAllClients(...)
end

function Event:OnEvent(Callback)
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

function Event:WaitForFire(Callback)
	if RunningEnv == "Server" then
		return self.Event.OnServerEvent:Wait()
	else
		return self.Event.OnClientEvent:Wait()
	end
end

return Event
