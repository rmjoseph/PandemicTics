** Created 2022-01-26 by Rebecca Joseph, University of Nottingham
*************************************
* Name:	linkage_eligibility2.do
* Creator:	RMJ
* Date:	20220126
* Desc:	Outputs list of patients to request linked data for
* Requires: Stata 17
* Version History:
*	Date	Reference	Update
*	20220110	linkage_eligibility	Create file
*	20220126	linkage_eligibility	New version correcting errors
*************************************

frames reset

** LOG
capture log close linkelig
local date: display %dCYND date("`c(current_date)'", "DMY")
log using "logs/LinkageElig_`date'.txt", text append name(linkelig)
display "Determining patients eligible for linkage; log opened $S_DATE $S_TIME"


** Files needed:
* Patient denominator
* Practice denominator (might be part of the patient file)
* Linkage eligibility
* (tics index dates)
**

**# Patient file
frame create patient
frame patient {
	** ACCEPTABLE PATIENTS
	import delim "data_raw/AurumDenominator_202201/202201_CPRDAurum_AcceptablePats.txt", stringcols(1)
	keep if acceptable==1
	count
	keep if patienttypeid=="Regular" // note - 'Regular' is part of Aurum definition of acceptable 
	count
	sort patid
	
	** AT ENGLISH PRACTICES
	keep if region<=9	// changed from <9
	drop region
	count 
	
	** DATES
	keep patid pracid regstartdate regenddate cprd_ddate uts lcd yob

	*** Convert string to numeric dates
	foreach X of varlist regstartdate regenddate cprd_ddate lcd {
		rename `X' date
		gen `X' = date(date,"DMY")
		format `X' %dD/N/CY
		drop date
	}

	*** Study window start and end
	gen sw_start = date("01/01/2015","DMY")
	gen sw_end = date("31/12/2021","DMY")
	format sw_* %dD/N/CY

	*** Date of registration plus one year
	gen regplus1 = floor(regstartdate + 365.25)
	format regplus1 %dD/N/CY

	*** Date of birth (01 July each year) and date of turning 4 and 19
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

	
	** ELIGIBILITY based on dates
	*** start: date turn 4, joining pracice +1y, study window start
	*** stop: date turn 19, leaving practice (/death), last data collection date, study window end
	order patid date4 regplus1 sw_start date19 regenddate cprd_ddate lcd sw_end

	egen eligstart = rowmax(date4 regplus1 sw_start)
	egen eligstop = rowmin(date19 regenddate lcd sw_end cprd_ddate)

	format eligstart eligstop %dD/N/CY

	count if eligstart<eligstop
	count if eligstart==eligstop
	count if eligstart>eligstop

}


**# Linkage eligibility file
frame create linkage
frame linkage {
	import delim using data_raw/set_21_Source_Aurum/linkage_eligibility.txt, stringcols(1)
	keep patid lsoa_e
	sort patid
	}

	
**# Combine
frame change patient
frlink 1:1 patid, frame(linkage)
frget lsoa_e, from(linkage)


**# Pats to include in linkage request
count
drop if eligstop < eligstart
count
keep if lsoa_e==1
count


**# Export
keep patid
duplicates drop
sort patid

export delimited using "outputs/21_001650_UniNottingham_patientlist_aurum_UPDATED.txt", delim(tab) replace


** end
frames reset
log close linkelig
exit
