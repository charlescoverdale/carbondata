# ICAP systems available

Lists the emissions trading systems carried by the ICAP Allowance Price
Explorer, with the date range and number of observations for each. Use
this to find the exact `jurisdiction` names accepted by
[`co2_icap_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_prices.md).

## Usage

``` r
co2_icap_systems(include_download = FALSE, refresh = FALSE)
```

## Arguments

- include_download:

  Logical. ICAP publishes a second "(download)" copy of several systems
  carrying the same prices as the main series. These are excluded by
  default, because including them duplicates a system in any chart or
  average. Set `TRUE` to keep them.

- refresh:

  Re-download? Default `FALSE`.

## Value

A data frame with `jurisdiction`, `currency`, `market_type`,
`first_date`, `last_date`, and `n_obs`.

## See also

Other aggregators:
[`co2_ecp_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_ecp_prices.md),
[`co2_icap_prices()`](https://charlescoverdale.github.io/carbondata/reference/co2_icap_prices.md),
[`co2_rff_pricing()`](https://charlescoverdale.github.io/carbondata/reference/co2_rff_pricing.md),
[`co2_world_bank()`](https://charlescoverdale.github.io/carbondata/reference/co2_world_bank.md)

## Examples

``` r
# \donttest{
op <- options(carbondata.cache_dir = tempdir())
co2_icap_systems()
#>                                            jurisdiction currency market_type
#> 1              Beijing (Pilot) Emissions Trading System      CNY     primary
#> 2              Beijing (Pilot) Emissions Trading System      CNY   secondary
#> 3                      California Cap-and-Trade Program      USD     primary
#> 4                      California Cap-and-Trade Program      USD   secondary
#> 5               China National Emissions Trading System      CNY   secondary
#> 6            Chongqing (Pilot) Emissions Trading System      CNY     primary
#> 7            Chongqing (Pilot) Emissions Trading System      CNY   secondary
#> 8   European Union Emissions Trading System (from 2019)      EUR     primary
#> 9   European Union Emissions Trading System (from 2019)      EUR   secondary
#> 10 European Union Emissions Trading System (until 2018)      EUR     primary
#> 11 European Union Emissions Trading System (until 2018)      EUR   secondary
#> 12              Fujian (Pilot) Emissions Trading System      CNY   secondary
#> 13             German National Emissions Trading System      EUR     primary
#> 14           Guangdong (Pilot) Emissions Trading System      CNY     primary
#> 15           Guangdong (Pilot) Emissions Trading System      CNY   secondary
#> 16               Hubei (Pilot) Emissions Trading System      CNY     primary
#> 17               Hubei (Pilot) Emissions Trading System      CNY   secondary
#> 18                      Korean Emissions Trading System      KRW     primary
#> 19                      Korean Emissions Trading System      KRW   secondary
#> 20     New Zealand Emissions Trading System (From 2024)      NZD     primary
#> 21     New Zealand Emissions Trading System (From 2024)      NZD   secondary
#> 22    New Zealand Emissions Trading System (Up to 2023)      NZD     primary
#> 23    New Zealand Emissions Trading System (Up to 2023)      NZD   secondary
#> 24        Nova Scotia Cap-and-Trade Program (2019-2022)      CAD     primary
#> 25            Ontario Cap-and-Trade Program (2017-2018)      CAD     primary
#> 26                          Québec Cap-and-Trade System      CAD     primary
#> 27                   Regional Greenhouse Gas Initiative      USD     primary
#> 28                   Regional Greenhouse Gas Initiative      USD   secondary
#> 29            Shanghai (Pilot) Emissions Trading System      CNY     primary
#> 30            Shanghai (Pilot) Emissions Trading System      CNY   secondary
#> 31            Shenzhen (Pilot) Emissions Trading System      CNY     primary
#> 32            Shenzhen (Pilot) Emissions Trading System      CNY   secondary
#> 33                 Switzerland Emissions Trading System      CHF     primary
#> 34             Tianjin (Pilot) Emissions Trading System      CNY     primary
#> 35             Tianjin (Pilot) Emissions Trading System      CNY   secondary
#> 36              United Kingdom Emissions Trading Scheme      GBP     primary
#> 37              United Kingdom Emissions Trading Scheme      GBP   secondary
#> 38                    Washington Cap-and-Invest Program      USD     primary
#> 39                    Washington Cap-and-Invest Program      USD   secondary
#>    first_date  last_date n_obs
#> 1  2022-11-23 2026-06-18     8
#> 2  2013-11-28 2026-06-30  2329
#> 3  2012-11-14 2026-05-20    55
#> 4  2020-11-02 2026-06-30  1439
#> 5  2021-07-16 2026-06-30  1199
#> 6  2021-11-02 2024-03-07     4
#> 7  2014-06-19 2026-06-30  1803
#> 8  2019-01-07 2026-06-30  1624
#> 9  2019-01-02 2026-06-30  1868
#> 10 2010-01-05 2018-12-17  1363
#> 11 2005-03-09 2018-12-28  3481
#> 12 2016-12-22 2026-06-30  1715
#> 13 2021-10-05 2026-06-09   365
#> 14 2013-12-16 2020-04-27    18
#> 15 2013-12-19 2026-06-30  2752
#> 16 2014-03-31 2023-12-18    11
#> 17 2014-04-02 2026-06-30  2927
#> 18 2019-01-23 2026-06-10    81
#> 19 2015-01-12 2026-06-30  2814
#> 20 2024-03-20 2026-03-03     9
#> 21 2024-01-23 2026-03-31   546
#> 22 2021-03-17 2023-09-06    11
#> 23 2009-03-09 2023-09-29  3601
#> 24 2020-06-10 2023-08-22     8
#> 25 2017-03-22 2018-05-15     6
#> 26 2013-12-03 2026-05-20    52
#> 27 2008-09-25 2026-06-03    73
#> 28 2008-09-30 2026-06-30  2154
#> 29 2014-06-30 2026-06-30    15
#> 30 2013-11-26 2026-06-30  2313
#> 31 2014-06-06 2022-08-12     2
#> 32 2013-06-18 2026-06-30  2898
#> 33 2014-05-21 2026-06-17    32
#> 34 2019-06-27 2026-06-12     8
#> 35 2013-12-26 2026-06-30  1811
#> 36 2021-05-19 2026-06-17   128
#> 37 2021-05-17 2026-06-30  1281
#> 38 2023-02-28 2026-06-03    14
#> 39 2023-06-05 2026-06-30   782
options(op)
# }
```
