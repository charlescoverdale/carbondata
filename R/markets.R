#' List supported carbon markets
#'
#' Returns a data frame of the carbon markets (compliance and
#' voluntary) supported by this package, with coverage metadata.
#'
#' @param type Character. One of `"all"` (default), `"compliance"`,
#'   or `"voluntary"`.
#'
#' @return A data frame with columns `market`, `name`, `type`,
#'   `coverage_start`, `jurisdiction`, `function_name`, and `notes`.
#'
#' @family helpers
#' @export
#' @examples
#' co2_markets()
#' co2_markets(type = "compliance")
co2_markets <- function(type = c("all", "compliance", "voluntary")) {
  type <- match.arg(type)
  out <- co2_markets_data
  if (type != "all") {
    out <- out[out$type == type, , drop = FALSE]
    rownames(out) <- NULL
  }
  out
}

# Built-in markets lookup table
co2_markets_data <- data.frame(
  market = c(
    "eu_ets", "uk_ets", "rggi", "california",
    "icap", "world_bank", "rff",
    "vrod", "offsets_db"
  ),
  name = c(
    "EU Emissions Trading System",
    "UK Emissions Trading Scheme",
    "Regional Greenhouse Gas Initiative",
    "California Cap-and-Trade",
    "ICAP Allowance Price Explorer",
    "World Bank Carbon Pricing Dashboard",
    "RFF World Carbon Pricing Database",
    "Berkeley Voluntary Registry Offsets Database",
    "CarbonPlan OffsetsDB"
  ),
  type = c(
    "compliance", "compliance", "compliance", "compliance",
    "compliance", "compliance", "compliance",
    "voluntary", "voluntary"
  ),
  coverage_start = c(
    2005L, 2021L, 2009L, 2013L,
    2005L, 1990L, 1989L,
    1996L, 1996L
  ),
  jurisdiction = c(
    "EU + EEA", "United Kingdom", "US Northeast (11 states)", "California",
    "Global (multi-ETS)", "Global (carbon taxes + ETS)", "National (200+ countries)",
    "Global (5 voluntary registries)", "Global (voluntary)"
  ),
  function_name = c(
    "co2_euets_emissions, co2_euets_allocations, co2_euets_surrendered, co2_euets_price, co2_euets_installations, co2_euets_files",
    "co2_ukets, co2_ukets_allocations",
    "co2_rggi_allowances, co2_rggi_state_proceeds",
    "co2_california_prices, co2_california_caps",
    "co2_icap_prices",
    "co2_world_bank",
    "co2_rff_pricing",
    "co2_vrod",
    "co2_offsets_db"
  ),
  notes = c(
    "Largest ETS globally; covers ~10k installations in stationary sectors plus aviation.",
    "Launched 2021 post-Brexit; covers power and industry; linked carbon price floor.",
    "Power sector only across 11 US states; quarterly auctions.",
    "Multi-sector; linked with Quebec (Western Climate Initiative); quarterly auctions.",
    "Curated price series across 20+ ETS; single best cross-market comparator.",
    "Global biannual dashboard of carbon pricing instruments.",
    "National/subnational historical coverage (Dolphin, Pollitt, Newbery 2020).",
    "Aggregates Verra, Gold Standard, ACR, CAR, ART TREES. Released bimonthly.",
    "Daily S3 parquet snapshots maintained by CarbonPlan."
  ),
  stringsAsFactors = FALSE
)
