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

function Logger:Log(Message: any, Type: InfoType)
	local Time = os.date("%H:%M:%S")
	local Value = self.InfoType[Type]
	local FinalMessage = "[" .. tostring(Time) .. "] " .. "[" .. Value .. "] " .. Message

	if Type == self.InfoType.Info then
		print(FinalMessage)
	elseif Type == self.InfoType.Warning or Type == self.InfoType.Debug then
		warn(FinalMessage)
	elseif Type == self.InfoType.Exception then
		error(FinalMessage)
	end
end

return Logger
