local gameprocedure = 
[[
DROP PROCEDURE IF EXISTS new_player;
CREATE PROCEDURE new_player(
    in in_account_id bigint
)
label_proc : BEGIN
    declare var_count INT;
    select count(*) into var_count from player where account_id = in_account_id;
    if var_count > 0 then
        select -1, "";
        leave label_proc;
    end if;
    insert into player
    (account_id, town_name)
    values(in_account_id, "township");
    select 0;
END;


DROP procedure if exists load_player;
create procedure load_player(
  in in_account_id bigint
)
  label_proc:begin 
    declare var_count int;
    select count(*) into var_count from player where account_id = in_account_id;
    if var_count <= 0 then 
      select -1,"角色数据不存在";
      leave label_proc;
    end if;
    select 0,town_name,gold,cash,topaz,emerald,ruby,amethyst,level,exp,
    role_attr,item_data,grid_data,plant_data,factory_data,feed_data,
    trains_data,seaport_data,flight_data,helicopter_data,achievement_data,market_data,employment_data
    from player where account_id = in_account_id;
  end;

  drop procedure if exists save_player;
  create procedure save_player(IN in_account_id      bigint, IN in_town_name varchar(20),
                             IN in_gold            bigint, IN in_cash bigint, IN in_topaz bigint, IN in_emerald bigint,
                             IN in_ruby            bigint, IN in_amethyst bigint, IN in_level int, IN in_exp bigint,
                             IN in_role_attr       mediumblob, IN in_item_data mediumblob,
                             IN in_grid_data mediumblob, IN in_plant_data mediumblob,
                             IN in_factory_data     mediumblob, IN in_feed_data mediumblob,
                             IN in_trains_data     mediumblob, IN in_seaport_data mediumblob,
                             IN in_flight_data     mediumblob, IN in_helicopter_data mediumblob,
                             IN in_achievement_data     mediumblob, IN in_market_data mediumblob,
                             IN in_employment_data     mediumblob)
  label_proc:begin
      declare var_count int;
      select count(*) into var_count from player where account_id = in_account_id;
      if var_count <= 0 then
        select -1,"role_data_not_exists";
        leave label_proc;
      end if;
      UPDATE player SET
      town_name       = in_town_name       ,
      gold            = in_gold            ,
      cash            = in_cash            ,
      topaz           = in_topaz           ,
      emerald         = in_emerald         ,
      ruby            = in_ruby            ,
      amethyst        = in_amethyst        ,
      level           = in_level           ,
      exp             = in_exp             ,

      role_attr       = in_role_attr       ,
      item_data       = in_item_data       ,
      grid_data       = in_grid_data       ,
      plant_data      = in_plant_data      ,
      factory_data    = in_factory_data    ,
      feed_data       = in_feed_data       ,
      trains_data     = in_trains_data     ,
      seaport_data    = in_seaport_data    ,
      flight_data     = in_flight_data     ,
      helicopter_data = in_helicopter_data ,
      achievement_data= in_achievement_data,
      market_data     = in_market_data     ,
      employment_data = in_employment_data
      WHERE in_account_id = account_id;
      select 0,"save_data_sucess";
    end;
]]


return gameprocedure