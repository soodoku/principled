cd "~/Dropbox/xperceive/PartisanScandal/data/partisan_response"

insheet using "partisanresponse.csv", names clear

*Dropping participants who fail pretreatment attention check
***COMMENTED OUT AS PER THE POLICY WE SET W/ THE PARTY PROTOTYPES PAPER -- LEAVE THEM IN
*drop if attn_check_1 != .
*drop if attn_check_2 != .
*drop if attn_check_4 != .
*drop if attn_check_6 != .
*drop if attn_check_7 != .
*drop if attn_check_8 != .
*drop if attn_check_9 != .
*drop if attn_check_10 != .
*drop if attn_check_3 != 1
*drop if attn_check_5 != 1

*Coding up political knowledge
recode know1 (1 = 1)(2 = 0)(3 = 0)(4 = 0)(5 = 0)
recode know2 (1 = 1)(2 = 0)(3 = 0)(4 = 0)(5 = 0)
recode know5 (1 = 1)(2 = 0)(3 = 0)(4 = 0)(5 = 0)
recode know6 (1 = 1)(2 = 0)(3 = 0)(4 = 0)(5 = 0)
recode know7 (1 = 1)(2 = 0)(3 = 0)(4 = 0)(5 = 0)
egen know = rowmean(know1 know2 know5 know6 know7)

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

gen strongpartisan = 0
replace strongpartisan = 1 if inlist(pid_7,1,7)

*IN-OUT conditions
gen io_cond = ""
replace io_cond = "control" if condition == 0
replace io_cond = "in-group" if inlist(condition,1,2) & pid_3 == 1
replace io_cond = "in-group" if inlist(condition,3,4) & pid_3 == 3
replace io_cond = "out-group" if inlist(condition,1,2) & pid_3 == 3
replace io_cond = "out-group" if inlist(condition,3,4) & pid_3 == 1

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

gen reps_update = 0
replace reps_update = 1 if condition == 4
gen reps_ignore = 0
replace reps_ignore = 1 if condition == 3

gen dems_update = 0
replace dems_update = 1 if condition == 2
gen dems_ignore = 0
replace dems_ignore = 1 if condition == 1

gen op_response = 0
replace op_response = 1 if (reps_update == 1 & pid_3 == 1) | (dems_update == 1 & pid_3 == 3)
gen op_nonresponse = 0
replace op_nonresponse = 1 if (reps_ignore == 1 & pid_3 == 1) | (dems_ignore == 1 & pid_3 == 3)
gen ip_response = 0
replace ip_response = 1 if (reps_update == 1 & pid_3 == 3) | (dems_update == 1 & pid_3 == 1)
gen ip_nonresponse = 0
replace ip_nonresponse = 1 if (reps_ignore == 1 & pid_3 == 3) | (dems_ignore == 1 & pid_3 == 1)

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

egen dems_tr_avg = rowmean(dems_sincere dems_open dems_compassionate dems_not_ignorant dems_not_smug dems_not_selfish dems_not_hypocritical)
egen reps_tr_avg = rowmean(reps_sincere reps_open reps_compassionate reps_not_ignorant reps_not_smug reps_not_selfish reps_not_hypocritical)

gen op_tr_avg = dems_tr_avg if pid_3 == 3
replace op_tr_avg = reps_tr_avg if pid_3 == 1

	*PCA
	gen op_sincere = dems_sincere if pid_3 == 3
	replace op_sincere = reps_sincere if pid_3 == 1
	gen op_open = dems_open if pid_3 == 3
	replace op_open = reps_open if pid_3 == 1
	gen op_compassionate = dems_compassionate if pid_3 == 3
	replace op_compassionate = reps_compassionate if pid_3 == 1
	gen op_patriotic = dems_patriotic if pid_3 == 3
	replace op_patriotic = reps_patriotic if pid_3 == 1	
	gen op_not_ignorant = dems_not_ignorant if pid_3 == 3
	replace op_not_ignorant = reps_not_ignorant if pid_3 == 1
	gen op_not_smug = dems_not_smug if pid_3 == 3
	replace op_not_smug = reps_not_smug if pid_3 == 1
	gen op_not_selfish = dems_not_selfish if pid_3 == 3
	replace op_not_selfish = reps_not_selfish if pid_3 == 1
	gen op_not_hypocritical = dems_not_hypocritical if pid_3 == 3
	replace op_not_hypocritical = reps_not_hypocritical if pid_3 == 1
	
	pca op_sincere op_open op_compassionate op_patriotic op_not_ignorant op_not_smug op_not_selfish op_not_hypocritical

*0-1 rescale
replace reps_tr_avg = (reps_tr_avg - 1) / 4
replace dems_tr_avg = (dems_tr_avg - 1) / 4
gen trait_diff = .
replace trait_diff = dems_tr_avg - reps_tr_avg if pid_3 == 1
replace trait_diff = reps_tr_avg - dems_tr_avg if pid_3 == 3
replace trait_diff = (trait_diff + 1) / 2

*Party placements
gen dem_place = .
replace dem_place = pty_place_1
replace dem_place = q56_1 if q56_1 != .

gen rep_place = .
replace rep_place = pty_place_2
replace rep_place = q56_2 if q56_2 != .

gen in_perceived_ext = .
replace in_perceived_ext = abs(4 - dem_place) / 3 if pid_3 == 1
replace in_perceived_ext = abs(4 - rep_place) / 3 if pid_3 == 3
gen out_perceived_ext = .
replace out_perceived_ext = abs(4 - dem_place) / 3 if pid_3 == 3
replace out_perceived_ext = abs(4 - rep_place) / 3 if pid_3 == 1

*ANALYSIS
	*COMMENTED OUT -- POOLING OVER PARTIES INSTEAD OF TOSSING GOP-ID'D CASES
	*reg reps_tr_avg i.reps_update##i.strongdem i.reps_ignore##i.strongdem
	*reg reps_tr_avg i.reps_ignore##i.strongdem if inlist(condition,3,4)
	
*PLOT
	*getting estimates--building CSV
	reg reps_tr_avg if pid_7 == 1 & condition == 0
	reg reps_tr_avg if inrange(pid_7,2,3) & condition == 0
	reg reps_tr_avg if pid_7 == 1 & reps_update == 1
	reg reps_tr_avg if inrange(pid_7,2,3) & reps_update == 1
	reg reps_tr_avg if pid_7 == 1 & reps_ignore == 1
	reg reps_tr_avg if inrange(pid_7,2,3) & reps_ignore == 1
	
	*in-party
	reg dems_tr_avg if pid_7 == 1 & condition == 0
	reg dems_tr_avg if inrange(pid_7,2,3) & condition == 0
	reg dems_tr_avg if pid_7 == 1 & reps_update == 1
	reg dems_tr_avg if inrange(pid_7,2,3) & reps_update == 1
	reg dems_tr_avg if pid_7 == 1 & reps_ignore == 1
	reg dems_tr_avg if inrange(pid_7,2,3) & reps_ignore == 1
	
	*Diffs
	reg trait_diff if inlist(pid_7,1,7) & condition == 0
	reg trait_diff if inlist(pid_7,2,3,5,6) & condition == 0
	reg trait_diff if inlist(pid_7,1,7) & react_cond == "in-party reacts"
	reg trait_diff if inlist(pid_7,2,3,5,6) & react_cond == "in-party reacts"
	reg trait_diff if inlist(pid_7,1,7) & react_cond == "in-party ignores"
	reg trait_diff if inlist(pid_7,2,3,5,6) & react_cond == "in-party ignores"
	reg trait_diff if inlist(pid_7,1,7) & react_cond == "out-party reacts"
	reg trait_diff if inlist(pid_7,2,3,5,6) & react_cond == "out-party reacts"
	reg trait_diff if inlist(pid_7,1,7) & react_cond == "out-party ignores"
	reg trait_diff if inlist(pid_7,2,3,5,6) & react_cond == "out-party ignores"


*TABLE
reg trait_diff ip_response ip_nonresponse op_response op_nonresponse 
reg trait_diff ip_response ip_nonresponse op_response op_nonresponse if strongpartisan == 0
reg trait_diff ip_response ip_nonresponse op_response op_nonresponse if strongpartisan == 1
reg trait_diff ip_response##strongpartisan ip_nonresponse##strongpartisan op_response##strongpartisan op_nonresponse##strongpartisan
	
*PLOTTING -- WE ARE SWITCHING DIRECTORIES HERE, PREPARE FOR HYPERSPACE...
cd "~/Dropbox/xperceive/PartisanScandal/tabs"

*PLOT TO USE IN PAPER:
insheet using "partisanresponse_inout_traitdiffs.csv", names clear
label define strong_lbl 0 "Weak/leaning partisans" 1 "Strong partisans", replace
label values strong strong_lbl
eclplot mean_ti l_ti h_ti parmid, rplot(rcap) supby(strong) ///
	yl(,nogrid) xt("Experimental Condition") yt("Evaluative Polarization") ///
	xlab(1.5 "Control" 5.5 "IP Response" 9.5 "IP Nonresponse" 13.5 "OP Response" 17.5 "OP Nonresponse", labs(small)) ///
	xsc(range(0 20))
	
*DEMS ONLY -- INTERESTING WAY TO SEE DATA
insheet using "partisanresponse_demsonly.csv", clear names
eclplot mean_ti l_ti h_ti parmid, rplot(rcap) supby(sw) ///
	yl(,nogrid) xt("Experimental Condition") yt("Mean Party Trait Rating") yline(0.5, lp(dot) lc(gs1)) ///
	xlab(1.5 "Control" 5.5 "Rep. Response" 9.5 "Rep. Nonresponse") xsc(range(0 11)) ///
	text(0.1 1.5 "Ratings of Republicans", size(vsmall)) text(0.8 1.5 "Ratings of Democrats", size(vsmall)) 
