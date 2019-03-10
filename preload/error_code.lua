local errors = {}

function error_msg(ec)
	if not ec then
		return "nil"
	end
	return errors[ec].desc
end

local function add(err)
	assert(errors[err.code] == nil, string.format("have the same error code[%x], msg[%s]", err.code, err.message))
	errors[err.code] = {desc = err.desc , type = err.type}
	return err.code
end

SYSTEM_ERROR = {
	success            = add{code = 0x0000, desc = "请求成功"},
	unknow             = add{code = 0x0001, desc = "未知错误"},
	argument           = add{code = 0x0002, desc = "参数错误"},
	busy               = add{code = 0x0003, desc = "服务繁忙"},
	forward            = add{code = 0x0004, desc = "协议转发"},
	decode_failure     = add{code = 0x0005, desc = "解析协议失败"},
	decode_header      = add{code = 0x0006, desc = "解析包头出错"},
	decode_data        = add{code = 0x0007, desc = "解析包体出错"},
	unknow_protoid     = add{code = 0x0008, desc = "未知协议id"},
	unknow_proto       = add{code = 0x0009, desc = "未知协议"},
	unknow_roomproxy   = add{code = 0x000a, desc = "未知房间地址"},
	invalid_proto      = add{code = 0x000b, desc = "非法协议"},
	no_auth_account    = add{code = 0x000c, desc = "未登录帐号"},
	service_stoped     = add{code = 0x000d, desc = "服务故障"},
	no_login_game      = add{code = 0x000e, desc = "未登陆游戏"},
	service_not_impl   = add{code = 0x000f, desc = "服务未实现"},
	module_not_impl    = add{code = 0x0010, desc = "模块未实现"},
	func_not_impl      = add{code = 0x0011, desc = "函数未实现"},
	service_maintance  = add{code = 0x0012, desc = "服务维护"},
}

AUTH_ERROR = {
	account_nil        = add{code = 0x0101, desc = "帐号为空"},
	password_nil       = add{code = 0x0102, desc = "密码为空"},
	account_exist      = add{code = 0x0103, desc = "帐号存在"},
	repeat_login       = add{code = 0x0104, desc = "重复登录"},
	account_not_exist  = add{code = 0x0105, desc = "不存在此帐号"},
	password_wrong     = add{code = 0x0106, desc = "密码错误"},
	player_not_exist   = add{code = 0x0107, desc = "对应的玩家不存在"},
	forbid_login       = add{code = 0x0108, desc = "禁止登陆"},
}

GAME_ERROR = {
	gold_not_enough    			= add{code = 0x1001, desc = "金币不足"},
	cash_not_enough    			= add{code = 0x1002, desc = "钞票不足"},
}

DB_ERROR = {
	SQL_ERROR    			= add{code = 0x2001, desc = "SQL执行出错"},
}

return errors