# Berkeley Voluntary Registry Offsets Database

Fetches the Berkeley GSPP Voluntary Registry Offsets Database, an
aggregator of Verra, Gold Standard, ACR, CAR, and ART TREES project
registrations and issuances. Released bimonthly under CC BY 4.0.

## Usage

``` r
co2_vrod(refresh = FALSE)
```

## Arguments

- refresh:

  Re-download? Default `FALSE`. Each release has a date-stamped
  filename; the package scrapes the landing page to find the latest
  release on each call unless a cached copy exists.

## Value

A data frame of project-level data.

## See also

Other voluntary markets:
[`co2_cad_trust()`](https://charlescoverdale.github.io/carbondata/reference/co2_cad_trust.md),
[`co2_offsets_db()`](https://charlescoverdale.github.io/carbondata/reference/co2_offsets_db.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
vrod <- co2_vrod()
#> ℹ Resolving latest VROD release...
#> Error in value[[3L]](cond): Failed to reach landing page
#> <https://gspp.berkeley.edu/berkeley-carbon-trading-project/offsets-database>.
#> ✖ Failed to perform HTTP request. Caused by error in
#>   `curl::curl_fetch_memory()`: ! Timeout was reached [gspp.berkeley.edu]:
#>   Failed to connect to gspp.berkeley.edu port 443 after 10001 ms: Timeout was
#>   reached
options(op)
# }
```
