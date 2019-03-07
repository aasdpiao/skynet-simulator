local CMD = {}
local print_r = require "print_r"
local syslog =require "syslog"

local function string_split(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end
	
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function CMD.add_gold(role_object,cmd_args)
    local money = tonumber(cmd_args[1])
    role_object:add_gold(money)
    return 0
end

function CMD.add_cash(role_object,cmd_args)
    local money = tonumber(cmd_args[1])
    role_object:add_cash(money)
    return 0
end

function CMD.add_exp(role_object,cmd_args)
    local exp = tonumber(cmd_args[1])
    role_object:add_exp(exp)
    return 0
end

function CMD.add_item(role_object,cmd_args)
    local args = string_split(cmd_args[1]," ")
    local item_index = tonumber(args[1])
    local item_count = 1
    if args[2] then
        item_count = tonumber(args[2])
    end
    role_object:get_item_ruler():add_item_count(item_index,item_count)
    return 0
end

function CMD.set_level(role_object,cmd_args)
    local level = tonumber(cmd_args[1])
    assert(level,"set level is nil")
    role_object:set_level(level)
    return 0
end

function CMD.add_topaz(role_object,cmd_args)
    local money = tonumber(cmd_args[1])
    role_object:add_topaz(money)
    return 0
end

function CMD.add_emerald(role_object,cmd_args)
    local money = tonumber(cmd_args[1])
    role_object:add_emerald(money)
    return 0
end

function CMD.add_ruby(role_object,cmd_args)
    local money = tonumber(cmd_args[1])
    role_object:add_ruby(money)
    return 0
end

function CMD.add_amethyst(role_object,cmd_args)
    local money = tonumber(cmd_args[1])
    role_object:add_amethyst(money)
    return 0
end

return CMD