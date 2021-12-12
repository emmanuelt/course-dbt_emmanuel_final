{% test valid_date(model,column_name) %}

   select *
   from {{ model }}
   where ({{ column_name }} < '2020-01-01')
   or ({{ column_name }} > now())

{% endtest %}