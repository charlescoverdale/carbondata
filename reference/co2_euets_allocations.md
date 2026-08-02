# EU ETS free allowance allocations

Returns free allowance allocations per installation per year. Same
source file as
[`co2_euets_emissions()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_emissions.md).

## Usage

``` r
co2_euets_allocations(
  country = NULL,
  year = NULL,
  file_year = NULL,
  scheme = c("ets1", "ets2", "all"),
  refresh = FALSE
)
```

## Arguments

- country:

  Optional character vector of two-letter registry codes to filter (e.g.
  `c("DE", "FR", "PL")`).

- year:

  Optional integer vector of emissions years. When `NULL`, returns all
  years in the latest published file. Note that the file year (e.g.
  "2025") refers to publication year; emissions data covers calendar
  years up to publication year -1.

- file_year:

  Publication year of the DG CLIMA file to use. Default is the latest
  year available in the package (see
  [`co2_euets_files()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_files.md)).

- scheme:

  Which trading system to return. `"ets1"` (default) is the original EU
  ETS: power, industry, and aviation installations. `"ets2"` is the
  separate buildings, road transport, and small industry system that
  began reporting for compliance year 2024, which DG CLIMA publishes in
  the same file as one aggregate account per member state. `"all"`
  returns both, and is rarely what you want: the two are different
  systems on different accounting bases, so summing them together
  double-counts (ETS2 accounts added 981 Mt to the 2024 file, about 45%
  of the reported total).

- refresh:

  Logical. Re-download? Default `FALSE`.

## Value

A data frame with `country`, `installation_id`, `installation_name`,
`activity`, `scheme`, `year`, `allocation_eua`.

## See also

Other EU ETS:
[`co2_euets_emissions()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_emissions.md),
[`co2_euets_files()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_files.md),
[`co2_euets_installations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_installations.md),
[`co2_euets_price()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_price.md),
[`co2_euets_surrendered()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_surrendered.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
alloc <- co2_euets_allocations(country = "DE")
#> ℹ Downloading DG CLIMA verified_emissions file for 2025...
options(op)
# }
```
