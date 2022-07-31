return {
	Verify = function(KeyName: string, Value: any)
		return type(Value) == "table" and Value.ClassName == "CUI_STATE"
	end,
	Apply = function(Element: {}, Name: string, Value: any)
		local Callback = Value.Callback
		local PropertyName = Name

		local CurrentValue = Value.State:Get()
		local Result = Callback(Element, CurrentValue)
		if not Result then
			warn("Initial state update empty")
		end

		Element:SetProperty(PropertyName, Result)

		local StateConnection = Value.Signal:Connect(function(NewValue: any)
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
