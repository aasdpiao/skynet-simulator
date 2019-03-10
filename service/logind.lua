local login = require "loginserver.loginserver"
local crypt = require "skynet.crypt"

local server = {
	host = "127.0.0.1",
	port = 8001,
	multilogin = false,
	name = "login_master",
}

local server_list = {}
local user_online = {}
local user_login = {}

function server.auth_handler(token)
	local user, server, password = token:match("([^@]+)@([^:]+):(.+)")
	user = crypt.base64decode(user)
	server = crypt.base64decode(server)
    password = crypt.base64decode(password)
    local sql = string.format("call check_account_and_password('%s', '%s')",user,password)
	local ret = skynet.call("mysqld","lua","queryaccountdb",sql)
    local retcode = ret[1][1][1]
	local account_id= ret[1][1][2]
    assert(retcode == "200", "Invalid password")
	return server, user, account_id
end

function server.login_handler(server, user, account_id, secret)
	print(string.format("%s@%s is login,account_id is %d secret is %s", user, server,account_id, crypt.hexencode(secret)))
	local gameserver = assert(server_list[server], "Unknown server")
	local last = user_online[account_id]
	if last then
		skynet.call(last.address, "lua", "kick", account_id, last.subid)
	end
	if user_online[account_id] then
		error(string.format("user %s is already online", user))
	end
	skynet.call(gameserver, "lua", "login", account_id, secret)
	user_online[account_id] = { address = gameserver, account_id = account_id , server = server, user = user}
	return account_id
end

local CMD = {}

function CMD.register_gate(server, address)
	server_list[server] = address
end

function CMD.logout(uid, subid)
	local u = user_online[uid]
	if u then
		print(string.format("%s@%s is logout", uid, u.server))
		user_online[uid] = nil
	end
end

function server.command_handler(command, ...)
	local f = assert(CMD[command])
	return f(...)
end

login(server)
