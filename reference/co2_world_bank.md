# World Bank Carbon Pricing Dashboard

Fetches the World Bank Carbon Pricing Dashboard Excel file, which covers
70+ carbon pricing initiatives worldwide (carbon taxes + ETS) with
price, coverage, and revenue data.

## Usage

``` r
co2_world_bank(refresh = FALSE)
```

## Arguments

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame.

## Details

The World Bank publishes a dated file every 6-12 months. This function
scrapes the landing page to find the latest release.

## See also

Other aggregators:
[`co2_icap_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_prices.md),
[`co2_rff_pricing()`](https://charlescoverdale.github.io/carbondata/reference/co2_rff_pricing.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
wb <- co2_world_bank()
#> ℹ Resolving latest World Bank Carbon Pricing file...
#> ℹ Downloading data_08_2025.xlsx...
#> New names:
#> • `` -> `...2`
#> • `` -> `...3`
#> • `` -> `...4`
#> • `` -> `...5`
#> • `` -> `...6`
#> • `` -> `...7`
#> • `` -> `...8`
#> • `` -> `...9`
#> • `` -> `...10`
#> • `` -> `...11`
#> • `` -> `...12`
#> • `` -> `...13`
#> • `` -> `...14`
#> • `` -> `...15`
#> • `` -> `...16`
#> • `` -> `...17`
#> • `` -> `...18`
#> • `` -> `...19`
#> • `` -> `...20`
#> • `` -> `...21`
#> • `` -> `...22`
#> • `` -> `...23`
#> • `` -> `...24`
#> • `` -> `...25`
#> • `` -> `...26`
#> • `` -> `...27`
#> • `` -> `...28`
#> • `` -> `...29`
#> • `` -> `...30`
#> • `` -> `...31`
#> • `` -> `...32`
#> • `` -> `...33`
#> • `` -> `...34`
#> • `` -> `...35`
#> • `` -> `...36`
#> • `` -> `...37`
#> • `` -> `...38`
#> • `` -> `...39`
#> • `` -> `...40`
#> • `` -> `...41`
#> • `` -> `...42`
#> • `` -> `...43`
#> • `` -> `...44`
options(op)
# }
```
