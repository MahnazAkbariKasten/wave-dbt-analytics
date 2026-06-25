-- models/staging/stg_wallets.sql

with source as (
    select * from {{ source('raw_source', 'wallets') }}
)

select
    wallet_id,
    user_created_at,
    kyc_tier,
    country as wallet_country, -- Disambiguating the country name
    is_agent,
    status as wallet_status,    -- Disambiguating the status name
    updated_at
from source
