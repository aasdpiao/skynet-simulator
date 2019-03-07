local gameserver = require "gameserver.gameserver"
local crypt = require "skynet.crypt"
local skynet = require "skynet"
local syslog = require "syslog"

local loginservice = tonumber(...)

local server = {}
local users = {}
local username_map = {}

local agent_pool = {}

local function get_role_agnet()
	if #agent_pool > 0 then
		return table.remove( agent_pool )
	else
		return skynet.newservice "role_agent"
	end
end

local function recycle_role_agent(agent)
	table.insert(agent_pool,agent)
end

-- login server disallow multi login, so login_handler never be reentry
-- call by login server
function server.login_handler(account_id, secret)
	if users[account_id] then
		error(string.format("%s is already login", account_id))
	end
	local username = gameserver.username(account_id,servername)
	local agent = get_role_agnet()
	local u = {
		username = username,
		agent = agent,
		account_id = account_id,
	}
	skynet.call(agent, "lua", "login",skynet.self(), account_id, secret)
	users[account_id] = u
	username_map[username] = u
	gameserver.login(username, secret)
end

-- call by agent
function server.logout_handler(account_id)
	local u = users[account_id]
	if u then
		local username = gameserver.username(account_id, servername)
		assert(u.username == username)
		gameserver.logout(u.username)
		users[account_id] = nil
		username_map[u.username] = nil
		skynet.call(loginservice, "lua", "logout",account_id)
		recycle_role_agent(u.agent)
	end
end

-- call by login server
function server.kick_handler(account_id)
	local u = users[account_id]
	if u then
		local username = gameserver.username(account_id, servername)
		assert(u.username == username)
		--NOTICE: logout may call skynet.exit, so you should use pcall.
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
	return skynet.tostring(skynet.rawcall(u.agent, "client", msg, sz))
end

-- call by self (when gate open)
function server.register_handler(name)
	servername = name
	skynet.call(loginservice, "lua", "register_gate", servername, skynet.self())
end

gameserver.start(server)

