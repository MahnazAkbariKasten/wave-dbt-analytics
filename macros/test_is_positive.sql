{% test is_positive(model, column_name) %}

-- This macro returns rows where the target column is less than 0.
-- If any rows are found, the test fails.
select
    {{ column_name }} as failing_value
from {{ model }}
where {{ column_name }} < 0

{% endtest %}
