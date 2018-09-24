--账号数据库表定义
local gamedb = [[
create table IF NOT EXISTS player
(
    account_id      bigint not null,                                      #账号ID
    town_name       varchar(20),                                          #小镇名称
    gold            bigint default 0,                                     #金币
    cash            bigint default 0,                                     #现金
    topaz           bigint default 0,                                     #黄玉
    emerald         bigint default 0,                                     #祖母绿
    ruby            bigint default 0,                                     #红宝石
    amethyst        bigint default 0,                                     #紫水晶
    level           int default 1,                                        #等级
    exp             bigint default 0,                                     #经验

    role_attr           mediumblob,                                       #角色数据
    item_data           mediumblob,                                       #物品数据
    grid_data           mediumblob,                                       #建筑数据
    plant_data          mediumblob,                                       #种植数据
    factory_data        mediumblob,                                       #工厂数据
    feed_data           mediumblob,                                       #养殖数据
    trains_data         mediumblob,                                       #火车数据
    seaport_data        mediumblob,                                       #海港数据
    flight_data         mediumblob,                                       #航班订单
    helicopter_data     mediumblob,                                       #直升机订单
    achievement_data    mediumblob,                                       #成就数据
    market_data         mediumblob,                                       #市场数据
    employment_data     mediumblob,                                       #雇佣数据

	primary key(account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
]]

return gamedb