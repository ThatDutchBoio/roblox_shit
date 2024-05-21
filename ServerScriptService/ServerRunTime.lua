-- @author Dutch_VII

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Null = require(ReplicatedStorage:WaitForChild("Null"))

--// Variables
local Require = Null.Require

--// Modules
local CombatSystem = Require("CombatSystem")
local Ragdoll = Require("Ragdoll")

local Combat = CombatSystem.new()
Combat:init()

local GameController = Require("GameController")

gameController = GameController.new()
gameController:init()

local LeaderboardService = Require("LeaderboardService")

local leaderboardService = LeaderboardService.new()
leaderboardService:init()

game.Players.PlayerAdded:Connect(function(ply)
	ply.CharacterAdded:Connect(function(char)
		Ragdoll:RigPlayer(char)
	end)
end)