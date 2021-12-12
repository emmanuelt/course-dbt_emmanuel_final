{% snapshot snapshot_users %}

  {{
    config(
      target_schema='snapshots',
      unique_key='user_id',
      strategy='timestamp',
      updated_at='updated_at'
    )
  }}

  SELECT * FROM {{ source('greenery_data_sources', 'users') }}

{% endsnapshot %}