# carbondata 0.2.0

Upstream repair release. Six data sources changed their URLs, file
layouts, or access terms between April and August 2026, and seven code
paths were returning wrong or empty data without raising an error.
Every source was re-tested against its live endpoint on 2 August 2026,
and a weekly canary now watches them.

## Silently wrong results (fixed)

* `co2_euets_emissions()` and `co2_euets_allocations()` gain a `scheme`
  argument and a `scheme` column. From compliance year 2024 DG CLIMA
  publishes the new EU ETS2 (buildings, road transport, small industry)
  in the same file as ETS1 installations, as one aggregate account per
  member state carrying activity code 60. These 25 accounts added
  981 Mt to the 2024 file, about 45% of the reported total, so any
  country-year sum roughly doubled. The default is now `"ets1"`, which
  is what the function returned before ETS2 existed. Pass
  `scheme = "ets2"` or `"all"` for the rest. Only compliance year 2024
  carries ETS2 emissions so far.
* `co2_vrod()` read sheet 1, which is now a "READ FIRST" cover sheet,
  and returned a 98-row single-column frame of prose instead of the
  project register. It now reads the `PROJECTS` sheet (11,468 projects,
  170 columns), locates the header row, and takes a `sheet` argument.
  It also picks the newest release by the date in the filename rather
  than lexically, which had selected the 2021 file because `v4` sorts
  above `v2026`.
* `co2_vrod()` and `co2_ukets()` now guess column types from the whole
  sheet. Several VROD columns stay blank well past readxl's default
  1000-row window and only fill in later, so they were typed as logical
  and every later value was discarded: 9 columns and 13,156 values in
  the 2026-06 release, including all 3,737 project registration dates
  and the project owner field.
* `co2_euets_surrendered()` returned zero rows for older compliance
  files. Their header sits below a preamble (row 11 in the 2015 file)
  rather than on row 1, so every identifier parsed as `NA` and the
  country filter dropped everything. The header row is now located, and
  the identifier columns are required, so a layout change errors rather
  than returning an empty frame.
* `co2_icap_prices()` excludes ICAP's "(download)" copies of systems by
  default. ICAP publishes a second entry for several systems carrying
  the same prices under a `(download)` suffix, so asking for one system
  returned it twice, duplicating it in any chart or average. Pass
  `include_download = TRUE` to keep them.
* `co2_euets_installations()` returned zero rows for any `country`
  filter, because a banner row above the header meant no column matched
  and the identifiers came back as `NA`. It now finds the header row.
  The function also warns that DG CLIMA's only bulk registry file is a
  snapshot dated 28 August 2012, which no amount of parsing fixes.
* `co2_icap_prices(jurisdiction = ...)` matched exactly against names
  that ICAP spells out in full and pads with a trailing space, so the
  documented `"EU ETS"` example returned an empty data frame. Names are
  now trimmed, short aliases (`"EU ETS"`, `"RGGI"`, `"UK ETS"`, and
  others) resolve to the official names, and an unmatched name errors
  with the list of valid ones instead of returning nothing.

## Sources repaired

* `co2_euets_emissions()` and `co2_euets_allocations()` work again. DG
  CLIMA added two banner rows above the header of the `data` sheet; the
  parser now locates the header row rather than assuming it is first.
  A latent bug that assumed the emissions and allocation blocks had
  equal row counts (they differ, allocations start a year later) is
  fixed by joining on installation and year.
* `co2_ukets()` works again. The registry moved the compliance report
  from section 4 to section 5 and renamed it, and sheet 1 of the new
  workbook is an empty "Information" sheet. Both sections are now
  tried, the filename match is looser, and the `Data` sheet is read.
* `co2_ukets_allocations()` works again. DESNZ dropped the month from
  the filename (`...-table-march-2025.xlsx` became
  `...-table-2026.xlsx`), which the old pattern required.
* `co2_rff_pricing()` works again, reading the `v2025.0.0` tag. The
  World Carbon Pricing Database stopped distributing through GitHub on
  30 May 2026 and stripped the data from the default branch; new
  releases sit behind an emailed token. The `version` default changed
  from `"v2026.1"` to `"v2025.0.0"`, the last openly published snapshot.
* `co2_offsets_db()` walks back up to 180 days (was 7) and probes every
  day rather than stepping weekly past isolated snapshots. CarbonPlan's
  daily publishing became irregular during 2026 and the last snapshot
  seen is 1 June 2026, so the function warns when the newest available
  snapshot is more than a fortnight old.

## Known-unavailable sources

* `co2_world_bank()` gains a `path` argument. The dashboard host began
  rejecting non-browser clients in 2026: every programmatic request
  returns HTTP 403 regardless of user agent, so the file cannot be
  fetched automatically. Download it in a browser and pass the local
  path. The function reports the direct URL when the fetch fails, and
  the `/about` page it used to scrape is now `/about-us`.

## New

* `co2_ecp_prices()` reads the emissions-weighted carbon price dataset
  published alongside WCPD at worldcarbonpricing.org. These endpoints
  are open and updated with each release, making this the live route to
  World Carbon Pricing Database derived data now that the GitHub
  distribution has stopped. Covers prices by jurisdiction and sector
  plus coverage shares by jurisdiction and sector. The publisher's
  `region` endpoint is accepted but currently has no data file behind
  it for any gas, and says so rather than failing obscurely.
* `co2_icap_systems()` lists the ICAP systems with date ranges and
  observation counts, so the exact `jurisdiction` names are
  discoverable.
* Column names coming from published spreadsheets have their internal
  whitespace collapsed, so a header that wraps across two lines in the
  sheet no longer arrives with the line break embedded in the name.
  VROD shipped a column called `"Total Credits \r\nIssued"`, which is
  now `"Total Credits Issued"`.
* `llms.txt` and `llms-full.txt` are generated from the package's own
  Rd files by `inst/tools/build-llms-txt.R`. They were hand-maintained
  and had drifted, advertising a stale version, old signatures, and
  none of the new functions.
* An `endpoint-canary` GitHub Actions workflow exercises every live
  source weekly and opens an issue when one breaks. Empty results count
  as failures, since that is how the VROD and installations bugs hid.
  The script is at `inst/canary/check-endpoints.R` and runs locally.

## Other changes

* EU ETS file UUIDs are scraped from the DG CLIMA Union Registry page
  at runtime, with the bundled list as an offline fallback, so new
  annual releases no longer need a package update to become visible.
  `co2_euets_files()` consequently lists far more vintages, and all of
  them now parse: verified emissions back to 2015 and compliance back
  to 2012. Making that work meant handling three layout differences
  between vintages, namely a data sheet named after the year rather
  than `data` (2021), a Read Me preamble inside the data sheet pushing
  the header to about row 21 (2022-2024), and allocation columns
  spelled `ALLOCATED_` rather than `ALLOCATION_` (2016 and earlier).
  As a cross-check, German 2015 emissions now read as 464.7 Mt from
  every file vintage between 2016 and 2025.
* A failed download no longer poisons the cache. `httr2` writes the
  response body to the destination before raising on an HTTP error, so
  a 403 or 404 left the error page sitting in the cache and every later
  call served that instead of retrying. Downloads now land in a
  temporary file and are moved into place only on success.
* A successful status code carrying an empty body is now treated as a
  failed download rather than a valid one. Some publishers sit behind a
  CDN that answers automated clients with an empty 200 instead of a 403,
  and the zero-byte file was being cached: the next call saw a cached
  copy, skipped the fetch, and failed in the parser with `no lines
  available in input`, which points at neither the source nor the
  network. The download now aborts naming the URL and the status.
* Downloads accept a cache age limit, applied to the ICAP JSON (1 day)
  and the current-year EEX auction report (1 day). Previously a cached
  copy of a file that updates in place under a stable name was served
  indefinitely, so a report downloaded in January still looked current
  in August.
* `co2_icap_prices()` builds its result by column instead of row-binding
  about 45,000 single-row data frames, cutting a call from roughly 15
  seconds to under 1.
* Internal column lookup can now be marked required, so a layout change
  aborts with the columns it did find instead of filling `NA`.

# carbondata 0.1.1

CRAN policy compliance pass. No functional API changes.

* Converted 14 of 17 `\dontrun{}` roxygen examples to `\donttest{}`.
  These examples wrap public, unauthenticated data fetches from
  'UK ETS', 'RGGI', California Cap-and-Trade, 'ICAP', World Bank,
  'RFF', Berkeley VROD, and 'CarbonPlan OffsetsDB'. Each converted
  example now also sets `options(carbondata.cache_dir = tempdir())`
  around the call and restores the prior value afterwards, so
  running the example on CRAN does not write to the user's home
  filespace.
* `co2_offsets_db()` example now guards the `arrow::read_parquet()`
  call with `requireNamespace("arrow", quietly = TRUE)` so the
  example does not error when `arrow` (in Suggests) is not
  installed.
* Three `\dontrun{}` remain:
  - `co2_euets_emissions()` and `co2_euets_allocations()`: DG CLIMA
    wide-format file schema drifted in 2026, so these functions
    currently abort. Marked `\dontrun{}` with a comment pending a
    parser update.
  - `co2_cad_trust()`: placeholder that always aborts (CAD Trust
    has no unauthenticated public API).

# carbondata 0.1.0

* Initial CRAN release.

## EU Emissions Trading System (5 functions)

* `co2_euets_emissions()` fetches verified greenhouse-gas emissions
  by installation and year from the European Environment Agency.
* `co2_euets_allocations()` fetches free allowance allocations.
* `co2_euets_surrendered()` fetches surrendered units per
  installation per year.
* `co2_euets_price()` fetches EUA auction settlement prices from
  EEX public reports.
* `co2_euets_installations()` returns the EU ETS installation
  registry.

## Other compliance markets (3 functions)

* `co2_ukets()` fetches UK ETS prices, verified emissions, and
  allocations.
* `co2_rggi()` fetches RGGI auction prices, quarterly emissions, and
  allowance distribution from the COATS system.
* `co2_california()` fetches California Cap-and-Trade auction
  settlement prices, emissions, and auction volumes.

## Cross-market aggregators (3 functions)

* `co2_icap_prices()` fetches the ICAP Allowance Price Explorer
  dataset covering 20+ ETS jurisdictions globally.
* `co2_world_bank()` fetches the World Bank Carbon Pricing Dashboard
  (carbon taxes + ETS, 70+ initiatives).
* `co2_rff_pricing()` fetches the RFF World Carbon Pricing Database
  (Dolphin, Pollitt, Newbery 2020).

## Voluntary markets (3 functions)

* `co2_vrod()` fetches the Berkeley Voluntary Registry Offsets
  Database aggregating Verra, Gold Standard, ACR, CAR, and
  ART TREES.
* `co2_offsets_db()` queries the CarbonPlan OffsetsDB REST API.
* `co2_cad_trust()` queries the Climate Action Data Trust (CAD
  Trust) API for Article 6-aligned carbon credit metadata.

## Helpers (3 functions)

* `co2_markets()` lists all supported markets with coverage
  metadata.
* `co2_clear_cache()` empties the local download cache.
* `co2_cache_info()` reports what is cached and how much space it
  uses.

## Deferred to v0.2.0

* New Zealand ETS, Korea ETS, China national and pilot ETS
* Direct Verra / Gold Standard / Puro.earth registry scraping
* Rating provider integrations (Sylvera, BeZero, MSCI)
* Intraday carbon prices
