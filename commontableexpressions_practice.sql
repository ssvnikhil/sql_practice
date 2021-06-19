"""
1. Provide the name of the sales_rep in each region with
   the largest amount of total_amt_usd sales.
"""
with cte as
(select s.name as sales_rep, r.name as region_name, sum(o.total_amt_usd) as total_amount
from region r
join sales_reps s
on r.id = s.region_id
join accounts a
on s.id = a.sales_rep_id
join orders o
on a.id = o.account_id
group by 1, 2),

 cte_2 as
(select region_name, max(total_amount) as total
from cte
group by 1)

select a.*
from cte a
join cte_2 b
on a.region_name = b.region_name
and a.total_amount = b.total
"""
2. For the region with the largest sales total_amt_usd,
   how many total orders were placed?
"""
with cte as
(select r.name as region_name, sum(o.total_amt_usd) as total_amount,
        count(o.id) as order_counts
from region r
join sales_reps s
on r.id = s.region_id
join accounts a
on s.id = a.sales_rep_id
join orders o
on a.id = o.account_id
group by 1),

cte_2 as
(select max(total_amount) as total
from cte)

select region_name, order_counts
from cte
where total_amount = (select total from cte_2);

"""
3. How many accounts had more total purchases than the account name
   which has bought the most standard_qty paper throughout their lifetime
   as a customer?
"""
with cte as
(select a.name as account_name, sum(o.standard_qty) as std_qty,
       sum(o.total) as total_qty
from accounts a
join orders o
on a.id = o.account_id
group by 1
order by 2 desc
limit 1),

cte_2 AS
(select total_qty
 from cte)

select a.name as account_name, sum(o.total) as total
from accounts a
join orders o
on a.id = o.account_id
group by 1
having sum(o.total) > (select * from cte_2)

"""
4. For the customer that spent the most (in total over their lifetime as a
  customer) total_amt_usd, how many web_events did they have for each channel?
"""
with cte as
(select a.id, a.name, sum(o.total_amt_usd) as total_amount
from accounts a
join orders o
on a.id = o.account_id
group by 1, 2
order by 3 DESC
limit 1)

SELECT a.name, w.channel, count(*) as cnt
from accounts a
join cte o
on a.id = o.id
join web_events w
on a.id = w.account_id
group by 1, 2
order by 3 desc

"""
5. What is the lifetime average amount spent in terms of total_amt_usd
   for the top 10 total spending accounts?
"""
with cte as
(select a.id, a.name as account_name, sum(o.total_amt_usd) as total_amount
from accounts a
join orders o
on a.id = o.account_id
group by 1, 2
order by 3 DESC
limit 10)

select avg(total_amount) as avg_amt
from cte

"""
6. What is the lifetime average amount spent in terms of total_amt_usd,
   including only the companies that spent more per order,
   on average, than the average of all orders.
"""
with cte as
(select avg(total_amt_usd)
from orders),

cte_2 as
(select a.id, a.name, avg(o.total_amt_usd) as avg_amt
from accounts a
join orders o
on a.id = o.account_id
group by 1, 2
having avg(o.total_amt_usd) > (select * from cte))

select avg(avg_amt) as average_amount from cte_2
