# California Cap-and-Trade auction settlement prices

Fetches the California Air Resources Board auction settlement price time
series, updated quarterly after each joint California- Quebec auction.

## Usage

``` r
co2_california_prices(refresh = FALSE)
```

## Arguments

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame with `joint_auction`, `quarter`, `settlement_price_usd`,
`reserve_price_usd`.

## See also

Other compliance markets:
[`co2_california_caps()`](https://charlescoverdale.github.io/carbondata/reference/co2_california_caps.md),
[`co2_rggi_allowances()`](https://charlescoverdale.github.io/carbondata/reference/co2_rggi_allowances.md),
[`co2_rggi_state_proceeds()`](https://charlescoverdale.github.io/carbondata/reference/co2_rggi_state_proceeds.md),
[`co2_ukets()`](https://charlescoverdale.github.io/carbondata/reference/co2_ukets.md),
[`co2_ukets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_ukets_allocations.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
prices <- co2_california_prices()
#> ℹ Downloading California Cap-and-Trade auction prices...
options(op)
# }
```
