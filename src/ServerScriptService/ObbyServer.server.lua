local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.ObbyConfig)

Players.RespawnTime = Config.DeathRespawnTime

local mapFolder = workspace:FindFirstChild("ObbyMap")
if mapFolder then
	mapFolder:Destroy()
end

mapFolder = Instance.new("Folder")
mapFolder.Name = "ObbyMap"
mapFolder.Parent = workspace

local checkpointParts = {}
local movingParts = {}

local function playerFromHit(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then
		return nil, nil, nil
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return nil, nil, nil
	end

	return Players:GetPlayerFromCharacter(character), humanoid, character
end

local function makePart(name, position, size, color)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Position = position
	part.Size = size
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = mapFolder
	return part
end

local function playCheckpointGlow(part)
	local now = os.clock()
	local lastGlow = part:GetAttribute("LastGlow") or 0
	if now - lastGlow < Config.CheckpointGlowCooldown then
		return
	end

	part:SetAttribute("LastGlow", now)

	local originalColor = part.Color
	local originalSize = part.Size
	local glowLight = Instance.new("PointLight")
	glowLight.Name = "Checkpoint Glow"
	glowLight.Color = Config.CheckpointGlowColor
	glowLight.Brightness = 0
	glowLight.Range = 0
	glowLight.Parent = part

	local glowInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local fadeInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	TweenService:Create(part, glowInfo, {
		Color = Config.CheckpointGlowColor,
		Size = originalSize + Vector3.new(1.5, 0.25, 1.5),
	}):Play()
	TweenService:Create(glowLight, glowInfo, {
		Brightness = 5,
		Range = 18,
	}):Play()

	task.delay(0.18, function()
		if not part.Parent then
			return
		end

		TweenService:Create(part, fadeInfo, {
			Color = originalColor,
			Size = originalSize,
		}):Play()
		TweenService:Create(glowLight, fadeInfo, {
			Brightness = 0,
			Range = 0,
		}):Play()
	end)

	Debris:AddItem(glowLight, 1)
end

local function playGoalCheer(position)
	local soundPart = Instance.new("Part")
	soundPart.Name = "Goal Cheer Sound"
	soundPart.Anchored = true
	soundPart.CanCollide = false
	soundPart.Transparency = 1
	soundPart.Position = position
	soundPart.Parent = mapFolder

	local sound = Instance.new("Sound")
	sound.Name = "Goal Cheer"
	sound.SoundId = Config.GoalCheerSoundId
	sound.Volume = 0.8
	sound.RollOffMaxDistance = 90
	sound.Parent = soundPart
	sound:Play()

	Debris:AddItem(soundPart, 8)
end

local function isRootPartOverPart(rootPart, part)
	local localPosition = part.CFrame:PointToObjectSpace(rootPart.Position)
	local halfSize = part.Size / 2

	return math.abs(localPosition.X) <= halfSize.X
		and math.abs(localPosition.Z) <= halfSize.Z
		and localPosition.Y >= halfSize.Y
end

local function canReachCheckpoint(player, humanoid, character, checkpointPart)
	if not player or humanoid.Health <= 0 then
		return false
	end

	local lastObstacleHit = player:GetAttribute("LastObstacleHit") or 0
	if os.clock() - lastObstacleHit < Config.CheckpointConfirmDelay then
		return false
	end

	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	return rootPart and isRootPartOverPart(rootPart, checkpointPart)
end

local function addMovingPart(part, offsets, moveTime)
	table.insert(movingParts, {
		part = part,
		startCFrame = part.CFrame,
		offsets = offsets,
		moveTime = moveTime,
	})
end

local function startMovingParts()
	if #movingParts == 0 then
		return
	end

	local moveTime = movingParts[1].moveTime
	local tweenInfo = TweenInfo.new(moveTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	task.spawn(function()
		while true do
			for _, offset in ipairs(movingParts[1].offsets) do
				for _, movingPart in ipairs(movingParts) do
					if movingPart.part.Parent then
						TweenService:Create(movingPart.part, tweenInfo, {
							CFrame = movingPart.startCFrame + offset,
						}):Play()
					end
				end

				task.wait(moveTime)

				for _, movingPart in ipairs(movingParts) do
					if movingPart.part.Parent then
						TweenService:Create(movingPart.part, tweenInfo, { CFrame = movingPart.startCFrame }):Play()
					end
				end

				task.wait(moveTime)
			end
		end
	end)
end

local function celebrateGoal(player)
	local now = os.clock()
	local lastCelebrate = player:GetAttribute("LastGoalCelebrate") or 0
	if now - lastCelebrate < Config.GoalCelebrateCooldown then
		return
	end

	player:SetAttribute("LastGoalCelebrate", now)

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local basePosition = if rootPart then rootPart.Position else Config.Checkpoints[#Config.Checkpoints].position
	local colors = {
		Color3.fromRGB(255, 80, 80),
		Color3.fromRGB(80, 200, 255),
		Color3.fromRGB(255, 230, 90),
		Color3.fromRGB(120, 255, 140),
		Color3.fromRGB(220, 120, 255),
	}

	for index = 1, 80 do
		local confetti = Instance.new("Part")
		confetti.Name = "Goal Confetti"
		confetti.Anchored = false
		confetti.CanCollide = false
		confetti.Color = colors[((index - 1) % #colors) + 1]
		confetti.Material = Enum.Material.Neon
		confetti.Size = Vector3.new(0.35, 0.12, 0.35)
		confetti.Position = basePosition + Vector3.new(math.random(-6, 6), math.random(5, 10), math.random(-6, 6))
		confetti.Orientation = Vector3.new(math.random(0, 360), math.random(0, 360), math.random(0, 360))
		confetti.Parent = mapFolder

		confetti.AssemblyLinearVelocity = Vector3.new(math.random(-18, 18), math.random(16, 32), math.random(-18, 18))
		confetti.AssemblyAngularVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))

		Debris:AddItem(confetti, 7)
	end

	playGoalCheer(basePosition)
end

local function checkpointCFrame(index)
	local checkpoint = Config.Checkpoints[index] or Config.Checkpoints[1]
	local position = checkpoint.position + Vector3.new(0, Config.RespawnHeight, 0)
	return CFrame.lookAt(position, position + Config.RespawnFacingDirection)
end

local function updateCheckpoint(player, index)
	local currentIndex = player:GetAttribute("CheckpointIndex") or 1
	if index <= currentIndex then
		return false
	end

	player:SetAttribute("CheckpointIndex", index)

	local leaderstats = player:FindFirstChild("leaderstats")
	local stageValue = leaderstats and leaderstats:FindFirstChild("Stage")
	if stageValue then
		stageValue.Value = index
	end

	return true
end

local function respawnAtCheckpoint(player)
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero
	character:PivotTo(checkpointCFrame(player:GetAttribute("CheckpointIndex") or 1))
end

local function setupCharacter(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	humanoid.WalkSpeed = Config.WalkSpeed
	humanoid.JumpPower = Config.JumpPower
	humanoid.UseJumpPower = true

	task.defer(function()
		if rootPart.Parent then
			respawnAtCheckpoint(player)
		end
	end)
end

local function setupPlayer(player)
	player:SetAttribute("CheckpointIndex", 1)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local stageValue = Instance.new("IntValue")
	stageValue.Name = "Stage"
	stageValue.Value = 1
	stageValue.Parent = leaderstats

	player.CharacterAdded:Connect(function(character)
		setupCharacter(player, character)
	end)
end

for index, checkpoint in ipairs(Config.Checkpoints) do
	local part = makePart(checkpoint.name, checkpoint.position, checkpoint.size, checkpoint.color)
	part.Material = Enum.Material.Neon
	part:SetAttribute("CheckpointIndex", index)
	checkpointParts[index] = part

	part.Touched:Connect(function(hit)
		local player, humanoid, character = playerFromHit(hit)
		if not player then
			return
		end

		task.delay(Config.CheckpointConfirmDelay, function()
			if not canReachCheckpoint(player, humanoid, character, part) then
				return
			end

			local reachedNewCheckpoint = updateCheckpoint(player, index)
			if reachedNewCheckpoint and index < #Config.Checkpoints then
				playCheckpointGlow(part)
			end

			if index == #Config.Checkpoints then
				celebrateGoal(player)
			end
		end)
	end)
end

for index, platform in ipairs(Config.Platforms) do
	local part = makePart("Platform " .. index, platform.position, platform.size, Config.Colors.Platform)
	if platform.moveOffsets then
		addMovingPart(part, platform.moveOffsets, platform.moveTime)
	end
end

for index, obstacle in ipairs(Config.Obstacles) do
	local part = makePart("Jump Obstacle " .. index, obstacle.position, obstacle.size, Config.Colors.Danger)
	part.Material = Enum.Material.Neon
	if obstacle.moveOffsets then
		addMovingPart(part, obstacle.moveOffsets, obstacle.moveTime)
	end

	part.Touched:Connect(function(hit)
		local player, humanoid = playerFromHit(hit)
		if not player or humanoid.Health <= 0 then
			return
		end

		local now = os.clock()
		local lastHit = player:GetAttribute("LastObstacleHit") or 0
		if now - lastHit < Config.ObstacleHitCooldown then
			return
		end

		player:SetAttribute("LastObstacleHit", now)
		humanoid.Health = 0
	end)
end

startMovingParts()

RunService.Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChild("Humanoid")

		if rootPart and humanoid and humanoid.Health > 0 and rootPart.Position.Y < Config.FallY then
			respawnAtCheckpoint(player)
		end
	end
end)

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end
