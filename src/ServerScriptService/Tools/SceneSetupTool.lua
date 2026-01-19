--!strict

-- SceneSetupTool
-- One-time (repeatable) setup script for BLIND BOX CAVES scene objects.

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local SceneSetupTool = {}

-- =========================
-- Configuration
-- =========================
local crystalFolderPath = "Workspace/CrystalFolder"
local podFolderPath = "Workspace/PodMachinesFolder"
local allowCreatePromptPart = true

-- =========================
-- Types
-- =========================
export type Summary = {
	crystalsProcessed: number,
	podMachinesProcessed: number,
	promptsCreated: number,
	tagsAdded: number,
	attributesSet: number,
}

-- =========================
-- Helpers
-- =========================
local function resolvePath(path: string): Instance?
	local segments = string.split(path, "/")
	if #segments == 0 then
		return nil
	end

	local current: Instance? = nil
	for index, segment in ipairs(segments) do
		if index == 1 then
			if segment == "Workspace" then
				current = Workspace
			else
				current = game:FindFirstChild(segment)
			end
		else
			if not current then
				return nil
			end
			current = current:FindFirstChild(segment)
		end
	end

	return current
end

local function getLargestBasePart(parts: { BasePart }): BasePart?
	local largest: BasePart? = nil
	local largestMetric = -math.huge
	for _, part in ipairs(parts) do
		local size = part.Size
		local metric = size.X * size.Y * size.Z
		if metric > largestMetric then
			largestMetric = metric
			largest = part
		end
	end
	return largest
end

local function collectBaseParts(root: Instance): { BasePart }
	local parts = {}
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(parts, descendant)
		end
	end
	return parts
end

local function ensurePromptPart(container: Instance): BasePart
	local existing = container:FindFirstChild("PromptPart")
	if existing and existing:IsA("BasePart") then
		return existing
	end

	local part = Instance.new("Part")
	part.Name = "PromptPart"
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(2, 2, 2)
	part.Parent = container
	return part
end

local function chooseBasePart(instance: Instance, canCreatePromptPart: boolean): BasePart?
	if instance:IsA("BasePart") then
		return instance
	end

	if instance:IsA("Model") then
		local primary = instance.PrimaryPart
		if primary and primary:IsA("BasePart") then
			return primary
		end

		local parts = collectBaseParts(instance)
		local largest = getLargestBasePart(parts)
		if largest then
			return largest
		end

		if canCreatePromptPart then
			return ensurePromptPart(instance)
		end
	end

	return nil
end

local function ensurePrompt(part: BasePart, defaults: { [string]: any }): (ProximityPrompt, boolean)
	local existing = part:FindFirstChildOfClass("ProximityPrompt")
	if existing then
		return existing, false
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Parent = part
	for key, value in pairs(defaults) do
		prompt[key] = value
	end
	return prompt, true
end

local function applyPromptDefaults(prompt: ProximityPrompt, defaults: { [string]: any })
	for key, value in pairs(defaults) do
		prompt[key] = value
	end
end

local function ensureAttribute(part: BasePart, name: string, value: any): boolean
	if part:GetAttribute(name) ~= nil then
		return false
	end
	part:SetAttribute(name, value)
	return true
end

local function ensureHealthAttribute(part: BasePart, maxHealth: number): boolean
	if part:GetAttribute("Health") ~= nil then
		return false
	end
	part:SetAttribute("Health", maxHealth)
	return true
end

local function ensureTag(part: BasePart, tagName: string): boolean
	if CollectionService:HasTag(part, tagName) then
		return false
	end
	CollectionService:AddTag(part, tagName)
	return true
end

local function warnIfEmpty(folder: Instance, label: string)
	if #folder:GetChildren() == 0 then
		warn(string.format("%s folder is empty: %s", label, folder:GetFullName()))
	end
end

-- =========================
-- Main logic
-- =========================
function SceneSetupTool.Run(): Summary
	local summary: Summary = {
		crystalsProcessed = 0,
		podMachinesProcessed = 0,
		promptsCreated = 0,
		tagsAdded = 0,
		attributesSet = 0,
	}

	local crystalFolder = resolvePath(crystalFolderPath)
	if not crystalFolder then
		warn(string.format("Crystal folder not found at path: %s", crystalFolderPath))
	else
		warnIfEmpty(crystalFolder, "Crystal")
		for _, item in ipairs(crystalFolder:GetChildren()) do
			local part = chooseBasePart(item, allowCreatePromptPart)
			if not part then
				warn(string.format("Crystal missing BasePart: %s", item:GetFullName()))
				continue
			end

			summary.crystalsProcessed += 1

			local promptDefaults = {
				ActionText = "Mine",
				ObjectText = "Crystal",
				KeyboardKeyCode = Enum.KeyCode.E,
				HoldDuration = 0.25,
				MaxActivationDistance = 12,
				RequiresLineOfSight = false,
				ClickablePrompt = true,
			}
			local prompt, created = ensurePrompt(part, promptDefaults)
			if created then
				summary.promptsCreated += 1
			else
				applyPromptDefaults(prompt, promptDefaults)
			end

			if ensureTag(part, "CrystalNode") then
				summary.tagsAdded += 1
			end

			if ensureAttribute(part, "MaxHealth", 10) then
				summary.attributesSet += 1
			end
			local maxHealth = tonumber(part:GetAttribute("MaxHealth")) or 10
			if ensureHealthAttribute(part, maxHealth) then
				summary.attributesSet += 1
			end
			if ensureAttribute(part, "ShardsPerHit", 2) then
				summary.attributesSet += 1
			end
			if ensureAttribute(part, "RespawnSeconds", 15) then
				summary.attributesSet += 1
			end
		end
	end

	local podFolder = resolvePath(podFolderPath)
	if not podFolder then
		warn(string.format("PodMachines folder not found at path: %s", podFolderPath))
	else
		warnIfEmpty(podFolder, "PodMachine")
		for _, item in ipairs(podFolder:GetChildren()) do
			local part = chooseBasePart(item, allowCreatePromptPart)
			if not part then
				warn(string.format("PodMachine missing BasePart: %s", item:GetFullName()))
				continue
			end

			summary.podMachinesProcessed += 1

			local promptDefaults = {
				ActionText = "Deposit",
				ObjectText = "Pod Machine",
				KeyboardKeyCode = Enum.KeyCode.E,
				HoldDuration = 0.6,
				MaxActivationDistance = 12,
				RequiresLineOfSight = false,
				ClickablePrompt = true,
			}
			local prompt, created = ensurePrompt(part, promptDefaults)
			if created then
				summary.promptsCreated += 1
			else
				applyPromptDefaults(prompt, promptDefaults)
			end

			if ensureTag(part, "PodMachine") then
				summary.tagsAdded += 1
			end

			if ensureAttribute(part, "PodTier", "Stone") then
				summary.attributesSet += 1
			end
			if ensureAttribute(part, "Cost", 25) then
				summary.attributesSet += 1
			end
		end
	end

	print(string.format(
		"SceneSetupTool summary: crystals=%d, pods=%d, promptsCreated=%d, tagsAdded=%d, attributesSet=%d",
		summary.crystalsProcessed,
		summary.podMachinesProcessed,
		summary.promptsCreated,
		summary.tagsAdded,
		summary.attributesSet
	))

	return summary
end

return SceneSetupTool
