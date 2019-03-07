local class = require "class"
local ItemEntry = require "item.item_entry"
local print_r = require "print_r"
local sharedata = require "skynet.sharedata"

local ItemManager = class()

function ItemManager:ctor()
    self.__item_entrys = {}
end

function ItemManager:init()
    self:load_item_config()
end

function ItemManager:load_item_config()
    local item_config = sharedata.deepcopy "item_config"
    for k,v in pairs(item_config) do
        local item_index = v.item_index
        local item_entry = ItemEntry.new(item_index)
        item_entry:init_item_entry(v)
        self.__item_entrys[item_index] = item_entry
    end
end

function ItemManager:get_item_entry(item_index)
    return self.__item_entrys[item_index]
end

return ItemManager