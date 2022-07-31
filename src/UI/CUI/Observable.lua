local Signal = require(script.Parent.Signal)
local Janitor = require(script.Parent.Parent.Parent.Util.NakoJanitor)
local Observable = {
	ListenSignal = nil,
	Value = nil,
	Janitor = nil,
	ClassName = "Observable",
}
Observable.__index = Observable

function Observable.new(DefaultValue: any)
	print("New observable:", DefaultValue)
	return setmetatable({
		Value = DefaultValue,
		DefaultValue = DefaultValue,
		Janitor = Janitor.new(),
		ListenSignal = Signal.new(),
	}, Observable)
end

-- Returns the current observable value.
function Observable:Get()
	return self.Value
end

-- Sets the value of the Observable and notifies listeners about it.
function Observable:Set(Value: any)
	self.Value = Value
	self.ListenSignal:Fire(Value)
end

-- Allows you to use events such as :GetPropertyChangedSignal() in a Observable.
-- Takes in an additional processor value for processing values before sending them to the listeners.
function Observable:SetConnection(Signal: RBXScriptSignal, Processor: (any) -> any): RBXScriptConnection
	local Connection = Signal:Connect(function(Value: any)
		if Processor then
			Value = Processor(Value)
		end

		self:Set(Value)
	end)
	Janitor:Add(Connection)

	return Connection
end

-- Listens normally as a signal, rather than returning a CUI descriptor.
function Observable:ListenSignalA(Callback: ({}) -> nil)
	return self.ListenSignal:Connect(Callback)
end

-- Returns a descriptor needed for CUI to bind to a property.
function Observable:Listen(Callback: ({}) -> nil)
	return { Observable = self, ClassName = "Observable", Callback = Callback }
end

-- Disconnects every connection and makes the observable read-only.
function Observable:Destroy()
	self.ListenSignal:DisconnectAll()
	self.Value = nil
	self.DefaultValue = nil
	self.Janitor:Cleanup()

	table.freeze(self)
end

return Observable
