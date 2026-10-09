library(testthat)
source("../../R/core.R")
source("../../R/graph.R")
source("../../R/lottery.R")

test_that("lottery statistic matches stratum fixed-effect regression", {
  strata <- rep(letters[1:3], c(3, 4, 2))
  z <- c(1, 0, 0, 1, 1, 0, 0, 1, 1)
  y <- c(3, 8, 2, 9, 1, 4, 3, 8, 20)
  design <- conditional_lottery(z, strata)
  expect_equal(sum(design$weights * y), unname(coef(lm(y ~ z + factor(strata)))["z"]))
  expect_equal(design$weights[8:9], c(0, 0))
  expect_equal(sum(design$weights), 0)
  expect_error(conditional_lottery(c(1, 1, 0, 0), c(1, 1, 2, 2)), "both treatment")
})

test_that("conditional draws follow the specified finite lottery law", {
  z <- c(1, 0, 1, 0, 0)
  strata <- c(1, 1, 2, 2, 2)
  y <- cbind(c(0, 2, 1, 4, 8), c(3, 0, 2, 5, 4))
  joint <- expand.grid(first = 1:2, second = 3:5)
  exact <- t(vapply(seq_len(nrow(joint)), function(i) {
    a <- as.numeric(seq_along(z) %in% unlist(joint[i, ]))
    drop(crossprod(conditional_lottery(a, strata)$weights, y))
  }, numeric(2)))
  set.seed(345)
  sampled <- lottery_reference(y, z, strata, 6000)
  expect_true(all(vapply(seq_len(nrow(sampled)), function(i) {
    any(rowSums(abs(sweep(exact, 2, sampled[i, ]))) < 1e-10)
  }, logical(1))))
  expect_equal(colMeans(sampled), colMeans(exact), tolerance = .08)
  expect_equal(colMeans(sampled^2), colMeans(exact^2), tolerance = .2)
})

test_that("Monte Carlo interval conventions handle zero and all exceedances", {
  reference <- cbind(rep(0, 99), rep(2, 99))
  result <- lottery_tail_summary(reference, c(1, 1), family_size = 8)
  expect_equal(result$exceedances, c(0, 99))
  expect_equal(result$p_mc, c(.01, 1))
  expect_equal(result$p_lower[1], 0)
  expect_equal(result$p_upper[2], 1)
  for (i in 1:2) {
    interval <- binom.test(result$exceedances[i], 99, conf.level = 1 - .05 / 8)$conf.int
    expect_equal(c(result$p_lower[i], result$p_upper[i]), as.numeric(interval))
  }
})

test_that("alternating-component blending retains injection and candidate feasibility", {
  set.seed(648)
  for (iteration in 1:20) {
    n <- 6
    donors <- 8
    left <- sample(seq_len(donors), n)
    right <- sample(seq_len(donors), n)
    y <- rnorm(donors)
    w <- rnorm(n)
    map <- blend_linkages(w, y, left, right)
    expect_false(anyDuplicated(map) > 0)
    expect_true(all(map == left | map == right))
    expect_lte(abs(sum(w * y[map])), min(abs(c(sum(w * y[left]), sum(w * y[right])))) + 1e-8)
  }
})

test_that("budgeted component choices attain the enumerated family extrema", {
  accepted <- 1:5
  alternative <- c(2, 1, 6, 5, 4)
  y <- c(0, 5, 1, 7, 4, 9)
  w <- c(1, -1, .5, 1, -1)
  groups <- injection_components(accepted, alternative)
  patterns <- as.matrix(expand.grid(rep(list(c(FALSE, TRUE)), length(groups))))
  maps <- t(apply(patterns, 1, function(selected) {
    map <- accepted
    for (ids in groups[selected]) map[ids] <- alternative[ids]
    map
  }))
  for (budget in 0:5) {
    eligible <- maps[rowSums(sweep(maps, 2, accepted, "!=")) <= budget, , drop = FALSE]
    scores <- apply(eligible, 1, function(map) sum(w * y[map]))
    low <- budget_linkage(w, y, accepted, alternative, budget, "min")
    high <- budget_linkage(w, y, accepted, alternative, budget, "max")
    expect_equal(sum(w * y[low]), min(scores))
    expect_equal(sum(w * y[high]), max(scores))
    expect_lte(sum(blend_linkages(w, y, accepted, low) != accepted), budget)
  }
  expect_error(injection_components(1:2, 1:3), "equal-length")
  expect_error(injection_components(c(1, 1), 1:2), "injections")
  expect_error(budget_linkage(w, y, accepted, alternative, .5, "min"), "budget")
  expect_error(budget_linkage(w, y, accepted, alternative, 1, "minimum"), "direction")
  expect_error(lottery_tail_summary(matrix(0, 3, 1), 1, family_error = NA), "inputs")
})
