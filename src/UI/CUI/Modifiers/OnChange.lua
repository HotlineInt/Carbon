return {
	Verify = function(KeyName: string, Value: any)
		if KeyName:find(script.Name) then
			return true
		end
	end,
	Apply = function(Element: {},Key : string, Value: any)
		local Property = string.gsub(Key, "OnChange", "")
		Element.Instance:GetPropertyChangedSignal(Property):Connect(function()
			local NewValue = Element:GetProperty(Property)
			Value(Element, NewValue)
		end)
	end,
}
