local msgserver = require "gameserver.msgserver"
local crypt = require "skynet.crypt"
local skynet = require "skynet"

local loginservice = tonumber(...)

local server = {}
local users = {}
local username_map = {}
local servername

local agents = {}

local function get_agent()
	local agent = table.remove(agents)
	if not agent then
		agent = skynet.newservice "agent"
	end
	return agent
end

-- login server disallow multi login, so login_handler never be reentry
-- call by login server
function server.login_handler(account_name,account_id,secret)
	if users[account_id] then
		LOG_WARNING("%s is already login", account_name)
		local u = users[account_id]
		skynet.call(u.agent, "lua", "reenter", account_name, account_id, secret)
		msgserver.reenter(u.username,secret)
		return
	end
	local username = msgserver.username(account_name, account_id, servername)
	-- you can use a pool to alloc new agent
	local agent = get_agent()
	-- trash subid (no used)
	skynet.call(agent, "lua", "login", account_name, account_id, secret)

	local u = {
		username = username,
		agent = agent,
		account_name = account_name,
		account_id = account_id,
	}

	users[account_id] = u
	username_map[username] = u

	msgserver.login(username, secret)
end

-- call by agent
function server.logout_handler(account_name,account_id)
	local u = users[account_id]
	if u then
		local username = msgserver.username(account_name, account_id, servername)
		assert(u.username == username)
		msgserver.logout(u.username)
		users[account_id] = nil
		username_map[u.username] = nil
		skynet.call(loginservice, "lua", "logout",account_name, account_id)
	end
end

-- call by login server
function server.kick_handler(account_name, account_id)
	local u = users[account_id]
	if u then
		local username = msgserver.username(account_name, account_id, servername)
		assert(u.username == username)
		-- NOTICE: logout may call skynet.exit, so you should use pcall.
		pcall(skynet.call, u.agent, "lua", "logout")
	end
end

-- call by self (when socket disconnect)
function server.disconnect_handler(username)
	local u = username_map[username]
	if u then
		skynet.call(u.agent, "lua", "disconnect")
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

function server.auth_handler(username,fd)
	local u = username_map[username]
	skynet.send(u.agent, "lua", "auth_handler", fd)
end

msgserver.start(server)

