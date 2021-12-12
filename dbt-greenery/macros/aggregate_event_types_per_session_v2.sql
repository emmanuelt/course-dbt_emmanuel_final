{% macro aggregate_event_types_per_session_v2() %}

{% set event_types = 
   dbt_utils.get_query_results_as_dict("select distinct event_type from" ~ ref('stg_events')) %}

select
    session_uuid
    {% for event_type_value in event_types['event_type'] %}
    ,count(distinct (case when event_type='{{event_type_value}}' then event_uuid end)) as "{{event_type_value}}_count"
    {% endfor %}
    ,count(distinct event_uuid) as total_count
from {{ref('stg_events')}} 
group by 
    session_uuid

{% endmacro %}