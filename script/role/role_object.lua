local RoleObject = class()
local RoleDispatcher = require "role.role_dispatcher"

function RoleObject:ctor(account_id,send_request)
    self.__account_id = account_id
    self.__send_request = send_request
    self.__c2s_protocal = {}
    self.__s2c_protocal = {}
end

function RoleObject:init()
    self.__role_dispatcher = RoleDispatcher.new(self)
    self.__role_dispatcher:init()
end

function RoleObject:register_c2s_callback(request_name,callback)
    self.__c2s_protocal[request_name] = callback
end

function RoleObject:register_s2c_callback(response_name,callback)
    self.__s2c_protocal[response_name] = callback
end

function RoleObject:get_handle_request(request_name)
    return self.__c2s_protocal[request_name]
end

function RoleObject:get_handle_response(response_name)
    return self.__s2c_protocal[response_name]
end

function RoleObject:send_request(name, args)
    self.__send_request(name, args)
end

return RoleObject