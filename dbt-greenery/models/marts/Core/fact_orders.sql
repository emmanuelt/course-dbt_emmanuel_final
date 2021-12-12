select
  o.order_uuid,
  o.user_uuid,
  o.created_at as order_date,
  a.address||', '||a.zipcode||', '||a.state||', '||a.country as order_delivery_address,
  o.order_status,
  o.estimated_delivery_at as order_expected_delivery_date,
  o.tracking_uuid as order_tracking_uuid,
  o.shipping_service as order_shipping_service,
  o.delivered_at as order_delivery_date,
  extract(day from o.delivered_at-o.created_at) as orders_days_to_deliver,
  o.order_total as order_total_cost_paid_by_client,
  o.order_total-o.shipping_cost as order_product_cost_paid_by_client,
  o.shipping_cost as order_shippping_cost_paid_by_client,
  o.order_total-o.shipping_cost as order_greenery_revenue,
  o.order_cost as order_greenery_cost,
  o.order_total-o.shipping_cost-o.order_cost as order_greenery_margin,
  o.promo_name as order_promo_name,
  pr.discount as order_promo_discount,
  oi.order_product_types,
  oi.order_quantity_of_products
from {{ ref('stg_orders') }} o
left join {{ ref('stg_users') }} u
on o.user_uuid = u.user_uuid
left join {{ ref('stg_addresses') }} a
on o.address_uuid = a.address_uuid
left join {{ ref('stg_promos') }} pr
on o.promo_name=pr.promo_name
left join {{ ref('int_order_items_metrics') }} oi
on o.order_uuid=oi.order_uuid
where order_total>0  --Exclusion of 1 outlier
group by 
  o.order_uuid,
  o.user_uuid,
  o.created_at,
  a.address||', '||a.zipcode||', '||a.state||', '||a.country,
  o.order_status,
  o.estimated_delivery_at,
  o.tracking_uuid,
  o.shipping_service,
  o.delivered_at,
  extract(day from o.delivered_at-o.created_at),
  o.order_total,
  o.order_total-o.shipping_cost,
  o.shipping_cost,
  o.order_total-o.shipping_cost,
  o.order_cost,
  o.order_total-o.shipping_cost-o.order_cost,
  o.promo_name,
  pr.discount,
  oi.order_product_types,
  oi.order_quantity_of_products