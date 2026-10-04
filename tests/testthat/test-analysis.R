testthat::test_that("the unstratified contrast reproduces Welch independently", {
  d <- data.frame(party = "D", arm = rep(c("A", "B"), c(7, 5)), y = c(
    1,
    2, 4, 7, 8, 9, 10, 0, 1, 2, 2, 3
  ), weight = 1)
  r <- estimate_contrast(d, "y", c(A = 1, B = -1))
  ref <- t.test(d$y[d$arm == "A"], d$y[d$arm == "B"])
  testthat::expect_equal(r$estimate, unname(ref$estimate[1] - ref$estimate[2]))
  testthat::expect_equal(c(r$low, r$high), as.numeric(ref$conf.int))
  testthat::expect_equal(r$df, unname(ref$parameter))
  testthat::expect_equal(r$p, ref$p.value)
})

testthat::test_that("weighted cell variance matches the independent sandwich implementation", {
  d <- data.frame(party = "D", arm = rep(c("A", "B"), each = 8), y = c(
    0:7,
    4:11
  ), weight = c(1:8, 8:1))
  r <- estimate_contrast(d, "y", c(B = 1, A = -1), TRUE)
  fit <- lm(y ~ factor(arm), weights = weight, data = d)
  testthat::expect_equal(r$estimate, unname(coef(fit)[2]))
  testthat::expect_equal(r$se, sqrt(sandwich::vcovHC(fit, type = "HC3")[
    2,
    2
  ]))
})

testthat::test_that("fixed strata recover planted heterogeneous effects despite arm imbalance", {
  d <- expand.grid(party = c("D", "R"), arm = c("A", "B"), draw = 1:20)
  d$weight <- 1
  effect <- ifelse(d$party == "D", 2, 8)
  d$y <- ifelse(d$party == "D", 50, 20) + ifelse(d$arm == "A", effect, 0) +
    rep(c(-1, 1), each = 4, length.out = nrow(d))
  r <- estimate_contrast(d, "y", c(A = 1, B = -1), shares = c(
    D = 0.75,
    R = 0.25
  ))
  testthat::expect_equal(r$estimate, 3.5)
  testthat::expect_equal(r$n, 80L)
})

testthat::test_that("published contrasts agree with independent raw-cell calculations", {
  m <- read_mturk(file.path(root, "data/raw/mturk.csv"))
  m <- m[m$assigned & m$attention & m$party %in% c("Democrat", "Republican"), ]
  r <- estimate_contrast(m, "in_ft", c(`In decline` = 1, `In stable` = -1))
  testthat::expect_equal(r$estimate, -4.3327808, tolerance = 1e-07)
  testthat::expect_equal(r$se, 2.315162, tolerance = 1e-06)
  y <- read_yougov(file.path(root, "data/raw/yougov.csv"))
  y <- y[y$party %in% c("Democrat", "Republican"), ]
  r <- estimate_contrast(y, "out_traits", c(Unbiased = 1, Control = -1))
  means <- with(y, tapply(out_traits, list(party, arm), mean, na.rm = TRUE))
  effect_d <- means["Democrat", "Unbiased"] - means["Democrat", "Control"]
  effect_r <- means["Republican", "Unbiased"] - means["Republican", "Control"]
  ref <- (641 * effect_d + 492 * effect_r) / 1133
  testthat::expect_equal(r$estimate, unname(ref))
  testthat::expect_equal(r$estimate, 2.5280713, tolerance = 1e-07)
  testthat::expect_equal(r$n, 752L)
})

testthat::test_that("case deletion calculations equal actual refits with fixed target shares", {
  d <- data.frame(party = rep(c("D", "R"), each = 12), arm = rep(rep(c(
    "A",
    "B"
  ), each = 6), 2), y = c(0:11, 1:12), weight = rep(1:6, 4))
  for (weighted in c(FALSE, TRUE)) {
    shares <- party_shares(d, weighted)
    ref <- vapply(seq_len(nrow(d)), function(i) {
      estimate_contrast(d[-i, ], "y", c(A = 1, B = -1), weighted, shares)$estimate
    }, numeric(1))
    r <- contrast_influence(d, "y", c(A = 1, B = -1), weighted)
    testthat::expect_equal(c(r$deletion_min, r$deletion_max), range(ref))
  }
})

testthat::test_that("bounds and randomization checks honor missingness and finite draws", {
  d <- data.frame(party = "D", arm = rep(c("A", "B"), each = 4), y = c(
    50,
    50, 50, NA, 25, 25, 25, 25
  ), weight = 1)
  b <- missing_bounds(d, "y", c(A = 1, B = -1))
  testthat::expect_equal(c(b$low, b$high), c(12.5, 37.5))
  a <- permutation_check(d, "y", c(A = 1, B = -1), draws = 99L)
  testthat::expect_equal(a, permutation_check(d, "y", c(A = 1, B = -1),
    draws = 99L
  ))
  testthat::expect_equal(a$p, (a$exceedances + 1) / 100)
  testthat::expect_gte(a$p, 0.01)
})

test_that("stratified intervals cover a known effect in heterogeneous samples", {
  set.seed(82714)
  d <- expand.grid(person = seq_len(60), party = c("D", "R"), arm = c(
    "T",
    "C"
  ))
  d$weight <- 1
  results <- replicate(400, {
    effect <- ifelse(d$party == "D", 2, 6)
    noise <- rnorm(nrow(d), sd = ifelse(d$party == "D", 7, 14))
    d$y <- ifelse(d$party == "D", 20, 50) + ifelse(d$arm == "T", effect, 0) + noise
    r <- estimate_contrast(d, "y", c(T = 1, C = -1))
    c(estimate = r$estimate, covers = r$low <= 4 & r$high >= 4)
  })
  expect_lt(abs(mean(results["estimate", ]) - 4), 0.4)
  expect_true(mean(results["covers", ]) > 0.9 && mean(results["covers", ]) < 0.99)
})
