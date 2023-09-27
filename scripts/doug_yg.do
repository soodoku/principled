use "/Users/Doug/Dropbox/principled/Data/yougov_june_2018/merged_worldview.dta", clear

*Party and treatment variables
gen party = ""
replace party = "Democratic" if inrange(pid7pre,1,3)
replace party = "Republican" if inrange(pid7pre,5,7)
replace party = "Independent" if pid7pre == 4

gen dems_unbiased = 0
replace dems_unbiased = 1 if article_treat == 2
gen dems_biased = 0
replace dems_biased = 1 if article_treat == 3
gen reps_unbiased = 0
replace reps_unbiased = 1 if article_treat == 4
gen reps_biased = 0
replace reps_biased = 1 if article_treat == 5

gen op_unbiased = 0 if inlist(party,"Democratic","Republican")
replace op_unbiased = 1 if (party == "Democratic" & reps_unbiased == 1) | (party == "Republican" & dems_unbiased == 1)
gen ip_biased = 0 if inlist(party,"Democratic","Republican")
replace ip_biased = 1 if (party == "Democratic" & dems_biased == 1) | (party == "Republican" & reps_biased == 1)

*FT transformations
gen ft_op = ftdems_w18 if party == "Republican"
replace ft_op = ftreps_w18 if party == "Democratic"
gen ft_ip = ftdems_w18 if party == "Democratic"
replace ft_ip = ftreps_w18 if party == "Republican"
gen ft_inout = ft_ip - ft_op

*Trait ratings
bys party: sum dem_smug

recode *_ignorant (1 = 0)(2 = 0.25)(3 = 0.5)(4 = 0.75)(5 = 1)
recode *_sincere (1 = 0)(2 = 0.25)(3 = 0.5)(4 = 0.75)(5 = 1)
recode *_open_reason (1 = 0)(2 = 0.25)(3 = 0.5)(4 = 0.75)(5 = 1)
recode *_smug (1 = 0)(2 = 0.25)(3 = 0.5)(4 = 0.75)(5 = 1)
recode *_patriotic (1 = 0)(2 = 0.25)(3 = 0.5)(4 = 0.75)(5 = 1)
recode *_hypocritical (1 = 0)(2 = 0.25)(3 = 0.5)(4 = 0.75)(5 = 1)

recode dem_ignorant (0 = 1)(0.25 = 0.75)(0.5 = 0.5)(0.75 = 0.25)(1 = 0), gen(dem_ignorant_rc)
recode gop_ignorant (0 = 1)(0.25 = 0.75)(0.5 = 0.5)(0.75 = 0.25)(1 = 0), gen(gop_ignorant_rc)
recode dem_smug (0 = 1)(0.25 = 0.75)(0.5 = 0.5)(0.75 = 0.25)(1 = 0), gen(dem_smug_rc)
recode gop_smug (0 = 1)(0.25 = 0.75)(0.5 = 0.5)(0.75 = 0.25)(1 = 0), gen(gop_smug_rc)
recode dem_hypocritical (0 = 1)(0.25 = 0.75)(0.5 = 0.5)(0.75 = 0.25)(1 = 0), gen(dem_hypocritical_rc)
recode gop_hypocritical (0 = 1)(0.25 = 0.75)(0.5 = 0.5)(0.75 = 0.25)(1 = 0), gen(gop_hypocritical_rc)

egen dem_ti = rowmean(dem_ignorant_rc dem_smug_rc dem_hypocritical_rc dem_sincere dem_open_reason dem_patriotic)

egen gop_ti = rowmean(gop_ignorant_rc gop_smug_rc gop_hypocritical_rc gop_sincere gop_open_reason gop_patriotic)

*Analysis

*FTs
reg ftdems_w18 dems_unbiased dems_biased reps_unbiased reps_biased if party == "Democratic"
reg ftdems_w18 dems_unbiased dems_biased reps_unbiased reps_biased if party == "Republican"
reg ftreps_w18 dems_unbiased dems_biased reps_unbiased reps_biased if party == "Democratic"
reg ftreps_w18 dems_unbiased dems_biased reps_unbiased reps_biased if party == "Republican"

reg ft_op ip_biased op_unbiased
reg ft_ip ip_biased op_unbiased

*Traits

*DO NOT RUN THESE --- TREATMENT NOT DISTRIBUTED INDEPENDENTLY OF P'SHIP!!!
*reg dem_ti dems_unbiased dems_biased reps_unbiased reps_biased
*reg gop_ti dems_unbiased dems_biased reps_unbiased reps_biased

	*By partisanship
	bys party: reg dem_ti dems_unbiased dems_biased reps_unbiased reps_biased
	bys party: reg gop_ti dems_unbiased dems_biased reps_unbiased reps_biased


