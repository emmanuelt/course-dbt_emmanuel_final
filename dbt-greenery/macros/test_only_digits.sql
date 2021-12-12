{% test only_digits(model,column_name) %}

   select *
   from {{ model }}
   where ({{ column_name }}::text ~* '[a-z]')

{% endtest %}