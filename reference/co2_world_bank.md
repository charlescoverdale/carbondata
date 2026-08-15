# World Bank Carbon Pricing Dashboard

Reads the World Bank Carbon Pricing Dashboard Excel file, which covers
70+ carbon pricing initiatives worldwide (carbon taxes and emissions
trading systems) with price, coverage, and revenue data.

## Usage

``` r
co2_world_bank(path = NULL, sheet = 1L, refresh = FALSE)
```

## Arguments

- path:

  Optional path to a locally downloaded dashboard `.xlsx` file. When
  supplied, no network request is made.

- sheet:

  Sheet to read. Default `1`. The workbook carries several sheets; pass
  a name or number to read another.

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame.

## Details

**Manual download may be required.** Since 2026 the dashboard host
rejects non-browser HTTP clients (every request returns HTTP 403,
regardless of user agent), so this function often cannot fetch the file
for you. When the automatic download fails it reports the direct file
URL: download that in a browser and pass the local path via `path`. The
file is republished roughly twice a year, so a manual copy stays current
for months.

## See also

Other aggregators:
[`co2_ecp_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_ecp_prices.md),
[`co2_icap_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_prices.md),
[`co2_icap_systems()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_systems.md),
[`co2_rff_pricing()`](https://charlescoverdale.github.io/carbondata/reference/co2_rff_pricing.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
wb <- try(co2_world_bank(), silent = TRUE)
#> ℹ Resolving latest World Bank Carbon Pricing file...
#> ℹ Downloading Download_data_May_2026.xlsx...
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
