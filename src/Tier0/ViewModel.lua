local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollisionGroupConstants = require(ReplicatedStorage:WaitForChild("CollisionGroupConstants"))

local Class = require(script.Parent.Parent.Util.Class)

local Camera = workspace.CurrentCamera

local ViewModel = Class("ViewModel")

function ViewModel:__init(Model: Model)
	self.Mounted = false
	self.Animations = {}
	self.OOBPosition = Vector3.new(99999, 99999, 99999)
	Model = Model:Clone()
	self.Model = Model

	self.Model:PivotTo(CFrame.new(self.OOBPosition))
	self.Model.Parent = Camera
	self.ClassName = "ViewModel"

	self:ProcessCollision()

	local Animator: Animator = Model:FindFirstChildWhichIsA("Animator", true)
	local AnimationController: AnimationController = Model:FindFirstAncestorWhichIsA("AnimationController", true)

	if Animator then
		self.AnimationController = Animator
	end
	if AnimationController then
		self.AnimationController = AnimationController
	end
end

-- Used internally to process the collisions to make sure nothing collides with the ViewModel
function ViewModel:ProcessCollision()
	for _, Part: BasePart in pairs(self.Model:GetDescendants()) do
		if Part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(Part, CollisionGroupConstants.VIEWMODELS)
		end
	end
end

-- Returns the currently used Animator.
function ViewModel:GetAnimator(): Animator | AnimationController
	return self.AnimationController
end

-- Returns a loaded AnimationTrack
function ViewModel:GetAnimation(Name: string): AnimationTrack
	return self.Animations[Name]
end

-- Stops all playing animations.
function ViewModel:StopAllAnimations(FadeTime: number)
	for _, Animation: AnimationTrack in pairs(self.Animations) do
		Animation:Stop(FadeTime)
	end
end

-- Loads an animation. Returns the AnimationTrack if its already loaded.
function ViewModel:LoadAnimation(Animation: Animation)
	local Animator: Animator | AnimationController = self:GetAnimator()
	print(Animator)

	if self:GetAnimation(Animation.Name) then
		print(self:GetAnimation(Animation.Name).Animation, self.Model.Name)
		warn("Animation " .. Animation.Name .. " is already loaded")
		return self:GetAnimation(Animation.Name)
	end

	-- LSP is being dumb here and considering Animator:LoadAnimatioon
	-- as Humanoid:LoadAnimation which is actually deprecated unlike Animator:LoadAnimation

	---@diagnostic disable-next-line: deprecated
	local Track = Animator:LoadAnimation(Animation)
	self.Animations[Animation.Name] = Track

	return Track
end

-- Takes a AnimationTrack and the same amount of arguments as AnimationTrack:Play()
-- FadeTime, Weight, Speed
function ViewModel:PlayAnimation(Track: AnimationTrack, ...)
	Track:Play(...)
end

-- Takes a AnimationTrack and the same amount of arguments as AnimationTrack:Stop()
-- FadeTime
function ViewModel:StopAnimation(Track: AnimationTrack, ...)
	Track:Stop(...)
end

-- "Mounts" the ViewModel onto the screen like a CUI element
function ViewModel:Mount()
	self:StopAllAnimations()
	self.Mounted = true
	self.Model:PivotTo(Camera.CFrame)
end

-- Removes the ViewModel from the screen
function ViewModel:Unmount()
	self.Mounted = false
	self.Model:PivotTo(CFrame.new(self.OOBPosition))
end

function ViewModel:Update()
	if not self.Mounted then
		return
	end
	self.Model:PivotTo(Camera.CFrame)
end

return ViewModel
