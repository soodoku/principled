args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1L) stop("Supply the directory containing the original study folders.")

source_dir <- normalizePath(args[1])

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

dir.create("docs", showWarnings = FALSE)

mt_path <- file.path(source_dir, "mturk_as/partisanresponse.csv")

yg_path <- file.path(source_dir, "yougov_june_2018/VAND0025_OUTPUT.sav")

mt <- read.csv(mt_path, check.names = TRUE)

names(mt) <- tolower(names(mt))

mt_fields <- c(
  "gender", "age", "educ", "race", "ethn", "pid", "pid_d", "pid_r",
  "pid_i", "pol_int", paste0("attn_check_", 1:10), "know1", "know2", "know5",
  "know6", "know7", "dt", "dc", "rt", "rc", "q48", "ft_1", "ft_2", "q53_1",
  "q53_2", unlist(lapply(c("dem", "rep"), function(p) {
    c(paste0(p, "_traits_", 1:8), paste0(p, "_traits_", 1:8, ".1"))
  }))
)

stopifnot(nrow(mt) == 930L, !anyDuplicated(mt$v1))

mt <- mt[, mt_fields]

stopifnot(all(vapply(mt, is.numeric, logical(1))))

mt <- data.frame(row_id = seq_len(nrow(mt)), mt)

yg <- haven::read_sav(yg_path, user_na = TRUE)

yg_fields <- c(
  "weight", "article_treat", "pid3pre", "pid7pre", "pid3", "pid7",
  "polinterest", "trust_gov", "threat", "attack", paste0("know", 1:6), "birthyr",
  "gender", "educ", "race", "ftdems", "ftreps", unlist(lapply(
    c("dem", "gop"),
    function(p) {
      paste0(p, "_", c(
        "ignorant", "sincere", "open_reason", "smug", "patriotic",
        "hypocritical"
      ))
    }
  )), "aware", "control_check", "dem_check", "rep_check"
)

stopifnot(nrow(yg) == 1500L, !anyDuplicated(yg$caseid))

dictionary <- do.call(rbind, lapply(yg_fields, function(n) {
  v <- yg[[n]]
  labs <- attr(v, "labels")
  data.frame(
    study = "YouGov", field = n, label = attr(v, "label"),
    codes = paste(paste(unname(labs), names(labs), sep = "="), collapse = "; "),
    missing = paste(attr(v, "na_values"), collapse = "; ")
  )
}))

yg <- as.data.frame(lapply(yg[, yg_fields], as.numeric))

yg <- data.frame(row_id = seq_len(nrow(yg)), yg)

write.csv(mt, "data/raw/mturk.csv", row.names = FALSE, na = "")

write.csv(yg, "data/raw/yougov.csv", row.names = FALSE, na = "")

write.csv(dictionary, "docs/yougov_dictionary.csv", row.names = FALSE)

manifest <- data.frame(
  source = c("mturk_as/partisanresponse.csv", "yougov_june_2018/VAND0025_OUTPUT.sav"),
  sha256 = vapply(c(mt_path, yg_path), digest::digest, character(1),
    file = TRUE,
    algo = "sha256"
  ), rows = c(nrow(mt), nrow(yg)), retained_columns = c(
    ncol(mt),
    ncol(yg)
  )
)

write.csv(manifest, "docs/source_manifest.csv", row.names = FALSE)
