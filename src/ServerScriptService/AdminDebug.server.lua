--!strict

local Players = game:GetService("Players")

local LootConfig = require(game:GetService("ReplicatedStorage").Shared.Config.LootConfig)
local RewardsCatalog = require(game:GetService("ReplicatedStorage").Shared.Config.RewardsCatalog)
local RandomUtil = require(game:GetService("ReplicatedStorage").Shared.Util.Random)
local Rarity = require(game:GetService("ReplicatedStorage").Shared.Config.Rarity)

local DataService = require(script.Parent.Services.DataService)
local CurrencyService = require(script.Parent.Services.CurrencyService)

local ALLOWLIST = {
	[12345678] = true, -- TODO: replace with your userId
}

local function isAdmin(player: Player): boolean
	return ALLOWLIST[player.UserId] == true
end

local function getRewardById(id: string)
	for _, reward in ipairs(RewardsCatalog) do
		if reward.id == id then
			return reward
		end
	end
	return nil
end

local function simulateOpen(tierName: string, count: number)
	local tier = LootConfig.PodTiers[tierName]
	if not tier then
		return nil
	end

	local tally = {
		Common = 0,
		Uncommon = 0,
		Rare = 0,
		Epic = 0,
		Mythic = 0,
	}

	for _ = 1, count do
		local rarity = RandomUtil.weightedChoice(tier.rarityWeights)
		if rarity ~= "" then
			tally[rarity] += 1
		end
	end

	return tally
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if not isAdmin(player) then
			return
		end

		local args = string.split(message, " ")
		local command = args[1]

		if command == "!giveShards" then
			local amount = tonumber(args[2] or "0") or 0
			CurrencyService.addShards(player, amount)
		elseif command == "!setPity" then
			local amount = tonumber(args[2] or "0") or 0
			local data = DataService.get(player)
			data.pity = math.max(amount, 0)
		elseif command == "!giveItem" then
			local itemId = tostring(args[2] or "")
			local count = tonumber(args[3] or "1") or 1
			local reward = getRewardById(itemId)
			if reward then
				local data = DataService.get(player)
				data.inventory[reward.id] = (data.inventory[reward.id] or 0) + count
			end
		elseif command == "!simOpen" then
			local tierName = tostring(args[2] or "Stone")
			local count = tonumber(args[3] or "1") or 1
			local result = simulateOpen(tierName, count)
			if result then
				print(string.format("SimOpen %s x%d", tierName, count))
				for _, rarityName in ipairs(Rarity.Names) do
					print(string.format("%s: %d", rarityName, result[rarityName]))
				end
			end
		end
	end)
end)
