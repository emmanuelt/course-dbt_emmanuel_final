### What is our user repeat rate?
The repeat rate is 80.5%.
```
select
(select count(user_uuid)
 from
 (select user_uuid
  from stg_orders
  group by user_uuid
  having count(distinct order_uuid)>1 
) t1 )::float
 /
 (select count(user_uuid)
  from
 (select user_uuid
  from stg_orders
  group by user_uuid
  having count(distinct order_uuid)>=1 
) t2 )::float
```

### What are good indicators of a user who will likely purchase again? 
- Users who purchased more than once and who visited the website recently.
- Users who visited the website recently and have a high conversion rate (using historical data).
- Potentially users who visited the website recently and who have not purchased yet, in particular users who added items in a cart or went to the checkout page but did not finalize the order (package not shipped).

### What about indicators of users who are likely NOT to purchase again? 
- Users who never purchased (could have visited the website or not).
- Users who purchased once and have not visited the website in the last year.
- Users where the delivery date occured much later than the order date (will be unsatisfied).

### If you had more data, what features would you want to look into to answer this question?
It would be great to implement a post order survey to get customer satisfaction scores following an order.
Ideally we should trigger the survey once the order has been delivered.
We could measure metrics such as CSAT (customer satisfaction), DSAT (customer disatisfaction),and CES (customer effort score).
These metrics should be good indicators to know if each user will purchase again or not.

### Think about what exploratory analysis you would do to approach this question.
- Scatter plots and correlation factor between number of purchases and CSAT/CES scores.
- Table with share of users who purchased several times versus users who purchased only with various metrics to look at (avg CSAT, avg DSAT, avg CES, avg delivery time, share of orders in promo, avg total order).

### Explain the marts models you added. Why did you organize the models in the way you did?
In the **Core folder** I created:
- **dim_users**: I added addresses data to the users data and I also calculated various metrics at user level based on website behaviors and order behaviors.
The goal was to create a big table we can rely on to get all customers dimensions but also some customer behaviors.
- **dim_product**: I simply replicated the same data than in the staging products table but keeping only the product_uuid (not keeping the integer id) and making some minor renaming to bring clarity to end users of the dimension.
- **fact_orders**: I reused a lot of fields from the orders staging table and I calculated revenue & cost metrics for the customers and for Greenery. I also added information from other tables such as the discounted value from a promotion as well as the quantity of distinct product types per order and the quantity of products per order.
The goal was to create a master table with the main data from each order. 

In the **Marketing folder** I created:
- **fact_users_orders**: I built a table at the "user-order" aggregation level. 
I used an intermediate table to do all the main joins (between users, addresses, orders & a previous intermediate table I calculated in the Core folder to get the quantity of distinct product types and the quantity of products for each order). 
In the final fact table (fact_users_oders) I calculated revenue & cost metrics for the customers and for Greenery.
The goal was to create a table containing all the orders of each user, in order to be able to know very easily what are all the orders a given user performed in the past, or to get all the active orders.

In the **Product folder** I created:
- **fact_web_event_types**: I calculated the volume of users, volume of web sessions and volume of web events for each event type.
The goal was to get a quick overview of what are the types of actions being performed on Greenery website, and to size the frequency of occurence of these various events looking at different angles (users, web sessions, events).
- **fact_web_events**: I calculated the volume of web events for each page URL on the Greenery website. 
The goal was to get a quick overview of what are the types of actions being performed on each page of the Greenery website, and to size the frequency of these actions occuring.
I did not use intermediate table for the Product folder on purpose. 

### We added some more models and transformed some data! Now we need to make sure they’re accurately reflecting the data. Add dbt tests into your dbt project on your existing models from Week 1, and new models from the section above.What assumptions are you making about each model? (i.e. why are you adding each test?) <br /> 
- I applied tests in all my staging models and my mart models so at the end more than 130 tests have been passed.
- I used the **not_null** and **unique** Dbt default test macros to ensure uniqueness of the primary keys for the main staging tables.
- I also used the same type of tests for dimension models and fact models whenever applicable.
- For some mart models it was not possible to apply a **unique** test because of the aggregation level (user-order, order-item).
- I also applied tests to make sure the total cost of an order paid by a customer could only be strictly positive.
- I also applied tests to make sure the quantity in stock coud only be positive or equal to zero, but not negative.
- I also applied tests on dates to make sure order dates or user creation dates were relevant (between Jan20 to date).
- Finally I applied tests to make sure some fields only contain digits or only contain letters, using regex.
### Did you find any “bad” data as you added and ran tests on your models?
- Yes I identified one outlier where the total cost of order paid by the customer was negative.
### How did you go about either cleaning the data in the dbt model or adjusting your assumptions/tests? ###
- I kept this outlier in the staging model but removed it from the mart models with orders (fact_oders, fact_user_orders).
### Your stakeholders at Greenery want to understand the state of the data each day. Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through.
- To ensure the tests pass regularly we will have to schedule daily runs of the various models and send the output of the "unpassed" tests and "unfreshed" data sources to stakeholders via email (if there is any unsuccesful run).
- I do not know yet how to orchestrate this within Dbt but I guess we will learn it in the 2 coming weeks.