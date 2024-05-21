--// @author dutch_vii
--// Repurposed from other game

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- // Modules
local Null = require(ReplicatedStorage.Null)
local Require = Null.Require

DamageController = {}
DamageController.__index = DamageController



function DamageController:DoDamage(Target : Model, Amount : number)
	
	local hum = Target:FindFirstChild("Humanoid")
	
	if not Target:FindFirstChild("@blocking") then
		
		-- // Not Blocking	
		hum:TakeDamage(Amount)
	
		--HitRemote:FireAllClients(Target, false)
		
	else
		-- // Blocking
		--HitRemote:FireAllClients(Target, true)
	end
	
end

return DamageController