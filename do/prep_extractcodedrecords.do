** Created 2022-02-15 by Rebecca Joseph, University of Nottingham
*************************************
* Name:	prep_extractcodedrecords.do
* Creator:	RMJ
* Date:	20220215
* Desc:	
* Requires: Stata 17
* Version History:
*	Date	Reference	Update
*	20220215	prep_extractcodedrecords	Create file
*	20220411	prep_extractcodedrecords	Update file paths for Mar data
*************************************


/*
open (single) observation file
merge with eligibility/dates file to get year birth and cohort exit date
convert obsdate/enterdate to dates, setting unfeasible dates to missing
drop records with missing dates
looping over each code list (except ethnicity):
	merge code list with file
	create variable containing date of first record of that condition (or missing)
save
merge with ethnicity code list
keep ethnicity records & save as separate file
*/

**# Import observation file
frames reset

import delimited using "data_raw/Aurum_extract_2022-03/tics202203_Extract_Observation_001.txt", stringcol(1 3 9)
keep patid obsdate enterdate medcodeid
drop if medcodeid==""

**# Merge with eligibility file
merge m:1 patid using "data_prepared/cohortwithdates.dta", keep(3) nogen keepusing(yob fupend)

**# Convert and clean event dates
gen date=date(obsdate,"DMY")
gen eventdate=date
format eventdate %dD/N/CY
sum eventdate, format
replace eventdate=. if year(eventdate)<yob | eventdate>fupend
drop date

gen date=date(enterdate,"DMY")
replace eventdate=date if eventdate==.
sum eventdate, format
replace eventdate=. if year(eventdate)<yob | eventdate>fupend
drop date yob fupend obsdate enterdate

**# Drop records with missing dates
count
count if eventdate==.
drop if eventdate==.

order patid eventdate medcodeid

**# Loop over each code list: load & link code list and get date
local diag "adhd anxiety autism depression eatingdisorder ocd selfharm somatoform stressreaction"
capture frame drop temp
foreach X of local diag {
	frame create temp
	frame temp {
		import excel "data_raw/codelists/TicsProject_ReadCodes_v2.xlsx", sheet(`X') firstrow case(lower)
		rename aurum_medcode medcodeid
		keep medcodeid
		drop if medcodeid==""
		duplicates drop
	}
	frlink m:1 medcodeid, frame(temp)
	gen `X'=eventdate if temp<.
	bys patid: egen first_`X'=min(`X')
	format `X' first_`X' %dD/N/CY
	drop temp
	frame drop temp
}

**# Put in a new frame and save file
frame put patid first*, into(new)
frame change new
bys patid: keep if _n==1

save "data_prepared/extracteddiagnosisdates.dta", replace

**# Save all records of these diagnoses
frame change default
frame drop new
order first*, last

egen nonmiss = rownonmiss(adhd-stressreaction)
frame put if nonmiss>0, into(new)

frame change new
keep patid eventdate medcodeid adhd-stressreaction
merge m:1 medcodeid using data_prepared/medical.dta, keepusing(term) keep(3) nogen
format term %60s
sort patid eventdate medcodeid

save "data_prepared/extracted_alldiagnosisrecords.dta", replace


**# ETHNICITY
frame change default
frame drop new
keep patid eventdate medcodeid

frame create ethnicity
frame ethnicity {
	import excel "data_raw/codelists/TicsProject_ReadCodes_v2.xlsx", sheet(ethnicity) firstrow case(lower) allstring
	rename aurum_medcode medcodeid
	drop if medcodeid==""
	duplicates drop
}

frlink m:1 medcodeid, frame(ethnicity)
frget *, from(ethnicity)
keep if ethnicity<.
drop ethnicity

encode group, gen(ethnicity)
save "data_prepared/extracted_allethnicityrecords.dta", replace

frames reset
exit
