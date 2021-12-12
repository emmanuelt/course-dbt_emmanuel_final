
select
  case when page_url like 'https://greenary.com/product%' then 'https://greenary.com/product' 
       else page_url 
  end as web_url,
  count(distinct event_uuid) as events,
  count(distinct case when event_type = 'page_view' then event_uuid else null end) as page_view_events,
  count(distinct case when event_type = 'add_to_cart' then event_uuid else null end) as add_to_cart_events,
  count(distinct case when event_type = 'delete_from_cart' then event_uuid else null end) as delete_from_cart_events,
  count(distinct case when event_type = 'checkout' then event_uuid else null end) as checkout_events,
  count(distinct case when event_type = 'package_shipped' then event_uuid else null end) as package_shipped_events
from {{ ref('stg_events') }}
group by 1