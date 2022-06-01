local Random = {}

function Random:randf(Min: number, Max: number)
	local diff = math.random() * (Min - Max)
	return Min + diff
end

function Random:rlist(List: {})
	return List[math.random(1, #List)]
end

return Random
