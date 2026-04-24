# EU ETS verified emissions

Fetches annual verified greenhouse-gas emissions for installations
covered by the EU Emissions Trading System, from the DG CLIMA Union
Registry bulk download. Coverage: ~10,000 stationary installations plus
~1,500 aircraft operators across the EU, EEA, and linked Swiss ETS.
Emissions data from 2005 onwards; annual files published each April for
the prior compliance year.

## Usage

``` r
co2_euets_emissions(
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

A data frame with columns `country`, `installation_id`,
`installation_name`, `activity`, `year`, `verified_emissions_tco2e`,
`allocation_eua`.

## See also

Other EU ETS:
[`co2_euets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_allocations.md),
[`co2_euets_files()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_files.md),
[`co2_euets_installations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_installations.md),
[`co2_euets_price()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_price.md),
[`co2_euets_surrendered()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_surrendered.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# DG CLIMA file schema drifted in 2026; parser needs updating.
# Tracked at https://github.com/charlescoverdale/carbondata/issues
de <- co2_euets_emissions(country = "DE")
} # }
```
