# List supported carbon markets

Returns a data frame of the carbon markets (compliance and voluntary)
supported by this package, with coverage metadata.

## Usage

``` r
co2_markets(type = c("all", "compliance", "voluntary"))
```

## Arguments

- type:

  Character. One of `"all"` (default), `"compliance"`, or `"voluntary"`.

## Value

A data frame with columns `market`, `name`, `type`, `coverage_start`,
`jurisdiction`, `function_name`, and `notes`.

## Examples

``` r
co2_markets()
#>        market                                         name       type
#> 1      eu_ets                  EU Emissions Trading System compliance
#> 2      uk_ets                  UK Emissions Trading Scheme compliance
#> 3        rggi           Regional Greenhouse Gas Initiative compliance
#> 4  california                     California Cap-and-Trade compliance
#> 5        icap                ICAP Allowance Price Explorer compliance
#> 6  world_bank          World Bank Carbon Pricing Dashboard compliance
#> 7         rff            RFF World Carbon Pricing Database compliance
#> 8         ecp        Emissions-weighted carbon price (ECP) compliance
#> 9        vrod Berkeley Voluntary Registry Offsets Database  voluntary
#> 10 offsets_db                         CarbonPlan OffsetsDB  voluntary
#>    coverage_start                          jurisdiction
#> 1            2005                              EU + EEA
#> 2            2021                        United Kingdom
#> 3            2009              US Northeast (11 states)
#> 4            2013                            California
#> 5            2005                    Global (multi-ETS)
#> 6            1990           Global (carbon taxes + ETS)
#> 7            1990             National (200+ countries)
#> 8            1990 Global (jurisdiction, sector, region)
#> 9            1996       Global (5 voluntary registries)
#> 10           1996                    Global (voluntary)
#>                                                                                                                   function_name
#> 1  co2_euets_emissions, co2_euets_allocations, co2_euets_surrendered, co2_euets_price, co2_euets_installations, co2_euets_files
#> 2                                                                                              co2_ukets, co2_ukets_allocations
#> 3                                                                                  co2_rggi_allowances, co2_rggi_state_proceeds
#> 4                                                                                    co2_california_prices, co2_california_caps
#> 5                                                                                             co2_icap_prices, co2_icap_systems
#> 6                                                                                                                co2_world_bank
#> 7                                                                                                               co2_rff_pricing
#> 8                                                                                                                co2_ecp_prices
#> 9                                                                                                                      co2_vrod
#> 10                                                                                                               co2_offsets_db
#>                                                                                   notes
#> 1  Largest ETS globally; covers ~10k installations in stationary sectors plus aviation.
#> 2      Launched 2021 post-Brexit; covers power and industry; linked carbon price floor.
#> 3                            Power sector only across 11 US states; quarterly auctions.
#> 4    Multi-sector; linked with Quebec (Western Climate Initiative); quarterly auctions.
#> 5             Curated price series across 20+ ETS; single best cross-market comparator.
#> 6      Biannual dashboard. Host blocks programmatic access; may need a manual download.
#> 7                      Frozen at the v2025.0.0 release; WCPD left GitHub on 2026-05-30.
#> 8  Emissions-weighted carbon prices and coverage; the live successor to WCPD on GitHub.
#> 9             Aggregates Verra, Gold Standard, ACR, CAR, ART TREES. Released bimonthly.
#> 10   S3 parquet snapshots; publication became irregular in 2026 (last seen 2026-06-01).
co2_markets(type = "compliance")
#>       market                                  name       type coverage_start
#> 1     eu_ets           EU Emissions Trading System compliance           2005
#> 2     uk_ets           UK Emissions Trading Scheme compliance           2021
#> 3       rggi    Regional Greenhouse Gas Initiative compliance           2009
#> 4 california              California Cap-and-Trade compliance           2013
#> 5       icap         ICAP Allowance Price Explorer compliance           2005
#> 6 world_bank   World Bank Carbon Pricing Dashboard compliance           1990
#> 7        rff     RFF World Carbon Pricing Database compliance           1990
#> 8        ecp Emissions-weighted carbon price (ECP) compliance           1990
#>                            jurisdiction
#> 1                              EU + EEA
#> 2                        United Kingdom
#> 3              US Northeast (11 states)
#> 4                            California
#> 5                    Global (multi-ETS)
#> 6           Global (carbon taxes + ETS)
#> 7             National (200+ countries)
#> 8 Global (jurisdiction, sector, region)
#>                                                                                                                  function_name
#> 1 co2_euets_emissions, co2_euets_allocations, co2_euets_surrendered, co2_euets_price, co2_euets_installations, co2_euets_files
#> 2                                                                                             co2_ukets, co2_ukets_allocations
#> 3                                                                                 co2_rggi_allowances, co2_rggi_state_proceeds
#> 4                                                                                   co2_california_prices, co2_california_caps
#> 5                                                                                            co2_icap_prices, co2_icap_systems
#> 6                                                                                                               co2_world_bank
#> 7                                                                                                              co2_rff_pricing
#> 8                                                                                                               co2_ecp_prices
#>                                                                                  notes
#> 1 Largest ETS globally; covers ~10k installations in stationary sectors plus aviation.
#> 2     Launched 2021 post-Brexit; covers power and industry; linked carbon price floor.
#> 3                           Power sector only across 11 US states; quarterly auctions.
#> 4   Multi-sector; linked with Quebec (Western Climate Initiative); quarterly auctions.
#> 5            Curated price series across 20+ ETS; single best cross-market comparator.
#> 6     Biannual dashboard. Host blocks programmatic access; may need a manual download.
#> 7                     Frozen at the v2025.0.0 release; WCPD left GitHub on 2026-05-30.
#> 8 Emissions-weighted carbon prices and coverage; the live successor to WCPD on GitHub.
```
