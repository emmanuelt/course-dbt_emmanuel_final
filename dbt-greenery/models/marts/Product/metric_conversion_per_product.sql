--Web sessions with product_x added to cart 
--(and which ended up as checked-out sessions or not checked-out)
with web_sessions_with_product_x_added_to_cart as
(
select 
    e1.session_uuid as web_session_uuid,
    split_part(e1.page_url,'/',5) as product_uuid,
    p.product_name,
    case when e2.session_uuid is not null then 1 else 0 end as web_session_checked_out
from {{ ref('stg_events') }} e1 
join {{ ref('dim_products') }} p
on split_part(e1.page_url,'/',5) = p.product_uuid
left join {{ ref('stg_events') }} e2
on e1.session_uuid = e2.session_uuid
and e2.event_type = 'checkout'
where e1.event_type = 'add_to_cart' 
)

--Conversation rate per product
select product_name,
       count(distinct case when web_session_checked_out=1 then web_session_uuid end) as web_sessions_checked_out,
       count(web_session_uuid) as web_sessions,
       round(count(distinct case when web_session_checked_out=1 then web_session_uuid end)::numeric 
             / count(web_session_uuid),4) as conversion_rate
from web_sessions_with_product_x_added_to_cart
group by product_name