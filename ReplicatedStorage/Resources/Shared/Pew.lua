--// @author Dutch_VII
--// Projectile module

Pew = {}
Pew.__index = Pew

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Null = require(ReplicatedStorage:WaitForChild("Null"))
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

--// Variables
local Require = Null.Require
local IsServer = RunService:IsServer()
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Replication = Remotes:WaitForChild("Replication")
local PewEvent = Remotes.Pew
local FastCast = Require("FastCastRedux")
local Visuals = workspace:WaitForChild("Visuals")

--[[
args = 
{
origin: Vector3, 
direction: Vector3, 
behavior: string, 
acceleration: Vector3, 
caster, 
speed: number,
extra_data: {},
}
]]
function Pew.new(args)
	local self = {}

	self.Position = args[1]
	self.Origin =  args[1]
	self.Direction = args[2]
	self.Behavior = require(script:FindFirstChild(args[3]))
	self.LastPos = nil
	self.Acceleration = args[4]
	self.Caster = args[5] or nil
	self.Speed = args[6]
	self.extra_data = args[8]
	if not self.Behavior then return error("Behavior doesn't exist") end	
	if IsServer then
		self.GUID = HttpService:GenerateGUID(false)
	else
		self.GUID = args[7]
	end
	if IsServer then
		
		Replication:FireAllClients(script.Name, "new", args[1], args[2], args[3], args[4], args[5], args[6], self.GUID, args[7] )
	else
		PewEvent.OnClientEvent:Connect(function(toDo: string, GUID)
			if toDo == "Start" then
				if GUID == self.GUID then
					self:Start()
				end
			end
		end)
	end
	
	return setmetatable(self, Pew)
end

function Pew:Start()
	
	
	if IsServer then
		PewEvent:FireAllClients("Start", self.GUID)
	end
	local Caster = FastCast.new()

	local Behavior = FastCast.newBehavior()
	local rParams = RaycastParams.new()
	rParams.FilterType = Enum.RaycastFilterType.Exclude
	if self.Caster then
		rParams.FilterDescendantsInstances = {self.Caster, Visuals}
	else
		rParams.FilterDescendantsInstances = {Visuals}
	end
	Behavior.RaycastParams = rParams
	Behavior.Acceleration = self.Acceleration

	
	
	if IsServer then
		--[[ 
			origin + ((origin - direction).Unit * speed)
		]]
		Caster.LengthChanged:Connect(function(ActiveCast, lastPoint, rayDir, displacement, segmentVelocity, cosmeticBulletObject)
			self.Behavior.LengthChanged(lastPoint, rayDir * displacement)
		end)

		Caster.RayHit:Connect(function(_, result)
			self.Behavior.Impacted(result, self.Caster)
		end)

	else
		local userData = self.Behavior.Start({extra_data = self.extra_data}, self)
		
		Caster.LengthChanged:Connect(function(ActiveCast, lastPoint, rayDir, displacement, segmentVelocity, cosmeticBulletObject)
			self.Behavior.LengthChanged(userData, lastPoint, rayDir * displacement)
		end)
		
		Caster.RayHit:Connect(function(_, result)
			self.Behavior.Impacted(userData, result)
		end)
	end
	
	Caster:Fire(self.Origin, (self.Direction - self.Origin).Unit , self.Speed, Behavior)
end

return Pew