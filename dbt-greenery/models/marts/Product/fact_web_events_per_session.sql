
select * from ({{aggregate_event_types_per_session()}}) t 

/* Other macro used to get the same results */
/* select * from ({{aggregate_event_types_per_session_v2()}}) t */