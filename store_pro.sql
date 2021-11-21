use fortune168_rev1;
drop procedure if exists create_customer_user;
delimiter $
create procedure create_customer_user(in userid varchar(50),
									   in car_reg_num varchar(7),
									   in blood_group varchar(2),
									    # user pool
                                       in phone_number varchar(10),
                                       in first_name varchar(30), 
                                       in last_name varchar(30),
									   in birth_date date, 
                                       in address varchar(100),
                                       in username varchar(50), 
                                       in password_hash varchar(1024),
									   out error_code int)
	  begin
			select user_checker(userid,phone_number,username) into error_code;
			if ( error_code <= 0 ) then
				insert into USER values( userid, phone_number, first_name, last_name, birth_date, address, username, password_hash);
				insert into CUSTOMER values( userid, car_reg_num, blood_group);
            end if;
      end$
delimiter ;
############################################################################################      
drop procedure if exists create_provider_user;
delimiter $
create procedure create_provider_user(in userid varchar(50),
									   in work_exp varchar(140),
									    # user pool
                                       in phone_number varchar(10),
                                       in first_name varchar(30), 
                                       in last_name varchar(30),
									   in birth_date date, 
                                       in address varchar(100),
                                       in username varchar(50), 
                                       in password_hash varchar(1024),
									   out error_code int)
	  begin
			select user_checker(userid,phone_number,username) into error_code;
			if ( error_code <= 0 ) then
				insert into USER values( userid, phone_number, first_name, last_name, birth_date, address, username, password_hash);
				insert into PROVIDER values( userid, work_exp);
			end if;
      end$
delimiter ;
#############################################################################################
drop procedure if exists query_customer;
delimiter $
create procedure query_customer(in userid varchar(50) )
	  begin
		select * 
		from CUSTOMER left outer join USER on CUSTOMER.userid = USER.UserId and CUSTOMER.userid =userid;
      #output CarRegNum,  BloodGroup, PhoneNumber, FirstName, LastName, BirthDate, Address,Username,Password
      end$
delimiter ;
#############################################################################################
drop procedure if exists query_provider;
delimiter $
create procedure query_provider(in userid varchar(50) )
	  begin
			select * 
            from PROVIDER left outer join USER on PROVIDER.userid = USER.userid and PROVIDER.userid = userid;
      #output userid,CarRegNum,BloodGroup,PhoneNumber, FirstName, LastName, BirthDate, Address,Username,Password
      end$
delimiter ;      
#############################################################################################
drop procedure if exists query_all_provider;
delimiter $
create procedure query_all_provider()
	  begin
			select * 
            from PROVIDER left outer join USER on PROVIDER.userid = USER.userid;
      #output userid,WorkExp, PhoneNumber, FirstName, LastName, BirthDate, Address,Username,Password
      end$
delimiter ;      
##############################################################################################
drop procedure if exists update_customer;
delimiter $
create procedure update_customer(in userid varchar(50),
								   in car_reg_num varchar(7),
								   in blood_group varchar(2),
									# user pool
								   in phone_number varchar(10),
								   in first_name varchar(30), 
								   in last_name varchar(30),
								   in birth_date date, 
								   in address varchar(100),
								   in username varchar(50), 
								   in password_hash varchar(1024),
                                   out error_code int
                                   )
	  begin
			update CUSTOMER
            set    
				CarRegNum = car_reg_num,
                BloodGroup = blood_group
			where CUSTOMER.Userid = userid;
            
            update USER
            set    
				PhoneNo = phone_number,
                FirstName = first_name,
                LastName = last_name,
                BirthDate = birth_date,
                Address = address,
                Username =  username,
                Password = password_hash
			where USER.Userid = userid;
            set error_code = 0;
      end$
delimiter ;      
##############################################################################################
drop procedure if exists update_provider;
delimiter $
create procedure update_provider(
								   in userid varchar(50),
								   in work_exp varchar(140),
									# user pool
								   in phone_number varchar(10),
								   in first_name varchar(30), 
								   in last_name varchar(30),
								   in birth_date date, 
								   in address varchar(100),
								   in username varchar(50), 
								   in password_hash varchar(1024),
                                   out error_code int
							   )
	  begin
			update PROVIDER
				set    
					WorkExp = work_exp
				where PROVIDER.Userid = userid;
				
			update USER
			set    
				PhoneNo = phone_number,
				FirstName = first_name,
				LastName = last_name,
				BirthDate = birth_date,
				Address = address,
				Username =  username,
				Password = password_hash
			where USER.Userid = userid;
            
			set error_code = 0;
                
      end$
delimiter ;
##############################################################################################
drop procedure if exists make_appointment;
delimiter $
create procedure make_appointment(
								in userid_customer varchar(50),
                                in userid_provider varchar(50),
								in ap_status int,
                                in ap_date datetime,
                                in ap_duration int,
                                in ap_rating_score int,
                                in ap_rating_text varchar(256),
                                out error_code int
								)
	begin
			declare newId int ;
			select gen_schedule_id() into newId;
			insert into SCHEDULE values(newId, ap_status, ap_date, ap_duration, null, null);
            insert into MAKE_SCHEDULE values(newId, userid_provider, userid_customer);
			set error_code = 0;
    end$
delimiter ;    
#################################################################################################
drop procedure if exists delete_appointment;
delimiter $
create procedure delete_appointment(
							in schedule_id int,
                            in userid_customer varchar(50),
							in userid_provider varchar(50)
							)
                            
	begin
		delete from SCHEDULE
		where SCHEDULE.ScheduleId = schedule_id;
        
        delete from MAKE_SCHEDULE
		where MAKE_SCHEDULE.ScheduleId = schedule_id and
			  MAKE_SCHEDULE.ProviderId = userid_provider and
              MAKE_SCHEDULE.CustomerId = userid_customer;
    end$
delimiter ;
##################################################################################################
drop procedure if exists update_appointment;
delimiter $
create procedure update_appointment(
							in schedule_id int,
                            in userid_customer varchar(50),
							in userid_provider varchar(50),
							in ap_status int,
							in ap_date datetime,
							in ap_duration int,
							in ap_rating_score int,
							in ap_rating_text varchar(256),
                            out error_code int
							)
                            
	begin
		update SCHEDULE
        set
			Status = ap_status,
            Date   = ap_date,
            Duration=ap_duration,
            RatingScore=ap_rating_score,
            RatingText=ap_rating_text
		where SCHEDULE.ScheduleId = schedule_id;
        
		set error_code = 0;
			
    end$
delimiter ;    
#################################################################################################
drop procedure if exists query_appointment_customer;
delimiter $
create procedure query_appointment_customer(
							in userid_customer varchar(50)
							)
	begin
			select * 
            from	MAKE_SCHEDULE left outer join SCHEDULE 
			    	on MAKE_SCHEDULE.ScheduleId = SCHEDULE.ScheduleId and MAKE_SCHEDULE.CustomerId =  userid_customer;
			# output SchduleId, ProviderId, CustomerId, Status, Date, Duration, RatingScore, RantingText
    end$
delimiter ;    
#################################################################################################
drop procedure if exists query_appointment_provider;
delimiter $
create procedure query_appointment_provider(
							in userid_provider varchar(50)
							)
			
	begin
		select * 
            from	MAKE_SCHEDULE left outer join SCHEDULE 
			    	on MAKE_SCHEDULE.ScheduleId = SCHEDULE.ScheduleId and MAKE_SCHEDULE.ProviderId =  userid_provider ;
    # output SchduleId, ProviderId, CustomerId, Status, Date, Duration, RatingScore, RantingText
    end$

delimiter ;
