testthat::test_that("coding preserves missingness, endpoints, and branch identity", {
  testthat::expect_equal(trait_score(c(1, 3, 5, 8, 9)), c(
    0, 50, 100,
    NA, NA
  ))
  testthat::expect_equal(trait_score(c(1, 3, 5), FALSE), c(100, 50, 0))
  testthat::expect_error(clean_codes(c(1, 7), 1:5), "Unexpected")
  testthat::expect_error(clean_codes(factor(1:3), 1:3))
  testthat::expect_error(coalesce_checked(c(1, NA), c(2, 3)), "Conflicting")
  testthat::expect_equal(coalesce_checked(c(1, NA), c(NA, 3)), c(1, 3))
  testthat::expect_equal(available_mean(data.frame(a = c(NA, 0), b = c(
    NA,
    100
  ))), c(NA, 50))
})

testthat::test_that("MTurk routing and attention conserve the intended sample", {
  d <- read_mturk(file.path(root, "data/raw/mturk.csv"))
  testthat::expect_equal(sum(d$assigned), 919L)
  testthat::expect_equal(sum(d$attention), 891L)
  testthat::expect_equal(sum(d$attention_loose), 892L)
  testthat::expect_equal(sum(d$arm == "Control", na.rm = TRUE), 180L)
  testthat::expect_true(all(is.na(d$article[!d$assigned])))
  testthat::expect_true(all(!is.na(d$dem_ft[d$assigned]) & !is.na(d$rep_ft[d$assigned])))
  z <- d[d$assigned & d$attention & d$party %in% c("Democrat", "Republican"), ]
  testthat::expect_equal(nrow(z), 724L)
  testthat::expect_equal(sum(z$party == "Democrat"), 552L)
  republicans <- z$party == "Republican"
  testthat::expect_equal(
    z$gap_ft[republicans], z$rep_ft[republicans] - z$dem_ft[republicans]
  )
})

testthat::test_that("YouGov routing uses pre-party and thermometers retain their scale", {
  d <- read_yougov(file.path(root, "data/raw/yougov.csv"))
  testthat::expect_equal(as.integer(table(d$party)), c(
    641L, 316L, 492L,
    51L
  ))
  testthat::expect_equal(sum(d$party != d$current_party), 24L)
  testthat::expect_equal(range(d$dem_ft, na.rm = TRUE), c(0, 100))
  testthat::expect_equal(mean(d$dem_ft, na.rm = TRUE), 44.67194, tolerance = 1e-05)
  z <- d[d$party %in% c("Democrat", "Republican"), ]
  testthat::expect_equal(sum(!is.na(z$out_traits)), 1125L)
  testthat::expect_equal(sum(!is.na(z$out_complete)), 1088L)
  testthat::expect_equal(sum(is.na(z$out_ft)), 132L)
  testthat::expect_true(all(z$out_lower <= z$out_upper))
  testthat::expect_true(all(is.na(d$in_ft[!d$party %in% c(
    "Democrat",
    "Republican"
  )])))
})

testthat::test_that("public extracts have only numeric responses and synthetic row identifiers", {
  for (study in c("mturk", "yougov")) {
    d <- read.csv(file.path(root, "data/raw", paste0(study, ".csv")))
    testthat::expect_true(all(vapply(d, is.numeric, logical(1))))
    testthat::expect_identical(d$row_id, seq_len(nrow(d)))
    testthat::expect_false(any(grepl(
      "email|ipaddress|caseid|q73|text|inputzip|starttime|endtime|^v[0-9]+$",
      names(d)
    )))
  }
})
