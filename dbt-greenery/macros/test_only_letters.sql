{% test only_letters(model,column_name) %}

   select *
   from {{ model }}
   where ({{ column_name }}::text ~* '[0-9]')

{% endtest %}