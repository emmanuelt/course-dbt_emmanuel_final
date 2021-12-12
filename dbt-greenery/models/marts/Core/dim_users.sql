select
  u.user_uuid,
  u.first_name as user_first_name,
  u.last_name as user_last_name,
  u.email as user_email,
  u.phone_number as user_phone_number,
  u.created_at as user_creation_date,
  u.updated_at as user_last_update_date,
  a.address as user_address,
  a.zipcode as user_zipcode,
  a.state as user_state,
  a.country as user_country,
  min(e.created_at) as user_first_web_activity_date,
  max(e.created_at) as user_last_web_activity_date,
  extract(day from now()-max(e.created_at)) as user_days_since_last_web_activity,
  count(distinct e.session_uuid) as user_web_sessions_count,
  min(o.created_at) as user_first_order_date,
  max(o.created_at) as user_last_order_date,
  extract(day from now()-max(o.created_at)) as user_days_since_last_order,
  count(distinct o.order_uuid) as user_orders_count
from {{ ref('stg_users') }} u
left join {{ ref('stg_addresses') }} a
on u.address_uuid=a.address_uuid
left join {{ ref('stg_events') }} e
on u.user_uuid=e.user_uuid
left join {{ ref('stg_orders') }} o
on u.user_uuid=o.user_uuid
group by 
  u.user_uuid,
  u.first_name,
  u.last_name,
  u.email,
  u.phone_number,
  u.created_at,
  u.updated_at,
  u.address_uuid,
  a.address,
  a.zipcode,
  a.state,
  a.country