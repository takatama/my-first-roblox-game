local ObbyConfig = {}

ObbyConfig.WalkSpeed = 18
ObbyConfig.JumpPower = 55

ObbyConfig.FallY = -20
ObbyConfig.RespawnHeight = 5
ObbyConfig.RespawnFacingDirection = Vector3.new(0, 0, 1)
ObbyConfig.DeathRespawnTime = 1.5
ObbyConfig.ObstacleHitCooldown = 1
ObbyConfig.CheckpointConfirmDelay = 0.08
ObbyConfig.GoalCelebrateCooldown = 5
ObbyConfig.CheckpointGlowCooldown = 0.8
ObbyConfig.CheckpointGlowColor = Color3.fromRGB(80, 255, 140)
ObbyConfig.BgmSoundId = "rbxassetid://127649117728805"
ObbyConfig.CheckpointSoundId = "rbxassetid://137991482731236"
ObbyConfig.JumpSoundId = "rbxassetid://88702393538382"
ObbyConfig.GoalCheerSoundId = "rbxassetid://7755719721"

ObbyConfig.Colors = {
	Start = Color3.fromRGB(86, 180, 233),
	Checkpoint = Color3.fromRGB(0, 200, 120),
	Goal = Color3.fromRGB(255, 214, 80),
	Platform = Color3.fromRGB(245, 245, 245),
	Danger = Color3.fromRGB(238, 85, 85),
}

ObbyConfig.Checkpoints = {
	{
		name = "Start",
		position = Vector3.new(0, 4, 0),
		size = Vector3.new(18, 1, 18),
		color = ObbyConfig.Colors.Start,
	},
	{
		name = "Checkpoint 1",
		position = Vector3.new(0, 7, 36),
		size = Vector3.new(14, 1, 14),
		color = ObbyConfig.Colors.Checkpoint,
	},
	{
		name = "Checkpoint 2",
		position = Vector3.new(18, 10, 72),
		size = Vector3.new(14, 1, 14),
		color = ObbyConfig.Colors.Checkpoint,
	},
	{
		name = "Goal",
		position = Vector3.new(18, 13, 112),
		size = Vector3.new(18, 1, 18),
		color = ObbyConfig.Colors.Goal,
	},
}

ObbyConfig.Platforms = {
	{ position = Vector3.new(0, 5, 15), size = Vector3.new(12, 1, 10) },
	{ position = Vector3.new(0, 6, 26), size = Vector3.new(10, 1, 8) },
	{ position = Vector3.new(8, 8, 50), size = Vector3.new(10, 1, 10) },
	{ position = Vector3.new(18, 9, 61), size = Vector3.new(10, 1, 10) },
	{
		position = Vector3.new(18, 11, 88),
		size = Vector3.new(12, 1, 10),
		moveOffsets = {
			Vector3.new(-12, 0, 0),
			Vector3.new(12, 0, 0),
		},
		moveTime = 1.6,
	},
	{ position = Vector3.new(18, 12, 100), size = Vector3.new(10, 1, 8) },
}

ObbyConfig.Obstacles = {
	{ position = Vector3.new(-4, 6.25, 15), size = Vector3.new(2, 1.5, 10) },
	{ position = Vector3.new(4, 7.25, 26), size = Vector3.new(2, 1.5, 8) },
	{ position = Vector3.new(8, 9.25, 50), size = Vector3.new(10, 1.5, 2) },
	{ position = Vector3.new(18, 10.25, 61), size = Vector3.new(2, 1.5, 10) },
	{
		position = Vector3.new(13, 12.25, 88),
		size = Vector3.new(2, 1.5, 10),
		moveOffsets = {
			Vector3.new(-12, 0, 0),
			Vector3.new(12, 0, 0),
		},
		moveTime = 1.6,
	},
	{ position = Vector3.new(23, 13.25, 100), size = Vector3.new(2, 1.5, 8) },
}

return ObbyConfig
