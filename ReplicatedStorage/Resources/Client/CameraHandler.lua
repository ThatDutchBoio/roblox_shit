--// @author Dutch_VII
CameraHandler = {}
CameraHandler.__index = CameraHandler

CameraHandler.CameraTweens = {
	Playing = {
		FOV = nil
	}
}

CameraHandler.Locked = false
CameraHandler.LockConn = nil

--// Services
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Null = require(ReplicatedStorage:WaitForChild("Null"))
local Require = Null.Require
local Players = game.Players
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--// Variables
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Modules
local InputController = Require("InputController")

function CameraHandler:TweenFOV(goal, speed)
	if not CameraHandler.CameraTweens.Playing.FOV then
		local tween = TweenService:Create(Camera, TweenInfo.new(speed), {FieldOfView = goal})
		CameraHandler.CameraTweens.Playing.FOV = tween
		tween:Play()
		tween.Completed:Connect(function()
			CameraHandler.CameraTweens.Playing.FOV = nil
		end)
	else
		CameraHandler.CameraTweens.Playing.FOV:Cancel()
		local tween = TweenService:Create(Camera, TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true), {FieldOfView = goal})
		CameraHandler.CameraTweens.Playing.FOV = tween
		tween:Play()
		tween.Completed:Connect(function()
			CameraHandler.CameraTweens.Playing.FOV = nil
		end)
	end
end

function CameraHandler:LockMouse()
	local character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = character:WaitForChild("Humanoid")
	if not CameraHandler.Locked then
		CameraHandler.Locked = true
	else
		CameraHandler.Locked = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end 
end

function CameraHandler:CancelCameraTweens()
	for _, v in CameraHandler.CameraTweens.Playing do
		if v then
			v:Cancel()
		end
	end
	
	TweenService:Create(Camera, TweenInfo.new(.5), {FieldOfView = 70}):Play()
end

function CameraHandler:WatchForLock()
	local character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = character:WaitForChild("Humanoid")
	local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
	Player.CharacterAdded:Connect(function(char)
		Humanoid = char:WaitForChild("Humanoid")
		HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
	end)
	RunService.RenderStepped:Connect(function(dt)
		
		if (Humanoid) and (HumanoidRootPart) then 
			Humanoid.AutoRotate = not CameraHandler.Locked
			Humanoid.CameraOffset = CameraHandler.Locked and Humanoid.CameraOffset:Lerp(Vector3.new(1.5, .25, 0), dt * 1.5) or Humanoid.CameraOffset:Lerp(Vector3.new(), dt * 1.5)
		end
		
		if CameraHandler.Locked then
			local x, y, z = Camera.CFrame:ToOrientation();
			HumanoidRootPart.CFrame = HumanoidRootPart.CFrame:Lerp(CFrame.new(HumanoidRootPart.Position) * CFrame.Angles(0, y, 0), dt * 5)
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		end
	end)
	
	InputController.InputChanged:Connect(function(Action)
		if Action == "Lock" and InputController.Active[Action] == true then
			self:LockMouse()
		end
	end)
end


return CameraHandler
