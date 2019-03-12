local skynet = require "skynet"

local debug_console_port = tonumber(skynet.getenv "debug_console_port")
local game_port = tonumber(skynet.getenv "game_port")

skynet.start(function()
	--初始化日志管理器
	skynet.uniqueservice "logd"
	skynet.call("logd", "lua", "start")

	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end

	skynet.newservice("debug_console",debug_console_port)
	--加载协议
	skynet.uniqueservice "sprotod"
	--加载配置文件
	skynet.uniqueservice "configd"
	--初始化数据库
	skynet.uniqueservice "mysqld"
	--初始化redis
	skynet.uniqueservice "redisd"
	--初始化推荐系统
	skynet.uniqueservice "recommend"
	--初始化时间管理器
	skynet.uniqueservice "timed"
	--初始化web服务器
	skynet.uniqueservice "httpd"
	--初始化注册服务器
	skynet.uniqueservice "registerd"
	--启动登录服务器
	local loginserver = skynet.newservice("logind")
	--启动网关
	local game = skynet.uniqueservice("gamed", loginserver)
	skynet.call(game, "lua", "open" , {
		port = game_port,
		maxclient = 1024,
		servername = "township",
	})
	skynet.exit()
end)
