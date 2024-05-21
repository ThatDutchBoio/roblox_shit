--// @author Dutch_VII

GameController = {}
GameController.__index = GameController
GameController.Team0 = {} -- // Lobby
GameController.Team1 = {}
GameController.Team2 = {}
GameController.InProgress = false
GameController.GameLoop = false
GameController.CanThrow = false

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Null = require(ReplicatedStorage:WaitForChild("Null"))
local Require = Null.Require
local RunService = game:GetService("RunService")

--// Variables
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UiRemote = Remotes:WaitForChild("UI")
local RagdollRemote = Remotes:WaitForChild("Ragdoll")
local is_server = RunService:IsServer()
local GetTeam = Remotes:WaitForChild("GetTeam")
local GetGameInfo = Remotes:WaitForChild("GetGameInfo")
local Reset = Remotes:WaitForChild("Reset")
local ResetMatch = Remotes:WaitForChild("ResetMatch")

--// Modules
local Knockback = Require("KnockBack")

function GameController.new()
	local self = {}
	
	return setmetatable(self, GameController)
end

function GameController:GetColor(team: string)
	if team == "Team1" then return "rgb(255,0,0)" end
	if team == "Team2" then return "rgb(0,0,255)" end
	return "rgb(150,150,150)"
end

if is_server then
	
	
	local LeaderboardService = Require("LeaderboardService")
	
	function GameController:RemoveFromTeam(ply)
		local team = self:GetTeam(ply)
		if team == "None" then return end
		if table.find(GameController[team], ply) then
			table.remove(GameController[team],table.find(GameController[team], ply) )
		end
		
	end

	function GameController:GetTeam(ply: Player)
		if table.find(GameController.Team1, ply) then return "Team1" end
		if table.find(GameController.Team2, ply) then return "Team2" end
		return "None"	
	end
	
	function GameController:CheckWinConditions()
		if #GameController.Team1 == 0 or #GameController.Team2 == 0 then
			GameController.InProgress = false
			local won
			if #GameController.Team1 > 0 then
				won = "Team1"
			else
				won = "Team2"
			end

			UiRemote:FireAllClients("WinMessage", won)

			task.wait(5)
			self:EndGame()

		end
	end
	
	function GameController:RegisterKill(ply: Player, killer: Player | {any}, isKill: boolean)

		if killer then
			LeaderboardService:AddStat(killer, "Eliminations", 1)
		end

		local KilledTeam = self:GetTeam(ply)
		local KillerTeam = self:GetTeam(killer)
		local Killed = {
			Name = ply.Name,
			Color = self:GetColor(KilledTeam)
		}
		local Killer
		if isKill then
			Killer = {
				Name = killer.Name,
				Color = self:GetColor(KillerTeam)
			}
		else
			Killer = {
				Name = "The Void",
				Color = "rgb(0,0,0)"
			}
		end

		RagdollRemote:FireClient(ply)
		local PlyChar = ply.Character or ply.CharacterAdded:Wait()
		if isKill then
			local KillerChar = killer.Character or killer.CharacterAdded:Wait()
			Knockback:KnockBack(KillerChar, PlyChar, {
				Power = 100,
				Duration = .2
			})
		end
		
		UiRemote:FireAllClients("AddKillMessage", Killed, Killer)

		self:RemoveFromTeam(ply)

		self:CheckWinConditions()
		
	end

	function GameController:ClearTeams()
		local spawnPoint = workspace:WaitForChild("SpawnLocation")
		
		--// Wait for all characters to be present
		--for _, v in GameController.Team1 do
		--	local c = v.Character or v.CharacterAdded:Wait()
		--end
		--for _, v in GameController.Team2 do
		--	local c = v.Character or v.CharacterAdded:Wait()
		--end
		
		for _, v in GameController.Team1 do
			if v.Character then
				v.Character:PivotTo(spawnPoint.CFrame * CFrame.new(0, 5, 0))
			end
		end
		for _, v in GameController.Team2 do
			if v.Character then
				v.Character:PivotTo(spawnPoint.CFrame * CFrame.new(0, 5, 0))
			end
		end

		table.clear(GameController.Team1)
		table.clear(GameController.Team2)
	end

	function GameController:init()
		
		
		Reset.OnServerEvent:Connect(function(ply)
			local char = ply.Character
			local hum = char:WaitForChild("Humanoid")
			hum.Health = 0
			self:RegisterKill(ply, nil, false)
		end)
		
		game.Players.PlayerAdded:Connect(function(ply)
			if self:GetTeam(ply) == "None" then
				table.insert(GameController.Team0, ply)
			end
			
			ply.CharacterAdded:Connect(function(char)
				local Humanoid = char:WaitForChild("Humanoid")
			end)
			if #game:GetService("Players"):GetPlayers() > 1 and not GameController.GameLoop then
				GameController.GameLoop = true

				task.wait(5)

				UiRemote:FireAllClients("StartingGame")

				task.wait(2)

				self:StartGame()

			end
		end)

		game.Players.PlayerRemoving:Connect(function(ply)
			local Team = self:GetTeam(ply)
			if Team ~= "None" then
				table.remove(GameController[Team], table.find(GameController[Team], ply))
			end
		end)
		
		GetTeam.OnServerInvoke = function(ply, toCheck)
			return self:GetTeam(toCheck)
		end
		
		GetGameInfo.OnServerInvoke = function(ply, Value)
			if Value == "CanThrow" then
				return GameController.CanThrow
			end
			if Value == "InProgress" then
				return GameController.InProgress
			end
		end
		
		ResetMatch.Event:Connect(function()
			self:EndGame()
		end)
		
		local startgame = workspace:WaitForChild("startgame")
		local db = os.clock()

	end

	function GameController:SpawnPlayers()
		local Team1 = workspace.Map:WaitForChild("Team1")
		local Team2 = workspace.Map:WaitForChild("Team2")

		--// Wait for all characters to be present
		--for _, v in GameController.Team1 do
		--	local c = v.Character or v.CharacterAdded:Wait()
		--end
		--for _, v in GameController.Team2 do
		--	local c = v.Character or v.CharacterAdded:Wait()
		--end

		--// @TODO Spawn players
		for _, v in GameController.Team1 do
			if v.Character then
				v.Character:PivotTo(CFrame.new(Team1.Position + Vector3.new(0,5,0)))
			end
		end

		for _, v in GameController.Team2 do
			if v.Character then
				v.Character:PivotTo(CFrame.new(Team2.Position + Vector3.new(0,5,0)))
			end
		end
	end

	local function Shuffle(tabl)
		for i=1,#tabl-1 do
			local ran = math.random(i,#tabl)
			tabl[i],tabl[ran] = tabl[ran],tabl[i]
		end
		return tabl
	end

	function GameController:StartGame()

		local i = 1
		local Shuffled = Shuffle(GameController.Team0)
		for _,v in Shuffled do
			if i % 2  == 0 then
				table.insert(GameController.Team1, v)	
			else
				table.insert(GameController.Team2, v)
			end

			i += 1
		end

		self:SpawnPlayers()
		GameController.InProgress = true
		
		UiRemote:FireAllClients("Countdown", 3)
		task.wait(3)
		GameController.CanThrow = true
		
	end

	function GameController:EndGame()
		
		GameController.CanThrow = false
		self:ClearTeams()

		task.wait(10)

		UiRemote:FireAllClients("StartingGame")

		task.wait(2)

		self:StartGame()
	end
else
	
	function GameController:GetTeam(ply)
		return GetTeam:InvokeServer(ply)
	end
	
	function GameController:Get(value)
		return GetGameInfo:InvokeServer(value)
	end
end



return GameController