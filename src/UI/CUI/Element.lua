local Spring = require(script.Parent.Spring)
local Signal = require(script.Parent.Signal)
local Promise = require(script.Parent.Parent.Parent.Util.Promise)
local TweenService = game:GetService("TweenService")

local Element = {
	Type = "Unknown",
	ClassName = "Element",
	Properties = {},
	Connections = {},
	Tweens = {},
	Children = {},
	StateUpdate = {},
	Changed = Signal.new(),
	Is_Element = true,
	Parent = nil,
}
Element.__index = Element

local BadProperties = require(script.Parent.BadProperties)
local Keys = require(script.Parent.Keys)

function Element.new(Type: string, Properties: table)
	local self = setmetatable({}, Element)

	-- self.Connections = {}
	-- self.Tweens = {}
	-- self.Children = {}
	-- self.StateUpdate = {}
	self.Type = Type
	self.Properties = Properties
	self.Instance = Instance.new(Type)

	if self.Properties then
		Element:_applyproperties(self, Properties)
	end

	return self
end

function Element:IsA(ClassName: string)
	return self.Instance.ClassName == ClassName
end

-- Calls an inner Roblox Method.
--[[

	```
		for _,Child in pairs(Element:CallRobloxMethod("GetChildren")) do
			print(Child) -- Output: SomeChildName
		end
	```
]]
function Element:CallRobloxMethod(Method: string, ...)
	return self.Instance[Method](self.Instance, ...)
end

-- Sets a property with the given Value
function Element:SetProperty(Name: string, Value: any)
	--	print(self.Instance:GetFullName())
	self.Instance[Name] = Value
	self.Changed:Fire(Name, Value)
end

-- Gets a value of a property.
function Element:GetProperty(Name: string, Value: any)
	return self.Instance[Name]
end

-- Internal method to apply properties (and children) to an Element
function Element:_applyproperties(Element, Properties)
	local OnEventSub = 7
	local OnChangeSub = 8

	for Name, Value in pairs(Properties) do
		if Name == Keys.Children then -- fusion/roact like children structure
			for Type, Component in pairs(Value) do
				task.spawn(function()
					-- normal roblox instances (for viewportframes)
					if Component:IsA("Instance") then
						Component.Parent = self.Instance
					elseif Component["Is_Element"] or Component.ClassName == "cui_component" then
						Element:Add(Component)
					elseif not Component["ClassName"] then
						Element:Add(Type, Component)
					-- this lets us properly handle pre-made components in children table
					else
						Element:Add(Component["ClassName"], Component)
					end
				end)
			end
			-- Event
		elseif type(Name) == "string" and Name:sub(1, OnEventSub) == "OnEvent" then
			local EventName = string.gsub(Name, "OnEvent", "")
			Element:On(EventName, Value)
		elseif type(Value) == "table" and Value.Type == "CUI_STATE" then
			local Callback = Value.Callback
			local PropertyName = Name

			local CurrentValue = Value.State:Get()
			local Result = Callback(Element, CurrentValue)
			if not Result then
				warn("Initial state update empty")
			end

			Element:SetProperty(PropertyName, Result)

			local StateConnection = Value.Signal:Connect(function(NewValue: any)
				local Result = Callback(Element, NewValue)
				if not Result then
					warn("State update returned nothing")
				end

				Element:SetProperty(PropertyName, Result)
			end)

			table.insert(Element.StateUpdate, {
				State = Value,
				TargetElement = Element,
				Connection = StateConnection,
			})
		elseif type(Name) == "string" and Name:sub(1, OnChangeSub) == "OnChange" then
			local Property = string.gsub(Name, "OnChange", "")
			Element.Instance:GetPropertyChangedSignal(Property):Connect(function()
				local NewValue = Element:GetProperty(Property)
				Value(Element, NewValue)
			end)
		elseif type(Name) == "string" and Name == Keys.OnMount then
			Element.OnMount = Value
		elseif type(Name) == "string" and Name == Keys.OnUnmount then
			Element.OnUnmount = Value
		elseif type(Name) == "string" and Name == Keys.BeforeMount then
			Element.BeforeMount = Value
		elseif type(Name) == "string" and Name == Keys.BeforeUnmount then
			Element.BeforeUnmount = Value
		elseif type(Name) == "string" and Name == Keys.OnUpdate then
			-- TODO: add to carbon UI update pool
		else -- normal properties
			-- We don't want to assign bad properties and clutter up the output:
			if table.find(BadProperties, Name) then
				continue
			end
			local Success, Fail = pcall(function()
				Element.Instance[Name] = Value
			end)
		end
	end
end

-- Called right after an element is mounted
function Element:OnMount(self, Parent: {}) end

-- Called right before an element is unmounted
function Element:OnUnmount(self, Parent: {}) end

-- Called right before an element is munted
function Element:BeforeMount(self) end

-- Called rigt before an element is unmounted
function Element:BeforeUnmount(self) end

-- Adds a Element with the given properties to ```self```
function Element:Add(Type, Properties: table, RobloxNative: table)
	local new_element

	-- Sometimes we're all lazy, right?
	if not Properties then
		Properties = {}
	end

	-- more and more edge cases... my head is getting dizzy..
	if type(Type) == "function" then
		warn("Function-elements are deprecated and will result in a not a valid member call soon.")
		return
		-- new_element = Type(Properties)

		-- -- fallback
		-- if RobloxNative == nil then
		-- 	RobloxNative = Properties
		-- end

		-- -- RobloxNative is used to set Roblox-Native properties rather than pass thru Props to components.
		-- -- ! This used to crash the entirety of CUI by passing thru new_element.Instance instead of just the table.
		-- -- ! end me.
		-- Element:_applyproperties(new_element, RobloxNative)
	elseif type(Type) == "string" then
		warn("String-elements are deprecated and will result in a not a valid member call soon.")
		return
		--	new_element = Element.new(Type, Properties)
	elseif Type.ClassName == "Element" then
		-- Certain edge-case where we want to add a already created component.
		new_element = Type
		-- Pretty sure this is a wasted call.
		--	Element:_applyproperties(new_element, Properties)
	elseif Type.ClassName == "cui_component" then
		Type:InternalRender()
		Type:GetGUI():Mount(self)
	end

	if new_element == nil then
		error("CUI has experienced an internal error: Given element has failed to create.")
	end

	table.insert(self.Children, new_element)
	new_element:Mount(self)

	return new_element
end

function Element:AddElement(...)
	return self:Add(...)
end

function Element:Get(Name: string | Instance)
	for _, Child in pairs(self.Children) do
		-- try to fix a bug where we SOMEHOW got garbage from other elements.
		if not Child.Instance:IsDescendantOf(self.Instance) then
			continue
		end
		if Child.Instance.Name == Name then
			return Child
		elseif Child.Instance == Name then
			return Child.Instance
		end
	end

	-- ! This error is useless. Would probably re-add later. I dont know. - Shiroko
	--error("Unknown Child: " .. Name .. "\n" .. debug.traceback())
end

function Element:GetDescendants()
	local Descendants = {}

	local function GetChildren(Child)
		table.insert(Descendants, Child)
		if Child.Children == {} then
			return
		end
		for _, Child in pairs(Child.Children) do
			table.insert(Descendants, Child)
			GetChildren(Child)
		end
	end

	for _, Child in pairs(self.Children) do
		GetChildren(Child)
	end

	return Descendants
end

function Element:On(EventName, Callback)
	local Event = self.Instance[EventName]
	local us = self

	if typeof(Event) == "RBXScriptSignal" then
		local connection = Event:Connect(function(...)
			Callback(us, ...)
		end)
		table.insert(self.Connections, {
			connection = connection,
			name = EventName,
			Host = self.Instance,
			callback = Callback,
		})

		return connection
	end
end

function Element:Clone()
	local new_element = table.copy(self)
	new_element.Instance = new_element.Instance:Clone()
	return new_element
end

function Element:FireEvent(Name, ...)
	for _, Connection in pairs(self.Connections) do
		if Connection.name == Name and Connection.connection.Connected then
			Connection.callback(...)
		end
	end
end

function Element:Mount(Parent: Instance)
	if Parent == nil then
		warn("Warning: Setting parent to nil.", debug.traceback())
	end

	if type(Parent) == "table" and Parent["Instance"] then
		self.Instance.Parent = Parent.Instance
	else -- instance
		self.Instance.Parent = Parent
	end

	self.Parent = Parent

	if Parent then
		print("Mounting")
		self:OnMount(self, Parent)
	end

	
end

function Element:Unmount()
	self:OnUnmount(self)
	self.Parent = nil
end

-- Cleansup and locks the element to prevent errors.
function Element:Destroy()
	for _, connection in pairs(self.Connections) do
		if connection.Host == self.Instance then
			connection.connection:Disconnect()
		end
	end
	self:OnUnmount()
	for _, Tween in pairs(self.Tweens) do
		Tween:Destroy()
	end
	self.Properties = nil
	self.Type = nil
	for Index, StateUpdater in pairs(self.StateUpdate) do
		print("IsTarget: ", StateUpdater.TargetElement == self)
		if StateUpdater.TargetElement == self then
			print("Still disconnecting \n Target:", StateUpdater.TargetElement, "self:", self)
			StateUpdater.Connection:Disconnect()
			self.StateUpdate[Index] = nil
		end
	end

	self.Instance:Destroy()
	self.Children = nil

	table.freeze(self)
end

function Element:AnimateTweenPromise(Info: Tween, Properties: table)
	return Promise.new(function(resolve, reject, onCancel)
		local tween = TweenService:Create(self.Instance, Info, Properties)

		-- No idea what this even means
		if onCancel(function()
			tween:Cancel()
		end) then
			return
		end

		-- :AnimateTween() is meant to be called once
		tween.Completed:Once(resolve)
		tween:Play()
	end)
end

function Element:AnimateTween(Info: Tween, Properties: table)
	local Tween = TweenService:Create(self.Instance, Info, Properties)
	Tween:Play()
	table.insert(self.Tweens, Tween)
end

function Element:AnimateSpring(DRatio, Frequency, Properties)
	-- animate with spring.target
	if not Properties then
		Properties = {}
	end
	Spring.target(self.Instance, DRatio, Frequency, Properties)
end

function Element:CancelSpring()
	Spring.stop(self.Instance)
end

return Element
