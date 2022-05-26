** Created 2022-05-04 by Rebecca Joseph, University of Nottingham
*************************************
* Name:	analysis_yearlyrates.do
* Creator:	RMJ
* Date:	20220504
* Desc:	Creates output file for annual incidence rates for all combos of age/sex
* Requires: Stata 17
* Version History:
*	Date	Reference	Update
*	20220504	analysis_yearlyrates	Create file
*	20220509	analysis_yearlyrates	Relabelled some of the variables
*************************************

frames reset
use newid monlabel outcome_tic daysfup year sex monthagegrp using "data_prepared/prepared_incidence_expanded.dta"
drop if sex==.
sort newid monlabel

by newid: gen newdays=sum(daysfup)

gen start = 0
by newid: replace start = start + newdays[_n-1] if _n>1
gen stop = start + daysfup


** Collapse to years so runs more quickly (don't need info for indiv months)
** (Need to collapse by year and age as dob set to July)
sort newid year monthage monlabel
by newid year monthage: egen fup=sum(daysfup)
by newid year monthage: gen outcome=outcome_tic[_N]

keep newid year monthage sex outcome fup
by newid year monthage: keep if _n==1

sort newid year monthage
by newid: gen newfup = sum(fup)
gen start = 0
by newid: replace start = start + newfup[_n-1] if _n>1
gen stop = start + fup


gen group=.
replace group=0 if sex==0 & monthage==0
replace group=1 if sex==0 & monthage==1
replace group=2 if sex==1 & monthage==0
replace group=3 if sex==1 & monthage==1

label define group	0 "Male, 4 to 11 years" 1 "Male, 12 to 18 years" ///
					2 "Female, 4 to 11 years" 3 "Female, 12 to 18 years"
label values group group


stset stop, fail(outcome) scale(365.25) enter(start) id(newid) 

frame change default
capture frame drop joined
capture frame drop temp
frame create joined
frame create temp


** Rates per year for each age/sex combination
forval X=2015/2021 {
	forval Y=0/3 {
		frame change default
		tempfile FILE
		stptime if year==`X' & group==`Y', per(10000) dd(2) ///
			output(`FILE',replace)
		
		frame temp {
			clear
			use `FILE'
			gen year=`X'
			gen group=`Y'
			label values group group
		}
		
		frame joined: frameappend temp
	
	}
}



** Rates for 2015-2019 for each age/sex combination
forval Y=0/3 {
	frame change default
	tempfile FILE
	stptime if year<=2019 & group==`Y', per(10000) dd(2) ///
		output(`FILE',replace)
	
	frame temp {
		clear
		use `FILE'
		gen year=201519
		gen group=`Y'
		label values group group
	}
	
	frame joined: frameappend temp

}

*** ALL
frame change default
tempfile FILE
stptime if year<=2019, per(10000) dd(2) ///
	output(`FILE',replace)

frame temp {
	clear
	use `FILE'
	gen year=201519
	gen group=4
}

frame joined: frameappend temp



*** BY AGE
forval Y=0/1 {
	frame change default
	tempfile FILE
	stptime if year<=2019 & monthage==`Y', per(10000) dd(2) ///
		output(`FILE',replace)
	
	frame temp {
		clear
		use `FILE'
		gen year=201519
		gen group=5+`Y'
		label values group group
	}
	
	frame joined: frameappend temp

}

*** BY SEX
forval Y=0/1 {
	frame change default
	tempfile FILE
	stptime if year<=2019 & sex==`Y', per(10000) dd(2) ///
		output(`FILE',replace)
	
	frame temp {
		clear
		use `FILE'
		gen year=201519
		gen group=7+`Y'
		label values group group
	}
	
	frame joined: frameappend temp

}


** Rates overall
frame change default

tempfile FILE
stptime, per(10000) dd(2) output(`FILE',replace)

frame temp {
	clear
	use `FILE'
	gen year=0
	gen group=4
}
frame joined: frameappend temp

** Rates overall for each age/sex combination
forval Y=0/3 {
	frame change default
	tempfile FILE
	stptime if group==`Y', per(10000) dd(2) ///
		output(`FILE',replace)
	
	frame temp {
		clear
		use `FILE'
		gen year=0
		gen group=`Y'
		label values group group
	}
	
	frame joined: frameappend temp

}

** Rates overall for each age
forval Y=0/1 {
	frame change default
	tempfile FILE
	stptime if monthage==`Y', per(10000) dd(2) ///
		output(`FILE',replace)
	
	frame temp {
		clear
		use `FILE'
		gen year=0
		gen group=5 + `Y'
	}
	
	frame joined: frameappend temp

}

** Rates overall for each sex
forval Y=0/1 {
	frame change default
	tempfile FILE
	stptime if sex==`Y', per(10000) dd(2) ///
		output(`FILE',replace)
	
	frame temp {
		clear
		use `FILE'
		gen year=0
		gen group=7 + `Y'
	}
	
	frame joined: frameappend temp

}


** Yearly rates for all
forval X=2015/2021 {
		frame change default
		tempfile FILE
		stptime if year==`X', per(10000) dd(2) ///
			output(`FILE',replace)
		
		frame temp {
			clear
			use `FILE'
			gen year=`X'
			gen group=4
		}
		
		frame joined: frameappend temp
	
}


** Yearly rates by age
forval X=2015/2021 {
	forval Y=0/1 {
		frame change default
		tempfile FILE
		stptime if year==`X' & monthage==`Y', per(10000) dd(2) ///
			output(`FILE',replace)
		
		frame temp {
			clear
			use `FILE'
			gen year=`X'
			gen group=5+`Y'
			label values group group
		}
		
		frame joined: frameappend temp
	
	}
}

** Yearly rates by sex
forval X=2015/2021 {
	forval Y=0/1 {
		frame change default
		tempfile FILE
		stptime if year==`X' & sex==`Y', per(10000) dd(2) ///
			output(`FILE',replace)
		
		frame temp {
			clear
			use `FILE'
			gen year=`X'
			gen group=7+`Y'
			label values group group
		}
		
		frame joined: frameappend temp
	
	}
}





**# Format new dataset and save/export
frame change joined
frame put *, into(preserving)

drop _group
duplicates drop

label define group	0 "Male aged 4-11 years" 1 "Male aged 12-18 years" ///
					2 "Female aged 4-11 years" 3 "Female aged 12-18 years" ///
					4 "All" 5 "All aged 4-11 years" 6 "All aged 12-18 years" ///
					7 "Male" 8 "Female", modify
label values group group
decode group, gen(group2)


label define year	0 "2015-2021" 201519 "2015-2019" ///
					2015 "2015" 2016 "2016" 2017 "2017" 2018 "2018" ///
					2019 "2019" 2020 "2020" 2021 "2021", modify
label values year year
decode year, gen(year2)

sort group2 year2
order group2 year2 _D _Y _Rate _Lower _Upper

rename _D Events
rename _Y PersonTime
rename _Rate IR
rename _Lower LowerCI
rename _Upper UpperCI

format Events PersonTime %12.0gc
format IR LowerCI UpperCI %9.2f

replace PersonTime = round(PersonTime)

replace IR = round(IR,.01)
replace LowerCI = round(LowerCI,.01)
replace UpperCI = round(UpperCI,.01)

gen IRDesc = string(IR,"%9.2f") + " (" + string(LowerCI,"%9.2f") + " to " + string(UpperCI,"%9.2f") + ")"
drop year group



rename group2 studygroup
rename year2 period
rename IR IncidenceRatePer10K

sort studygroup period
save data_prepared/yearly_IRs.dta, replace
export delimited using outputs/yearly_IRs.csv, replace delim(",")







frames reset
exit
