local skynet = require "skynet"
local queue = require "skynet.queue"
local syslog = require "syslog"
local RoleObject = require "role.role_object"
local sprotoloader = require "sprotoloader"
local print_r = require "print_r"

local gate
local user
local traceback = debug.traceback

local host
local CMD = {}

-- 处理客户端来的请求消息
-- 这里的local REQUEST在后面的几个register里merge了很多方法进来
local function handle_request (name, args, response)
	syslog.debug("request:"..name,"args:")
	print_r(args)
	local f = user:get_handle_request(name)
	if f then
		local ok, ret = xpcall (f, traceback, user, args)
		if not ok then
			syslog.warningf ("handle message(%s) failed : %s", name, ret) 
		else
			if response and ret then
				syslog.debug("response:")
				print_r(ret)
				return response (ret)
			end
		end
	else
		syslog.warningf ("unhandled message : %s", name)
	end
end

local function handle_response(id, args)

end

function CMD.login(source, account_id, secret)
	-- you may use secret to make a encrypted data stream
	gate = source
	user = RoleObject.new( account_id, secret)
    user:init()
	-- you may load user data from database
end

function CMD.logout()
	-- NOTICE: The logout MAY be reentry
	syslog.debug("logout")
	user:save_player()
	skynet.call(gate,"lua", "logout",user:get_account_id())
end

function CMD.disconnect()
	syslog.debug("disconnect")
	user:save_player()
	skynet.call(gate,"lua", "logout",user:get_account_id())
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, command, ...)
		local f = assert(CMD[command])
		skynet.ret(skynet.pack(f(...)))
	end)
	host = sprotoloader.load(1):host "package"
end)

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch (msg, sz)
	end,
	dispatch = function (_, _, type, ...)
		if type == "REQUEST" then
			skynet.ret(handle_request(...))
		elseif type == "RESPONSE" then
			skynet.ret(handle_response(...))
		else
			syslog.warningf ("invalid message type : %s", type) 
		end
	end,
}

skynet.info_func(function()
	return user:debug_info()
  end)