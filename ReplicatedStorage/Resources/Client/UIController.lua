UIController = {}
UIController.__index = UIController

--// Services
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Null = require(ReplicatedStorage:WaitForChild("Null"))
local Require = Null.Require
local Players = game.Players
local TweenService = game:GetService("TweenService")

--// Variables
local Player = Players.LocalPlayer
local PlayerGUI = Player.PlayerGui
local Messages = PlayerGUI:WaitForChild("Messages")
local KillFeed = Messages:WaitForChild("Killfeed")
local WinMessage = Messages:WaitForChild("Won")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UiRemote = Remotes:WaitForChild("UI")
local Starting = Messages:WaitForChild("Starting")
local Countdown = Messages:WaitForChild("Countdown")
local Reset = Remotes:WaitForChild("Reset")

function UIController.new()
	local self = {}
	
	return setmetatable(self, UIController)
end

function UIController:init()
	
	UiRemote.OnClientEvent:Connect(function(taskType: string, ...)
		local args = {...}
		self[taskType](args)
	end)
	
	local resetBindable = Instance.new("BindableEvent")
	resetBindable.Event:connect(function()
		Reset:FireServer(Null.Player)
	end)
	
	game:GetService("StarterGui"):SetCore("ResetButtonCallback", resetBindable)
	
end

function UIController.AddKillMessage(args)
	local nLabel = script.KillText:Clone()
	local PlayerKilled = args[1]
	local Killer = args[2]
	nLabel.RichText = true
	nLabel.Text = [[<font color="]].. Killer.Color .. [[">]] .. Killer.Name .. [[</font> Eliminated <font color="]] .. PlayerKilled.Color .. [[">]].. PlayerKilled.Name .. [[</font>]]
	nLabel.Parent = KillFeed
	TweenService:Create(nLabel, TweenInfo.new(.5, Enum.EasingStyle.Cubic), {TextTransparency = 0}):Play()
	
	
	task.delay(10, function()
		TweenService:Create(nLabel, TweenInfo.new(.5, Enum.EasingStyle.Cubic), {TextTransparency = 1}):Play()
		task.wait(.5)
		nLabel:Destroy()
	end)
end

function UIController.WinMessage(args)
	WinMessage.Visible = true
	WinMessage.Text = args[1] .. "Won"
	TweenService:Create(WinMessage, TweenInfo.new(.5, Enum.EasingStyle.Cubic), {TextTransparency = 0}):Play()
	task.wait(10)
	TweenService:Create(WinMessage, TweenInfo.new(.5, Enum.EasingStyle.Cubic), {TextTransparency = 1}):Play()
	task.wait(.5)
	WinMessage.Visible = false
end

function UIController.StartingGame()
	TweenService:Create(Starting, TweenInfo.new(.5, Enum.EasingStyle.Cubic), {TextTransparency = 0}):Play()
	task.wait(2)
	TweenService:Create(Starting, TweenInfo.new(.5, Enum.EasingStyle.Cubic), {TextTransparency = 1}):Play()
end

function UIController.Countdown(args)
	print("Starting countdown")
	TweenService:Create(Starting, TweenInfo.new(.5, Enum.EasingStyle.Cubic), {TextTransparency = 0}):Play()
	
	for count = 3, 1, -1 do
		Countdown.Text = tostring(count)
		print(count)
		task.wait(1)
	end
	
	TweenService:Create(Starting, TweenInfo.new(.2, Enum.EasingStyle.Cubic), {TextTransparency = 1}):Play()
end

return UIController
