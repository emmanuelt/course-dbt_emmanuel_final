/*{{
  config(
    materialized='table'
  )
}}*/

SELECT 
    id as promo_id,
    promo_id as promo_name,
    discout as discount,
    status as promo_status
FROM {{ source('greenery_data_sources', 'promos') }}