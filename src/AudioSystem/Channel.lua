local Create = require(script.Parent.Parent.Util.Create)
local Signal = require(script.Parent.Parent.Util.Signal)
local Channel = {
	SoundGroup = nil :: SoundGroup,
	OnSoundPlay = nil :: RBXScriptSignal,
}

Channel.__index = Channel

function Channel.new(SoundGroup: SoundGroup)
	local self = setmetatable({ SoundGroup = SoundGroup, OnSoundPlay = Signal.new() }, Channel)

	-- apply soundgroup props to sounds
	for _, Sound: Sound in pairs(self:GetSoundEffects()) do
		if not Sound:IsA("Sound") then
			continue
		end
		Sound.SoundGroup = self.SoundGroup

		Sound.Played:Connect(function(soundId)
			self.OnSoundPlay:Fire(Sound)
		end)
	end

	return self
end

function Channel:GetSoundGroup()
	return self.SoundGroup
end

type EffectType =
	"ChorusSoundEffect"
	| "DistortionSoundEffect"
	| "PitchShiftSoundEffect"
	| "ReverbSoundEffect"
	| "EchoSoundEffect"
	| "EqualizerSoundEffect"

function Channel:ApplyEffect(EffectType: EffectType, Props: {})
	local SoundEffect = Create(EffectType, Props)
	SoundEffect.Parent = self.SoundGroup

	return SoundEffect
end

function Channel:GetSound(Name: string): Sound | nil
	return self.SoundGroup:FindFirstChild(Name)
end

function Channel:GetSoundEffects(): Array<Sound>
	return self.SoundGroup:GetChildren()
end

function Channel:PlaySoundInPoint(SoundName: string, Point: BasePart | Attachment)
	local Sound = self:GetSound(SoundName)
	if Sound then
		local Clone = Sound:Clone()
		Clone.Parent = Point
		Clone:Play()

		Clone.Ended:Once(function(soundId)
			Clone:Destroy()
		end)
	end
end

function Channel:StopAll()
	for _, Sound in pairs(self:GetSoundEffects()) do
		Sound:Stop()
	end
end

return Channel
