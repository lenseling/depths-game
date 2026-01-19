--!strict

local LootConfig = {}

export type PodTierName = "Stone" | "Glow" | "Prism" | "Void" | "Myth"

LootConfig.PityThreshold = 12

LootConfig.PodTiers = {
	Stone = {
		cost = 10,
		rarityWeights = {
			Common = 70,
			Uncommon = 25,
			Rare = 4,
			Epic = 1,
			Mythic = 0.1,
		},
	},
	Glow = {
		cost = 25,
		rarityWeights = {
			Common = 55,
			Uncommon = 30,
			Rare = 12,
			Epic = 2.5,
			Mythic = 0.5,
		},
	},
	Prism = {
		cost = 60,
		rarityWeights = {
			Common = 40,
			Uncommon = 30,
			Rare = 20,
			Epic = 7,
			Mythic = 3,
		},
	},
	Void = {
		cost = 125,
		rarityWeights = {
			Common = 30,
			Uncommon = 30,
			Rare = 25,
			Epic = 10,
			Mythic = 5,
		},
	},
	Myth = {
		cost = 250,
		rarityWeights = {
			Common = 15,
			Uncommon = 25,
			Rare = 30,
			Epic = 20,
			Mythic = 10,
		},
	},
}

return LootConfig
