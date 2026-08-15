# California overall emissions caps

Fetches the California Cap-and-Trade program overall cap and allocation
channels, by vintage year.

## Usage

``` r
co2_california_caps(refresh = FALSE)
```

## Arguments

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame.

## See also

Other compliance markets:
[`co2_california_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_california_prices.md),
[`co2_rggi_allowances()`](https://charlescoverdale.github.io/carbondata/reference/co2_rggi_allowances.md),
[`co2_rggi_state_proceeds()`](https://charlescoverdale.github.io/carbondata/reference/co2_rggi_state_proceeds.md),
[`co2_ukets()`](https://charlescoverdale.github.io/carbondata/reference/co2_ukets.md),
[`co2_ukets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_ukets_allocations.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
caps <- co2_california_caps()
#> ℹ Downloading California overall caps...
#> Error in co2_download(url, dest, refresh = refresh): Download of
#> <https://ww2.arb.ca.gov/sites/default/files/2025-06/nc-OverallCaps.csv>
#> returned HTTP 202 with an empty body.
#> ℹ The publisher may be refusing automated clients from this network.
#>   Retry later, or report at
#>   https://github.com/charlescoverdale/carbondata/issues.
options(op)
# }
```
