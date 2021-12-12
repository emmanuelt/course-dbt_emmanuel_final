-- Function to aggregate any dimension per any measure for any model
{% macro count_any_model_dimension_measure(model,dimension,measure) %}

    select {{dimension}},
           count(distinct {{measure}}) as {{measure}}_quantity        
    from {{ ref(model) }}
    group by {{dimension}}

{% endmacro %}