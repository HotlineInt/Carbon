-- Keys.lua - 2022/04/15
-- Purpose: Keys that serve a certain purpose in CUI, like specifying a Children table or a OnEvent

return {
	Children = "CUI_CHILDREN_TABLE",
	OnEvent = function(Name)
		return "OnEvent" .. Name
	end,
	OnChange = function(Name)
		return "OnChange" .. Name
	end,
	-- Called when the Element is mounted
	OnMount = "OnMount",
	-- Called when the Element is unmounted
	OnUnmount = "UnMountEvent",

	-- Called before the Element is mounted
	BeforeMount = "BeforeMount",

	-- Called before the Element is unmounted
	BeforeUnmount = "BeforeUnMount",
	State = function(DefaultValue)
		return "State" .. DefaultValue
	end,
	Props = "CUI_COMPONENT_PROPS",
}
