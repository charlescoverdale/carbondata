# List the EU ETS data file vintages available

Returns a data frame of the DG CLIMA file vintages available. The
package scrapes the Union Registry page at runtime so new annual
releases appear automatically; when the page is unreachable, the
vintages bundled with the package are listed instead.

## Usage

``` r
co2_euets_files()
```

## Value

A data frame.

## See also

Other EU ETS:
[`co2_euets_allocations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_allocations.md),
[`co2_euets_emissions()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_emissions.md),
[`co2_euets_installations()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_installations.md),
[`co2_euets_price()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_price.md),
[`co2_euets_surrendered()`](https://charlescoverdale.github.io/carbondata/reference/co2_euets_surrendered.md)

## Examples

``` r
co2_euets_files()
#>                  kind file_year                                 uuid
#> 1  verified_emissions      2025 53018483-62b3-499e-9ab9-b4a831cc44f4
#> 2  verified_emissions      2024 385daec1-0970-44ab-917d-f500658e72aa
#> 3  verified_emissions      2023 ebb2c20e-8737-4a73-b6ba-a4b7e78ecc01
#> 4  verified_emissions      2022 8f79885d-c567-4db2-9711-71ee8a29a037
#> 5  verified_emissions      2021 9bcb5ebd-47bd-49af-8c19-a24df8077cf9
#> 6  verified_emissions      2020 6e39920a-8999-403c-8840-d413ca707373
#> 7  verified_emissions      2019 e5843058-b800-4845-8676-dc2663585534
#> 8  verified_emissions      2018 9e3ed91e-5820-47d1-8b6f-f99b9a67172e
#> 9  verified_emissions      2017 4446fc66-741d-4bf8-854b-59837f1af786
#> 10 verified_emissions      2016 040d847e-5285-4224-b512-c6b2d61d4d0a
#> 11 verified_emissions      2015 50300a10-3870-4da4-8d71-949356a913cd
#> 12         compliance      2024 b80300cf-7608-405d-969e-8b016687640e
#> 13         compliance      2023 42495a32-cb4c-4772-9a2a-d08781c8ed61
#> 14         compliance      2022 7e7268a1-fa21-4f73-b368-6e9571262e2f
#> 15         compliance      2021 86a31a71-dff3-4729-86d0-943685c20dc1
#> 16         compliance      2020 2d3e055d-ba0e-46db-b4c1-e3a9210d7ddb
#> 17         compliance      2019 aa7a64c3-c4a4-4029-b325-151ccd3f8a8e
#> 18         compliance      2018 e987eacc-5268-4775-a53b-975eef1dbdd3
#> 19         compliance      2017 d7bc1af8-a125-47b8-8393-d0ab879eb702
#> 20         compliance      2016 632ab131-64f4-4ee7-b6dc-f728d3b46ae4
#> 21         compliance      2015 5b6fe8e5-b8af-4e04-88ec-de4f722cdfd3
#> 22         compliance      2012 5abebaca-a667-463f-97b9-b8992fafe594
```
