select 
  event_type,
  count(distinct user_uuid) as users,
  count(distinct session_uuid) as web_sessions,
  count(distinct event_uuid) as web_events
from {{ ref('stg_events') }}
group by 
  event_type