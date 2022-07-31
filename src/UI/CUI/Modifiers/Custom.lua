-- Allows for custom functions.
local Keys = require(script.Parent.Parent.Keys)

return {
	Verify = function(KeyName: string, Value: any)
		if KeyName:find(script.Name) then
			return true
		end
	end,
	Apply = function(Element: {}, Key: string, Value: any)
		local FuncName = Key:gsub(script.Name, "")
		print(FuncName)
		Element[FuncName] = Value
	end,
}
