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
#>       market                                         name       type
#> 1     eu_ets                  EU Emissions Trading System compliance
#> 2     uk_ets                  UK Emissions Trading Scheme compliance
#> 3       rggi           Regional Greenhouse Gas Initiative compliance
#> 4 california                     California Cap-and-Trade compliance
#> 5       icap                ICAP Allowance Price Explorer compliance
#> 6 world_bank          World Bank Carbon Pricing Dashboard compliance
#> 7        rff            RFF World Carbon Pricing Database compliance
#> 8       vrod Berkeley Voluntary Registry Offsets Database  voluntary
#> 9 offsets_db                         CarbonPlan OffsetsDB  voluntary
#>   coverage_start                    jurisdiction
#> 1           2005                        EU + EEA
#> 2           2021                  United Kingdom
#> 3           2009        US Northeast (11 states)
#> 4           2013                      California
#> 5           2005              Global (multi-ETS)
#> 6           1990     Global (carbon taxes + ETS)
#> 7           1989       National (200+ countries)
#> 8           1996 Global (5 voluntary registries)
#> 9           1996              Global (voluntary)
#>                                                                                                                  function_name
#> 1 co2_euets_emissions, co2_euets_allocations, co2_euets_surrendered, co2_euets_price, co2_euets_installations, co2_euets_files
#> 2                                                                                             co2_ukets, co2_ukets_allocations
#> 3                                                                                 co2_rggi_allowances, co2_rggi_state_proceeds
#> 4                                                                                   co2_california_prices, co2_california_caps
#> 5                                                                                                              co2_icap_prices
#> 6                                                                                                               co2_world_bank
#> 7                                                                                                              co2_rff_pricing
#> 8                                                                                                                     co2_vrod
#> 9                                                                                                               co2_offsets_db
#>                                                                                  notes
#> 1 Largest ETS globally; covers ~10k installations in stationary sectors plus aviation.
#> 2     Launched 2021 post-Brexit; covers power and industry; linked carbon price floor.
#> 3                           Power sector only across 11 US states; quarterly auctions.
#> 4   Multi-sector; linked with Quebec (Western Climate Initiative); quarterly auctions.
#> 5            Curated price series across 20+ ETS; single best cross-market comparator.
#> 6                             Global biannual dashboard of carbon pricing instruments.
#> 7           National/subnational historical coverage (Dolphin, Pollitt, Newbery 2020).
#> 8            Aggregates Verra, Gold Standard, ACR, CAR, ART TREES. Released bimonthly.
#> 9                                 Daily S3 parquet snapshots maintained by CarbonPlan.
co2_markets(type = "compliance")
#>       market                                name       type coverage_start
#> 1     eu_ets         EU Emissions Trading System compliance           2005
#> 2     uk_ets         UK Emissions Trading Scheme compliance           2021
#> 3       rggi  Regional Greenhouse Gas Initiative compliance           2009
#> 4 california            California Cap-and-Trade compliance           2013
#> 5       icap       ICAP Allowance Price Explorer compliance           2005
#> 6 world_bank World Bank Carbon Pricing Dashboard compliance           1990
#> 7        rff   RFF World Carbon Pricing Database compliance           1989
#>                  jurisdiction
#> 1                    EU + EEA
#> 2              United Kingdom
#> 3    US Northeast (11 states)
#> 4                  California
#> 5          Global (multi-ETS)
#> 6 Global (carbon taxes + ETS)
#> 7   National (200+ countries)
#>                                                                                                                  function_name
#> 1 co2_euets_emissions, co2_euets_allocations, co2_euets_surrendered, co2_euets_price, co2_euets_installations, co2_euets_files
#> 2                                                                                             co2_ukets, co2_ukets_allocations
#> 3                                                                                 co2_rggi_allowances, co2_rggi_state_proceeds
#> 4                                                                                   co2_california_prices, co2_california_caps
#> 5                                                                                                              co2_icap_prices
#> 6                                                                                                               co2_world_bank
#> 7                                                                                                              co2_rff_pricing
#>                                                                                  notes
#> 1 Largest ETS globally; covers ~10k installations in stationary sectors plus aviation.
#> 2     Launched 2021 post-Brexit; covers power and industry; linked carbon price floor.
#> 3                           Power sector only across 11 US states; quarterly auctions.
#> 4   Multi-sector; linked with Quebec (Western Climate Initiative); quarterly auctions.
#> 5            Curated price series across 20+ ETS; single best cross-market comparator.
#> 6                             Global biannual dashboard of carbon pricing instruments.
#> 7           National/subnational historical coverage (Dolphin, Pollitt, Newbery 2020).
```
