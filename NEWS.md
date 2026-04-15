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
