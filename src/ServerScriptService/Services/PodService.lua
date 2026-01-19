--!strict

local CollectionService = game:GetService("CollectionService")
local TextChatService = game:GetService("TextChatService")

local Remotes = require(game:GetService("ReplicatedStorage").Shared.Remotes)
local LootConfig = require(game:GetService("ReplicatedStorage").Shared.Config.LootConfig)
local Rarity = require(game:GetService("ReplicatedStorage").Shared.Config.Rarity)
local RewardsCatalog = require(game:GetService("ReplicatedStorage").Shared.Config.RewardsCatalog)
local RandomUtil = require(game:GetService("ReplicatedStorage").Shared.Util.Random)

export type DataService = {
	get: (player: Player) -> any,
}

export type CurrencyService = {
	spendShards: (player: Player, amount: number) -> boolean,
}

local PodService = {}

local dataService: DataService
local currencyService: CurrencyService
local remotes = Remotes.get()

local MAX_DISTANCE = 12
local openDebounce: { [number]: boolean } = {}

local function getRoot(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function getPrompt(part: BasePart): ProximityPrompt
	local existing = part:FindFirstChildOfClass("ProximityPrompt")
	if existing then
		return existing
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Open Pod"
	prompt.ObjectText = "Pod Machine"
	prompt.MaxActivationDistance = MAX_DISTANCE
	prompt.HoldDuration = 0
	prompt.Parent = part
	return prompt
end

local function ensureAttributes(part: BasePart)
	if part:GetAttribute("PodTier") == nil then
		part:SetAttribute("PodTier", "Stone")
	end
end

local function getRewardsByRarity(rarity: string): { any }
	local list = {}
	for _, reward in ipairs(RewardsCatalog) do
		if reward.rarity == rarity then
			table.insert(list, reward)
		end
	end
	return list
end

local function rollRarity(weights: { [string]: number }, pity: number): string
	if pity >= LootConfig.PityThreshold then
		local pityWeights = {}
		for rarityName, weight in pairs(weights) do
			if (Rarity.Rank[rarityName] or 0) >= Rarity.Rank.Rare then
				pityWeights[rarityName] = weight
			end
		end
		local pityRoll = RandomUtil.weightedChoice(pityWeights)
		if pityRoll ~= "" then
			return pityRoll
		end
	end
	return RandomUtil.weightedChoice(weights)
end

local function broadcastMythic(message: string)
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		local channel = TextChatService:FindFirstChild("TextChannels")
		if channel then
			local general = channel:FindFirstChild("RBXGeneral")
			if general and general:IsA("TextChannel") then
				general:DisplaySystemMessage(message)
				return
			end
		end
	end
	print(message)
end

local function handleOpen(player: Player, part: BasePart, prompt: ProximityPrompt)
	if openDebounce[player.UserId] then
		return
	end
	openDebounce[player.UserId] = true

	local root = getRoot(player)
	if not root then
		openDebounce[player.UserId] = nil
		return
	end

	if (root.Position - part.Position).Magnitude > MAX_DISTANCE then
		openDebounce[player.UserId] = nil
		return
	end

	local tierName = tostring(part:GetAttribute("PodTier") or "Stone")
	local tier = LootConfig.PodTiers[tierName]
	if not tier then
		openDebounce[player.UserId] = nil
		return
	end

	local canSpend = currencyService.spendShards(player, tier.cost)
	if not canSpend then
		openDebounce[player.UserId] = nil
		return
	end

	local data = dataService.get(player)
	local rarity = rollRarity(tier.rarityWeights, data.pity)
	if rarity == "" then
		openDebounce[player.UserId] = nil
		return
	end

	local rewards = getRewardsByRarity(rarity)
	local reward = RandomUtil.choice(rewards)
	if not reward then
		openDebounce[player.UserId] = nil
		return
	end

	if (Rarity.Rank[rarity] or 0) < Rarity.Rank.Rare then
		data.pity += 1
	else
		data.pity = 0
	end

	data.inventory[reward.id] = (data.inventory[reward.id] or 0) + 1

	remotes.PodReveal:FireClient(player, {
		id = reward.id,
		name = reward.name,
		rarity = reward.rarity,
		kind = reward.kind,
	})

	if rarity == "Mythic" then
		broadcastMythic(string.format("%s pulled a Mythic reward: %s!", player.Name, reward.name))
	end

	task.delay(0.25, function()
		openDebounce[player.UserId] = nil
	end)
end

local function bindPrompt(part: BasePart)
	ensureAttributes(part)
	local prompt = getPrompt(part)

	prompt.Triggered:Connect(function(player)
		handleOpen(player, part, prompt)
	end)
end

local function resolveBasePart(instance: Instance): BasePart?
	if instance:IsA("BasePart") then
		return instance
	end
	if instance:IsA("Model") then
		return instance:FindFirstChildWhichIsA("BasePart")
	end
	return nil
end

local function bindExisting()
	for _, instance in ipairs(CollectionService:GetTagged("PodMachine")) do
		local part = resolveBasePart(instance)
		if part then
			bindPrompt(part)
		end
	end
end

function PodService.init(service: DataService, currency: CurrencyService)
	dataService = service
	currencyService = currency

	bindExisting()

	CollectionService:GetInstanceAddedSignal("PodMachine"):Connect(function(instance)
		local part = resolveBasePart(instance)
		if part then
			bindPrompt(part)
		end
	end)
end

return PodService
