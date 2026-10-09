# Full overlap and known assignment are contracts, not inferred from candidates.
bijection_problem <- function(outcomes, z, graph, trusted = NULL,
                              trusted_error_budget = 0L, off_graph_budget = 0L) {
  check_assignment(z)
  n <- length(z)
  validate_graph(graph, n)
  if (nrow(graph) != n || length(outcomes) != n || any(!is.finite(outcomes))) {
    stop("Requires equally sized anchor and donor populations with finite outcomes")
  }
  budgets <- c(trusted_error_budget, off_graph_budget)
  if (length(trusted_error_budget) != 1 || length(off_graph_budget) != 1 ||
        anyNA(budgets) || any(!is.finite(budgets)) ||
        any(budgets < 0 | budgets > n | budgets != floor(budgets))) {
    stop("Budgets must be integer counts between zero and population size")
  }
  if (!is.null(trusted) && (length(trusted) != n || anyNA(trusted) ||
                              !identical(sort(as.numeric(trusted)), as.numeric(seq_len(n))))) {
    stop("Trusted linkage must be a complete permutation")
  }
  if (is.null(trusted) && trusted_error_budget != 0) {
    stop("A trusted-error budget requires a trusted linkage")
  }
  edges <- which(graph | off_graph_budget > 0, arr.ind = TRUE)
  if (!nrow(edges)) stop("No feasible linkage")
  v <- nrow(edges)
  a <- matrix(0, 2 * n, v)
  a[cbind(edges[, 1], seq_len(v))] <- 1
  a[cbind(n + edges[, 2], seq_len(v))] <- 1
  dirs <- rep("=", 2 * n)
  rhs <- rep(1, 2 * n)
  a <- rbind(a, as.numeric(!graph[edges]))
  dirs <- c(dirs, "<=")
  rhs <- c(rhs, off_graph_budget)
  if (!is.null(trusted)) {
    a <- rbind(a, as.numeric(edges[, 2] != trusted[edges[, 1]]))
    dirs <- c(dirs, "<=")
    rhs <- c(rhs, trusted_error_budget)
  }
  centered <- outcomes - mean(outcomes)
  list(
    edges = edges, a = a, dirs = dirs, rhs = rhs,
    costs = contrast_weights(z)[edges[, 1]] * centered[edges[, 2]]
  )
}

# Complete randomization gives the same sharp-null law for every full permutation.
# Binary outcomes use its hypergeometric form; other outcomes enumerate assignments.
graph_information_test <- function(outcomes, z, graph, trusted = NULL,
                                   trusted_error_budget = 0L, off_graph_budget = 0L,
                                   delta = 0, assignment_limit = 100000L,
                                   solver_timeout = 0L) {
  check_solver_timeout(solver_timeout)
  if (length(delta) != 1 || !is.finite(delta) || delta < 0 || delta > 1) {
    stop("Delta must be a reconstruction-containment failure bound in [0, 1]")
  }
  if (!length(outcomes) || any(!is.finite(outcomes))) stop("Invalid outcomes")
  centered <- outcomes - mean(outcomes)
  outcome_scale <- max(abs(centered))
  if (!is.finite(outcome_scale)) {
    stop("Outcome spread exceeds floating-point range; rescale outcomes first")
  }
  if (outcome_scale == 0) outcome_scale <- 1
  normalized <- centered / outcome_scale
  problem <- bijection_problem(
    normalized, z, graph, trusted, trusted_error_budget, off_graph_budget
  )
  v <- nrow(problem$edges)
  two_valued <- length(unique(normalized)) <= 2L
  objective_conversion <- 1
  objective_lower <- 0
  if (two_valued) {
    high <- as.numeric(normalized > min(normalized))
    n <- length(z)
    m <- sum(z)
    problem$costs <- (n * z[problem$edges[, 1]] - m) * high[problem$edges[, 2]]
    objective_conversion <- diff(range(normalized)) / (m * (n - m))
    total_high <- sum(high)
    support_high <- seq.int(max(0, m - (n - total_high)), min(m, total_high))
    objective_lower <- min(abs(n * support_high - m * total_high))
  }
  a <- rbind(
    cbind(problem$a, 0),
    c(problem$costs, -1), c(-problem$costs, -1), c(rep(0, v), 1)
  )
  fit <- lpSolve::lp(
    "min", c(rep(0, v), 1), a, c(problem$dirs, "<=", "<=", ">="),
    c(problem$rhs, 0, 0, objective_lower),
    binary.vec = seq_len(v), int.vec = if (two_valued) v + 1L else integer(),
    timeout = as.integer(solver_timeout)
  )
  if (fit$status != 0L) stop("No feasible optimum; lpSolve status ", fit$status)
  chosen <- which(fit$solution[seq_len(v)] > .5)
  map <- integer(length(z))
  map[problem$edges[chosen, 1]] <- problem$edges[chosen, 2]
  residual <- as.vector(problem$a %*% round(fit$solution[seq_len(v)])) - problem$rhs
  if (length(chosen) != length(z) || any(map == 0) || anyDuplicated(map) ||
        any(abs(residual[problem$dirs == "="]) > 1e-7) ||
        any(residual[problem$dirs == "<="] > 1e-7)) {
    stop("Solver returned an invalid witness")
  }
  statistic <- abs(contrast(normalized[map], z))
  tolerance <- 1e-9
  if (abs(statistic - fit$objval * objective_conversion) > tolerance) {
    stop("Solver objective and witness disagree")
  }
  bounds <- linkage_bounds(
    contrast_weights(z), normalized, graph,
    trusted = trusted,
    trusted_error_budget = trusted_error_budget, off_graph_budget = off_graph_budget,
    solver_timeout = solver_timeout
  )
  maximum <- max(abs(c(bounds$lower, bounds$upper)))
  most_favorable <- if (abs(bounds$lower) >= abs(bounds$upper)) {
    bounds$lower_map
  } else {
    bounds$upper_map
  }
  m <- sum(z)
  n <- length(z)
  if (two_valued) {
    total <- sum(normalized > min(normalized))
    k <- seq.int(max(0, m - (n - total)), min(m, total))
    stats <- abs(k / m - (total - k) / (n - m)) * diff(range(normalized))
    probabilities <- dhyper(k, total, n - total, m)
    p_max <- sum(probabilities[stats >= statistic - tolerance])
    p_min <- sum(probabilities[stats >= maximum - tolerance])
    null_method <- "hypergeometric"
  } else {
    support <- assignments(n, m, assignment_limit)
    stats <- abs(as.vector(support %*% normalized) * (1 / m + 1 / (n - m)))
    p_max <- mean(stats >= statistic - tolerance)
    p_min <- mean(stats >= maximum - tolerance)
    null_method <- "enumerated complete randomization"
  }
  list(
    p_value = min(1, p_max + delta), p_min = p_min, p_max = p_max, delta = delta,
    maximum_absolute_contrast = maximum * outcome_scale, most_favorable_map = most_favorable,
    minimum_absolute_contrast = statistic * outcome_scale, least_favorable_map = map,
    lower = bounds$lower * outcome_scale, upper = bounds$upper * outcome_scale,
    lower_map = bounds$lower_map, upper_map = bounds$upper_map,
    null_method = null_method
  )
}


# Smallest identity budget at which the robust sharp-null test no longer rejects.
graph_breakdown_budget <- function(outcomes, z, graph, accepted, alpha = .05,
                                   off_graph_budget = 0L, delta = 0,
                                   assignment_limit = 100000L, solver_timeout = 0L) {
  check_solver_timeout(solver_timeout)
  if (length(alpha) != 1 || !is.finite(alpha) || alpha < 0 || alpha >= 1) {
    stop("Alpha must be in [0, 1)")
  }
  bijection_problem(outcomes, z, graph, accepted, 0L, off_graph_budget)
  if (is.null(accepted)) stop("An accepted complete linkage is required")
  n <- length(z)
  if (sum(!graph[cbind(seq_len(n), accepted)]) > off_graph_budget) {
    stop("Accepted linkage is not feasible under graph and off-graph budget")
  }
  evaluate <- function(k) {
    graph_information_test(
      outcomes, z, graph, accepted, k, off_graph_budget,
      delta, assignment_limit, solver_timeout
    )
  }
  baseline <- evaluate(0L)
  package_result <- function(k, fit) {
    list(
      budget = k, p_value = fit$p_value, p_max = fit$p_max,
      linkage = fit$least_favorable_map,
      changed = sum(fit$least_favorable_map != accepted),
      alpha = alpha, delta = delta, baseline_p_value = baseline$p_value
    )
  }
  if (baseline$p_value > alpha) {
    return(package_result(0L, baseline))
  }
  upper <- evaluate(n)
  if (upper$p_value <= alpha) {
    return(package_result(Inf, upper))
  }
  low <- 0L
  high <- n
  while (high - low > 1L) {
    middle <- as.integer(floor((low + high) / 2))
    fit <- evaluate(middle)
    if (fit$p_value > alpha) {
      high <- middle
      upper <- fit
    } else {
      low <- middle
    }
  }
  package_result(high, upper)
}
