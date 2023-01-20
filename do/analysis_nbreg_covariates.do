** Created 2022-11-21 by Ruth Jack, University of Nottingham
*************************************
* Name:	analysis_nbreg_covariates.do
* Creator:	RHJ
* Date:	20221121
* Desc:	nbreg regression for tics by age-sex group and period adjusted for deprivation and region
* Requires: Stata 17
*	Date	Reference	Update
*	20221121	analysis_nbreg_covariates	Create file
*	20221122	analysis_nbreg_covariates	Add in nbreg models without adjusting for covariates
*	20221129	analysis_nbreg_covariates	Get lincom estimates with 4dp
*************************************


version 17.0
frames reset

global date: display %dCYND date("`c(current_date)'", "DMY")


**# New frame 
frame create nbreg
frame change nbreg

use "data_prepared/Tics_strate_all_split.dta"

**# Create var for study period
gen yearcat=0
replace yearcat=1 if year==2020
replace yearcat=2 if year==2021

lab def yearcat 0 "2015-2019" 1 "2020" 2 "2021"
lab val yearcat yearcat

**# Create sex-age variable for regression
gen sex_s="m"
replace sex_s="f" if sex==1
egen sex_age1=concat(sex_s monthagegrp), punct(_)
encode sex_age1, gen(sex_age)
drop sex_s sex_age1

**# Incidence rate ratios including interaction term of sex/age and period
nbreg _D ib3.sex_age##yearcat, exposure(_Y) irr

table () (command result),									///
	command(_r_b _r_ci _r_p									///
	: nbreg _D ib3.sex_age##yearcat, exposure(_Y) irr)    ///
	nformat(%5.2f  _r_b _r_ci )                   			///
	nformat(%5.4f  _r_p)                                	///
	sformat("(%s)" _r_ci )                             		///
	cidelimiter(" to ")
 
collect label levels result _r_b "IRR", modify
collect label levels command 1 "Negative binomial regression interaction model", modify
collect style showbase off
collect style row stack, delimiter(" x ") nobinder
collect style cell border_block, border(right, pattern(nil))

putdocx clear
putdocx begin
collect style putdocx, layout(autofitcontents)               ///
title("Table: Incidence rate ratios (IRR) of tics by age-sex group and period")
putdocx collect

local date: display %dCYND date("`c(current_date)'", "DMY")
putdocx save outputs/nbreg_table_covariates_`date', replace

putdocx begin

**# Incidence rate ratios estimating effect of period within each age-sex group
nbreg _D ib3.sex_age##i.yearcat, exposure(_Y) irr

forvalues x = 1/4 {
    forvalues y = 0/2 {
	    lincom `y'.yearcat + `x'.sex_age#`y'.yearcat, irr pformat(%5.4f)
	}
}


**# Incidence rate ratios including interaction term of sex/age and period
nbreg _D ib3.sex_age##yearcat i.imd i.region, exposure(_Y) irr

table () (command result),									///
	command(_r_b _r_ci _r_p									///
	: nbreg _D ib3.sex_age##yearcat i.imd i.region, exposure(_Y) irr)    ///
	nformat(%5.2f  _r_b _r_ci )                   			///
	nformat(%5.4f  _r_p)                                	///
	sformat("(%s)" _r_ci )                             		///
	cidelimiter(" to ")
 
collect label levels result _r_b "IRR", modify
collect label levels command 1 "Negative binomial regression interaction model", modify
collect style showbase off
collect style row stack, delimiter(" x ") nobinder
collect style cell border_block, border(right, pattern(nil))

putdocx clear
putdocx begin
collect style putdocx, layout(autofitcontents)               ///
title("Table: Incidence rate ratios (IRR) of tics by age-sex group and period, adjusted for deprivation and region")
putdocx collect

local date: display %dCYND date("`c(current_date)'", "DMY")
putdocx save outputs/nbreg_table_covariates_`date', append

putdocx begin

**# Incidence rate ratios estimating effect of period within each age-sex group
nbreg _D ib3.sex_age##i.yearcat i.imd i.region, exposure(_Y) irr

forvalues x = 1/4 {
    forvalues y = 0/2 {
	    lincom `y'.yearcat + `x'.sex_age#`y'.yearcat, rrr
	}
}


// Males aged 4-11 years
collect _r_b _r_ci _r_p: nbreg _D i.yearcat i.imd i.region if sex_age==3, exposure(_Y) irr
collect layout (yearcat) (result)
// Males aged 12-18 years
collect _r_b _r_ci _r_p: nbreg _D i.yearcat i.imd i.region if sex_age==4, exposure(_Y) irr 
collect layout (yearcat) (result)
// Females aged 4-11 years
collect _r_b _r_ci _r_p: nbreg _D i.yearcat i.imd i.region if sex_age==1, exposure(_Y) irr
collect layout (yearcat) (result)
// Females aged 12-18 years
collect _r_b _r_ci _r_p: nbreg _D i.yearcat i.imd i.region if sex_age==2, exposure(_Y) irr
collect layout (yearcat) (result)


**# Incidence rate ratios exluding period main effect
nbreg _D ib3.sex_age ib3.sex_age#i.yearcat i.imd i.region, exposure(_Y) irr
table () (command result),											///
	command(_r_b _r_ci _r_p											///
	: nbreg _D ib3.sex_age ib3.sex_age#yearcat i.imd i.region, exposure(_Y) irr)	///
	nformat(%5.2f  _r_b _r_ci )                   					///
	nformat(%5.4f  _r_p)                                			///
	sformat("(%s)" _r_ci )                             				///
	cidelimiter(" to ")
 
collect label levels result _r_b "IRR", modify
collect label levels command 1 "Negative binomial regression model excluding period main effect, adjusted for deprivation and region", modify
collect style showbase off
collect style row stack, delimiter(" x ") nobinder
collect style cell border_block, border(right, pattern(nil))

putdocx clear
putdocx begin
collect style putdocx, layout(autofitcontents)               ///
title("Table: Incidence rate ratios (IRR) of tics by age-sex group and period, adjusted for deprivation and region")
putdocx collect

putdocx save outputs/nbreg_table_covariates_`date', append



frames reset
exit
