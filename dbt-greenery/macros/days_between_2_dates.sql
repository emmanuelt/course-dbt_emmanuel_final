-- Function to calculate the difference in days between 2 dates.
{% macro days_between_2_dates(first_date,last_date) %}
    extract(day from ('{{last_date}}'::timestamp) - ('{{first_date}}'::timestamp))
{% endmacro %}

-- Examples of how the function can be called:
-- days_between_2_dates('2021-01-01','2021-07-31')
-- days_between_2_dates('2021-01-01','now()')

--What I do not manage to make work:
-- days_between_2_dates('o.created_at','now()')
-- days_between_2_dates('max(o.created_at)','now()')
--> Struggling to reference to an existing field from the query embedding the Jinja function,
--  and stuggling to reference to an aggregated field from the query embedding the Jinja function.  
--  The query embedding the Jinja function is joining several sources (several ref used).                                               

