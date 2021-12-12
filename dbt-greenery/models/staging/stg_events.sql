/*{{
  config(
    materialized='table'
  )
}}*/

SELECT 
    id as event_id,
    event_id as event_uuid,
    session_id as session_uuid,
    user_id as user_uuid,
    event_type,
    page_url,
    created_at
FROM {{ source('greenery_data_sources', 'events') }}