# RGGI cumulative state proceeds by auction

Fetches cumulative auction proceeds time series for one RGGI state,
indexed by auction number. Derived from the per-state XLSX files on
rggi.org. Combining all states gives the full RGGI auction time series.

## Usage

``` r
co2_rggi_state_proceeds(state, refresh = FALSE)
```

## Arguments

- state:

  Two-letter state code (one of: CT, DE, MA, MD, ME, NH, NJ, NY, RI, VA,
  VT).

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame.

## See also

Other compliance markets:
[`co2_california_caps()`](https://charlescoverdale.github.io/carbondata/reference/co2_california_caps.md),
[`co2_california_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_california_prices.md),
[`co2_rggi_allowances()`](https://charlescoverdale.github.io/carbondata/reference/co2_rggi_allowances.md),
[`co2_ukets()`](https://charlescoverdale.github.io/carbondata/reference/co2_ukets.md),
[`co2_ukets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_ukets_allocations.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
ny <- co2_rggi_state_proceeds("NY")
#> ℹ Downloading RGGI NY cumulative proceeds...
options(op)
# }
```
