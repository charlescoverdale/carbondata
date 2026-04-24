# Changelog

## carbondata 0.1.1

CRAN policy compliance pass. No functional API changes.

- Converted 14 of 17 `\dontrun{}` roxygen examples to `\donttest{}`.
  These examples wrap public, unauthenticated data fetches from ‘UK
  ETS’, ‘RGGI’, California Cap-and-Trade, ‘ICAP’, World Bank, ‘RFF’,
  Berkeley VROD, and ‘CarbonPlan OffsetsDB’. Each converted example now
  also sets `options(carbondata.cache_dir = tempdir())` around the call
  and restores the prior value afterwards, so running the example on
  CRAN does not write to the user’s home filespace.
- [`co2_offsets_db()`](https://charlescoverdale.github.io/carbondata/reference/co2_offsets_db.md)
  example now guards the
  [`arrow::read_parquet()`](https://rdrr.io/pkg/arrow/man/read_parquet.html)
  call with
  [`requireNamespace("arrow", quietly = TRUE)`](https://rdrr.io/r/base/ns-load.html)
  so the example does not error when `arrow` (in Suggests) is not
  installed.
- Three `\dontrun{}` remain:
  - [`co2_euets_emissions()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_emissions.md)
    and
    [`co2_euets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_allocations.md):
    DG CLIMA wide-format file schema drifted in 2026, so these functions
    currently abort. Marked `\dontrun{}` with a comment pending a parser
    update.
  - [`co2_cad_trust()`](https://charlescoverdale.github.io/carbondata/reference/co2_cad_trust.md):
    placeholder that always aborts (CAD Trust has no unauthenticated
    public API).

## carbondata 0.1.0

CRAN release: 2026-04-21

- Initial CRAN release.

### EU Emissions Trading System (5 functions)

- [`co2_euets_emissions()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_emissions.md)
  fetches verified greenhouse-gas emissions by installation and year
  from the European Environment Agency.
- [`co2_euets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_allocations.md)
  fetches free allowance allocations.
- [`co2_euets_surrendered()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_surrendered.md)
  fetches surrendered units per installation per year.
- [`co2_euets_price()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_price.md)
  fetches EUA auction settlement prices from EEX public reports.
- [`co2_euets_installations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_installations.md)
  returns the EU ETS installation registry.

### Other compliance markets (3 functions)

- [`co2_ukets()`](https://charlescoverdale.github.io/carbondata/reference/co2_ukets.md)
  fetches UK ETS prices, verified emissions, and allocations.
- `co2_rggi()` fetches RGGI auction prices, quarterly emissions, and
  allowance distribution from the COATS system.
- `co2_california()` fetches California Cap-and-Trade auction settlement
  prices, emissions, and auction volumes.

### Cross-market aggregators (3 functions)

- [`co2_icap_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_prices.md)
  fetches the ICAP Allowance Price Explorer dataset covering 20+ ETS
  jurisdictions globally.
- [`co2_world_bank()`](https://charlescoverdale.github.io/carbondata/reference/co2_world_bank.md)
  fetches the World Bank Carbon Pricing Dashboard (carbon taxes + ETS,
  70+ initiatives).
- [`co2_rff_pricing()`](https://charlescoverdale.github.io/carbondata/reference/co2_rff_pricing.md)
  fetches the RFF World Carbon Pricing Database (Dolphin, Pollitt,
  Newbery 2020).

### Voluntary markets (3 functions)

- [`co2_vrod()`](https://charlescoverdale.github.io/carbondata/reference/co2_vrod.md)
  fetches the Berkeley Voluntary Registry Offsets Database aggregating
  Verra, Gold Standard, ACR, CAR, and ART TREES.
- [`co2_offsets_db()`](https://charlescoverdale.github.io/carbondata/reference/co2_offsets_db.md)
  queries the CarbonPlan OffsetsDB REST API.
- [`co2_cad_trust()`](https://charlescoverdale.github.io/carbondata/reference/co2_cad_trust.md)
  queries the Climate Action Data Trust (CAD Trust) API for Article
  6-aligned carbon credit metadata.

### Helpers (3 functions)

- [`co2_markets()`](https://charlescoverdale.github.io/carbondata/reference/co2_markets.md)
  lists all supported markets with coverage metadata.
- [`co2_clear_cache()`](https://charlescoverdale.github.io/carbondata/reference/co2_clear_cache.md)
  empties the local download cache.
- [`co2_cache_info()`](https://charlescoverdale.github.io/carbondata/reference/co2_cache_info.md)
  reports what is cached and how much space it uses.

### Deferred to v0.2.0

- New Zealand ETS, Korea ETS, China national and pilot ETS
- Direct Verra / Gold Standard / Puro.earth registry scraping
- Rating provider integrations (Sylvera, BeZero, MSCI)
- Intraday carbon prices
