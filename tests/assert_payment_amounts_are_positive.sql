-- This test fails if it finds any transaction amounts less than 0
select
    payment_id,
    amount
from {{ ref('stg_payments') }}
where amount < 0
