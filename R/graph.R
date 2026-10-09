check_solver_timeout <- function(solver_timeout) {
  if (length(solver_timeout) != 1 || !is.numeric(solver_timeout) ||
        !is.finite(solver_timeout) || solver_timeout < 0 ||
        solver_timeout != floor(solver_timeout) || solver_timeout > .Machine$integer.max) {
    stop("Solver timeout must be a nonnegative integer number of seconds")
  }
  invisible(TRUE)
}

validate_graph <- function(graph, n_donor) {
  if (!is.matrix(graph) || !is.logical(graph) || anyNA(graph) ||
        ncol(graph) != n_donor || nrow(graph) < 1) {
    stop("Invalid candidate graph")
  }
}
# Fixed cardinality is never inferred from the presence of candidate edges.
linkage_bounds <- function(weights, outcomes, graph, support = NULL,
                           outside = rep(FALSE, length(weights)),
                           cardinality = c(sum(!outside), length(weights)),
                           off_graph_budget = 0L, trusted = NULL,
                           trusted_error_budget = 0L, solver_timeout = 0L) {
  check_solver_timeout(solver_timeout)
  validate_graph(graph, length(outcomes))
  n <- nrow(graph)
  b <- ncol(graph)
  if (length(weights) != n || any(!is.finite(c(weights, outcomes))) ||
        length(outside) != n || !is.logical(outside) || anyNA(outside) ||
        length(cardinality) != 2 || any(!is.finite(cardinality)) ||
        any(cardinality != as.integer(cardinality)) || cardinality[1] < 0 ||
        cardinality[2] > n || cardinality[1] > cardinality[2] ||
        off_graph_budget < 0 || trusted_error_budget < 0) {
    stop("Invalid constraints")
  }
  if (any(outside) && (length(support) != 2 || any(!is.finite(support)) ||
                         support[1] > support[2])) {
    stop("Outside options need finite support")
  }
  if (!is.null(trusted) && (length(trusted) != n ||
                              any(!is.na(trusted) & (!trusted %in% 0:b)))) {
    stop("Invalid trusted links")
  }
  e <- which(graph | off_graph_budget > 0, arr.ind = TRUE)
  edge_i <- c(e[, 1], which(outside))
  edge_j <- c(e[, 2], rep(0L, sum(outside)))
  if (!length(edge_i)) stop("No feasible linkage")
  v <- length(edge_i)
  a <- matrix(0, n + b + 2L, v)
  a[cbind(edge_i, seq_len(v))] <- 1
  matched <- edge_j > 0
  a[cbind(n + edge_j[matched], which(matched))] <- 1
  a[n + b + 1L, matched] <- 1
  a[n + b + 2L, matched] <- 1
  dirs <- c(rep("=", n), rep("<=", b), ">=", "<=")
  rhs <- c(rep(1, n + b), cardinality)
  off <- rep(FALSE, v)
  off[matched] <- !graph[cbind(edge_i[matched], edge_j[matched])]
  a <- rbind(a, as.numeric(off))
  dirs <- c(dirs, "<=")
  rhs <- c(rhs, off_graph_budget)
  if (!is.null(trusted)) {
    violation <- !is.na(trusted[edge_i]) & edge_j != trusted[edge_i]
    a <- rbind(a, as.numeric(violation))
    dirs <- c(dirs, "<=")
    rhs <- c(rhs, trusted_error_budget)
  }
  solve_end <- function(direction) {
    value <- numeric(v)
    value[matched] <- weights[edge_i[matched]] * outcomes[edge_j[matched]]
    if (any(!matched)) {
      w <- weights[edge_i[!matched]]
      lo <- pmin(w * support[1], w * support[2])
      hi <- pmax(w * support[1], w * support[2])
      value[!matched] <- if (direction == "min") lo else hi
    }
    fit <- lpSolve::lp(direction, value, a, dirs, rhs, all.bin = TRUE,
                       timeout = as.integer(solver_timeout))
    if (fit$status != 0L) stop("No feasible optimum; lpSolve status ", fit$status)
    chosen <- which(fit$solution > .5)
    map <- integer(n)
    map[edge_i[chosen]] <- edge_j[chosen]
    list(value = sum(value[chosen]), map = map)
  }
  lo <- solve_end("min")
  hi <- solve_end("max")
  list(lower = lo$value, upper = hi$value, lower_map = lo$map, upper_map = hi$map)
}
# Independent reference implementation for small cases only.
enumerate_linkages <- function(graph, outside = rep(FALSE, nrow(graph)),
                               limit = 100000L) {
  validate_graph(graph, ncol(graph))
  if (length(outside) != nrow(graph) || !is.logical(outside) || anyNA(outside)) {
    stop("Invalid outside options")
  }
  maps <- list()
  visit <- function(i, map, used) {
    if (i > nrow(graph)) {
      maps[[length(maps) + 1L]] <<- map
      if (length(maps) > limit) stop("Enumeration limit exceeded")
      return(invisible(NULL))
    }
    choices <- setdiff(which(graph[i, ]), used)
    if (outside[i]) choices <- c(0L, choices)
    for (j in choices) visit(i + 1L, c(map, j), c(used, j))
  }
  visit(1L, integer(), integer())
  if (!length(maps)) {
    return(matrix(integer(), nrow = 0, ncol = nrow(graph)))
  }
  do.call(rbind, maps)
}
# Uniform unconditional coverage under complete random assignment and known
# potential-outcome support. Graph containment failure adds delta to alpha.
causal_bounds <- function(z, outcomes, graph, support, alpha = .05, ...) {
  check_assignment(z)
  if (length(support) != 2 || any(!is.finite(support)) ||
        support[1] > support[2] || any(outcomes < support[1] | outcomes > support[2]) ||
        alpha <= 0 || alpha >= 1) {
    stop("Invalid support or alpha")
  }
  range <- linkage_bounds(contrast_weights(z), outcomes, graph, support, ...)
  width <- diff(support)
  radius <- width * sqrt(log(4 / alpha) / 2) *
    (1 / sqrt(sum(z)) + 1 / sqrt(sum(1 - z)))
  c(
    lower = max(-width, range$lower - radius),
    upper = min(width, range$upper + radius),
    estimator_lower = range$lower, estimator_upper = range$upper
  )
}
roster_bounds <- function(outcomes, graph, off_graph_budget = 0L,
                          trusted = NULL, trusted_error_budget = 0L) {
  m <- nrow(graph)
  n <- length(outcomes)
  if (m >= n) stop("Roster requires treated and control units")
  b <- linkage_bounds(rep(n / (m * (n - m)), m), outcomes, graph,
    off_graph_budget = off_graph_budget, trusted = trusted,
    trusted_error_budget = trusted_error_budget
  )
  offset <- sum(outcomes) / (n - m)
  c(lower = b$lower - offset, upper = b$upper - offset)
}
review_priority <- function(weights, outcomes, graph) {
  base <- linkage_bounds(weights, outcomes, graph)
  base_width <- base$upper - base$lower
  result <- lapply(seq_len(nrow(graph)), function(i) {
    widths <- vapply(which(graph[i, ]), function(j) {
      trusted <- rep(NA_integer_, nrow(graph))
      trusted[i] <- j
      b <- tryCatch(linkage_bounds(weights, outcomes, graph, trusted = trusted),
        error = function(e) NULL
      )
      if (is.null(b)) {
        return(NA_real_)
      }
      b$upper - b$lower
    }, numeric(1))
    widths <- widths[is.finite(widths)]
    data.frame(
      record = i, width = base_width,
      guaranteed_reduction = base_width - max(widths),
      best_reduction = base_width - min(widths)
    )
  })
  do.call(rbind, result)
}
sharp_null_p <- function(y, z, assignment_support = assignments(length(z), sum(z))) {
  check_assignment(z)
  if (!is.matrix(assignment_support) || anyNA(assignment_support) ||
        nrow(assignment_support) == 0 || ncol(assignment_support) != length(z) ||
        any(!assignment_support %in% 0:1) ||
        any(rowSums(assignment_support) != sum(z)) ||
        anyDuplicated(as.data.frame(assignment_support)) ||
        !any(apply(assignment_support, 1, function(a) all(a == z)))) {
    stop("Invalid assignment support")
  }
  observed <- abs(contrast(y, z))
  stats <- apply(assignment_support, 1, function(a) abs(contrast(y, a)))
  mean(stats >= observed - 1e-12)
}
graph_null_p <- function(outcomes, z, graph) {
  maps <- enumerate_linkages(graph)
  if (!nrow(maps)) stop("No feasible linkage")
  a <- assignments(length(z), sum(z))
  max(apply(maps, 1, function(map) sharp_null_p(outcomes[map], z, a)))
}
