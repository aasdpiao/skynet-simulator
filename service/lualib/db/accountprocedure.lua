local accountprocedure = 
[[
DROP PROCEDURE IF EXISTS register_new_account;
CREATE PROCEDURE register_new_account(
	in in_user_name varchar(32), 
	in in_password varchar(32),
	in in_server_name varchar(32)
)
label_proc : BEGIN
    declare var_count int;
	declare var_user_name varchar(32);
	declare var_AccountID bigint;

	set var_user_name = trim(in_user_name);
	select count(*) into var_count from account where Username = in_user_name;
	if var_count > 0 then
		select 101, 0;
		leave label_proc;
	end if;

	insert into account
	(Username, Password,ServerName)
	values(var_user_name, in_password,in_server_name);

	select AccountID into var_AccountID from account where Username = in_user_name;
	
	select 100,var_AccountID;
END;

DROP PROCEDURE IF EXISTS check_account_and_password;
CREATE PROCEDURE check_account_and_password(
	in in_user_name VARCHAR(32), 
	in in_password VARCHAR(32)
)
label_proc : BEGIN
		declare var_accountID VARCHAR(32);
		select AccountID into var_accountID from account where Username = in_user_name
		and Password = in_password;

		if ISNULL(var_accountID) then
			select 201,0;
		else
			select 200, var_accountID;
		end if;
END
]]

return accountprocedure