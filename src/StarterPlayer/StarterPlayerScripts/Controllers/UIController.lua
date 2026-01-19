--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)

local UIController = {}

local remotes = Remotes.get()

local function createShardsLabel(parent: Instance): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = "ShardsCounter"
	label.Size = UDim2.new(0, 220, 0, 40)
	label.Position = UDim2.new(0, 20, 0, 20)
	label.BackgroundTransparency = 0.25
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	label.TextColor3 = Color3.fromRGB(200, 240, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = "Shards: 0"
	label.Parent = parent
	return label
end

local function createPodReveal(parent: Instance): Frame
	local frame = Instance.new("Frame")
	frame.Name = "PodReveal"
	frame.Size = UDim2.new(0, 360, 0, 200)
	frame.Position = UDim2.new(0.5, -180, 0.5, -100)
	frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	frame.BackgroundTransparency = 0.1
	frame.Visible = false
	frame.Parent = parent

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -20, 0, 40)
	title.Position = UDim2.new(0, 10, 0, 10)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Text = "Pod Opened!"
	title.Parent = frame

	local reward = Instance.new("TextLabel")
	reward.Name = "Reward"
	reward.Size = UDim2.new(1, -20, 0, 60)
	reward.Position = UDim2.new(0, 10, 0, 60)
	reward.BackgroundTransparency = 1
	reward.Font = Enum.Font.Gotham
	reward.TextColor3 = Color3.fromRGB(200, 240, 255)
	reward.TextScaled = true
	reward.Text = ""
	reward.Parent = frame

	local close = Instance.new("TextButton")
	close.Name = "Close"
	close.Size = UDim2.new(0, 120, 0, 40)
	close.Position = UDim2.new(0.5, -60, 1, -50)
	close.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.TextScaled = true
	close.Font = Enum.Font.GothamBold
	close.Text = "Close"
	close.Parent = frame

	close.Activated:Connect(function()
		frame.Visible = false
	end)

	return frame
end

function UIController.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BlindBoxCavesUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local shardsLabel = createShardsLabel(screenGui)
	local revealFrame = createPodReveal(screenGui)

	remotes.CurrencySync.OnClientEvent:Connect(function(shards: number)
		shardsLabel.Text = string.format("Shards: %d", shards)
	end)

	remotes.PodReveal.OnClientEvent:Connect(function(reward)
		local rewardLabel = revealFrame:FindFirstChild("Reward") :: TextLabel?
		if rewardLabel then
			rewardLabel.Text = string.format("%s (%s)", reward.name, reward.rarity)
		end
		revealFrame.Visible = true
	end)

	remotes.MineFX.OnClientEvent:Connect(function(position: Vector3, remainingHealth: number)
		-- TODO: hook up particle/sound effects for mining feedback.
		local _ = position
		local _ = remainingHealth
	end)
end

return UIController
