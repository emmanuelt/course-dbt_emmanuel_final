/*{{
  config(
    materialized='table'
  )
}}*/

SELECT 
    id as address_id,
    address_id as address_uuid,
    address,
    zipcode,
    state,
    country
FROM {{ source('greenery_data_sources', 'addresses') }}