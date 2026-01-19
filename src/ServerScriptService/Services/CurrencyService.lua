--!strict

local Players = game:GetService("Players")

local Remotes = require(game:GetService("ReplicatedStorage").Shared.Remotes)

export type DataService = {
	get: (player: Player) -> any,
	set: (player: Player, data: any) -> (),
}

local CurrencyService = {}

local dataService: DataService
local remotes = Remotes.get()

local function sync(player: Player, shards: number)
	remotes.CurrencySync:FireClient(player, shards)
end

function CurrencyService.init(service: DataService)
	dataService = service

	Players.PlayerAdded:Connect(function(player)
		local data = dataService.get(player)
		sync(player, data.shards)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		local data = dataService.get(player)
		sync(player, data.shards)
	end
end

function CurrencyService.getShards(player: Player): number
	local data = dataService.get(player)
	return data.shards
end

function CurrencyService.addShards(player: Player, amount: number)
	local data = dataService.get(player)
	data.shards += amount
	if data.shards < 0 then
		data.shards = 0
	end
	sync(player, data.shards)
end

function CurrencyService.setShards(player: Player, amount: number)
	local data = dataService.get(player)
	data.shards = math.max(amount, 0)
	sync(player, data.shards)
end

function CurrencyService.spendShards(player: Player, amount: number): boolean
	local data = dataService.get(player)
	if data.shards < amount then
		return false
	end
	data.shards -= amount
	sync(player, data.shards)
	return true
end

return CurrencyService
