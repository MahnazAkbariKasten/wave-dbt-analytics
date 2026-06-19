-- tests/assert_breach_amounts_are_valid.sql
-- This test fails if a breach row indicates an impossible negative or zero-value overage amount
select
    wallet_id,
    breach_amount
from {{ ref('rpt_kyc_breaches_current') }}
where breach_amount <= 0
