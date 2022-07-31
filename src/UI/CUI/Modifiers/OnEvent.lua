return {
	Verify = function(KeyName: string, Value: any)
		if KeyName:find(script.Name) then
			return true
		end
	end,
	Apply = function(Element: {}, Key: string, Value: any)
		local EventName = string.gsub(Key, script.Name, "")
		Element:On(EventName, Value)
	end,
}
