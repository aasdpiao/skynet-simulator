local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local cjson = require "cjson"
local table = table
local string = string

local mode = ...

if mode == "agent" then
    local function response(id, ...)
        local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
        if not ok then
            skynet.error(string.format("fd = %d, %s", id, err))
        end
    end

    --处理注册问题
    local function requst_register(params)
        local username = params.username
        local password = params.password
        if not username or not password then
            return "用户名或密码为空,参数错误"
        end
        local sql = string.format("call register_new_account('%s', '%s', '%s')",username,password,"game")
        local ret = skynet.call("mysqld","lua","queryaccountdb",sql,true)
        local retcode = ret[1][1][1]
        local account_id = ret[1][1][2]
        skynet.error(retcode)
        skynet.error(account_id)
        if retcode == 101 then
            return "用户名已注册"
        elseif retcode == 100 then
            sql = string.format("call new_player(%d,%s)",account_id,""..account_id)
            skynet.call("mysqld","lua","querygamedb",sql,true)
            return "注册成功"
        end
    end

    skynet.start(function()
        skynet.dispatch("lua", function (_,_,id)
            socket.start(id)
            local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
            if code then
                if code ~= 200 then
                    response(id, code)
                else
                    local path, query = urllib.parse(url)
                    if not query then
                        response(id, code,"query is nil")
                    end
                    local params = urllib.parse_query(query)
                    local result = requst_register(params)
                    response(id, code, result)
                end
            else
                if url == sockethelper.socket_error then
                    skynet.error("socket closed")
                else
                    skynet.error(url)
                end
            end
            socket.close(id)
        end)
    end)
else
    skynet.start(function()
        local agent = {}
        for i= 1, 8 do
            agent[i] = skynet.newservice(SERVICE_NAME, "agent")
        end
        local balance = 1
        local port = tonumber(skynet.getenv "register_port")
        local id = socket.listen("0.0.0.0", port)
        skynet.error("Listen web port "..port)
        socket.start(id , function(id, addr)
            skynet.error(string.format("%s connected, pass it to agent :%08x", addr, agent[balance]))
            skynet.send(agent[balance], "lua", id)
            balance = balance + 1
            if balance > #agent then
                balance = 1
            end
        end)
    end)
end