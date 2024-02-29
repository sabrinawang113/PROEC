********************************************************************************
*	Do-file:		2CR_olink_qc.do
*	Project:		PROEC: Proteomics for endometrial cancer case-control
*
*	Data used:		PROEC_basevars.dta
*
*	Data created:	PROEC_qcflag.dta
*					PROEC_exclqcfail.dta
*
* 	Purpose:  		Flag samples with QC warning
*					Create a separate dataset
*					Exclude samples with QC warning
*					Also exclude their matched case or control
*
*	Date:			25-APR-2023
*	Author: 		Sabrina Wang
********************************************************************************

// run the 0_settings.do for this project
capture log close 
cd "$PROEClog"
log using "2CR_olink_qc$current_date", replace
set linesize 255

di "Stata Version: `c(stata_version)'"
di "Current Date: `c(current_date)'"

********************************************************************************

// import data
cd "$PROECderived"
use PROEC_basevars, clear
	
********************************************************************************

// Flag QC warning
tab qc_warning_infl qc_warning_ir
encode qc_warning_infl, gen(qcfail_infl)
encode qc_warning_ir, gen(qcfail_ir)
gen qcfail = 1 if qcfail_infl==2 | qcfail_ir==2
tab qcfail eccase,m

cd "$PROECderived"
save PROEC_qcflag, replace

********************************************************************************

// Exclude samples with QC warning
drop if qcfail==1

// matched id
* exclude the matched case or control
codebook match_caseset
duplicates tag match_caseset, gen(matched)
tab matched eccase,m
drop if matched==0

tab matched eccase,m //636+636=1272

cd "$PROECderived"
save PROEC_exclqcfail, replace

********************************************************************************
log close