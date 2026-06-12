-- models/intermediate/int_payments_enriched.sql

{{
    config(
        materialized='incremental',
        unique_key='payment_id',
        incremental_strategy='merge',
        cluster_by=['payment_hour']
    )
}}

with incremental_payments as (
    select *
    from {{ ref('int_payments') }} -- Pulls from our 15-min incremental base model
    {% if is_incremental() %}
    -- Dynamically looks at only the rows that changed since this model last ran
    where updated_at >= (select max(updated_at) from {{ this }})
    {% endif %}
),

wallet_snapshots as (
    select *
    from {{ ref('snap_wallets') }} -- Pulls from our 15-min KYC snapshot
),

merchants as (
    select 
        merchant_id,
        merchant_category,
        merchant_country
    from {{ ref('stg_merchants') }}
)

select
    p.payment_id,
    p.wallet_id,
    p.amount,
    p.payment_status,
    p.channel,
    p.created_at,
    p.updated_at,
    -- Truncate creation time to the hour for our dashboard grouping
    date_trunc('hour', p.created_at) as payment_hour,
    
    -- Dimensions needed for KPIs
    m.merchant_category,
    m.merchant_country,
    w.kyc_tier

from incremental_payments p
left join merchants m 
    on p.merchant_id = m.merchant_id
left join wallet_snapshots w 
    on p.wallet_id = w.wallet_id
    -- "CHALLENGE A" SOLUTION: Match payment time to the active window of the KYC tier
    -- Check if the payment happened AFTER this tier window started
    and p.created_at >= w.dbt_valid_from
    -- Check if the payment happened BEFORE this tier window closed
    and p.created_at < coalesce(w.dbt_valid_to, '9999-12-31'::timestamp)

