local StarterGui = game:GetService("StarterGui")
local ChatUtil = {}

function ChatUtil:MakeSystemMessage(Text: string, Config: {})
	local Merged = { Text = string.format("[SYSTEM] %s", Text) }
	if not Config then
		Config = {}
	end

	for i, v in pairs(Config) do
		Merged[i] = v
	end

	StarterGui:SetCore("ChatMakeSystemMessage", Merged)
end

return ChatUtil
