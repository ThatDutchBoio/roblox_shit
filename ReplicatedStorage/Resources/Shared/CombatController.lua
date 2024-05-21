--// @author Dutch_VII
--// Repurposed from another game for use here

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Null = require(ReplicatedStorage:WaitForChild("Null"))
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

--// Variables
local Require = Null.Require
local IsServer = RunService:IsServer()
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CombatRemote = Remotes.Combat
local AnimEx = ReplicatedStorage:WaitForChild("AnimEx")

--// Modules
local Janitor = Require("Janitor")
local GameController = Require("GameController")

CombatSystem = {}
CombatSystem.__index = CombatSystem

function CombatSystem.new()
	local self = {}
	if not IsServer then
		self.WeaponType = "Fists"
		self.WeaponName = "Default"
		self.LastAttacked = os.clock()
		self.Attacking = false
		self.UserData = {}
	end
	return setmetatable(self, CombatSystem)
end

function CombatSystem:init()
	
	if not IsServer then
		local last = {}
		local InputController = Require("InputController")
		InputController.InputChanged:Connect(function(Action)
			if Action == "Primary" and not self.Attacking then
				if InputController.Active[Action] == true then
					local start = os.clock()
					local GUID = HttpService:GenerateGUID(false)
					if GameController:GetTeam(game:GetService("Players").LocalPlayer) == "None" then return end
					CombatRemote:FireServer("Primary", self.WeaponType, self.WeaponName, os.clock() - start, GUID)	
					self.Attacking = true
					while InputController.Active[Action] == true or os.clock() - start <= 1.4 / 2 do
						task.wait()
					end
					warn("Releasing")
					CombatRemote:FireServer("Release", self.WeaponType, self.WeaponName, os.clock() - start, GUID)
					
					task.wait(1.4 / 2)
					self.Attacking = false
				end	
			end
		end)
		
		CombatRemote.OnClientEvent:Connect(function(Caster: Player, Action: string, WeaponType: string, WeaponName: string, Duration, GUID)
			self[Action]({
				WeaponName = WeaponName,
				Caster = Caster,
				Action = Action,
				WeaponType = WeaponType,
				Duration = Duration,
				GUID = GUID,
				UserData = self.UserData
			})
		end)
	else
		CombatRemote.OnServerEvent:Connect(function(Player: Player, Action: string, WeaponType: string, WeaponName: string, Duration, GUID)
			warn("combat remote caught")
			if not GameController.CanThrow then return end
			CombatRemote:FireAllClients(Player, Action, WeaponType, WeaponName, Duration, GUID)
			self[Action]({
				WeaponName = WeaponName,
				Caster = Player,
				Action = Action,
				WeaponType = WeaponType,
				Duration = Duration,
				GUID = GUID
			})
		end)
	end
	
end

function CombatSystem.Primary(self)
	local FistsFolder = script:FindFirstChild(self.WeaponType)
	local weaponModule = require(script:FindFirstChild(self.WeaponType):FindFirstChild(self.WeaponName))
	weaponModule.primary(self)
	
end

function CombatSystem.Secondary(self)
	local weaponModule = require(script:FindFirstChild(self.WeaponType):FindFirstChild(self.WeaponName))
	weaponModule.secondary(self)
end

function CombatSystem.Release(self)
	local weaponModule = require(script:FindFirstChild(self.WeaponType):FindFirstChild(self.WeaponName))
	weaponModule.release(self)
end

if not IsServer then
	function CombatSystem:PreloadAnimations()
		local weaponModule = require(script:FindFirstChild(self.WeaponType):FindFirstChild(self.WeaponName))
		local anims = AnimEx:FindFirstChild(self.WeaponType):FindFirstChild(self.WeaponName)
		local Player = Null.Player
		local Character = Player.Character or Player.CharacterAdded:Wait()
		local Animator = Character:WaitForChild("Humanoid"):WaitForChild("Animator")
		for _,v in anims:GetChildren() do
			local Track = Animator:LoadAnimation(v)
			weaponModule.Animations[v.Name] = Track
		end
		
	end
end
return CombatSystem