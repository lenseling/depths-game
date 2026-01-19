--!strict

export type RarityName = "Common" | "Uncommon" | "Rare" | "Epic" | "Mythic"

local Rarity = {}

Rarity.Names = {
	"Common",
	"Uncommon",
	"Rare",
	"Epic",
	"Mythic",
}

Rarity.Rank = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Mythic = 5,
}

return Rarity
