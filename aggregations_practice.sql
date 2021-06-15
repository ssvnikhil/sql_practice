"""
Aggregation Questions:

1. Find the total amount of poster_qty paper ordered in the orders table.
"""
select sum(poster_qty) as Total_poster_quantity
from orders;

"""
2. Find the total amount of standard_qty paper ordered in the orders table.
"""
select sum(standard_qty) as Total_standard_quantity
from orders;


"""
3. Find the total dollar amount of sales using the total_amt_usd in the orders table.
"""
select sum(total_amt_usd) as Total_amount
from orders;

"""
4. Find the total amount spent on standard_amt_usd and gloss_amt_usd paper for each order in the orders table.
This should give a dollar amount for each order in the table.
"""
select (standard_amt_usd + gloss_amt_usd) as Total_standard_gloss
from orders;

"""
5. Find the standard_amt_usd per unit of standard_qty paper.
Your solution should use both an aggregation and a mathematical operator.
"""
select sum(standard_amt_usd) / sum(standard_qty) as standard_units
from orders;

"""
6. When was the earliest order ever placed? You only need to return the date.
"""
select min(occurred_at)
from orders;

"""
Try performing the same query as in question 1 without using an aggregation function.
"""
select occurred_at
from orders
order by occurred_at
limit 1;

"""
7. When did the most recent (latest) web_event occur?
"""
select max(occurred_at) as most_recent
from web_events;

"""
Try to perform the result of the previous query without using an aggregation function.
"""
select occurred_at
from web_events
order by occurred_at desc
limit 1;

"""
8. Find the mean (AVERAGE) amount spent per order on each paper type, as well as
the mean amount of each paper type purchased per order.
Your final answer should have 6 values - one for each paper type for the average number of sales,
as well as the average amount.
"""
select avg(standard_qty) as avg_std_qty, avg(gloss_qty) as avg_gloss_qty, avg(poster_qty) as avg_poster_qty,
       avg(standard_amt_usd) as avg_std_amt, avg(gloss_amt_usd) as avg_gloss_amt, avg(poster_amt_usd) as avg_poster_amt
from orders;


"""
Via the video, you might be interested in how to calculate the MEDIAN.
Though this is more advanced than what we have covered so far try finding -
what is the MEDIAN total_usd spent on all orders?
"""
SET @rowindex := -1;

SELECT
   AVG(total_amt_usd) as Median
FROM
   (SELECT @rowindex:=@rowindex + 1 AS rowindex,
           orders.total_amt_usd AS distance
    FROM orders
    ORDER BY orders.total_amt_usd) AS o
WHERE o.rowindex IN (FLOOR(@rowindex / 2), CEIL(@rowindex / 2));


"""
9. Which account (by name) placed the earliest order?
Your solution should have the account name and the date of the order.
"""
SELECT a.name, min(occurred_at) as earliest_order
FROM accounts a
join orders o
on a.id = o.account_id
group by a.name
order by 2
limit 1;

"""
10. Find the total sales in usd for each account.
You should include two columns - the total sales for each company's orders in usd and the company name.
"""
select a.name, sum(total_amt_usd) as Total_sales
from accounts a
join orders o
on a.id = o.account_id
group by a.name;

"""
11. Via what channel did the most recent (latest) web_event occur,
which account was associated with this web_event?
Your query should return only three values - the date, channel, and account name.
"""
select a.name, w.channel, max(w.occurred_at) as most_recent
from accounts a
join web_events w
on a.id = w.account_id
group by 1, 2
order by 3 desc
limit 1;

"""
12. Find the total number of times each type of channel from the web_events was used.
Your final table should have two columns - the channel and the number of times the channel was used.
"""
select channel, count(*) as frequency
from web_events
group by 1;


"""
13. Who was the primary contact associated with the earliest web_event?
"""
select a.primary_poc, min(w.occurred_at) as earliest_event
from accounts a
join web_events w
on a.id = w.account_id
group by 1
order by 2
limit 1;

"""
14. What was the smallest order placed by each account in terms of total usd.
Provide only two columns - the account name and the total usd.
Order from smallest dollar amounts to largest.
"""
select a.name, min(o.total_amt_usd) as smallest_amt_order
from accounts a
join orders o
on a.id = o.account_id
group by 1
order by 2;


"""
15. Find the number of sales reps in each region.
Your final table should have two columns - the region and the number of sales_reps.
Order from fewest reps to most reps.
"""
select r.name, count(*) as frequency
from region r
join sales_reps s
on r.id = s.region_id
group by 1
order by 2;

"""
16. For each account, determine the average amount of each type of paper they purchased across their orders.
Your result should have four columns - one for the account name and one for the average quantity purchased
for each of the paper types for each account.
"""
SELECT a.name, avg(o.standard_qty) as mean_std, avg(o.gloss_qty) as mean_gloss, avg(o.poster_qty) as mean_poster
FROM accounts a
join orders o
on a.id = o.account_id
group by 1;


"""
17. For each account, determine the average amount spent per order on each paper type.
Your result should have four columns - one for the account name and one for the average amount spent on each paper type.
"""
SELECT a.name, avg(o.standard_amt_usd) as mean_std_amt, avg(o.gloss_amt_usd) as mean_gloss_amt, avg(o.poster_amt_usd) as mean_poster_amt
FROM accounts a
join orders o
on a.id = o.account_id
group by 1;


"""
18. Determine the number of times a particular channel was used in the web_events table for each sales rep.
Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences.
Order your table with the highest number of occurrences first.
"""
SELECT s.name as sales_rep, w.channel, count(*) as frequency
FROM sales_reps s
join accounts a
on s.id = a.sales_rep_id
join web_events w
on a.id = w.account_id
group by 1, 2
order by 3 desc;

"""
19. Determine the number of times a particular channel was used in the web_events table for each region.
Your final table should have three columns - the region name, the channel, and the number of occurrences.
Order your table with the highest number of occurrences first.
"""
SELECT r.name as region_name, w.channel, count(*) as frequency
from region r
join sales_reps s
on r.id = s.region_id
join accounts a
on s.id = a.sales_rep_id
join web_events w
on a.id = w.account_id
group by 1, 2
order by 3 desc;

"""
20. Use DISTINCT to test if there are any accounts associated with more than one region.
"""
SELECT DISTINCT a.id, r.name as region_name
FROM accounts a
join sales_reps s
on a.sales_rep_id = s.id
join region r
on s.region_id = r.id
order by a.id;


"""
21. Have any sales reps worked on more than one account?
"""
SELECT s.name as sales_rep, count(*) as frequency
FROM accounts a
join sales_reps s
on a.sales_rep_id = s.id
group by s.name
having count(*) > 1
order by 2 desc;

"""
22. How many of the sales reps have more than 5 accounts that they manage?
"""
select sales_rep_id, count(id)
from accounts
group by 1
having count(id) > 5
order by 2 asc;

"""
23. How many accounts have more than 20 orders?
"""
SELECT account_id, count(id)
from orders
group by 1
having count(id) > 20
order by 2 asc;

"""
24. Which account has the most orders?
"""
select account_id, count(id)
from orders
group by 1
order by 2 desc
limit 1;

"""
25. Which accounts spent more than 30,000 usd total across all orders?
"""
SELECT account_id, sum(total_amt_usd) as Total_amount
FROM orders
group by 1
having sum(total_amt_usd) > 30000
order by 2 desc;


"""
26. Which accounts spent less than 1,000 usd total across all orders?
"""
SELECT account_id, sum(total_amt_usd) as Total_amount
FROM orders
group by 1
having sum(total_amt_usd) < 1000
order by 2 asc;

"""
27. Which account has spent the most with us?
"""
SELECT account_id, sum(total_amt_usd) as Total_amount
FROM orders
group by 1
order by 2 desc
limit 1;


"""
28. Which account has spent the least with us?
"""
SELECT account_id, sum(total_amt_usd) as Total_amount
FROM orders
group by 1
order by 2 asc
limit 1;


"""
29. Which accounts used facebook as a channel to contact customers more than 6 times?
"""
select a.id, count(w.channel) as num_events
from accounts a
join web_events w
on a.id = w.account_id
where w.channel = 'facebook'
group by 1
having count(w.channel) > 6;

"""
30. Which account used facebook most as a channel?
"""
select a.id, count(w.channel) as num_events
from accounts a
join web_events w
on a.id = w.account_id
where w.channel = 'facebook'
group by 1
order by 2 desc
limit 1;

"""
31. Which channel was most frequently used by most accounts?
"""
select a.id, w.channel, count(w.channel) as most_frequent
from accounts a
join web_events w
on a.id = w.account_id
group by 1, 2
order by 3 desc
limit 10;

"""
32.Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least.
Do you notice any trends in the yearly sales totals?
"""
select date_part('year', occurred_at) as Year, sum(total_amt_usd) as Total_amt
FROM orders
group by 1
order by 2 desc;

"""
Observation to the above result: When we look at the yearly totals, you might notice that 2013 and 2017 have much smaller totals than all other years.
If we look further at the monthly data, we see that for 2013 and 2017 there is only one month of sales for each of
these years (12 for 2013 and 1 for 2017). Therefore, neither of these are evenly represented.
Sales have been increasing year over year, with 2016 being the largest sales to date.
At this rate, we might expect 2017 to have the largest sales.
"""


"""
33. Which month did Parch & Posey have the greatest sales in terms of total dollars?
Are all months evenly represented by the dataset?
"""
select date_part('month', occurred_at) as Month, sum(total_amt_usd) as Total_amt
FROM orders
where occurred_at between '2014-01-01' and '2016-12-31'
group by 1
order by 2 desc;

"""
34. Which year did Parch & Posey have the greatest sales in terms of total number of orders?
Are all years evenly represented by the dataset?
"""
select date_part('year', occurred_at) as Year, count(*) as Total_orders
FROM orders
group by 1
order by 2 desc;

"""
35. Which month did Parch & Posey have the greatest sales in terms of total number of orders?
Are all months evenly represented by the dataset?
"""
select date_part('month', occurred_at) as Month, count(*) as Total_orders
FROM orders
where occurred_at between '2014-01-01' and '2016-12-31'
group by 1
order by 2 desc;

"""
36. In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
"""
select date_part('month', occurred_at) as Month,
	     date_part('year', occurred_at) as Year,
       sum(gloss_amt_usd) as Gloss_amt
FROM orders o
join accounts a
on a.id = o.account_id
where a.name = 'Walmart'
group by 1, 2
order by 3 desc;

"""
37. Write a query to display for each order, the account ID, total amount of the order,
and the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000.
"""
select account_id, total_amt_usd, case when total_amt_usd >= 3000 then 'Large'
							                         ELSE 'Small'
                                       end as Level_of_order
FROM orders;


"""
38. Write a query to display the number of orders in each of three categories, based on the total number of items in each order.
The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
"""
select case when total >= 2000 then 'At Least 2000'
            when total >= 1000 and total < 2000 then 'Between 1000 and 2000'
            when total < 1000 then 'Less than 1000'
          end as no_of_orders, count(*) as order_count
from orders
group by 1;

"""
39. We would like to understand 3 different levels of customers based on the amount associated with their purchases.
The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd.
The second level is between 200,000 and 100,000 usd.
The lowest level is anyone under 100,000 usd.
Provide a table that includes the level associated with each account.
You should provide the account name, the total sales of all orders for the customer,
and the level. Order with the top spending customers listed first.
"""
SELECT a.name as account_name, sum(total_amt_usd) as Total_amt,
      case when sum(total_amt_usd) > 200000 then 'Top Level'
           when sum(total_amt_usd) between 100000 and 200000 then 'Second Level'
           when sum(total_amt_usd) < 100000 then 'Lowest Level'
      end as Level
from accounts a
join orders o
on a.id = o.account_id
group by 1
order by 2 desc;


"""
40. We would now like to perform a similar calculation to the first,
but we want to obtain the total amount spent by customers only in 2016 and 2017.
Keep the same levels as in the previous question. Order with the top spending customers listed first.
"""
select a.name, sum(total_amt_usd) as Total_amt,
              case when sum(total_amt_usd) > 200000 then 'Top Level'
                   when sum(total_amt_usd) between 100000 and 200000 then 'Second Level'
                   when sum(total_amt_usd) < 100000 then 'Lowest Level'
              end as Level
from accounts a
join orders o
on a.id = o.account_id
where date_part('year', occurred_at) in (2016, 2017)
group by 1
order by 2 desc;

"""
41. We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders.
Create a table with the sales rep name, the total number of orders, and a column with top or not depending on
if they have more than 200 orders. Place the top sales people first in your final table.
"""
select s.name as sales_rep, count(o.id) as no_of_orders,
      case when count(o.id) > 200 then 'Top'
      else 'Not' end as sales_rep_level
from sales_reps s
join accounts a
on s.id = a.sales_rep_id
join orders o
on a.id = o.account_id
group by 1
order by 2 desc;

"""
42. The previous didn't account for the middle, nor the dollar amount associated with the sales.
Management decides they want to see these characteristics represented as well.
We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders
or more than 750000 in total sales.
The middle group has any rep with more than 150 orders or 500000 in sales.
Create a table with the sales rep name, the total number of orders, total sales across all orders,
and a column with top, middle, or low depending on this criteria.
Place the top sales people based on dollar amount of sales first in your final table.
You might see a few upset sales people by this criteria!
"""
select s.name as sales_rep, count(o.id) as no_of_orders,
      sum(total_amt_usd) as Total_amount,
      case when count(o.id) > 200 or sum(total_amt_usd) > 750000 then 'Top'
           when count(o.id) > 150 or sum(total_amt_usd) > 500000 then 'Middle'
           else 'Low' end as Level
from sales_reps s
join accounts a
on s.id = a.sales_rep_id
join orders o
on a.id = o.account_id
group by 1
order by 3 desc;
