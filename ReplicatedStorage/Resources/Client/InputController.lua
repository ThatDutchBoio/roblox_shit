--// @author Dutch_VII
InputController = {}
InputController.__index = InputController

--// Services
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Null = require(ReplicatedStorage:WaitForChild("Null"))
local Require = Null.Require

--// Modules
local Keybinds = require(script.KeyBinds)
local Signal = Require("Signal") 

InputController.Active = {}
InputController.Last = {}
InputController.InputChanged = Signal.new()

function InputController.new()
	local self = {}
	
	for _,v in Keybinds do
		InputController.Active[v] = false
		InputController.Last[v] = false	
	end
	
	return setmetatable(self, InputController)
end

function InputController:init()
	UserInputService.InputBegan:Connect(function(inp)
		local Action = Keybinds[inp.KeyCode] or Keybinds[inp.UserInputType]
		if Action then
			InputController.Last[Action] = InputController.Active[Action]
			InputController.Active[Action] = true
			InputController.InputChanged:Fire(Action)
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		local Action = Keybinds[inp.KeyCode] or Keybinds[inp.UserInputType]
		if Action then
			InputController.Last[Action] = InputController.Active[Action]
			InputController.Active[Action] = false
			InputController.InputChanged:Fire(Action)
		end
	end)
	
end



return InputController