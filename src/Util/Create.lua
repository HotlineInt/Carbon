function Create(ClassName: string, Props: {})
	local Instance = Instance.new(ClassName)

	for Index, Props in pairs(Props) do
		if Index == "Children" then
			for _, Child in pairs(Props) do
				Child.Parent = Instance
			end
		else
			Instance[Index] = Props
		end
	end

	return Instance
end

return Create
