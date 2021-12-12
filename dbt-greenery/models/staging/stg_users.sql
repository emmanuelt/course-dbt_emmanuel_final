/*{{
  config(
    materialized='table'
  )
}}*/

SELECT 
    id as user_id,
    user_id as user_uuid,
    first_name,
    last_name,
    email,
    phone_number,
    created_at,
    updated_at,
    address_id as address_uuid
FROM {{ source('greenery_data_sources', 'users') }}