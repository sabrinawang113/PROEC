********************************************************************************
*	Do-file:		3AN_adipro.do
*	Project:		PROEC: Proteomics for endometrial cancer case-control
*
*	Data used:		PROEC_coredata.dta
*
*	Data created:	tab_PROEC_adipro.xlsx
*					volcano plots
*
* 	Purpose:  		Examine association between adiposity and biomarkers
*
*	Date:			03-MAY-2023
*	Author: 		Sabrina Wang
********************************************************************************

// run the 0_settings.do for this project
capture log close 
cd "$PROEClog"
log using "3AN_adipro$current_date", replace
set linesize 255

di "Stata Version: `c(stata_version)'"
di "Current Date: `c(current_date)'"

*cap ssc install schemepack, replace
set scheme tab2
graph set window fontface "Helvetica"

********************************************************************************

// import data
* load data in program
* PROEC_exclqcfail
* PROEC_coredata
* PROEC_coredata_olk75

cd "$PROECderived"
use PROEC_coredata_olk75, clear

********************************************************************************

// standardise bmi and waist circumference
egen stdbmi = std(bmi_c)
egen stdwc = std(waist_c)
sum bmi_c waist_c stdbmi stdwc

********************************************************************************

// Olink proteins

// all olk proteins	
*global olk = "olk_il8_infl olk_vegfa_infl olk_cd8a_infl olk_mcp_3_infl olk_gdnf_infl olk_cdcp1_infl olk_cd244_infl olk_il7_infl olk_opg_infl olk_laptgf_beta_1_infl olk_upa_infl olk_il6_infl olk_il_17c_infl olk_mcp_1_infl olk_il_17a_infl olk_cxcl11_infl olk_axin1_infl olk_trail_infl olk_il_20ra_infl olk_cxcl9_infl olk_cst5_infl olk_il_2rb_infl olk_il_1alpha_infl olk_osm_infl olk_il2_infl olk_cxcl1_infl olk_tslp_infl olk_ccl4_infl olk_cd6_infl olk_scf_infl olk_il18_infl olk_slamf1_infl olk_tgf_alpha_infl olk_mcp_4_infl olk_ccl11_infl olk_tnfsf14_infl olk_fgf_23_infl olk_il_10ra_infl olk_fgf_5_infl olk_mmp_1_infl olk_lif_r_infl olk_fgf_21_infl olk_ccl19_infl olk_il_15ra_infl olk_il_10rb_infl olk_il_22ra1_infl olk_il_18r1_infl olk_pd_l1_infl olk_beta_ngf_infl olk_cxcl5_infl olk_trance_infl olk_hgf_infl olk_il_12b_infl olk_il_24_infl olk_il13_infl olk_artn_infl olk_mmp_10_infl olk_il10_infl olk_tnf_infl olk_ccl23_infl olk_cd5_infl olk_ccl3_infl olk_flt3l_infl olk_cxcl6_infl olk_cxcl10_infl olk_4e_bp1_infl olk_il_20_infl olk_sirt2_infl olk_ccl28_infl olk_dner_infl olk_en_rage_infl olk_cd40_infl olk_il33_infl olk_ifn_gamma_infl olk_fgf_19_infl olk_il4_infl olk_lif_infl olk_nrtn_infl olk_mcp_2_infl olk_casp_8_infl olk_ccl25_infl olk_cx3cl1_infl olk_tnfrsf9_infl olk_nt_3_infl olk_tweak_infl olk_ccl20_infl olk_st1a1_infl olk_stambp_infl olk_il5_infl olk_ada_infl olk_tnfb_infl olk_csf_1_infl olk_ppp1r9b_ir olk_glb1_ir olk_psip1_ir olk_zbtb16_ir olk_irak4_ir olk_tpsab1_ir olk_hcls1_ir olk_cntnap2_ir olk_clec4g_ir olk_irf9_ir olk_edar_ir olk_il6_ir olk_dgkz_ir olk_clec4c_ir olk_irak1_ir olk_clec4a_ir olk_prdx1_ir olk_prdx3_ir olk_fgf2_ir olk_prdx5_ir olk_dpp10_ir olk_trim5_ir olk_dctn1_ir olk_itga6_ir olk_cdsn_ir olk_galnt3_ir olk_fxyd5_ir olk_traf2_ir olk_trim21_ir olk_lilrb4_ir olk_ntf4_ir olk_krt19_ir olk_itm2a_ir olk_hnmt_ir olk_ccl11_ir olk_milr1_ir olk_egln1_ir olk_nfatc3_ir olk_ly75_ir olk_eif5a_ir olk_eif4g1_ir olk_cd28_ir olk_pth1r_ir olk_birc2_ir olk_hsd11b1_ir olk_nf2_ir olk_plxna4_ir olk_sh2b3_ir olk_fcrl3_ir olk_ckap4_ir olk_jun_ir olk_hexim1_ir olk_clec4d_ir olk_prkcq_ir olk_mgmt_ir olk_trem1_ir olk_cxadr_ir olk_il10_ir olk_srpk2_ir olk_klrd1_ir olk_bach1_ir olk_pik3ap1_ir olk_spry2_ir olk_stc1_ir olk_arnt_ir olk_fam3b_ir olk_sh2d1a_ir olk_ica1_ir olk_dffa_ir olk_dcbld2_ir olk_fcrl6_ir olk_ncr1_ir olk_cxcl12_ir olk_areg_ir olk_ifnlr1_ir olk_dapp1_ir olk_padi2_ir olk_sit1_ir olk_masp1_ir olk_lamp3_ir olk_clec7a_ir olk_clec6a_ir olk_ddx58_ir olk_il12rb1_ir olk_tank_ir olk_itga11_ir olk_kpna1_ir olk_lag3_ir olk_il5_ir olk_cd83_ir olk_itgb6_ir olk_btn3a2_ir"

// olk proteins >75% above lod
global olk = "olk_il8_infl olk_vegfa_infl olk_cd8a_infl olk_mcp_3_infl olk_gdnf_infl olk_cdcp1_infl olk_cd244_infl olk_il7_infl olk_opg_infl olk_laptgf_beta_1_infl olk_upa_infl olk_il6_infl olk_il_17c_infl olk_mcp_1_infl olk_il_17a_infl olk_cxcl11_infl olk_axin1_infl olk_trail_infl olk_cxcl9_infl olk_cst5_infl olk_il_2rb_infl olk_osm_infl olk_cxcl1_infl olk_ccl4_infl olk_cd6_infl olk_scf_infl olk_il18_infl olk_slamf1_infl olk_tgf_alpha_infl olk_mcp_4_infl olk_ccl11_infl olk_tnfsf14_infl olk_fgf_23_infl olk_il_10ra_infl olk_fgf_5_infl olk_mmp_1_infl olk_lif_r_infl olk_fgf_21_infl olk_ccl19_infl olk_il_10rb_infl olk_il_18r1_infl olk_pd_l1_infl olk_cxcl5_infl olk_trance_infl olk_hgf_infl olk_il_12b_infl olk_mmp_10_infl olk_il10_infl olk_tnf_infl olk_ccl23_infl olk_cd5_infl olk_ccl3_infl olk_flt3l_infl olk_cxcl6_infl olk_cxcl10_infl olk_4e_bp1_infl olk_sirt2_infl olk_ccl28_infl olk_dner_infl olk_en_rage_infl olk_cd40_infl olk_ifn_gamma_infl olk_fgf_19_infl olk_mcp_2_infl olk_casp_8_infl olk_ccl25_infl olk_cx3cl1_infl olk_tnfrsf9_infl olk_nt_3_infl olk_tweak_infl olk_ccl20_infl olk_st1a1_infl olk_stambp_infl olk_ada_infl olk_tnfb_infl olk_csf_1_infl olk_ppp1r9b_ir olk_glb1_ir olk_psip1_ir olk_zbtb16_ir olk_tpsab1_ir olk_hcls1_ir olk_cntnap2_ir olk_clec4g_ir olk_irf9_ir olk_edar_ir olk_il6_ir olk_clec4c_ir olk_irak1_ir olk_clec4a_ir olk_prdx1_ir olk_prdx3_ir olk_fgf2_ir olk_prdx5_ir olk_dpp10_ir olk_trim5_ir olk_dctn1_ir olk_itga6_ir olk_cdsn_ir olk_traf2_ir olk_trim21_ir olk_lilrb4_ir olk_ntf4_ir olk_krt19_ir olk_itm2a_ir olk_hnmt_ir olk_ccl11_ir olk_milr1_ir olk_egln1_ir olk_nfatc3_ir olk_ly75_ir olk_eif4g1_ir olk_cd28_ir olk_pth1r_ir olk_hsd11b1_ir olk_plxna4_ir olk_sh2b3_ir olk_fcrl3_ir olk_ckap4_ir olk_jun_ir olk_hexim1_ir olk_clec4d_ir olk_prkcq_ir olk_mgmt_ir olk_cxadr_ir olk_il10_ir olk_srpk2_ir olk_klrd1_ir olk_bach1_ir olk_pik3ap1_ir olk_spry2_ir olk_stc1_ir olk_fam3b_ir olk_sh2d1a_ir olk_dffa_ir olk_dcbld2_ir olk_fcrl6_ir olk_ncr1_ir olk_areg_ir olk_ifnlr1_ir olk_dapp1_ir olk_sit1_ir olk_masp1_ir olk_lamp3_ir olk_clec7a_ir olk_clec6a_ir olk_ddx58_ir olk_il12rb1_ir olk_itga11_ir olk_kpna1_ir olk_lag3_ir olk_il5_ir olk_cd83_ir olk_itgb6_ir olk_btn3a2_ir"

// standardise proteins
foreach protein of varlist $olk {	
	egen std`protein' = std(`protein')
}

global stdolk = "stdolk_il8_infl stdolk_vegfa_infl stdolk_cd8a_infl stdolk_mcp_3_infl stdolk_gdnf_infl stdolk_cdcp1_infl stdolk_cd244_infl stdolk_il7_infl stdolk_opg_infl stdolk_laptgf_beta_1_infl stdolk_upa_infl stdolk_il6_infl stdolk_il_17c_infl stdolk_mcp_1_infl stdolk_il_17a_infl stdolk_cxcl11_infl stdolk_axin1_infl stdolk_trail_infl stdolk_cxcl9_infl stdolk_cst5_infl stdolk_il_2rb_infl stdolk_osm_infl stdolk_cxcl1_infl stdolk_ccl4_infl stdolk_cd6_infl stdolk_scf_infl stdolk_il18_infl stdolk_slamf1_infl stdolk_tgf_alpha_infl stdolk_mcp_4_infl stdolk_ccl11_infl stdolk_tnfsf14_infl stdolk_fgf_23_infl stdolk_il_10ra_infl stdolk_fgf_5_infl stdolk_mmp_1_infl stdolk_lif_r_infl stdolk_fgf_21_infl stdolk_ccl19_infl stdolk_il_10rb_infl stdolk_il_18r1_infl stdolk_pd_l1_infl stdolk_cxcl5_infl stdolk_trance_infl stdolk_hgf_infl stdolk_il_12b_infl stdolk_mmp_10_infl stdolk_il10_infl stdolk_tnf_infl stdolk_ccl23_infl stdolk_cd5_infl stdolk_ccl3_infl stdolk_flt3l_infl stdolk_cxcl6_infl stdolk_cxcl10_infl stdolk_4e_bp1_infl stdolk_sirt2_infl stdolk_ccl28_infl stdolk_dner_infl stdolk_en_rage_infl stdolk_cd40_infl stdolk_ifn_gamma_infl stdolk_fgf_19_infl stdolk_mcp_2_infl stdolk_casp_8_infl stdolk_ccl25_infl stdolk_cx3cl1_infl stdolk_tnfrsf9_infl stdolk_nt_3_infl stdolk_tweak_infl stdolk_ccl20_infl stdolk_st1a1_infl stdolk_stambp_infl stdolk_ada_infl stdolk_tnfb_infl stdolk_csf_1_infl stdolk_ppp1r9b_ir stdolk_glb1_ir stdolk_psip1_ir stdolk_zbtb16_ir stdolk_tpsab1_ir stdolk_hcls1_ir stdolk_cntnap2_ir stdolk_clec4g_ir stdolk_irf9_ir stdolk_edar_ir stdolk_il6_ir stdolk_clec4c_ir stdolk_irak1_ir stdolk_clec4a_ir stdolk_prdx1_ir stdolk_prdx3_ir stdolk_fgf2_ir stdolk_prdx5_ir stdolk_dpp10_ir stdolk_trim5_ir stdolk_dctn1_ir stdolk_itga6_ir stdolk_cdsn_ir stdolk_traf2_ir stdolk_trim21_ir stdolk_lilrb4_ir stdolk_ntf4_ir stdolk_krt19_ir stdolk_itm2a_ir stdolk_hnmt_ir stdolk_ccl11_ir stdolk_milr1_ir stdolk_egln1_ir stdolk_nfatc3_ir stdolk_ly75_ir stdolk_eif4g1_ir stdolk_cd28_ir stdolk_pth1r_ir stdolk_hsd11b1_ir stdolk_plxna4_ir stdolk_sh2b3_ir stdolk_fcrl3_ir stdolk_ckap4_ir stdolk_jun_ir stdolk_hexim1_ir stdolk_clec4d_ir stdolk_prkcq_ir stdolk_mgmt_ir stdolk_cxadr_ir stdolk_il10_ir stdolk_srpk2_ir stdolk_klrd1_ir stdolk_bach1_ir stdolk_pik3ap1_ir stdolk_spry2_ir stdolk_stc1_ir stdolk_fam3b_ir stdolk_sh2d1a_ir stdolk_dffa_ir stdolk_dcbld2_ir stdolk_fcrl6_ir stdolk_ncr1_ir stdolk_areg_ir stdolk_ifnlr1_ir stdolk_dapp1_ir stdolk_sit1_ir stdolk_masp1_ir stdolk_lamp3_ir stdolk_clec7a_ir stdolk_clec6a_ir stdolk_ddx58_ir stdolk_il12rb1_ir stdolk_itga11_ir stdolk_kpna1_ir stdolk_lag3_ir stdolk_il5_ir stdolk_cd83_ir stdolk_itgb6_ir stdolk_btn3a2_ir"

********************************************************************************

*=======================*
*	clogit_or program	*
*=======================*

cap program drop est_adipro
program est_adipro
syntax, name(string) covar(string)
	* Association with waist circumference
	cd "$PROECderived"
		tempname temp1
		postfile `temp1' str35 protein  ///
						 double n rr lci uci pval	///
						 using "`name'_wc", replace
				 
	foreach protein of varlist $olk {	
		reg `protein' stdwc `covar' // for every std increase in wc
		local n	= e(N)
			matrix b = r(table)
			local rr = b[1,1]
			local lci = b[5,1]
			local uci = b[6,1]
			local pval = b[4,1]
			post `temp1' ("`protein'") (`n') (`rr') (`lci') (`uci') (`pval')
		}
		postclose `temp1'
		
	* Association with BMI
	cd "$PROECderived"
		tempname temp1
		postfile `temp1' str35 protein  ///
						 double n rr lci uci pval	///
						 using "`name'_bmi", replace
	 
	foreach protein of varlist $olk {	
		reg `protein' stdbmi `covar' // for every std increase in bmi
		local n	= e(N)
			matrix b = r(table)
			local rr = b[1,1]
			local lci = b[5,1]
			local uci = b[6,1]
			local pval = b[4,1]
			post `temp1' ("`protein'") (`n') (`rr') (`lci') (`uci') (`pval')
		}
		postclose `temp1'
end


// Perform linear regression
local covar = " "
* Controls 
preserve
keep if eccase==0
est_adipro, name(controls) covar("`covar'")
restore

* Controls + cases >10yrs from baseline
local covar = " "
preserve
keep if time_bld_diag >10 
tab eccase,m
est_adipro, name(cc10yrs) covar("`covar'")
restore

/* Controls + cases >2yrs from baseline
preserve
sum time_bld_diag
count if time_bld_diag <=2
keep if time_bld_diag>2
tab eccase,m
est_adipro, name(cc2yrs) covar("`covar'")
restore */


// Perform linear regression
local covar = "age_recr i.pa_index i.ever_pill i.ever_horm i.smoke_stat"
* Controls 
preserve
keep if eccase==0
est_adipro, name(adj_con) covar("`covar'")
restore

* Controls + cases >10yrs from baseline
local covar = "age_recr i.pa_index i.ever_pill i.ever_horm i.smoke_stat"
preserve
keep if time_bld_diag >10 
tab eccase,m
est_adipro, name(adj_cc10) covar("`covar'")
restore


********************************************************************************	

// Export results (Controls)
local sheet = "controls"
* Waist circumference
local adipro = "wc"
cd "$PROECderived"	
use "`sheet'_`adipro'", clear	
sort pval
cd "$PROECoutput"
tostring rr lci uci, replace force format(%9.2f)
export excel using "tab_PROEC_adipro.xlsx", firstrow(variables) sheet("`sheet'_`adipro'", replace) keepcellfmt
* BMI	
local adipro = "bmi"	
cd "$PROECderived"	
use "`sheet'_`adipro'", clear	
sort pval
cd "$PROECoutput"
tostring rr lci uci, replace force format(%9.2f)
export excel using "tab_PROEC_adipro.xlsx", firstrow(variables) sheet("`sheet'_`adipro'", replace) keepcellfmt
		

// Export results (Controls + cases >10yrs from baseline)
local sheet = "cc10yrs"
* Waist circumference
local adipro = "wc"
cd "$PROECderived"	
use "`sheet'_`adipro'", clear	
sort pval
cd "$PROECoutput"
tostring rr lci uci, replace force format(%9.2f)
export excel using "tab_PROEC_adipro.xlsx", firstrow(variables) sheet("`sheet'_`adipro'", replace) keepcellfmt
* BMI	
local adipro = "bmi"	
cd "$PROECderived"	
use "`sheet'_`adipro'", clear	
sort pval
cd "$PROECoutput"
tostring rr lci uci, replace force format(%9.2f)
export excel using "tab_PROEC_adipro.xlsx", firstrow(variables) sheet("`sheet'_`adipro'", replace) keepcellfmt

/* Export results (Controls + cases >2yrs from baseline)
local sheet = "cc2yrs"
* Waist circumference
local adipro = "wc"
cd "$PROECderived"	
use "`sheet'_`adipro'", clear	
sort pval
cd "$PROECoutput"
tostring rr lci uci, replace force format(%9.2f)
export excel using "tab_PROEC_adipro.xlsx", firstrow(variables) sheet("`sheet'_`adipro'", replace) keepcellfmt
* BMI	
local adipro = "bmi"	
cd "$PROECderived"	
use "`sheet'_`adipro'", clear	
sort pval
cd "$PROECoutput"
tostring rr lci uci, replace force format(%9.2f)
export excel using "tab_PROEC_adipro.xlsx", firstrow(variables) sheet("`sheet'_`adipro'", replace) keepcellfmt */


// Export results (Controls, adjusted)
local sheet = "adj_con"
* Waist circumference
local adipro = "wc"
cd "$PROECderived"	
use "`sheet'_`adipro'", clear	
sort pval
cd "$PROECoutput"
tostring rr lci uci, replace force format(%9.2f)
export excel using "tab_PROEC_adipro.xlsx", firstrow(variables) sheet("`sheet'_`adipro'", replace) keepcellfmt
* BMI	
local adipro = "bmi"	
cd "$PROECderived"	
use "`sheet'_`adipro'", clear	
sort pval
cd "$PROECoutput"
tostring rr lci uci, replace force format(%9.2f)
export excel using "tab_PROEC_adipro.xlsx", firstrow(variables) sheet("`sheet'_`adipro'", replace) keepcellfmt
		

// Export results (Controls + cases >10yrs from baseline, adjusted)
local sheet = "adj_cc10"
* Waist circumference
local adipro = "wc"
cd "$PROECderived"	
use "`sheet'_`adipro'", clear	
sort pval
cd "$PROECoutput"
tostring rr lci uci, replace force format(%9.2f)
export excel using "tab_PROEC_adipro.xlsx", firstrow(variables) sheet("`sheet'_`adipro'", replace) keepcellfmt
* BMI	
local adipro = "bmi"	
cd "$PROECderived"	
use "`sheet'_`adipro'", clear	
sort pval
cd "$PROECoutput"
tostring rr lci uci, replace force format(%9.2f)
export excel using "tab_PROEC_adipro.xlsx", firstrow(variables) sheet("`sheet'_`adipro'", replace) keepcellfmt

********************************************************************************

// Multiple testing correction: Compute bonferroni qvalue
* see: https://journals.sagepub.com/doi/pdf/10.1177/1536867X1101000403
* bonferroni method = one-step; FWER; arbitrary correlation assumed

global datasets = "controls_wc controls_bmi cc10yrs_wc cc10yrs_bmi adj_con_wc adj_con_bmi adj_cc10_wc adj_cc10_bmi"

foreach file in $datasets {
	cd "$PROECderived"
	use `file', clear

	cap drop qvalue npvalue
	qqvalue pval , method(bonferroni) qvalue(qvalue) npvalue(npvalue)
	sort qvalue
	order qvalue npvalue, last

	cd "$PROECderived"
	save `file', replace
	
	cd "$PROECoutput"
	tostring rr lci uci, replace force format(%9.2f)
	*local sheet = substr(`file',8,.)
	export excel using "tab_PROEC_adipro.xlsx", firstrow(variables) sheet("`file'", replace) keepcellfmt
}

********************************************************************************

*=======================*
*	scatterplot program	*
*=======================*

cap program drop scatterplot
program scatterplot
syntax, file(string) unit(string) pq(string) plabel(string) 
	cd "$PROECderived"
	use `file', clear
	
	* by panel
	gen str s_panel = substr(protein,-2,.) 
	encode s_panel, gen(panel) 
	drop s_panel
	label drop panel
	label define panel 1 "Inflammation" 2 "Immune response" 
	label value panel panel
	order panel protein
	
	* q=0.05
	gen neglogp = -log10(`pq')
	local yline = -log10(`plabel')
	recode neglogp .=29.9 // arbitery no. for very small pval displayed as 0

	* label name
	* label for those selected proteins only
	gen str label = substr(protein,5,.) 
	replace label = substr(label,1, length(label)-5) if panel==1 
	replace label = substr(label,1, length(label)-3) if panel==2
	replace label ="" if neglogp < -log10(`plabel')
	
	gen clock = 3
	replace clock = 9 if  label=="scf" | label=="trance" | label=="stc1"
	
	* scatter plot
	cd "$PROECoutput"
	cap graph drop "`file'"
	scatter neglogp rr, by(panel) yline(`yline') ///
			note(yline: `pq'=0.05, size(small)) ///
			mlabel(label) mlabangle(horizontal) mlabsize(small) ///
			mfcolor(%0) msize(small) mlcolor(navy) mlabvpos(clock) ///
			xtitle(Protein NPX change per `unit') ytitle("-Log(`pq')") name("`file'")
			graph export "adipro_`file'_`pq'.jpg", as(jpg) name("`file'") width(1600) height(1200)quality(100) replace
			graph close
end



cap program drop scatterplot_com_pval
program scatterplot_com_pval
syntax, file(string) unit(string) pq(string) plabel(string) 
	cd "$PROECderived"
	use `file', clear
	
	* panel
	gen str s_panel = substr(protein,-2,.) 
	encode s_panel, gen(panel) 
	drop s_panel
	label drop panel
	label define panel 1 "Inflammation" 2 "Immune response" 
	label value panel panel
	order panel protein
	
	* q=0.05
	gen neglogp = -log10(`pq')
	local yline = -log10(`plabel')
	recode neglogp .=29.9 // arbitery no. for very small pval displayed as 0

	* label name
	* label for those selected proteins only
	gen str label = substr(protein,5,.) 
	replace label = substr(label,1, length(label)-5) if panel==1 
	replace label = "il6_infl" if label=="il6" 
	replace label = substr(label,1, length(label)-3) if panel==2
	replace label = "il6_ir" if label=="il6" 
	replace label ="" if neglogp < 3
	
	gen clock = 3
	replace clock = 9 if  label=="scf"  | label=="stc1" | label=="clec4a" | label=="lilrb4"
	* scatter plot
	cd "$PROECoutput"
	cap graph drop "`file'"
	scatter neglogp rr, yline(`yline') ///
			note(yline: Q-value = 0.05, size(small)) ///
			mlabel(label) mlabangle(horizontal) mlabsize(small) ///
			mfcolor(%0) msize(small) mlcolor(navy) mlabvpos(clock) ///
			xlabel(-.2(.1).4) ///
			xtitle(Protein NPX change per `unit') ytitle("-Log(P-value)") name("`file'")
			graph export "adipro_`file'_`pq'.jpg", as(jpg) name("`file'") width(1600) height(1200)quality(100) replace
			graph close
end


cap program drop scatterplot_com_qval
program scatterplot_com_qval
syntax, file(string) unit(string) pq(string) plabel(string) 
	cd "$PROECderived"
	use `file', clear
	
	* panel
	gen str s_panel = substr(protein,-2,.) 
	encode s_panel, gen(panel) 
	drop s_panel
	label drop panel
	label define panel 1 "Inflammation" 2 "Immune response" 
	label value panel panel
	order panel protein
	
	* q=0.05
	gen neglogp = -log10(`pq')
	local yline = -log10(`plabel')
	recode neglogp .=29.9 // arbitery no. for very small pval displayed as 0

	* label name
	* label for those selected proteins only
	gen str label = substr(protein,5,.) 
	replace label = substr(label,1, length(label)-5) if panel==1 
	replace label = "il6_infl" if label=="il6" 
	replace label = substr(label,1, length(label)-3) if panel==2
	replace label = "il6_ir" if label=="il6" 
	replace label ="" if neglogp < -log10(`plabel')
	
	gen clock = 3
	replace clock = 9 if  label=="scf"  | label=="stc1" | label=="clec4a" | label=="lilrb4"
	* scatter plot
	cd "$PROECoutput"
	cap graph drop "`file'"
	scatter neglogp rr, yline(`yline') ///
			note(yline: Q-value = 0.05, size(small)) ///
			mlabel(label) mlabangle(horizontal) mlabsize(small) ///
			mfcolor(%0) msize(small) mlcolor(red) mlabvpos(clock) ///
			xlabel(-.2(.1).4) ///
			xtitle(Protein NPX change per `unit') ytitle("-Log(Q-value)") name("`file'")
			graph export "adipro_`file'_`pq'.jpg", as(jpg) name("`file'") width(1600) height(1200)quality(100) replace
			*graph close
end



// Plot scatterplot

local pq 	= "qvalue" 	// plot with qvalue
local pval 	= 0.05		// set threshold
	scatterplot, file(controls_wc) unit(SD increase in waist circumference) pq(`pq') plabel(`pval')
	scatterplot, file(controls_bmi) unit(SD increase in BMI) pq(`pq') plabel(`pval')
	*scatterplot, file(cc2yrs_wc) unit(SD increase in waist circumference) pq(`pq') plabel(`pval')
	*scatterplot, file(cc2yrs_bmi) unit(SD increase in BMI) pq(`pq') plabel(`pval')
	scatterplot, file(cc10yrs_wc) unit(SD increase in waist circumference) pq(`pq') plabel(`pval')
	scatterplot, file(cc10yrs_bmi) unit(SD increase in BMI) pq(`pq') plabel(`pval')
	scatterplot, file(adj_con_wc) unit(SD increase in waist circumference) pq(`pq') plabel(`pval')
	scatterplot, file(adj_con_bmi) unit(SD increase in BMI) pq(`pq') plabel(`pval')
	scatterplot, file(adj_cc10_wc) unit(SD increase in waist circumference) pq(`pq') plabel(`pval')
	scatterplot, file(adj_cc10_bmi) unit(SD increase in BMI) pq(`pq') plabel(`pval')
	
local pq 	= "pval" 	// plot with pval
local pval 	= 0.000001 	// set threshold
	scatterplot, file(controls_wc) unit(SD increase in waist circumference) pq(`pq') plabel(`pval')
	scatterplot, file(controls_bmi) unit(SD increase in BMI) pq(`pq') plabel(`pval')
	*scatterplot, file(cc2yrs_wc) unit(SD increase in waist circumference) pq(`pq') plabel(`pval')
	*scatterplot, file(cc2yrs_bmi) unit(SD increase in BMI) pq(`pq') plabel(`pval')
	scatterplot, file(cc10yrs_wc) unit(SD increase in waist circumference) pq(`pq') plabel(`pval')
	scatterplot, file(cc10yrs_bmi) unit(SD increase in BMI) pq(`pq') plabel(`pval')
	scatterplot, file(adj_con_wc) unit(SD increase in waist circumference) pq(`pq') plabel(`pval')
	scatterplot, file(adj_con_bmi) unit(SD increase in BMI) pq(`pq') plabel(`pval')
	scatterplot, file(adj_cc10_wc) unit(SD increase in waist circumference) pq(`pq') plabel(`pval')
	scatterplot, file(adj_cc10_bmi) unit(SD increase in BMI) pq(`pq') plabel(`pval')


scatterplot_com_qval, file(controls_wc) unit(SD increase in waist circumference) pq("qvalue") plabel(0.05)
scatterplot_com_qval, file(controls_bmi) unit(SD increase in BMI) pq("qvalue") plabel(0.05)	
scatterplot_com_qval, file(adj_con_wc) unit(SD increase in waist circumference) pq("qvalue") plabel(0.05)
scatterplot_com_qval, file(adj_con_bmi) unit(SD increase in BMI) pq("qvalue") plabel(0.05)	
scatterplot_com_pval, file(adj_con_bmi) unit(SD increase in BMI) pq("pval") plabel(0.05)	
	
********************************************************************************
log close



/*
cap graph drop "`sheet'_`adipro'"
hist pval, freq addlabels width(0.1) name("`sheet'_`adipro'")
	graph export "adipro_hist_`sheet'_`adipro'.jpg", as(jpg) name("`sheet'_`adipro'") ///
		width(1600) height(1200) quality(100) replace