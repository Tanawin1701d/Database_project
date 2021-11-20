use fortune168_rev1;
drop function if exists user_checker;
delimiter $

 create function user_checker(userid varchar(50),phone_number varchar(10),username varchar(50))
    returns int
	deterministic
        begin
			declare error_code int default(0);
            declare id_check int default(0);
            declare phone_check bool default(0);
            declare username_check int default(0);
			####################################################33
			select count(USER.UserId) into id_check
            from USER
            where USER.UserId = userid;
            
            if (id_check > 0)then
				set error_code = error_code + 1;
                signal sqlstate '45000' set message_text = 'user id error';
			end if;
             ####################################################
             if ( not (phone_number regexp '[0-9]{10}') ) then
 				set error_code =  error_code + 10;
				signal sqlstate '45000' set message_text = 'phone number error';
             end if;
--             ##################################################
             select count(USER.UserName) into username_check
             from USER
             where USER.UserName = username;
             
             if (username_check > 0)then
 				set error_code = error_code + 100;
				signal sqlstate '45000' set message_text = 'username error';
            end if;
--             ####################################################
			return error_code;
		end$
        
delimiter ;