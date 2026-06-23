-- tests/assert_no_overlapping_kyc_windows.sql
-- This test checks for timeline overlap anomalies in your wallet snapshot data
select
    t1.wallet_id,
    t1.dbt_valid_from as t1_from,
    t1.dbt_valid_to as t1_to,
    t2.dbt_valid_from as t2_from
from {{ ref('snap_wallets') }} t1
inner join {{ ref('snap_wallets') }} t2 
    -- pairs every historical version of a wallet against every other historical version of that same wallet
    on t1.wallet_id = t2.wallet_id
    -- ensures a row doesn't compare against itself
    and t1.dbt_scd_id != t2.dbt_scd_id
-- searches for any instance where a second record's starting time (t2.dbt_valid_from) begins after 
-- a previous record started, but before that previous record officially closed (t1.dbt_valid_to)
where t2.dbt_valid_from > t1.dbt_valid_from 
  and t2.dbt_valid_from < coalesce(t1.dbt_valid_to, '9999-12-31'::timestamp)
