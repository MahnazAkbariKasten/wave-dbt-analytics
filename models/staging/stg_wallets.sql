with source as (
    select * from {{ source('raw_source', 'wallets') }}
)

select
    wallet_id,
    user_id,
    kyc_tier,
    country as wallet_country, -- Disambiguating the country column!
    status as wallet_status,   -- Disambiguating the statuse column!
    created_at
from source
