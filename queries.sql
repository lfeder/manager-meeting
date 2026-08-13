-- =====================================================================
-- H1 2026 Manager Review — data provenance for deck.html
--
-- Source:  aloha-prod  (Supabase project zdvpqygiqavwpxljpvqw)
-- Org:     hawaii_farming
--
-- deck.html is a copy of H1_2026_Manager_Final.pptx with the five chart
-- images rebuilt as live HTML/SVG. Every number in those charts is the
-- verbatim output of a query below — re-run them to refresh the deck.
--
-- Not from here: the capital board on slide 7 (Capital Investments
-- '26.xlsx), the PCR / audit scores on slide 6, and the site plan on
-- slide 8 (Huete drawing 26JJ009(04), embedded as an image).
-- =====================================================================


-- ---------------------------------------------------------------------
-- SLIDE 1 · "% Short"
-- Ordered vs shipped per cucumber product, by invoice month.
-- The chart plots (shipped - ordered) / ordered. "Shipped" is the sum of
-- fulfilment records against the order lines, not invoice_quantity,
-- which is only populated for the current open month.
-- ---------------------------------------------------------------------
with base as (
  select to_char(p.invoice_date,'YYYY-MM') as m,
         l.sales_product_id as pid, l.id as line_id, l.order_quantity as oq
  from sales_po p
  join sales_po_line l on l.sales_po_id = p.id and not l.is_deleted
  where p.org_id = 'hawaii_farming' and not p.is_deleted
    and p.invoice_date >= '2025-01-01' and p.invoice_date < '2026-08-01'
    and l.sales_product_id in ('KR','KW','JR','JW')
), ff as (
  select b.m, b.pid, sum(f.fulfilled_quantity) as fq
  from base b
  join sales_po_fulfillment f on f.sales_po_line_id = b.line_id and not f.is_deleted
  group by 1,2
)
select b.m, b.pid,
       sum(b.oq)::int as ordered,
       (select sum(fq)::int from ff where ff.m = b.m and ff.pid = b.pid) as shipped
from base b
group by b.m, b.pid
order by b.pid, b.m;


-- ---------------------------------------------------------------------
-- SLIDE 3 · the two stat cards — K (Keiki) and J (Japanese) net lb, H1
-- Variety comes off the seed item on the batch.
--   K: 1,248,059 -> 1,122,039  (-10%)
--   J:   441,472 ->   444,667  (+1%)
-- ---------------------------------------------------------------------
with b as (
  select h.net_weight, h.harvest_date, i.grow_variety_id as variety
  from grow_harvest_weight h
  join grow_cuke_seed_batch s
    on s.id = h.grow_cuke_seed_batch_id and not s.is_deleted
  left join invnt_item i on i.id = s.invnt_item_id and i.org_id = s.org_id
  where h.org_id = 'hawaii_farming' and not h.is_deleted and h.farm_id = 'Cuke'
)
select variety,
  sum(net_weight) filter (where harvest_date >= '2025-01-01'
                            and harvest_date <  '2025-07-01')::int as h1_2025,
  sum(net_weight) filter (where harvest_date >= '2026-01-01'
                            and harvest_date <  '2026-07-01')::int as h1_2026
from b group by 1 order by 3 desc nulls last;


-- ---------------------------------------------------------------------
-- SLIDE 3 · the table — days in the house vs lb per greenhouse-day
-- A cycle is (site, transplant_date). A cycle counts toward a half-year
-- if its LAST harvest lands in that Jan-Jun window. Days = transplant to
-- last harvest. Lb per GH-day is total lb over total days across the
-- window's cycles — NOT the mean of the per-cycle rates, which would
-- over-weight short cycles (that variant gives 836/736, not 819/734).
-- ---------------------------------------------------------------------
with cyc as (
  select b.site_id, b.transplant_date,
         max(h.harvest_date) as last_h,
         sum(h.net_weight)   as lb
  from grow_cuke_seed_batch b
  join grow_harvest_weight h
    on h.grow_cuke_seed_batch_id = b.id and not h.is_deleted
  where b.org_id = 'hawaii_farming' and not b.is_deleted
    and b.transplant_date is not null
  group by 1,2
), c2 as (
  select site_id, lb,
         (last_h - transplant_date)::numeric as days,
         case when last_h >= '2025-01-01' and last_h < '2025-07-01' then 2025
              when last_h >= '2026-01-01' and last_h < '2026-07-01' then 2026 end as yr
  from cyc
  where last_h > transplant_date
)
select site_id,
  round(avg(days) filter (where yr = 2025),1) as days_25,
  round(avg(days) filter (where yr = 2026),1) as days_26,
  round(sum(lb)   filter (where yr = 2025)
      / sum(days) filter (where yr = 2025))   as lb_per_gh_day_25,
  round(sum(lb)   filter (where yr = 2026)
      / sum(days) filter (where yr = 2026))   as lb_per_gh_day_26
from c2 where yr is not null
group by 1
union all
select 'All 12 houses',
  round(avg(days) filter (where yr = 2025),1),
  round(avg(days) filter (where yr = 2026),1),
  round(sum(lb) filter (where yr = 2025) / sum(days) filter (where yr = 2025)),
  round(sum(lb) filter (where yr = 2026) / sum(days) filter (where yr = 2026))
from c2 where yr is not null
order by 1;


-- ---------------------------------------------------------------------
-- SLIDES 4-7 · "Lettuce packhouse, day by day"
-- One row per pack day, 1 Jan - 11 Aug, for 2025 and 2026. Both years
-- are plotted on a shared day-of-year axis; neither year is a leap year,
-- so day 60 is 1 March in both and the two align exactly.
--
-- Feeds four charts:
--   lb            -> Pounds packed per day
--   tppm          -> Trays per packer per minute
--   packer_hours  -> Packer-hours per day
--   fails         -> Fails per day
--
-- Definitions:
--   trays        = cases x pack_per_case across every lettuce product,
--                  so food-service bag packs count at 5 per case
--   packer_hours = sum of the hourly packer headcount over the day
--                  (one labor row per hour, so a count IS an hour)
--   tppm         = trays / (packer_hours * 60)
--
-- NULLs are real recording gaps, not zeroes, and the deck breaks the
-- line across them rather than interpolating:
--   fails  not logged 24 May - 9 Jul 2026
--   labour not logged  1 Jul -  9 Jul 2026
-- ---------------------------------------------------------------------
with span as (
  select generate_series::date d
    from generate_series('2025-01-01'::date,'2025-08-11'::date,'1 day')
  union all
  select generate_series::date
    from generate_series('2026-01-01'::date,'2026-08-11'::date,'1 day')
), tr as (
  select c.pack_date d,
         sum(c.cases_packed * p.pack_per_case)   as trays,
         sum(c.cases_packed * p.case_net_weight) as lb
  from pack_session_cases c
  join sales_product p
    on p.id = c.sales_product_id and p.org_id = c.org_id and not p.is_deleted
  where c.org_id = 'hawaii_farming' and c.farm_id = 'Lettuce' and not c.is_deleted
  group by 1
), lab as (
  select pack_date d, sum(packers) ph
  from pack_session_labor_hour
  where org_id = 'hawaii_farming' and farm_id = 'Lettuce' and not is_deleted
  group by 1
), fl as (
  select pack_date d, sum(fail_count) fails
  from pack_session_fails
  where org_id = 'hawaii_farming' and farm_id = 'Lettuce' and not is_deleted
  group by 1
)
select extract(year from s.d)::int as yr,
       extract(doy  from s.d)::int as doy,
       round(tr.lb)::int           as lb,
       nullif(lab.ph,0)::int       as packer_hours,
       case when lab.ph > 0 and tr.trays is not null
            then round(tr.trays / (lab.ph * 60.0), 3) end as tppm,
       fl.fails::int               as fails
from span s
left join tr  on tr.d  = s.d
left join lab on lab.d = s.d
left join fl  on fl.d  = s.d
where tr.lb is not null or lab.ph is not null or fl.fails is not null
order by yr, doy;


-- ---------------------------------------------------------------------
-- SLIDE 6 · "FOOD SAFETY SPEND"
-- 2026 is the H1 actual doubled to a full-year run-rate.
-- ---------------------------------------------------------------------
select
  sum(effective_amount) filter (where txn_date >= '2024-01-01'
                                  and txn_date <  '2025-01-01')::int as y2024,
  sum(effective_amount) filter (where txn_date >= '2025-01-01'
                                  and txn_date <  '2026-01-01')::int as y2025,
 (sum(effective_amount) filter (where txn_date >= '2026-01-01'
                                  and txn_date <  '2026-07-01') * 2)::int as y2026_run_rate
from fin_expense
where org_id = 'hawaii_farming' and not is_deleted
  and account_name = '6. Office:Food Safety';
