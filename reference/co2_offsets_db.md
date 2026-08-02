# CarbonPlan OffsetsDB (via S3 parquet)

Fetches the CarbonPlan OffsetsDB daily snapshots of voluntary carbon
market projects and credits, stored as Parquet in a public S3 bucket.
Covers Verra, ART TREES, Gold Standard, American Carbon Registry, and
Climate Action Reserve.

## Usage

``` r
co2_offsets_db(
  kind = c("projects", "credits"),
  date = NULL,
  max_lookback = 180L,
  refresh = FALSE
)
```

## Arguments

- kind:

  Character. `"projects"` (default) or `"credits"`.

- date:

  Optional character. ISO date of the snapshot to fetch. The function
  walks backwards from this date to find a published snapshot. Default
  [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html).

- max_lookback:

  Integer. How many days to walk back before giving up. Default 180,
  because CarbonPlan's publication cadence became irregular during 2026
  and the last snapshot seen was 1 June 2026.

- refresh:

  Re-download? Default `FALSE`.

## Value

A file path to the downloaded Parquet file. The caller must have `arrow`
or `nanoparquet` installed to read it.

## Details

The CarbonPlan REST API at `offsets-db-api.carbonplan.org` was
deprecated; this function uses the S3 bucket directly. Parquet reading
requires an installed Parquet reader; the `arrow` package is the
recommended suggest.

## See also

Other voluntary markets:
[`co2_cad_trust()`](https://charlescoverdale.github.io/carbondata/reference/co2_cad_trust.md),
[`co2_vrod()`](https://charlescoverdale.github.io/carbondata/reference/co2_vrod.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
path <- co2_offsets_db("projects")
#> Warning: ! Newest OffsetsDB snapshot is 62 days old (2026-06-01).
#> ℹ CarbonPlan's publication cadence became irregular in 2026.
#> ℹ Downloading OffsetsDB projects snapshot from 2026-06-01...
if (requireNamespace("arrow", quietly = TRUE)) {
  df <- arrow::read_parquet(path)
}
options(op)
# }
```
