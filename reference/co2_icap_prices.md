# ICAP Allowance Price Explorer

Fetches allowance prices across 20+ Emissions Trading Systems from the
International Carbon Action Partnership (ICAP) Allowance Price Explorer.
Covers EU ETS, UK ETS, California, RGGI, New Zealand, Korea, and other
jurisdictions with auction and secondary-market prices where available.

## Usage

``` r
co2_icap_prices(jurisdiction = NULL, refresh = FALSE)
```

## Arguments

- jurisdiction:

  Optional character vector. Filter by jurisdiction name (e.g.
  `c("Regional Greenhouse Gas Initiative", "EU ETS")`). When `NULL`,
  returns all.

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame with `date`, `jurisdiction`, `market_type` (`"primary"`
auction or `"secondary"`), `price`, and `currency`.

## See also

Other aggregators:
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
