--!strict

export type RewardKind = "cosmetic" | "tool" | "pet"
export type RewardItem = {
	id: string,
	name: string,
	rarity: string,
	kind: RewardKind,
}

local RewardsCatalog: { RewardItem } = {
	{ id = "cave_goggles", name = "Cave Goggles", rarity = "Common", kind = "cosmetic" },
	{ id = "dusty_cloak", name = "Dusty Cloak", rarity = "Common", kind = "cosmetic" },
	{ id = "miner_pick", name = "Miner Pick", rarity = "Uncommon", kind = "tool" },
	{ id = "glow_lantern", name = "Glow Lantern", rarity = "Uncommon", kind = "tool" },
	{ id = "crystal_pup", name = "Crystal Pup", rarity = "Rare", kind = "pet" },
	{ id = "deep_drill", name = "Deep Drill", rarity = "Rare", kind = "tool" },
	{ id = "abyss_cape", name = "Abyss Cape", rarity = "Epic", kind = "cosmetic" },
	{ id = "void_sprite", name = "Void Sprite", rarity = "Epic", kind = "pet" },
	{ id = "mythic_relic", name = "Mythic Relic", rarity = "Mythic", kind = "cosmetic" },
	{ id = "cave_leviathan", name = "Cave Leviathan", rarity = "Mythic", kind = "pet" },
}

return RewardsCatalog
