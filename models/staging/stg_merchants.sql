with source_merchants as (
    select * 
    from {{ source('raw_sources', 'merchants') }}
)

select
    merchant_id,
    merchant_category,
    country as merchant_country -- Ensure this alias is present
from source_merchants
