local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local socketdriver = require "skynet.socketdriver"
local RoleObject = require "role.role_object"

local host = sprotoloader.load(MSG.c2s):host "package"
local request = host:attach (sprotoloader.load (MSG.s2c))

local gate
local account_name,account_id,client_fd
local role_object

local session = {}
local session_id = 0

local function send_message(message)
	if not client_fd then return end
	local package = string.pack (">s2", message)
	socketdriver.send(client_fd, package)
end

local function send_request (name, args)
	session_id = session_id + 1
	local msg = request (name, args, session_id)
	send_message(msg)
	session[session_id] = { name = name, args = args }
end

-- 处理客户端来的请求消息
-- 这里的local REQUEST在后面的几个register里merge了很多方法进来
local function handle_request (name, args, response)
	local f = role_object:get_handle_request(name)
	if f then
		local ok, ret = xpcall (f, debug.traceback, role_object, args)
		if not ok then
			syslog.warningf ("handle message(%s) failed : %s", name, ret) 
		else
			if response and ret then
				local message = response(ret)
				send_message(message)
			end
		end
	else
		syslog.warningf ("unhandled message : %s", name)
	end
end
-- 处理客户端来的返回消息
-- 这里的local REQUEST在后面的几个register里merge了很多方法进来
local function handle_response(id, args)
	local s = session[id]
	session[id] = nil
	if not s then
		syslog.warningf ("session %d not found", id)
		return
	end
	local f = role_object:get_handle_response(s.name)
	if not f then
		syslog.warningf ("unhandled response : %s", s.name)
		return
	end
	local ok, ret = xpcall (f, debug.traceback, role_object, s.args, args)
	if not ok then
		syslog.warningf ("handle response(%d-%s) failed : %s", id, s.name, ret) 
	end
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		return host:dispatch (msg, sz)
	end,
	dispatch = function (_, _, type, ...)
		if type == "REQUEST" then
			handle_request(...)
		elseif type == "RESPONSE" then
			handle_response(...)
		end
	end,
}

local CMD = {}

function CMD.login(source, name, id, secret)
	-- you may use secret to make a encrypted data stream
	skynet.error(string.format("%s is login", name))
	gate = source
	account_name = name
	account_id = id
	role_object = RoleObject.new(account_id,send_request)
	role_object:init()
	-- you may load user data from database
end

function CMD.logout(source)
	-- NOTICE: The logout MAY be reentry
	skynet.error(string.format("%s is logout", account_name))
	if gate then
		skynet.call(gate, "lua", "logout", account_name, account_id)
	end
	skynet.exit()
end

function CMD.disconnect(source)
	-- the connection is broken, but the user may back
	skynet.error(string.format("AFK"))
end

function CMD.auth_handler(source,fd)
	client_fd = fd
end

skynet.start(function()
	-- If you want to fork a work thread , you MUST do it in CMD.login
	skynet.dispatch("lua", function(session, source, command, ...)
		local f = assert(CMD[command])
		skynet.ret(skynet.pack(f(source, ...)))
	end)
end)