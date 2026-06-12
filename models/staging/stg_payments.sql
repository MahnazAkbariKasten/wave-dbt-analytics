with source_payments as (
    select * 
    from {{ source('raw_sources', 'payments') }}
)

select
    payment_id,
    wallet_id,
    merchant_id,
    amount,
    -- Added back for multi-currency handling and geographic tracking
    currency,
    country as payment_country, 
    status as payment_status, 
    channel,
    created_at,
    updated_at
from source_payments
