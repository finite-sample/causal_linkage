# All core routines use a fixed anchor population. Zero denotes no counterpart.
check_assignment <- function(z, min_arm = 1L) {
  if (!is.numeric(z) || anyNA(z) || !all(z %in% 0:1) ||
        min(sum(z), sum(1 - z)) < min_arm) {
    stop("Assignment must be binary with sufficiently populated arms")
  }
  invisible(TRUE)
}
contrast <- function(y, z) {
  check_assignment(z)
  if (length(y) != length(z) || any(!is.finite(y))) stop("Invalid outcomes")
  mean(y[z == 1]) - mean(y[z == 0])
}
contrast_weights <- function(z) {
  check_assignment(z)
  z / sum(z) - (1 - z) / sum(1 - z)
}
assignments <- function(n, m, limit = 100000L) {
  if (m < 1 || m >= n || lchoose(n, m) > log(limit)) {
    stop("Invalid or excessive assignment support")
  }
  a <- combn(n, m)
  out <- matrix(0, nrow = ncol(a), ncol = n)
  for (i in seq_len(ncol(a))) out[i, a[, i]] <- 1
  out
}
