local RoleObject = class()

function RoleObject:ctor(account_id)
    self.__account_id = account_id
    
end

return RoleObject