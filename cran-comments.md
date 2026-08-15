# CRAN submission comments — carbondata 0.2.0

## Reason for this submission

This is an update to carbondata 0.1.0, currently on CRAN. It is an
upstream repair release. Six of the data sources the package wraps
changed their URLs, file layouts, or access terms between April and
August 2026, and seven code paths were returning wrong or empty data
without raising an error. Every source was re-tested against its live
endpoint on 2 August 2026.

## Headline fixes

* `co2_euets_emissions()` and `co2_euets_allocations()`: from compliance
  year 2024, DG CLIMA publishes EU ETS2 in the same file as ETS1
  installations, as one aggregate account per member state. Those 25
  accounts added roughly 45% to the reported 2024 total, so country-year
  sums roughly doubled. A new `scheme` argument defaults to `"ets1"`,
  preserving the pre-ETS2 meaning of the result.
* `co2_vrod()`: read sheet 1, which upstream replaced with a "READ
  FIRST" cover sheet, so it returned prose rather than the project
  register. It now reads the `PROJECTS` sheet and selects releases by
  the date in the filename rather than lexically.
* Column typing now guesses from the whole sheet, since several columns
  stay blank past readxl's default 1000-row window.

Full detail in NEWS.md.

## R CMD check results

0 errors | 0 warnings | 0 notes (CRAN default settings, R 4.5.2, macOS).

## Notes on data access

The package downloads from third-party endpoints on first use and caches
locally using `tools::R_user_dir()`. No data is bundled. Network-using
examples are wrapped in `\donttest{}` and tests in `skip_on_cran()`, so
the check does not depend on any remote host being reachable.

## Downstream dependencies

None on CRAN.
