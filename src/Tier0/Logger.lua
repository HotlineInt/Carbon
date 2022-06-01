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
local MessageFormat = "[%s][%s] %s"

function Logger:_LogMessage(Prefix: any, Message: any, PrintFunc)
	local Time = os.date("%H:%M:%S")
	PrintFunc(string.format(MessageFormat, Time, Prefix, Message))
end

function Logger:Log(Message: any, Context: InfoType)
	if not Context then
		Context = self.InfoType.Info
	end
	if Context == self.InfoType.Info then
		self:_LogMessage(Context, Message, print)
	elseif Context == self.InfoType.Warning or Context == self.InfoType.Debug then
		self:_LogMessage(Context, Message, warn)
	elseif Context == self.InfoType.Exception then
		self:_LogMessage(Context, Message, error)
	end
end

function Logger:Info(...)
	local Message = tostring(...)
	self:_LogMessage("INFO", Message, print)
end

function Logger:Warn(...)
	local Message = tostring(...)
	self:_LogMessage("WARNING", Message, warn)
end

function Logger:Debug(...)
	local Message = tostring(...)
	self:_LogMessage("DEBUG", Message, warn)
end

function Logger:Exception(...)
	local Message = tostring(...)
	self:_LogMessage("EXCEPTION", Message, error)
end

return Logger
