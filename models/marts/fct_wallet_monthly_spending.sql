-- models/marts/fct_wallet_monthly_spending.sql

{{
    config(
        materialized='incremental',
        unique_key='wallet_month_id',
        incremental_strategy='merge'
    )
}}

with enriched_payments as (
    select *
    from {{ ref('int_payments_enriched') }}
    where payment_status = 'success' -- Compliance only counts successfully settled funds
    
    {% if is_incremental() %}
    -- Only look at payments touched in the last 15-30 minutes to find which wallets to update
    and updated_at >= (select max(updated_at) - interval '3 hours' from {{ this }})
    {% endif %}
),

monthly_aggregates as (
    select
        -- Unique key linking the wallet to the specific calendar month
        md5(coalesce(wallet_id, '') || '-' || date_trunc('month', created_at)::text) as wallet_month_id,
        wallet_id,
        date_trunc('month', created_at) as calendar_month,
        sum(amount) as current_monthly_spent,
        max(updated_at) as updated_at
    from enriched_payments
    group by wallet_id, date_trunc('month', created_at)
)

select * from monthly_aggregates
