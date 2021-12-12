select
  order_uuid,
  count(distinct product_uuid) as order_product_types,
  sum(quantity_ordered) as order_quantity_of_products
from {{ ref('stg_order_items') }}
group by order_uuid