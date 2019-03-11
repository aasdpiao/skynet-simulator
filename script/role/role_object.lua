local RoleObject = class()

function RoleObject:ctor(fd,account_id)
    self.__account_id = account_id
end

function RoleObject:set_client_fd(fd)
    self.__fd = fd
end

return RoleObject