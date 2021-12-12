{% snapshot snapshot_order_items %}

  {{
    config(
      target_schema='snapshots',
      unique_key='order_id',
      strategy='check',
      check_cols=['product_id','quantity']
    )
  }}

  SELECT * FROM {{ source('greenery_data_sources', 'order_items') }}

{% endsnapshot %}