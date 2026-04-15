# CRAN submission comments — carbondata 0.1.0

## New submission

This is a new package providing unified R access to carbon market
data from:

* Emissions Trading Systems: EU ETS, UK ETS, RGGI, California
  Cap-and-Trade
* Cross-market aggregators: ICAP Allowance Price Explorer, World
  Bank Carbon Pricing Dashboard, RFF World Carbon Pricing Database
* Voluntary carbon markets: Berkeley VROD, CarbonPlan OffsetsDB,
  Climate Action Data Trust

## R CMD check results

0 errors | 0 warnings | 0 notes

## Test suite

60+ expectations. Network-dependent tests are wrapped in
`skip_on_cran()` and `skip_if_offline()`. Tests requiring the
optional `CARBONDATA_LIVE_TESTS` environment variable cover live
fetches against real endpoints and are skipped by default.

## Notes on data access

* All data sources are public and free.
* No authentication required for v0.1.0 functionality (CAD Trust
  optional for future integration).
* Downloaded data is cached to `tools::R_user_dir("carbondata", "cache")`
  on first use.
* `\donttest` examples redirect the cache to `tempdir()` via
  `options(carbondata.cache_dir = ...)` so no files are written to
  the user's home filespace.
* `\dontrun` is used only for examples that require an API key
  (CAD Trust) or a private endpoint (OffsetsDB pagination) that
  cannot be safely demonstrated without network access on CRAN's
  test systems.

## Downstream dependencies

None.
