** Created 2022-02-15 by Rebecca Joseph, University of Nottingham
*************************************
* Name:	prep_diagnosesatindex.do
* Creator:	RMJ
* Date:	20220215
* Desc:	
* Requires: Stata 17
* Version History:
*	Date	Reference	Update
*	20220215	prep_diagnosesatindex	Create file
*************************************


/*
merge extracteddiagnosisdates with list of people who had tics to get full patlist and their index
change vars to indicators (1 0) based on record <= indexdate
*/

**# Open and merge files
frames reset
use patid firsttic tic if tic==1 using "data_prepared/cohortwithdates.dta"
merge 1:1 patid using "data_prepared/extracteddiagnosisdates.dta"
drop if _merge==2
drop _merge

**# Create indicators from diagnosis vars
foreach X of varlist first_* {
	local Y = substr("`X'",7,.)
	gen `Y' = `X' <= firsttic
	drop `X'
}

**# Save and exit
save data_prepared/defined_bldiagnoses.dta, replace
clear
exit
