# ICAP Allowance Price Explorer

Fetches allowance prices across 20+ Emissions Trading Systems from the
International Carbon Action Partnership (ICAP) Allowance Price Explorer.
Covers EU ETS, UK ETS, California, RGGI, New Zealand, Korea, and other
jurisdictions with auction and secondary-market prices where available.

## Usage

``` r
co2_icap_prices(jurisdiction = NULL, include_download = FALSE, refresh = FALSE)
```

## Arguments

- jurisdiction:

  Optional character vector. Filter by jurisdiction name. Matching is
  case-insensitive and partial, so `"EU ETS"` matches
  `"European Union Emissions Trading System (from 2019)"`. When `NULL`,
  returns all. Use
  [`co2_icap_systems()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_systems.md)
  to list the exact names.

- include_download:

  Logical. ICAP publishes a second "(download)" copy of several systems
  carrying the same prices as the main series. These are excluded by
  default, because including them duplicates a system in any chart or
  average. Set `TRUE` to keep them.

- refresh:

  Re-download? Default `FALSE`. The cached copy is refreshed
  automatically when it is more than a day old.

## Value

A data frame with `date`, `jurisdiction`, `market_type` (`"primary"`
auction or `"secondary"`), `price`, and `currency`.

## See also

Other aggregators:
[`co2_ecp_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_ecp_prices.md),
[`co2_icap_systems()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_systems.md),
[`co2_rff_pricing()`](https://charlescoverdale.github.io/carbondata/reference/co2_rff_pricing.md),
[`co2_world_bank()`](https://charlescoverdale.github.io/carbondata/reference/co2_world_bank.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
prices <- co2_icap_prices(jurisdiction = "EU ETS")
#> ℹ Downloading ICAP Allowance Price Explorer data...
options(op)
# }
```
