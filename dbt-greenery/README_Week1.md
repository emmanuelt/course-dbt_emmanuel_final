### How many users do we have?
**There are 130 users.**
```
select count(distinct user_uuid) as nb_of_users from dbt.dbt_emmanuel_t_staging.stg_users;
```
<br />

### On average, how many orders do we receive per hour?
**On average 8.35 orders are received per hour.**
```
select first_order_date, last_order_date,
       extract(epoch from last_order_date-first_order_date)/3600 as Diff_In_Hours,
       orders / (extract(epoch from last_order_date-first_order_date)/3600) as Orders_per_Hour
from (select min(created_at) as first_order_date,max(created_at) as last_order_date,
             count(distinct order_uuid) as orders
      from dbt.dbt_emmanuel_t_staging.stg_orders) t;
```
<br />

### On average, how long does an order take from being placed to being delivered?
**On average it takes 94 hours (almost 4 days) for an order to be delivered.**
```
select avg(Diff_In_Hours) as Avg_Delivery_Time_In_Hours
from (select created_at, delivered_at,
             extract(epoch FROM delivered_at-created_at)/3600 as Diff_In_Hours
      from dbt.dbt_emmanuel_t_staging.stg_orders) t
where Diff_In_Hours is not null;
```
<br />

### How many users have only made one purchase? Two purchases? Three+ purchases?
**25 users have made only 1 purchase. 22 users have made 2 purchases. 81 users have made 3 or more purchases.**
```
select Purchases, count(distinct user_uuid) as Users
from
(select user_uuid, 
        case when count(distinct order_uuid)=0 then '0'
             when count(distinct order_uuid)=1 then '1'
             when count(distinct order_uuid)=2 then '2'
             when count(distinct order_uuid)>=3 then '3+'
        end as Purchases
 from dbt.dbt_emmanuel_t_staging.stg_orders
 group by user_uuid) t
group by Purchases
order by 1;
```
<br />

### On average, how many unique sessions do we have per hour?
**On average, there are 0.11 sessions per hour.**
```
select first_session_date, last_session_date, sessions,
       extract(epoch from last_session_date-first_session_date)/3600 as Diff_In_Hours,
       sessions / (extract(epoch from last_session_date-first_session_date)/3600) as Sessions_per_Hour
from (select min(created_at) as first_session_date,max(created_at) as last_session_date,
             count(distinct session_uuid) as sessions
      from dbt.dbt_emmanuel_t_staging.stg_events) t;
```