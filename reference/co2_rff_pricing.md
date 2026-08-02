# RFF World Carbon Pricing Database

Fetches the Dolphin-Pollitt-Newbery World Carbon Pricing Database for
one country: national-level carbon pricing with CO2 tax and ETS
instruments harmonised by IPCC sector across 200+ jurisdictions.

## Usage

``` r
co2_rff_pricing(country, version = "v2025.0.0", refresh = FALSE)
```

## Arguments

- country:

  Character. Country name using underscores (e.g. `"United_Kingdom"`,
  `"Germany"`, `"Antigua_and_Barbuda"`).

- version:

  Character. Git tag of the dataset release to read. Default
  `"v2025.0.0"`, the last openly published snapshot.

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame of annual carbon prices by IPCC sector code.

## Details

On 30 May 2026 the maintainer stopped distributing WCPD through GitHub
and stripped the data files from the default branch; new releases moved
to <https://worldcarbonpricing.org> behind an emailed download token.
This function therefore reads the last openly published snapshot, the
`v2025.0.0` tag, which remains available and covers 1990 to 2023. For
newer vintages, request access on the WCPD site. For the companion
emissions-weighted carbon price, which is still served openly, see
[`co2_ecp_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_ecp_prices.md).

## References

Dolphin, G. G., Pollitt, M. G. and Newbery, D. M. (2020). "The political
economy of carbon pricing: a panel analysis." *Oxford Economic Papers*,
72(2), 472–500. <doi:10.1093/oep/gpz042>

## See also

Other aggregators:
[`co2_ecp_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_ecp_prices.md),
[`co2_icap_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_prices.md),
[`co2_icap_systems()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_systems.md),
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
