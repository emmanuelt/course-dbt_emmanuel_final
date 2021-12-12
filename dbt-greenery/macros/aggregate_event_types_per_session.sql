{% macro aggregate_event_types_per_session() %}

{% set event_types_query %}
select distinct event_type from {{ref('stg_events')}}
{% endset %}

{% set event_types = run_query(event_types_query) %}

{% if execute %}
    {% set event_types_list = event_types.columns[0].values() %}
{% else %}
    {% set event_types_list = [] %}
{% endif %}

select
    session_uuid
    {% for event_type_value in event_types_list %}
    ,count(distinct (case when event_type='{{event_type_value}}' then event_uuid end)) as "{{event_type_value}}_count"
    {% endfor %}
    ,count(distinct event_uuid) as total_count
from {{ref('stg_events')}} 
group by 
    session_uuid

{% endmacro %}