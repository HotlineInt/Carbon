local Keys = require(script.Parent.Keys)
local IllegalProperties = require(script.Parent.BadProperties)

local Modifiers = {}
for _, Modifier in pairs(script.Parent.Modifiers:GetDescendants()) do
	-- Filter out non-modules
	if not Modifier:IsA("ModuleScript") then
		continue
	end
	Modifiers[Modifier.Name] = require(Modifier)
end

local function ModifierPass(Element: {}, Name: any, Value: any)
	for _, Modifier in pairs(Modifiers) do
		if Modifier.Verify(Name, Value) then
			Modifier.Apply(Element, Name, Value)
			return
		end
	end
end

return function(ParentElement: {}, Element: {}, Properties: { string: any })
	for Name, Value in pairs(Properties) do
		ModifierPass(Element, Name, Value)
		if Name == Keys.Children then -- fusion/roact like children structure
			for _, Component in pairs(Value) do
				task.spawn(function()
					-- normal roblox instances (for viewportframes)
					if Component:IsA("Instance") then
						Component.Parent = ParentElement.Instance
					elseif Component.ClassName == "Element" or Component.ClassName == "cui_component" then
						Element:Add(Component)
					end
				end)
			end
		elseif type(Value) == "table" then
			if Value.ClassName == "Observable" then
				Modifiers["Observable"].Apply(Element, Name, Value)
			elseif Value.ClassName == "CUI_STATE" then
				Modifiers["State"].Apply(Element, Name, Value)
			end
		else
			-- We don't want to assign bad properties and clutter up the output:
			if table.find(IllegalProperties, Name) then
				continue
			end
			local Success, Fail = pcall(function()
				Element.Instance[Name] = Value
			end)

			-- if not Success then
			-- 	warn("Failed to set property: " .. Name .. ": " .. tostring(Fail))
			-- end
		end
	end
end
