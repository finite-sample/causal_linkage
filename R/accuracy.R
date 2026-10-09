# Accuracy-only comparator under binary outcomes and a conserved donor pool.
binary_accuracy_test <- function(outcomes, z, accepted, error_budget) {
  check_assignment(z)
  n <- length(z)
  if (!is.numeric(outcomes) || length(outcomes) != n || anyNA(outcomes) ||
        !all(outcomes %in% 0:1)) {
    stop("Outcomes must be a complete binary vector")
  }
  if (length(accepted) != n || anyNA(accepted) ||
        !identical(sort(as.numeric(accepted)), as.numeric(seq_len(n)))) {
    stop("Accepted linkage must be a complete permutation")
  }
  if (length(error_budget) != 1L || !is.finite(error_budget) ||
        error_budget < 0 || error_budget > n || error_budget != floor(error_budget)) {
    stop("Error budget must be an integer between zero and population size")
  }
  m <- sum(z)
  total <- sum(outcomes)
  q0 <- sum(outcomes[accepted][z == 1])
  support <- seq.int(max(0, m - (n - total)), min(m, total))
  reachable <- support[abs(support - q0) <= floor(error_budget / 2)]
  statistic <- function(q) q / m - (total - q) / (n - m)
  null_stats <- abs(statistic(support))
  probabilities <- dhyper(support, total, n - total, m)
  p_values <- vapply(reachable, function(q) {
    sum(probabilities[null_stats >= abs(statistic(q)) - 1e-12])
  }, numeric(1))
  witness <- function(q) {
    map <- accepted
    change <- as.integer(abs(q - q0))
    if (change == 0L) {
      return(map)
    }
    linked <- outcomes[accepted]
    increase <- q > q0
    treated <- head(which(z == 1 & linked == as.integer(!increase)), change)
    control <- head(which(z == 0 & linked == as.integer(increase)), change)
    map[treated] <- accepted[control]
    map[control] <- accepted[treated]
    map
  }
  q_min <- reachable[which.min(p_values)]
  q_max <- reachable[which.max(p_values)]
  list(
    lower = statistic(min(reachable)), upper = statistic(max(reachable)),
    p_min = min(p_values), p_max = max(p_values), p_value = max(p_values),
    lower_map = witness(min(reachable)), upper_map = witness(max(reachable)),
    most_favorable_map = witness(q_min), least_favorable_map = witness(q_max),
    minimum_absolute_contrast = min(abs(statistic(reachable))),
    maximum_absolute_contrast = max(abs(statistic(reachable))),
    accepted_treated_successes = q0, reachable_treated_successes = reachable,
    null_method = "hypergeometric"
  )
}
