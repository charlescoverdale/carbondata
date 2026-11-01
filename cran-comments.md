# CRAN submission comments: carbondata 0.2.1

## Reason for this submission

Bug fix. `co2_rggi_allowances()` read the RGGI workbook's title block as
its header, so it returned unusable columns. Details in NEWS.md.

## R CMD check results

0 errors | 0 warnings | 0 notes (CRAN settings, R 4.5.2, macOS).

Tests that need the network are skipped on CRAN, and network examples
are wrapped in `try()` inside `\donttest{}`.

## Downstream dependencies

None on CRAN.
