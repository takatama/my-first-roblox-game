local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.ObbyConfig)

local mapFolder = workspace:FindFirstChild("ObbyMap")
if mapFolder then
	mapFolder:Destroy()
end

mapFolder = Instance.new("Folder")
mapFolder.Name = "ObbyMap"
mapFolder.Parent = workspace

local checkpointParts = {}

local function playerFromHit(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then
		return nil, nil
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		return nil, nil
	end

	return Players:GetPlayerFromCharacter(character), humanoid
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
end

local function checkpointCFrame(index)
	local checkpoint = Config.Checkpoints[index] or Config.Checkpoints[1]
	return CFrame.new(checkpoint.position + Vector3.new(0, Config.RespawnHeight, 0))
end

local function updateCheckpoint(player, index)
	local currentIndex = player:GetAttribute("CheckpointIndex") or 1
	if index <= currentIndex then
		return
	end

	player:SetAttribute("CheckpointIndex", index)

	local leaderstats = player:FindFirstChild("leaderstats")
	local stageValue = leaderstats and leaderstats:FindFirstChild("Stage")
	if stageValue then
		stageValue.Value = index
	end
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
		local player = playerFromHit(hit)
		if player then
			updateCheckpoint(player, index)

			if index == #Config.Checkpoints then
				celebrateGoal(player)
			end
		end
	end)
end

for index, platform in ipairs(Config.Platforms) do
	makePart("Platform " .. index, platform.position, platform.size, Config.Colors.Platform)
end

for index, obstacle in ipairs(Config.Obstacles) do
	local part = makePart("Jump Obstacle " .. index, obstacle.position, obstacle.size, Config.Colors.Danger)
	part.Material = Enum.Material.Neon

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
