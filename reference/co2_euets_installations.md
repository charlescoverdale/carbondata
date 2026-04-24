# EU ETS installation registry

Returns the registry of stationary EU ETS installations with operator
name, activity type, country, city, and permit details. Sourced from the
DG CLIMA Union Registry snapshot.

## Usage

``` r
co2_euets_installations(country = NULL, refresh = FALSE)
```

## Arguments

- country:

  Optional two-letter registry codes.

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame.

## See also

Other EU ETS:
[`co2_euets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_allocations.md),
[`co2_euets_emissions()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_emissions.md),
[`co2_euets_files()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_files.md),
[`co2_euets_price()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_price.md),
[`co2_euets_surrendered()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_surrendered.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
inst <- co2_euets_installations(country = "PL")
#> ℹ Downloading EU ETS installation registry...
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
options(op)
# }
```
