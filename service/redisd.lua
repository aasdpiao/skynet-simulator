local redis = require "skynet.db.redis"
local packer = require "db.packer"
local db_const = require "db.db_const"
local cjson = require "cjson"
local md5 = require "md5"
require "skynet.manager"

cjson.encode_sparse_array(true, 1, 1)

local CMD = {}
local pool = {}

local maxconn = 1
local save_timer
local SAVE_INTERAL = 100   --定时存档时间间隔

local function getconn(uid)
	local db
	if not uid or maxconn == 1 then
		db = pool[1]
	else
		db = pool[uid % (maxconn - 1) + 2]
	end
	return db
end

local function start()
	local db = redis.connect{
	host = skynet.getenv("redis_host"),
	port = skynet.getenv("redis_port"),
	db = 0,
	auth = skynet.getenv("redis_auth"),
	}
	if db then
		db:flushdb() --清理redis数据
		table.insert(pool, db)
		skynet.error("redis connect sucess")
	else
		skynet.error("redis connect error")
	end
end

function CMD.set(uid, key, value)
	local db = getconn(uid)
	local retsult = db:set(key,value)
	return retsult
end

function CMD.get(uid, key)
	local db = getconn(uid)
	local retsult = db:get(key)
	return retsult
end

function CMD.hmset(uid, key, t)
	local data = {}
	for k, v in pairs(t) do
		table.insert(data, k)
		table.insert(data, v)
	end

	local db = getconn(uid)
	local result = db:hmset(key, table.unpack(data))
	return result
end

function CMD.hmget(uid, key, ...)
	if not key then return end
	local db = getconn(uid)
	local result = db:hmget(key, ...)
	return result
end

function CMD.hset(uid, key, filed, value)
	local db = getconn(uid)
	local result = db:hset(key,filed,value)
	return result
end

function CMD.hget(uid, key, filed)
	local db = getconn(uid)
	local result = db:hget(key, filed)
	return result
end

function CMD.hgetall(uid, key)
	local db = getconn(uid)
	local result = db:hgetall(key)
	return result
end

function CMD.zadd(uid, key, score, member)
	local db = getconn(uid)
	local result = db:zadd(key, score, member)
	return result
end

function CMD.keys(uid, key)
	local db = getconn(uid)
	local result = db:keys(key)
	return result
end

function CMD.zrange(uid, key, from, to)
	local db = getconn(uid)
	local result = db:zrange(key, from, to)
	return result
end

function CMD.zrevrange(uid, key, from, to ,scores)
	local result
	local db = getconn(uid)
	if not scores then
		result = db:zrevrange(key,from,to)
	else
		result = db:zrevrange(key,from,to,scores)
	end
	return result
end

function CMD.zrank(uid, key, member)
	local db = getconn(uid)
	local result = db:zrank(key,member)
	return result
end

function CMD.zrevrank(uid, key, member)
	local db = getconn(uid)
	local result = db:zrevrank(key,member)
	return result
end

function CMD.zscore(uid, key, score)
	local db = getconn(uid)
	local result = db:zscore(key,score)
	return result
end

function CMD.zcount(uid, key, from, to)
	local db = getconn(uid)
	local result = db:zcount(key,from,to)
	return result
end

function CMD.zcard(uid, key)
	local db = getconn(uid)
	local result = db:zcard(key)
	return result
end

function CMD.incr(uid, key)
	local db = getconn(uid)
	local result = db:incr(key)
	return result
end

function CMD.del(uid, key)
	local db = getconn(uid)
	local result = db:del(key)
	return result
end

local function load_player(uid)
	local sql = string.format("call load_player(%d)",uid)
	local ret = skynet.call("mysqld","lua","querygamedb",sql)
    local select = ret[1][1]
    local retcode = select[db_const.retcode]
    if retcode ~= 0 then 
        LOG_ERROR("sql:%s err_msg:%s",sql,error_msg(DB_ERROR.SQL_ERROR))
        return DB_ERROR.SQL_ERROR
    end
	local player = {}
	player.town_name = select[db_const.town_name]
    player.gold = select[db_const.gold]
    player.cash = select[db_const.cash]
    player.topaz = select[db_const.topaz]
    player.emerald = select[db_const.emerald]
    player.ruby = select[db_const.ruby]
    player.amethyst = select[db_const.amethyst]
    player.level = select[db_const.level]
    player.exp = select[db_const.exp]
    player.thumb_up = select[db_const.thumb_up]
    player.avatar_index = select[db_const.avatar_index]

    player.role_attr = select[db_const.role_attr]
    player.item_data = select[db_const.item_data]
    player.grid_data = select[db_const.grid_data]
    player.plant_data = select[db_const.plant_data]
    player.factory_data = select[db_const.factory_data]
    player.feed_data = select[db_const.feed_data]
    player.trains_data = select[db_const.trains_data]
    player.seaport_data = select[db_const.seaport_data]
    player.flight_data = select[db_const.flight_data]
    player.helicopter_data = select[db_const.helicopter_data]
    player.achievement_data = select[db_const.achievement_data]
    player.market_data = select[db_const.market_data]
    player.employment_data = select[db_const.employment_data]
    player.mail_data = select[db_const.mail_data]
	player.friend_data = select[db_const.friend_data]
	player.event_data = select[db_const.event_data]
	player.daily_data = select[db_const.daily_data]

	local account_id = uid
	local town_name = player.town_name
	local level = player.level
	local exp = player.exp
	local avatar_index = player.avatar_index
	skynet.call("recommend","lua","update_player",account_id,town_name,level,exp,avatar_index)
	local db = getconn(uid)
	db:hset("thumb_up", uid, player.thumb_up)
	return player
end

function CMD.get_player(uid)
	local db = getconn(uid)
	local player = db:hget("player", uid)
	if player then return cjson.decode(player) end
	player = load_player(uid)
	db:hset("player",uid,cjson.encode(player))
	return player
end

function CMD.save_player(uid,player)
	local db = getconn(uid)
	db:hset("player",uid, cjson.encode(player))
	local town_name = player.town_name
	local level = player.level
	local exp = player.exp
	local avatar_index = player.avatar_index
	skynet.call("recommend","lua","update_player",uid,town_name,level,exp,avatar_index)
	db:hset("player_dirty",uid,1)
end

function CMD.dump_all()
	local db = getconn()
	local all_data = db:hgetall("player_dirty") or {}
	local players = {}
	for i=1,#all_data,2 do
		local key = all_data[i]
		local val = all_data[i+1]
		players[key] = val
	end
	for account_id,dirty in pairs(players) do
		local player = db:hget("player", account_id)
		local data = cjson.decode(player)
		local town_name = data.town_name
		local gold = data.gold
		local cash = data.cash
		local topaz = data.topaz
		local emerald = data.emerald
		local ruby = data.ruby
		local amethyst = data.amethyst
		local level = data.level
		local exp = data.exp
		local thumb_up = data.thumb_up
		local avatar_index = data.avatar_index

		local role_attr = packer.pack(data.role_attr)
		local item_data = packer.pack(data.item_data)
		local grid_data = packer.pack(data.grid_data)
		local plant_data = packer.pack(data.plant_data)
		local factory_data = packer.pack(data.factory_data)
		local feed_data = packer.pack(data.feed_data)
		local trains_data = packer.pack(data.trains_data)
		local seaport_data = packer.pack(data.seaport_data)
		local flight_data = packer.pack(data.flight_data)
		local helicopter_data = packer.pack(data.helicopter_data)
		local achievement_data = packer.pack(data.achievement_data)
		local market_data = packer.pack(data.market_data)
		local employment_data = packer.pack(data.employment_data)
		local mail_data = packer.pack(data.mail_data)
		local friend_data = packer.pack(data.friend_data)
		local event_data = packer.pack(data.event_data)
		local daily_data = packer.pack(data.daily_data)
		
		local sql = string.format("call save_player(%d,'%s',%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,'%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')",account_id,
		town_name,gold,cash,topaz,emerald,ruby,amethyst,level,exp,thumb_up,avatar_index,
		role_attr,item_data,grid_data,plant_data,factory_data,feed_data,
		trains_data,seaport_data,flight_data,helicopter_data,achievement_data,
		market_data,employment_data,mail_data,friend_data,event_data,daily_data)
		skynet.call("mysqld","lua","querygamedb",sql,true)
	end
	db:del("player_dirty")
end

function CMD.thumb_up(uid)
	local db = getconn(uid)
	local thumb_up = db:hget("thumb_up", uid)
	if not thumb_up then
		load_player(uid)
	end
	db:hincrby("thumb_up",uid,1)
	return db:hget("thumb_up",uid)
end

function CMD.get_thumb_up(uid)
	local db = getconn(uid)
	local thumb_up = db:hget("thumb_up", uid)
	if not thumb_up then
		load_player(uid)
	end
	return db:hget("thumb_up", uid)
end

skynet.start(function()
	start()
	
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)
    skynet.register(SERVICE_NAME)
    --注册一个定时存档定时器
    save_timer = Timer.new()
    save_timer:init()
    save_timer:register(SAVE_INTERAL, function()
        CMD.dump_all()
    end,true)
end)
