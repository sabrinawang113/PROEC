********************************************************************************
*	Do-file:		2_3AN_proteins_distr.do
*	Project:		PROEC: Proteomics for endometrial cancer case-control
*
*	Data used:		PROEC_qcflag.dta
*
*	Data created:	ppt_olink_descriptive.pptx
*
* 	Purpose:  		Descriptive analysis for olink assays
*					Examine normality and outliers 
*
*	Date:			02-MAY-2023
*	Author: 		Sabrina Wang
********************************************************************************

// run the 0_settings.do for this project
capture log close 
cd "$PROEClog"
log using "2_3AN_proteins_distr$current_date", replace
set linesize 255

di "Stata Version: `c(stata_version)'"
di "Current Date: `c(current_date)'"

*cap ssc install schemepack, replace
set scheme tab2
graph set window fontface "Helvetica"


********************************************************************************

// import initial datasets
* PROEC_qcflag
* PROEC_coredata

local dataset = "PROEC_coredata"

cd "$PROECderived"
use `dataset', clear

********************************************************************************

// Normality
*  Shapiro –Wilk W test for normality

// all olk proteins	
*global olk = "olk_il8_infl olk_vegfa_infl olk_cd8a_infl olk_mcp_3_infl olk_gdnf_infl olk_cdcp1_infl olk_cd244_infl olk_il7_infl olk_opg_infl olk_laptgf_beta_1_infl olk_upa_infl olk_il6_infl olk_il_17c_infl olk_mcp_1_infl olk_il_17a_infl olk_cxcl11_infl olk_axin1_infl olk_trail_infl olk_il_20ra_infl olk_cxcl9_infl olk_cst5_infl olk_il_2rb_infl olk_il_1alpha_infl olk_osm_infl olk_il2_infl olk_cxcl1_infl olk_tslp_infl olk_ccl4_infl olk_cd6_infl olk_scf_infl olk_il18_infl olk_slamf1_infl olk_tgf_alpha_infl olk_mcp_4_infl olk_ccl11_infl olk_tnfsf14_infl olk_fgf_23_infl olk_il_10ra_infl olk_fgf_5_infl olk_mmp_1_infl olk_lif_r_infl olk_fgf_21_infl olk_ccl19_infl olk_il_15ra_infl olk_il_10rb_infl olk_il_22ra1_infl olk_il_18r1_infl olk_pd_l1_infl olk_beta_ngf_infl olk_cxcl5_infl olk_trance_infl olk_hgf_infl olk_il_12b_infl olk_il_24_infl olk_il13_infl olk_artn_infl olk_mmp_10_infl olk_il10_infl olk_tnf_infl olk_ccl23_infl olk_cd5_infl olk_ccl3_infl olk_flt3l_infl olk_cxcl6_infl olk_cxcl10_infl olk_4e_bp1_infl olk_il_20_infl olk_sirt2_infl olk_ccl28_infl olk_dner_infl olk_en_rage_infl olk_cd40_infl olk_il33_infl olk_ifn_gamma_infl olk_fgf_19_infl olk_il4_infl olk_lif_infl olk_nrtn_infl olk_mcp_2_infl olk_casp_8_infl olk_ccl25_infl olk_cx3cl1_infl olk_tnfrsf9_infl olk_nt_3_infl olk_tweak_infl olk_ccl20_infl olk_st1a1_infl olk_stambp_infl olk_il5_infl olk_ada_infl olk_tnfb_infl olk_csf_1_infl olk_ppp1r9b_ir olk_glb1_ir olk_psip1_ir olk_zbtb16_ir olk_irak4_ir olk_tpsab1_ir olk_hcls1_ir olk_cntnap2_ir olk_clec4g_ir olk_irf9_ir olk_edar_ir olk_il6_ir olk_dgkz_ir olk_clec4c_ir olk_irak1_ir olk_clec4a_ir olk_prdx1_ir olk_prdx3_ir olk_fgf2_ir olk_prdx5_ir olk_dpp10_ir olk_trim5_ir olk_dctn1_ir olk_itga6_ir olk_cdsn_ir olk_galnt3_ir olk_fxyd5_ir olk_traf2_ir olk_trim21_ir olk_lilrb4_ir olk_ntf4_ir olk_krt19_ir olk_itm2a_ir olk_hnmt_ir olk_ccl11_ir olk_milr1_ir olk_egln1_ir olk_nfatc3_ir olk_ly75_ir olk_eif5a_ir olk_eif4g1_ir olk_cd28_ir olk_pth1r_ir olk_birc2_ir olk_hsd11b1_ir olk_nf2_ir olk_plxna4_ir olk_sh2b3_ir olk_fcrl3_ir olk_ckap4_ir olk_jun_ir olk_hexim1_ir olk_clec4d_ir olk_prkcq_ir olk_mgmt_ir olk_trem1_ir olk_cxadr_ir olk_il10_ir olk_srpk2_ir olk_klrd1_ir olk_bach1_ir olk_pik3ap1_ir olk_spry2_ir olk_stc1_ir olk_arnt_ir olk_fam3b_ir olk_sh2d1a_ir olk_ica1_ir olk_dffa_ir olk_dcbld2_ir olk_fcrl6_ir olk_ncr1_ir olk_cxcl12_ir olk_areg_ir olk_ifnlr1_ir olk_dapp1_ir olk_padi2_ir olk_sit1_ir olk_masp1_ir olk_lamp3_ir olk_clec7a_ir olk_clec6a_ir olk_ddx58_ir olk_il12rb1_ir olk_tank_ir olk_itga11_ir olk_kpna1_ir olk_lag3_ir olk_il5_ir olk_cd83_ir olk_itgb6_ir olk_btn3a2_ir"

// olk proteins >75% above lod
global olk = "olk_il8_infl olk_vegfa_infl olk_cd8a_infl olk_mcp_3_infl olk_gdnf_infl olk_cdcp1_infl olk_cd244_infl olk_il7_infl olk_opg_infl olk_laptgf_beta_1_infl olk_upa_infl olk_il6_infl olk_il_17c_infl olk_mcp_1_infl olk_il_17a_infl olk_cxcl11_infl olk_axin1_infl olk_trail_infl olk_cxcl9_infl olk_cst5_infl olk_il_2rb_infl olk_osm_infl olk_cxcl1_infl olk_ccl4_infl olk_cd6_infl olk_scf_infl olk_il18_infl olk_slamf1_infl olk_tgf_alpha_infl olk_mcp_4_infl olk_ccl11_infl olk_tnfsf14_infl olk_fgf_23_infl olk_il_10ra_infl olk_fgf_5_infl olk_mmp_1_infl olk_lif_r_infl olk_fgf_21_infl olk_ccl19_infl olk_il_10rb_infl olk_il_18r1_infl olk_pd_l1_infl olk_cxcl5_infl olk_trance_infl olk_hgf_infl olk_il_12b_infl olk_mmp_10_infl olk_il10_infl olk_tnf_infl olk_ccl23_infl olk_cd5_infl olk_ccl3_infl olk_flt3l_infl olk_cxcl6_infl olk_cxcl10_infl olk_4e_bp1_infl olk_sirt2_infl olk_ccl28_infl olk_dner_infl olk_en_rage_infl olk_cd40_infl olk_ifn_gamma_infl olk_fgf_19_infl olk_mcp_2_infl olk_casp_8_infl olk_ccl25_infl olk_cx3cl1_infl olk_tnfrsf9_infl olk_nt_3_infl olk_tweak_infl olk_ccl20_infl olk_st1a1_infl olk_stambp_infl olk_ada_infl olk_tnfb_infl olk_csf_1_infl olk_ppp1r9b_ir olk_glb1_ir olk_psip1_ir olk_zbtb16_ir olk_tpsab1_ir olk_hcls1_ir olk_cntnap2_ir olk_clec4g_ir olk_irf9_ir olk_edar_ir olk_il6_ir olk_clec4c_ir olk_irak1_ir olk_clec4a_ir olk_prdx1_ir olk_prdx3_ir olk_fgf2_ir olk_prdx5_ir olk_dpp10_ir olk_trim5_ir olk_dctn1_ir olk_itga6_ir olk_cdsn_ir olk_traf2_ir olk_trim21_ir olk_lilrb4_ir olk_ntf4_ir olk_krt19_ir olk_itm2a_ir olk_hnmt_ir olk_ccl11_ir olk_milr1_ir olk_egln1_ir olk_nfatc3_ir olk_ly75_ir olk_eif4g1_ir olk_cd28_ir olk_pth1r_ir olk_hsd11b1_ir olk_plxna4_ir olk_sh2b3_ir olk_fcrl3_ir olk_ckap4_ir olk_jun_ir olk_hexim1_ir olk_clec4d_ir olk_prkcq_ir olk_mgmt_ir olk_cxadr_ir olk_il10_ir olk_srpk2_ir olk_klrd1_ir olk_bach1_ir olk_pik3ap1_ir olk_spry2_ir olk_stc1_ir olk_fam3b_ir olk_sh2d1a_ir olk_dffa_ir olk_dcbld2_ir olk_fcrl6_ir olk_ncr1_ir olk_areg_ir olk_ifnlr1_ir olk_dapp1_ir olk_sit1_ir olk_masp1_ir olk_lamp3_ir olk_clec7a_ir olk_clec6a_ir olk_ddx58_ir olk_il12rb1_ir olk_itga11_ir olk_kpna1_ir olk_lag3_ir olk_il5_ir olk_cd83_ir olk_itgb6_ir olk_btn3a2_ir"


tempname temp1
tempfile temp2
postfile `temp1' str35	protein  ///
				 double w 	///
				 using `temp2', replace
				
foreach protein of varlist $olk {
	swilk `protein'
	local w = r(W)
	post `temp1' ("`protein'") (`w')
}

postclose `temp1'
use `temp2', clear

cd "$PROECderived"
save olink_normality, replace

// merge in lod
use olink_normality, clear
merge 1:1 protein using olink_lod_proteins
drop _merge

// histogram
hist w, freq addl
cd "$PROECoutput"
local file = "olink_normality"
	cap graph drop "`file'"
hist w, freq addl name("`file'")
	graph export "`file'.jpg", as(jpg) name("`file'") ///
		width(1600) height(1200)quality(100) replace
		
// export as excel
sort w

preserve
keep protein w pbelow

cd "$PROECoutput"
tostring w pbelow, replace force format(%9.3f)
export excel using "tab_olink_normality_lod.xlsx", firstrow(variables) sheet("`dataset'", replace) keepcellfmt
restore

********************************************************************************	
********************************************************************************

// import initial datasets

cd "$PROECderived"
use `dataset', clear

********************************************************************************
********************************************************************************

// Outliers

* qc warnings
list idepic qcfail_infl qcfail_ir if qcfail==1
/*
      +---------------------------------------------+
      |         idepic      n   qcfail~l   qcfail~r |
      |---------------------------------------------|
  31. | 13______602947     31    Warning       Pass |
  41. | 14______374832     41    Warning    Warning |
  60. | 16______443705     60    Warning       Pass |
 143. | 21____21069050    143    Warning    Warning |
 148. | 21____21071323    148       Pass    Warning |
      |---------------------------------------------|
 149. | 21____21071485    149    Warning       Pass |
 188. | 21____21124294    188       Pass    Warning |
 211. | 22____22212080    211    Warning    Warning |
 254. | 22____22232835    254    Warning    Warning |
 289. | 22____22274344    289    Warning    Warning |
      |---------------------------------------------|
 304. | 22____22305131    304    Warning    Warning |
 320. | 23____23412773    320    Warning       Pass |
 353. | 24____24618344    353    Warning    Warning |
 378. | 24____24689769    378    Warning       Pass |
 430. | 31____3102024E    430       Pass    Warning |
      |---------------------------------------------|
 476. | 32____3201864E    476    Warning       Pass |
 479. | 32____3202528I    479       Pass    Warning |
 536. | 33____3301413D    536    Warning    Warning |
 552. | 33____3305812C    552       Pass    Warning |
 588. | 33____3309110A    588    Warning       Pass |
      |---------------------------------------------|
 606. | 34____3401823D    606       Pass    Warning |
 620. | 34____3404248I    620    Warning       Pass |
 726. | 41____41055205    726       Pass    Warning |
 849. | 42_______32124    849    Warning       Pass |
 876. | 42_______64216    876    Warning       Pass |
      |---------------------------------------------|
 889. | 42_______69947    889    Warning       Pass |
 906. | 51______467358    906       Pass    Warning |
 916. | 51______510261    916    Warning    Warning |
 962. | 52_31300300570    962    Warning       Pass |
 969. | 52_31600601600    969    Warning       Pass |
      |---------------------------------------------|
1043. | 52_34401104563   1043    Warning       Pass |
1187. | 72__7210033344   1187    Warning    Warning |
      +---------------------------------------------+
*/


// Define outliers 

local sd = 3 // 3sd from mean
local iqr = 3 // p25-3*iqr | p75+3*iqr

// Summary of outliers 
cd "$PROECderived"
tempname temp1
postfile `temp1' str35	protein  ///
				 double outl_`sd'sd 	///
				 double outl_sdqcfail ///
				 double outl_`iqr'iqr 	///
				 double outl_iqrqcfail ///
				 using olink_outliers, replace

foreach var of varlist $olk {
	
	egen std`var' = std(`var')
	gen sdoutlier`var' =1 if (std`var'>`sd') | (std`var'<-`sd')
	recode sdoutlier`var' .=0
	count if sdoutlier`var'==1
	local ns = r(N)
	
	preserve
	keep if qcfail==1
	count if sdoutlier`var'==1
	local qcns = r(N)
	restore
	
	cap drop iqr p25 p75 upperlimit lowerlimit
		egen iqr = iqr(`var')
		egen p25 = pctile(`var'), p(25)
		egen p75 = pctile(`var'), p(75)
		gen upperlimit = p75+(`iqr'*iqr)
		gen lowerlimit = p25-(`iqr'*iqr)
	gen iqroutlier`var' =1 if (`var'> upperlimit) | (`var'< lowerlimit)
	recode iqroutlier`var' .=0
	count if iqroutlier`var'==1
	local nq = r(N)
	
	preserve
	keep if qcfail==1
	count if iqroutlier`var'==1
	local qcnq = r(N)
	restore
	
	post `temp1' ("`var'") (`ns') (`qcns') (`nq') (`qcnq')
}


postclose `temp1'
use olink_outliers, clear


********************************************************************************

// Combine all protein information

cd "$PROECderived"
use olink_lod_proteins, clear
rename nbelow lod_nbelow
rename pbelow lod_pbelow
drop nnormal

merge 1:1 protein using olink_normality
drop _merge
rename w normality_w

merge 1:1 protein using olink_outliers
drop _merge

* by panel
gen str s_panel = substr(protein,-2,.) 
	encode s_panel, gen(panel) 
	drop s_panel
	label drop panel
	label define panel 1 "INFL" 2 "IR" 
	label value panel panel
	order panel protein
	
save olink_summary, replace


* export as excel
cd "$PROECoutput"
sort lod_pbelow normality_w
tostring lod_pbelow, replace force format(%9.2f)
tostring normality_w, replace force format(%9.3f)
export excel using "tab_olink_summary.xlsx", firstrow(variables) sheet("`dataset'", replace) keepcellfmt


********************************************************************************
log close

********************************************************************************
/********************************************************************************
// visual examinations
* PROEC_qcflag
* PROEC_coredata

local dataset = "PROEC_qcflag"

cd "$PROECderived"
use `dataset', clear

local protein = "olk_fgf_23_infl"
hist `protein', freq addl name(histogram)
stripplot `protein', box(barw(0.02)) iqr(3) boffset(0.05)

