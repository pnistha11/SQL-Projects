-- what date range am I actually working with?!
select min(order_purchase_timestamp) as first_order,
	   max(order_purchase_timestamp) as last_order
from orders;
/*Note that Sep-Dec 2016 is nearly
empty (a handful of orders) and Oct 2018 is a partial month.
That is why the cohort script clips to 2017-01 .. 2018-08.  */

-- what statues exists ,and how common are they?
select order_status, count(*) n,
	   round(100 * count(*) / sum(count(*)) over (), 2) pct
from orders group by order_status order by n desc;
/* 'delivered' dominates. Notice how few orders sit in 'approved' —
that's why the funnel uses timestamps, not statuses. */