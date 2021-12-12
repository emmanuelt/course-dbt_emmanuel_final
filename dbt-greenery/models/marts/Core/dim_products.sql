select 
  product_uuid,
  name as product_name,
  price as product_price,
  quantity_in_stock as product_quantity_in_stock
from {{ ref('stg_products') }}