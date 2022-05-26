** Created 2022-02-03 by Rebecca Joseph, University of Nottingham
*************************************
* Name:	prep_combinevars.do
* Creator:	RMJ
* Date:	20220203
* Desc:	create master dataset with all outcomes and covariates etc
* Requires: Stata 17
* Version History:
*	Date	Reference	Update
*	20220203	prep_combinevars	Create file
*	20220215	prep_combinevars	Add comorbs and ethnicity
*	20220216	prep_combinevars	Create age vars & labels before separate dsets
*	20220324	prep_combinevars	Add NK category for IMD [RHJ]
*************************************

frames reset
set more off

use "data_prepared/cohortwithdates.dta"

**# IMD
frame create pat
frame pat {
	import delim "data_raw/imd/patient_imd2015_21_001650.txt", stringcols(1)
	sort patid
}

sort patid
frlink 1:1 patid, frame(pat)
frget imd2015_5, from(pat)
drop pat

frame create prac
frame prac {
	import delim "data_raw/imd/practice_imd_21_001650.txt"
	sort pracid
}

sort pracid
frlink m:1 pracid, frame(prac)
frget country e2019_imd_5, from(prac)
drop prac

gen imd = imd2015_5
replace imd=e2019_imd_5 if imd==.


**# Comorbidities
merge 1:1 patid using "data_prepared/defined_bldiagnoses.dta"
drop _merge

**# Ethnicity
merge 1:1 patid using "data_prepared/defined_ethnicity.dta"
drop _merge


**# Age / year variables for people with tic record
gen agefirsttic = age(dob,firsttic)
gen agegrp = (agefirst>=12)
label def agegroup 0 "4 to 11 years" 1 "12 to 18 years"
label values agegrp agegroup

gen yeartic = year(firsttic)
gen temp = "2015 to 2019"
replace temp = "2020" if yeartic==2020
replace temp = "2021" if yeartic==2021
encode temp, gen(yeargrp)
drop temp


**# tidying / labelling
label var agegrp "Age group"

label var yeargrp "Year of first tic record"

label var sex "Sex"
label def sex 0 "Male" 1 "Female", modify

label var imd "Deprivation quintile (IMD)"
mvencode imd, mv(9)
label def imd 1 "1 (least deprived)" 2 "2" 3 "3" 4 "4" 5 "5 (most deprived)" 9 "NK"
label values imd imd

label var region "Practice region"

label var adhd "ADHD"
label var anxiety "Anxiety (phobic or generalised)"
label var autism "Autism Spectrum Disorder"
label var depress "Depression"
label var eatingdisorder "Eating disorder"
label var ocd "Obsessive Compulsive Disorder"
label var selfharm "Self-harm (intentional or unspecified)"
label var somatoform "Dissociative or somatoform disorder"
label var stressreaction "Stress reaction or adjustment disorder"

label var ethnicity "Ethnicity"


**# tidy and save - TWO DATASETS
*** first dataset is comparison dataset for those who do have a tic
frame put if tic==1, into(subset)
frame change subset
keep patid pracid firsttic sex region imd adhd-stress ethnicity agefirsttic agegrp yeartic yeargrp

order patid pracid firsttic yeartic yeargrp agefirsttic agegrp

save "data_prepared/prepared_comparison", replace



*** second dataset is incidence dataset for whole denominator
frame change default
keep patid pracid tic dob sex region fupstart fupend firsttic imd

save "data_prepared/prepared_incidence", replace



**# CLEAR AND END
frames reset
exit



