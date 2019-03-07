local skynet = require "skynet"
local sharedata = require "skynet.sharedata"

local item_config = require "config.item_config"
local build_config = require "config.build_config"
local build_unlock_config = require "config.build_unlock_config"
local product_plant = require "config.product_plant"
local levelup_config = require "config.levelupInfo_config"
local speedup_config = require "config.speed_up_config"
local product_build = require "config.product_build"
local product_config = require "config.product_factory"
local product_breed = require "config.product_breed"
local undeveloped_config = require "config.undeveloped_config"
local trains_config = require "config.trains_config"
local trains_order_config = require "config.trains_order_config"
local trains_reward = require "config.trains_reward"
local terminal_config = require "config.terminal_config"
local worker_config = require "config.worker_config"
local worker_levelup = require "config.worker_levelup"
local worker_profession = require "config.worker_profession"
local worker_skill = require "config.worker_skill"
local worker_starup = require "config.worker_starup"
local employ_config = require "config.employ_config"
local flight_order_config = require "config.plane_order_config"
local flight_reward_config = require "config.plane_reward_config"
local sign_box_config = require "config.sign_box_config"
local sign_in_config = require "config.sign_in_config"
local businessman_config = require "config.businessman_config"
local market_count_config = require "config.market_count_config"
local market_order_config = require "config.market_order_config"
local helicopter_count_config = require "config.helicopter_count_config"
local helicopter_order_config = require "config.helicopter_order_config"
local helicopter_person_config = require "config.helicopter_person_config"
local island_config = require "config.island_config"
local island_reward_config = require "config.island_reward_config"
local achievement_config = require "config.achievement_config"

local build_data = require "init_data.build_data"
local floor_data = require "init_data.floor_data"
local green_data = require "init_data.green_data"
local road_data = require "init_data.road_data"
local ground_data = require "init_data.ground_data"

skynet.start(function()
	sharedata.new("item_config", item_config)
	sharedata.new("build_config", build_config)
	sharedata.new("build_unlock_config", build_unlock_config)
	sharedata.new("product_plant", product_plant)
	sharedata.new("levelup_config", levelup_config)
	sharedata.new("speedup_config", speedup_config)
	sharedata.new("product_build", product_build)
	sharedata.new("product_config", product_config)
	sharedata.new("product_breed", product_breed)
	sharedata.new("undeveloped_config", undeveloped_config)
	sharedata.new("trains_config", trains_config)
	sharedata.new("trains_order_config", trains_order_config)
	sharedata.new("trains_reward", trains_reward)
	sharedata.new("terminal_config", terminal_config)
	sharedata.new("worker_levelup", worker_levelup)
	sharedata.new("worker_profession", worker_profession)
	sharedata.new("worker_skill", worker_skill)
	sharedata.new("worker_starup", worker_starup)
	sharedata.new("worker_config", worker_config)
	sharedata.new("employ_config", employ_config)
	sharedata.new("flight_order_config", flight_order_config)
	sharedata.new("flight_reward_config", flight_reward_config)
	sharedata.new("sign_box_config", sign_box_config)
	sharedata.new("sign_in_config", sign_in_config)
	sharedata.new("businessman_config", businessman_config)
	sharedata.new("market_count_config", market_count_config)
	sharedata.new("market_order_config", market_order_config)
	sharedata.new("helicopter_count_config", helicopter_count_config)
	sharedata.new("helicopter_order_config", helicopter_order_config)
	sharedata.new("helicopter_person_config", helicopter_person_config)
	sharedata.new("island_config", island_config)
	sharedata.new("island_reward_config", island_reward_config)
	sharedata.new("achievement_config", achievement_config)

	sharedata.new("build_data", build_data)
	sharedata.new("floor_data", floor_data)
	sharedata.new("green_data", green_data)
	sharedata.new("road_data", road_data)
	sharedata.new("ground_data", ground_data)
end)
