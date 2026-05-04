# CarbonPlan OffsetsDB (via S3 parquet)

Fetches the CarbonPlan OffsetsDB daily snapshots of voluntary carbon
market projects and credits, stored as Parquet in a public S3 bucket.
Covers Verra, ART TREES, Gold Standard, American Carbon Registry, and
Climate Action Reserve.

## Usage

``` r
co2_offsets_db(kind = c("projects", "credits"), date = NULL, refresh = FALSE)
```

## Arguments

- kind:

  Character. `"projects"` (default) or `"credits"`.

- date:

  Optional character. ISO date of the snapshot to fetch (must be a day
  CarbonPlan published; the function walks backwards from this date up
  to 7 days). Default
  [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html).

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
#> ℹ Downloading OffsetsDB projects snapshot from 2026-04-29...
if (requireNamespace("arrow", quietly = TRUE)) {
  df <- arrow::read_parquet(path)
}
options(op)
# }
```
