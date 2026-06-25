-- models/staging/stg_payments.sql

with source_payments as (
    select * 
    from {{ source('raw_source', 'payments') }}
)

select
    payment_id,
    wallet_id,
    merchant_id,
    amount,
    currency,
    country as payment_country, 
    status as payment_status, 
    channel,
    created_at,
    updated_at
from source_payments
