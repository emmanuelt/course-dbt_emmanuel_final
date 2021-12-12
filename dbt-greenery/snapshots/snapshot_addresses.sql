{% snapshot snapshot_addresses %}

  {{
    config(
      target_schema='snapshots',
      unique_key='address_id',
      strategy='check',
      check_cols=['address','zipcode','state','country']
    )
  }}

  SELECT * FROM {{ source('greenery_data_sources', 'addresses') }}

{% endsnapshot %}