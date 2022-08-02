** Created 2022-05-09 by Ruth Jack, University of Nottingham
*************************************
* Name:	analysis_poisson.do
* Creator:	RHJ
* Date:	20220509
* Desc:	Poisson regression for tics by age-sex group and period
* Requires: Stata 17
*	Date	Reference	Update
*	20220509	analysis_poisson	Create file
*	20220529	analysis_poisson	Prepare for upload (replace file paths) [RMJ]
*************************************


version 17.0
frames reset

global date: display %dCYND date("`c(current_date)'", "DMY")


**# New frame 
frame create poisson
frame change poisson

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
poisson _D ib3.sex_age##yearcat, exposure(_Y) irr

table () (command result),									///
	command(_r_b _r_ci _r_p									///
	: poisson _D ib3.sex_age##yearcat, exposure(_Y) irr)    ///
	nformat(%5.2f  _r_b _r_ci )                   			///
	nformat(%5.4f  _r_p)                                	///
	sformat("(%s)" _r_ci )                             		///
	cidelimiter(" to ")
 
collect label levels result _r_b "IRR", modify
collect label levels command 1 "Poisson Interaction Model", modify
collect style showbase off
collect style row stack, delimiter(" x ") nobinder
collect style cell border_block, border(right, pattern(nil))

putdocx clear
putdocx begin
collect style putdocx, layout(autofitcontents)               ///
title("Table: Incidence rate ratios (IRR) of tics by age-sex group and period")
putdocx collect

local date: display %dCYND date("`c(current_date)'", "DMY")
putdocx save outputs/poisson_table_`date', replace

putdocx begin

**# Incidence rate ratios estimating effect of period within each age-sex group
poisson _D ib3.sex_age##i.yearcat, exposure(_Y) irr

forvalues x = 1/4 {
    forvalues y = 0/2 {
	    lincom `y'.yearcat + `x'.sex_age#`y'.yearcat, rrr
	}
}

**# Incidence rate ratios exluding period main effect
poisson _D ib3.sex_age ib3.sex_age#i.yearcat, exposure(_Y) irr
table () (command result),											///
	command(_r_b _r_ci _r_p											///
	: poisson _D ib3.sex_age ib3.sex_age#yearcat, exposure(_Y) irr)	///
	nformat(%5.2f  _r_b _r_ci )                   					///
	nformat(%5.4f  _r_p)                                			///
	sformat("(%s)" _r_ci )                             				///
	cidelimiter(" to ")
 
collect label levels result _r_b "IRR", modify
collect label levels command 1 "Poisson model excluding period main effect", modify
collect style showbase off
collect style row stack, delimiter(" x ") nobinder
collect style cell border_block, border(right, pattern(nil))

putdocx clear
putdocx begin
collect style putdocx, layout(autofitcontents)               ///
title("Table: Incidence rate ratios (IRR) of tics by age-sex group and period")
putdocx collect

putdocx save outputs/poisson_table_`date', append



frames reset
exit
