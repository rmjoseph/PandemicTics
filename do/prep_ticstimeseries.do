** Created 2022-01-10 by Rebecca Joseph, University of Nottingham
*************************************
* Name:	prep_tictimeseries.do
* Creator:	RMJ
* Date:	20220110
* Desc:	
* Requires: Stata 17
* Version History:
*	Date	Reference	Update
*	20220110	prep_tictimeseries	Create file
*	20220224	prep_tictimeseries	Start with prepared_incidence.dta (not cohort)
*	20220225	prep_tictimeseries	Offset stop by 0.9 day for survival etc
*	20220411	prep_tictimeseries	Paste code to collapse dataset from rates_itsa_poisson
*	20220411	prep_tictimeseries	Also gen simplified counts collapsed dataset
*************************************

frames reset

use "data_prepared/prepared_incidence.dta"

**# For memory: remove string patid 
bys patid: keep if _n==1
gen newid = _n

*frame put patid newid, into(link)
drop patid
order newid

**# var to help identify when tic was rec'd
gen mon=month(firsttic)
gen year=year(firsttic)

gen monthtic = (year-1960)*12 + mon-1
format monthtic %tm
replace  monthtic=. if tic!=1

drop mon year





**# Expand the dataset so all pats have a record for each month from Jan 2015 to Dec 2021
expand 84
sort newid

** Numeric counter for months
bys newid: gen month=_n
replace month = month + m(2015m1) - 1
format month %tm
sort newid month




**# Calculate length of follow-up for each pat in each month
** Vars for start and end of each month
bys newid (month): gen year = _n - 1
replace year = floor(year/12) + 2015

bys newid year (month): gen mon = _n

gen day = 1

gen monthfirstday = mdy(mon,day,year)
format monthfirstday %td

gen monthlastday = lastdayofmonth(monthfirstday) 
format monthlastday %td

drop day	// keep year mon


** Monthly follow-up start and end dates
egen start = rowmax(fupstart monthfirstday)
egen stop = rowmin(fupend monthlastday firsttic)
replace stop = stop + 0.99 // otherwise survival/fuptime counts will drop them if start==stop
format start stop %dD/N/CY

**# Length of follow-up each month, and drop months with no followup
gen daysfup = stop-start
replace daysfup = round(daysfup)

count
*codebook newid
count if monthtic==month
count if monthtic==month & daysfup>0

drop if daysfup<=0 // stop has been adjusted so <= is ok

count
codebook newid
count if monthtic==month


**# Indicator of which month the tic occured in
gen outcome_tic = monthtic==month


**# Create vars for age and study period
gen yearcat=0
replace yearcat=1 if year==2020
replace yearcat=2 if year==2021

gen monthage = age(dob,monthfirstday)
gen monthagegrp = (monthage>=12 & monthage<.)


**# Tidy and save
order newid outcome_tic month start stop daysfup yearcat monthage monthagegrp sex region imd mon year pracid fupstart fupend firsttic monthfirstday monthlastday

rename month monlabel
rename mon month
label var newid "New numeric patient id (does not link back)"
label var outcome_tic "Indicates outcome happening in particular month"
label var monlabel "Numeric label indicating month & year of followup"
label var start "First day of follow-up each month"
label var stop "Last day of follow-up each month, offset by +0.99 days"
label var daysfup "stop - start, rounded to whole day"
label var yearcat "grouping 0=2015-2019, 1=2020, 2=2021"
label var monthage "Age (years) of patient in that month"
label var monthagegrp "Categorised aged of pat in that month (4-11, 12-19)"

drop tic dob monthtic

save "data_prepared/prepared_incidence_expanded.dta", replace



**# stset data and create new dataset with collapsed data
*use "data_prepared/prepared_incidence_expanded.dta", clear
stset stop, id(newid) origin(fupstart) enter(start) failure(outcome_tic) exit(failure) scale(365.25)
strate year sex monthagegrp month region imd, per(10000) output("data_prepared/Tics_strate_all_split.dta", replace)



**# Collapsed data for quick check of incidence/counts
frames reset
use outcome_tic daysfup yearcat monthagegrp sex month using "data_prepared/prepared_incidence_expanded.dta"

sort monthagegrp sex yearcat month
by monthagegrp sex yearcat month: egen persontime=sum(daysfup)
replace persontime=persontime/365.25
by monthagegrp sex yearcat month: egen eventscount=sum(outcome_tic)

keep monthagegrp sex yearcat month persontime eventscount
duplicates drop

gen rate=(eventscount/persontime)*10000

label def period 0 "2015-2019" 1 "2020" 2 "2022"
label values yearcat period

label def age 0 "4-11 years" 1 "12-18 years"
label values monthagegrp age

save data_prepared/simplifiedcounts.dta, replace


************
frames reset
exit

