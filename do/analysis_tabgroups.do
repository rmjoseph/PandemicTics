** Created 2022-05-09 by Rebecca Joseph, University of Nottingham
*************************************
* Name:	analysis_tabgroups.do
* Creator:	RMJ
* Date:	20220509
* Desc:	Tabulates the numbers of people in each study group/subgroup
* Requires: Stata 17
* Version History:
*	Date	Reference	Update
*	20220509	new file	Create file
*************************************
cd R:/QResearch/Tics/analysis

**# Set up scalars containing values of interest 
frames reset

use data_prepared/prepared_comparison.dta, clear 
keep if sex<.

gen group=.
replace group=1 if agegrp==0 & sex==0
replace group=2 if agegrp==1 & sex==0
replace group=3 if agegrp==0 & sex==1
replace group=4 if agegrp==1 & sex==1

tab group yeargrp

label def group 1 "Males aged 4 to 11 years" 2 "Males aged 12 to 18 years" 3 "Females aged 4 to 11 years" 4 "Females aged 12 to 18 years" 
label values group group



putdocx begin
putdocx paragraph
putdocx text ("groups: 1 Males aged 4 to 11 years, 2 Males aged 12 to 18 years, 3 Females aged 4 to 11 years, 4 Females aged 12 to 18 years")

table group yeargrp, nformat(%9.0gc)
collect
putdocx collect

local date: display %dCYND date("`c(current_date)'", "DMY")
putdocx save outputs/groups_counts_`date', replace


frames reset
exit
