# RGGI allowance distribution by state and year

Fetches the Regional Greenhouse Gas Initiative (RGGI) annual CO2
allowance distribution table from the public RGGI website. Covers 11
participating US states from 2009 onwards.

## Usage

``` r
co2_rggi_allowances(year = NULL, refresh = FALSE)
```

## Arguments

- year:

  Integer year (2009-present). Default is the current year.

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame of allowance distribution by state.

## Details

Auction clearing prices are NOT returned here because RGGI publishes
them only as per-auction PDFs (no CSV aggregation exists). For RGGI
prices, use
[`co2_icap_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_prices.md)
with `jurisdiction = "Regional Greenhouse Gas Initiative"`.

## See also

Other compliance markets:
[`co2_california_caps()`](https://charlescoverdale.github.io/carbondata/reference/co2_california_caps.md),
[`co2_california_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_california_prices.md),
[`co2_rggi_state_proceeds()`](https://charlescoverdale.github.io/carbondata/reference/co2_rggi_state_proceeds.md),
[`co2_ukets()`](https://charlescoverdale.github.io/carbondata/reference/co2_ukets.md),
[`co2_ukets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_ukets_allocations.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
a <- co2_rggi_allowances(year = 2026)
#> ℹ Downloading RGGI allowance distribution for 2026...
#> New names:
#> • `` -> `...2`
#> • `` -> `...3`
#> • `` -> `...4`
#> • `` -> `...5`
#> • `` -> `...6`
#> • `` -> `...7`
#> • `` -> `...8`
#> • `` -> `...9`
options(op)
# }
```
