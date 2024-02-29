********************************************************************************
*	Do-file:		2_1AN_proteins_lod.do
*	Project:		PROEC: Proteomics for endometrial cancer case-control
*
*	Data used:		PROEC_qcflag.dta
*
*	Data created:	olink_lod_proteins.dta
*
* 	Purpose:  		Descriptive analysis for olink assays
*					Examine measurements under LOD
*
*	Date:			06-APR-2023
*	Author: 		Sabrina Wang
********************************************************************************

// run the 0_settings.do for this project
capture log close 
cd "$PROEClog"
log using "2_1AN_proteins_lod$current_date", replace
set linesize 255

di "Stata Version: `c(stata_version)'"
di "Current Date: `c(current_date)'"

*cap ssc install schemepack, replace
set scheme tab2
graph set window fontface "Helvetica"

********************************************************************************
********************************************************************************

// import dataset
*PROEC_qcflag
*PROEC_coredata
cd "$PROECderived"
use PROEC_coredata, clear

********************************************************************************
********************************************************************************

global infl = ///
"olk_il8_infl olk_vegfa_infl olk_cd8a_infl olk_mcp_3_infl olk_gdnf_infl olk_cdcp1_infl olk_cd244_infl olk_il7_infl olk_opg_infl olk_laptgf_beta_1_infl olk_upa_infl olk_il6_infl olk_il_17c_infl olk_mcp_1_infl olk_il_17a_infl olk_cxcl11_infl olk_axin1_infl olk_trail_infl olk_il_20ra_infl olk_cxcl9_infl olk_cst5_infl olk_il_2rb_infl olk_il_1alpha_infl olk_osm_infl olk_il2_infl olk_cxcl1_infl olk_tslp_infl olk_ccl4_infl olk_cd6_infl olk_scf_infl olk_il18_infl olk_slamf1_infl olk_tgf_alpha_infl olk_mcp_4_infl olk_ccl11_infl olk_tnfsf14_infl olk_fgf_23_infl olk_il_10ra_infl olk_fgf_5_infl olk_mmp_1_infl olk_lif_r_infl olk_fgf_21_infl olk_ccl19_infl olk_il_15ra_infl olk_il_10rb_infl olk_il_22ra1_infl olk_il_18r1_infl olk_pd_l1_infl olk_beta_ngf_infl olk_cxcl5_infl olk_trance_infl olk_hgf_infl olk_il_12b_infl olk_il_24_infl olk_il13_infl olk_artn_infl olk_mmp_10_infl olk_il10_infl olk_tnf_infl olk_ccl23_infl olk_cd5_infl olk_ccl3_infl olk_flt3l_infl olk_cxcl6_infl olk_cxcl10_infl olk_4e_bp1_infl olk_il_20_infl olk_sirt2_infl olk_ccl28_infl olk_dner_infl olk_en_rage_infl olk_cd40_infl olk_il33_infl olk_ifn_gamma_infl olk_fgf_19_infl olk_il4_infl olk_lif_infl olk_nrtn_infl olk_mcp_2_infl olk_casp_8_infl olk_ccl25_infl olk_cx3cl1_infl olk_tnfrsf9_infl olk_nt_3_infl olk_tweak_infl olk_ccl20_infl olk_st1a1_infl olk_stambp_infl olk_il5_infl olk_ada_infl olk_tnfb_infl olk_csf_1_infl"

global ires = ///
"olk_ppp1r9b_ir olk_glb1_ir olk_psip1_ir olk_zbtb16_ir olk_irak4_ir olk_tpsab1_ir olk_hcls1_ir olk_cntnap2_ir olk_clec4g_ir olk_irf9_ir olk_edar_ir olk_il6_ir olk_dgkz_ir olk_clec4c_ir olk_irak1_ir olk_clec4a_ir olk_prdx1_ir olk_prdx3_ir olk_fgf2_ir olk_prdx5_ir olk_dpp10_ir olk_trim5_ir olk_dctn1_ir olk_itga6_ir olk_cdsn_ir olk_galnt3_ir olk_fxyd5_ir olk_traf2_ir olk_trim21_ir olk_lilrb4_ir olk_ntf4_ir olk_krt19_ir olk_itm2a_ir olk_hnmt_ir olk_ccl11_ir olk_milr1_ir olk_egln1_ir olk_nfatc3_ir olk_ly75_ir olk_eif5a_ir olk_eif4g1_ir olk_cd28_ir olk_pth1r_ir olk_birc2_ir olk_hsd11b1_ir olk_nf2_ir olk_plxna4_ir olk_sh2b3_ir olk_fcrl3_ir olk_ckap4_ir olk_jun_ir olk_hexim1_ir olk_clec4d_ir olk_prkcq_ir olk_mgmt_ir olk_trem1_ir olk_cxadr_ir olk_il10_ir olk_srpk2_ir olk_klrd1_ir olk_bach1_ir olk_pik3ap1_ir olk_spry2_ir olk_stc1_ir olk_arnt_ir olk_fam3b_ir olk_sh2d1a_ir olk_ica1_ir olk_dffa_ir olk_dcbld2_ir olk_fcrl6_ir olk_ncr1_ir olk_cxcl12_ir olk_areg_ir olk_ifnlr1_ir olk_dapp1_ir olk_padi2_ir olk_sit1_ir olk_masp1_ir olk_lamp3_ir olk_clec7a_ir olk_clec6a_ir olk_ddx58_ir olk_il12rb1_ir olk_tank_ir olk_itga11_ir olk_kpna1_ir olk_lag3_ir olk_il5_ir olk_cd83_ir olk_itgb6_ir olk_btn3a2_ir"

global Outdpflag = ///
"outdq_olk_4e_bp1_infl outdq_olk_ada_infl outdq_olk_areg_ir outdq_olk_arnt_ir outdq_olk_artn_infl outdq_olk_axin1_infl outdq_olk_bach1_ir outdq_olk_beta_ngf_infl outdq_olk_birc2_ir outdq_olk_btn3a2_ir outdq_olk_casp_8_infl outdq_olk_ccl11_ir outdq_olk_ccl11_infl outdq_olk_ccl19_infl outdq_olk_ccl20_infl outdq_olk_ccl23_infl outdq_olk_ccl25_infl outdq_olk_ccl28_infl outdq_olk_ccl3_infl outdq_olk_ccl4_infl outdq_olk_cd244_infl outdq_olk_cd28_ir outdq_olk_cd40_infl outdq_olk_cd5_infl outdq_olk_cd6_infl outdq_olk_cd83_ir outdq_olk_cd8a_infl outdq_olk_cdcp1_infl outdq_olk_cdsn_ir outdq_olk_ckap4_ir outdq_olk_clec4a_ir outdq_olk_clec4c_ir outdq_olk_clec4d_ir outdq_olk_clec4g_ir outdq_olk_clec6a_ir outdq_olk_clec7a_ir outdq_olk_cntnap2_ir outdq_olk_csf_1_infl outdq_olk_cst5_infl outdq_olk_cx3cl1_infl outdq_olk_cxadr_ir outdq_olk_cxcl10_infl outdq_olk_cxcl11_infl outdq_olk_cxcl12_ir outdq_olk_cxcl1_infl outdq_olk_cxcl5_infl outdq_olk_cxcl6_infl outdq_olk_cxcl9_infl outdq_olk_dapp1_ir outdq_olk_dcbld2_ir outdq_olk_dctn1_ir outdq_olk_ddx58_ir outdq_olk_dffa_ir outdq_olk_dgkz_ir outdq_olk_dner_infl outdq_olk_dpp10_ir outdq_olk_edar_ir outdq_olk_egln1_ir outdq_olk_eif4g1_ir outdq_olk_eif5a_ir outdq_olk_en_rage_infl outdq_olk_fam3b_ir outdq_olk_fcrl3_ir outdq_olk_fcrl6_ir outdq_olk_fgf2_ir outdq_olk_fgf_19_infl outdq_olk_fgf_21_infl outdq_olk_fgf_23_infl outdq_olk_fgf_5_infl outdq_olk_flt3l_infl outdq_olk_fxyd5_ir outdq_olk_galnt3_ir outdq_olk_gdnf_infl outdq_olk_glb1_ir outdq_olk_hcls1_ir outdq_olk_hexim1_ir outdq_olk_hgf_infl outdq_olk_hnmt_ir outdq_olk_hsd11b1_ir outdq_olk_ica1_ir outdq_olk_ifn_gamma_infl outdq_olk_ifnlr1_ir outdq_olk_il10_ir outdq_olk_il10_infl outdq_olk_il12rb1_ir outdq_olk_il13_infl outdq_olk_il18_infl outdq_olk_il2_infl outdq_olk_il33_infl outdq_olk_il4_infl outdq_olk_il5_ir outdq_olk_il5_infl outdq_olk_il6_ir outdq_olk_il6_infl outdq_olk_il7_infl outdq_olk_il8_infl outdq_olk_il_10ra_infl outdq_olk_il_10rb_infl outdq_olk_il_12b_infl outdq_olk_il_15ra_infl outdq_olk_il_17a_infl outdq_olk_il_17c_infl outdq_olk_il_18r1_infl outdq_olk_il_1alpha_infl outdq_olk_il_20_infl outdq_olk_il_20ra_infl outdq_olk_il_22ra1_infl outdq_olk_il_24_infl outdq_olk_il_2rb_infl outdq_olk_irak1_ir outdq_olk_irak4_ir outdq_olk_irf9_ir outdq_olk_itga11_ir outdq_olk_itga6_ir outdq_olk_itgb6_ir outdq_olk_itm2a_ir outdq_olk_jun_ir outdq_olk_klrd1_ir outdq_olk_kpna1_ir outdq_olk_krt19_ir outdq_olk_lag3_ir outdq_olk_lamp3_ir outdq_olk_laptgf_beta_1_infl outdq_olk_lif_infl outdq_olk_lif_r_infl outdq_olk_lilrb4_ir outdq_olk_ly75_ir outdq_olk_masp1_ir outdq_olk_mcp_1_infl outdq_olk_mcp_2_infl outdq_olk_mcp_3_infl outdq_olk_mcp_4_infl outdq_olk_mgmt_ir outdq_olk_milr1_ir outdq_olk_mmp_10_infl outdq_olk_mmp_1_infl outdq_olk_ncr1_ir outdq_olk_nf2_ir outdq_olk_nfatc3_ir outdq_olk_nrtn_infl outdq_olk_nt_3_infl outdq_olk_ntf4_ir outdq_olk_opg_infl outdq_olk_osm_infl outdq_olk_padi2_ir outdq_olk_pd_l1_infl outdq_olk_pik3ap1_ir outdq_olk_plxna4_ir outdq_olk_ppp1r9b_ir outdq_olk_prdx1_ir outdq_olk_prdx3_ir outdq_olk_prdx5_ir outdq_olk_prkcq_ir outdq_olk_psip1_ir outdq_olk_pth1r_ir outdq_olk_scf_infl outdq_olk_sh2b3_ir outdq_olk_sh2d1a_ir outdq_olk_sirt2_infl outdq_olk_sit1_ir outdq_olk_slamf1_infl outdq_olk_spry2_ir outdq_olk_srpk2_ir outdq_olk_st1a1_infl outdq_olk_stambp_infl outdq_olk_stc1_ir outdq_olk_tank_ir outdq_olk_tgf_alpha_infl outdq_olk_tnf_infl outdq_olk_tnfb_infl outdq_olk_tnfrsf9_infl outdq_olk_tnfsf14_infl outdq_olk_tpsab1_ir outdq_olk_traf2_ir outdq_olk_trail_infl outdq_olk_trance_infl outdq_olk_trem1_ir outdq_olk_trim21_ir outdq_olk_trim5_ir outdq_olk_tslp_infl outdq_olk_tweak_infl outdq_olk_upa_infl outdq_olk_vegfa_infl outdq_olk_zbtb16_ir"

preserve
keep *_ir
global Outdpflag_ires = ///
"outdq_olk_areg_ir outdq_olk_arnt_ir outdq_olk_bach1_ir outdq_olk_birc2_ir outdq_olk_btn3a2_ir outdq_olk_ccl11_ir outdq_olk_cd28_ir outdq_olk_cd83_ir outdq_olk_cdsn_ir outdq_olk_ckap4_ir outdq_olk_clec4a_ir outdq_olk_clec4c_ir outdq_olk_clec4d_ir outdq_olk_clec4g_ir outdq_olk_clec6a_ir outdq_olk_clec7a_ir outdq_olk_cntnap2_ir outdq_olk_cxadr_ir outdq_olk_cxcl12_ir outdq_olk_dapp1_ir outdq_olk_dcbld2_ir outdq_olk_dctn1_ir outdq_olk_ddx58_ir outdq_olk_dffa_ir outdq_olk_dgkz_ir outdq_olk_dpp10_ir outdq_olk_edar_ir outdq_olk_egln1_ir outdq_olk_eif4g1_ir outdq_olk_eif5a_ir outdq_olk_fam3b_ir outdq_olk_fcrl3_ir outdq_olk_fcrl6_ir outdq_olk_fgf2_ir outdq_olk_fxyd5_ir outdq_olk_galnt3_ir outdq_olk_glb1_ir outdq_olk_hcls1_ir outdq_olk_hexim1_ir outdq_olk_hnmt_ir outdq_olk_hsd11b1_ir outdq_olk_ica1_ir outdq_olk_ifnlr1_ir outdq_olk_il10_ir outdq_olk_il12rb1_ir outdq_olk_il5_ir outdq_olk_il6_ir outdq_olk_irak1_ir outdq_olk_irak4_ir outdq_olk_irf9_ir outdq_olk_itga11_ir outdq_olk_itga6_ir outdq_olk_itgb6_ir outdq_olk_itm2a_ir outdq_olk_jun_ir outdq_olk_klrd1_ir outdq_olk_kpna1_ir outdq_olk_krt19_ir outdq_olk_lag3_ir outdq_olk_lamp3_ir outdq_olk_lilrb4_ir outdq_olk_ly75_ir outdq_olk_masp1_ir outdq_olk_mgmt_ir outdq_olk_milr1_ir outdq_olk_ncr1_ir outdq_olk_nf2_ir outdq_olk_nfatc3_ir outdq_olk_ntf4_ir outdq_olk_padi2_ir outdq_olk_pik3ap1_ir outdq_olk_plxna4_ir outdq_olk_ppp1r9b_ir outdq_olk_prdx1_ir outdq_olk_prdx3_ir outdq_olk_prdx5_ir outdq_olk_prkcq_ir outdq_olk_psip1_ir outdq_olk_pth1r_ir outdq_olk_sh2b3_ir outdq_olk_sh2d1a_ir outdq_olk_sit1_ir outdq_olk_spry2_ir outdq_olk_srpk2_ir outdq_olk_stc1_ir outdq_olk_tank_ir outdq_olk_tpsab1_ir outdq_olk_traf2_ir outdq_olk_trem1_ir outdq_olk_trim21_ir outdq_olk_trim5_ir outdq_olk_zbtb16_ir"
restore

preserve
keep *_infl
global Outdpflag_infl = ///
"outdq_olk_4e_bp1_infl outdq_olk_ada_infl outdq_olk_artn_infl outdq_olk_axin1_infl outdq_olk_beta_ngf_infl outdq_olk_casp_8_infl outdq_olk_ccl11_infl outdq_olk_ccl19_infl outdq_olk_ccl20_infl outdq_olk_ccl23_infl outdq_olk_ccl25_infl outdq_olk_ccl28_infl outdq_olk_ccl3_infl outdq_olk_ccl4_infl outdq_olk_cd244_infl outdq_olk_cd40_infl outdq_olk_cd5_infl outdq_olk_cd6_infl outdq_olk_cd8a_infl outdq_olk_cdcp1_infl outdq_olk_csf_1_infl outdq_olk_cst5_infl outdq_olk_cx3cl1_infl outdq_olk_cxcl10_infl outdq_olk_cxcl11_infl outdq_olk_cxcl1_infl outdq_olk_cxcl5_infl outdq_olk_cxcl6_infl outdq_olk_cxcl9_infl outdq_olk_dner_infl outdq_olk_en_rage_infl outdq_olk_fgf_19_infl outdq_olk_fgf_21_infl outdq_olk_fgf_23_infl outdq_olk_fgf_5_infl outdq_olk_flt3l_infl outdq_olk_gdnf_infl outdq_olk_hgf_infl outdq_olk_ifn_gamma_infl outdq_olk_il10_infl outdq_olk_il13_infl outdq_olk_il18_infl outdq_olk_il2_infl outdq_olk_il33_infl outdq_olk_il4_infl outdq_olk_il5_infl outdq_olk_il6_infl outdq_olk_il7_infl outdq_olk_il8_infl outdq_olk_il_10ra_infl outdq_olk_il_10rb_infl outdq_olk_il_12b_infl outdq_olk_il_15ra_infl outdq_olk_il_17a_infl outdq_olk_il_17c_infl outdq_olk_il_18r1_infl outdq_olk_il_1alpha_infl outdq_olk_il_20_infl outdq_olk_il_20ra_infl outdq_olk_il_22ra1_infl outdq_olk_il_24_infl outdq_olk_il_2rb_infl outdq_olk_laptgf_beta_1_infl outdq_olk_lif_infl outdq_olk_lif_r_infl outdq_olk_mcp_1_infl outdq_olk_mcp_2_infl outdq_olk_mcp_3_infl outdq_olk_mcp_4_infl outdq_olk_mmp_10_infl outdq_olk_mmp_1_infl outdq_olk_nrtn_infl outdq_olk_nt_3_infl outdq_olk_opg_infl outdq_olk_osm_infl outdq_olk_pd_l1_infl outdq_olk_scf_infl outdq_olk_sirt2_infl outdq_olk_slamf1_infl outdq_olk_st1a1_infl outdq_olk_stambp_infl outdq_olk_tgf_alpha_infl outdq_olk_tnf_infl outdq_olk_tnfb_infl outdq_olk_tnfrsf9_infl outdq_olk_tnfsf14_infl outdq_olk_trail_infl outdq_olk_trance_infl outdq_olk_tslp_infl outdq_olk_tweak_infl outdq_olk_upa_infl outdq_olk_vegfa_infl"
restore


// proteins below LOD for each sample

egen nbelowlod = rowtotal($Outdpflag)
gen pbelowlod = (nbelowlod/184)
tabstat nbelowlod pbelowlod, statistics(n mean sd median p25 p75) columns(statistics)

egen nbelowlod_infl = rowtotal($Outdpflag_infl)
gen pbelowlod_infl = (nbelowlod_infl/92)
tabstat nbelowlod_infl pbelowlod_infl, statistics(n mean sd median p25 p75) columns(statistics)

egen nbelowlod_ires = rowtotal($Outdpflag_ires)
gen pbelowlod_ires = (nbelowlod_ires/92)
tabstat nbelowlod_ires pbelowlod_ires, statistics(n mean sd median p25 p75) columns(statistics)


// distribution for samples by % protein below LOD
hist nbelowlod , freq ///
	start(0) addlabels width(5) ///
	xlabel(0(10)80, format(%9.0f)) ///
 	xtitle(Proteins below LOD (n)) ytitle(Samples (n)) ///
	note(Distribution of samples by n protein below LOD (n=1333))

preserve
replace pbelowlod = pbelowlod*100
cd "$PROECoutput"
local file = "olink_lod_samples"	
	cap graph drop "`file'"
hist pbelowlod , freq ///
	start(0) width(5) addlabels ///
	xlabel(0(5)50, format(%9.0f)) ///
	xtitle(% protein below LOD) ytitle(Samples (n)) ///
	note(distribtion of samples by % protein below LOD (n=1333)) name("`file'")
graph export "`file'.jpg", as(jpg) name("`file'") /// 
	width(1600) height(1200) quality(100) replace
restore

* stratify by panel
preserve
replace pbelowlod_ires = pbelowlod_ires*100	
hist pbelowlod_ires, freq ///
	start(0) addlabels width(5) ///
	xlabel(0(5)50, format(%9.0f)) ///
 	xtitle(% protein below LOD) ytitle(Samples (n)) ///
	note(IR panel- distribtion of samples by % protein below LOD (n=1333)) 
restore

preserve
replace pbelowlod_infl = pbelowlod_infl*100	
hist pbelowlod_infl , freq ///
	start(0) addlabels width(5) ///
	xlabel(0(5)50, format(%9.0f)) ///
 	xtitle(% protein below LOD) ytitle(Samples (n)) ///
	note(Infl panel- distribtion of samples by % protein below LOD (n=1333))
restore


********************************************************************************	
********************************************************************************

// create % below LOD by protein dataset

cd "$PROECderived"
tempname temp1
tempfile temp2
postfile `temp1' str35	protein  ///
				double total nnormal nbelow pbelow	///
				using `temp2', replace
					 
foreach var of varlist $Outdpflag {
	count if `var'==0
	local nnormal = r(N)
	count if `var'==1
	local nbelow = r(N)
	assert `nnormal' + `nbelow' == _N
	local pbelow = `nbelow' / _N
	local total = _N
	local protein = substr("`var'",7,.)
	
	post `temp1' ("`protein'") (`total') (`nnormal') (`nbelow') (`pbelow')
}

	postclose `temp1'

	
use `temp2', clear
cd "$PROECderived"
save olink_lod_proteins, replace

********************************************************************************
********************************************************************************

cd "$PROECderived"
use olink_lod_proteins, clear

// samples below LOD for each protein

sum nbelow
tabstat nbelow, statistics(n mean sd median p25 p75)

sum pbelow
tabstat pbelow, statistics(n mean sd median p25 p75)

preserve
replace pbelow = pbelow*100
cd "$PROECoutput"
local file = "olink_lod_proteins"	
	cap graph drop "`file'"
hist pbelow , freq ///
	width(5) addlabels ///
	xlabel(0(10)100, format(%9.0f)) ///
	xtitle(% sample below LOD) ytitle(proteins (n)) ///
	note(distribution of proteins by % sample below LOD (n=184)) name("`file'")	
graph export "`file'.jpg", as(jpg) name("`file'") /// 
	width(1600) height(1200) quality(100) replace
restore
	
preserve
replace pbelow = pbelow*100
	hist pbelow , freq ///
	width(10) addlabels ///
	xlabel(0(10)100, format(%9.0f)) ///
	xtitle(% sample below LOD) ytitle(proteins (n)) ///
	note(distribution of proteins by % sample below LOD (n=184))
restore
	
	
* stratified by panel	
gen str s_panel = substr(protein,-2,.) 
	encode s_panel, gen(panel) 
	drop s_panel
	label drop panel
	label define panel 1 "INFL" 2 "IR" 
	label value panel panel
	order panel protein

tabstat nbelow, by(panel) statistics(n mean sd median p25 p75)
tabstat pbelow, by(panel) statistics(n mean sd median p25 p75)

preserve
replace pbelow = pbelow*100	
	hist pbelow if panel==1, freq ///
	width(10) addlabels ///
	xlabel(0(10)100, format(%9.0f)) ///
	xtitle(% sample below LOD) ytitle(proteins (n)) ///
	note(distribution of proteins by % sample below LOD (n=184))
restore
	
preserve
replace pbelow = pbelow*100	
	hist pbelow if panel==2, freq ///
	width(10) addlabels ///
	xlabel(0(10)100, format(%9.0f)) ///
	xtitle(% sample below LOD) ytitle(proteins (n)) ///
	note(distribution of proteins by % sample below LOD (n=184))	
restore

********************************************************************************

log close
