# EU ETS allowance (EUA) auction settlement prices

Fetches EU Allowance (EUA) primary-auction settlement prices from the
EEX public auction report. Auctions are held several times per week;
each year's file accumulates all auctions for that year.

## Usage

``` r
co2_euets_price(from = NULL, to = NULL, year = NULL, refresh = FALSE)
```

## Arguments

- from, to:

  Optional character or Date. Date range.

- year:

  Optional integer year. If supplied, only the file for that year is
  fetched (faster than `from`/`to`).

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame with `date`, `auction_name`, `contract`, `status`,
`price_eur`, `min_bid_eur`, `max_bid_eur`, `volume_t`.

## See also

Other EU ETS:
[`co2_euets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_allocations.md),
[`co2_euets_emissions()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_emissions.md),
[`co2_euets_files()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_files.md),
[`co2_euets_installations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_installations.md),
[`co2_euets_surrendered()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_surrendered.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
prices <- co2_euets_price(year = 2025)
#> ℹ Downloading EEX EUA auction report for 2025...
options(op)
# }
```
