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
