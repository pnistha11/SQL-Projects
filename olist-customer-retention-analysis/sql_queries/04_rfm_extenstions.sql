-- RFM EXTENSIONS
use olist;

/* ============================================================
   EXERCISE 1 — NTILE vs RULE-BASED FREQUENCY SCORE

   Identical to the main segment table with one substitution:
   f_score_ntile replaces f_score everywhere in the CASE.
   Run the diagnostic first so you can see WHY the numbers move.
   ============================================================ */

-- Diagnostic: does NTILE actually separate anyone on frequency?
select f_score_ntile,
		count(*) as customers,
        min(frequency) as min_freq,
        max(frequency) as max_freq
from rfm_customers
group by f_score_ntile
order by f_score_ntile;

-- the ntile version of the segment table
with resegmented as (
	select monetary, recency_days,frequency,
		case
			when r_score >= 4 and f_score_ntile >= 4 then 'Champions'
            when r_score >= 2 and f_score_ntile >= 5 then 'Cannot Lose Them'
            when r_score >= 3 and f_score_ntile >= 3 then 'Loyal Customers'
            when r_score <= 2 and f_score_ntile >= 3 then 'At Risk'
            when r_score = 5 and f_score_ntile <= 2 then 'New Customers'
            when r_score = 4 and f_score_ntile <= 2 then 'Promising'
            when r_score = 3 and f_score_ntile <= 2 then 'Needs Attention'
            when r_score <= 2 and f_score_ntile <= 2 then 'Hibernating'
			else 'Others'
		end as segment_ntile
	from rfm_customers
)
select segment_ntile,
		count(*) as customers,
        round(100.0 * count(*) / sum(count(*)) over (), 2) as pct_customers,
        round(sum(monetary), 2) as revenue_brl,
        round(100.0 * sum(monetary) / sum(sum(monetary)) over () ,2) as pct_revenue,
        round(avg(frequency), 3) as avg_frequency
from resegmented
group by segment_ntile
order by revenue_brl desc;

-- Side-by-side comparison of the two labellings.
-- The diagonal is agreement; everything off it is a customer
-- the two methods disagree about.
