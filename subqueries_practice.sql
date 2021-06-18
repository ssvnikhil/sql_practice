"""
1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
"""
select b.sales_rep, a.region_name, a.total_max_amt
from
      (select region_name, max(total_amount) as Total_max_amt
      from
            (select s.name as sales_rep, r.name as region_name, sum(total_amt_usd) as Total_amount
            from sales_reps s
            join accounts a
            on s.id = a.sales_rep_id
            join orders o
            on a.id = o.account_id
            join region r
            on r.id = s.region_id
            group by 1, 2) sub
      group by 1) a
JOIN (select s.name as sales_rep, r.name as region_name, sum(total_amt_usd) as Total_amount
      from sales_reps s
      join accounts a
      on s.id = a.sales_rep_id
      join orders o
      on a.id = o.account_id
      join region r
      on r.id = s.region_id
      group by 1, 2) b
on a.region_name = b.region_name and a.total_max_amt = b.total_amount;

"""
2. For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?
"""
select r.name as region_name, sum(total_amt_usd) as Total_amount, count(o.id) as Total_orders
from region r
join sales_reps s
on r.id = s.region_id
join accounts a
on s.id = a.sales_rep_id
join orders o
on a.id = o.account_id
group by 1
having sum(total_amt_usd) = (select max(total_amount)
                             from (select r.name as region_name, sum(total_amt_usd) as Total_amount, count(o.id) as Total_orders
                                   from region r
                                   join sales_reps s
                                   on r.id = s.region_id
                                   join accounts a
                                   on s.id = a.sales_rep_id
                                   join orders o
                                   on a.id = o.account_id
                                   group by 1) sub);

"""
3. How many accounts had more total purchases than the account name which has bought the
most standard_qty paper throughout their lifetime as a customer?
"""
select a.name as account_name, sum(total) as Total_qty
from accounts a
join orders o
on a.id = o.account_id
group by 1
having sum(total) > (select total
                     from
                          (select a.name as account_name, sum(standard_qty) as Total_std_qty, sum(o.total) total
                          from accounts a
                          join orders o
                          on a.id = o.account_id
                          group by 1
                          order by 2 desc
                          limit 1) sub);

"""
4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd,
how many web_events did they have for each channel?
"""
select a.name, w.channel, count(*) as no_of_events
from web_events w
join accounts a
on a.id = w.account_id
where account_id in
                      (select a.id
                      from
                            (select a.id, sum(o.total_amt_usd) as total_amount
                            from accounts a
                            join orders o
                            on a.id = o.account_id
                            group by 1
                            order by 2 desc
                            limit 1) sub_query)
group by 1, 2
order by 3 desc;

"""
5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
"""
select avg(total_amount) as avg_amt
from
    (select account_id, sum(total_amt_usd) as Total_amount
    from orders
    group by 1
    order by 2 desc
    limit 10) sub_query;

"""
6. What is the lifetime average amount spent in terms of total_amt_usd,
including only the companies that spent more per order, on average, than the average of all orders.
"""
select avg(avg_amt)
from
      (select account_id, avg(total_amt_usd) as avg_amt
      from orders
      group by 1
      having avg(total_amt_usd) > (select avg(total_amt_usd)
                                   from orders))
