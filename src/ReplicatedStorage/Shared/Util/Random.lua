--!strict

local RandomUtil = {}

function RandomUtil.weightedChoice(weights: { [string]: number }, rng: Random?): string
	local total = 0
	for _, weight in pairs(weights) do
		total += weight
	end

	if total <= 0 then
		return ""
	end

	local random = rng or Random.new()
	local roll = random:NextNumber(0, total)
	local cumulative = 0
	for key, weight in pairs(weights) do
		cumulative += weight
		if roll <= cumulative then
			return key
		end
	end

	return ""
end

function RandomUtil.choice<T>(list: { T }, rng: Random?): T?
	if #list == 0 then
		return nil
	end
	local random = rng or Random.new()
	local index = random:NextInteger(1, #list)
	return list[index]
end

return RandomUtil
