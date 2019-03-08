local source = {}

function source_msg(sc)
	if not sc then
		return "nil"
	end
	return source[sc].desc
end

local function add(sou)
	assert(source[sou.code] == nil, string.format("have the same error code[%x], msg[%s]", sou.code, sou.message))
	source[sou.code] = {desc = sou.desc , type = sou.type}
	return sou.code
end

SOURCE_CODE = {
	no_source            = add{code = 0x0000, desc = "未标记来源"},
	sign_in              = add{code = 0x0001, desc = "签到"},
	levelup              = add{code = 0x0002, desc = "升级"},
	buy_item             = add{code = 0x0003, desc = "购买物品"},
	sale_item            = add{code = 0x0004, desc = "出售物品"},
}

return source