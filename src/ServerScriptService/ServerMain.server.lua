--!strict

local DataService = require(script.Parent.Services.DataService)
local CurrencyService = require(script.Parent.Services.CurrencyService)
local MiningService = require(script.Parent.Services.MiningService)
local PodService = require(script.Parent.Services.PodService)

DataService.init()
CurrencyService.init(DataService)
MiningService.init(CurrencyService)
PodService.init(DataService, CurrencyService)
