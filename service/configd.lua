local skynet = require "skynet"
local datacenter = require "skynet.datacenter"

local item_config = require "config.item_config"

skynet.start(function()
	datacenter.set("item_config", item_config)
end)
