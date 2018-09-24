local skynet = require "skynet"
local sprotoparser = require "sprotoparser"
local sprotoloader = require "sprotoloader"
local service = require "skynet.service"
local syslog = require "syslog"

local c2s_sproto_file = {
	"1_role",
	"2_plant",
	"3_grid",
	"4_time",
	"5_factory",
	"6_breed",
	"7_trains",
	"8_seaport",
	"9_flight",
	"10_helicopter",
	"11_achievement",
	"12_market",
	"13_employment",
}

local s2c_sproto_file = {

}

local attr_file = "proto.attr"

local function read_file(name)
	local filename = string.format("proto/%s.sproto", name)
	local f = assert(io.open(filename), "Can't open " .. name)
	local t = f:read "a"
	f:close()
	return t
end

local function load_c2s_sproto()
	local attr = read_file(attr_file)
	local sp = "\n"
	for i,file_name in ipairs(c2s_sproto_file) do
		local name = "c2s/"..file_name
		sp = sp .. read_file(name).."\n"
	end
	return sprotoparser.parse(attr..sp)
end

local function load_s2c_sproto()
	local attr = read_file(attr_file)
	local sp = "\n"
	for i,file_name in ipairs(s2c_sproto_file) do
		local name = "s2c/"..file_name
		sp = sp .. read_file(name).."\n"
	end
	return sprotoparser.parse(attr..sp)
end

skynet.start(function()
	local c2s = load_c2s_sproto()
	syslog.debugf("load c2s sproto in slot %d", 1)
	sprotoloader.save(c2s, 1)
	local s2c = load_s2c_sproto()
	syslog.debugf("load s2c sproto in slot %d", 2)
	sprotoloader.save(s2c, 2)
end)
