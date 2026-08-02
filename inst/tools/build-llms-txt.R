# Regenerate llms.txt and llms-full.txt from the package's own Rd files.
# These were previously hand-maintained and drifted out of step with the
# code: they advertised a stale version, missing functions, and old
# signatures. Generating them removes that failure mode.
#
# Run from the package root:  Rscript inst/tools/build-llms-txt.R

pkg_root <- normalizePath(".")
desc <- read.dcf(file.path(pkg_root, "DESCRIPTION"))
pkg <- desc[1, "Package"]
version <- desc[1, "Version"]
description <- gsub("\\s+", " ", desc[1, "Description"])
site <- "https://charlescoverdale.github.io/carbondata/"

exports <- sort(grep("^co2_", readLines(file.path(pkg_root, "NAMESPACE")),
                     value = TRUE))
exports <- sub("^export\\(([^)]+)\\).*$", "\\1",
               grep("^export\\(", readLines(file.path(pkg_root, "NAMESPACE")),
                    value = TRUE))
exports <- sort(exports)

rd_files <- list.files(file.path(pkg_root, "man"), pattern = "\\.Rd$",
                       full.names = TRUE)
db <- lapply(rd_files, tools::parse_Rd)
names(db) <- basename(rd_files)

# Cut to at most `n` characters on a word boundary.
.truncate_words <- function(x, n) {
  if (nchar(x) <= n) return(x)
  cut <- substr(x, 1L, n)
  paste0(sub("\\s+\\S*$", "", cut), "...")
}

# Pull one Rd section out as plain text.
section <- function(rd, tag) {
  hit <- Filter(function(x) identical(attr(x, "Rd_tag"), tag), rd)
  if (length(hit) == 0L) return(NULL)
  txt <- paste(vapply(hit, function(h) paste(as.character(unlist(h)), collapse = ""),
                      character(1L)), collapse = "\n")
  txt <- gsub("\\\\(link|code|pkg|file|url|emph|strong)\\{([^{}]*)\\}", "\\2", txt)
  txt <- gsub("[ \t]+", " ", txt)
  trimws(txt)
}

# \arguments{\item{name}{description}}
arguments <- function(rd) {
  args <- Filter(function(x) identical(attr(x, "Rd_tag"), "\\arguments"), rd)
  if (length(args) == 0L) return(character(0L))
  items <- Filter(function(x) identical(attr(x, "Rd_tag"), "\\item"), args[[1L]])
  vapply(items, function(it) {
    nm <- paste(as.character(unlist(it[[1L]])), collapse = "")
    dsc <- paste(as.character(unlist(it[[2L]])), collapse = "")
    dsc <- gsub("\\\\(link|code|pkg|file|url|emph|strong)\\{([^{}]*)\\}", "\\2", dsc)
    dsc <- trimws(gsub("\\s+", " ", dsc))
    sprintf("- `%s` — %s", trimws(nm), dsc)
  }, character(1L))
}

# Map each exported function to the Rd that documents it.
rd_for <- list()
for (nm in names(db)) {
  aliases <- vapply(
    Filter(function(x) identical(attr(x, "Rd_tag"), "\\alias"), db[[nm]]),
    function(a) trimws(paste(as.character(unlist(a)), collapse = "")),
    character(1L)
  )
  for (a in aliases) rd_for[[a]] <- nm
}

# ---- llms.txt: the short index -------------------------------------
short <- c(
  sprintf("# %s", pkg),
  "",
  sprintf("> %s Install with `install.packages(\"%s\")`.",
          .truncate_words(description, 200L), pkg),
  "",
  paste0("Full API reference (for agents): https://raw.githubusercontent.com/",
         "charlescoverdale/carbondata/main/llms-full.txt"),
  "",
  sprintf("Version: %s. License: MIT.", version),
  "",
  "## Functions",
  ""
)
for (fn in exports) {
  rd <- db[[rd_for[[fn]]]]
  title <- section(rd, "\\title") %||% fn
  short <- c(short, sprintf("- [`%s()`](%sreference/%s.html): %s",
                            fn, site, sub("\\.Rd$", "", rd_for[[fn]]),
                            gsub("\n", " ", title)))
}
short <- c(short, "", "## Links", "",
           sprintf("- [Reference site](%s)", site),
           "- [GitHub](https://github.com/charlescoverdale/carbondata)",
           "- [CRAN](https://CRAN.R-project.org/package=carbondata)")
writeLines(short, file.path(pkg_root, "llms.txt"))

# ---- llms-full.txt: the full reference ------------------------------
full <- c(
  sprintf("# %s — full API reference", pkg),
  "",
  sprintf("> %s", description),
  "",
  sprintf("- Version: %s", version),
  sprintf("- Install: `install.packages(\"%s\")`", pkg),
  "- CRAN: https://CRAN.R-project.org/package=carbondata",
  "- GitHub: https://github.com/charlescoverdale/carbondata",
  sprintf("- Reference site: %s", site),
  "",
  "This file is a self-contained reference for LLM agents: every exported",
  "function with its signature, arguments, return value, and example.",
  "",
  "---",
  ""
)
for (fn in exports) {
  rd <- db[[rd_for[[fn]]]]
  full <- c(full,
            sprintf("## `%s()`", fn),
            "",
            sprintf("**%s**", section(rd, "\\title")),
            "")
  d <- section(rd, "\\description")
  if (!is.null(d)) full <- c(full, gsub("\n+", " ", d), "")
  u <- section(rd, "\\usage")
  if (!is.null(u)) full <- c(full, "**Usage**", "", "```r", trimws(u), "```", "")
  a <- arguments(rd)
  if (length(a) > 0L) full <- c(full, "**Arguments**", "", a, "")
  v <- section(rd, "\\value")
  if (!is.null(v)) full <- c(full, "**Returns**", "", gsub("\n+", " ", v), "")
  ex <- section(rd, "\\examples")
  if (!is.null(ex)) {
    ex <- gsub("\\\\donttest\\{|\\\\dontrun\\{", "", ex)
    ex <- sub("\\}\\s*$", "", ex)
    full <- c(full, "**Example**", "", "```r", trimws(ex), "```", "")
  }
  full <- c(full, "---", "")
}
writeLines(full, file.path(pkg_root, "llms-full.txt"))

cat(sprintf("Wrote llms.txt and llms-full.txt for %s %s (%d exports).\n",
            pkg, version, length(exports)))
