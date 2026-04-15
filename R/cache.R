#' Clear the carbondata cache
#'
#' Deletes all locally cached carbon market data files. The next
#' call to any data function will re-download.
#'
#' @return Invisibly returns `NULL`.
#'
#' @family configuration
#' @export
#' @examples
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' co2_clear_cache()
#' options(op)
#' }
co2_clear_cache <- function() {
  d <- co2_cache_dir()
  files <- list.files(d, full.names = TRUE)
  n <- length(files)
  if (n > 0L) unlink(files, recursive = TRUE)
  cli_inform("Removed {n} cached file{?s} from {.path {d}}.")
  invisible(NULL)
}

#' Inspect the local carbondata cache
#'
#' Returns information about the local cache: directory, file count,
#' size, and list of cached files. Useful for debugging stale
#' results or deciding whether to call [co2_clear_cache()].
#'
#' @return A list with elements `dir`, `n_files`, `size_bytes`,
#'   `size_human`, and `files` (a data frame with `name`,
#'   `size_bytes`, `modified`).
#'
#' @family configuration
#' @export
#' @examples
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' co2_cache_info()
#' options(op)
#' }
co2_cache_info <- function() {
  d <- co2_cache_dir()
  empty <- data.frame(
    name = character(0L),
    size_bytes = numeric(0L),
    modified = as.POSIXct(character(0L)),
    stringsAsFactors = FALSE
  )
  paths <- list.files(d, full.names = TRUE)
  if (length(paths) == 0L) {
    return(list(dir = d, n_files = 0L, size_bytes = 0,
                size_human = "0 B", files = empty))
  }
  info <- file.info(paths)
  files <- data.frame(
    name = basename(paths),
    size_bytes = info$size,
    modified = info$mtime,
    stringsAsFactors = FALSE
  )
  files <- files[order(-files$size_bytes), , drop = FALSE]
  rownames(files) <- NULL
  total <- sum(files$size_bytes)
  list(dir = d, n_files = nrow(files), size_bytes = total,
       size_human = co2_format_bytes(total), files = files)
}
