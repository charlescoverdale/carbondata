# EU ETS compliance status and cumulative surrendered units

Returns cumulative total surrendered allowances per installation,
compliance code, and account closure date. Per-year surrender events
require the EUTL transaction log ZIP, which is deferred to v0.2.0
because it is ~1.5 GB uncompressed and requires LZMA extraction.

## Usage

``` r
co2_euets_surrendered(country = NULL, file_year = NULL, refresh = FALSE)
```

## Arguments

- country:

  Optional two-letter registry codes.

- file_year:

  Publication year of the compliance file. Default is the latest in the
  package.

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame with `country`, `installation_id`, `installation_name`,
`compliance_code`, `compliance_status`, `total_verified_emissions`,
`total_surrendered_allowances`, `year_of_first_emissions`,
`year_of_last_emissions`, `account_closure`.

## See also

Other EU ETS:
[`co2_euets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_allocations.md),
[`co2_euets_emissions()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_emissions.md),
[`co2_euets_files()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_files.md),
[`co2_euets_installations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_installations.md),
[`co2_euets_price()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_price.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
comp <- co2_euets_surrendered(country = "FR")
#> ℹ Downloading DG CLIMA compliance file for 2024...
options(op)
# }
```
