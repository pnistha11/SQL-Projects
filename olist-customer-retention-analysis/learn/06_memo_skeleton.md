# Findings memo — skeleton

Fill the brackets with your real numbers, then tell me and I'll turn
this into a formatted one-page PDF.

---

## How to write this (read once, then delete this section)

**Your reader is a category manager.** They own a P&L, they're busy,
and they will read the first two lines and the last three. They do not
care that you used `NTILE` or a window function. They care about what
is losing money and what to do on Monday.

Five rules:

1. **Lead with the number, not the method.** Not "I performed cohort
   analysis and found that retention is low." Instead: "97 of every 100
   customers never buy again."
2. **Every finding needs a size.** A finding without R$ or % attached is
   an observation, not a finding.
3. **One page. Genuinely one page.** If it spills, cut the third-most
   interesting thing. Discipline about this is itself a signal.
4. **Recommendations must be actionable by the reader.** "Improve
   retention" is not an action. "Trigger a category-matched offer at day
   30 for the 12k customers who bought health & beauty once" is.
5. **Name one limitation.** Every real analysis has one. Stating it
   builds more trust than hiding it. Reviews firing on dispatch rather
   than delivery is a good honest candidate.

**On currency:** this is Brazilian data in **R$**. Don't relabel it ₹.
If you want a rupee figure for an Indian audience, write it as
"R$ X (approx. ₹Y at R$1 = ₹Z)" and state the rate you used. Quietly
swapping the symbol is the kind of thing that gets caught in an
interview and costs you the room.

---

## Customer behaviour review — Olist marketplace
**Period:** Jan 2017 – Aug 2018 | **Prepared by:** [name] | **Date:** [date]

### What I found

- **[Retention finding.]** Of [N] customers acquired in the period,
  only [X]% ever placed a second order. Month-1 return rate averaged
  [X]% across cohorts and did not improve over 20 months of trading —
  this is structural, not seasonal.

- **[Funnel finding.]** [X]% of placed orders reach delivery. The
  largest single loss is at [stage], where [N] orders ([X]%) drop out.
  Median time from order to delivery is [X] days, but the slowest 10%
  of customers wait [X] days — [X]x longer.

- **[Value concentration finding.]** The top [X]% of customers by value
  generate [X]% of revenue. [Segment name] is the largest segment at
  [N] customers ([X]%) and holds [X]% of historic revenue, all of it
  currently dormant.

### Why it matters

- At the current repeat rate, we spend acquisition budget [X] times to
  earn revenue we could have earned once. Lifting repeat purchase from
  [X]% to just [X]% would add approximately **R$ [amount]** per year at
  today's average order value of R$ [X] — no new customers required.

- Customers whose first delivery arrived late repeat at [X]% versus
  [X]% for on-time deliveries — a **[X] percentage point** gap. The
  [N] late first deliveries in the period represent an estimated
  **R$ [amount]** in forgone second orders.

- The dormant [segment] segment is worth **R$ [amount]** in past
  revenue. Reactivating even [X]% of it returns **R$ [amount]**,
  materially cheaper than acquiring the equivalent new customers.

### What I'd do about it

1. **[Highest-value action.]** Launch a day-[N] post-delivery offer
   targeted at the [N] customers in [segment], matched to their first
   purchase category. Median repeat gap is [X] days, so the window
   closes fast. Measure as a holdout test; success = [X]% second-order
   rate within 60 days.

2. **[Fix the funnel leak.]** Investigate the [N] orders stuck at
   [stage]. If [X]% of these are concentrated in [states/sellers], a
   carrier or seller SLA change fixes it without touching marketing
   spend.

3. **[Protect the good customers.]** Put the [N] "At Risk" and "Cannot
   Lose Them" customers on a watch list with priority fulfilment. They
   are [X]% of the base but [X]% of revenue; losing them costs more per
   head than any other group.

### Method and limitations

Cohorts, funnel and RFM built in MySQL 8 over [N] orders from the Olist
public dataset, keyed on `customer_unique_id` (the order-level
`customer_id` is regenerated per order and would understate repeat
purchase to zero). Revenue is item price plus freight.

One caveat: review requests are sent at dispatch rather than delivery,
so "reviewed" is not strictly downstream of "delivered" — [N] orders
carry a review without a recorded delivery date. The funnel above
enforces nesting, which slightly understates review volume.

---

## Numbers checklist

Run these before writing. If a bracket above is still empty, the number
comes from here:

| Number | Source |
|---|---|
| Total customers, repeat %, repeat rate | `02_cohort_retention.sql`, supporting query 1 |
| Average month-1 retention | `05_visuals.py` prints it |
| Median days between purchases | `02_cohort_retention.sql`, supporting query 2 |
| Repeat rate: late vs on-time first delivery | `02_cohort_retention.sql`, supporting query 3 |
| Funnel counts and conversion | `03_funnel.sql`, main query |
| Median and p90 stage durations | `03_funnel.sql`, median block |
| GMV by status (leaked revenue) | `03_funnel.sql`, money-leak query |
| Segment sizes and revenue share | `04_rfm.sql`, main query |
| Top-20% revenue concentration | `04_rfm.sql`, Pareto query |
| Average order value | `SELECT AVG(order_revenue) FROM ...` — write it |
