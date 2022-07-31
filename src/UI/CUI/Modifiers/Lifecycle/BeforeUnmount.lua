local Keys = require(script.Parent.Parent.Parent.Keys)

return {
	Verify = function(KeyName: string, Value: any)
		return KeyName == Keys[script.Name]
	end,
	Apply = function(Element: {}, Key: string, Value: any)
		print(Element)
		Element[script.Name] = Value
	end,
}
