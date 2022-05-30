type InfoType = {
	Info: string,
	Warning: string,
	Debug: string,
	Exception: string,
}
local Logger = { InfoType = {
	Info = "INFO",
	Warning = "WARNING",
	Debug = "DEBUG",
	Exception = "EXCEPTION",
} }

function Logger:Log(Message: any, Context: InfoType)
	if not Context then
		Context = self.InfoType.Info
	end
	local Time = os.date("%H:%M:%S")

	local FinalMessage = "[" .. tostring(Time) .. "] " .. "[" .. Context .. "] " .. Message

	if Context == self.InfoType.Info then
		print(FinalMessage)
	elseif Context == self.InfoType.Warning or Context == self.InfoType.Debug then
		warn(FinalMessage)
	elseif Context == self.InfoType.Exception then
		error(FinalMessage)
	end
end

return Logger
