-- snapshots/snap_wallets.sql

-- When you define a file as a snapshot using the "snapshot" block, 
-- dbt automatically injects four metadata columns into the target table 
-- in Snowflake:dbt_scanned_at, dbt_updated_at, dbt_valid_from, dbt_valid_to
{% snapshot snap_wallets %}

{{
    config(
      target_database=env_var('DBT_DATABASE', 'wave'),
      target_schema='snapshots',
      unique_key='wallet_id',
      
      strategy='timestamp',
      updated_at='updated_at'
    )
}}

select
    wallet_id,
    user_id,
    kyc_tier,
    kyc_limit,
    created_at,
    updated_at
from {{ source('raw_sources', 'wallets') }}

{% endsnapshot %}
