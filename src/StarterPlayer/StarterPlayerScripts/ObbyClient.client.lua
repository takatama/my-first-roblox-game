local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.ObbyConfig)

local player = Players.LocalPlayer

local function applyMovement(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = Config.WalkSpeed
	humanoid.JumpPower = Config.JumpPower
	humanoid.UseJumpPower = true
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

	return label
end

local stageLabel = makeStageGui()

local function updateStageText()
	local checkpointIndex = player:GetAttribute("CheckpointIndex") or 1
	local checkpoint = Config.Checkpoints[checkpointIndex]
	stageLabel.Text = checkpoint and checkpoint.name or "Stage " .. checkpointIndex
end

player:GetAttributeChangedSignal("CheckpointIndex"):Connect(updateStageText)
updateStageText()

if player.Character then
	applyMovement(player.Character)
end

player.CharacterAdded:Connect(applyMovement)
