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
local MessageFormat = "[%s][%s][%s] %s"

function Logger:_LogMessage(Prefix: any, Source, Message: any, PrintFunc)
	local Time = os.date("%H:%M:%S")
	PrintFunc(string.format(MessageFormat, Time, Source, Prefix, Message))
end

function Logger:Log(Message: any, Context: InfoType)
	if not Context then
		Context = self.InfoType.Info
	end
	local Source = getfenv(0).script.Name
	if Context == self.InfoType.Info then
		self:_LogMessage(Context, Source, Message, print)
	elseif Context == self.InfoType.Warning or Context == self.InfoType.Debug then
		self:_LogMessage(Context, Source, Message, warn)
	elseif Context == self.InfoType.Exception then
		self:_LogMessage(Context, Source, Message, error)
	end
end

function Logger:Info(...)
	local Message = tostring(...)
	local Source = getfenv(0).script.Name
	self:_LogMessage("INFO", Source, Message, print)
end

function Logger:Warn(...)
	local Message = tostring(...)
	local Source = getfenv(0).script.Name
	self:_LogMessage("WARNING", Source, Message, warn)
end

function Logger:Debug(...)
	local Message = tostring(...)
	local Source = getfenv(0).script.Name
	self:_LogMessage("DEBUG", Source, Message, warn)
end

function Logger:Exception(...)
	local Message = tostring(...)
	local Source = getfenv(0).script.Name
	self:_LogMessage("EXCEPTION", Source, Message, error)
end

return Logger
