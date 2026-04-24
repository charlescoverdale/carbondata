# UK ETS verified emissions and surrenders

Fetches the UK Emissions Trading Scheme Section 4 compliance report
(verified emissions and allowance surrenders per account per scheme
year), published annually by the UK Emissions Trading Registry after the
30 April reconciliation deadline.

## Usage

``` r
co2_ukets(refresh = FALSE)
```

## Arguments

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame with one row per account-year.

## See also

Other compliance markets:
[`co2_california_caps()`](https://charlescoverdale.github.io/carbondata/reference/co2_california_caps.md),
[`co2_california_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_california_prices.md),
[`co2_rggi_allowances()`](https://charlescoverdale.github.io/carbondata/reference/co2_rggi_allowances.md),
[`co2_rggi_state_proceeds()`](https://charlescoverdale.github.io/carbondata/reference/co2_rggi_state_proceeds.md),
[`co2_ukets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_ukets_allocations.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
uk <- co2_ukets()
#> ℹ Resolving UK ETS Section 4 compliance report URL...
#> ℹ Downloading 20250611_Compliance_Report_Emissions_and_Surrenders.xlsx...
options(op)
# }
```
