select p_side.Userid      as forteller,
	   c_side.Userid      as customer, 
	   inter_side.d_inter as hour
from ( 
		select *
		from CUSTOMER left outer join USER on CUSTOMER.userid = USER.UserId
	 ) as c_side, 
     (
			select MAKE_SCHEDULE.ProviderId as pid_inter,
				   MAKE_SCHEDULE.CustomerId as cid_inter,
				   sum(SCHEDULE.Duration)   as d_inter
			from   MAKE_SCHEDULE left outer join SCHEDURE on MAKE_SCHEDURE.ScheduleId = SCHEDURE.ScheduleId
			group by pid_inter, cid_inter
			having (pid_inter, d_inter) in (
											select dsep.pid as pid_compress, max(dsep.d) as dmax
											from(
												 select MAKE_SCHEDURE.ProviderId as pid,
														MAKE_SCHEDURE.CustomerId as cid,
													    sum(SCHEDURE.Duration) as d
												 from   MAKE_SCHEDURE left outer join SCHEDURE on MAKE_SCHEDURE.ScheduleId = SCHEDURE.ScheduleId
												 group by pid, cid
												)  as dsep
											group by pid_compress
                                          )
	 ) as inter_side,
     (
		select *
        from PROVIDER left outer join USER on PROVIDER.userid = USER.UserId
     ) as p_side
 where p_side.Userid = inter_side.pid_inter and c_side.Userid = inter_side.cid_inter
