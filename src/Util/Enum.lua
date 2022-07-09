local Enum = {}

function Enum.new(Values: {})
	local FinalTable = {}

	for _, Value in pairs(Values) do
		FinalTable[Value] = Value
	end

	return FinalTable
end

return Enum
