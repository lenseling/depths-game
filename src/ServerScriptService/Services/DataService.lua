--!strict

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

export type PlayerData = {
	shards: number,
	pity: number,
	inventory: { [string]: number },
}

local DataService = {}

local DATASTORE_NAME = "BBCaves_v1"
local AUTOSAVE_SECONDS = 60

local dataStore = DataStoreService:GetDataStore(DATASTORE_NAME)
local playerData: { [number]: PlayerData } = {}
local autosaveConnection: thread? = nil

local function defaultData(): PlayerData
	return {
		shards = 0,
		pity = 0,
		inventory = {},
	}
end

function DataService.get(player: Player): PlayerData
	local existing = playerData[player.UserId]
	if existing then
		return existing
	end

	local fresh = defaultData()
	playerData[player.UserId] = fresh
	return fresh
end

function DataService.set(player: Player, data: PlayerData)
	playerData[player.UserId] = data
end

local function loadPlayer(player: Player)
	local success, result = pcall(function()
		return dataStore:GetAsync(tostring(player.UserId))
	end)

	if success and type(result) == "table" then
		local data = defaultData()
		data.shards = tonumber(result.shards) or data.shards
		data.pity = tonumber(result.pity) or data.pity
		if type(result.inventory) == "table" then
			data.inventory = result.inventory
		end
		playerData[player.UserId] = data
	else
		playerData[player.UserId] = defaultData()
	end
end

local function savePlayer(player: Player)
	local data = playerData[player.UserId]
	if not data then
		return
	end

	local payload = {
		shards = data.shards,
		pity = data.pity,
		inventory = data.inventory,
	}

	pcall(function()
		dataStore:SetAsync(tostring(player.UserId), payload)
	end)
end

local function startAutosave()
	autosaveConnection = task.spawn(function()
		while true do
			for _, player in ipairs(Players:GetPlayers()) do
				savePlayer(player)
			end
			task.wait(AUTOSAVE_SECONDS)
		end
	end)
end

function DataService.init()
	Players.PlayerAdded:Connect(loadPlayer)
	Players.PlayerRemoving:Connect(savePlayer)

	for _, player in ipairs(Players:GetPlayers()) do
		loadPlayer(player)
	end

	startAutosave()

	game:BindToClose(function()
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayer(player)
		end
	end)
end

return DataService
