local CUI = require(script.Parent.Parent:WaitForChild("CUI"))

return function(Props: {})
	local Route = Props.Route

	return CUI:CreateElement("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(1, 0, 1, 0),
		[CUI.Children] = {
			CUI:CreateElement("TextLabel", {
				Text = 'Hit an error while loading the route "' .. Route .. '" \nCheck the output for more info',
				Size = UDim2.new(1, 0, 1, 0),
				TextSize = 24,
				BackgroundTransparency = 1,
				TextColor3 = Color3.new(0, 0, 0),
				TextWrapped = true,
				Font = Enum.Font.SourceSansBold,
				TextXAlignment = Enum.TextXAlignment.Left,

				-- top
				TextYAlignment = Enum.TextYAlignment.Top,
			}),
		},
	})
end
