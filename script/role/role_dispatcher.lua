local RoleDispatcher = class()

function RoleDispatcher:ctor(role_object)
    self.__role_object = role_object
end

function RoleDispatcher:register_c2s_callback(request_name,callback)
    self.__role_object:register_c2s_callback(request_name,callback)
end

function RoleDispatcher:register_s2c_callback(request_name,callback)
    self.__role_object:register_s2c_callback(request_name,callback)
end

function RoleDispatcher:init()
    self:register_c2s_callback("pingpong",self.dispatcher_c2s_pingpong)

    self:register_s2c_callback("pingpong",self.dispatcher_s2c_pingpong)
end

function RoleDispatcher.dispatcher_s2c_pingpong(role_object,args,msg_data)
    local pong = msg_data.pong
    skynet.error("pong",pong)
end

function RoleDispatcher.dispatcher_c2s_pingpong(role_object,msg_data)
    local ping = msg_data.ping
    self.__role_object:send_request("pingpong",{ping = ping + 1})
    return {pong = ping}
end

return RoleDispatcher