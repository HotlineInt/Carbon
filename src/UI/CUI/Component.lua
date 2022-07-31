-- For reference look at something like React's component class
local Class = require(script.Parent.Parent.Parent.Util.Class)
local Component = Class("cui_component")

function Component:__init(Props: {})
	self.Props = Props
end

-- Method for rendering. Automatically sets self.Gui to whatever this returns.
function Component:Render()
	return {}
end

function Component:GetGUI()
	return self.UI
end

-- Internal renderer call
function Component:InternalRender()
	local UI = self:Render()
	print(UI)
	UI.Component = self
	self.UI = UI

	return UI
end

--[[
    Sets a table of children's properties.

    ```
    Component::SetProps({
        Root = {
            BackgroundColor3 = Color3.new(1, 1, 1),
        },
        SomeChild = {
            Text = "Hello, World!"
        }
    })
    ```

]]
--
function Component:SetProps(Props: {
	string: { any: any },
})
	local GUI = self:GetGUI()
	for ChildName, Properties in pairs(Props) do
		local ObjectToApply

		if ChildName ~= "_ROOT" then
			local Child = GUI:Get(ChildName)

			if Child then
				ObjectToApply = Child
			end
		else
			ObjectToApply = GUI
		end

		for Name, Value in pairs(Properties) do
			ObjectToApply:SetProperty(Name, Value)
		end
	end
end

function Component:Update() end

function Component:OnMount() end

function Component:OnUnmount() end

return Component
