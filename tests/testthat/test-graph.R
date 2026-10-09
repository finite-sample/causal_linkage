library(testthat)
source("../../R/core.R")
source("../../R/graph.R")

test_that("optimization agrees with independent enumeration on random graphs", {
  set.seed(722)
  for (r in 1:40) {
    n <- sample(2:5, 1)
    b <- n + 1L
    g <- matrix(runif(n * b) < .4, n, b)
    g[cbind(1:n, 1:n)] <- TRUE
    outside <- rep(r %% 2 == 0, n)
    w <- rnorm(n)
    y <- runif(b, -1, 2)
    maps <- enumerate_linkages(g, outside)
    values <- apply(maps, 1, function(map) {
      observed <- map > 0
      v <- sum(w[observed] * y[map[observed]])
      c(
        v + sum(pmin(-w[!observed], 2 * w[!observed])),
        v + sum(pmax(-w[!observed], 2 * w[!observed]))
      )
    })
    fit <- linkage_bounds(w, y, g, c(-1, 2), outside)
    expect_equal(fit$lower, min(values[1, ]))
    expect_equal(fit$upper, max(values[2, ]))
  }
})

test_that("outside options and error budgets are substantive constraints", {
  g <- matrix(TRUE, 2, 2)
  full <- linkage_bounds(c(.5, .5), c(0, 10), g)
  expect_equal(c(full$lower, full$upper), c(5, 5))
  partial <- linkage_bounds(c(.5, .5), c(0, 10), g, c(0, 10), c(TRUE, TRUE))
  expect_equal(c(partial$lower, partial$upper), c(0, 10))
  g <- diag(2) == 0
  fixed <- linkage_bounds(c(1, -1), c(0, 10), g)
  repaired <- linkage_bounds(c(1, -1), c(0, 10), g, off_graph_budget = 2)
  expect_equal(fixed$lower, 10)
  expect_equal(repaired$lower, -10)
  expect_error(linkage_bounds(c(1, 1), c(0, 1), g, trusted = 1:2), "feasible")
  expect_equal(linkage_bounds(c(1, -1), c(0, 10), matrix(TRUE, 2, 2),
                 trusted = 2:1, trusted_error_budget = 2
               )$lower, -10)
  expect_error(linkage_bounds(1:2, c(0, 1), matrix(FALSE, 2, 2)), "feasible")
})

test_that("roster bounds maintain total treated and identify controls by complement", {
  y <- c(0, 1, 3, 7)
  g <- matrix(TRUE, 2, 4)
  maps <- enumerate_linkages(g)
  values <- apply(maps, 1, function(map) contrast(y, as.numeric(1:4 %in% map)))
  expect_equal(unname(roster_bounds(y, g)), range(values))
})

test_that("zero local outcome range can carry global review value", {
  g <- rbind(c(TRUE, TRUE, FALSE), c(TRUE, FALSE, TRUE))
  p <- review_priority(c(.5, .5), c(0, 0, 100), g)
  expect_equal(p$best_reduction[1], 50)
  expect_equal(p$guaranteed_reduction[1], 0)
})

test_that("graph-max sharp-null test controls exact randomization size", {
  y <- c(0, 1, 4, 6, 8, 11)
  g <- diag(6) == 1
  g[1:2, 1:2] <- TRUE
  p <- apply(assignments(6, 3), 1, function(z) graph_null_p(y, z, g))
  for (alpha in c(.05, .1, .2, .5)) expect_lte(mean(p <= alpha), alpha + 1e-12)
})

test_that("estimator bounds differ from causal confidence sets", {
  z <- c(1, 1, 0, 0)
  y <- c(1, 1, 0, 0)
  b <- causal_bounds(z, y, diag(4) == 1, c(0, 1))
  expect_equal(unname(b["estimator_lower"]), 1)
  expect_lt(b["lower"], b["estimator_lower"])
  expect_error(causal_bounds(z, y, diag(4) == 1, c(0, .5)), "support")
})

test_that("unsupported assignment and roster contracts fail explicitly", {
  expect_error(
    sharp_null_p(1:4, c(1, 1, 0, 0), matrix(c(0, 0, 1, 1), 1)),
    "Invalid assignment support"
  )
  a <- assignments(4, 2)
  expect_error(sharp_null_p(1:4, a[1, ], rbind(a, a[1, ])), "Invalid assignment support")
  expect_error(
    roster_bounds(1:4, matrix(TRUE, 2, 4), outside = c(TRUE, TRUE)),
    "unused argument"
  )
  expect_error(permutation_expectation(1:2, 2:3, c(1.5, 2.5)), "complete permutation")
})
