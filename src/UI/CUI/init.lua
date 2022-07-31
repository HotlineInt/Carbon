-- init.lua - Shirozii (contact@shiroko.me) - 2022/04/09
-- Description: Carbon GUI System (CGUI or CUI)

local CollectionService = game:GetService("CollectionService")
local Element = require(script.Element)
local Keys = require(script.Keys)
local CUI = {
	Children = Keys.Children,
	OnEvent = Keys.OnEvent,
	OnChange = Keys.OnChange,
	OnMount = Keys.OnMount,
	OnUnmount = Keys.OnUnmount,
	BeforeMount = Keys.BeforeMount,
	Scaleable = Keys.Scaleable,
	Custom = Keys.Custom,
	BeforeUnmount = Keys.BeforeUnmount,
	Props = Keys.Props,
}

export type Element = {
	Type: string,
	ClassName: string,
	Properties: table,
	Connections: table,
	Tweens: table,
	Children: table,
	StateUpdate: table,
	Changed: RBXScriptSignal,
	Is_Element: boolean,
	Parent: Element,
}

-- Creates a brand new CUI element.
function CUI:CreateElement(Type, Properties): Element
	assert(type(Type) == "string", "Type must be a valid string")
	assert(type(Properties) == "table", "Properties must be a valid table")

	if type(Type) == "table" and Type.ClassName == "cui_component" then
		local Element = Type:Create(Properties)
		return Element
	end

	local Viewport = Element.new(Type, Properties)
	return Viewport
end

function CUI:RequiredProp(Prop: any, ExpectedValue: any)
	if typeof(Prop) ~= ExpectedValue then
		warn(
			string.format(
				"Prop %s is null or has an incorrect type, Expected %s got %s",
				Prop,
				ExpectedValue,
				typeof(ExpectedValue)
			)
		)
	end

	return Prop ~= ExpectedValue
end

function CUI:ComputeCondition(Condition, Callback, ...): ()
	if Condition then
		return Callback(...)
	end
end

function CUI:MarkAsScalable(Viewport: table)
	local UIScale = Viewport:Add("UIScale", { Name = "GlobalUIScale" }, {})
	CollectionService:AddTag(UIScale.Instance, "ScalableUI")
end

function CUI:UnmarkAsScalable(Viewport: {})
	local GlobalScaleElement = Viewport:Get("GlobalUIScale")

	if GlobalScaleElement then
		GlobalScaleElement.Instance:Destroy()
	end
end

function CUI:SetGlobalScale(ScaleMultiplier: number)
	for _, Scale: UIScale in pairs(CollectionService:GetTagged("ScalableUI")) do
		-- basic optimization; we dont want to scale UI that isnt even enabled.

		-- nvm this is dumb lol
		-- if not Scale.Parent.Enabled then
		-- 	return
		-- end

		Scale.Scale = ScaleMultiplier
	end
end

function CUI:ConvertExisting(GUIObject: GuiObject): Element
	local function AddAndCreate(Object: GuiObject)
		local object = CUI:CreateElement(GUIObject.ClassName, {})
		object.Instance:Destroy()
		object.Instance = Object
		object.Children = {}

		for _, Child in pairs(object.Instance:GetChildren()) do
			table.insert(object.Children, AddAndCreate(Child))
		end

		return object
	end

	return AddAndCreate(GUIObject)
end

return CUI
