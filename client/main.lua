package.cpath = "skynet/luaclib/?.so"
package.path = "skynet/lualib/?.lua;".."server/lualib/?.lua;".."?.lua;".."preload/?.lua"

require "luaext"
require "error_code"
require "source_code"
require "consume_code"
require "msg"
require "random"

local RoleObject = require("client.role_object")

local token = {
	server = "township",
	user = "zdq",
	pass = "123456",
}

local role_object = RoleObject.new(token)
role_object:start()

