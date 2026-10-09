conditional_lottery <- function(z, strata) {
  check_assignment(z)
  if (length(strata) != length(z) || anyNA(strata)) stop("Invalid lottery strata")
  groups <- split(seq_along(z), as.character(strata))
  probability <- numeric(length(z))
  for (indices in groups) probability[indices] <- mean(z[indices])
  denominator <- sum(probability * (1 - probability))
  if (denominator <= 0) stop("No lottery stratum contains both treatment arms")
  list(
    groups = groups, probability = probability, denominator = denominator,
    weights = (z - probability) / denominator
  )
}

# Each column is a fixed feasible outcome reconstruction. Draws are shared across
# columns but independent across rows and are generated after selecting witnesses.
lottery_reference <- function(outcomes, z, strata, draws = 9999L) {
  if (!is.matrix(outcomes) || nrow(outcomes) != length(z) ||
        ncol(outcomes) < 1 || any(!is.finite(outcomes)) ||
        length(draws) != 1 || !is.finite(draws) || draws < 1 || draws != floor(draws)) {
    stop("Invalid reconstructed outcomes or draw count")
  }
  design <- conditional_lottery(z, strata)
  reference <- matrix(0, draws, ncol(outcomes))
  for (indices in design$groups) {
    size <- length(indices)
    treated <- sum(z[indices])
    if (treated == 0 || treated == size) next
    if (lchoose(size, treated) <= log(5000)) {
      subsets <- combn(size, treated)
      draw_indices <- sample.int(ncol(subsets), draws, replace = TRUE)
    } else {
      subsets <- replicate(draws, sample.int(size, treated))
      subsets <- matrix(subsets, nrow = treated)
      draw_indices <- seq_len(draws)
    }
    for (column in seq_len(ncol(outcomes))) {
      values <- outcomes[indices, column]
      totals <- colSums(matrix(values[subsets], nrow = treated))
      centered <- totals[draw_indices] - treated / size * sum(values)
      reference[, column] <- reference[, column] + centered / design$denominator
    }
  }
  colnames(reference) <- colnames(outcomes)
  reference
}

lottery_tail_summary <- function(reference, observed, family_size = length(observed),
                                 family_error = .05) {
  if (!is.matrix(reference) || nrow(reference) < 1 || ncol(reference) != length(observed) ||
        any(!is.finite(c(reference, observed))) || length(family_size) != 1 ||
        !is.finite(family_size) || family_size < length(observed) ||
        family_size != floor(family_size) || length(family_error) != 1 ||
        !is.finite(family_error) || family_error <= 0 || family_error >= 1) {
    stop("Invalid Monte Carlo summary inputs")
  }
  draws <- nrow(reference)
  tolerance <- 1e-10 * pmax(1, abs(observed))
  successes <- colSums(sweep(abs(reference), 2, abs(observed) - tolerance, ">="))
  tail <- family_error / (2 * family_size)
  lower <- upper <- numeric(length(observed))
  for (i in seq_along(observed)) {
    lower[i] <- if (successes[i] == 0) 0 else qbeta(tail, successes[i], draws - successes[i] + 1)
    upper[i] <- if (successes[i] == draws) {
      1
    } else {
      qbeta(1 - tail, successes[i] + 1, draws - successes[i])
    }
  }
  data.frame(
    statistic = observed, exceedances = successes, draws,
    p_mc = (successes + 1) / (draws + 1), p_lower = lower, p_upper = upper,
    null_sd_mc = apply(reference, 2, sd)
  )
}

# The union of two source-covering injections splits into switchable components.
# Greedy whole-component flips find a witness, not a global p-value optimum.
blend_linkages <- function(weights, outcomes, left, right) {
  n <- length(weights)
  valid <- function(map) {
    length(map) == n && !anyNA(map) && !anyDuplicated(map) &&
      all(map >= 1 & map <= length(outcomes) & map == floor(map))
  }
  if (!valid(left) || !valid(right) || any(!is.finite(c(weights, outcomes)))) {
    stop("Invalid injection or values")
  }
  groups <- injection_components(left, right)
  gain <- vapply(groups, function(i) sum(weights[i] * (outcomes[right[i]] - outcomes[left[i]])),
                 numeric(1))
  base <- sum(weights * outcomes[left])
  improve <- function(selected) {
    value <- base + sum(gain[selected])
    repeat {
      alternatives <- value + ifelse(selected, -gain, gain)
      best <- which.min(abs(alternatives))
      if (abs(alternatives[best]) >= abs(value) - 1e-12) break
      selected[best] <- !selected[best]
      value <- alternatives[best]
    }
    list(selected = selected, value = value)
  }
  fits <- list(improve(rep(FALSE, length(groups))), improve(rep(TRUE, length(groups))))
  fit <- fits[[which.min(vapply(fits, function(x) abs(x$value), numeric(1)))]]
  map <- left
  for (indices in groups[fit$selected]) map[indices] <- right[indices]
  stopifnot(!anyDuplicated(map), abs(sum(weights * outcomes[map]) - fit$value) < 1e-7)
  map
}

# For two injections, shared donor use connects the source indices that must move together.
injection_components <- function(left, right) {
  n <- length(left)
  valid <- function(map) {
    is.numeric(map) && length(map) == n && n > 0 && all(is.finite(map)) &&
      all(map >= 1 & map == floor(map)) && !anyDuplicated(map)
  }
  if (!valid(left) || !valid(right)) stop("Requires two equal-length injections")
  parent <- seq_len(n)
  root <- function(i) {
    while (parent[i] != i) i <- parent[i]
    i
  }
  partner <- match(left, right)
  for (i in which(!is.na(partner))) {
    parent[root(i)] <- root(partner[i])
  }
  component <- vapply(seq_len(n), root, integer(1))
  split(seq_len(n), component)
}

# Optimize within the switchable family defined by an accepted and alternative map.
# This family supplies feasible sensitivity witnesses, not global graph extrema.
budget_linkage <- function(weights, outcomes, accepted, alternative, budget, direction) {
  groups <- injection_components(accepted, alternative)
  if (length(weights) != length(accepted) || any(!is.finite(c(weights, outcomes))) ||
        any(c(accepted, alternative) > length(outcomes)) || length(budget) != 1 ||
        !is.finite(budget) || budget < 0 || budget > length(accepted) ||
        budget != floor(budget) || length(direction) != 1 || !direction %in% c("min", "max")) {
    stop("Invalid budget, direction, weights, or donor values")
  }
  costs <- vapply(groups, function(i) sum(accepted[i] != alternative[i]), integer(1))
  gains <- vapply(groups, function(i) {
    sum(weights[i] * (outcomes[alternative[i]] - outcomes[accepted[i]]))
  }, numeric(1))
  active <- which(costs > 0)
  if (!length(active) || budget == 0) return(accepted)
  fit <- lpSolve::lp(direction, gains[active], matrix(costs[active], nrow = 1),
                     "<=", budget, all.bin = TRUE)
  if (fit$status != 0) stop("Component-budget optimization failed")
  chosen <- active[fit$solution > .5]
  map <- accepted
  for (i in groups[chosen]) map[i] <- alternative[i]
  stopifnot(!anyDuplicated(map), sum(map != accepted) <= budget)
  map
}
