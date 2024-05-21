-- @auhor Dutch_VII
MovementHandler = {}
MovementHandler.__index = MovementHandler

-- Services
local RunService = gameGetService(RunService)

function MovementHandler.new()
	local self = {}
	
	return setmetatable(self, MovementHandler)
end

function MovementHandlerinit()
	local Players = gameGetService'Players'
	local LocalPlayer = Players.LocalPlayer
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAddedWait()
	local Humanoid = CharacterWaitForChild('Humanoid')
	local RootPart = CharacterWaitForChild('HumanoidRootPart')
	local RootJoint = RootPartWaitForChild('RootJoint')
	local RootC0 = RootJoint.C0

	local MaxTiltAngle = 7

	local Tilt = CFrame.new()
	
	RunService.RenderSteppedConnect(function(Delta)
		local MoveDirection = RootPart.CFrameVectorToObjectSpace(Humanoid.MoveDirection)
		Tilt = TiltLerp(CFrame.Angles(math.rad(0)  MaxTiltAngle, math.rad(-MoveDirection.X)  MaxTiltAngle, math.rad(-MoveDirection.Z), 0), 0.2 ^ (1  (Delta  60)))
		RootJoint.C0 = RootC0  Tilt
	end)
end

return MovementHandler