-- models/marts/fct_payment_summary_hourly.sql

{{
    config(
        materialized='incremental',
        unique_key='summary_id',
        incremental_strategy='merge'
    )
}}

with enriched_payments as (
    select *
    from {{ ref('int_payments_enriched') }}
    {% if is_incremental() %}
    -- Scan hours affected by recent 15-min updates
    where payment_hour >= (select min(payment_hour) from {{ ref('int_payments_enriched') }} where updated_at >= (select max(updated_at) - interval '3 hours' from {{ this }}))
    {% endif %}
),

aggregated as (
    select
        -- Create a unique key combining the hour and dimensions for the merge strategy
        md5(coalesce(payment_hour::text, '') || '-' || coalesce(merchant_country, '') || '-' || coalesce(payment_status, '') || '-' || coalesce(channel, '') || '-' || coalesce(merchant_category, '') || '-' || coalesce(kyc_tier::text, '')) as summary_id,
        
        payment_hour,
        merchant_country,
        payment_status,
        channel,
        merchant_category,
        kyc_tier,
        
        -- Metric Calculations
        count(payment_id) as total_payments,
        sum(amount) as total_volume,
        
        -- Net Volume (excluding failed and reversed transactions)
        sum(case when payment_status = 'success' then amount else 0 end) as net_volume,
        
        -- Gross Volume (all attempts except strict technical failures)
        sum(case when payment_status != 'failed' then amount else 0 end) as gross_volume,
        
        max(updated_at) as updated_at

    from enriched_payments
    group by 
        payment_hour, 
        merchant_country, 
        payment_status, 
        channel, 
        merchant_category, 
        kyc_tier

)

select * from aggregated
