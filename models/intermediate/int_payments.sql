{{
    config(
        materialized='incremental',
        unique_key='payment_id',
        incremental_strategy='delete+insert'
    )
}}

-- Queries the only rows from source tbale (stg_payments) that have been created 
-- after the most recent batch in target table (int_payments).
with raw_payments as (
    select
        payment_id,
        wallet_id,
        merchant_id,
        amount,
        status,
        channel,
        created_at,
        updated_at
    from {{ source('raw_source', 'payments') }}

    {% if is_incremental() %}  -- Checks whether this model already exist in 
                               -- the database
    -- Snowflake interval syntax
    -- This filter ensures we only scan the last 15-30 minutes of data
    -- We look back 3 hours as a safe buffer for any late-arriving data or pipeline delays

    -- The inner SELECT: This tells Snowflake to look at the destination table right before
    -- the 15-minute run starts, find the single newest updated_at timestamp currently stored, 
    -- and return it.

    -- - interval '3 hours': This is standard Snowflake date math. It takes that maximum 
    -- timestamp and subtracts exactly 3 hours from it to create a rolling cut-off time.
    -- It only loads the tiny handful of boxes containing files touched or created within 
    -- that active 3-hour buffer window.
    -- From those few isolated micro-partitions, Snowflake extracts the small batch of rows 
    -- that arrived or changed in the last 15 minutes.
    where updated_at >= (select max(updated_at) - interval '3 hours' from {{ this }})
    {% endif %}

)

select
    payment_id,
    wallet_id,
    merchant_id,
    amount,
    status as payment_status,
    channel,
    created_at,
    updated_at
from raw_payments