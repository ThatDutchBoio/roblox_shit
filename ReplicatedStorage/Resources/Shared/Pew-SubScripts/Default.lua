--// @author Dutch_VII
--// Filesys Pew -> Default
--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Null = require(ReplicatedStorage:WaitForChild("Null"))
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

--// Variables
local Require = Null.Require
local IsServer = RunService:IsServer()
local AnimEx = ReplicatedStorage:WaitForChild("AnimEx")
local ChargeFist = AnimEx:WaitForChild("ChargeFist")
local Effects = ReplicatedStorage:WaitForChild("Effects")
local SkillEffects = Effects:WaitForChild("ChargeFist")
local Visuals = workspace:WaitForChild("Visuals")

--// Modules
local CameraEffects = Require("CameraEffects")
local ScreenEffects = Require("ScreenEffects")
local ParticleEffect = Require("ParticleEffect")
local Rocks = Require("Dwayne")
local Hitbox = Require("Hitbox")

local Behavior = {}


if IsServer then
	
	function Behavior.LengthChanged(lastPos, curPos)
		
	end
	
	function Behavior.Impacted(result, Caster)
		--Rocks.Spit(5, 15, 2.5, result.Position, 80)
		
		local hitbox = Hitbox.new(result.Position, 5, false, Caster)
		
		local victims = hitbox:GetVictims()
		
		local GameController = Require("GameController")
		local DamageController = Require("DamageController")
		
		for _, v in victims do
			local ply = game.Players:GetPlayerFromCharacter(v)
			local casterChar = game.Players:GetPlayerFromCharacter(Caster)
			if GameController:GetTeam(ply) == GameController:GetTeam(casterChar) then
			else
				DamageController:DoDamage(v, 100)
				GameController:RegisterKill(ply, casterChar)
			end
		end
	end
	
else
	
	function Behavior.Start(userData)
		if userData.Started then return end
		if not userData.Projectile then
			userData.Projectile = ParticleEffect.new({
				EffectInstance = SkillEffects.Ball
			})
			userData.Projectile.EffectInstance.Parent = Visuals
		end
		userData.Started = true
		return userData
	end
	
	function Behavior.LengthChanged(userData, lastPos, curPos)
		userData.Projectile:SetCFrame(CFrame.new(lastPos, lastPos + curPos) * CFrame.Angles(0, math.rad(180), 0))
		--Rocks.RockTrail(lastPos, lastPos + curPos, 3, 4, 5)
	end

	function Behavior.Impacted(userData, result)
		userData.Projectile:Destroy()
		--local Impact = ParticleEffect.new({
		--	EffectInstance = SkillEffects.explosion
		--})
		--Impact.EffectInstance.Parent = Visuals
		--Impact:SetCFrame(CFrame.new(result.Position))
		--Impact:Play()
		----Origin, Size, Amount, Radius, Duration
		--Rocks.Crater(result.Position, 3, 15, 10, 5)
		
	end
end

return Behavior