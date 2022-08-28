-- init.lua - 2022/03/28
-- Purpose: Carbon-Knit bridge

local Knit = require(script:WaitForChild("Knit"):WaitForChild("Knit"))
local KnitBridge = { Util = Knit.Util }

function KnitBridge:CreateService(...)
	return Knit.CreateService(...)
end

function KnitBridge:CreateServices(Folder: Folder)
	return Knit.AddServices(Folder)
end

function KnitBridge:GetService(Name)
	return Knit.GetService(Name)
end

function KnitBridge:Start(Settings)
	return Knit.Start()
end

function KnitBridge:CreateSignal(Name: string)
	return Knit.CreateSignal(Name)
end

function KnitBridge:CreateProperty(...)
	return Knit.CreateProperty(...)
end

return KnitBridge
