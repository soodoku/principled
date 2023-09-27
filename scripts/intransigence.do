cd "/Users/Doug/Dropbox/xperceive/partisanScandal/PartisanResponse/data"

insheet using "partisanresponse.csv", names clear

*Dropping participants who fail pretreatment attention check
drop if attn_check_1 != .
drop if attn_check_2 != .
drop if attn_check_4 != .
drop if attn_check_6 != .
drop if attn_check_7 != .
drop if attn_check_8 != .
drop if attn_check_9 != .
drop if attn_check_10 != .
drop if attn_check_3 != 1
drop if attn_check_5 != 1

*Generating some variables to identify conditions and groups
*Conditions
gen condition = .
replace condition = 0 if q48 == 1
replace condition = 1 if dt == 1
replace condition = 2 if dc == 1
replace condition = 3 if rt == 1
replace condition = 4 if rc == 1

gen pid_7 = .
replace pid_7 = 1 if pid == 1 & pid_d == 1
replace pid_7 = 2 if pid == 1 & pid_d == 2
replace pid_7 = 3 if inlist(pid,3,4) & pid_i == 3
replace pid_7 = 4 if inlist(pid,3,4) & pid_i == 2
replace pid_7 = 5 if inlist(pid,3,4) & pid_i == 1
replace pid_7 = 6 if pid == 2 & pid_r == 2
replace pid_7 = 7 if pid == 2 & pid_r == 1

gen pid_3 = .
replace pid_3 = 1 if inrange(pid_7,1,3)
replace pid_3 = 3 if inrange(pid_7,5,7)
replace pid_3 = 2 if pid_7 == 4

gen pid_f = abs(pid_7 - 4) / 3

gen dem_party_strength = .
replace dem_party_strength = 0 if pid_7 == 3
replace dem_party_strength = 0.5 if pid_7 == 2
replace dem_party_strength = 1 if pid_7 == 1


*IN-OUT conditions
gen io_cond = ""
replace io_cond = "control" if condition == 0
replace io_cond = "in-group" if inlist(condition,1,2) & pid_3 == 1
replace io_cond = "in-group" if inlist(condition,3,4) & pid_3 == 3
replace io_cond = "out-group" if inlist(condition,1,2) & pid_3 == 3
replace io_cond = "out-group" if inlist(condition,3,4) & pid_3 == 1

gen in_cond = 0
replace in_cond = 1 if io_cond == "in-group"
gen out_cond = 0
replace out_cond = 1 if io_cond == "out-group"

*Conditions for "in-party reacts" and "out-party reacts"
gen react_cond = ""
replace react_cond = "control" if condition == 0
replace react_cond = "in-party reacts" if condition == 2 & pid_3 == 1
replace react_cond = "in-party reacts" if condition == 4 & pid_3 == 3
replace react_cond = "in-party ignores" if condition == 1 & pid_3 == 1
replace react_cond = "in-party ignores" if condition == 3 & pid_3 == 3
replace react_cond = "out-party reacts" if condition == 2 & pid_3 == 3
replace react_cond = "out-party reacts" if condition == 4 & pid_3 == 1
replace react_cond = "out-party ignores" if condition == 1 & pid_3 == 3
replace react_cond = "out-party ignores" if condition == 3 & pid_3 == 1
gen ip_reacts = 0
replace ip_reacts = 1 if condition == 2 & pid_3 == 1
replace ip_reacts = 1 if condition == 4 & pid_3 == 3
gen ip_ignores = 0
replace ip_ignores = 1 if condition == 1 & pid_3 == 1
replace ip_ignores = 1 if condition == 3 & pid_3 == 3
gen op_reacts = 0
replace op_reacts = 1 if condition == 2 & pid_3 == 3
replace op_reacts = 1 if condition == 4 & pid_3 == 1
gen op_ignores = 0
replace op_ignores = 1 if condition == 1 & pid_3 == 3
replace op_ignores = 1 if condition == 3 & pid_3 == 1

gen dems_ignore = 0
replace dems_ignore = 1 if condition == 1
gen dems_react = 0
replace dems_react = 1 if condition == 2
gen reps_ignore = 0
replace reps_ignore = 1 if condition == 3
gen reps_react = 0
replace reps_react = 1 if condition == 4
gen control = 0
replace control = 1 if condition == 0

*Value labels
label define condition1 0 "Control" 1 "Democrats--No Response" 2 "Democrats--Response" 3 "Republicans--No Response" 4 "Republicans--Response"  
label values condition condition1

*Generating some dependent variables
*Feeling thermometers
gen ft_dem = .
replace ft_dem = ft_1 if ft_1 != .
replace ft_dem = q53_1 if q53_1 != .

gen ft_rep = .
replace ft_rep = ft_2 if ft_2 != .
replace ft_rep = q53_2 if q53_2 != .

gen ft_in_out = .
replace ft_in_out = ft_dem - ft_rep if inrange(pid_3,1,3)
replace ft_in_out = ft_rep - ft_dem if inrange(pid_3,5,7)

gen ft_in = .
replace ft_in = ft_dem if pid_3 == 1
replace ft_in = ft_rep if pid_3 == 3
gen ft_out = .
replace ft_out = ft_dem if pid_3 == 3
replace ft_out = ft_rep if pid_3 == 1

*Trait ratings
gen dems_ignorant = .
replace dems_ignorant = dem_traits_1
replace dems_ignorant = v124 if v124 != .
gen dems_sincere = .
replace dems_sincere = dem_traits_2
replace dems_sincere = v125 if v125 != .
gen dems_open = .
replace dems_open = dem_traits_3
replace dems_open = v126 if v126 != .
gen dems_smug = .
replace dems_smug = dem_traits_4
replace dems_smug = v127 if v127 != .
gen dems_selfish = .
replace dems_selfish = dem_traits_5
replace dems_selfish = v128 if v128 != .
gen dems_patriotic = .
replace dems_patriotic = dem_traits_6
replace dems_patriotic = v129 if v129 != .
gen dems_compassionate = .
replace dems_compassionate = dem_traits_7
replace dems_compassionate = v130 if v130 != .
gen dems_hypocritical = .
replace dems_hypocritical = dem_traits_8
replace dems_hypocritical = v131 if v131 != .

gen reps_ignorant = .
replace reps_ignorant = rep_traits_1
replace reps_ignorant = v116 if v116 != .
gen reps_sincere = .
replace reps_sincere = rep_traits_2
replace reps_sincere = v117 if v117 != .
gen reps_open = .
replace reps_open = rep_traits_3
replace reps_open = v118 if v118 != .
gen reps_smug = .
replace reps_smug = rep_traits_4
replace reps_smug = v119 if v119 != .
gen reps_selfish = .
replace reps_selfish = rep_traits_5
replace reps_selfish = v120 if v120 != .
gen reps_patriotic = .
replace reps_patriotic = rep_traits_6
replace reps_patriotic = v121 if v121 != .
gen reps_compassionate = .
replace reps_compassionate = rep_traits_7
replace reps_compassionate = v122 if v122 != .
gen reps_hypocritical = .
replace reps_hypocritical = rep_traits_8
replace reps_hypocritical = v123 if v123 != .

gen dems_not_ignorant = 6 - dems_ignorant
gen reps_not_ignorant = 6 - reps_ignorant
gen dems_not_smug = 6 - dems_smug
gen reps_not_smug = 6 - reps_smug
gen dems_not_selfish = 6 - dems_selfish
gen reps_not_selfish = 6 - reps_selfish
gen dems_not_hypocritical = 6 - dems_hypocritical
gen reps_not_hypocritical = 6 - reps_hypocritical

egen dems_tr_avg = rowmean(dems_sincere dems_open dems_patriotic dems_compassionate dems_not_ignorant dems_not_smug dems_not_selfish dems_not_hypocritical)
egen reps_tr_avg = rowmean(reps_sincere reps_open reps_patriotic reps_compassionate reps_not_ignorant reps_not_smug reps_not_selfish reps_not_hypocritical)

replace dems_tr_avg = (dems_tr_avg - 1) / 4
replace reps_tr_avg = (reps_tr_avg - 1) / 4

gen tr_inout = dems_tr_avg - reps_tr_avg if pid_3 == 1
replace tr_inout = reps_tr_avg - dems_tr_avg if pid_3 == 3

egen dems_tr_avg_5 = rowmean(dems_sincere dems_open dems_patriotic dems_not_ignorant dems_not_hypocritical)
egen reps_tr_avg_5 = rowmean(reps_sincere reps_open reps_patriotic reps_not_ignorant reps_not_hypocritical)

replace dems_tr_avg_5 = (dems_tr_avg_5 - 1) / 4
replace reps_tr_avg_5 = (reps_tr_avg_5 - 1) / 4

gen tr_inout_5 = dems_tr_avg_5 - reps_tr_avg_5 if pid_3 == 1
replace tr_inout_5 = reps_tr_avg - dems_tr_avg_5 if pid_3 == 3

egen dems_tr_avg_4 = rowmean(dems_sincere dems_open dems_not_ignorant dems_not_hypocritical)
egen reps_tr_avg_4 = rowmean(reps_sincere reps_open reps_not_ignorant reps_not_hypocritical)

replace dems_tr_avg_4 = (dems_tr_avg_4 - 1) / 4
replace reps_tr_avg_4 = (reps_tr_avg_4 - 1) / 4

gen tr_inout_4 = dems_tr_avg_4 - reps_tr_avg_4 if pid_3 == 1
replace tr_inout_4 = reps_tr_avg_4 - dems_tr_avg_4 if pid_3 == 3

*Party placements
gen dem_place = .
replace dem_place = pty_place_1
replace dem_place = q56_1 if q56_1 != .

gen rep_place = .
replace rep_place = pty_place_2
replace rep_place = q56_2 if q56_2 != .

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

*Summarizing DVs
bys condition: sum ft_dem
bys condition: sum ft_rep

bys condition: sum ft_dem if pid_3 == 3
bys condition: sum ft_dem if pid_3 == 1
bys condition: sum ft_rep if pid_3 == 1
bys condition: sum ft_rep if pid_3 == 3

bys condition: sum ft_in_out if pid_3 == 1
bys condition: sum ft_in_out if pid_3 == 3

bys condition: sum dem_place
bys condition: sum rep_place

bys condition: sum dems_tr_avg if pid_3 == 1
bys condition: sum dems_tr_avg if pid_3 == 3
bys condition: sum reps_tr_avg if pid_3 == 1
bys condition: sum reps_tr_avg if pid_3 == 3

*Are people simply reacting to the elites' actions detailed in the story? (Seems to be "yes.")
ttest ft_in_out if inlist(io_cond,"in-group","out-group"), by(io_cond) unequal

*Versus differences in rank-and-file reaction, where we get no movement.
bys react_cond: sum ft_in_out if inlist(pid_3,1,3)
ttest ft_in_out if inlist(react_cond,"in-party reacts","in-party ignores"), by(react_cond) unequal
ttest ft_in_out if inlist(react_cond,"out-party reacts","out-party ignores"), by(react_cond) unequal
ttest ft_in if inlist(react_cond,"in-party reacts","in-party ignores"), by(react_cond) unequal
ttest ft_out if inlist(react_cond,"out-party reacts","out-party ignores"), by(react_cond) unequal

*TRAITS
regress reps_tr_avg reps_ignore reps_react dems_ignore dems_react if pid_3 == 1
	regress reps_tr_avg reps_ignore reps_react if pid_3 == 1 & inlist(condition,0,3,4)
	regress reps_tr_avg reps_ignore if pid_3 == 1 & inlist(condition,3,4)
regress reps_tr_avg_5 reps_ignore reps_react dems_ignore dems_react if pid_3 == 1
regress reps_tr_avg_4 reps_ignore reps_react dems_ignore dems_react if pid_3 == 1

regress tr_inout reps_ignore reps_react dems_ignore dems_react if pid_3 == 1
	regress tr_inout reps_ignore reps_react if pid_3 == 1 & inlist(condition,0,3,4)
		outreg2 using main_table, word se auto(3) replace
	regress tr_inout reps_ignore if pid_3 == 1 & inlist(condition,3,4)
regress tr_inout_5 reps_ignore reps_react dems_ignore dems_react if pid_3 == 1
regress tr_inout_4 reps_ignore reps_react dems_ignore dems_react if pid_3 == 1

ciplot tr_inout if pid_3 == 1 & inlist(condition,0,3,4), by(condition) yt("In-Party - Out-Party Trait Rating Index") xt("Condition") scheme(lean2) yl(,nogrid) text(0.349 2.1 "0.349 (0.241)", place(e) size(small)) text(0.406 5.1 "0.406 (0.271)", place(e) size(small)) text(0.340 8.1 "0.340 (0.242)", place(e) size(small))

regress tr_inout ip_reacts ip_ignores op_reacts op_ignores if inlist(pid_3,1,3)

*Indepenents on traits
gen tr_demrep = dems_tr_avg - reps_tr_avg
regress tr_demrep dems_ignore dems_react reps_ignore reps_react if pid_3 == 2

*Interaction with PID
regress tr_inout reps_ignore##c.dem_party_strength if pid_3 == 1 & (condition == 0 | reps_ignore == 1)
regress tr_inout reps_ignore##c.dem_party_strength if pid_3 == 1 & (reps_react == 1 | reps_ignore == 1)
regress tr_inout reps_ignore##c.dem_party_strength reps_react##c.dem_party_strength if pid_3 == 1 & (condition == 0 | reps_ignore == 1 | reps_react == 1)

*Binary strong/weak PID
regress tr_inout reps_ignore if pid_7 == 1 & (condition == 0 | reps_ignore == 1)
		outreg2 using binary_interaction_table, word se auto(3) replace
regress tr_inout reps_ignore if inlist(pid_7,2,3) & (condition == 0 | reps_ignore == 1)
		outreg2 using binary_interaction_table, word se auto(3) append
regress tr_inout reps_ignore if pid_7 == 1 & (reps_react == 1 | reps_ignore == 1)
		outreg2 using binary_interaction_table, word se auto(3) append
regress tr_inout reps_ignore if inlist(pid_7,2,3) & (reps_react == 1 | reps_ignore == 1)
		outreg2 using binary_interaction_table, word se auto(3) append

*The table I want in the paper:
regress tr_inout reps_ignore##c.dem_party_strength if pid_3 == 1 & (condition == 0 | reps_ignore == 1)
	outreg2 using interaction_table, word se auto(3) replace
regress tr_inout reps_ignore##c.dem_party_strength if pid_3 == 1 & (reps_react == 1 | reps_ignore == 1)
	outreg2 using interaction_table, word se auto(3) append
	
*POWER ANALYSIS FOR TESS
bys condition: sum tr_inout if inlist(condition,3,4) & pid_3 == 1
sampsi .340 .406, sd1(.24) sd2(.27)

*In-party reaction
regress tr_inout in_cond out_cond if pid_3 == 1
regress tr_inout dems_ignore dems_react if pid_3 == 1 & inlist(condition,0,1,2)
	outreg2 using inparty_table, word se auto(3) replace
regress tr_inout dems_react if pid_3 == 1 & inlist(condition,1,2)
regress tr_inout dems_ignore##c.dem_party_strength if pid_3 == 1 & inlist(condition,0,1)
regress tr_inout dems_react##c.dem_party_strength if pid_3 == 1 & inlist(condition,0,2)
regress tr_inout dems_react##c.dem_party_strength if pid_3 == 1 & inlist(condition,1,2)
regress tr_inout dems_react##c.dem_party_strength dems_ignore##c.dem_party_strength if pid_3 == 1 & inlist(condition,0,1,2)
	outreg2 using inparty_interaction_table, word se auto(3) replace

regress tr_inout dems_react dems_ignore if pid_7 == 1 & inlist(condition,0,1,2)
regress tr_inout dems_react dems_ignore if inrange(pid_7,2,3) & inlist(condition,0,1,2)

