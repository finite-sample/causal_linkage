library(testthat)
source("../../R/core.R")
source("../../R/graph.R")
source("../../R/information.R")

test_that("optimized randomization p-values equal exhaustive linkage calculations", {
  set.seed(3189)
  for (replicate_id in 1:24) {
    n <- sample(3:6, 1)
    m <- sample(seq_len(n - 1), 1)
    z <- c(rep(1, m), rep(0, n - m))
    y <- if (replicate_id %% 2) sample(0:1, n, TRUE) else rnorm(n)
    g <- matrix(runif(n * n) < .45, n, n)
    diag(g) <- TRUE
    trusted <- sample(seq_len(n))
    budget <- sum(trusted != seq_len(n))
    off <- replicate_id %% 3
    maps <- enumerate_linkages(matrix(TRUE, n, n))
    keep <- apply(maps, 1, function(p) {
      sum(p != trusted) <= budget && sum(!g[cbind(seq_len(n), p)]) <= off
    })
    maps <- maps[keep, , drop = FALSE]
    a <- assignments(n, sum(z))
    values <- apply(maps, 1, function(p) contrast(y[p], z))
    p_values <- apply(maps, 1, function(p) sharp_null_p(y[p], z, a))
    fit <- graph_information_test(y, z, g, trusted, budget, off)
    expect_equal(c(fit$lower, fit$upper), range(values))
    expect_equal(fit$minimum_absolute_contrast, min(abs(values)), tolerance = 1e-7)
    expect_equal(fit$p_max, max(p_values))
    expect_equal(fit$p_min, min(p_values))
    expect_equal(sharp_null_p(y[fit$most_favorable_map], z, a), min(p_values))
    expect_equal(abs(contrast(y[fit$least_favorable_map], z)), min(abs(values)))
  }
})

test_that("an interval crossing zero need not contain an attainable zero contrast", {
  g <- matrix(TRUE, 2, 2)
  fit <- graph_information_test(c(0, 2), c(1, 0), g)
  expect_equal(c(fit$lower, fit$upper), c(-2, 2))
  expect_equal(fit$minimum_absolute_contrast, 2)
})

test_that("equal accuracy and degrees can imply different causal conclusions", {
  z <- c(rep(1, 4), rep(0, 4))
  y <- z
  near <- outer(rep(1:4, each = 2), rep(1:4, each = 2), "==")
  labels <- c(1, 1, 2, 3, 2, 4, 3, 4)
  far <- outer(labels, labels, "==")
  trusted <- c(2, 1, 3:8)
  same_arm <- graph_information_test(y, z, near, trusted, 2)
  cross_arm <- graph_information_test(y, z, far, trusted, 2)
  rate <- graph_information_test(y, z, matrix(TRUE, 8, 8), trusted, 2)
  expect_equal(rowSums(near), rowSums(far))
  expect_equal(c(same_arm$lower, same_arm$upper), c(1, 1))
  expect_equal(same_arm$p_max, 2 / choose(8, 4))
  expect_equal(c(cross_arm$lower, cross_arm$upper), c(.5, 1))
  expect_equal(cross_arm$p_max, 34 / choose(8, 4))
  expect_equal(cross_arm$p_max, rate$p_max)
})

test_that("data-adaptive truth-containing graphs still control sharp-null size", {
  y <- c(0, 0, 1, 1, 2, 3)
  a <- assignments(6, 3)
  p <- apply(a, 1, function(z) {
    g <- outer(z, z, "==") | outer(y, y, "==")
    graph_information_test(y, z, g)$p_value
  })
  for (alpha in c(.05, .1, .2, .5)) expect_lte(mean(p <= alpha), alpha + 1e-12)
  fit <- graph_information_test(y, a[1, ], diag(6) == 1, delta = .08)
  expect_equal(fit$p_value, min(1, fit$p_max + .08))
})

test_that("binary inference avoids exponential assignment enumeration", {
  n <- 40
  y <- rep(0:1, each = n / 2)
  fit <- graph_information_test(y, y, diag(n) == 1, assignment_limit = 1)
  expect_equal(fit$p_max, 2 / choose(n, n / 2), tolerance = 1e-20)
  expect_equal(fit$null_method, "hypergeometric")
})

test_that("invalid overlap, budgets, and missing feasible maps fail explicitly", {
  g <- matrix(TRUE, 2, 2)
  expect_error(graph_information_test(0:2, c(1, 0), g), "equally sized")
  expect_error(graph_information_test(0:1, c(1, 0), g, 1:2, .5), "integer")
  expect_error(graph_information_test(0:1, c(1, 0), g, c(1, 1)), "permutation")
  expect_error(graph_information_test(0:1, c(1, 0), g, delta = NA), "Delta")
  expect_error(
    graph_information_test(0:1, c(1, 0), g, trusted_error_budget = 1),
    "requires a trusted"
  )
  expect_error(graph_information_test(0:1, c(1, 0), matrix(FALSE, 2, 2)), "feasible")
  expect_error(graph_information_test(0:1, c(1, 0), diag(2) == 0, 1:2), "feasible")
})

test_that("complete-component width formula accounts for treatment mixing", {
  set.seed(525)
  labels <- c(1, 1, 1, 2, 2, 3, 3)
  graph <- outer(labels, labels, "==")
  for (iteration in 1:12) {
    y <- rnorm(length(labels))
    z <- sample(c(1, 1, 1, 0, 0, 0, 0))
    width <- sum(vapply(unique(labels), function(group) {
      in_group <- labels == group
      values <- sort(y[in_group])
      treated <- sum(z[in_group])
      sum(tail(values, treated)) - sum(head(values, treated))
    }, numeric(1))) * (1 / sum(z) + 1 / sum(1 - z))
    bounds <- linkage_bounds(contrast_weights(z), y, graph)
    expect_equal(bounds$upper - bounds$lower, width)
  }
})

test_that("a shared error budget couples otherwise separate components", {
  z <- c(1, 0, 1, 0)
  y <- c(0, 2, 0, 3)
  g <- outer(c(1, 1, 2, 2), c(1, 1, 2, 2), "==")
  unrestricted <- linkage_bounds(contrast_weights(z), y, g)
  budgeted <- linkage_bounds(contrast_weights(z), y, g,
    trusted = 1:4,
    trusted_error_budget = 2
  )
  expect_equal(unrestricted$upper - unrestricted$lower, 5)
  expect_equal(budgeted$upper - budgeted$lower, 3)
})

test_that("exact inference is invariant to representable affine outcome changes", {
  z <- rep(c(1, 0), each = 4)
  y <- c(4, 3, 2, 1, -1, -2, -3, -4)
  g <- outer(rep(1:4, each = 2), rep(1:4, each = 2), "==")
  reference <- graph_information_test(y, z, g, 1:8, 2)
  for (scale in c(1e-100, 1e-10, 1e100, -1e-100, -1e100)) {
    fit <- graph_information_test(y * scale, z, g, 1:8, 2)
    expect_equal(fit$p_max, reference$p_max)
    expect_equal(fit$p_min, reference$p_min)
    expect_equal(
      fit$minimum_absolute_contrast / abs(scale),
      reference$minimum_absolute_contrast
    )
    expect_equal(
      sort(c(fit$lower, fit$upper) / scale),
      c(reference$lower, reference$upper)
    )
  }
  shifted <- graph_information_test(y + 2^40, z, g, 1:8, 2)
  expect_equal(shifted$p_max, reference$p_max)
  expect_equal(c(shifted$lower, shifted$upper), c(reference$lower, reference$upper))
  binary <- graph_information_test(z * 1e-100, z, diag(8) == 1, assignment_limit = 1)
  expect_equal(binary$p_max, 2 / choose(8, 4))
  constant <- graph_information_test(rep(1e100, 8), z, g, 1:8, 2)
  expect_equal(c(constant$p_min, constant$p_max), c(1, 1))
  expect_equal(c(constant$lower, constant$upper), c(0, 0))
})

test_that("breakdown budget equals exhaustive first nonrejection budget", {
  z <- c(1, 1, 1, 0, 0, 0)
  y <- z
  graph <- matrix(TRUE, 6, 6)
  accepted <- 1:6
  maps <- enumerate_linkages(graph)
  p_values <- apply(maps, 1, function(p) sharp_null_p(y[p], z))
  costs <- apply(maps, 1, function(p) sum(p != accepted))
  for (alpha in c(.05, .1, .3, .9)) {
    fit <- graph_breakdown_budget(y, z, graph, accepted, alpha)
    expected <- min(costs[p_values > alpha])
    expect_equal(fit$budget, expected)
    expect_equal(fit$changed, expected)
    expect_gt(fit$p_value, alpha)
    expect_equal(sharp_null_p(y[fit$linkage], z), fit$p_max)
  }
  at_boundary <- graph_breakdown_budget(y, z, graph, accepted, alpha = .1)
  expect_equal(at_boundary$budget, 2)
  impossible <- graph_breakdown_budget(y, z, diag(6) == 1, accepted, alpha = .1)
  expect_equal(impossible$budget, Inf)
  expect_lte(impossible$p_value, .1)
  adjusted <- graph_breakdown_budget(y, z, graph, accepted, alpha = .1, delta = .01)
  expect_equal(adjusted$budget, 0)
  expect_error(graph_breakdown_budget(y, z, graph, accepted, alpha = 1), "Alpha")
  expect_error(graph_breakdown_budget(y, z, diag(6) == 0, accepted), "not feasible")
  expect_error(graph_breakdown_budget(y, z, graph, NULL), "accepted")
})

test_that("solver time limits are validated and preserve solved results", {
  z <- c(1, 1, 0, 0)
  y <- c(1, 1, 0, 0)
  graph <- diag(4) == 1
  baseline <- graph_information_test(y, z, graph)
  timed <- graph_information_test(y, z, graph, solver_timeout = 1L)
  expect_equal(timed, baseline)
  expect_equal(graph_breakdown_budget(y, z, graph, 1:4, solver_timeout = 1L)$budget, 0)
  for (bad in list(-1, .5, NA, Inf, c(0, 1), "1", .Machine$integer.max + 1)) {
    expect_error(graph_information_test(y, z, graph, solver_timeout = bad), "timeout")
    expect_error(linkage_bounds(contrast_weights(z), y, graph, solver_timeout = bad),
                 "timeout")
    expect_error(graph_breakdown_budget(y, z, graph, 1:4, solver_timeout = bad), "timeout")
  }
})
