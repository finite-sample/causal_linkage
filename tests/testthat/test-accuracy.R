library(testthat)
source("../../R/core.R")
source("../../R/graph.R")
source("../../R/accuracy.R")

test_that("binary accuracy bounds equal independent exhaustive permutations", {
  set.seed(1052026)
  for (iteration in seq_len(24)) {
    n <- sample(3:6, 1)
    m <- sample(seq_len(n - 1), 1)
    z <- sample(c(rep(1, m), rep(0, n - m)))
    y <- sample(0:1, n, TRUE)
    accepted <- sample(seq_len(n))
    maps <- enumerate_linkages(matrix(TRUE, n, n))
    support <- assignments(n, sum(z))
    for (budget in seq.int(0L, n)) {
      keep <- apply(maps, 1, function(map) sum(map != accepted) <= budget)
      feasible <- maps[keep, , drop = FALSE]
      values <- apply(feasible, 1, function(map) contrast(y[map], z))
      probabilities <- apply(feasible, 1, function(map) sharp_null_p(y[map], z, support))
      fit <- binary_accuracy_test(y, z, accepted, budget)
      expect_equal(c(fit$lower, fit$upper), range(values))
      expect_equal(c(fit$p_min, fit$p_max), range(probabilities))
      for (name in c("lower_map", "upper_map", "most_favorable_map", "least_favorable_map")) {
        map <- fit[[name]]
        expect_identical(sort(map), seq_len(n))
        expect_lte(sum(map != accepted), budget)
      }
      expect_equal(sharp_null_p(y[fit$least_favorable_map], z, support), fit$p_max)
      expect_equal(sharp_null_p(y[fit$most_favorable_map], z, support), fit$p_min)
    }
  }
})

test_that("identity changes require pairs and success availability limits swaps", {
  y <- c(1, 1, 0, 0, 0, 0)
  z <- c(1, 1, 1, 0, 0, 0)
  expect_equal(binary_accuracy_test(y, z, 1:6, 1)$reachable_treated_successes, 2)
  expect_equal(binary_accuracy_test(y, z, 1:6, 3)$reachable_treated_successes, 1:2)
  expect_equal(binary_accuracy_test(y, z, 1:6, 6)$reachable_treated_successes, 0:2)
  fit <- binary_accuracy_test(rep(1, 6), z, 6:1, 6)
  expect_equal(c(fit$lower, fit$upper, fit$p_min, fit$p_max), c(0, 0, 1, 1))
})

test_that("binary accuracy comparator rejects invalid contracts", {
  expect_error(binary_accuracy_test(c(0, .5), c(1, 0), 1:2, 0), "binary")
  expect_error(binary_accuracy_test(0:1, c(1, 0), c(1, 1), 0), "permutation")
  expect_error(binary_accuracy_test(0:1, c(1, 0), 1:2, NA), "integer")
  expect_error(binary_accuracy_test(0:1, c(1, 0), 1:2, .5), "integer")
  expect_error(binary_accuracy_test(0:1, c(1, 0), 1:2, 3), "integer")
})
