********************************************************************************
*	Do-file:		2_2AN_proteins_corr.do
*	Project:		PROEC: Proteomics for endometrial cancer case-control
*
*	Data used:		PROEC_qcflag.dta
*
*	Data created:	ppt_olink_descriptive.pptx
*
* 	Purpose:  		Descriptive analysis for olink assays
*					Examine correlation between all proteins
*					Examine correlation between proteins measured on both panels
*
*	Date:			02-MAY-2023
*	Author: 		Sabrina Wang
********************************************************************************

// run the 0_settings.do for this project
capture log close 
cd "$PROEClog"
log using "2_2AN_proteins_corr$current_date", replace
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

cd "$PROECderived"
use PROEC_coredata, clear

********************************************************************************

// proteins on both panels
* refer to excel "Olink panels protein lists"
* n=4 proteins are assessed on both panels

corr olk_il5_infl olk_il5_ir
corr olk_il6_infl olk_il6_ir
corr olk_il10_infl olk_il10_ir
corr olk_ccl11_infl olk_ccl11_ir

tabstat olk_il5_infl olk_il5_ir olk_il6_infl olk_il6_ir olk_il10_infl olk_il10_ir olk_ccl11_infl olk_ccl11_ir ///
		, statistics(n mean sd median p25 p75 min max) columns(statistics)

scatter olk_il5_infl olk_il5_ir
scatter olk_il6_infl olk_il6_ir
scatter olk_il10_infl olk_il10_ir
scatter olk_ccl11_infl olk_ccl11_ir


* compare below LOD
tab outdq_olk_il5_ir outdq_olk_il5_infl
tab outdq_olk_il6_ir outdq_olk_il6_infl
tab outdq_olk_il10_ir outdq_olk_il10_infl
tab outdq_olk_ccl11_ir outdq_olk_ccl11_infl


********************************************************************************

// correlation between all proteins
// all olk proteins	
*global olk = "olk_il8_infl olk_vegfa_infl olk_cd8a_infl olk_mcp_3_infl olk_gdnf_infl olk_cdcp1_infl olk_cd244_infl olk_il7_infl olk_opg_infl olk_laptgf_beta_1_infl olk_upa_infl olk_il6_infl olk_il_17c_infl olk_mcp_1_infl olk_il_17a_infl olk_cxcl11_infl olk_axin1_infl olk_trail_infl olk_il_20ra_infl olk_cxcl9_infl olk_cst5_infl olk_il_2rb_infl olk_il_1alpha_infl olk_osm_infl olk_il2_infl olk_cxcl1_infl olk_tslp_infl olk_ccl4_infl olk_cd6_infl olk_scf_infl olk_il18_infl olk_slamf1_infl olk_tgf_alpha_infl olk_mcp_4_infl olk_ccl11_infl olk_tnfsf14_infl olk_fgf_23_infl olk_il_10ra_infl olk_fgf_5_infl olk_mmp_1_infl olk_lif_r_infl olk_fgf_21_infl olk_ccl19_infl olk_il_15ra_infl olk_il_10rb_infl olk_il_22ra1_infl olk_il_18r1_infl olk_pd_l1_infl olk_beta_ngf_infl olk_cxcl5_infl olk_trance_infl olk_hgf_infl olk_il_12b_infl olk_il_24_infl olk_il13_infl olk_artn_infl olk_mmp_10_infl olk_il10_infl olk_tnf_infl olk_ccl23_infl olk_cd5_infl olk_ccl3_infl olk_flt3l_infl olk_cxcl6_infl olk_cxcl10_infl olk_4e_bp1_infl olk_il_20_infl olk_sirt2_infl olk_ccl28_infl olk_dner_infl olk_en_rage_infl olk_cd40_infl olk_il33_infl olk_ifn_gamma_infl olk_fgf_19_infl olk_il4_infl olk_lif_infl olk_nrtn_infl olk_mcp_2_infl olk_casp_8_infl olk_ccl25_infl olk_cx3cl1_infl olk_tnfrsf9_infl olk_nt_3_infl olk_tweak_infl olk_ccl20_infl olk_st1a1_infl olk_stambp_infl olk_il5_infl olk_ada_infl olk_tnfb_infl olk_csf_1_infl olk_ppp1r9b_ir olk_glb1_ir olk_psip1_ir olk_zbtb16_ir olk_irak4_ir olk_tpsab1_ir olk_hcls1_ir olk_cntnap2_ir olk_clec4g_ir olk_irf9_ir olk_edar_ir olk_il6_ir olk_dgkz_ir olk_clec4c_ir olk_irak1_ir olk_clec4a_ir olk_prdx1_ir olk_prdx3_ir olk_fgf2_ir olk_prdx5_ir olk_dpp10_ir olk_trim5_ir olk_dctn1_ir olk_itga6_ir olk_cdsn_ir olk_galnt3_ir olk_fxyd5_ir olk_traf2_ir olk_trim21_ir olk_lilrb4_ir olk_ntf4_ir olk_krt19_ir olk_itm2a_ir olk_hnmt_ir olk_ccl11_ir olk_milr1_ir olk_egln1_ir olk_nfatc3_ir olk_ly75_ir olk_eif5a_ir olk_eif4g1_ir olk_cd28_ir olk_pth1r_ir olk_birc2_ir olk_hsd11b1_ir olk_nf2_ir olk_plxna4_ir olk_sh2b3_ir olk_fcrl3_ir olk_ckap4_ir olk_jun_ir olk_hexim1_ir olk_clec4d_ir olk_prkcq_ir olk_mgmt_ir olk_trem1_ir olk_cxadr_ir olk_il10_ir olk_srpk2_ir olk_klrd1_ir olk_bach1_ir olk_pik3ap1_ir olk_spry2_ir olk_stc1_ir olk_arnt_ir olk_fam3b_ir olk_sh2d1a_ir olk_ica1_ir olk_dffa_ir olk_dcbld2_ir olk_fcrl6_ir olk_ncr1_ir olk_cxcl12_ir olk_areg_ir olk_ifnlr1_ir olk_dapp1_ir olk_padi2_ir olk_sit1_ir olk_masp1_ir olk_lamp3_ir olk_clec7a_ir olk_clec6a_ir olk_ddx58_ir olk_il12rb1_ir olk_tank_ir olk_itga11_ir olk_kpna1_ir olk_lag3_ir olk_il5_ir olk_cd83_ir olk_itgb6_ir olk_btn3a2_ir"

*global infl = "olk_il8_infl olk_vegfa_infl olk_cd8a_infl olk_mcp_3_infl olk_gdnf_infl olk_cdcp1_infl olk_cd244_infl olk_il7_infl olk_opg_infl olk_laptgf_beta_1_infl olk_upa_infl olk_il6_infl olk_il_17c_infl olk_mcp_1_infl olk_il_17a_infl olk_cxcl11_infl olk_axin1_infl olk_trail_infl olk_il_20ra_infl olk_cxcl9_infl olk_cst5_infl olk_il_2rb_infl olk_il_1alpha_infl olk_osm_infl olk_il2_infl olk_cxcl1_infl olk_tslp_infl olk_ccl4_infl olk_cd6_infl olk_scf_infl olk_il18_infl olk_slamf1_infl olk_tgf_alpha_infl olk_mcp_4_infl olk_ccl11_infl olk_tnfsf14_infl olk_fgf_23_infl olk_il_10ra_infl olk_fgf_5_infl olk_mmp_1_infl olk_lif_r_infl olk_fgf_21_infl olk_ccl19_infl olk_il_15ra_infl olk_il_10rb_infl olk_il_22ra1_infl olk_il_18r1_infl olk_pd_l1_infl olk_beta_ngf_infl olk_cxcl5_infl olk_trance_infl olk_hgf_infl olk_il_12b_infl olk_il_24_infl olk_il13_infl olk_artn_infl olk_mmp_10_infl olk_il10_infl olk_tnf_infl olk_ccl23_infl olk_cd5_infl olk_ccl3_infl olk_flt3l_infl olk_cxcl6_infl olk_cxcl10_infl olk_4e_bp1_infl olk_il_20_infl olk_sirt2_infl olk_ccl28_infl olk_dner_infl olk_en_rage_infl olk_cd40_infl olk_il33_infl olk_ifn_gamma_infl olk_fgf_19_infl olk_il4_infl olk_lif_infl olk_nrtn_infl olk_mcp_2_infl olk_casp_8_infl olk_ccl25_infl olk_cx3cl1_infl olk_tnfrsf9_infl olk_nt_3_infl olk_tweak_infl olk_ccl20_infl olk_st1a1_infl olk_stambp_infl olk_il5_infl olk_ada_infl olk_tnfb_infl olk_csf_1_infl"

*global ires = "olk_ppp1r9b_ir olk_glb1_ir olk_psip1_ir olk_zbtb16_ir olk_irak4_ir olk_tpsab1_ir olk_hcls1_ir olk_cntnap2_ir olk_clec4g_ir olk_irf9_ir olk_edar_ir olk_il6_ir olk_dgkz_ir olk_clec4c_ir olk_irak1_ir olk_clec4a_ir olk_prdx1_ir olk_prdx3_ir olk_fgf2_ir olk_prdx5_ir olk_dpp10_ir olk_trim5_ir olk_dctn1_ir olk_itga6_ir olk_cdsn_ir olk_galnt3_ir olk_fxyd5_ir olk_traf2_ir olk_trim21_ir olk_lilrb4_ir olk_ntf4_ir olk_krt19_ir olk_itm2a_ir olk_hnmt_ir olk_ccl11_ir olk_milr1_ir olk_egln1_ir olk_nfatc3_ir olk_ly75_ir olk_eif5a_ir olk_eif4g1_ir olk_cd28_ir olk_pth1r_ir olk_birc2_ir olk_hsd11b1_ir olk_nf2_ir olk_plxna4_ir olk_sh2b3_ir olk_fcrl3_ir olk_ckap4_ir olk_jun_ir olk_hexim1_ir olk_clec4d_ir olk_prkcq_ir olk_mgmt_ir olk_trem1_ir olk_cxadr_ir olk_il10_ir olk_srpk2_ir olk_klrd1_ir olk_bach1_ir olk_pik3ap1_ir olk_spry2_ir olk_stc1_ir olk_arnt_ir olk_fam3b_ir olk_sh2d1a_ir olk_ica1_ir olk_dffa_ir olk_dcbld2_ir olk_fcrl6_ir olk_ncr1_ir olk_cxcl12_ir olk_areg_ir olk_ifnlr1_ir olk_dapp1_ir olk_padi2_ir olk_sit1_ir olk_masp1_ir olk_lamp3_ir olk_clec7a_ir olk_clec6a_ir olk_ddx58_ir olk_il12rb1_ir olk_tank_ir olk_itga11_ir olk_kpna1_ir olk_lag3_ir olk_il5_ir olk_cd83_ir olk_itgb6_ir olk_btn3a2_ir"

// olk proteins >75% above lod
global olk = "bmi_c waist_c olk_il8_infl olk_vegfa_infl olk_cd8a_infl olk_mcp_3_infl olk_gdnf_infl olk_cdcp1_infl olk_cd244_infl olk_il7_infl olk_opg_infl olk_laptgf_beta_1_infl olk_upa_infl olk_il6_infl olk_il_17c_infl olk_mcp_1_infl olk_il_17a_infl olk_cxcl11_infl olk_axin1_infl olk_trail_infl olk_cxcl9_infl olk_cst5_infl olk_il_2rb_infl olk_osm_infl olk_cxcl1_infl olk_ccl4_infl olk_cd6_infl olk_scf_infl olk_il18_infl olk_slamf1_infl olk_tgf_alpha_infl olk_mcp_4_infl olk_ccl11_infl olk_tnfsf14_infl olk_fgf_23_infl olk_il_10ra_infl olk_fgf_5_infl olk_mmp_1_infl olk_lif_r_infl olk_fgf_21_infl olk_ccl19_infl olk_il_10rb_infl olk_il_18r1_infl olk_pd_l1_infl olk_cxcl5_infl olk_trance_infl olk_hgf_infl olk_il_12b_infl olk_mmp_10_infl olk_il10_infl olk_tnf_infl olk_ccl23_infl olk_cd5_infl olk_ccl3_infl olk_flt3l_infl olk_cxcl6_infl olk_cxcl10_infl olk_4e_bp1_infl olk_sirt2_infl olk_ccl28_infl olk_dner_infl olk_en_rage_infl olk_cd40_infl olk_ifn_gamma_infl olk_fgf_19_infl olk_mcp_2_infl olk_casp_8_infl olk_ccl25_infl olk_cx3cl1_infl olk_tnfrsf9_infl olk_nt_3_infl olk_tweak_infl olk_ccl20_infl olk_st1a1_infl olk_stambp_infl olk_ada_infl olk_tnfb_infl olk_csf_1_infl olk_ppp1r9b_ir olk_glb1_ir olk_psip1_ir olk_zbtb16_ir olk_tpsab1_ir olk_hcls1_ir olk_cntnap2_ir olk_clec4g_ir olk_irf9_ir olk_edar_ir olk_il6_ir olk_clec4c_ir olk_irak1_ir olk_clec4a_ir olk_prdx1_ir olk_prdx3_ir olk_fgf2_ir olk_prdx5_ir olk_dpp10_ir olk_trim5_ir olk_dctn1_ir olk_itga6_ir olk_cdsn_ir olk_traf2_ir olk_trim21_ir olk_lilrb4_ir olk_ntf4_ir olk_krt19_ir olk_itm2a_ir olk_hnmt_ir olk_ccl11_ir olk_milr1_ir olk_egln1_ir olk_nfatc3_ir olk_ly75_ir olk_eif4g1_ir olk_cd28_ir olk_pth1r_ir olk_hsd11b1_ir olk_plxna4_ir olk_sh2b3_ir olk_fcrl3_ir olk_ckap4_ir olk_jun_ir olk_hexim1_ir olk_clec4d_ir olk_prkcq_ir olk_mgmt_ir olk_cxadr_ir olk_il10_ir olk_srpk2_ir olk_klrd1_ir olk_bach1_ir olk_pik3ap1_ir olk_spry2_ir olk_stc1_ir olk_fam3b_ir olk_sh2d1a_ir olk_dffa_ir olk_dcbld2_ir olk_fcrl6_ir olk_ncr1_ir olk_areg_ir olk_ifnlr1_ir olk_dapp1_ir olk_sit1_ir olk_masp1_ir olk_lamp3_ir olk_clec7a_ir olk_clec6a_ir olk_ddx58_ir olk_il12rb1_ir olk_itga11_ir olk_kpna1_ir olk_lag3_ir olk_il5_ir olk_cd83_ir olk_itgb6_ir olk_btn3a2_ir"

global infl = "bmi_c waist_c olk_il8_infl olk_vegfa_infl olk_cd8a_infl olk_mcp_3_infl olk_gdnf_infl olk_cdcp1_infl olk_cd244_infl olk_il7_infl olk_opg_infl olk_laptgf_beta_1_infl olk_upa_infl olk_il6_infl olk_il_17c_infl olk_mcp_1_infl olk_il_17a_infl olk_cxcl11_infl olk_axin1_infl olk_trail_infl olk_cxcl9_infl olk_cst5_infl olk_il_2rb_infl olk_osm_infl olk_cxcl1_infl olk_ccl4_infl olk_cd6_infl olk_scf_infl olk_il18_infl olk_slamf1_infl olk_tgf_alpha_infl olk_mcp_4_infl olk_ccl11_infl olk_tnfsf14_infl olk_fgf_23_infl olk_il_10ra_infl olk_fgf_5_infl olk_mmp_1_infl olk_lif_r_infl olk_fgf_21_infl olk_ccl19_infl olk_il_10rb_infl olk_il_18r1_infl olk_pd_l1_infl olk_cxcl5_infl olk_trance_infl olk_hgf_infl olk_il_12b_infl olk_mmp_10_infl olk_il10_infl olk_tnf_infl olk_ccl23_infl olk_cd5_infl olk_ccl3_infl olk_flt3l_infl olk_cxcl6_infl olk_cxcl10_infl olk_4e_bp1_infl olk_sirt2_infl olk_ccl28_infl olk_dner_infl olk_en_rage_infl olk_cd40_infl olk_ifn_gamma_infl olk_fgf_19_infl olk_mcp_2_infl olk_casp_8_infl olk_ccl25_infl olk_cx3cl1_infl olk_tnfrsf9_infl olk_nt_3_infl olk_tweak_infl olk_ccl20_infl olk_st1a1_infl olk_stambp_infl olk_ada_infl olk_tnfb_infl olk_csf_1_infl"

global ires = "bmi_c waist_c olk_ppp1r9b_ir olk_glb1_ir olk_psip1_ir olk_zbtb16_ir olk_tpsab1_ir olk_hcls1_ir olk_cntnap2_ir olk_clec4g_ir olk_irf9_ir olk_edar_ir olk_il6_ir olk_clec4c_ir olk_irak1_ir olk_clec4a_ir olk_prdx1_ir olk_prdx3_ir olk_fgf2_ir olk_prdx5_ir olk_dpp10_ir olk_trim5_ir olk_dctn1_ir olk_itga6_ir olk_cdsn_ir olk_traf2_ir olk_trim21_ir olk_lilrb4_ir olk_ntf4_ir olk_krt19_ir olk_itm2a_ir olk_hnmt_ir olk_ccl11_ir olk_milr1_ir olk_egln1_ir olk_nfatc3_ir olk_ly75_ir olk_eif4g1_ir olk_cd28_ir olk_pth1r_ir olk_hsd11b1_ir olk_plxna4_ir olk_sh2b3_ir olk_fcrl3_ir olk_ckap4_ir olk_jun_ir olk_hexim1_ir olk_clec4d_ir olk_prkcq_ir olk_mgmt_ir olk_cxadr_ir olk_il10_ir olk_srpk2_ir olk_klrd1_ir olk_bach1_ir olk_pik3ap1_ir olk_spry2_ir olk_stc1_ir olk_fam3b_ir olk_sh2d1a_ir olk_dffa_ir olk_dcbld2_ir olk_fcrl6_ir olk_ncr1_ir olk_areg_ir olk_ifnlr1_ir olk_dapp1_ir olk_sit1_ir olk_masp1_ir olk_lamp3_ir olk_clec7a_ir olk_clec6a_ir olk_ddx58_ir olk_il12rb1_ir olk_itga11_ir olk_kpna1_ir olk_lag3_ir olk_il5_ir olk_cd83_ir olk_itgb6_ir olk_btn3a2_ir"

********************************************************************************

// create excel workbook and sheet 

cd "$PROECoutput"
putexcel set tab_olink_corr, sheet(pearson) modify


corr $olk
putexcel A1 = matrix(r(C)), names

********************************************************************************

// create dataset for R for heatmap

cd "$PROECderived"
use PROEC_coredata, clear
keep $olk
order bmi_c, before(waist_c)
cd "$PROECderived"
save olk, replace

cd "$PROECderived"
use PROEC_coredata, clear
keep $infl
order bmi_c, before(waist_c)
cd "$PROECderived"
save infl, replace

cd "$PROECderived"
use PROEC_coredata, clear
keep $ires
order bmi_c, before(waist_c)
cd "$PROECderived"
save ires, replace

********************************************************************************
log close
