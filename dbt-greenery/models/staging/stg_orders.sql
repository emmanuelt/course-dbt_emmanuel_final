/*{{
  config(
    materialized='table'
  )
}}*/
SELECT
    id as order_id, 
    order_id as order_uuid,
    user_id as user_uuid,
    promo_id as promo_name,
    address_id as address_uuid,
    created_at,
    order_cost,
    shipping_cost,
    order_total,
    tracking_id as tracking_uuid,
    shipping_service,
    estimated_delivery_at,
    delivered_at,
    status as order_status
FROM {{ source('greenery_data_sources', 'orders') }}