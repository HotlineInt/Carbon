local Keys = require(script.Parent.Parent.Keys)

return {
	Verify = function(KeyName: string, Value: any)
		return KeyName == Keys[script.Name]
	end,
	Apply = function(Element: {}, Key: string, Value: any)
		Element.CUI:MarkAsScalable(Element)
	end,
}
