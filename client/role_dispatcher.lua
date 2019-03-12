local RoleDispatcher = class()

function RoleDispatcher:ctor()
    self.__protocal = {}
end

function RoleDispatcher:register_s2c_callback(name,callback)
    self.__protocal[name] = callback
end

function RoleDispatcher:get_handle_response(name)
    return self.__protocal[name]
end

function RoleDispatcher:init()
    -- self:register_s2c_callback("synctime",self.dispatcher_synctime)
    -- self:register_s2c_callback("cmd",self.dispatcher_cmd)
    -- self:register_s2c_callback("pull",self.dispatcher_pull)
    -- self:register_s2c_callback("push",self.dispatcher_push)
    -- self:register_s2c_callback("planting_cropper",self.dispatcher_planting_cropper)
    -- self:register_s2c_callback("harvest_cropper",self.dispatcher_harvest_cropper)
    -- self:register_s2c_callback("promote_plant",self.dispatcher_promote_plant)
end

return RoleDispatcher

