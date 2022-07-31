return {
	Verify = function(KeyName: string, Value: any)
		return type(Value) == "table" and Value.ClassName == "Observable"
	end,
	Apply = function(Element: {}, Name: string, Value: any)
		local PropertyName = Name
		local Observable, Callback = Value.Observable, Value.Callback

		local CurrentValue = Observable:Get()
		local Result = Callback(Element, CurrentValue)
		if not Result then
			warn("Initial state update empty")
		end

		Element:SetProperty(PropertyName, Result)

		print(Observable)
		local StateConnection = Observable.ListenSignal:Connect(function(NewValue: any)
			local Result = Callback(Element, NewValue)
			if not Result then
				warn("State update returned nothing")
			end

			Element:SetProperty(PropertyName, Result)
		end)

		table.insert(Element.StateUpdate, {
			State = Value,
			TargetElement = Element,
			Connection = StateConnection,
		})
	end,
}
