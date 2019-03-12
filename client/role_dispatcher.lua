local RoleDispatcher = class()

function RoleDispatcher:ctor()
    self.__s2c_protocal = {}
    self.__c2s_protocal = {}
end

function RoleDispatcher:register_s2c_callback(name,callback)
    self.__s2c_protocal[name] = callback
end

function RoleDispatcher:register_c2s_callback(name,callback)
    self.__c2s_protocal[name] = callback
end

function RoleDispatcher:get_handle_request(name)
    return self.__c2s_protocal[name]
end

function RoleDispatcher:get_handle_response(name)
    return self.__s2c_protocal[name]
end

function RoleDispatcher:init()
    self:register_s2c_callback("synctime",self.dispatcher_s2c_pingpong)
    self:register_c2s_callback("synctime",self.dispatcher_c2s_pingpong)
end

function RoleDispatcher.dispatcher_s2c_pingpong(role_object,args)
    local ping = args.ping
    role_object:send_request("ping",{ping = ping + 1})
    return {pong = ping}
end

function RoleDispatcher.dispatcher_c2s_pingpong(role_object,params,args)
    local pong = args.pong
    print(pong)
end

return RoleDispatcher

