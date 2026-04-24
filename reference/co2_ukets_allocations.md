# UK ETS free allocations

Fetches the UK ETS free-allocation table for stationary installations
(OHA) published by DESNZ on GOV.UK. Filename includes a media GUID that
changes when DESNZ republishes, so the package scrapes the stable
publications landing page.

## Usage

``` r
co2_ukets_allocations(sector = c("installations", "aviation"), refresh = FALSE)
```

## Arguments

- sector:

  Character. `"installations"` (default) for stationary installations,
  `"aviation"` for aviation allocations.

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame.

## See also

Other compliance markets:
[`co2_california_caps()`](https://charlescoverdale.github.io/carbondata/reference/co2_california_caps.md),
[`co2_california_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_california_prices.md),
[`co2_rggi_allowances()`](https://charlescoverdale.github.io/carbondata/reference/co2_rggi_allowances.md),
[`co2_rggi_state_proceeds()`](https://charlescoverdale.github.io/carbondata/reference/co2_rggi_state_proceeds.md),
[`co2_ukets()`](https://charlescoverdale.github.io/carbondata/reference/co2_ukets.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
alloc <- co2_ukets_allocations()
#> ℹ Resolving UK ETS installations allocation URL...
#> ℹ Downloading uk-ets-allocation-table-april-2026.xlsx...
#> New names:
#> • `` -> `...1`
#> • `` -> `...2`
#> • `` -> `...3`
#> • `` -> `...4`
options(op)
# }
```
