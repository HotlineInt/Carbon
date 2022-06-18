local Class = require(script.Parent.Class)
local Janitor = Class("Janitor")

function Janitor:__init()
	self.Connections = {}
end

function Janitor:Add(Connection: RBXScriptConnection)
	table.insert(self.Connections, Connection)
end

function Janitor:Cleanup()
	for Index, Connection in pairs(self.Connections) do
		Connection:Disconnect()
		table.remove(self.Connections, Index)
	end
end

return Janitor
