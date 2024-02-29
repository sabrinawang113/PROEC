********************************************************************************
*	Do-file:		5AN_clogit_cat.do
*	Project:		PROEC: Proteomics for endometrial cancer case-control
*
*	Data used:		PROEC_coredata_olk5075.dta
*
*	Data created:	or_`model'_cat3.dta
*
* 	Purpose:  		conditional logistic regression on EC risk
*					For proteins with 50-75% samples below LOD: 
*					analyse as 3 categories - below LOD, lower, upper
*
*	Date:			05-MAY-2023
*	Author: 		Sabrina Wang
********************************************************************************

// run the 0_settings.do for this project
capture log close 
cd "$PROEClog"
log using "5AN_clogit_cat$current_date", replace
set linesize 255

di "Stata Version: `c(stata_version)'"
di "Current Date: `c(current_date)'"

*cap ssc install schemepack, replace
set scheme tab2
graph set window fontface "Helvetica"

********************************************************************************

// import data
* load data in program
* PROEC_coredata
global dataset = "PROEC_coredata"

cd "$PROECderived"
use $dataset, clear

********************************************************************************

//bmi & wc categorical
cap drop bmibin
gen bmibin =0 if bmi_categ==1 | bmi_categ==2
replace bmibin =1 if bmi_categ==3 | bmi_categ==4
tab bmibin bmi_categ

cap drop wcbin
gen wcbin =0 if waist_c<=80 
replace wcbin =1 if waist_c>80 & waist_c<. 
tab wcbin

cap drop wccat
gen wccat =0 if waist_c<=80 
replace wccat =1 if waist_c>80 & waist_c<=88 
replace wccat =2 if waist_c>88 & waist_c<. 
tab wccat

cap drop bmicat
gen bmicat =0 if bmi_categ==1 | bmi_categ==2
replace bmicat =1 if bmi_categ==3
replace bmicat =2 if bmi_categ==4
tab bmicat

cd "$PROECderived"
save $dataset, replace

********************************************************************************

// Olink proteins

global olk_5075 = ///
"olk_mcp_3_infl olk_il_17a_infl olk_il_10ra_infl olk_fgf_5_infl olk_prdx3_ir olk_egln1_ir olk_jun_ir olk_prkcq_ir olk_spry2_ir olk_dapp1_ir olk_il12rb1_ir olk_kpna1_ir olk_il5_ir"

********************************************************************************

// Conditional regression

*=======================*
*	clogit_or program	*
*=======================*
cap program drop clogit_or
program clogit_or
syntax, file(string) covar(string)

	cd "$PROECderived"
	use $dataset, clear // dataset

	cd "$PROECderived"
	tempname temp1
	postfile `temp1' str35	model str35 protein  ///
					 double n or lci uci pval	///
					 using `file', replace

	* clogit for olk_5075
	foreach protein of varlist $olk_5075 {
		
		* categorise protein (3 cats)
		gen cat_`protein' = outdq_`protein'
		recode cat_`protein' 0=1 1=0
		sum `protein' if cat_`protein'==1,d
		recode cat_`protein' 1=2 if r(p50)<`protein'
		tab cat_`protein',m
		
		* clogit 
		clogit eccase i.cat_`protein' `covar', group(match_caseset) or
		local n	= e(N)
		matrix b = r(table)
		local or = b[1,3]
		local lci = b[5,3]
		local uci = b[6,3]
		local pval = b[4,3]

		post `temp1' ("`file'") ("`protein'") (`n') (`or') (`lci') (`uci') (`pval')
	}
	postclose `temp1'

	* merge in protein summary
	cd "$PROECderived"
	use `file', clear
	merge 1:1 protein using olink_summary
	drop if _merge==2
	drop _merge
	
	* compute qvalue	
	cap drop qvalue npvalue
	qqvalue pval , method(simes) qvalue(qvalue) npvalue(npvalue)
	sort qvalue
	order qvalue npvalue, after(pval)
	
	* export as excel
	sort protein
	save `file', replace
	cd "$PROECoutput"
	
	tostring or lci uci, replace force format(%9.2f)
	tostring pval qvalue, replace force format(%9.3f)
	gen estimate = or + " ("+lci +"–"+ uci+")"
	
	tostring lod_pbelow, replace force format(%9.2f)
	tostring normality_w, replace force format(%9.2f)
		
	keep model panel protein n estimate pval qvalue lod_pbelow normality_w outl_3sd outl_sdqcfail outl_3iqr outl_iqrqcfail
	order model panel protein n estimate pval qvalue lod_pbelow normality_w outl_3sd outl_sdqcfail outl_3iqr outl_iqrqcfail
	export excel using "tab_PROEC_clogit_cat.xlsx", firstrow(variables) sheet("`file'", replace) keepcellfmt

end 


*2yrbl
cap program drop clogit_or_2yrbl
program clogit_or_2yrbl
syntax, file(string) covar(string)

	cd "$PROECderived"
	use $dataset, clear // dataset

	*exclude cases diagnosed 2 years from blood collection
	sum time_bld_diag
	count if time_bld_diag < 2
	drop if time_bld_diag < 2
	* exclude the matched case or control
	duplicates tag match_caseset, gen(matched) 
	tab matched,m
	drop if matched==0
	drop matched
	tab eccase,m

	cd "$PROECderived"
	tempname temp1
	postfile `temp1' str35	model str35 protein  ///
					 double n or lci uci pval	///
					 using `file', replace

	* clogit for olk_5075
	foreach protein of varlist $olk_5075 {
		
		* categorise protein (3 cats)
		gen cat_`protein' = outdq_`protein'
		recode cat_`protein' 0=1 1=0
		sum `protein' if cat_`protein'==1,d
		recode cat_`protein' 1=2 if r(p50)<`protein'
		tab cat_`protein',m
		
		* clogit 
		clogit eccase i.cat_`protein' `covar', group(match_caseset) or
		local n	= e(N)
		matrix b = r(table)
		local or = b[1,3]
		local lci = b[5,3]
		local uci = b[6,3]
		local pval = b[4,3]

		post `temp1' ("`file'") ("`protein'") (`n') (`or') (`lci') (`uci') (`pval')
	}
	postclose `temp1'

	* merge in protein summary
	cd "$PROECderived"
	use `file', clear
	merge 1:1 protein using olink_summary
	drop if _merge==2
	drop _merge
	
	* compute qvalue	
	cap drop qvalue npvalue
	qqvalue pval , method(simes) qvalue(qvalue) npvalue(npvalue)
	sort qvalue
	order qvalue npvalue, after(pval)
	
	* export as excel
	sort protein
	save `file', replace
	cd "$PROECoutput"
	
	tostring or lci uci, replace force format(%9.2f)
	tostring pval qvalue, replace force format(%9.3f)
	gen estimate = or + " ("+lci +"–"+ uci+")"
	
	tostring lod_pbelow, replace force format(%9.2f)
	tostring normality_w, replace force format(%9.2f)
		
	keep model panel protein n estimate pval qvalue lod_pbelow normality_w outl_3sd outl_sdqcfail outl_3iqr outl_iqrqcfail
	order model panel protein n estimate pval qvalue lod_pbelow normality_w outl_3sd outl_sdqcfail outl_3iqr outl_iqrqcfail
	export excel using "tab_PROEC_clogit_cat.xlsx", firstrow(variables) sheet("`file'", replace) keepcellfmt

end 


*keep only post-menopausal 
cap program drop clogit_or_meno
program clogit_or_meno
syntax, file(string) covar(string)

	cd "$PROECderived"
	use $dataset, clear // dataset

	*tab menop_bld eccase,m
	keep if menop_bld ==1 | menop_bld ==3
	duplicates tag match_caseset, gen(matched) 
	tab matched,m // all matched
	drop matched

	cd "$PROECderived"
	tempname temp1
	postfile `temp1' str35	model str35 protein  ///
					 double n or lci uci pval	///
					 using `file', replace

	* clogit for olk_5075
	foreach protein of varlist $olk_5075 {
		
		* categorise protein (3 cats)
		gen cat_`protein' = outdq_`protein'
		recode cat_`protein' 0=1 1=0
		sum `protein' if cat_`protein'==1,d
		recode cat_`protein' 1=2 if r(p50)<`protein'
		tab cat_`protein',m
		
		* clogit 
		clogit eccase i.cat_`protein' `covar', group(match_caseset) or
		local n	= e(N)
		matrix b = r(table)
		local or = b[1,3]
		local lci = b[5,3]
		local uci = b[6,3]
		local pval = b[4,3]

		post `temp1' ("`file'") ("`protein'") (`n') (`or') (`lci') (`uci') (`pval')
	}
	postclose `temp1'

	* merge in protein summary
	cd "$PROECderived"
	use `file', clear
	merge 1:1 protein using olink_summary
	drop if _merge==2
	drop _merge
	
	* compute qvalue	
	cap drop qvalue npvalue
	qqvalue pval , method(simes) qvalue(qvalue) npvalue(npvalue)
	sort qvalue
	order qvalue npvalue, after(pval)
	
	* export as excel
	sort protein
	save `file', replace
	cd "$PROECoutput"
	
	tostring or lci uci, replace force format(%9.2f)
	tostring pval qvalue, replace force format(%9.3f)
	gen estimate = or + " ("+lci +"–"+ uci+")"
	
	tostring lod_pbelow, replace force format(%9.2f)
	tostring normality_w, replace force format(%9.2f)
		
	keep model panel protein n estimate pval qvalue lod_pbelow normality_w outl_3sd outl_sdqcfail outl_3iqr outl_iqrqcfail
	order model panel protein n estimate pval qvalue lod_pbelow normality_w outl_3sd outl_sdqcfail outl_3iqr outl_iqrqcfail
	export excel using "tab_PROEC_clogit_cat.xlsx", firstrow(variables) sheet("`file'", replace) keepcellfmt

end 


*keep only type 1
cap program drop clogit_or_type1
program clogit_or_type1
syntax, file(string) covar(string)

	cd "$PROECderived"
	use $dataset, clear // dataset

	*keep only type 1
	gen ectype1 = 1 if morpcoru == "8140/3" | morpcoru == "8210/3" | morpcoru == "8480/3" | morpcoru == "8481/3" | morpcoru == "8380/3" | morpcoru == "8560/3" | morpcoru == "8570/3" 
	recode ectype1 .=0 if eccase==0
	tab eccase ectype1,m
	drop if ectype1==.

	duplicates tag match_caseset, gen(matched) 
	tab matched,m
	drop if matched==0
	tab eccase ectype1,m

	cd "$PROECderived"
	tempname temp1
	postfile `temp1' str35	model str35 protein  ///
					 double n or lci uci pval	///
					 using `file', replace

	* clogit for olk_5075
	foreach protein of varlist $olk_5075 {
		
		* categorise protein (3 cats)
		gen cat_`protein' = outdq_`protein'
		recode cat_`protein' 0=1 1=0
		sum `protein' if cat_`protein'==1,d
		recode cat_`protein' 1=2 if r(p50)<`protein'
		tab cat_`protein',m
		
		* clogit 
		clogit eccase i.cat_`protein' `covar', group(match_caseset) or
		local n	= e(N)
		matrix b = r(table)
		local or = b[1,3]
		local lci = b[5,3]
		local uci = b[6,3]
		local pval = b[4,3]

		post `temp1' ("`file'") ("`protein'") (`n') (`or') (`lci') (`uci') (`pval')
	}
	postclose `temp1'

	* merge in protein summary
	cd "$PROECderived"
	use `file', clear
	merge 1:1 protein using olink_summary
	drop if _merge==2
	drop _merge
	
	* compute qvalue	
	cap drop qvalue npvalue
	qqvalue pval , method(simes) qvalue(qvalue) npvalue(npvalue)
	sort qvalue
	order qvalue npvalue, after(pval)
	
	* export as excel
	sort protein
	save `file', replace
	cd "$PROECoutput"
	
	tostring or lci uci, replace force format(%9.2f)
	tostring pval qvalue, replace force format(%9.3f)
	gen estimate = or + " ("+lci +"–"+ uci+")"
	
	tostring lod_pbelow, replace force format(%9.2f)
	tostring normality_w, replace force format(%9.2f)
		
	keep model panel protein n estimate pval qvalue lod_pbelow normality_w outl_3sd outl_sdqcfail outl_3iqr outl_iqrqcfail
	order model panel protein n estimate pval qvalue lod_pbelow normality_w outl_3sd outl_sdqcfail outl_3iqr outl_iqrqcfail
	export excel using "tab_PROEC_clogit_cat.xlsx", firstrow(variables) sheet("`file'", replace) keepcellfmt

end 


// crude 
local file	= "or_crude"
local covar = " "
clogit_or, file("`file'") covar("`covar'")

// minimally adjusted
local file	= "or_minadj"
local covar = "i.pa_index age_menarche i.ftp i.ever_pill i.ever_horm i.smoke_stat"
clogit_or, file("`file'") covar("`covar'")

// adjusted for full list of potential confounders - BMI
local file	= "or_adjfull"
local covar = "i.bmicat i.pa_index age_menarche i.ftp i.ever_pill i.ever_horm i.smoke_stat"
clogit_or, file("`file'") covar("`covar'")

// adjusted for full list of potential confounders - BMI + cpeptide
local file	= "or_adjfull_cpeptide"
local covar = "i.bmicat i.pa_index age_menarche i.ftp i.ever_pill i.ever_horm i.smoke_stat cpept_std"
clogit_or, file("`file'") covar("`covar'")



// exclude cases diagnosed 2 years from blood collection
local file	= "or_2yrbl"
local covar = "i.bmicat i.pa_index age_menarche i.ftp i.ever_pill i.ever_horm i.smoke_stat"
clogit_or_2yrbl, file("`file'") covar("`covar'")

// keep type 1 only
local file	= "or_type1"
local covar = "i.bmicat i.pa_index age_menarche i.ftp i.ever_pill i.ever_horm i.smoke_stat"
clogit_or_type1, file("`file'") covar("`covar'")

// keep post-menopausal only
local file	= "or_meno"
local covar = "i.bmicat i.pa_index age_menarche i.ftp i.ever_pill i.ever_horm i.smoke_stat"
clogit_or_meno, file("`file'") covar("`covar'")



// adjusted for full list of potential confounders - WC
local file	= "or_adjfull_wc"
local covar = "i.wccat i.pa_index age_menarche i.ftp i.ever_pill i.ever_horm i.smoke_stat"
clogit_or, file("`file'") covar("`covar'")


********************************************************************************
log close