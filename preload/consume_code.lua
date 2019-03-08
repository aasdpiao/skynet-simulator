local consume = {}

function consume_msg(sc)
	if not sc then
		return "nil"
	end
	return consume[sc].desc
end

local function add(con)
	assert(consume[con.code] == nil, string.format("have the same error code[%x], msg[%s]", con.code, con.message))
	consume[con.code] = {desc = con.desc , type = con.type}
	return con.code
end

CONSUME_CODE = {
	no_consume              = add{code = 0x0000, desc = "未标记"},
	buy_item                = add{code = 0x0001, desc = "购买物品"},
	sale_item               = add{code = 0x0002, desc = "出售物品"},
}

return consume