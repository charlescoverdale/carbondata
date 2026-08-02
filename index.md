# carbondata

Access carbon market data in R. Emissions trading system prices and
verified emissions, voluntary carbon credit registrations and
retirements, and global carbon pricing data from compliance and
voluntary markets worldwide.

## Carbon markets now price 12 billion tonnes a year. The data is a mess.

Carbon pricing has gone from a niche instrument to a systemic part of
global climate policy. Around 12 billion tonnes of CO2-equivalent are
now covered by some form of carbon price, about a quarter of global
emissions. On the data this package returns, EU ETS primary auctions
raised EUR 43.2bn across 213 auctions in 2025 at a mean settlement price
of EUR 73.45, the EU ETS covered 1.19 billion tonnes of verified
emissions in 2024, and the voluntary registries have issued 2.65 billion
credits since 1996. Article 6 of the Paris Agreement is bringing a
further wave of international carbon trading online.

The catch is that the data is scattered across dozens of jurisdictions,
agencies, and registries, each with its own format, access pattern, and
quirks:

- **EU ETS** publishes verified emissions and allocations via the DG
  CLIMA Union Registry as XLSX files with year-specific UUIDs, and
  auction prices via EEX as per-year XLSX reports
- **UK Emissions Trading Registry** publishes compliance and allocation
  reports as XLSX, with date-stamped filenames that change on every
  republication
- **RGGI** publishes per-state allowance distributions as XLSX on a
  stable year-parameterised URL, but clearing prices only as per-auction
  PDFs
- **California Air Resources Board** serves auction prices and caps as
  stable CSVs from `ww2.arb.ca.gov`
- **ICAP Allowance Price Explorer** exposes cross-ETS prices via an
  undocumented but stable JSON endpoint
- **World Bank Carbon Pricing Dashboard** publishes an XLSX twice a
  year, with a filename that encodes the release date
- **RFF World Carbon Pricing Database** published per-country CSVs on
  GitHub until May 2026, and now serves current data through its own API
- **Berkeley VROD** aggregates five voluntary registries into a
  bimonthly XLSX release
- **CarbonPlan OffsetsDB** publishes parquet snapshots of voluntary
  credits to a public S3 bucket (the REST API was deprecated in 2026,
  and daily publishing stopped mid-2026)

`carbondata` wraps the stable, free, API-accessible sources through a
consistent R interface, handling URL resolution, caching, and schema
normalisation so you can get on with the analysis.

## Installation

``` r

install.packages("carbondata")

# Or install the development version from GitHub
# install.packages("devtools")
devtools::install_github("charlescoverdale/carbondata")
```

## Data sources covered

| Source | Coverage |
|----|----|
| **EU Emissions Trading System** (via EEA) | Verified emissions, free allocations, surrendered units, installation registry, EUA prices (2005-present) |
| **UK Emissions Trading Scheme** | UKA auction prices, verified emissions, allocations (2021-present) |
| **Regional Greenhouse Gas Initiative** | Auction prices, emissions, allowance distribution (2009-present, US Northeast) |
| **California Cap-and-Trade** | Auction settlement prices, emissions, auction volumes (2013-present) |
| **ICAP Allowance Price Explorer** | Curated cross-ETS prices (20+ jurisdictions globally) |
| **World Bank Carbon Pricing Dashboard** | Global carbon pricing: taxes + ETS (70+ initiatives) |
| **RFF World Carbon Pricing Database** | National historical coverage to 2023 (Dolphin, Pollitt, Newbery 2020) |
| **Emissions-weighted carbon price (ECP)** | Effective carbon prices and coverage by jurisdiction, sector, and region |
| **Berkeley VROD** | Voluntary market aggregator (Verra, Gold Standard, ACR, CAR, ART TREES) |
| **CarbonPlan OffsetsDB** | Voluntary market aggregator, parquet snapshots |

All sources are free. Two need extra steps: the World Bank dashboard
blocks programmatic clients, so
[`co2_world_bank()`](https://charlescoverdale.github.io/carbondata/reference/co2_world_bank.md)
takes a manually downloaded file, and full World Carbon Pricing Database
downloads now need a token requested from the publisher (the derived ECP
data behind
[`co2_ecp_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_ecp_prices.md)
stays open).

## Quick start

``` r

library(carbondata)

# All supported markets at a glance
co2_markets()

# Latest EU ETS auction prices
prices <- co2_euets_price(from = "2024-01-01")
head(prices)

# Verified emissions for German installations, 2022
emissions <- co2_euets_emissions(country = "DE", year = 2022)

# Cross-market price comparison
icap <- co2_icap_prices(jurisdiction = c("EU ETS", "UK ETS", "RGGI"))

# Voluntary offset projects across five registries
vrod <- co2_vrod()
```

## Example: the cross-market price chart

One chart, four compliance markets, two decades of data.

``` r

library(carbondata)

icap <- co2_icap_prices(
  jurisdiction = c("EU ETS", "UK ETS", "RGGI", "California")
)

plot(icap$date, icap$price, col = factor(icap$jurisdiction),
     xlab = "", ylab = "Price per tCO2e (local currency)", pch = 20)
legend("topleft", legend = levels(factor(icap$jurisdiction)),
       col = seq_len(nlevels(factor(icap$jurisdiction))), pch = 20)
```

Short names such as `"EU ETS"` and `"RGGI"` resolve to the full names
ICAP uses. Call
[`co2_icap_systems()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_systems.md)
to see every system with its date range.

## Example: voluntary vs compliance divergence

Compliance allowances trade far above nature-based voluntary credits.
The two datasets make the gap easy to quantify.

``` r

# EU ETS average auction price, 2024
eu <- co2_euets_price(from = "2024-01-01", to = "2024-12-31")
mean(eu$price_eur, na.rm = TRUE)

# Issuances across Verra forestry projects
vrod <- co2_vrod()
forestry <- vrod[vrod$`Voluntary Registry` == "VCS" &
                   vrod$Scope == "Forestry & Land Use", ]
summary(forestry$`Total Credits Issued`)
```

Registry codes are `VCS` (Verra), `GOLD`, `ACR`, `CAR`, `ART`, and
`ISO`. Column names come straight from the workbook, with wrapped
headers flattened: the sheet stores one column as
`"Total Credits \r\nIssued"`, which `carbondata` normalises to
`"Total Credits Issued"`.

## A trap worth knowing about: EU ETS2

From compliance year 2024, DG CLIMA publishes the new EU ETS2
(buildings, road transport, small industry) in the *same file* as the
original ETS1 installations, as one aggregate account per member state.
Those 25 accounts added 981 Mt to the 2024 file, about 45% of the
reported total, so summing the file as published roughly doubles country
totals.

`carbondata` separates them. The default is ETS1, which is what “EU ETS”
has always meant:

``` r

co2_euets_emissions(country = "DE", year = 2024)                   # ETS1 only
co2_euets_emissions(country = "DE", year = 2024, scheme = "ets2")  # ETS2 accounts
co2_euets_emissions(country = "DE", year = 2024, scheme = "all")   # both, do not sum
```

## Functions

### EU ETS (EEA / EUTL)

| Function | What it returns |
|----|----|
| [`co2_euets_emissions()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_emissions.md) | Verified emissions by installation and year |
| [`co2_euets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_allocations.md) | Free allowance allocations |
| [`co2_euets_surrendered()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_surrendered.md) | Surrendered units for compliance |
| [`co2_euets_price()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_price.md) | EUA auction settlement prices |
| [`co2_euets_installations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_installations.md) | Installation registry (2012 snapshot, historical) |
| [`co2_euets_files()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_files.md) | DG CLIMA file vintages available |

### Other compliance markets

| Function | What it returns |
|----|----|
| [`co2_ukets()`](https://charlescoverdale.github.io/carbondata/reference/co2_ukets.md) | UK ETS verified emissions and surrenders |
| [`co2_ukets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_ukets_allocations.md) | UK ETS free allocations (installations or aviation) |
| [`co2_rggi_allowances()`](https://charlescoverdale.github.io/carbondata/reference/co2_rggi_allowances.md) | RGGI allowance distribution by state |
| [`co2_rggi_state_proceeds()`](https://charlescoverdale.github.io/carbondata/reference/co2_rggi_state_proceeds.md) | RGGI cumulative auction proceeds by state |
| [`co2_california_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_california_prices.md) | California Cap-and-Trade auction settlement prices |
| [`co2_california_caps()`](https://charlescoverdale.github.io/carbondata/reference/co2_california_caps.md) | California overall caps by vintage |

### Cross-market aggregators

| Function | What it returns |
|----|----|
| [`co2_icap_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_prices.md) | ICAP Allowance Price Explorer (multi-ETS prices) |
| [`co2_icap_systems()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_systems.md) | ICAP systems with date ranges and observation counts |
| [`co2_world_bank()`](https://charlescoverdale.github.io/carbondata/reference/co2_world_bank.md) | World Bank Carbon Pricing Dashboard (manual download) |
| [`co2_rff_pricing()`](https://charlescoverdale.github.io/carbondata/reference/co2_rff_pricing.md) | RFF World Carbon Pricing Database (frozen at v2025.0.0) |
| [`co2_ecp_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_ecp_prices.md) | Emissions-weighted carbon prices and coverage |

### Voluntary markets

| Function | What it returns |
|----|----|
| [`co2_vrod()`](https://charlescoverdale.github.io/carbondata/reference/co2_vrod.md) | Berkeley VROD (5 registries aggregated) |
| [`co2_offsets_db()`](https://charlescoverdale.github.io/carbondata/reference/co2_offsets_db.md) | CarbonPlan OffsetsDB parquet snapshots |
| [`co2_cad_trust()`](https://charlescoverdale.github.io/carbondata/reference/co2_cad_trust.md) | Climate Action Data Trust (not supported, see below) |

### Helpers

| Function | What it returns |
|----|----|
| [`co2_markets()`](https://charlescoverdale.github.io/carbondata/reference/co2_markets.md) | Directory of supported markets |
| [`co2_clear_cache()`](https://charlescoverdale.github.io/carbondata/reference/co2_clear_cache.md) | Empty the local cache |
| [`co2_cache_info()`](https://charlescoverdale.github.io/carbondata/reference/co2_cache_info.md) | Show cached files |

## Source availability

Carbon market publishers move files without notice, so this package
tracks source health explicitly. As of August 2026:

- **World Bank Carbon Pricing Dashboard**: the host rejects non-browser
  clients (HTTP 403 regardless of user agent). Download the file in a
  browser and pass it:
  `co2_world_bank(path = "~/Downloads/data_08_2025.xlsx")`. The function
  reports the current URL when the automatic fetch fails.
- **RFF World Carbon Pricing Database**: left GitHub on 30 May 2026.
  [`co2_rff_pricing()`](https://charlescoverdale.github.io/carbondata/reference/co2_rff_pricing.md)
  reads the last openly published release, `v2025.0.0`. For newer
  vintages request a token from the publisher, or use
  [`co2_ecp_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_ecp_prices.md),
  which stays open and updates with each release.
- **CarbonPlan OffsetsDB**: daily publishing became irregular during
  2026, with the last snapshot seen on 1 June 2026.
  [`co2_offsets_db()`](https://charlescoverdale.github.io/carbondata/reference/co2_offsets_db.md)
  walks back to find the newest available and warns when it is more than
  a fortnight old.
- **Climate Action Data Trust**: no unauthenticated public API.
  [`co2_cad_trust()`](https://charlescoverdale.github.io/carbondata/reference/co2_cad_trust.md)
  errors with guidance on self-hosting or requesting partnership access.
- **EU ETS installation registry**: DG CLIMA’s only bulk registry file
  is a snapshot dated 28 August 2012.
  [`co2_euets_installations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_installations.md)
  warns on every call. For current installation detail, use the
  identifiers on
  [`co2_euets_emissions()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_emissions.md).

A weekly GitHub Actions canary exercises every source and opens an issue
when one breaks. Run it yourself with:

``` bash
Rscript inst/canary/check-endpoints.R
```

## Caching

Downloads are cached to `tools::R_user_dir("carbondata", "cache")` by
default. Subsequent calls are instant. Override the location with
`options(carbondata.cache_dir = "/path/to/dir")`. Use
[`co2_clear_cache()`](https://charlescoverdale.github.io/carbondata/reference/co2_clear_cache.md)
to remove cached files.

Files that update in place under a stable name (the ICAP price feed, the
current-year EEX auction report) carry a one-day cache limit so a stale
copy is not served indefinitely. Everything else is cached until you
pass `refresh = TRUE`.

## Related packages

| Package | Description |
|----|----|
| [cer](https://github.com/charlescoverdale/cer) | Australian Clean Energy Regulator (ACCUs, Safeguard, NGER) |
| [aemo](https://github.com/charlescoverdale/aemo) | Australian Energy Market Operator (NEM prices, dispatch) |
| [climatekit](https://github.com/charlescoverdale/climatekit) | Climate indices (temperature, precipitation, drought) |
| [readnoaa](https://github.com/charlescoverdale/readnoaa) | NOAA climate and weather data |
| [inflationkit](https://github.com/charlescoverdale/inflationkit) | Inflation analysis (real-terms carbon prices) |
| [carbonr](https://cran.r-project.org/package=carbonr) | Carbon footprint calculator (activity → tCO2e conversion) |

## Issues

Report bugs or request features at [GitHub
Issues](https://github.com/charlescoverdale/carbondata/issues).

## Keywords

carbon markets, emissions trading, EU ETS, UK ETS, RGGI, California
Cap-and-Trade, Verra, Gold Standard, ICAP, World Bank carbon pricing,
voluntary carbon markets, climate finance, CO2, greenhouse gas,
sustainability disclosure, TCFD, CSRD, SFDR, ISSB
