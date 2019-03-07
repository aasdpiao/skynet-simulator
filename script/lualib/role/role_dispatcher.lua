local syslog = require "syslog"
local class = require "class"
local print_r = require "print_r"
local skynet = require "skynet"
local CMD = require "role.admin_power"

local RoleDispatcher = class()

function RoleDispatcher:ctor(role_object)
    self.__role_object = role_object
end

function RoleDispatcher:register_c2s_callback(request_name,callback)
    self.__role_object:register_c2s_callback(request_name,callback)
end

function RoleDispatcher:init()
    self:register_c2s_callback("version_check",self.dispatcher_version_check)
    self:register_c2s_callback("cmd",self.dispatcher_cmd)
    self:register_c2s_callback("pull",self.dispatcher_pull)
    self:register_c2s_callback("buy_item",self.dispatcher_buy_item)
    self:register_c2s_callback("sale_item",self.dispatcher_sale_item)
    self:register_c2s_callback("sign_in",self.dispatcher_sign_in)
end

function RoleDispatcher.dispatcher_sign_in(role_object,msg_data)
    local timestamp = msg_data.timestamp
    local continue_times = msg_data.continue_times
    if not role_object:check_can_sign(timestamp) then return {result = 101} end
    if continue_times ~= role_object:get_continue_times(timestamp) then return {result = 102} end
    local index = continue_times + 1
    role_object:set_continue_times(index)
    role_object:set_sign_timestamp(timestamp)
    if index < 5 then
        local item_index = 7001
        local item_count = role_object:get_role_manager():get_sign_gold(index)
        return {result = 0,item_objects = {{item_index = item_index,item_count = item_count}}}
    else
        local item_objects = role_object:get_role_manager():gen_sign_rewards()
        return {result = 0,item_objects = item_objects}
    end
end

--版本检查
function RoleDispatcher.dispatcher_version_check(role_object,msg_data)
    local version = msg_data.version
    syslog.debug("version_check:",version)
    return {result = 0}
end

--GM指令
function RoleDispatcher.dispatcher_cmd(role_object,msg_data)
    local func = CMD[msg_data.cmd]
    local result = 0
    if func then
        result = func(role_object,msg_data.args)
    else
        syslog.err("cmd:"..msg_data.cmd.." not callback")
    end
    return {result = result}
end

--获取存档数据
function RoleDispatcher.dispatcher_pull(role_object,msg_data)
    local account_id = role_object:get_account_id()
    local town_name = role_object:get_town_name()
    local gold = role_object:get_gold()
    local cash = role_object:get_cash()
    local topaz = role_object:get_topaz()
    local emerald = role_object:get_emerald()
    local ruby = role_object:get_ruby()
    local amethyst = role_object:get_amethyst()
    local level = role_object:get_level()
    local exp = role_object:get_exp()

    local role_attr = role_object:dump_role_attr()
    local item_data = role_object:get_item_ruler():dump_item_data()
    local grid_data = role_object:get_grid_ruler():dump_grid_data()
    local plant_data = role_object:get_plant_ruler():dump_plant_data()
    local factory_data = role_object:get_factory_ruler():dump_factory_data()
    local feed_data = role_object:get_feed_ruler():dump_feed_data()
    local trains_data = role_object:get_trains_ruler():dump_trains_data()
    local seaport_data = role_object:get_seaport_ruler():dump_seaport_data()
    local flight_data = role_object:get_flight_ruler():dump_flight_data()
    local helicopter_data = role_object:get_helicopter_ruler():dump_helicopter_data()
    local achievement_data = role_object:get_achievement_ruler():dump_achievement_data()
    local market_data = role_object:get_market_ruler():dump_market_data()
    local employment_data = role_object:get_employment_ruler():dump_employment_data()

    local pull_data = {}
    pull_data.account_id = account_id
    pull_data.town_name = town_name
    pull_data.gold = gold
    pull_data.cash = cash
    pull_data.topaz = topaz
    pull_data.emerald = emerald
    pull_data.ruby = ruby
    pull_data.amethyst = amethyst
    pull_data.level = level
    pull_data.exp = exp

    pull_data.role_attr = role_attr
    pull_data.item_data = item_data
    pull_data.grid_data = grid_data
    pull_data.plant_data = plant_data
    pull_data.factory_data = factory_data
    pull_data.feed_data = feed_data
    pull_data.trains_data = trains_data
    pull_data.seaport_data = seaport_data
    pull_data.flight_data = flight_data
    pull_data.helicopter_data = helicopter_data
    pull_data.achievement_data = achievement_data
    pull_data.market_data = market_data
    pull_data.employment_data = employment_data

    return pull_data
end

function RoleDispatcher.dispatcher_buy_item(role_object,msg_data)
    local item_index = msg_data.item_index
    local item_count = msg_data.item_count
    local cash_count = msg_data.cash_count
    local item_ruler = role_object:get_item_ruler()
    local item_entry = item_ruler:get_item_entry(item_index)
    assert(item_entry,"item_entry is nil")
    local unit_price = item_entry:get_cash_count()
    local cash = unit_price * item_count
    if cash ~= cash_count then return {result = 101} end
    if not role_object:check_enough_cash(cash) then return {result = 102} end
    role_object:consume_cash(cash)
    role_object:add_item(item_index,item_count)
end

function RoleDispatcher.dispatcher_sale_item(role_object,msg_data)
    local item_index = msg_data.item_index
    local item_count = msg_data.item_count
    local gold_count = msg_data.gold_count
    local item_ruler = role_object:get_item_ruler()
    local item_entry = item_ruler:get_item_entry(item_index)
    assert(item_entry,"item_entry is nil")
    local unit_price = item_entry:get_sale_price()
    local gold = unit_price * item_count
    if gold ~= gold_count then return {result = 101} end
    if not role_object:check_item(item_index,item_count) then return {result = 102} end
    role_object:consume_item(item_index,item_count)
    role_object:add_gold(gold)
    return {result = 0}
end

return RoleDispatcher

