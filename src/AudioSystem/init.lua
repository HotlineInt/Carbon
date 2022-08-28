local SoundService = game:GetService("SoundService")
local ChannelClass = require(script:WaitForChild("Channel"))
local AudioSystem = { Channels = {} }

function AudioSystem:Start()
	for _, Channel in pairs(SoundService:GetDescendants()) do
		if Channel:IsA("SoundGroup") then
			self:CreateChannel(Channel)
		end
	end
end

function AudioSystem:CreateChannel(AudioChannel: SoundGroup)
	if self.Channels[AudioChannel.Name] then
		error("Channel " .. AudioChannel.Name .. " already exists")
		return
	end

	if not AudioChannel:IsA("SoundGroup") then
		error("Provided AudioChannel is not a SoundGroup")
		return
	end

	local Channel = ChannelClass.new(AudioChannel)
	self.Channels[AudioChannel.Name] = Channel

	return Channel
end

function AudioSystem:GetChannel(Name: string)
	if not self.Channels[Name] then
		error("No such audio channel exists:" .. Name)
	end

	return self.Channels[Name]
end

function AudioSystem:GetChannels()
	return self.Channels
end

return AudioSystem
