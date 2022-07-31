-- Keys.lua - 2022/04/15
-- Purpose: Keys that serve a certain purpose in CUI, like specifying a Children table or a OnEvent

return {
	Children = "CUI_CHILDREN_TABLE",
	OnEvent = function(Name)
		return "OnEvent" .. Name
	end,
	Scaleable = "Scaleable",
	OnChange = function(Name)
		return "OnChange" .. Name
	end,
	-- Called when the Element is mounted
	OnMount = "OnMount",
	-- Called when the Element is unmounted
	OnUnmount = "OnUnmount",

	-- Called before the Element is mounted
	BeforeMount = "BeforeMount",
	Custom = function(FuncName: string)
		return "Custom" .. FuncName
	end,

	-- Called before the Element is unmounted
	BeforeUnmount = "BeforeUnmount",
	State = function(DefaultValue)
		return "State" .. DefaultValue
	end,
	Props = "CUI_COMPONENT_PROPS",
}
