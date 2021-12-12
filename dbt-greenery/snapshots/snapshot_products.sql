{% snapshot snapshot_products %}

  {{
    config(
      target_schema='snapshots',
      unique_key='product_id',
      strategy='check',
      check_cols=['name','price','quantity']
    )
  }}

  SELECT * FROM {{ source('greenery_data_sources', 'products') }}

{% endsnapshot %}