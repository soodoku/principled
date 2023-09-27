"
 YG Survey Experiment
"

# Set options
options(stringsAsFactors = FALSE)

# Set Working dir.
setwd(dropboxdir)

# Sourcing Common Functions
# Installing goji
# devtools::install_github("soodoku/goji")
library(goji)

# Load data
yg         <- foreign::read.spss("principled/data/yougov_june_2018/VAND0025_OUTPUT.sav", to.data.frame = TRUE)
names(yg)  <- tolower(names(yg))

# PID
table(yg$pid3, yg$pid7)
table(yg$pid3pre, yg$pid7pre)

yg$pid3pre_r <-  car::recode(yg$pid7, "c('Strong Democrat', 'Not very strong Democrat', 'Lean Democrat') = 'Democrat'; 
	                               c('Lean Republican', 'Not very strong Republican', 'Strong Republican') = 'Republican'")
	
yg$pid3_r <-  car::recode(yg$pid7, "c('Strong Democrat', 'Not very strong Democrat', 'Lean Democrat') = 'Democrat'; 
	                               c('Lean Republican', 'Not very strong Republican', 'Strong Republican') = 'Republican'")

# Political Knowledge
yg$know1_r	<- nona(yg$know1 == "Speaker of the House of Representatives")
yg$know2_r	<- nona(yg$know2 == "Chancellor of Germany")
yg$know3_r	<- nona(yg$know3 == "6 years")
yg$know4_r	<- nona(yg$know4 == "Republicans control both the House of Representatives and the Senate")
yg$know5_r	<- nona(yg$know5 == "Charlottesville, Virginia")
yg$know6_r	<- nona(yg$know6 == "Immigration and border security")

yg$know		<- with(yg, rowMeans(cbind(know1_r, know2_r, know3_r, know4_r, know5_r, know6_r)))

# Treatment
table(yg$article_treat)
# Control article, Democrats unbiased article, Democrats biased article, Republicans unbiased article, Republicans biased article
yg$three_cat <- car::recode(yg$article_treat, "c('Democrats unbiased article', 'Republicans unbiased article') = 'Unbiased'; c('Democrats biased article', 'Republicans biased article') = 'Biased'")

# Traits
trt_code     <- "'Very poorly' = 0; 'Somewhat poorly' = .25; 'Neither well nor poorly' = .50; 'Somewhat well' = .75; 'Very well' = 1"
trt_rev_code <- "'Very poorly' = 1; 'Somewhat poorly' = .75; 'Neither well nor poorly' = .50; 'Somewhat well' = .25; 'Very well' = 0"

src_dv       <- paste0(c("dem", "gop"), rep(c("_open_reason", "_patriotic", "_sincere"), each = 2))
src_dv_rev   <- paste0(c("dem", "gop"), rep(c("_ignorant", "_hypocritical", "_smug"), each = 2))

dst_dv       <- paste0(src_dv, "_r")
dst_dv_rev   <- paste0(src_dv_rev, "_r")

yg[, dst_dv]     <- lapply(yg[, src_dv], function(x) car::recode(x, trt_code, as.factor = FALSE))
yg[, dst_dv_rev] <- lapply(yg[, src_dv_rev], function(x) car::recode(x, trt_rev_code, as.factor = FALSE))

trt_battery <- c("open_reason", "patriotic", "sincere", "ignorant", "hypocritical", "smug")

# Sanity check
cor(yg[, paste0("dem_", trt_battery, "_r")], use = "na.or.complete")
cor(yg[, paste0("gop_", trt_battery, "_r")], use = "na.or.complete")

yg$rep_traits <- rowMeans(yg[, paste0("gop_", trt_battery, "_r")], na.rm = T)
yg$dem_traits <- rowMeans(yg[, paste0("dem_", trt_battery, "_r")], na.rm = T)

yg$rd_traits  <- rowMeans(yg[, paste0("gop_", trt_battery, "_r")] - yg[, paste0("dem_", trt_battery, "_r")], na.rm = T)

# Therms
yg$ftdems    <- as.numeric(yg$ftdems)
yg$ftreps    <- as.numeric(yg$ftreps)
yg$fttrump   <- as.numeric(yg$fttrump)
yg$ftclinton <- as.numeric(yg$ftclinton)
yg$ftobama   <- as.numeric(yg$ftobama)

yg$rdtherm   <- yg$ftreps - yg$ftdems

# Save data
write.csv(yg, file = "principled/data/yougov_june_2018/yg_recode.csv", row.names = FALSE)

# What did we learn?
library(dplyr)

table(yg$pid3_r, yg$article_treat)

yg[, c("article_treat", "pid3_r", "rep_traits", "dem_traits", "rd_traits", "ftdems", "ftreps")] %>% 
  filter(pid3_r != "Not sure") %>%
  filter(!(article_treat == "Democrats biased article" &  pid3_r == "Republican")) %>%
  filter(!(article_treat == "Republicans unbiased article" &  pid3_r == "Republican")) %>%
  filter(!(article_treat == "Democrats biased article" &  pid3_r == "Independent")) %>%
  filter(!(article_treat == "Democrats unbiased article" &  pid3_r == "Independent")) %>%
  group_by(article_treat, pid3_r) %>%
  summarize_all(funs(mean), na.rm = TRUE) %>%
  arrange(pid3_r)

yg [, c("rep_traits", "dem_traits", "pid3pre")] %>% 
  group_by(pid3pre) %>%
  summarize_all(funs(mean), na.rm = TRUE)

dem_treats <- subset(yg, pid3_r == "Democrat"    & article_treat %in% c("Control article", "Democrats biased article", "Republicans unbiased article"))
rep_treats <- subset(yg, pid3_r == "Republican"  & article_treat %in% c("Control article", "Democrats unbiased article", "Republicans biased article"))
ind_treats <- subset(yg, (pid3_r == "Independent" | pid3_r == "Not sure") & article_treat %in% c("Control article", "Republicans unbiased article", "Republicans biased article"))

agg <- rbind(dem_treats, rep_treats, ind_treats)
agg$inparty_trt  <- ifelse(agg$pid3_r == "Democrat", agg$dem_traits, agg$rep_traits)
agg$outparty_trt <- ifelse(agg$pid3_r == "Democrat" | agg$pid3_r == "Independent" | agg$pid3_r == "Not sure", agg$rep_traits, agg$dem_traits)

with(dem_treats, summary(lm(dem_traits ~ article_treat)))
with(dem_treats, summary(lm(rep_traits ~ article_treat)))

with(rep_treats, summary(lm(dem_traits ~ article_treat)))
with(rep_treats, summary(lm(rep_traits ~ article_treat)))

with(ind_treats, summary(lm(rep_traits ~ article_treat)))

with(agg[!(agg$pid3_r == "Independent" | agg$pid3_r == "Not sure"), ], summary(lm(outparty_trt ~ I(three_cat == "Unbiased") + I(three_cat == "Biased"))))

with(agg, summary(lm(outparty_trt ~ I(three_cat == "Unbiased") + I(three_cat == "Biased"))))

agg_model <- lm(outparty_trt ~ I(three_cat == "Unbiased") + I(three_cat == "Biased"), data = agg)

# Pretty out
library(stargazer)
stargazer(agg_model,
    label = "yg_results",
    title = "Effect of Partisan Responses on Partisan Affect",
    align = TRUE,
    dep.var.labels = "Out-Party Traits",
    covariate.labels = c("Unbiased", "Biased"),
    keep.stat = c("n", "rsq"),
    out = "principled/tabs/yg_tab.tex")

