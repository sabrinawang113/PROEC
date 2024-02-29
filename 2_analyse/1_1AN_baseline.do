********************************************************************************
*	Do-file:		1_1AN_baseline.do
*	Project:		PROEC: Proteomics for endometrial cancer case-control
*
*	Data used:		PROEC_basevars.dta
*					PROEC_coredata.dta
*
*	Data created:	tab_PROEC_baseline.xlsx
*
* 	Purpose:  		Create descriptive table for baseline characterisitics
*					of endometrial cases and matched controls
*
*	Date:			28-MAR-2023
*	Author: 		Sabrina Wang
********************************************************************************

// run the 0_settings.do for this project
capture log close 
cd "$PROEClog"
log using "1_1AN_baseline$current_date", replace
set linesize 255 

di "Stata Version: `c(stata_version)'"
di "Current Date: `c(current_date)'"

********************************************************************************

// import data
* PROEC_basevars
* PROEC_coredata

global dataset = "PROEC_coredata"

cd "$PROECderived"
use $dataset, clear
	
********************************************************************************

// create excel workbook and sheet 

cd "$PROECoutput"
putexcel set tab_PROEC_baseline, sheet("$dataset") modify

********************************************************************************

// review and check data

tab eccase,m

*------------------------------------------------------------------------------*
*age at blood collection (years)
tabstat age_blood, statistics(n mean sd median p25 p75) by(eccase)

*age at diagnosis (years)
tabstat age_diagnosis, statistics(n mean sd median p25 p75) by(eccase)

*time between blood collection and diagnosis (years)
tabstat time_bld_diag, statistics(n mean sd median p25 p75) by(eccase)

*fasting status
tab fasting_c eccase, col

*------------------------------------------------------------------------------*
*age at menarche (years)
tabstat age_menarche, statistics(n mean sd median p25 p75) by(eccase)

*age at first full term pregnancy (years) - among parous women
tabstat age_ftp if ftp==1, statistics(n mean sd median p25 p75) by(eccase)

*number of full term pregnancies - among parous women
tabstat n_ftp if ftp==1, statistics(n mean sd median p25 p75) by(eccase)

*ever use of oral contraceptives 
tab ever_pill eccase, col

*menopausal status at blood collection
tab menop_bld eccase, col
gen menop_bld_3 = menop_bld
recode menop_bld_3 3=1 //recode surgical postmenopausal to postmenopausal
tab menop_bld_3 eccase, col

*age at menopause (years) - among postmenopausal women
tabstat a_menopause if menopause==1 | menopause==3, statistics(n mean sd median p25 p75) by(eccase)

*ever use menopausal hormone therapy - among postmenopausal women
tab ever_horm eccase if menopause==1 | menopause==3, col

*use of OC/MHT at blood collection
tab phrt_bld eccase, col //all coded as 0 - exlcuded from study

*------------------------------------------------------------------------------*
*smoking status
tab smoke_stat eccase, col

*Cambridge physical activity index 
tab pa_index eccase, col

*alcohol at recruitment (g/day) categ
tab alc_re_categ eccase, col

*educational level categ
tab edu_categ eccase, col

*------------------------------------------------------------------------------*
*height (cm)
tabstat height_c, statistics(n mean sd median p25 p75) by(eccase)

*weight (kg)
tabstat weight_c, statistics(n mean sd median p25 p75) by(eccase)

*Body Mass Index (kg/m2)
tabstat bmi_c, statistics(n mean sd median p25 p75) by(eccase)

* cr var BMI WHO categ
tab bmi_categ eccase, col

*waist circumference (cm)
tabstat waist_c, statistics(n mean sd median p25 p75) by(eccase)

*hip circumference (cm)
tabstat hip_c, statistics(n mean sd median p25 p75) by(eccase)

*waist/hip ratio
tabstat whr_c, statistics(n mean sd median p25 p75) by(eccase)

*cpeptide
tabstat cpeptide, statistics(n mean sd median p25 p75) by(eccase)

*diabetes
tab diabet eccase, col

********************************************************************************
********************************************************************************

// Putexcel programs

*=======================*
*	Mean(sd) program	*
*=======================*

cap program drop mean_sd
program mean_sd
syntax,var(string) t_row(integer) p(integer)
    matrix b=e(`var')'
    forvalues i=1/9 {
	   local j =`i' + 1
	   local x`i' = string(b[`i',1],"%5.`p'f") 
	   local y`i' = string(b[`j',1],"%5.`p'f") 
	   cap drop z`i'
	   gen z`i'=  "`x`i''" + " (" + "`y`i''" + ")"
    }
	putexcel B`t_row' =  `x7'	//total n
	putexcel C`t_row' =  z5 	//cases mean(sd)
	putexcel D`t_row' =  z2		//controls mean(sd)
end


*===================*
*	N(%) programs	*
*===================*
* for 2,3,4 categories

cap program drop n_pcent_cat2
program n_pcent_cat2
syntax, t_row(integer) t_col(string) categ(integer)
    matrix b=e(b)'
	matrix pct=e(colpct)'
	
	local pos = `t_row'
	local i=2
	    local k =`categ'-1 + `i'
	    local n = b[`k',1]
		local pcent = string(pct[`k',1], "%5.1f")
		cap drop npc
		gen npc = "`n'" + " (" + "`pcent'" + "%)"
		putexcel `t_col'`pos' = npc
		local ++pos
	
	putexcel B`t_row' = b[9,1]
end


cap program drop n_pcent_cat3
program n_pcent_cat3
syntax, t_row(integer) t_col(string) categ(integer)
    matrix b=e(b)'
	matrix pct=e(colpct)'
	
	local pos = `t_row'
	forvalues i=1/3 {
	    local k =`categ'-1 + `i'
	    local n = b[`k',1]
		local pcent = string(pct[`k',1], "%5.1f")
		cap drop npc
		gen npc = "`n'" + " (" + "`pcent'" + "%)"
		putexcel `t_col'`pos' = npc
		local ++pos
	}
	local tot = `t_row'-1
	putexcel B`tot' = b[12,1]
end


cap program drop n_pcent_cat4
program n_pcent_cat4
syntax, t_row(integer) t_col(string) categ(integer)
    matrix b=e(b)'
	matrix pct=e(colpct)'
	
	local pos = `t_row'
	forvalues i=1/4 {
	    local k =`categ'-1 + `i'
	    local n = b[`k',1]
		local pcent = string(pct[`k',1], "%5.1f")
		cap drop npc
		gen npc = "`n'" + " (" + "`pcent'" + "%)"
		putexcel `t_col'`pos' = npc
		local ++pos
	}
	local tot = `t_row'-1
	putexcel B`tot' = b[15,1]
end


********************************************************************************

//	Column headings

putexcel A2 = "Characteristic"
putexcel B2 = "N"

estpost tab eccase
	matrix b=e(b)'
	matrix pct=e(pct)'
	matrix list b
	matrix list pct
	local n2 = string(b[2,1], "%5.0f")
	local n1 = string(b[1,1], "%5.0f")
	gen ncase 	 = "Cases (N=" + "`n2'" + ")"
	gen ncontrol = "Controls (N=" + "`n1'" + ")"
putexcel C2 = ncase
putexcel D2 = ncontrol
	
// Row headings
*see excel template

********************************************************************************

//	Input values

*age at blood collection (years)
estpost tabstat age_blood age_blood, statistics(n mean sd) by(eccase)
mean_sd, var(age_blood) t_row(3) p(1)


*age at diagnosis (years) - cases only
estpost tabstat age_diagnosis age_diagnosis, statistics(n mean sd) by(eccase) //TBC for the n=1 control selected as case after diagnosis
    matrix b=e(age_diagnosis)'
    forvalues i=1/9 {
	   local j =`i' + 1
	   local x`i' = string(b[`i',1],"%5.1f") 
	   local y`i' = string(b[`j',1],"%5.1f") 
	   cap drop z`i'
	   gen z`i'=  "`x`i''" + " (" + "`y`i''" + ")"
    }
	putexcel B4 = `x4'	//cases n
	putexcel C4 =  z5 	//cases mean(sd)
	putexcel D4 = "-"
	
	
*time between blood collection and diagnosis (years) - cases only
estpost tabstat time_bld_diag time_bld_diag, statistics(n mean sd) by(eccase) //TBC for the n=1 control selected as case after diagnosis
    matrix b=e(time_bld_diag)'
    forvalues i=1/9 {
	   local j =`i' + 1
	   local x`i' = string(b[`i',1],"%5.1f") 
	   local y`i' = string(b[`j',1],"%5.1f") 
	   cap drop z`i'
	   gen z`i'=  "`x`i''" + " (" + "`y`i''" + ")"
    }
	putexcel B5 =  `x4'	//cases n
	putexcel C5 =  z5 	//cases mean(sd)
	putexcel D5 = "-"
	
	
*fasting status
estpost tab fasting_c eccase
n_pcent_cat3, t_row(7) t_col(C) categ(5)
n_pcent_cat3, t_row(7) t_col(D) categ(1)

*------------------------------------------------------------------------------*
*age at menarche (years)
estpost tabstat age_menarche age_menarche, statistics(n mean sd) by(eccase)
mean_sd, var(age_menarche) t_row(10) p(1)

*age at first full term pregnancy (years) - among parous women
estpost tabstat age_ftp age_ftp if ftp==1, statistics(n mean sd) by(eccase)
mean_sd, var(age_ftp) t_row(11) p(1)

*number of full term pregnancies - among parous women
estpost tabstat n_ftp n_ftp if ftp==1, statistics(n mean sd) by(eccase)
mean_sd, var(n_ftp) t_row(12) p(1)

*ever use of oral contraceptives 
estpost tab ever_pill eccase
n_pcent_cat2, t_row(13) t_col(C) categ(4)
n_pcent_cat2, t_row(13) t_col(D) categ(1)

*menopausal status at blood collection
estpost tab menop_bld_3 eccase
n_pcent_cat3, t_row(15) t_col(C) categ(5)
n_pcent_cat3, t_row(15) t_col(D) categ(1)

*age at menopause (years) - among postmenopausal women
estpost tabstat a_menopause a_menopause if menopause==1 | menopause==3, statistics(n mean sd) by(eccase)
mean_sd, var(a_menopause) t_row(18) p(1)

*ever use menopausal hormone therapy - among postmenopausal women
estpost tab ever_horm eccase if menopause==1 | menopause==3
n_pcent_cat2, t_row(19) t_col(C) categ(4)
n_pcent_cat2, t_row(19) t_col(D) categ(1)

*use of OC/MHT at blood collection
estpost tab phrt_bld eccase,m //all coded as 0?? TBC
*n_pcent_cat2, t_row(20) t_col(C) categ(4)
*n_pcent_cat2, t_row(20) t_col(D) categ(1)

*------------------------------------------------------------------------------*
*smoking status
estpost tab smoke_stat eccase
n_pcent_cat3, t_row(22) t_col(C) categ(5)
n_pcent_cat3, t_row(22) t_col(D) categ(1)

*Cambridge physical activity index 
estpost tab pa_index eccase
n_pcent_cat4, t_row(26) t_col(C) categ(6)
n_pcent_cat4, t_row(26) t_col(D) categ(1)

*alcohol at recruitment (g/day) categ
estpost tab alc_re_categ eccase
n_pcent_cat4, t_row(31) t_col(C) categ(6)
n_pcent_cat4, t_row(31) t_col(D) categ(1)

*educational level categ
estpost tab edu_categ eccase
n_pcent_cat3, t_row(36) t_col(C) categ(5)
n_pcent_cat3, t_row(36) t_col(D) categ(1)

*------------------------------------------------------------------------------*
*height (cm)
estpost tabstat height_c height_c, statistics(n mean sd) by(eccase)
mean_sd, var(height_c) t_row(39) p(1)

*weight (kg)
estpost tabstat weight_c weight_c, statistics(n mean sd) by(eccase)
mean_sd, var(weight_c) t_row(40) p(1)

*Body Mass Index (kg/m2)
estpost tabstat bmi_c bmi_c, statistics(n mean sd) by(eccase)
mean_sd, var(bmi_c) t_row(41) p(1)

* cr var BMI WHO categ
estpost tab bmi_categ eccase
n_pcent_cat4, t_row(43) t_col(C) categ(6)
n_pcent_cat4, t_row(43) t_col(D) categ(1)

*waist circumference (cm)
estpost tabstat waist_c waist_c, statistics(n mean sd) by(eccase)
mean_sd, var(waist_c) t_row(47) p(1)

*hip circumference (cm)
estpost tabstat hip_c hip_c, statistics(n mean sd) by(eccase)
mean_sd, var(hip_c) t_row(48) p(1)

*waist/hip ratio
estpost tabstat whr_c whr_c, statistics(n mean sd) by(eccase)
mean_sd, var(whr_c) t_row(49) p(1)

*diabetes
estpost tab diabet eccase
n_pcent_cat2, t_row(50) t_col(C) categ(4)
n_pcent_cat2, t_row(50) t_col(D) categ(1)


//additional vars
*waist cir cat
cap drop wccat
gen wccat =0 if waist_c<=80 
replace wccat =1 if waist_c>80 & waist_c<=88 
replace wccat =2 if waist_c>88 & waist_c<. 
tab wccat
estpost tab wccat eccase
n_pcent_cat3, t_row(56) t_col(C) categ(5)
n_pcent_cat3, t_row(56) t_col(D) categ(1)

*cpeptide
estpost tabstat cpeptide cpeptide, statistics(n mean sd) by(eccase)
mean_sd, var(cpeptide) t_row(59) p(1)

********************************************************************************

//	Formatting 

putexcel (A2:D2), border(top)
putexcel (A2:D2), border(bottom)
putexcel (A60:D60), border(bottom)

putexcel A2:D2, bold
putexcel B2:D60, left vcenter

putexcel A1:D60, font("Calibri",10)
putexcel A1 = ""

********************************************************************************

log close

********************************************************************************

// get follow-up time for eligible cohort

sum d_check
list d_check if d_check==`r(min)'
sum d_csr_cncr
list d_csr_cncr if d_csr_cncr==`r(min)'

gen futime = (d_endfup - d_recrui)/365.25
tabstat futime, stats(n p50 p5 p95)
