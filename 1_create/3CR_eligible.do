********************************************************************************
*	Do-file:		3CR_eligible.do
*	Project:		PROEC: Proteomics for endometrial cancer case-control
*
*	Data used:		PROEC_qcflag.dta
*
*	Data created:	PROEC_eligible.dta
*
* 	Purpose:  		Apply eligiblity criteria 
*
*	Date:			03-MAY-2023
*	Author: 		Sabrina Wang
********************************************************************************

// Eligibility criteria

*	exclude Country==B due to GDPR issue
*	qc warning TBC

********************************************************************************

// run the 0_settings.do for this project
capture log close 
cd "$PROEClog"
log using "3CR_eligible$current_date", replace
set linesize 255

di "Stata Version: `c(stata_version)'"
di "Current Date: `c(current_date)'"

********************************************************************************

// import data
* PROEC_qcflag
* PROEC_exclqcfail

local dataset = "PROEC_qcflag" //do not exclude qc warnings for now

cd "$PROECderived"
use `dataset', clear 
	
********************************************************************************

// Exclude country=="B"
tab country
sort match_caseset
list idepic match_caseset eccase if country=="B"  //all country B exclusions are matched
drop if country=="B"

// matched id
* exclude the matched case or control
duplicates tag match_caseset, gen(matched) //all country B exclusions are matched
tab matched eccase,m //624+624=1248
drop matched

********************************************************************************

cd "$PROECderived"
save PROEC_eligible, replace

********************************************************************************
log close