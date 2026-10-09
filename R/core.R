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
neyman <- function(y, z) {
  check_assignment(z, 2L)
  estimate <- contrast(y, z)
  se <- sqrt(var(y[z == 1]) / sum(z) + var(y[z == 0]) / sum(1 - z))
  c(
    estimate = estimate, se = se, lower = estimate - qnorm(.975) * se,
    upper = estimate + qnorm(.975) * se
  )
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
reconstruct <- function(anchor, donor, map, fields) {
  if (length(map) != nrow(anchor) || anyNA(map) ||
        any(map < 0 | map > nrow(donor) | map != as.integer(map)) ||
        anyDuplicated(map[map > 0])) {
    stop("Map must be an injective partial linkage")
  }
  if (!all(fields %in% names(donor))) stop("Missing donor fields")
  for (field in fields) {
    anchor[[field]] <- donor[[field]][ifelse(map == 0, NA_integer_, map)]
  }
  anchor
}
permutation_expectation <- function(y0, y1, map) {
  n <- length(y0)
  if (n < 2 || length(y1) != n || anyNA(map) || any(map != as.integer(map)) ||
        !identical(sort(as.integer(map)), seq_len(n))) {
    stop("Requires a complete permutation and paired potential outcomes")
  }
  tau <- y1 - y0
  (sum(tau[map == seq_len(n)]) - mean(tau)) / (n - 1)
}
# A two-phase difference estimator; the sample must validate identities and fields.
audit_correct <- function(y_link, z_link, audit, y_true, z_true, n_treated) {
  n <- length(y_link)
  k <- length(audit)
  if (k < 2 || anyDuplicated(audit) || any(!audit %in% seq_len(n)) ||
        length(y_true) != k || length(z_true) != k ||
        length(z_link) != n || any(!z_link %in% 0:1) ||
        any(!z_true %in% 0:1) || any(!is.finite(c(y_link, y_true))) ||
        n_treated < 2 || n - n_treated < 2) {
    stop("Invalid validation sample")
  }
  m <- n_treated
  c0 <- n - m
  score <- function(y, z) y * (z / m - (1 - z) / c0)
  delta <- score(y_true, z_true) - score(y_link[audit], z_link[audit])
  estimate <- sum(score(y_link, z_link)) + n * mean(delta)
  audit_var <- n^2 * (1 - k / n) * var(delta) / k
  pi2 <- k * (k - 1) / (n * (n - 1))
  pair_var <- function(v, size) {
    if (length(v) < 2) {
      return(0)
    }
    length(v) * sum((v - mean(v))^2) / (size^2 * (size - 1) * pi2)
  }
  design_var <- pair_var(y_true[z_true == 1], m) +
    pair_var(y_true[z_true == 0], c0)
  se <- sqrt(audit_var + design_var)
  c(
    estimate = estimate, se = se, lower = estimate - qnorm(.975) * se,
    upper = estimate + qnorm(.975) * se,
    audit_variance = audit_var, design_variance = design_var
  )
}
# This model-based comparator assumes homogeneous effects and a permutation
# drawn independently of assignment; it is intentionally tested outside that model.
attenuation_correct <- function(estimate, se, correct, n) {
  k <- length(correct)
  if (k < 2 || !all(correct %in% 0:1) || k > n) stop("Invalid audit")
  q <- mean(correct)
  kappa <- (n * q - 1) / (n - 1)
  v_kappa <- (n / (n - 1))^2 * (1 - k / n) * var(correct) / k
  if (abs(kappa) < .05) {
    return(c(estimate = NA, se = NA, lower = NA, upper = NA))
  }
  corrected <- estimate / kappa
  corrected_se <- sqrt(se^2 / kappa^2 + estimate^2 * v_kappa / kappa^4)
  c(
    estimate = corrected, se = corrected_se,
    lower = corrected - qnorm(.975) * corrected_se,
    upper = corrected + qnorm(.975) * corrected_se
  )
}
