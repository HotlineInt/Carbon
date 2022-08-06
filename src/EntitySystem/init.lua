local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Entity = require(script.Entity)
local System = {
	Entities = {},
	Classes = {
		["Entity"] = Entity,
		["ZoneEntity"] = require(script.ZoneEntity),
		["AudioSource"] = require(script.AudioSource),
	},
}
local Tag = require(script.EntityTag)

-- Loads all instances marked as Entities.
function System:Init()
	local Entities = CollectionService:GetTagged("Entity")

	for _, Instance: Instance in pairs(Entities) do
		self:_ICreateEntity(Instance)
	end

	CollectionService.TagAdded:Connect(function(ITag: string, Instance: Instance)
		if ITag == Tag then
			self:_ICreateEntity(Instance)
		end
	end)
end

function System:_ICreateEntity(Instance: Instance)
	print("Creating entity", Instance)
	local ClassName = Instance:GetAttribute("ClassName")
	local Entity = self:CreateEntity(Instance, ClassName, Instance:GetAttributes())

	if Entity then
		print("Adding entity", Entity)
		self:AddEntity(Entity)
	end
end

function System:RegisterEntityClass(Entity: {})
	self.Classes[Entity.ClassName] = Entity
end

function System:AddEntity(Entity: {})
	local ExistingEntity = self:GetEntity(Entity.Name)

	if ExistingEntity and ExistingEntity.GUID == Entity.GUID then
		warn("Attempt to add an entity that is already registered")
		return
	end

	table.insert(self.Entities, Entity)
end

function System:RemoveEntity(Entity: {})
	local EntityExists, Index: number = self:GetEntity(Entity.Name) ~= nil

	if not EntityExists then
		warn("Attempt to remove an entity that is not registered in the Registry", debug.traceback())
		return
	end

	table.remove(self.Entities, Index)
end

function System:CreateEntity(Instance: Instance, EntityClass: string, Properties: {})
	local Entity = self:GetClass(EntityClass)

	if not Entity then
		error("Unknown Entity Class: " .. EntityClass)
		return
	end

	-- Apply properties
	for Name, Value in pairs(Properties) do
		Instance:SetAttribute(Name, Value)
	end

	-- do it on a different thread because we cant do anything to abort the creation process
	task.spawn(function()
		local self = Entity.new(Instance, Properties)
		Entity.GUID = HttpService:GenerateGUID()

		return self
	end)
end

function System:GetEntity(Name: string)
	for Index, Entity in pairs(self.Entities) do
		if Entity.Name == Name then
			return Entity, Index
		end
	end
end

function System:GetEntityFromInstance(Instance: Instance)
	for Index, Entity in pairs(self.Entities) do
		if Entity.Instance == Instance then
			return Entity, Index
		end
	end
end

function System:GetEntities()
	return self.Entities
end

function System:GetClass(ClassName: string)
	return self.Classes[ClassName]
end

return System
