{% snapshot snapshot_promos %}

  {{
    config(
      target_schema='snapshots',
      unique_key='promo_id',
      strategy='check',
      check_cols=['discount','status']
    )
  }}

  SELECT * FROM {{ source('greenery_data_sources', 'promos') }}

{% endsnapshot %}