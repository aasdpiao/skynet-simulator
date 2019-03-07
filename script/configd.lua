local skynet = require "skynet"
local sharedata = require "skynet.sharedata"

local item_config = require "config.item_config"

skynet.start(function()
	sharedata.new("item_config", item_config)
end)
