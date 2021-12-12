{% snapshot snapshot_orders %}

  {{
    config(
      target_schema='snapshots',
      unique_key='order_id',
      strategy='check',
      check_cols=['discount','status']
    )
  }}

  SELECT * FROM {{ source('greenery_data_sources', 'orders') }}

{% endsnapshot %}