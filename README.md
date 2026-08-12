# Manager Meeting

Single-page review deck for the manager meeting: cucumber growing and lettuce
packhouse, 2025 against 2026.

`index.html` is self-contained — no build, no dependencies, no network calls.
Open it locally or serve it from GitHub Pages.

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
