** Created 2022-01-10 by Rebecca Joseph, University of Nottingham
*************************************
* Name:	prep_eligibilityanddates.do
* Creator:	RMJ
* Date:	20220110
* Desc:	
* Requires: Stata 17
* Version History:
*	Date	Reference	Update
*	20220110	prep_eligibilityanddates	Create file
*	20220110	prep_eligibilityanddates	Update file paths
*	20220110	prep_eligibilityanddates	Update def of date4 and date19
*	20220203	prep_eligibilityanddates	New eligibility flags rather than dropping
*	20220203	prep_eligibilityanddates	Save two files, one with eligibility flags for counting
*	20220324	prep_eligibilityanddates	Edit to censor at 30/11/2021, add tic date as censor date if appropriate [RHJ]
*	20220411	prep_eligibilityanddates	Updated file paths (202203) and reverted sw_end to 31/12
*************************************

frames reset
set more off

** Files needed:
*** Acceptable patients denominator file (and practice file if info is separate)
*** First tic date (define results?)

** Vars to create:
*** DOB
*** Flag for tic
*** Date of first tic
*** Follow-up start (latest registration start + 1y, study window start, date4)
*** Follow-up end (earliest first tic, registration end, death, last collection date, study window end, date19)
*** Eligibility (fupstart < fupend) 



**# PATIENT FILE
** Load acceptable patients denominator file, keep acceptable & in England
import delimited using "data_raw/AurumDenominator_202203/202203_CPRDAurum_AcceptablePats.txt", stringcols(1)
keep if acceptable==1
keep if patienttypeid=="Regular" 
keep if region<10 //  10 Wales 11 Scotland 12 NI
keep patid gender pracid regstartdate regenddate cprd_ddate uts lcd yob region

** Convert strings to numeric dates
foreach X of varlist regstartdate regenddate cprd_ddate lcd {
	rename `X' date
	gen `X' = date(date,"DMY")
	format `X' %dD/N/CY
	drop date
}

** Study window start and end
gen sw_start = date("01/01/2015","DMY")
gen sw_end = date("31/12/2021","DMY")	// 20220411 changed from 30/11
format sw_* %dD/N/CY

** Date of registration plus one year
gen regplus1 = floor(regstartdate + 365.25)
format regplus1 %dD/N/CY

** Date of birth (01 July each year) and date of turning 4 and 19
gen dob = "01/07/" + string(yob)
gen date4 = "01/07/" + string(yob + 4)
gen date19 = "01/07/" + string(yob + 19)

foreach X of varlist dob date4 date19 {
	rename `X' date
	gen `X' = date(date,"DMY")
	format `X' %dD/N/CY
	drop date
}

replace date19 = date19-1 // so <= eligstop works

** Follow-up start and end
egen fupstart = rowmax(regplus1 date4 sw_start)
egen fupend = rowmin(regenddate cprd_ddate lcd date19 sw_end)
format fupstart fupend %dD/N/CY

** Tidy
gen sex=0 if gender=="M"
replace sex=1 if gender=="F"
replace sex=. if gender=="I"
label define sex 0 "M" 1 "F", replace
label values sex sex

label define region	0 "None" ///
					1 "North East" ///
					2 "North West" ///
					3 "Yorkshire and The Humber" ///
					4 "East Midlands" ///
					5 "West Midlands" ///
					6 "East of England" ///
					7 "London" ///
					8 "South East" ///
					9 "South West" ///
					10 "Wales" ///
					11 "Scotland" ///
					12 "Northern Ireland"
label values region region


order patid pracid dob sex region fupstart fupend
drop uts



**# ELIGIBILITY FLAG
gen eligiblefup = (fupstart<=fupend)
label var eligiblefup "follow-up start <= follow-up end"



**# DATE OF FIRST TIC RECORD
** Load define result file with index date, link to prep'd dataset
frame create define
frame define {
	import delimited using data_raw/Aurum_extract_2022-03/tics202203_Define_results.txt, stringcols(1)
	gen firsttic=date(index,"DMY")
	drop index
	format firsttic %dD/N/CY
}

frlink 1:1 patid, frame(define)
frget firsttic, from(define)


** Update eligibility (first tic is during follow-up). create tic flag and update censor date (fupend)
** Note, first tic should be after 1y of follow-up. Automatically excluded below.
gen eligibletic = (firsttic>=fupstart)
label var eligibletic "0 if tic before follow-up start"

gen eligible = eligiblefup==1 & eligibletic==1
label var eligible "1 if Eligible for final cohort"

gen tic = (firsttic>=fupstart & firsttic<=fupend)

replace fupend=firsttic if firsttic<fupend & tic==1


**# TIDY AND SAVE (two datasets: eligibility and cohort)
order patid pracid tic dob sex region fupstart fupend firsttic eligiblefup eligibletic eligible 
drop define 
drop gender

label var regstartdate "Date of registering with CPRD practice"
label var regplus1 "Date of registering with CPRD practice plus one year"
label var fupstart "Latest of reg +1y, date turned 4yo,  01 Jan 2015"
label var fupend "Earliest of reg end, death, lcd, 30 Nov 2021, date turned 19yo, tic"
label var firsttic "Date of first tic"
label var tic "Indicator of having first tic during follow-up"

frame put if eligible==1, into(tosave)
keep patid eligiblefup eligibletic eligible
save "data_prepared/eligibilityflags_allpats.dta", replace

frame change tosave
drop eligible*
save "data_prepared/cohortwithdates.dta", replace


**# CLEAR AND END
frames reset
exit

