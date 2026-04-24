# Inspect the local carbondata cache

Returns information about the local cache: directory, file count, size,
and list of cached files. Useful for debugging stale results or deciding
whether to call
[`co2_clear_cache()`](https://charlescoverdale.github.io/carbondata/reference/co2_clear_cache.md).

## Usage

``` r
co2_cache_info()
```

## Value

A list with elements `dir`, `n_files`, `size_bytes`, `size_human`, and
`files` (a data frame with `name`, `size_bytes`, `modified`).

## See also

Other configuration:
[`co2_clear_cache()`](https://charlescoverdale.github.io/carbondata/reference/co2_clear_cache.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
co2_cache_info()
#> $dir
#> [1] "/tmp/RtmpqqQvND"
#> 
#> $n_files
#> [1] 1
#> 
#> $size_bytes
#> [1] 4096
#> 
#> $size_human
#> [1] "4.0 KB"
#> 
#> $files
#>                                     name size_bytes            modified
#> 1 bslib-246362e7e3ff6191071d5f9b40ba8d62       4096 2026-04-24 08:54:37
#> 
options(op)
# }
```
