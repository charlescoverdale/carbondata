# List the EU ETS data file versions bundled with this package

Returns a data frame of the DG CLIMA file vintages supported. When DG
CLIMA publishes a newer file, upgrade the package.

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
#>                 kind file_year                                 uuid
#> 1 verified_emissions      2025 53018483-62b3-499e-9ab9-b4a831cc44f4
#> 2 verified_emissions      2024 385daec1-0970-44ab-917d-f500658e72aa
#> 3 verified_emissions      2023 ebb2c20e-8737-4a73-b6ba-a4b7e78ecc01
#> 4 verified_emissions      2022 8f79885d-c567-4db2-9711-71ee8a29a037
#> 5 verified_emissions      2021 9bcb5ebd-47bd-49af-8c19-a24df8077cf9
#> 6         compliance      2024 b80300cf-7608-405d-969e-8b016687640e
#> 7         compliance      2023 42495a32-cb4c-4772-9a2a-d08781c8ed61
#> 8         compliance      2022 7e7268a1-fa21-4f73-b368-6e9571262e2f
#> 9         compliance      2021 86a31a71-dff3-4729-86d0-943685c20dc1
```
