** Created 2022-02-15 by Rebecca Joseph, University of Nottingham
*************************************
* Name:	prep_defineethnicity.do
* Creator:	RMJ
* Date:	20220215
* Desc:	
* Requires: Stata 17
* Version History:
*	Date	Reference	Update
*	20220215	prep_defineethnicity	Create file
*************************************


/*
open extracted_ethnicityrecords file
if single ethnicity record or multiple ethnicity records but all for the same ethnic group, define ethnicity  as that group
if ethnicity records from multiple ethnic groups, set to unknown/missing
*/

**# Open file
frames reset
use data_prepared/extracted_allethnicityrecords.dta

**# Count number of ethnicities recorded
bys patid ethnicity (eventdate): gen sum=1 if _n==1
bys patid ethnicity (eventdate): replace sum=sum(sum)

**# Set ethnicity
bys patid (ethnicity eventdate): keep if _n==1
replace ethnicity = . if sum>1
keep patid ethnicity

**# Save and exit
save data_prepared/defined_ethnicity.dta, replace
clear
exit
