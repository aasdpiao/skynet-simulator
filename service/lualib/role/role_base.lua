local class = require("class")

local RoleBase = class()

function RoleBase:ctor()
end

function RoleBase:get_account_id()
    return self.__account_id
end

function RoleBase:get_town_name()
    return self.__town_name
end

function RoleBase:set_town_name(town_name)
    self.__town_name = town_name
end

function RoleBase:get_gold()
    return self.__gold
end

function RoleBase:get_cash()
    return self.__cash
end

function RoleBase:get_topaz()
    return self.__topaz
end

function RoleBase:get_emerald()
    return self.__emerald
end

function RoleBase:get_ruby()
    return self.__ruby
end

function RoleBase:get_amethyst()
    return self.__amethyst
end

function RoleBase:get_level()
    return self.__level
end

function RoleBase:set_level(level)
    self.__level = level
end

function RoleBase:check_level(level)
    return self.__level >= level
end

function RoleBase:get_exp()
    return self.__exp
end

function RoleBase:check_people(people)
    return true
end

function RoleBase:check_enough_gold(money)
    return self.__gold >= money
end

function RoleBase:consume_gold(money)
    self.__gold = self.__gold - money
end

function RoleBase:add_gold(money)
    self.__gold = self.__gold + money
end

function RoleBase:check_enough_cash(money)
    return self.__cash >= money
end

function RoleBase:consume_cash(money)
    self.__cash = self.__cash - money
end

function RoleBase:add_cash(money)
    self.__cash = self.__cash + money
end

function RoleBase:check_enough_topaz(money)
    return self.__topaz >= money
end

function RoleBase:consume_topaz(money)
    self.__topaz = self.__topaz - money
end

function RoleBase:add_topaz(money)
    self.__topaz = self.__topaz + money
end

function RoleBase:check_enough_emerald(money)
    return self.__emerald >= money
end

function RoleBase:consume_emerald(money)
    self.__emerald = self.__emerald - money
end

function RoleBase:add_emerald(money)
    self.__emerald = self.__emerald + money
end

function RoleBase:check_enough_ruby(money)
    return self.__ruby >= money
end

function RoleBase:consume_ruby(money)
    self.__ruby = self.__ruby - money
end

function RoleBase:add_ruby(money)
    self.__ruby = self.__ruby + money
end

function RoleBase:check_enough_amethyst(money)
    return self.__amethyst >= money
end

function RoleBase:consume_amethyst(money)
    self.__amethyst = self.__amethyst - money
end

function RoleBase:add_amethyst(money)
    self.__amethyst = self.__amethyst + money
end

function RoleBase:add_exp(exp)
    local role_entry = self.__role_manager:get_role_entry(self.__level)
    local max_exp = role_entry:get_max_exp()
    self.__exp = self.__exp + exp
    if self.__exp < max_exp then return end
    self.pay_levelup_reward(self)
    self.__level = self.__level + 1
    exp = self.__exp - max_exp
    self.__exp = 0
    self:add_exp(exp)
end

function RoleBase:get_role_entry()
    return self.__role_manager:get_role_entry(self.__level)
end

function RoleBase:pay_levelup_reward()
    local role_entry = self:get_role_entry()
    local reward_gold = role_entry:get_reward_gold()
    local reward_cash = role_entry:get_reward_cash()
    local reward_item = role_entry:get_reward_item()
    self:add_gold(reward_gold)
    self:add_cash(reward_cash)
    for k,v in pairs(reward_item) do
        self:add_item(k,v)
    end
end
--[[
3001	黄宝石
3002	蓝宝石
3003	红宝石
3004	紫宝石
7001	金币
7002	钞票

]]
function RoleBase:add_item(item_index,item_count)
    if item_index == 7001 then
        self:add_gold(item_count)
    elseif item_index == 7002 then
        self:add_cash(item_count)
    elseif item_index == 3001 then
        self:add_ruby(item_count)
    elseif item_index == 3002 then
        self:add_emerald(item_count)
    elseif item_index == 3003 then
        self:add_topaz(item_count)
    elseif item_index == 3004 then
        self:add_amethyst(item_count)
    else
        self.__item_ruler:add_item_count(item_index,item_count)
    end
end

function RoleBase:check_item(item_index,item_count)
    item_count = item_count or 1
    return self.__item_ruler:check_item_count(item_index,item_count)
end

function RoleBase:consume_item(item_index,item_count)
    item_count = item_count or 1
    self.__item_ruler:consume_item_count(item_index,item_count)
end

return RoleBase