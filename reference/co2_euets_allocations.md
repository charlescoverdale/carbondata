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

- refresh:

  Logical. Re-download? Default `FALSE`.

## Value

A data frame with `country`, `installation_id`, `year`,
`allocation_eua`.

## See also

Other EU ETS:
[`co2_euets_emissions()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_emissions.md),
[`co2_euets_files()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_files.md),
[`co2_euets_installations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_installations.md),
[`co2_euets_price()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_price.md),
[`co2_euets_surrendered()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_surrendered.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# DG CLIMA file schema drifted in 2026; parser needs updating.
# Tracked at https://github.com/charlescoverdale/carbondata/issues
alloc <- co2_euets_allocations(country = "DE")
} # }
```
