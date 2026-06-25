-- models/staging/stg_merchants.sql

with source as (
    select * from {{ source('raw_source', 'merchants') }}
)

select
    merchant_id,
    merchant_name,
    category as merchant_category,
    country as merchant_country,  -- Contextual disambiguation rename
    status as merchant_status,    -- Contextual disambiguation rename
    created_at,
    updated_at
from source
