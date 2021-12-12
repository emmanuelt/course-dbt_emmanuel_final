### (1) What is our overall conversion rate?
The overall conversion rate is 36.1%.
```sql
select round(count(distinct case when event_type = 'checkout' then session_uuid end)::numeric
             / count(distinct session_uuid), 3) as conversion_rate
from dbt.dbt_emmanuel_t_staging.stg_events
```
For the calculation I have used the formula suggested by Sourabh on the Slack channel (Conversion rate = number of unique sessions that had checkout / number of unique sessions).\
But I found the web events data really not self-explanatory.
Usually a checkout page is reached when products have been added to the cart and when customers are in the final step of the booking flow. And it is only once they would have finished to fill the details on the checkout page (payment details & delivery details) and after having sent the final validation ("order" click) that the visit would then be converted as an order.
So I would have expected another event after the "checkout" event and before the "package_shipped" event.
I also do not understand how some sessions can have a "delete_from_cart" event without any "add_to_cart" event, why some sessions can have a "add_to_cart" event without previous "page_view", or why "package-shipped" events are standalone events.

### (1) What is our conversion rate by product?
These are the final values I obtained per product, as well as the query I have built to obtain these results.

|   product_name     | web_sessions_checked_out | web_sessions | conversion_rate |
|--------------------|--------------------------|--------------|-----------------|
| Monstera           |                       18 |           28 |          0.6429 |
| Peace Lily         |                       17 |           28 |          0.6071 |
| Orchid             |                       23 |           38 |          0.6053 |
| Majesty Palm       |                       22 |           37 |          0.5946 |
| ZZ Plant           |                       23 |           39 |          0.5897 |
| String of pearls   |                       25 |           43 |          0.5814 |
| Birds Nest Fern    |                       20 |           35 |          0.5714 |
| Dragon Tree        |                       20 |           36 |          0.5556 |
| Bamboo             |                       21 |           38 |          0.5526 |
| Bird of Paradise   |                       19 |           35 |          0.5429 | 
| Pink Anthurium     |                       19 |           35 |          0.5429 |
| Spider Plant       |                       17 |           32 |          0.5313 |
| Cactus             |                       17 |           33 |          0.5152 |
| Arrow Head         |                       20 |           41 |          0.4878 | 
| Calathea Makoyana  |                       16 |           33 |          0.4848 |
| Pilea Peperomioides|                       16 |           33 |          0.4848 |
| Money Tree         |                       14 |           29 |          0.4828 |
| Pothos             |                       12 |           25 |          0.4800 |
| Fiddle Leaf Fig    |                       15 |           32 |          0.4688 |
| Boston Fern        |                       15 |           32 |          0.4688 |
| Philodendron       |                       16 |           35 |          0.4571 |
| Snake Plant        |                       16 |           35 |          0.4571 |
| Angel Wings Begonia|                       14 |           31 |          0.4516 |
| Jade Plant         |                       10 |           24 |          0.4167 |
| Aloe Vera          |                       15 |           38 |          0.3947 |
| Ficus              |                       14 |           37 |          0.3784 |
| Ponytail Palm      |                       11 |           30 |          0.3667 |
| Rubber Plant       |                       13 |           36 |          0.3611 |
| Alocasia Polly     |                       10 |           28 |          0.3571 |
| Devil's Ivy        |                       10 |           31 |          0.3226 |

```sql
--Web sessions with product_x added to cart 
--(and which ended up as checked-out sessions or not checked-out)
with web_sessions_with_product_x_added_to_cart as
(
select 
    e1.session_uuid as web_session_uuid,
    split_part(e1.page_url,'/',5) as product_uuid,
    p.product_name,
    case when e2.session_uuid is not null then 1 else 0 end as web_session_checked_out
from {{ ref('stg_events') }} e1 
join {{ ref('dim_products') }} p
on split_part(e1.page_url,'/',5) = p.product_uuid
left join {{ ref('stg_events') }} e2
on e1.session_uuid = e2.session_uuid
and e2.event_type = 'checkout'
where e1.event_type = 'add_to_cart' 
)

--Conversation rate per product
select product_name,
       count(distinct case when web_session_checked_out=1 then web_session_uuid end) as web_sessions_checked_out,
       count(web_session_uuid) as web_sessions,
       round(count(distinct case when web_session_checked_out=1 then web_session_uuid end)::numeric 
             / count(web_session_uuid),4) as conversion_rate
from web_sessions_with_product_x_added_to_cart
group by product_name
```
For the calculation I have used the logic suggested by Sourabh on the Slack channel and I leveraged the split_part function from the dbt_utils package.

### (2) Create a macro to simplify part of a model.
I have created various macros.
<br />

**Macro 1: Counting event types per web session** \
Looping through the different event types extracted from a sql query.\
I used the "run_query" methodology to get all the distinct event_types from the sql query affected to a set.
```sql 
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
```
I also adapted the same macro with the dbt_utils "get_query_results_as_dic" function, which is giving the same results.

**Macro 2: Counting the occurences of any measure aggregated by any dimension, for any model** \
I therefore defined 3 parameters for this function (model,dimension,measure).\
The function can be applied to any staging model or to any mart model.
```sql 
{% macro count_any_model_dimension_measure(model,dimension,measure) %}

    select {{dimension}},
           count(distinct {{measure}}) as {{measure}}_quantity        
    from {{ ref(model) }}
    group by {{dimension}}

{% endmacro %}
```
**Macro 3: Calculating days between two dates**\
I managed to call the function with "dates entered manually" as arguments or with some sql functions such as now().\
But I do not manage to reference the field of a model within the Jinja used to call the macro.
```sql 
{% macro days_between_2_dates(first_date,last_date) %}
    extract(day from ('{{last_date}}'::timestamp) - ('{{first_date}}'::timestamp))
{% endmacro %}

-- Examples of how the function can be called:
-- days_between_2_dates('2021-01-01','2021-07-31')
-- days_between_2_dates('2021-01-01','now()')

-- What I do not manage to make work:
-- days_between_2_dates('o.created_at','now()')
-- days_between_2_dates('max(o.created_at)','now()')  
```

### (3) Add a post hook to your project to apply grants to the role “reporting”. Create reporting role first by running "CREATE ROLE reporting" in your database instance.
I added the following code in the dbt_project.yml, after having received some help from Jake because I was facing issues on my runs due to my "multiple schemas" setup (main schema in my profile.yml and sub-schemas in my Marts and Staging folders).\
I did not apply a post-hook but an on-run-end.
```yml 
on-run-end:
  - "{% for schema in schemas %}grant usage on schema {{ schema }} to group reporting;{% endfor %}"
  - "{% for schema in schemas %}grant select on all tables in schema {{ schema }} to group reporting;{% endfor %}"
  - "{% for schema in schemas %}alter default privileges in schema {{ schema }} grant select on tables to group reporting;{% endfor %}"
```

### (4) Install a package and apply one or more of the macros to your project.
I have installed the dbt-utils package and used the split_part function of the package to get the product_uuid from a page_url.
I had to install an old version of the package to be compatible to the current version of dbt we are using.
