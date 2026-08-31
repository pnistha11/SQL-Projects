# Global Layoffs Analysis, 2020–2025

**SQL analysis of 3,551 layoff events across 800,859 people, from the start of the pandemic through December 2025.**

Cleaning and analysis in MySQL, using window functions and CTEs. The dataset covers publicly reported layoffs by company, industry, country, funding stage, and date.

---

## Headline findings

**2023 was the worst year, not 2020 or 2025.** 264,320 people were laid off in 2023 — more than 2024 and 2025 combined, and over three times the pandemic-onset spike of 2020.

| Year | Laid off |
|---|---|
| 2020 | 80,998 |
| 2021 | 15,823 |
| 2022 | 164,319 |
| 2023 | **264,320** |
| 2024 | 152,922 |
| 2025 | 122,477 |

**Intel leads all companies at 43,115** — ahead of Amazon (41,940) and Microsoft (30,055). A chipmaker, not a consumer tech giant, tops the list.

**Hardware is the most affected industry at 93,207**, ahead of Retail (88,211) and Consumer (80,810). The common assumption that software and crypto dominated the layoff wave does not hold up against the totals.

**The United States accounts for 556,665 — 70% of the global figure.** India is a distant second at 63,624, followed by Germany (31,438).

**339 companies laid off their entire workforce.** These are shutdowns rather than reductions, and they skew toward earlier funding stages.

## The data problem worth knowing about

44% of rows have no headcount. 1,470 of 4,248 records report that a layoff happened without saying how many people it affected — many list only a percentage.

This matters more than it looks. Blank values cast to an `INT` column become `0` in MySQL, silently. That would turn 776 real layoff events into zero-person events and drag every average down by roughly 22%. The cleaning script converts blanks to `NULL` **before** any type conversion, so aggregates skip them honestly rather than counting them as zero.

Rows carrying neither a headcount nor a percentage (694 of them) are dropped, since they cannot support any analysis.

One consequence to keep in mind when reading the figures above: totals reflect only the events that reported headcounts. The true numbers are higher.

## Cleaning steps

1. **Stage** the raw table so the source is never modified.
2. **Deduplicate** on the full attribute set with `ROW_NUMBER()`. This removes 3 rows from 4,248 — worth checking, but duplication is not a real problem in this dataset.
3. **Standardize** text: trim whitespace, collapse Crypto / Crypto Currency variants into one label, strip trailing periods from country names.
4. **Convert blanks to `NULL`** across every column. This must precede step 6.
5. **Backfill missing industries** from other rows of the same company via a self-join (affects Appsmith and Eyeo).
6. **Convert types.** Dates parse with `STR_TO_DATE(..., '%m/%d/%Y')` — all 4,248 parse cleanly. Headcounts arrive as `24.0`, `80.0`, so they are rounded through `DECIMAL` before the `INT` cast to avoid truncation warnings.
7. **Index** on date, company, and industry.
8. **Validate**: row count, NULL counts, and a check that no headcount equals zero — the canary for the blank-to-integer bug.

## Analysis

`02_eda.sql` covers:

- Totals by company, industry, country, funding stage, and year
- Monthly totals with a running cumulative sum (`SUM() OVER (ORDER BY month)`)
- Top 5 companies per year, ranked with `DENSE_RANK()` over a partitioned CTE
- Complete shutdowns, identified by a 100% layoff percentage

## Running it

Requires MySQL 8.0+ (window functions and CTEs).

```sql
CREATE DATABASE world_layoffs;
```

Import `data/layoffs_2025.csv` into a table named `layoffs_2025`, then run in order:

```
00_setup.sql          -- creates layoffs_staging from layoffs_2025
01_data_cleaning.sql  -- cleaning, NULL handling, type conversion
02_eda.sql            -- analysis queries
```

## Project structure

```
├── data/
│   └── layoffs_2025.csv     # Source data, 4,248 rows
├── 00_setup.sql             # Staging table creation
├── 01_data_cleaning.sql     # Cleaning and type conversion
├── 02_eda.sql               # Analysis
└── README.md
```

## Limitations

- **Reporting bias.** These are publicly reported layoffs. Smaller companies and non-US markets are almost certainly underrepresented, so country comparisons reflect reporting coverage as much as reality.
- **Headcount coverage is partial.** 44% of events report no headcount, so every total is a floor, not a true figure.
- **No industry normalization beyond Crypto.** Labels like "Other" absorb 85,035 layoffs and are not broken down.
- **No company-size denominator.** A 500-person layoff means something different at Amazon than at a 600-person startup; without headcount data, proportional impact cannot be measured except through the percentage column.
- **Analysis is descriptive.** No statistical testing of whether observed differences between years or industries are meaningful.

## Tech stack

MySQL 8 · Window functions · CTEs · `DENSE_RANK` · Self-joins

---

Built by [Nistha Patel](https://github.com/pnistha11)
