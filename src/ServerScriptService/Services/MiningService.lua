--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Remotes = require(game:GetService("ReplicatedStorage").Shared.Remotes)

export type CurrencyService = {
	addShards: (player: Player, amount: number) -> (),
}

local MiningService = {}

local currencyService: CurrencyService
local remotes = Remotes.get()

local HIT_COOLDOWN = 0.25
local MAX_DISTANCE = 12

local lastHitTime: { [number]: number } = {}

local function ensureAttributes(part: BasePart)
	if part:GetAttribute("MaxHealth") == nil then
		part:SetAttribute("MaxHealth", 10)
	end
	if part:GetAttribute("Health") == nil then
		part:SetAttribute("Health", part:GetAttribute("MaxHealth"))
	end
	if part:GetAttribute("ShardsPerHit") == nil then
		part:SetAttribute("ShardsPerHit", 2)
	end
	if part:GetAttribute("RespawnSeconds") == nil then
		part:SetAttribute("RespawnSeconds", 15)
	end
end

local function getPrompt(part: BasePart): ProximityPrompt
	local existing = part:FindFirstChildOfClass("ProximityPrompt")
	if existing then
		return existing
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Mine"
	prompt.ObjectText = "Crystal"
	prompt.MaxActivationDistance = MAX_DISTANCE
	prompt.HoldDuration = 0
	prompt.Parent = part
	return prompt
end

local function getRoot(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

local function hideNode(part: BasePart, prompt: ProximityPrompt)
	prompt.Enabled = false
	part.Transparency = 1
	part.CanCollide = false
end

local function showNode(part: BasePart, prompt: ProximityPrompt)
	prompt.Enabled = true
	part.Transparency = 0
	part.CanCollide = true
end

local function handleHit(player: Player, part: BasePart, prompt: ProximityPrompt)
	local now = os.clock()
	if (lastHitTime[player.UserId] or 0) + HIT_COOLDOWN > now then
		return
	end
	lastHitTime[player.UserId] = now

	local root = getRoot(player)
	if not root then
		return
	end

	if (root.Position - part.Position).Magnitude > MAX_DISTANCE then
		return
	end

	local health = tonumber(part:GetAttribute("Health")) or 0
	if health <= 0 then
		return
	end

	local shardsPerHit = tonumber(part:GetAttribute("ShardsPerHit")) or 0
	currencyService.addShards(player, shardsPerHit)

	local newHealth = health - 1
	part:SetAttribute("Health", newHealth)

	remotes.MineFX:FireClient(player, part.Position, newHealth)

	if newHealth <= 0 then
		hideNode(part, prompt)
		local respawnSeconds = tonumber(part:GetAttribute("RespawnSeconds")) or 15
		task.delay(respawnSeconds, function()
			if part.Parent then
				part:SetAttribute("Health", part:GetAttribute("MaxHealth"))
				showNode(part, prompt)
			end
		end)
	end
end

local function bindPrompt(part: BasePart)
	ensureAttributes(part)
	local prompt = getPrompt(part)

	prompt.Triggered:Connect(function(player)
		handleHit(player, part, prompt)
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
	for _, instance in ipairs(CollectionService:GetTagged("CrystalNode")) do
		local part = resolveBasePart(instance)
		if part then
			bindPrompt(part)
		end
	end
end

function MiningService.init(currency: CurrencyService)
	currencyService = currency
	bindExisting()

	CollectionService:GetInstanceAddedSignal("CrystalNode"):Connect(function(instance)
		local part = resolveBasePart(instance)
		if part then
			bindPrompt(part)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastHitTime[player.UserId] = nil
	end)
end

return MiningService
