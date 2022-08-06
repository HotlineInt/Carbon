local Janitor = require(script.Parent.Parent.Util.NakoJanitor)

local Attribute = {}
Attribute.__index = Attribute

function Attribute.new(Instance: Instance, AttributeName: string, DefaultValue: any)
	local self = setmetatable({}, Attribute)

	self.Name = AttributeName
	self.Value = Instance:GetAttribute(AttributeName) or DefaultValue

	self.Instance = Instance
	self.Janitor = Janitor.new()

	return self
end

function Attribute:Listen(Callback: (any | nil) -> nil)
	self.Janitor:Add(self.Instance:GetAttributeChangedSignal(self.Name):Connect(function()
		Callback(self.Instance:GetAttribute(self.Name))
	end))
end

function Attribute:GetValue()
	return self.Value
end

function Attribute:Destroy()
	self.Janitor:Cleanup()
	self.Instance = nil
	self.Janitor = nil
	self.Value = nil

	table.freeze(self)
end

return Attribute
