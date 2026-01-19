--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type RemoteMap = {
	CurrencySync: RemoteEvent,
	PodReveal: RemoteEvent,
	MineFX: RemoteEvent,
}

local Remotes = {}

local function getOrCreateFolder(): Folder
	local existing = ReplicatedStorage:FindFirstChild("Remotes")
	if existing and existing:IsA("Folder") then
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = "Remotes"
	folder.Parent = ReplicatedStorage
	return folder
end

local function getOrCreateRemote(folder: Folder, name: string): RemoteEvent
	local existing = folder:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = folder
	return remote
end

function Remotes.get(): RemoteMap
	local folder = getOrCreateFolder()
	return {
		CurrencySync = getOrCreateRemote(folder, "CurrencySync"),
		PodReveal = getOrCreateRemote(folder, "PodReveal"),
		MineFX = getOrCreateRemote(folder, "MineFX"),
	}
end

return Remotes
