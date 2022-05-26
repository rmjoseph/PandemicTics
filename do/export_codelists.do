** Created 2022-05-09 by Rebecca Joseph, University of Nottingham
*************************************
* Name:	export_codelists.do
* Creator:	RMJ
* Date:	20220509
* Desc:	Export codelists as a .csv file for sharing
* Requires: Stata 17
* Version History:
*	Date	Reference	Update
*	20220509	export_codelists	Create file
*	20220524	export_codelists	New section - export in ClinicalCodes format
*	20220526	export_codelists	Revise/replace export in ClinicalCodes (updated approach)
*************************************

frames reset

** Load all lists and create a long dataset
capture frame drop temp
frame create temp

local diag "tics ethnicity adhd anxiety autism depression eatingdisorder ocd selfharm somatoform stressreaction"
foreach X of local diag {
	frame temp {
		clear
		import excel "data_raw/codelists/TicsProject_ReadCodes_v2.xlsx", sheet(`X') firstrow case(lower)
		rename aurum_medcode medcodeid
		capture gen group=""
		keep medcodeid group
		drop if medcodeid==""
		duplicates drop
		gen list="`X'"
	}
	
	frameappend temp
}

** Merge the dataset with medical.dta. 
merge m:1 medcodeid using "data_prepared/medical.dta"
keep if _merge==3

sort list medcodeid
keep medcodeid group list term cleansed snomed*
compress
format term %50s

rename  cleansedreadcode readcode
rename medcodeid CPRD_medcode

order list group CPRD_medcode readcode 

** Export
export delim outputs/all_codelists.csv, delim(",") replace





**# added 24-05-2022 - EXPORT CODELISTS IN CLINICALCODES FORMAT
frames reset
import delim outputs/all_codelists.csv, stringcols(_all)

rename cprd_medcode medcodeid

*** (1) move records where the medcode is the snomedctdesc
frame put if medcodeid==snomedctdesc, into(new1)
drop if medcodeid==snomedctdesc

*** (2) move records where there is a readcode 
frame put if readcode!="", into(new2)
drop if readcode!=""

*** (3) for remaining records, set code to snomedctdesc. Check for duplicates.
gen code=snomedctdesc
gen coding_system="SNOMED"
gen entity="diagnostic"
gen list_name=list + "_snomed"
gen description=term
gen category=group
keep code-category

duplicates report code list_name

*** For (1), set code to medcodeid. Check for duplicates.
frame change new1
gen code=medcodeid
gen coding_system="SNOMED"
gen entity="diagnostic"
gen list_name=list + "_snomed"
gen description=term
gen category=group
keep code-category

duplicates report code list_name

*** For (2), set code to readcode. Check for duplicates. Export.
frame change new2
gen code=readcode
gen coding_system="Read"
gen entity="diagnostic"
gen list_name=list + "_read"
gen description=term
gen category=group
keep code-category

duplicates report code list_name

export delimited using "R:\QResearch\Tics\analysis\outputs\ticscodelistsforupload_read.csv", replace


*** (4) Combine (1) and (3) into single list. Check for duplicates. Export.
frame change default
frameappend new1
duplicates drop

duplicates report code list_name

levelsof list_name, local(var)
foreach X of local var {
	export delimited if list_name=="`X'" using "R:\QResearch\Tics\analysis\outputs\ticscodelistsforupload_`X'.csv", replace

}


gen snomedctdescriptionid = code
replace code=substr(code,1,8)
duplicates report code list_name


export delimited using "R:\QResearch\Tics\analysis\outputs\ticscodelistsforupload_snomed.csv", replace



/* Check mapping to medical dictionary
replace code=snomedctdescriptionid
drop snomedctdescription

frame create medical
frame change medical
use data_prepared/medical.dta
gen code=cleansed
frame new2: duplicates drop code, force
frlink m:1 code, frame(new2)

replace code=snomedctdesc
frame default: duplicates drop code, force
frlink m:1 code, frame(default)

frame create codelist
frame codelist {
	import delim outputs/all_codelists.csv, stringcols(_all)
	keep cprd_medcode
	duplicates drop
	rename cprd_medcode medcodeid
}

frlink m:1 medcodeid, frame(codelist)
replace codelist=codelist<.
gen match=(default<.) | (new2<.)
tab codelist match,m
*/

frames reset
exit
