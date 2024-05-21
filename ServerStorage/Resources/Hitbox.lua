-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- // Modules
local Null = require(ReplicatedStorage.Null)
local Require = Null.Require
local Janitor = Require("Janitor")

-- // Variables
local is_server = RunService:IsServer()
local Controllers = {}
local Visuals = workspace.Visuals

Hitbox = {}
Hitbox.__index = Hitbox

function Hitbox.new(Origin : Vector3, Size : number, Visualize : boolean, Owner : Model)
	local self = setmetatable({}, Hitbox)
	
	self.Origin = Origin
	self.Radius = Size
	self.Visualize = Visualize
	self.Owner = Owner
	self._janitor = Janitor.new()
	return self
end

function Hitbox:VisualizeHitbox()
	
	local HitBoxPart = Instance.new("Part", Visuals)
	HitBoxPart.Shape = Enum.PartType.Ball
	HitBoxPart.Transparency = .75
	HitBoxPart.Material = Enum.Material.Neon
	HitBoxPart.Color = Color3.fromRGB(255,0,0)
	HitBoxPart.Anchored = true
	HitBoxPart.Position = self.Origin
	HitBoxPart.Size = Vector3.new(self.Radius, self.Radius, self.Radius)
	HitBoxPart.CanCollide = false
	
	self._janitor:Add(function()
		HitBoxPart:Destroy()
	end)
	
	task.delay(.5, function()
		TweenService:Create(HitBoxPart, TweenInfo.new(1,Enum.EasingStyle.Quad), {Transparency = 1}):Play()
	end)
	
	
end

function Hitbox:GetVictims()
	
	local victims = workspace:GetPartBoundsInRadius(self.Origin, self.Radius)
	local HumanoidsHit = {}
	
	if self.Visualize then
		self:VisualizeHitbox()
	end
	
	for _,v in pairs(victims) do
		local Model = v:FindFirstAncestorWhichIsA("Model")
		if Model then
			if Model:FindFirstChild("Humanoid") and not table.find(HumanoidsHit, Model) and Model ~= self.Owner then
				table.insert(HumanoidsHit, Model)
			end
		end
	end
	
	return HumanoidsHit
end

function Hitbox:GetPartBoundsInBox(args)
	local oParams = OverlapParams.new()
	oParams.FilterDescendantsInstances = {args.Executor, Visuals}
	oParams.FilterType = Enum.RaycastFilterType.Exclude
	local victims = workspace:GetPartBoundsInBox(args.Origin, args.Size, oParams)
	local HumanoidsHit = {}

	if self.Visualize then
		self:VisualizeHitbox()
	end

	for _,v in pairs(victims) do
		local Model = v:FindFirstAncestorWhichIsA("Model")
		if Model then
			if Model:FindFirstChild("Humanoid") and not table.find(HumanoidsHit, Model) and Model ~= self.Owner then
				table.insert(HumanoidsHit, Model)
			end
		end
	end

	return HumanoidsHit
end


function Hitbox:Destroy()
	self._janitor:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

return Hitbox