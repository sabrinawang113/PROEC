********************************************************************************
*	Do-file:		4_4AN_clogit_cpeptide.do
*	Project:		PROEC: Proteomics for endometrial cancer case-control
*
*	Data used:		PROEC_coredata_olk75
*
*	Data created:	or_`model'.dta
*					or_`model'.jpg
*
* 	Purpose:  		conditional logistic regression of each protein on EC risk
*					- restricted to type 1 endometrial cancer
*
*	Date:			25-JUL-2023
*	Author: 		Sabrina Wang
********************************************************************************
*ref for graph: https://www.stata.com/manuals/g-4colorstyle.pdf#g-4colorstyle

// Multiple testing correction: Compute FDR qvalue
* see: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1101000403
* simes = step-up; FDR; nonnegative correlation assumed 
* (Simes [1986]; Benjamini and Hochberg [1995]; Benjamini and Yekutieli [2001, first method])

********************************************************************************

// run the 0_settings.do for this project
capture log close 
cd "$PROEClog"
log using "4_4AN_clogit_cpeptide$current_date", replace
set linesize 255

di "Stata Version: `c(stata_version)'"
di "Current Date: `c(current_date)'"

*cap ssc install schemepack, replace
set scheme tab2
graph set window fontface "Helvetica"

********************************************************************************

// import data

global dataset = "PROEC_coredata_olk75"
cd "$PROECderived"
use $dataset, clear

********************************************************************************

//bmi & wc binary
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

// olk proteins >75% above lod
* for final presentation, the 50-75% results will be removed (and present the binary results only)

global olk = "olk_il8_infl olk_vegfa_infl olk_cd8a_infl olk_mcp_3_infl olk_gdnf_infl olk_cdcp1_infl olk_cd244_infl olk_il7_infl olk_opg_infl olk_laptgf_beta_1_infl olk_upa_infl olk_il6_infl olk_il_17c_infl olk_mcp_1_infl olk_il_17a_infl olk_cxcl11_infl olk_axin1_infl olk_trail_infl olk_cxcl9_infl olk_cst5_infl olk_il_2rb_infl olk_osm_infl olk_cxcl1_infl olk_ccl4_infl olk_cd6_infl olk_scf_infl olk_il18_infl olk_slamf1_infl olk_tgf_alpha_infl olk_mcp_4_infl olk_ccl11_infl olk_tnfsf14_infl olk_fgf_23_infl olk_il_10ra_infl olk_fgf_5_infl olk_mmp_1_infl olk_lif_r_infl olk_fgf_21_infl olk_ccl19_infl olk_il_10rb_infl olk_il_18r1_infl olk_pd_l1_infl olk_cxcl5_infl olk_trance_infl olk_hgf_infl olk_il_12b_infl olk_mmp_10_infl olk_il10_infl olk_tnf_infl olk_ccl23_infl olk_cd5_infl olk_ccl3_infl olk_flt3l_infl olk_cxcl6_infl olk_cxcl10_infl olk_4e_bp1_infl olk_sirt2_infl olk_ccl28_infl olk_dner_infl olk_en_rage_infl olk_cd40_infl olk_ifn_gamma_infl olk_fgf_19_infl olk_mcp_2_infl olk_casp_8_infl olk_ccl25_infl olk_cx3cl1_infl olk_tnfrsf9_infl olk_nt_3_infl olk_tweak_infl olk_ccl20_infl olk_st1a1_infl olk_stambp_infl olk_ada_infl olk_tnfb_infl olk_csf_1_infl olk_ppp1r9b_ir olk_glb1_ir olk_psip1_ir olk_zbtb16_ir olk_tpsab1_ir olk_hcls1_ir olk_cntnap2_ir olk_clec4g_ir olk_irf9_ir olk_edar_ir olk_il6_ir olk_clec4c_ir olk_irak1_ir olk_clec4a_ir olk_prdx1_ir olk_prdx3_ir olk_fgf2_ir olk_prdx5_ir olk_dpp10_ir olk_trim5_ir olk_dctn1_ir olk_itga6_ir olk_cdsn_ir olk_traf2_ir olk_trim21_ir olk_lilrb4_ir olk_ntf4_ir olk_krt19_ir olk_itm2a_ir olk_hnmt_ir olk_ccl11_ir olk_milr1_ir olk_egln1_ir olk_nfatc3_ir olk_ly75_ir olk_eif4g1_ir olk_cd28_ir olk_pth1r_ir olk_hsd11b1_ir olk_plxna4_ir olk_sh2b3_ir olk_fcrl3_ir olk_ckap4_ir olk_jun_ir olk_hexim1_ir olk_clec4d_ir olk_prkcq_ir olk_mgmt_ir olk_cxadr_ir olk_il10_ir olk_srpk2_ir olk_klrd1_ir olk_bach1_ir olk_pik3ap1_ir olk_spry2_ir olk_stc1_ir olk_fam3b_ir olk_sh2d1a_ir olk_dffa_ir olk_dcbld2_ir olk_fcrl6_ir olk_ncr1_ir olk_areg_ir olk_ifnlr1_ir olk_dapp1_ir olk_sit1_ir olk_masp1_ir olk_lamp3_ir olk_clec7a_ir olk_clec6a_ir olk_ddx58_ir olk_il12rb1_ir olk_itga11_ir olk_kpna1_ir olk_lag3_ir olk_il5_ir olk_cd83_ir olk_itgb6_ir olk_btn3a2_ir"

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

	* clogit				 
	foreach protein of varlist $olk {
		clogit eccase `protein' `covar', group(match_caseset) or
		local n	= e(N)
		matrix b = r(table)
		local or = b[1,1]
		local lci = b[5,1]
		local uci = b[6,1]
		local pval = b[4,1]
		post `temp1' ("`file'") ("`protein'") (`n') (`or') (`lci') (`uci') (`pval')
	}
	postclose `temp1'
	
	* merge in protein summary
	cd "$PROECderived"
	use `file', clear
	merge 1:1 protein using olink_summary
	drop _merge
	
	* compute qvalue	
	cap drop qvalue npvalue
	qqvalue pval , method(simes) qvalue(qvalue) npvalue(npvalue)
	sort qvalue
	order qvalue npvalue, after(pval)
	
	* export as excel
	sort pval
	save `file', replace
	cd "$PROECoutput"
	
	tostring or lci uci, replace force format(%9.2f)
	tostring pval qvalue, replace force format(%9.3f)
	gen estimate = or + " ("+lci +"–"+ uci+")"
	
	tostring lod_pbelow, replace force format(%9.2f)
		
	keep model panel protein n estimate pval qvalue npvalue lod_pbelow 
	order model panel protein n estimate pval qvalue npvalue lod_pbelow 
	export excel using "tab_PROEC_clogit.xlsx", firstrow(variables) sheet("`file'", replace) keepcellfmt

end 

// adjusted for full list of potential confounders 
local file	= "or_cpeptide"
local covar = "i.bmicat i.pa_index age_menarche i.ftp i.ever_pill i.ever_horm i.smoke_stat cpept_std"
clogit_or, file("`file'") covar("`covar'")

********************************************************************************
log close