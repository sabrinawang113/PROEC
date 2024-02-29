********************************************************************************
*	Do-file:		1CR_basevars.do
*	Project:		PROEC: Proteomics for endometrial cancer case-control
*
*	Data used:		coru_caco_biom.dta
*
*	Data created:	PROEC_basevars.dta
*
* 	Purpose:  		Review and create demographic, clinical, anthropometric vars 
*					for analysis
*
*	Date:			27-MAR-2023
*	Author: 		Sabrina Wang
********************************************************************************

// run the 0_settings.do for this project
capture log close 
cd "$PROEClog"
log using "1CR_basevars$current_date", replace
set linesize 255

di "Stata Version: `c(stata_version)'"
di "Current Date: `c(current_date)'"

********************************************************************************

// import data
*this is the data used for the metabolomic analysis
*we will use the baseline characteristic vars from this dataset
clear
use "\\inti\nme\Temp\Sabrina\Olink data\coru_caco_biom_olink.dta"
*use "Z:\Temp\Sabrina\Olink data\coru_caco_biom.dta" 

cd "$PROECinitial"
save coru_caco_biom_olink, replace

********************************************************************************

// review and check data
*create vars needed for analysis

desc 
rename *, lower

*------------------------------------------------------------------------------*
*case control status 
tab cncr_caco_coru,m
label define cncr_caco_coru 0 "control" 1 "case"
label value cncr_caco_coru cncr_caco_coru

codebook idepic 
duplicates tag idepic, gen(dup)
tab dup

*------------------------------------------------------------------------------*
*age at blood collection (years)
tabstat age_blood, statistics(n mean sd median p25 p75) by(cncr_caco_coru)

*date at blood collection
sum d_bld_coll 
list d_bld_coll if d_bld_coll==r(min)
list d_bld_coll if d_bld_coll==r(max) 

*------------------------------------------------------------------------------*
*date at diagnosis
sum d_dgcoru 
list d_dgcoru if d_dgcoru==r(min)
list d_dgcoru if d_dgcoru==r(max) 

assert d_dgcoru!=. if cncr_caco_coru==1
assert d_bld_coll < d_dgcoru
count if d_dgcoru!=. & cncr_caco_coru==0 //n=3 controls diagnosed with EC, one of them had match date after date of diagnosis?
list idepic cncr_caco_coru match_caseset match_ctrlnum match_round match_nb_elig match_date match_status d_dgcoru if cncr_caco_coru==0 & d_dgcoru!=.

*date of birth
sum d_birth
list d_birth if d_dgcoru==r(min)
list d_birth if d_dgcoru==r(max) 
assert d_birth < d_bld_coll < d_dgcoru

*cr var age at diagnosis (years)
gen age_diagnosis = (d_dgcoru - d_birth) / 365.5
tabstat age_diagnosis, statistics(n mean sd median p25 p75) by(cncr_caco_coru)
assert age_blood < age_diagnosis
label var age_diagnosis "age at diagnosis (years)"

*cr var time between blood collection and diagnosis (years)
gen time_bld_diag = (d_dgcoru - d_bld_coll) / 365.5
tabstat time_bld_diag, statistics(n mean sd median p25 p75) by(cncr_caco_coru)
label var time_bld_diag "time between blood collection and diagnosis (years)"

*------------------------------------------------------------------------------*
*fasting status
tab fasting_c cncr_caco_coru,m
label define fasting_c 0 "0-3h" 1 "3-6h" 2 ">6h"
label value fasting_c fasting_c

*------------------------------------------------------------------------------*
*age at menarche (years)
tabstat a_1_per_aggr, statistics(n mean sd median p25 p75) by(cncr_caco_coru)
rename a_1_per_aggr age_menarche

*age at first full term pregnancy (years) - among parous women
tabstat a_1_ftp if ftp==1, statistics(n mean sd median p25 p75) by(cncr_caco_coru)
rename a_1_ftp age_ftp

*number of full term pregnancies - among parous women
tabstat n_ftp if ftp==1, statistics(n mean sd median p25 p75) by(cncr_caco_coru)

*ever use of oral contraceptives 
tab ever_pill cncr_caco_coru,m
label define noyes 0 "no" 1 "yes"
label value ever_pill noyes

*menopausal status at blood collection
tab menop_bld menopause,m 
tab menop_bld cncr_caco_coru,m
label define menop_bld 0 "premenopausal" 1 "postmenopausal" 2 "peri or unknown" 3 "surgical post"
label value menop_bld menop_bld

*age at menopause (years) - among postmenopausal women
tabstat a_menopause, statistics(n mean sd median p25 p75) by(cncr_caco_coru)
tabstat a_menopause if menopause==1, statistics(n mean sd median p25 p75) by(cncr_caco_coru)
list menopause a_menopause menop_bld if menopause!=1 & a_menopause!=. //n=3 surgical postmenopausal
assert a_menopause==. if menopause==0 | menopause==2

*ever use menopausal hormone therapy - among postmenopausal women
tab ever_horm cncr_caco_coru if menopause==1 | menopause==3,m

*use of OC/MHT at blood collection
tab phrt_bld cncr_caco_coru,m //all coded as 0 - excluded from study

*------------------------------------------------------------------------------*
*smoking status
tab smoke_stat cncr_caco_coru,m
recode smoke_stat 4=.a
label define smoke_stat 1 "never" 2 "former" 3 "smoker" .a "unknown"
label value smoke_stat smoke_stat

*Cambridge physical activity index 
tab pa_index cncr_caco_coru,m
recode pa_index 5=.a
label define pa_index 1 "inactive" 2 "moderately inactive" 3 "moderately active" 4 "active" .a "missing"
label value pa_index pa_index

*cr var alcohol at recruitment (g/day) categ
sum alc_re
gen alc_re_categ =.
replace alc_re_categ = 1 if alc_re==0
replace alc_re_categ = 2 if alc_re>0 & alc_re<=3
replace alc_re_categ = 3 if alc_re>3 & alc_re<=12
replace alc_re_categ = 4 if alc_re>12 & alc_re<. //the metabolomic paper has >12-24g/day as the last category, but the numbers reported corresponds more closely to >12g/day
label define alc_re_categ 1 "Non-drinker" 2 ">0-3g/d" 3 ">3-12g/d" 4 ">12g/d"
label value alc_re_categ alc_re_categ
label var alc_re_categ "Alcohol at recruitment (for analysis)"
tab alc_re_categ cncr_caco_coru,m

*cr var educational level categ
tab l_school cncr_caco_coru,m
gen edu_categ = l_school
recode edu_categ 0=1 /// //primary/no schooling
				 3=2 /// //technical/professional/secondary
				 4=3 /// //longer education
				 5=.a //not specified
tab l_school edu_categ,m
label define edu_categ 1 "primary/no schooling" 2 "technical/professional/secondary" 3 "longer education" .a "not specified"
label value edu_categ edu_categ 
label var edu_categ "Educational level (for analysis)"
tab edu_categ cncr_caco_coru,m

*------------------------------------------------------------------------------*
*height (cm)
list height_adj height_c if height_adj!=height_c //looks like metabolomic paper used height_c
tabstat height_c, statistics(n mean sd median p25 p75) by(cncr_caco_coru)

*weight (kg)
list weight_adj weight_c if weight_adj!= weight_c 
tabstat weight_c, statistics(n mean sd median p25 p75) by(cncr_caco_coru)

*Body Mass Index (kg/m2)
list bmi_adj bmi_c if bmi_adj!= bmi_c
tabstat bmi_c, statistics(n mean sd median p25 p75) by(cncr_caco_coru)

* cr var BMI WHO categ
gen bmi_categ =.
replace bmi_categ = 1 if bmi_c<18.5
replace bmi_categ = 2 if bmi_c>=18.5 & bmi_c<25
replace bmi_categ = 3 if bmi_c>=25 & bmi_c<30
replace bmi_categ = 4 if bmi_c>=30 & bmi_c<.
label define bmi_categ 1 "<18.5" 2 "18.5-<25" 3 "25-<30" 4 ">=30"
label value bmi_categ bmi_categ
label var bmi_categ "BMI kg/m2 WHO categ (for analysis)"
tab bmi_categ cncr_caco_coru,m

*waist circumference (cm)
list waist_adj waist_c if waist_adj!= waist_c 
tabstat waist_c, statistics(n mean sd median p25 p75) by(cncr_caco_coru)

*hip circumference (cm)
list hip_adj hip_c if hip_adj!= hip_c 
tabstat hip_c, statistics(n mean sd median p25 p75) by(cncr_caco_coru)

*waist/hip ratio
list whr_adj whr_c if whr_adj!= whr_c 
tabstat whr_c, statistics(n mean sd median p25 p75) by(cncr_caco_coru)


*diabetes
tab diabet cncr_caco_coru,m
label value diabet noyes


********************************************************************************

*EC case-control
tab cncr_caco_coru,m
rename cncr_caco_coru eccase

********************************************************************************
cd "$PROECderived"
save PROEC_basevars, replace
log close
