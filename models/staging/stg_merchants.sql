with source_merchants as (
    select * 
    from {{ source('raw_source', 'merchants') }}
)

select
    merchant_id,
    merchant_category,
    country as merchant_country -- Distingushe country attribute for different entities
from source_merchants
