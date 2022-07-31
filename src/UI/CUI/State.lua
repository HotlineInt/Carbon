local Signal = require(script.Parent.Signal)
local State = { Value = {}, _LISTEN_SIGNAL = nil }
State.__index = State

function State.new(Values: any)
	return setmetatable({ Value = Values, _LISTEN_SIGNAL = Signal.new() }, State)
end

function State:Get()
	return self.Value
end

function State:Set(NewValue: any)
	self.Value = NewValue
	return self._LISTEN_SIGNAL:Fire(self.Value)
end

function State:Listen(Callback: (any))
	return {
		State = self,
		ClassName = "CUI_STATE",
		Type = "CUI_STATE",
		Callback = Callback,
		Signal = self._LISTEN_SIGNAL,
	}
end

function State:Destroy()
	self._LISTEN_SIGNAL:DisconnectAll()
	self._LISTEN_SIGNAL = nil
	self.Value = nil

	self = nil
end

return State
