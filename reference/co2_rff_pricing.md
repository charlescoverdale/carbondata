# RFF World Carbon Pricing Database

Fetches the Dolphin-Pollitt-Newbery World Carbon Pricing Database for
one country. Covers national-level carbon pricing from 1989 to present,
with CO2 tax and ETS instruments harmonised across 200+ jurisdictions.

## Usage

``` r
co2_rff_pricing(country, version = "v2026.1", refresh = FALSE)
```

## Arguments

- country:

  Character. Country name using underscores (e.g. `"United_Kingdom"`,
  `"Germany"`, `"Antigua_and_Barbuda"`).

- version:

  Character. Dataset version folder. Default `"v2026.1"`.

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame of annual carbon prices by IPCC sector code.

## References

Dolphin, G. G., Pollitt, M. G. and Newbery, D. M. (2020). "The political
economy of carbon pricing: a panel analysis." *Oxford Economic Papers*,
72(2), 472–500. <doi:10.1093/oep/gpz042>

## See also

Other aggregators:
[`co2_icap_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_prices.md),
[`co2_world_bank()`](https://charlescoverdale.github.io/carbondata/reference/co2_world_bank.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
uk <- co2_rff_pricing("United_Kingdom")
#> ℹ Downloading RFF World Carbon Pricing Database for United_Kingdom...
options(op)
# }
```
