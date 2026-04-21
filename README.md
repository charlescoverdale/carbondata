# carbondata

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/carbondata)](https://CRAN.R-project.org/package=carbondata) [![CRAN downloads](https://cranlogs.r-pkg.org/badges/carbondata)](https://cran.r-project.org/package=carbondata) [![Total Downloads](https://cranlogs.r-pkg.org/badges/grand-total/carbondata)](https://CRAN.R-project.org/package=carbondata) [![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

Access carbon market data in R. Emissions trading system prices and verified emissions, voluntary carbon credit registrations and retirements, and global carbon pricing data from compliance and voluntary markets worldwide.


## Carbon markets now price 12 billion tonnes a year. The data is a mess.

Carbon pricing has gone from a niche instrument to a systemic part of global climate policy. Around 12 billion tonnes of CO2-equivalent are now covered by some form of carbon price, about 24% of global emissions. The EU ETS alone prices ~40% of EU emissions and generates roughly EUR 40 billion a year in auction revenue. Voluntary carbon markets have issued over 2 billion credits since 1996, and Article 6 of the Paris Agreement is bringing a new wave of international carbon trading online.

The catch is that the data is scattered across dozens of jurisdictions, agencies, and registries, each with its own format, access pattern, and quirks:

- **EU ETS** publishes verified emissions and allocations via the DG CLIMA Union Registry as XLSX files with year-specific UUIDs, and auction prices via EEX as per-year XLSX reports
- **UK Emissions Trading Registry** publishes compliance and allocation reports as XLSX, with date-stamped filenames that change on every republication
- **RGGI** publishes per-state allowance distributions as XLSX on a stable year-parameterised URL, but clearing prices only as per-auction PDFs
- **California Air Resources Board** serves auction prices and caps as stable CSVs from `ww2.arb.ca.gov`
- **ICAP Allowance Price Explorer** exposes cross-ETS prices via an undocumented but stable JSON endpoint
- **World Bank Carbon Pricing Dashboard** publishes an XLSX twice a year, with a filename that encodes the release date
- **RFF World Carbon Pricing Database** lives on GitHub as per-country CSVs in version-stamped folders
- **Berkeley VROD** aggregates five voluntary registries into a bimonthly XLSX release
- **CarbonPlan OffsetsDB** maintains daily parquet snapshots of voluntary credits in a public S3 bucket (the REST API was deprecated in 2026)

`carbondata` wraps the stable, free, API-accessible sources through a consistent R interface, handling URL resolution, caching, and schema normalisation so you can get on with the analysis.


## Installation

```r
install.packages("carbondata")

# Or install the development version from GitHub
# install.packages("devtools")
devtools::install_github("charlescoverdale/carbondata")
```


## Data sources covered

| Source | Coverage |
|---|---|
| **EU Emissions Trading System** (via EEA) | Verified emissions, free allocations, surrendered units, installation registry, EUA prices (2005-present) |
| **UK Emissions Trading Scheme** | UKA auction prices, verified emissions, allocations (2021-present) |
| **Regional Greenhouse Gas Initiative** | Auction prices, emissions, allowance distribution (2009-present, US Northeast) |
| **California Cap-and-Trade** | Auction settlement prices, emissions, auction volumes (2013-present) |
| **ICAP Allowance Price Explorer** | Curated cross-ETS prices (20+ jurisdictions globally) |
| **World Bank Carbon Pricing Dashboard** | Global carbon pricing: taxes + ETS (70+ initiatives) |
| **RFF World Carbon Pricing Database** | Subnational historical coverage 1990-2020 (Dolphin, Pollitt, Newbery 2020) |
| **Berkeley VROD** | Voluntary market aggregator (Verra, Gold Standard, ACR, CAR, ART TREES) |
| **CarbonPlan OffsetsDB** | Voluntary market aggregator with REST API |
| **Climate Action Data Trust** | Article 6-aligned harmonised registry API |

All sources are free. None require registration for v0.1.0 functionality.


## Quick start

```r
library(carbondata)

# All supported markets at a glance
co2_markets()

# Latest EU ETS auction prices
prices <- co2_euets_price(from = "2024-01-01")
head(prices)

# Verified emissions for large German installations, 2022
emissions <- co2_euets_emissions(country = "DE", year = 2022)

# Cross-market price comparison
icap <- co2_icap_prices(jurisdiction = c("EU ETS", "UK ETS", "RGGI"))

# Voluntary forestry projects registered with Verra
verra_forestry <- co2_vrod(registry = "Verra", project_type = "Forestry")
```


## Example: the cross-market price chart

One chart, four compliance markets, 20 years of data.

```r
library(carbondata)

icap <- co2_icap_prices(
  jurisdiction = c("EU ETS", "UK ETS", "RGGI", "California"),
  from = "2005-01-01"
)

plot(icap$date, icap$price_usd, col = factor(icap$jurisdiction),
     xlab = "", ylab = "USD / tCO2e", pch = 20)
legend("topleft", legend = levels(factor(icap$jurisdiction)),
       col = seq_len(nlevels(factor(icap$jurisdiction))), pch = 20)
```


## Example: voluntary vs compliance divergence

Compliance markets (EU ETS) trade around USD 70/tCO2. Nature-based voluntary credits trade around USD 5/tCO2. Why the gap?

```r
# EU ETS average 2024 price
eu <- co2_euets_price(from = "2024-01-01", to = "2024-12-31")
mean(eu$price_eur, na.rm = TRUE)
#> [1] ~65

# Average Verra credit issuance across forestry projects
vrod <- co2_vrod(registry = "Verra", project_type = "Forestry")
summary(vrod$total_issuances)
```


## Functions

### EU ETS (EEA / EUTL)

| Function | What it returns |
|---|---|
| `co2_euets_emissions()` | Verified emissions by installation and year |
| `co2_euets_allocations()` | Free allowance allocations |
| `co2_euets_surrendered()` | Surrendered units for compliance |
| `co2_euets_price()` | EUA auction settlement prices |
| `co2_euets_installations()` | Installation registry |

### Other compliance markets

| Function | What it returns |
|---|---|
| `co2_ukets()` | UK ETS prices, emissions, allocations |
| `co2_rggi()` | RGGI prices, emissions, allowance distribution |
| `co2_california()` | California Cap-and-Trade prices, emissions, auctions |

### Cross-market aggregators

| Function | What it returns |
|---|---|
| `co2_icap_prices()` | ICAP Allowance Price Explorer (multi-ETS prices) |
| `co2_world_bank()` | World Bank Carbon Pricing Dashboard |
| `co2_rff_pricing()` | RFF World Carbon Pricing Database |

### Voluntary markets

| Function | What it returns |
|---|---|
| `co2_vrod()` | Berkeley VROD (5 registries aggregated) |
| `co2_offsets_db()` | CarbonPlan OffsetsDB (REST API) |
| `co2_cad_trust()` | Climate Action Data Trust (Article 6-aligned) |

### Helpers

| Function | What it returns |
|---|---|
| `co2_markets()` | Directory of supported markets |
| `co2_clear_cache()` | Empty the local cache |
| `co2_cache_info()` | Show cached files |


## Caching

Downloads are cached to `tools::R_user_dir("carbondata", "cache")` by default. Subsequent calls are instant. Override the location with `options(carbondata.cache_dir = "/path/to/dir")`. Use `co2_clear_cache()` to remove cached files.


## Related packages

| Package | Description |
|---------|-------------|
| [carbonr](https://cran.r-project.org/package=carbonr) | Carbon footprint calculator (activity → tCO2e conversion) |
| [climatekit](https://github.com/charlescoverdale/climatekit) | Climate indices (temperature, precipitation, drought) |
| [readnoaa](https://github.com/charlescoverdale/readnoaa) | NOAA climate and weather data |
| [inflationkit](https://github.com/charlescoverdale/inflationkit) | Inflation analysis |


## Issues

Report bugs or request features at [GitHub Issues](https://github.com/charlescoverdale/carbondata/issues).


## Keywords

carbon markets, emissions trading, EU ETS, UK ETS, RGGI, California Cap-and-Trade, Verra, Gold Standard, ICAP, World Bank carbon pricing, voluntary carbon markets, climate finance, CO2, greenhouse gas, sustainability disclosure, TCFD, CSRD, SFDR, ISSB
