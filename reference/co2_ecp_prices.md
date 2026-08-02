# Emissions-weighted carbon prices (ECP)

Fetches the emissions-weighted carbon price dataset published alongside
the World Carbon Pricing Database at <https://worldcarbonpricing.org>.
Unlike the raw WCPD files, these endpoints remain open and are updated
with each release, so this is the current route to World Carbon Pricing
Database derived data.

## Usage

``` r
co2_ecp_prices(
  level = c("jurisdiction", "sector", "coverage", "coverage_sector", "region"),
  gas = "CO2",
  country = NULL,
  refresh = FALSE
)
```

## Arguments

- level:

  Character. One of `"jurisdiction"` (default), `"sector"`,
  `"coverage"`, `"coverage_sector"`, or `"region"`.

- gas:

  Character. Greenhouse gas. Default `"CO2"`.

- country:

  Optional character vector of jurisdiction names to filter (matched
  case-insensitively, e.g. `"United Kingdom"`).

- refresh:

  Re-download? Default `FALSE`. Cached copies refresh automatically
  after 30 days.

## Value

A data frame.

## Details

`level = "jurisdiction"` returns average effective carbon prices by
jurisdiction and year and `"sector"` disaggregates by IPCC sector.
Coverage shares, the fraction of emissions subject to a price, come from
`"coverage"` (by jurisdiction) and `"coverage_sector"`.

`"region"` is accepted because the publisher documents the endpoint, but
their server currently has no data file behind it for any gas; the call
errors with that explanation until they restore it.

## References

Dolphin, G., Xiahou, Q. (2022). "World carbon pricing database: sources
and methods." *Scientific Data*, 9, 573.
<doi:10.1038/s41597-022-01659-x>

## See also

Other aggregators:
[`co2_icap_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_prices.md),
[`co2_icap_systems()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_systems.md),
[`co2_rff_pricing()`](https://charlescoverdale.github.io/carbondata/reference/co2_rff_pricing.md),
[`co2_world_bank()`](https://charlescoverdale.github.io/carbondata/reference/co2_world_bank.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
ecp <- co2_ecp_prices(country = "United Kingdom")
#> ℹ Downloading ECP jurisdiction data...
options(op)
# }
```
