local class = require "class"
local skynet = require "skynet"
local RoleManager = require "role.role_manager"
local ItemRuler = require "item.item_ruler"
local GridRuler = require "grid.grid_ruler" 
local PlantRuler = require "plant.plant_ruler"
local FactoryRuler = require "factory.factory_ruler"
local FeedRuler = require "feed.feed_ruler"
local PeopleRuler = require "people.people_ruler"
local TimeRuler = require "time.time_ruler"
local TrainsRuler = require "trains.trains_ruler"
local SeaportRuler = require "seaport.seaport_ruler"
local FlightRuler = require "flight.flight_ruler"
local HelicopterRuler = require "helicopter.helicopter_ruler"
local AchievementRuler = require "achievement.achievement_ruler"
local MarketRuler = require "market.market_ruler"
local EmploymentRuler = require "employment.employment_ruler"
local syslog = require "syslog"
local print_r = require "print_r"
local cjson = require "cjson"
local utils = require "utils"
local RoleBase = require "role.role_base"
local sprotoloader = require "sprotoloader"
local role_const = require "role.role_const"
local crypt = require "skynet.crypt"
local base64encode = crypt.base64encode
local base64decode = crypt.base64decode

local RoleObject = class(RoleBase)


function RoleObject:ctor(account_id,secret)
    self.__account_id = tonumber(account_id)
    self.__secret = secret

    self.__town_name = "township"
    self.__gold = 0
    self.__cash = 0
    
    self.__topaz = 0
    self.__emerald = 0
    self.__ruby = 0
    self.__amethyst = 0
    
    self.__level = 1
    self.__exp = 0

    self.__c2s_protocal = {}
    self.__s2c_protocal = {}

    self.__role_attrs = {}

end

function RoleObject:init()
    self.__role_manager = RoleManager.new(self)
    self.__role_manager:init()
    self.__item_ruler = ItemRuler.new(self)
    self.__item_ruler:init()
    self.__grid_ruler = GridRuler.new(self)
    self.__grid_ruler:init()
    self.__plant_ruler = PlantRuler.new(self)
    self.__plant_ruler:init()
    self.__factory_ruler = FactoryRuler.new(self)
    self.__factory_ruler:init()
    self.__feed_ruler = FeedRuler.new(self)
    self.__feed_ruler:init()
    self.__people_ruler = PeopleRuler.new(self)
    self.__people_ruler:init()
    self.__time_ruler = TimeRuler.new(self)
    self.__time_ruler:init()
    self.__trains_ruler = TrainsRuler.new(self)
    self.__trains_ruler:init()
    self.__seaport_ruler = SeaportRuler.new(self)
    self.__seaport_ruler:init()
    self.__flight_ruler = FlightRuler.new(self)
    self.__flight_ruler:init()
    self.__helicopter_ruler = HelicopterRuler.new(self)
    self.__helicopter_ruler:init()
    self.__achievement_ruler = AchievementRuler.new(self)
    self.__achievement_ruler:init()
    self.__market_ruler = MarketRuler.new(self)
    self.__market_ruler:init()
    self.__employment_ruler = EmploymentRuler.new(self)
    self.__employment_ruler:init()
    self:load_player()
end

function RoleObject:register_c2s_callback(request_name,callback)
    self.__c2s_protocal[request_name] = callback
end

function RoleObject:register_s2c_callback(response_name,callback)
    self.__s2c_protocal[response_name] = callback
end

function RoleObject:get_handle_request(request_name)
    return self.__c2s_protocal[request_name]
end

function RoleObject:get_handle_response(response_name)
    return self.__s2c_protocal[response_name]
end

function RoleObject:get_role_manager()
    return self.__role_manager
end

function RoleObject:get_item_ruler()
    return self.__item_ruler
end

function RoleObject:get_plant_ruler()
    return self.__plant_ruler
end

function RoleObject:get_grid_ruler()
    return self.__grid_ruler
end

function RoleObject:get_time_ruler()
    return self.__time_ruler
end

function RoleObject:get_factory_ruler()
    return self.__factory_ruler
end

function RoleObject:get_feed_ruler()
    return self.__feed_ruler
end

function RoleObject:get_people_ruler()
    return self.__people_ruler
end

function RoleObject:get_trains_ruler()
    return self.__trains_ruler
end

function RoleObject:get_seaport_ruler()
    return self.__seaport_ruler
end

function RoleObject:get_flight_ruler()
    return self.__flight_ruler
end

function RoleObject:get_helicopter_ruler()
    return self.__helicopter_ruler
end

function RoleObject:get_achievement_ruler()
    return self.__achievement_ruler
end

function RoleObject:get_market_ruler()
    return self.__market_ruler
end

function RoleObject:get_employment_ruler()
    return self.__employment_ruler
end

function RoleObject:get_role_attr(key,default)
    return self.__role_attrs[key] or default
end

function RoleObject:set_role_attr(key,value)
    self.__role_attrs[key] = value
end

function RoleObject:load_role_attr(role_attrs)
    if not role_attrs then return end
    self.__role_attrs = cjson.decode(role_attrs)
end

function RoleObject:dump_role_attr()
    return cjson.encode(self.__role_attrs)
end

function RoleObject:serialize_role_attr()
    return self:dump_role_attr()
end

function RoleObject:check_can_sign(timestamp)
    local sign_timestamp = self.__role_attrs.sign_timestamp or 0
    local interval_timestamp = utils.get_interval_timestamp(timestamp) - (24 * 60 * 60)
    return interval_timestamp > sign_timestamp
end

function RoleObject:get_continue_times(timestamp)
    local continue_times = self.__role_attrs.continue_times or 0
    local sign_timestamp = self.__role_attrs.sign_timestamp or 0
    local interval_timestamp = utils.get_interval_timestamp(sign_timestamp)
    local current = utils.get_interval_timestamp(timestamp)
    if timestamp - interval_timestamp > (24 * 60 *60) then
        self.__role_attrs.continue_times = 0
    end
    return self.__role_attrs.continue_times
end

function RoleObject:set_continue_times(times)
    self.__role_attrs.continue_times = times
end

function RoleObject:set_sign_timestamp(timestamp)
    self.__role_attrs.sign_timestamp = timestamp
end

function RoleObject:load_player()
    local mysqld = skynet.queryservice("mysqld")
	local sql = string.format("call load_player(%d)",self.__account_id)
    local ret = skynet.call(mysqld,"lua","querygamedb",sql)
    local select = ret[1][1]
    local retcode = select[role_const.retcode]
    if retcode ~= 0 then return end
    local town_name = select[role_const.town_name]
    local gold = select[role_const.gold]
    local cash = select[role_const.cash]
    local topaz = select[role_const.topaz]
    local emerald = select[role_const.emerald]
    local ruby = select[role_const.ruby]
    local amethyst = select[role_const.amethyst]
    local level = select[role_const.level]
    local exp = select[role_const.exp]

    local role_attr = select[role_const.role_attr]
    local item_data = select[role_const.item_data]
    local grid_data = select[role_const.grid_data]
    local plant_data = select[role_const.plant_data]
    local factory_data = select[role_const.factory_data]
    local feed_data = select[role_const.feed_data]
    local trains_data = select[role_const.trains_data]
    local seaport_data = select[role_const.seaport_data]
    local flight_data = select[role_const.flight_data]
    local helicopter_data = select[role_const.helicopter_data]
    local achievement_data = select[role_const.achievement_data]
    local market_data = select[role_const.market_data]
    local employment_data = select[role_const.employment_data]
    
    if role_attr then role_attr = base64decode(role_attr) end
    if item_data then item_data = base64decode(item_data) end
    if grid_data then grid_data = base64decode(grid_data) end
    if plant_data then plant_data = base64decode(plant_data) end
    if factory_data then factory_data = base64decode(factory_data) end
    if feed_data then feed_data = base64decode(feed_data) end
    if trains_data then trains_data = base64decode(trains_data) end
    if seaport_data then seaport_data = base64decode(seaport_data) end
    if flight_data then flight_data = base64decode(flight_data) end
    if helicopter_data then helicopter_data = base64decode(helicopter_data) end
    if achievement_data then achievement_data = base64decode(achievement_data) end
    if market_data then market_data = base64decode(market_data) end
    if employment_data then employment_data = base64decode(employment_data) end
   
    self.__town_name = town_name
    self.__gold = gold
    self.__cash = cash
    self.__topaz = topaz
    self.__emerald = emerald
    self.__ruby = ruby
    self.__amethyst = amethyst
    self.__level = level
    self.__exp = exp

    self:load_role_attr(role_attr)
    self.__item_ruler:load_item_data(item_data)
    self.__grid_ruler:load_grid_data(grid_data)
    self.__plant_ruler:load_plant_data(plant_data)
    self.__factory_ruler:load_factory_data(factory_data)
    self.__feed_ruler:load_feed_data(feed_data)
    self.__trains_ruler:load_trains_data(trains_data)
    self.__seaport_ruler:load_seaport_data(seaport_data)
    self.__flight_ruler:load_flight_data(flight_data)
    self.__helicopter_ruler:load_helicopter_data(helicopter_data)
    self.__achievement_ruler:load_achievement_data(achievement_data)
    self.__market_ruler:load_market_data(market_data)
    self.__employment_ruler:load_employment_data(employment_data)
end

function RoleObject:save_player()
    local town_name = self.__town_name
    local gold = self.__gold
    local cash = self.__cash
    local topaz = self.__topaz
    local emerald = self.__emerald
    local ruby = self.__ruby
    local amethyst = self.__amethyst
    local level = self.__level
    local exp = self.__exp

    local role_attr = base64encode(self.serialize_role_attr(self))
    local item_data = base64encode(self.__item_ruler:serialize_item_data())
    local grid_data = base64encode(self.__grid_ruler:serialize_grid_data())
    local plant_data = base64encode(self.__plant_ruler:serialize_plant_data())
    local factory_data = base64encode(self.__factory_ruler:serialize_factory_data())
    local feed_data = base64encode(self.__feed_ruler:serialize_feed_data())
    local trains_data = base64encode(self.__trains_ruler:serialize_trains_data())
    local seaport_data = base64encode(self.__seaport_ruler:serialize_seaport_data())
    local flight_data = base64encode(self.__flight_ruler:serialize_flight_data())
    local helicopter_data = base64encode(self.__helicopter_ruler:serialize_helicopter_data())
    local achievement_data = base64encode(self.__achievement_ruler:serialize_achievement_data())
    local market_data = base64encode(self.__market_ruler:serialize_market_data())
    local employment_data = base64encode(self.__employment_ruler:serialize_employment_data())
    
    local sql = string.format("call save_player(%d,'%s',%d,%d,%d,%d,%d,%d,%d,%d,'%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')",self.__account_id,
    town_name,gold,cash,topaz,emerald,ruby,amethyst,level,exp,
    role_attr,item_data,grid_data,plant_data,factory_data,feed_data,
    trains_data,seaport_data,flight_data,helicopter_data,achievement_data,
    market_data,employment_data)
    local mysqld = skynet.queryservice("mysqld")
    local ret = skynet.call(mysqld,"lua","querygamedb",sql,true)
end

function RoleObject:debug_info()
    local role_info = ""
    role_info = role_info.."account_id:"..self.__account_id.."\n"
    role_info = role_info.."town_name:"..self.__town_name.."\n"
    role_info = role_info.."gold:"..self.__gold.."\n"
    role_info = role_info.."cash:"..self.__cash.."\n"
    role_info = role_info.."topaz:"..self.__topaz.."\n"
    role_info = role_info.."emerald:"..self.__emerald.."\n"
    role_info = role_info.."ruby:"..self.__ruby.."\n"
    role_info = role_info.."amethyst:"..self.__amethyst.."\n"
    role_info = role_info.."level:"..self.__level.."\n"
    role_info = role_info.."exp:"..self.__exp.."\n"
    role_info = role_info.."role_attr:"..cjson.encode(self.__role_attrs).."\n"

    role_info = role_info.."item:\n"..self.__item_ruler:debug_info().."\n"
    role_info = role_info.."factory:\n"..self.__factory_ruler:debug_info().."\n"
    role_info = role_info.."trains:\n"..self.__trains_ruler:debug_info().."\n"
    role_info = role_info.."employ:\n"..self.__employment_ruler:debug_info().."\n"
    return role_info
end

return RoleObject