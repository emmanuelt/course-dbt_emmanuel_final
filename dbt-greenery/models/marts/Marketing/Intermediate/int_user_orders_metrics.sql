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
  o.order_uuid,
  o.created_at as order_date,
  oi.order_product_types,
  oi.order_quantity_of_products,
  o.order_cost,
  o.shipping_cost as order_shipping_cost,
  o.order_total,
  o.tracking_uuid as order_tracking_id,
  o.shipping_service as order_shipping_service,
  o.estimated_delivery_at as order_expected_delivery_date,
  o.delivered_at as order_delivery_date,
  o.order_status   
from {{ ref('stg_users') }} u
left join {{ ref('stg_addresses') }} a
on u.address_uuid=a.address_uuid
left join {{ ref('stg_orders') }} o
on u.user_uuid=o.user_uuid
left join {{ ref('int_order_items_metrics') }} oi
on o.order_uuid=oi.order_uuid
where o.order_total>0  --Exclusion of 1 outlier
group by
  u.user_uuid,
  u.first_name,
  u.last_name,
  u.email,
  u.phone_number,
  u.created_at,
  u.updated_at,
  a.address,
  a.zipcode,
  a.state,
  a.country,
  o.order_uuid,
  o.created_at,
  oi.order_product_types,
  oi.order_quantity_of_products,
  o.order_cost,
  o.shipping_cost,
  o.order_total,
  o.tracking_uuid,
  o.shipping_service,
  o.estimated_delivery_at,
  o.delivered_at,
  o.order_status 