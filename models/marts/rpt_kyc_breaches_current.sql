-- models/marts/rpt_kyc_breaches_current.sql

{{
    config(
        materialized='view'
    )
}}

with active_month_spending as (
    select 
        wallet_id,
        current_monthly_spent
    from {{ ref('fct_wallet_monthly_spending') }}
    -- Filter strictly for the current ongoing calendar month
    where calendar_month = date_trunc('month', current_date)
),

current_wallets as (
    select 
        wallet_id,
        user_id,
        kyc_tier,
        kyc_limit
    from {{ ref('snap_wallets') }}
    -- Filter for the absolute current state of the wallet
    where dbt_valid_to is null
)

select
    w.user_id,
    w.wallet_id,
    w.kyc_tier,
    w.kyc_limit,
    s.current_monthly_spent,
    (s.current_monthly_spent - w.kyc_limit) as breach_amount,
    now() as alert_detected_at
from active_month_spending s
inner join current_wallets w 
    on s.wallet_id = w.wallet_id
-- The Alerting Condition: Flag if their monthly accumulation exceeds their current allowance
where s.current_monthly_spent > w.kyc_limit
