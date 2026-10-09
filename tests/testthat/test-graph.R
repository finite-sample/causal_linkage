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

test_that("unsupported assignment supports fail explicitly", {
  expect_error(
    sharp_null_p(1:4, c(1, 1, 0, 0), matrix(c(0, 0, 1, 1), 1)),
    "Invalid assignment support"
  )
  a <- assignments(4, 2)
  expect_error(sharp_null_p(1:4, a[1, ], rbind(a, a[1, ])), "Invalid assignment support")
})
