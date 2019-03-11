local msgserver = require "gameserver.msgserver"
local crypt = require "skynet.crypt"
local skynet = require "skynet"
local RoleObject = require "role.role_object"

local loginservice = tonumber(...)

local server = {}
local users = {}
local username_map = {}
local servername

local role_objects = {}


local function get_role_object(account_id)
	local role_object = role_objects[account_id]
	if not role_object then
		local agent = skynet.newservice "agent"
		role_object = RoleObject.new(account_id,agent)
		role_objects[account_id] = role_object
	end
	return role_object
end


-- login server disallow multi login, so login_handler never be reentry
-- call by login server
function server.login_handler(account_name,account_id,secret)
	if users[account_id] then
		error(string.format("%s is already login", account_name))
	end
	local username = msgserver.username(account_name, account_id, servername)
	local fd = msgserver.fd(username)
	-- you can use a pool to alloc new agent
	local role_object = get_role_object(account_id)
	role_object:set_client_fd(fd)

	-- trash subid (no used)
	skynet.call(role_object:get_agent(), "lua", "login", uid, id, secret)

	users[account_id] = role_object
	username_map[username] = role_object

	msgserver.login(username, secret)
end

-- call by agent
function server.logout_handler(account_id)
	local u = users[account_id]
	if u then
		local username = msgserver.username(uid, subid, servername)
		assert(u.username == username)
		msgserver.logout(u.username)
		users[account_id] = nil
		username_map[u.username] = nil
		skynet.call(loginservice, "lua", "logout",uid, subid)
	end
end

-- call by login server
function server.kick_handler(uid, subid)
	local u = users[uid]
	if u then
		local username = msgserver.username(uid, subid, servername)
		assert(u.username == username)
		-- NOTICE: logout may call skynet.exit, so you should use pcall.
		pcall(skynet.call, u.agent, "lua", "logout")
	end
end

-- call by self (when socket disconnect)
function server.disconnect_handler(username)
	local u = username_map[username]
	if u then
		skynet.call(u.agent, "lua", "afk")
	end
end

-- call by self (when recv a request from client)
function server.request_handler(username, msg, sz)
	local u = username_map[username]
	skynet.rawsend(u.agent, "client", msg, sz)
end

-- call by self (when gate open)
function server.register_handler(name)
	servername = name
	skynet.call(loginservice, "lua", "register_gate", servername, skynet.self())
end

msgserver.start(server)

