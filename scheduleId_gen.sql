use fortune168_rev1;

drop function if exists gen_schedule_id;
delimiter $

 create function gen_schedule_id()
	returns int
    deterministic
		begin
			declare new_id int;
            select max(SCHEDULE.ScheduleId)+1 into new_id
            from SCHEDULE;
			
            if (new_id = NULL or (new_id > 10000000) )then 
				return 0;
            end if;
            return(new_id);
		end$
        
delimiter ;

