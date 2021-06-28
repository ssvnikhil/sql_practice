"""
1. create a running total of standard_amt_usd (in the orders table) over order time with no date truncation.
Your final table should have two columns:
one with the amount being added for each new row, and a second with the running total.
"""
select standard_amt_usd, occurred_at,
       sum(standard_amt_usd) over (order by occurred_at) as running_total
from orders;


"""
2. Create a running total of standard_amt_usd (in the orders table) over order time,
but this time, date truncate occurred_at by year and partition by that same year-truncated occurred_at variable.
Your final table should have three columns:
One with the amount being added for each row, one for the truncated date,
and a final column with the running total within each year.
"""
select standard_amt_usd,
       date_trunc('year', occurred_at) as Year,
       sum(standard_amt_usd) over (partition by date_trunc('year', occurred_at)
            order by occurred_at) as running_total
from orders;

"""
3. Rownum, Rank and Dense Rank window functions
"""
select id, account_id,
	     date_trunc('month', occurred_at) as month,
	     row_number() over (partition by account_id order by date_trunc('month', occurred_at)) as rownum,
       rank() over (partition by account_id order by date_trunc('month', occurred_at)) as rnk,
      dense_rank() over (partition by account_id order by date_trunc('month', occurred_at)) as dense_rnk
from orders;

"""
4. Select the id, account_id, and total variable from the orders table, then create a column called total_rank
that ranks this total amount of paper ordered (from highest to lowest) for each account using a partition.
Your final table should have these four columns
"""
select id, account_id, total,
       rank() over (partition by account_id order by total desc) as total_rank
from orders;

"""
5. Aggregates in window functions
"""
select id, account_id, standard_qty,
       date_trunc('month', occurred_at) as month,
       dense_rank() over (partition by account_id order by date_trunc('month', occurred_at)) as dense_rnk,
       sum(standard_qty) over (partition by account_id order by date_trunc('month', occurred_at)) as sum_std_qty,
       count(standard_qty) over (partition by account_id order by date_trunc('month', occurred_at)) as count_std_qty,
       min(standard_qty) over (partition by account_id order by date_trunc('month', occurred_at)) as min_std_qty,
       max(standard_qty) over (partition by account_id order by date_trunc('month', occurred_at)) as max_std_qty,
       avg(standard_qty) over (partition by account_id order by date_trunc('month', occurred_at)) as avg_std_qty
from orders;

"""
6. Aliases for multiple window functions
"""
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER main_window AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER main_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER main_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER main_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER main_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER main_window AS max_total_amt_usd
FROM orders
WINDOW main_window as (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at))

"""
7. LAG and LEAD window functions
"""
select account_id, standard_sum,
       lag(standard_sum) over (order by standard_sum) as lag,
       lead(standard_sum) over (order by standard_sum) as lead,
       standard_sum - (lag(standard_sum) over (order by standard_sum)) as lag_difference,
       lead(standard_sum) over (order by standard_sum) - standard_sum as lead_difference
FROM
      (select account_id, sum(standard_qty) as standard_sum
      from orders
      group by 1) sub;

select occurred_at, total_amt,
       lag(total_amt) over (order by occurred_at) as lag,
       lead(total_amt) over (order by occurred_at) as lead,
       total_amt - lag(total_amt) over (order by occurred_at) as lag_difference,
       lead(total_amt) over (order by occurred_at) - total_amt as lead_difference
from
      (select occurred_at, sum(total_amt_usd) as total_amt
       from orders
       group by 1) sub

"""
Percentiles
"""

"""
8. Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for their orders.
Your resulting table should have the account_id, the occurred_at time for each order,
the total amount of standard_qty paper purchased, and one of four levels in a standard_quartile column.
"""
SELECT account_id, occurred_at, standard_qty,
       NTILE(4) over (PARTITION by account_id order by standard_qty) as standard_quartile
FROM orders
order by account_id

"""
9. Use the NTILE functionality to divide the accounts into two levels in terms of the amount of gloss_qty for their orders.
Your resulting table should have the account_id, the occurred_at time for each order,
the total amount of gloss_qty paper purchased, and one of two levels in a gloss_half column.
"""
SELECT account_id, occurred_at, gloss_qty,
      NTILE(2) over (partition by account_id order by gloss_qty) as gloss_half
FROM orders
order by account_id

"""
10. Use the NTILE functionality to divide the orders for each account into 100 levels in terms of
the amount of total_amt_usd for their orders. Your resulting table should have the account_id,
the occurred_at time for each order, the total amount of total_amt_usd paper purchased,
and one of 100 levels in a total_percentile column.
"""
SELECT account_id, occurred_at, total_amt_usd,
       NTILE(100) over (partition by account_id order by total_amt_usd) as total_percentile
FROM orders
ORDER by account_id
