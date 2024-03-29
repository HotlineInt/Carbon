local Router = {
	Vieewer = nil,
	Routes = {},
	CurrentView = nil,
	History = {},
}

local MergeTable = require(script.Parent.Parent.Util.MergeTable)
local Signal = require(script.Parent.Parent.Util.Signal)
Router.__index = Router
local ErrorPage = require(script.ErrorPage)

function Router.new(Viewer: {}, Routes: {})
	local self = setmetatable({}, Router)

	Routes["BUILTIN_ERROR_PAGE"] = {
		Title = "CUIRouter internal error",
		View = ErrorPage,
	}

	self.Viewer = Viewer
	self.Routes = Routes
	self.OnRoute = Signal.new()

	return self
end

function Router:ResolveRoute(Route: string): {}
	local View
	local RouteView = self.Routes[Route]

	if RouteView then
		View = RouteView
	else
		View = ErrorPage({ Route = Route })
		warn("Such route does not exist:" .. Route)
	end

	return View
end

function Router:SetContent(View: {})
	-- Borders dont make sense here.
	View:SetProperty("BorderSizePixel", 0)
	View:Mount(self.Viewer)
	self.CurrentView = View
end

function Router:GenerateRoutesFromFolder(Folder: Folder): {}
	local Routes = {}

	for _, Route in pairs(Folder:GetChildren()) do
		Routes["/" .. string.lower(Route.Name)] = {
			Title = Route.Name,
			View = require(Route),
		}
	end

	return Routes
end

-- Goes to a route. Displays an error page if theres none.
function Router:GoTo(Route: string, Props: {}): {} | {}
	if self.CurrentView then
		self.CurrentView:Destroy()
	end

	if not Props then
		Props = {}
	end

	local View = self:ResolveRoute(Route)
	local ElementView

	if type(View) == "table" and View["Is_Element"] then
		-- we hit the error page
		self:SetContent(View)
		ElementView = View
	else
		ElementView = self:SetContent(View.View(MergeTable({ Router = self }, Props)))
	end

	self.OnRoute:Fire(Route, View, ElementView)
	return View, ElementView
end

function Router:GetRoutes()
	local Routes = self.Routes

	-- We dont want that garbage here!
	Routes["BUILTIN_ERROR_PAGE"] = nil

	return Routes
end

function Router:GoBack() end

return Router
