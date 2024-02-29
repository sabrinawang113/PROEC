********************************************************************************
*	Do-file:		7AN_olk50_linearity.do
*	Project:		PROEC: Proteomics for endometrial cancer case-control
*
*	Data used:		PROEC_coredata_olk50.dta
*
*	Data created:	olk50_linearity.dta
*					tab_PROEC_linearity.xlsx
*
* 	Purpose:  		Test for trend and linearity for those analysed as cont vars
*					***SOME GROUPS OMITED DUE TO PERFECT PREDICTION AFTER XTILE
*
*	Date:			10-MAY-2023
*	Author: 		Sabrina Wang

********************************************************************************
// run the 0_settings.do for this project
capture log close 
cd "$PROEClog"
log using "7AN_olk50_linearity$current_date", replace
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
* PROEC_coredata_olk75
* PROEC_coredata_olk50

global dataset = "PROEC_coredata_olk50"

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
* perform test for linearity and trend for those with >50% aboveLOD only
global olk = "olk_il8_infl olk_vegfa_infl olk_cd8a_infl olk_gdnf_infl olk_cdcp1_infl olk_cd244_infl olk_il7_infl olk_opg_infl olk_laptgf_beta_1_infl olk_upa_infl olk_il6_infl olk_il_17c_infl olk_mcp_1_infl olk_cxcl11_infl olk_axin1_infl olk_trail_infl olk_cxcl9_infl olk_cst5_infl olk_il_2rb_infl olk_osm_infl olk_cxcl1_infl olk_ccl4_infl olk_cd6_infl olk_scf_infl olk_il18_infl olk_slamf1_infl olk_tgf_alpha_infl olk_mcp_4_infl olk_ccl11_infl olk_tnfsf14_infl olk_fgf_23_infl olk_mmp_1_infl olk_lif_r_infl olk_fgf_21_infl olk_ccl19_infl olk_il_10rb_infl olk_il_18r1_infl olk_pd_l1_infl olk_cxcl5_infl olk_trance_infl olk_hgf_infl olk_il_12b_infl olk_mmp_10_infl olk_il10_infl olk_tnf_infl olk_ccl23_infl olk_cd5_infl olk_ccl3_infl olk_flt3l_infl olk_cxcl6_infl olk_cxcl10_infl olk_4e_bp1_infl olk_sirt2_infl olk_ccl28_infl olk_dner_infl olk_en_rage_infl olk_cd40_infl olk_ifn_gamma_infl olk_fgf_19_infl olk_mcp_2_infl olk_casp_8_infl olk_ccl25_infl olk_cx3cl1_infl olk_tnfrsf9_infl olk_nt_3_infl olk_tweak_infl olk_ccl20_infl olk_st1a1_infl olk_stambp_infl olk_ada_infl olk_tnfb_infl olk_csf_1_infl olk_ppp1r9b_ir olk_glb1_ir olk_psip1_ir olk_zbtb16_ir olk_tpsab1_ir olk_hcls1_ir olk_cntnap2_ir olk_clec4g_ir olk_irf9_ir olk_edar_ir olk_il6_ir olk_clec4c_ir olk_irak1_ir olk_clec4a_ir olk_prdx1_ir olk_fgf2_ir olk_prdx5_ir olk_dpp10_ir olk_trim5_ir olk_dctn1_ir olk_itga6_ir olk_cdsn_ir olk_traf2_ir olk_trim21_ir olk_lilrb4_ir olk_ntf4_ir olk_krt19_ir olk_itm2a_ir olk_hnmt_ir olk_ccl11_ir olk_milr1_ir olk_nfatc3_ir olk_ly75_ir olk_eif4g1_ir olk_cd28_ir olk_pth1r_ir olk_hsd11b1_ir olk_plxna4_ir olk_sh2b3_ir olk_fcrl3_ir olk_ckap4_ir olk_hexim1_ir olk_clec4d_ir olk_mgmt_ir olk_cxadr_ir olk_il10_ir olk_srpk2_ir olk_klrd1_ir olk_bach1_ir olk_pik3ap1_ir olk_stc1_ir olk_fam3b_ir olk_sh2d1a_ir olk_dffa_ir olk_dcbld2_ir olk_fcrl6_ir olk_ncr1_ir olk_areg_ir olk_ifnlr1_ir olk_sit1_ir olk_masp1_ir olk_lamp3_ir olk_clec7a_ir olk_clec6a_ir olk_ddx58_ir olk_itga11_ir olk_lag3_ir olk_cd83_ir olk_itgb6_ir olk_btn3a2_ir"

********************************************************************************

// Conditional regression

/*
xtile olk_il6_ir_q4 = olk_il6_ir , n(4)
clogit eccase i.olk_il6_ir_q4 bmi_c i.pa_index age_menarche i.ftp i.ever_pill i.ever_horm i.smoke_stat, group(match_caseset) or
*/

*=======================*
*	clogit_or program	*
*=======================*
cap program drop test_linear

program test_linear
syntax, covars(string) xtile(int)

	cd "$PROECderived"
	use $dataset, clear // dataset

	cd "$PROECderived"
	tempname temp1
	tempfile temp2
	postfile `temp1' str35 protein  ///
					 double n xtile plin ptrend	///
					 using `temp2', replace

	* clogit				 
	foreach protein of varlist $olk {
		
		xtile `protein'_q`int' = `protein', n(`xtile')
			clogit eccase i.`protein'_q`int' `covars', group(match_caseset) or
				est store a
				local n	= e(N)
			clogit eccase `protein'_q`int' `covars', group(match_caseset) or
				est store b
				matrix b = r(table)
				local ptrend = b[4,1]
		lrtest a b
			local plin = r(p)
	
		post `temp1' ("`protein'") (`n') (`xtile') (`plin') (`ptrend')
	}
	postclose `temp1'
	
	* merge in clogit results
	cd "$PROECderived"
	use `temp2', clear
	merge 1:1 protein using or_adjfull
	drop if _merge==2
	drop _merge
	
	* export as excel
	sort plin
	save olk50_linearity, replace
	cd "$PROECoutput"
	tostring plin ptrend, replace force format(%9.3f)
	export excel using "tab_PROEC_linearity.xlsx", firstrow(variables) sheet("$dataset", replace) keepcellfmt

end 

test_linear, covars("i.bmicat i.pa_index age_menarche i.ftp i.ever_pill i.ever_horm i.smoke_stat") xtile(4)

********************************************************************************

// List proteins that violates linearity assumption
cd "$PROECderived"
use olk50_linearity, clear
list protein if plin <0.05

// Examine them as categorical variables
cd "$PROECderived"
use PROEC_coredata_olk75, clear
global dataset = "PROEC_coredata_olk75"
global nonlinolk = "olk_cxcl5_infl olk_cxcl9_infl"

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
				 double xtile or lci uci pval	///
				 using `file', replace

	* clogit for nonlinolk
	foreach protein of varlist $nonlinolk {
	
	local n = 4
	xtile `protein'_q4 = `protein' , n(`n')
	
	local model = "full_q4"
	clogit eccase i.`protein'_q4 `covar', group(match_caseset) or
		matrix b = r(table)
				local or = b[1,4]
				local lci = b[5,4]
				local uci = b[6,4]
				local pval = b[4,4]
				post `temp1' ("`model'") ("`protein'") (`n') (`or') (`lci') (`uci') (`pval')
			
	}
	postclose `temp1'
	
	* compute qvalue	
	cd "$PROECderived"
	use `file', clear
	merge 1:1 protein using olink_summary
	drop if _merge==2
	drop _merge
	
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
		
	keep model panel protein estimate pval qvalue  
	order model panel protein estimate pval qvalue  
	export excel using "tab_PROEC_linearity.xlsx", firstrow(variables) sheet("`file'", replace) keepcellfmt
	
end

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
				 double xtile or lci uci pval	///
				 using `file', replace

	* clogit for nonlinolk
	foreach protein of varlist $nonlinolk {
	
	local n = 4
	xtile `protein'_q4 = `protein' , n(`n')
	
	local model = "full_q4"
	clogit eccase i.`protein'_q4 `covar', group(match_caseset) or
		matrix b = r(table)
				local or = b[1,4]
				local lci = b[5,4]
				local uci = b[6,4]
				local pval = b[4,4]
				post `temp1' ("`model'") ("`protein'") (`n') (`or') (`lci') (`uci') (`pval')
			
	}
	postclose `temp1'
	
	* compute qvalue	
	cd "$PROECderived"
	use `file', clear
	merge 1:1 protein using olink_summary
	drop if _merge==2
	drop _merge
	
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
		
	keep model panel protein estimate pval qvalue  
	order model panel protein estimate pval qvalue  
	export excel using "tab_PROEC_linearity.xlsx", firstrow(variables) sheet("`file'", replace) keepcellfmt
	
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
				 double xtile or lci uci pval	///
				 using `file', replace

	* clogit for nonlinolk
	foreach protein of varlist $nonlinolk {
	
	local n = 4
	xtile `protein'_q4 = `protein' , n(`n')
	
	local model = "full_q4"
	clogit eccase i.`protein'_q4 `covar', group(match_caseset) or
		matrix b = r(table)
				local or = b[1,4]
				local lci = b[5,4]
				local uci = b[6,4]
				local pval = b[4,4]
				post `temp1' ("`model'") ("`protein'") (`n') (`or') (`lci') (`uci') (`pval')
			
	}
	postclose `temp1'
	
	* compute qvalue	
	cd "$PROECderived"
	use `file', clear
	merge 1:1 protein using olink_summary
	drop if _merge==2
	drop _merge
	
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
		
	keep model panel protein estimate pval qvalue  
	order model panel protein estimate pval qvalue  
	export excel using "tab_PROEC_linearity.xlsx", firstrow(variables) sheet("`file'", replace) keepcellfmt
	
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
				 double xtile or lci uci pval	///
				 using `file', replace

	* clogit for nonlinolk
	foreach protein of varlist $nonlinolk {
	
	local n = 4
	xtile `protein'_q4 = `protein' , n(`n')
	
	local model = "full_q4"
	clogit eccase i.`protein'_q4 `covar', group(match_caseset) or
		matrix b = r(table)
				local or = b[1,4]
				local lci = b[5,4]
				local uci = b[6,4]
				local pval = b[4,4]
				post `temp1' ("`model'") ("`protein'") (`n') (`or') (`lci') (`uci') (`pval')
			
	}
	postclose `temp1'
	
	* compute qvalue	
	cd "$PROECderived"
	use `file', clear
	merge 1:1 protein using olink_summary
	drop if _merge==2
	drop _merge
	
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
		
	keep model panel protein estimate pval qvalue  
	order model panel protein estimate pval qvalue  
	export excel using "tab_PROEC_linearity.xlsx", firstrow(variables) sheet("`file'", replace) keepcellfmt
	
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
