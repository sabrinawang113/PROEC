********************************************************************************
*	Do-file:		4CR_imputation.do
*	Project:		PROEC: Proteomics for endometrial cancer case-control
*
*	Data used:		PROEC_basevars.dta 
*					PROEC_eligible.dta
*
*	Data created:	tab_basevars_missing.xlsx
*					PROEC_coredata_nostd.dta
*
* 	Purpose:  		Generate summary for missing values of covariates
*					Impute missing values for covariates
*					Create core dataset for analysis
*
*	Date:			03-MAY-2023
*	Author: 		Sabrina Wang
********************************************************************************

// Rules for imputing missing values (analysis plan)

*	assign the median (continuous variables) or mode (categorical variables) 
*	if they represented less than 5% of the study sample 
*	or classify in a "missing" category otherwise. 

********************************************************************************

// run the 0_settings.do for this project
capture log close 
cd "$PROEClog"
log using "4CR_imputation$current_date", replace
set linesize 255

di "Stata Version: `c(stata_version)'"
di "Current Date: `c(current_date)'"

********************************************************************************

// import data
* PROEC_basevars
* PROEC_eligible

local dataset = "PROEC_eligible"

cd "$PROECderived"
use `dataset', clear
	
********************************************************************************

// generate report for vars with missing value

rename center s_center
encode s_center, gen(center)

preserve

cd "$PROECderived"
tempname temp1
tempfile temp2
postfile `temp1' str35	variable  ///
				double total nmissing pmissing	///
				using `temp2', replace
					 
foreach var of varlist eccase age_blood fasting_c ///
					age_menarche ftp ever_pill menop_bld ///
					smoke_stat pa_index alc_re_categ edu_categ ///
					height_c weight_c bmi_c bmi_categ waist_c hip_c whr_c diabet ///
					age_blood fasting_c t_bld_coll menopause center {
	count if `var'==.
	local total = _N
	local nmissing = r(N) 
	local pmissing = r(N) / `total'	
	post `temp1' ("`var'") (`total') (`nmissing') (`pmissing')
	}
	
	*----------------
	* diagnosis vars
	*----------------
	foreach var of varlist age_diagnosis time_bld_diag  {
	count if eccase==1
	local total = r(N) 
	count if `var'==. & eccase==1
	local nmissing = r(N) 
	local pmissing = r(N) / `total'
	post `temp1' ("`var'") (`total') (`nmissing') (`pmissing')
	}
	
	*----------------
	* ftp vars
	*----------------
	foreach var of varlist age_ftp n_ftp {
	count if ftp==1
	local total = r(N) 
	count if `var'==. & ftp==1
	local nmissing = r(N) 
	local pmissing = r(N) / `total'
	post `temp1' ("`var'") (`total') (`nmissing') (`pmissing')
	}
	
	*----------------
	* menopause vars
	*----------------
	foreach var of varlist a_menopause ever_horm {
	count if menopause==1 | menopause==3
	local total = r(N) 
	count if `var'==. & menopause==1 | menopause==3
	local nmissing = r(N) 
	local pmissing = r(N) / `total'
	post `temp1' ("`var'") (`total') (`nmissing') (`pmissing')
	}

	postclose `temp1'

	
* flag vars with missing values
use `temp2', clear
gen yesmissing =1 if nmissing!=0
order variable yesmissing

* export as excel
cd "$PROECoutput"
tostring pmissing, replace force format(%9.2f)
export excel using "tab_basevars_missing.xlsx", firstrow(variables) sheet("`dataset'", replace) keepcellfmt

restore

********************************************************************************

// Check individual vars

* ever HRT
* replace premenopausal missing = no
tab menop_bld ever_horm,m
recode ever_horm .=0 if menop_bld==0

sum age_menarche
tab ftp,m
tab ever_pill,m
tab ever_horm,m

tab pa_index,m
tab pa_index,m nol
recode pa_index .a = .

tab smoke_stat,m
tab smoke_stat,m nol
recode smoke_stat .a = .

tab edu_categ,m
tab edu_categ,m nol
recode edu_categ .a = .

********************************************************************************

// Imputation

* for vars with <5% missing values
* assign the median (continuous variables) or mode (categorical variables)
foreach var of varlist age_menarche t_bld_coll {
	list idepic eccase `var' if `var'==.
	sum `var',d
	local median = r(p50)
	recode `var' . = `median'
}			

foreach var of varlist ftp ever_pill edu_categ alc_re_categ ever_horm fasting_c pa_index smoke_stat {
	list idepic eccase `var' if `var'==.
	cap drop mode
	egen mode = mode(`var')
	replace `var' = mode if `var'==.
}			

********************************************************************************

cd "$PROECderived"
save PROEC_coredata_nostd, replace

********************************************************************************
log close