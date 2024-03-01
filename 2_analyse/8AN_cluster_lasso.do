********************************************************************************
*	Do-file:		8AN_cluster_lasso.do
*	Project:		PROEC: Proteomics for endometrial cancer case-control
*
*	Data used:		coredata_clusterpca.csv
*					PROEC_coredata_olk75.dta
* 					
*	Data created:	or_`model'.dta
*					or_`model'.jpg
*
* 	Purpose:  		run lasso regression for protein clusters
*					use bootstrap sampling with replacement, rep=1000
*
*	Date:			02-OCT-2023
*	Author: 		Sabrina Wang
********************************************************************************

// run the 0_settings.do for this project
capture log close 
cd "$PROEClog"
log using "8AN_cluster_lasso$current_date", replace
set linesize 255

di "Stata Version: `c(stata_version)'"
di "Current Date: `c(current_date)'"

*cap ssc install schemepack, replace
set scheme tab2
graph set window fontface "Helvetica"

********************************************************************************

// import data
clear
cd "$PROECderived"
import delimited "coredata_clusterpca.csv"
keep idepic match_caseset cluster*

merge 1:1 idepic match_caseset using PROEC_coredata_olk75
drop _merge

********************************************************************************

// matching vars
* paramed does not fit clogit so matching factors are included as covariates instead
* estimates are mostly +/-0.02 compared with conditional logistic regression

sum age_blood
gen agecat =.
recode agecat .=1 if age_blood<=50
recode agecat .=2 if age_blood>50 & age_blood<=60
recode agecat .=3 if age_blood>60 & age_blood<.
tab agecat

tab fasting_c,m

tab country,m

recode menopause 3=2
tab menopause,m

generate bldcolhr = hh(t_bld_coll)
tab bldcolhr
gen bldbin =.
recode bldbin .=0 if bldcolhr<12
recode bldbin .=1 if bldcolhr>=12 & bldcolhr<.
tab bldbin,m


// covariates
* generate dummy variables
tabulate menopause, generate(m)
tabulate fasting_c, generate(f)
tabulate country, generate(c)
tabulate pa_index, generate(p)
tabulate smoke_stat, generate(s)
tabulate bmicat, generate(b)

// save dataset
save coredata_clusterpca, replace

********************************************************************************

// macros
global matchvar = "age_blood m2 m3 f2 f3 c2 c3 c4 c5 c6 bldbin"
global covar = "p2 p3 p4 age_menarche ftp ever_pill ever_horm s2 s3 b2 b3"
global clusters = "cluster1 cluster2 cluster3 cluster4 cluster5 cluster6 cluster7 cluster8 cluster9 cluster10 cluster11 cluster12 cluster13 cluster14 cluster15 cluster16 cluster17 cluster18 cluster19 cluster20 cluster21 cluster22 cluster23 cluster24 cluster25 cluster26 cluster27 cluster28 cluster29 cluster30 cluster31 cluster32 cluster33 cluster34 cluster35 cluster36 cluster37 cluster38 cluster39 cluster40 cluster41 cluster42 cluster43 cluster44"

********************************************************************************

// lasso to select clusters

cd "$PROECderived"
use coredata_clusterpca, clear

lasso logit eccase ($covar $matchvar) $clusters, selection(cv, folds(5)) rseed(99)
global selvars = e(othervars_sel)
di "$selvars"

//multiply cluster17 by -1 (because it is negatively correlated with its vars)
gen cluster17_neg = cluster17*-1

*=======================*
*	clogit_or program	*
*=======================*
cap program drop clogit_or
program clogit_or
syntax, file(string) 

	cd "$PROECderived"
	use $dataset, clear // dataset

	cd "$PROECderived"
	tempname temp1
	postfile `temp1' str35	model str35 protein  ///
					 double n or lci uci pval	///
					 using `file', replace

	* clogit				 
	foreach protein of varlist $clusters {
		clogit eccase `protein' $covar, group(match_caseset) or
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
	
		
	keep model protein n estimate pval qvalue npvalue 
	order model protein n estimate pval qvalue npvalue 
	export excel using "tab_PROEC_clogit_clusters.xlsx", firstrow(variables) sheet("`file'", replace) keepcellfmt

end 

// adjusted for full list of potential confounders
local file	= "or_adj_full"
clogit_or, file("`file'")
	
********************************************************************************

// run bootstrap lasso
cd "$PROECderived"
use coredata_clusterpca, clear

//putexcel
cd "$PROECoutput"
putexcel set tab_PROEC_cluster_bolasso, modify
// bootstrap sampling + lasso
* set bootstrap sampling no. to run	
forvalues i = 1/1000 {
	preserve
	set seed `i'
	bsample 624, cluster(match_caseset) 
	lasso logit eccase ($covar $matchvar) $clusters, selection(cv, folds(5)) rseed(99)
	*lassocoef, display(coef, postselection eform)
	global selvars = e(othervars_sel)
	di "rep `i'"
	di "$selvars"
	local j = `i'+1
	putexcel A`j' = `i'
	putexcel B`j' = "$selvars"
	restore
}	
putexcel save

********************************************************************************
log close
