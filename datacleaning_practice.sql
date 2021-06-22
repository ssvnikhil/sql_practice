"""
LEFT & RIGHT Quizzes
"""

"""
1. In the accounts table, there is a column holding the website for each company.
The last three digits specify what type of web address they are using.
A list of extensions (and pricing) is provided here.
Pull these extensions and provide how many of each website type exist in the accounts table.
"""
select right(website, 3) as domain_extension, count(*) as domain_cnt
from accounts
group by 1
order by 2 desc

"""
2. There is much debate about how much the name (or even the first letter of a company name) matters.
Use the accounts table to pull the first letter of each company name to see the distribution of company names
that begin with each letter (or number).
"""
select left(upper(name), 1) as company_first_letter, count(*) as cnt
from accounts
group by 1
order by 2 desc

"""
3. Use the accounts table and a CASE statement to create two groups: one group of company names that
start with a number and a second group of those company names that start with a letter.
What proportion of company names start with a letter?
"""
select sum(num) as num_count, sum(letter) as letter_count
from
(select name, case when left(upper(name), 1) in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9') then 1 else 0 end as num,
             case when left(upper(name), 1) not in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9') then 1 else 0 end as letter
from accounts) t1;


"""
4. Consider vowels as a, e, i, o, and u.
What proportion of company names start with a vowel, and what percent start with anything else?
"""
select sum(vowel) as vowel_count, sum(non_vowel) as non_vowel_count
from
      (select name, case when left(upper(name), 1) in ('A', 'E', 'I', 'O', 'U') then 1 else 0 end as vowel,
      case when left(upper(name), 1) not in ('A', 'E', 'I', 'O', 'U') then 1 else 0 end as non_vowel
      from accounts) t1;

"""
POSITION & STRPOS
"""

"""
5. Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.
"""
select primary_poc,
	     position(' ' in primary_poc) as space_pos,
       left(primary_poc, position(' ' in primary_poc) - 1) as first_name,
       right(primary_poc, length(primary_poc) - position(' ' in primary_poc)) as last_name
from accounts;

"""
6. Now see if you can do the same thing for every rep name in the sales_reps table.
Again provide first and last name columns.
"""
select name, strpos(name, ' ') as space_pos,
	     left(name, strpos(name, ' ') - 1) as first_name,
       right(name, length(name) - strpos(name, ' ')) as last_name
from sales_reps;

"""
CONCAT
"""

"""
7. Each company in the accounts table wants to create an email address for each primary_poc.
The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.
"""
select primary_poc, name,
       left(primary_poc, strpos(primary_poc, ' ') - 1) as first_name,
       right(primary_poc, length(primary_poc) - strpos(primary_poc, ' ')) as last_name,
left(primary_poc, strpos(primary_poc, ' ') - 1) || '.' || right(primary_poc, length(primary_poc) - strpos(primary_poc, ' ')) || '@' || name || '.com' as email_address
from accounts;


"""
8. You may have noticed that in the previous solution some of the company names include spaces,
which will certainly not work in an email address.
See if you can create an email address that will work by removing all of the spaces in the account name,
but otherwise your solution should be just as in question 1.
"""
select primary_poc, name,
left(primary_poc, strpos(primary_poc, ' ') - 1) as first_name,
right(primary_poc, length(primary_poc) - strpos(primary_poc, ' ')) as last_name,
left(primary_poc, strpos(primary_poc, ' ') - 1) || '.' || right(primary_poc, length(primary_poc) - strpos(primary_poc, ' '))
|| '@' || replace(name,' ', '') || '.com' as email_address
from accounts;


"""
9. We would also like to create an initial password, which they will change after their first log in. The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their first name (lowercase), the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, the number of letters in their last name, and then the name of the company they are working with, all capitalized with no spaces.
"""
select primary_poc, name,
       left(primary_poc, strpos(primary_poc, ' ') - 1) as first_name,
       right(primary_poc, length(primary_poc) - strpos(primary_poc, ' ')) as last_name,
       left(lower(primary_poc), 1) || right(left(lower(primary_poc), strpos(primary_poc, ' ') - 1), 1) ||
       left(right(lower(primary_poc), length(primary_poc) - strpos(primary_poc, ' ')), 1) ||
       right(lower(primary_poc), 1) || length(left(primary_poc, strpos(primary_poc, ' ') - 1)) ||
       length(right(primary_poc, length(primary_poc) - strpos(primary_poc, ' '))) ||
       upper(replace(name, ' ', '')) as password
from accounts;

with cte as
(select primary_poc, name,
        left(primary_poc, strpos(primary_poc, ' ') - 1) as first_name,
        right(primary_poc, length(primary_poc) - strpos(primary_poc, ' ')) as last_name
from accounts)

select first_name, last_name,
       left(lower(first_name), 1) || right(lower(first_name), 1) || left(lower(last_name), 1) ||
       right(lower(last_name), 1) || length(first_name) || length(last_name) || upper(replace(name, ' ', '')) as password
from cte;

"""
CAST
"""

"""
10. Date column changed from string format to date format
"""
select *, substr(date, 1, 10) as date_str,
      cast((substr(date, 7, 4) || '-' || substr(date, 1, 2)  || '-' || substr(date, 4, 2)) as date) as date_alt
from sf_crime_data
limit 10;

"""
Coalesce
"""
select a.id, name, website, lat, long, primary_poc, sales_rep_id,
       coalesce(o.account_id, a.id) as account_id, occurred_at,
       coalesce(standard_qty, 0) as standard_qty,
       coalesce(gloss_qty, 0) as gloss_qty,
       coalesce(poster_qty, 0) as poster_qty,
       coalesce((standard_qty + gloss_qty + poster_qty), 0) as total,
       coalesce(standard_amt_usd, 0) as standard_amt_usd,
       coalesce(gloss_amt_usd, 0) as gloss_amt_usd,
       coalesce(poster_amt_usd, 0) as poster_amt_usd,
       coalesce((standard_amt_usd + gloss_amt_usd + poster_amt_usd), 0) as total_amt_usd
from accounts a
left join orders o
on a.id = o.account_id
where o.total is NULL
