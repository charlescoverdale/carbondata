# Clear the carbondata cache

Deletes all locally cached carbon market data files. The next call to
any data function will re-download.

## Usage

``` r
co2_clear_cache()
```

## Value

Invisibly returns `NULL`.

## See also

Other configuration:
[`co2_cache_info()`](https://charlescoverdale.github.io/carbondata/reference/co2_cache_info.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
co2_clear_cache()
#> Removed 3 cached files from /tmp/RtmpqqQvND.
options(op)
# }
```
