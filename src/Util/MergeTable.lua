return function(Table1: {}, Table2: {})
	local NewTable = {}
	for Key, Value in pairs(Table1) do
		NewTable[Key] = Value
	end
	for Key, Value in pairs(Table2) do
		NewTable[Key] = Value
	end
	return NewTable
end
