local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage.Shared.ObbyConfig)

local player = Players.LocalPlayer

local bgm = Instance.new("Sound")
bgm.Name = "Obby BGM"
bgm.SoundId = Config.BgmSoundId
bgm.Volume = 0.35
bgm.Looped = true
bgm.Parent = SoundService
bgm:Play()

local jumpSound = Instance.new("Sound")
jumpSound.Name = "Jump SE"
jumpSound.SoundId = Config.JumpSoundId
jumpSound.Volume = 0.45
jumpSound.Parent = SoundService

local function applyMovement(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = Config.WalkSpeed
	humanoid.JumpPower = Config.JumpPower
	humanoid.UseJumpPower = true

	humanoid.Jumping:Connect(function(isJumping)
		if isJumping then
			jumpSound:Play()
		end
	end)
end

local function makeStageGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ObbyHud"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local label = Instance.new("TextLabel")
	label.Name = "StageLabel"
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	label.BackgroundTransparency = 0.15
	label.BorderSizePixel = 0
	label.Position = UDim2.fromScale(0.5, 0.04)
	label.Size = UDim2.fromOffset(220, 44)
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Parent = screenGui

	local padding = Instance.new("UIPadding")
	padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.PaddingTop = UDim.new(0, 8)
	padding.Parent = label

	local timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "TimerLabel"
	timerLabel.AnchorPoint = Vector2.new(0.5, 0)
	timerLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	timerLabel.BackgroundTransparency = 0.15
	timerLabel.BorderSizePixel = 0
	timerLabel.Position = UDim2.fromScale(0.5, 0.11)
	timerLabel.Size = UDim2.fromOffset(220, 34)
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.TextColor3 = Color3.fromRGB(255, 230, 90)
	timerLabel.TextScaled = true
	timerLabel.Parent = screenGui

	local timerPadding = Instance.new("UIPadding")
	timerPadding.PaddingBottom = UDim.new(0, 6)
	timerPadding.PaddingLeft = UDim.new(0, 10)
	timerPadding.PaddingRight = UDim.new(0, 10)
	timerPadding.PaddingTop = UDim.new(0, 6)
	timerPadding.Parent = timerLabel

	return label, timerLabel
end

local stageLabel, timerLabel = makeStageGui()

local function formatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local remainingSeconds = seconds - minutes * 60
	return string.format("%02d:%05.2f", minutes, remainingSeconds)
end

local function updateStageText()
	local checkpointIndex = player:GetAttribute("CheckpointIndex") or 1
	local checkpoint = Config.Checkpoints[checkpointIndex]
	stageLabel.Text = checkpoint and checkpoint.name or "Stage " .. checkpointIndex
end

player:GetAttributeChangedSignal("CheckpointIndex"):Connect(updateStageText)
updateStageText()

local function updateTimerText()
	local goalTime = player:GetAttribute("GoalTime")
	if goalTime then
		timerLabel.Text = "Goal  " .. formatTime(goalTime)
		return
	end

	local runStartedAt = player:GetAttribute("RunStartedAt")
	if not runStartedAt then
		timerLabel.Text = "Time  00:00.00"
		return
	end

	timerLabel.Text = "Time  " .. formatTime(workspace:GetServerTimeNow() - runStartedAt)
end

RunService.RenderStepped:Connect(updateTimerText)
updateTimerText()

if player.Character then
	applyMovement(player.Character)
end

player.CharacterAdded:Connect(applyMovement)
