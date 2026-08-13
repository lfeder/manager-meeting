# Manager Meeting

Single-page review deck for the manager meeting: cucumber growing and lettuce
packhouse, 2025 against 2026.

`index.html` is self-contained — no build, no dependencies, no network calls.
Open it locally or serve it from GitHub Pages.

`deck.html` is the full H1 2026 manager review deck — sales, grow, packhouse,
tech, corp, capital and expansion. See [Full review deck](#full-review-deck) below.

## Pages

- **Grow** — season pounds, how long cycles keep picking, and run length by variety
  (K Delta Star Minis, J F1 TSX-CU235JP, E Cumlaude RZ).
- **Packhouse** — pounds packed, trays per packer-minute, packer-hours, and fails.

Each tile opens its own detail chart.

## Data

Figures are hardcoded from Supabase (`hawaii_farming`) as of 12 Aug 2026, covering
1 Jan – 11 Aug of each year. Grade 1 only for cucumbers; the Feb–Apr cohort is
cycles seeded 1 Feb – 30 Apr, measured per cycle (12 in 2025, 13 in 2026).

Two caveats carried on the page itself:

- Packhouse growth of +33% is mostly **Costco Iwilei (687)**, which started 22 May
  2025. Excluding it, growth is **+7.6%**.
- The 2025 cucumber cohort has **no E (Cumlaude)** at all, so the variety comparison
  is within-2026.

To refresh, re-run the queries and update the data arrays at the top of the
`<script>` block: `D`, `LB`, `PF` (packhouse), `DAY`, `WK`, `VAR`, `CYC` (grow).

## Full review deck

`deck.html` is the H1 2026 manager review, rebuilt in HTML from
`H1_2026_Manager_Final.pptx`. Same conventions as `index.html` — self-contained,
no build, no network calls — but paginated as slides rather than scrolled.

Arrow keys or space to move, `O` for a slide overview, number keys to jump. Every
chart has a hover tooltip and a **Data** button (revealed on hover) that swaps the
chart for the table behind it.

15 slides: an Opportunities cover, % Short, Sales Opportunities and its two
click-throughs (Costco Japanese ordered vs shipped, lettuce cases by customer),
three Grow slides, three Lettuce packhouse day-by-day slides (pounds packed,
then trays per packer-minute beside packer-hours, then fails), Tech, Corp,
Capital and Expansion.

The packhouse slides carry the four KPI tiles from `index.html` across all
three; a tile is lit on the slide it opens, and clicking one jumps there. The
two Sales cards with a **See the chart →** cue open their own slide.

The packhouse charts share this repo's conventions — amber 2025, green 2026,
weekly-mean line over a faint scatter of single days — and keep the mid-2026
logging gaps as breaks in the line rather than drawing them as zero.

`queries.sql` documents the SQL behind every series in `deck.html`.
