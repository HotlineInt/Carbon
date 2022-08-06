-- Represents an Entity. Can be extended for Extra behaviour.
local Carbon = require(game:GetService("ReplicatedStorage"):WaitForChild("Carbon"))

local Class = require(script.Parent.Parent.Util.Class)
local Janitor = require(script.Parent.Parent.Util.NakoJanitor)

local Signal = require(script.Parent.Parent.Util.Signal)

local Attribute = require(script.Parent.Attribute)

local Entity = Class("entity")

function Entity:__init(Instance: Instance, DefaultProps: {})
	self.Name = Instance.Name
	self.ClassName = "Entity"
	self.Components = {}
	self.Instance = Instance
	self.CreationFailed = false
	self.Janitor = Janitor.new()

	-- merge the two tables
	self.Properties = {
		ClientOnly = Attribute.new(Instance, "ClientOnly", false),
		ServerOnly = Attribute.new(Instance, "ServerOnly", false),
	}
	for k, v in pairs(DefaultProps) do
		self.Properties[k] = v
	end

	self.Destroying = Signal.new()

	-- Fill in missing props with default values
	for Name, Value in pairs(DefaultProps) do
		if not Instance:GetAttribute(Name) then
			Instance:SetAttribute(Name, Value)
			self.Properties[Name] = Attribute.new(Instance, Name, Value)
		end
	end

	for Name in pairs(Instance:GetAttributes()) do
		self.Properties[Name] = Attribute.new(Instance, Name)
	end

	if self:GetProperty("ClientOnly"):GetValue() and Carbon:GetEnv() ~= "Client" then
		print("Entity is client only, but we are not on the client, aborting constructor")
		self:_EARLY_DESTROY()
		return
	end

	if self:GetProperty("ServerOnly"):GetValue() and Carbon:GetEnv() ~= "Server" then
		print("Entity is server only, but we are not on the server, aborting constructor")
		self:_EARLY_DESTROY()
		return
	end

	self:ListenToAttributes(function(Attribute: {}, Value: any)
		self:SetProperty(Attribute.Name, Value)
	end)
	self:InitAttributes()
end

-- Sets up base attributes for the entity.
-- unused atm
function Entity:InitAttributes() end

function Entity:ListenToAttributes(Callback: ({}, any) -> nil)
	for Name, Attribute in pairs(self.Properties) do
		Attribute:Listen(function(NewValue: any)
			Callback(Attribute, NewValue)
		end)
	end
end

function Entity:GetProperty(Name: string)
	return self.Properties[Name]
end

function Entity:SetProperty(Name: string, Value: any)
	self.Properties[Name].Value = Value
end

function Entity:_EARLY_DESTROY()
	self.Janitor:Cleanup()
	self.Janitor = nil
	self.Destroying = nil
	self.Properties = {}

	table.freeze(self)

	-- hang the current thread
	coroutine.yield()
end

function Entity:Destroy()
	self.Destroying:Fire()
	self.Janitor:Cleanup()
	self.Instance = nil
	self.Janitor = nil

	for _, Attribute in pairs(self.Properties) do
		Attribute:Destroy()
	end

	self.Properties = nil
	self.Components = nil

	table.freeze(self)
end

return Entity
