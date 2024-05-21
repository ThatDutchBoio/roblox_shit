--// @author Dutch_VII

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Null = require(ReplicatedStorage:WaitForChild("Null"))
local RunService = game:GetService("RunService")

--// Variables
local Require = Null.Require
local IsServer = RunService:IsServer()
local AnimEx = ReplicatedStorage:WaitForChild("AnimEx")
local ChargeFist = AnimEx:WaitForChild("ChargeFist")
local Effects = ReplicatedStorage:WaitForChild("Effects")
local SkillEffects = Effects:WaitForChild("ChargeFist")
local Visuals = workspace:WaitForChild("Visuals")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GetMouse = Remotes:WaitForChild("GetMouse")

--// Modules
local CameraEffects = Require("CameraEffects")
local ScreenEffects = Require("ScreenEffects")
local Pew = Require("Pew")
local ParticleEffect = Require("ParticleEffect")
local Cowboy = Require("Cowboy")
local Hitbox = Require("Hitbox")
local GameController = Require("GameController")


local weapon = {}
weapon.Animations = {}

if IsServer then
	--// Server	
	function weapon.primary(self)
		print("primary server")
		local char = self.Caster.Character
		local Humanoid = char:WaitForChild("Humanoid")
		Humanoid.WalkSpeed = 7
		Humanoid.JumpHeight = 3
	end
	
	function weapon.release(self)
		print("Server released")
		local char = self.Caster.Character 
		local rightArm = char:WaitForChild("Right Arm")
		local root = char:WaitForChild("HumanoidRootPart")
		local MouseHit = GetMouse:InvokeClient(self.Caster)
		local Humanoid = char:WaitForChild("Humanoid")
		Humanoid.WalkSpeed = 16
		Humanoid.JumpHeight = 7.2
		--// Update mouse pos before shooting
		MouseHit = GetMouse:InvokeClient(self.Caster)
	
		local rParams = RaycastParams.new()
		rParams.FilterType = Enum.RaycastFilterType.Exclude
		rParams.FilterDescendantsInstances = {self.Caster, Visuals}
		
		local hitbox = Hitbox.new(rightArm.Position, 5, false, char)
		local Projectile = Cowboy.Shoot({
			owner = char,
			raycast_params = rParams,
			origin = rightArm.Position,
			velocity = (MouseHit - rightArm.Position).Unit * (275 * (math.clamp(self.Duration,0, 3))),
			acceleration = Vector3.new(0, -30, 0),
			life_time = 100,
			max_distance = 2000,
			bullet_behavior = "Ball",
			hitbox_class = hitbox,
			range = 2
			})
		Projectile:Start()
	end
	
	function weapon.secondary(self)
		print("secondary server")
	end
else
	--// Client
	local CameraHandler = Require("CameraHandler")
	function weapon.primary(self)
		-- // Unpack Data
		local character = self.Caster.Character
		local humanoid = character:WaitForChild("Humanoid")
		local animator = humanoid:WaitForChild("Animator")
		local rightArm = character:WaitForChild("Right Arm")
		local GUID = self.GUID
		if not self.UserData[GUID] then
			self.UserData[GUID] = {}
		end
		self.UserData[GUID].Released = false
		local Ball = ParticleEffect.new({
			EffectInstance = SkillEffects.BallHold
		})
		Ball.EffectInstance.Parent = Visuals
		Ball:SetCFrame(rightArm.CFrame * CFrame.new(0, -1.75, 0))
		self.UserData[GUID].Ball = Ball
		local BallWeld = Instance.new("WeldConstraint", Ball.EffectInstance)
		BallWeld.Part0 = Ball.EffectInstance
		BallWeld.Part1 = rightArm
		self.UserData[GUID].BallWeld = BallWeld
		local Team = GameController:GetTeam(self.Caster)
		if Team == "Team2" then
			Ball.EffectInstance.Color = Color3.fromRGB(0, 0, 255)
		end 
		--// Caster exclusive fx		
		if Null.Player == self.Caster then
			print("Primary running on caster!")
			local track = animator:LoadAnimation(ChargeFist)
			track:Play(.1)
			track:AdjustSpeed(2)
			CameraHandler:TweenFOV(20, 10)
			
			local started = os.clock()
			weapon._track = track
			track:GetMarkerReachedSignal("shake"):Connect(function()
				--CameraEffects.ShakeOnce("Bump")
			end)
			track:GetMarkerReachedSignal("pause"):Connect(function()
				if not self.UserData[GUID].Released then
					warn("Pausing animation")
					track:AdjustSpeed(0)
				end
				
			end)
		end 

	end
	
	function weapon.release(self)
		print("Client released")
		local GUID = self.GUID
		self.UserData[GUID].Released = true
		if self.UserData[GUID].Ball then
			self.UserData[GUID].Ball:Destroy()
		end
		if self.UserData[GUID].BallWeld then
			self.UserData[GUID].BallWeld:Destroy()
		end
		
		--// Caster exclusive
		if Null.Player == self.Caster then
			if weapon._track then
				warn("Resuming animation")
				weapon._track:AdjustSpeed(1)
			end
			CameraHandler:CancelCameraTweens()

			task.delay(.1, function()
				CameraEffects.ShakeOnce("Bump")
				--ScreenEffects.ScreenFlash({Duration = .2})

			end)

			task.delay(.5, function()
				if weapon._track then
					weapon._track:Destroy()
					
				end
			end)
		end 
		task.delay(.5, function()
			self.UserData[GUID].Released = false
		end)
		return
	end
	
	function weapon.secondary(self)
		print("secondary client")
	end
	
end

return weapon