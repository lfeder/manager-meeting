# Manager Meeting

Single-page review deck for the manager meeting: cucumber growing and lettuce
packhouse, 2025 against 2026.

`index.html` is self-contained — no build, no dependencies, no network calls.
Open it locally or serve it from GitHub Pages.

`deck.html` is the full H1 2026 manager review deck, which folds this page's
grow and packhouse charts into the wider review — sales, tech, corp, capital and
expansion. See [Full review deck](#full-review-deck) below.

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

15 slides:

| | |
|---|---|
| 1 | % Short — cucumber fill rate by product, 2025 vs 2026 |
| 2 | Sales — the account and product agenda |
| 3 | Grow — time in the house vs lb per greenhouse-day, per house |
| 4–7 | **Cucumber Growing Review** — merged from this repo's Grow page |
| 8–11 | **Lettuce packhouse, day by day** — merged from this repo's Packhouse page |
| 12 | Tech — where we are on the ladder |
| 13 | Corp — food safety and people |
| 14 | Capital — funded, committed, evaluating, expansion |
| 15 | Expansion — 6 acres, site layout |

Slides 4–11 are this repo's own charts, one per page, restyled to the deck's light
palette: amber 2025, green 2026, weekly-mean line over a faint scatter of single
days. The caveats travel with them — late 2026 cycles still picking, the
JTL_05 03/26 lineage repair, no E in the 2025 cohort, and the fails/labour logging
gaps in mid-2026, which break the lines rather than being drawn as zero.

`queries.sql` documents the SQL behind every series in `deck.html`, including a
re-query of this page's headline figure: 1,921,947 / 1,950,388 lb live against the
1,922,039 / 1,950,566 snapshotted here — same definition, a few rows edited since.
