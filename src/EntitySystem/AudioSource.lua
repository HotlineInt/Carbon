-- Represents a Entity with a sound

local Carbon = require(game:GetService("ReplicatedStorage"):WaitForChild("Carbon"))

local Class = require(script.Parent.Parent.Util.Class)
local Entity = require(script.Parent.Entity)

local Sound, Base = Class("Sound", Entity)
local IInstance = Instance

local LocalizedProps = {
	Playing = "Playing",
	Looped = "Looped",
	Speed = "PlaybackSpeed",
	Position = "TimePosition",
	Volume = "Volume",
	RangeMax = "RollOffMaxDistance",
	RangeMin = "RollOffMinDistance",
	Sound = "SoundId",
}

function Sound:__init(Instance: Instance)
	Base.__init(self, Instance, {
		Playing = false,
		Looped = false,
		Speed = 1,
		Position = 0,
		RangeMin = 1500,
		RangeMax = 1500,
		Volume = 1,
		Sound = "rbxassetid://5048077804",
	})

	self.Sound = IInstance.new("Sound") :: Sound
	self.Sound.Parent = Instance

	for Name, Prop in pairs(self.Properties) do
		local LocalizedName = LocalizedProps[Name]
		local Value = Prop:GetValue()

		-- roblox is FUCKING retarded so i have to do this
		local function pissoff()
			pcall(function()
				self.Sound[LocalizedName] = Value
			end)
		end

		pissoff()
	end

	self:GetProperty("Sound"):Listen(function(Sound)
		if not Sound:find("rbxassetid://") then
			Sound = "rbxassetid://%s" .. tostring(Sound)
		end

		self.Sound.SoundId = Sound
	end)

	self:GetProperty("Looped"):Listen(function(Looped)
		self.Sound.Looped = Looped
	end)

	self:GetProperty("Playing"):Listen(function(Playing)
		if Playing then
			self.Sound:Play()
		else
			self.Sound:Stop()
		end
	end)

	self:GetProperty("Speed"):Listen(function(Speed)
		self.Sound.PlaybackSpeed = Speed
	end)

	self:GetProperty("Position"):Listen(function(Position)
		self.Sound.TimePosition = Position
	end)

	self:GetProperty("RangeMax"):Listen(function(Range)
		self.Sound.RollOffMaxDistance = Range
	end)

	self:GetProperty("RangeMin"):Listen(function(Range)
		self.Sound.RollOffMaxDistance = Range
	end)
end

function Sound:Play()
	self:SetProperty("Playing", true)
end

function Sound:Stop()
	self:SetProperty("Playing", false)
end

return Sound
