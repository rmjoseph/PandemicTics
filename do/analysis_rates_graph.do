** Created 2022-05-11 by Ruth Jack, University of Nottingham
*************************************
* Name:	analysis_rates_graph.do
* Creator:	RHJ
* Date:	20220511
* Desc:	Graph of tic incidence rates by age-sex group over study period
* Requires: Stata 17
*************************************

version 17.0
frames reset

use data_prepared/simplifiedcounts.dta

drop if sex==.

**# Create year-month variable for regression
egen ycat_m1=concat(yearcat month) if month<=9, punct(_0)
egen ycat_m2=concat(yearcat month) if month>9, punct(_)
replace ycat_m1=ycat_m2 if ycat_m1==""
encode ycat_m1, gen(ycat_m)
drop ycat_m1 ycat_m2

** Set limit for areas on graph representing lockdowns
gen upper=25

**# Draw graph of each age-sex group across whole time period
graph twoway (bar upper ycat_m if inrange(ycat_m, 15, 18), bcolor(gs14) base(0) lwidth(none)) ///
			 (bar upper ycat_m if inrange(ycat_m, 23, 23), bcolor(gs14) base(0) lwidth(none)) ///
			 (bar upper ycat_m if inrange(ycat_m, 25, 27), bcolor(gs14) base(0) lwidth(none)) ///
			 (line rate ycat_m if sex==0 & monthagegrp==0, lc("0 45 114") lw(medthick) lp(-)) ///
			 (line rate ycat_m if sex==0 & monthagegrp==1, lc("0 45 114") lw(medthick)) ///
			 (line rate ycat_m if sex==1 & monthagegrp==0, lc("252 89 16") lw(medthick) lp(-)) ///
			 (line rate ycat_m if sex==1 & monthagegrp==1, lc("252 89 16") lw(medthick)), ///
			 legend(order(4 5 6 7 1) label(1 "England lockdowns / schools closed") ///
			 label(4 "Males 4 to 11 years") label(5 "Males 12 to 18 years") ///
			 label(6 "Females 4 to 11 years") label(7 "Females 12 to 18 years")) ///
			 xlabel(1 "J" 2 "F" 3 "M" 4 "A" 5 "M" 6 `""J" "2015-2019""' 7 "J" 8 "A" 9 "S" 10 "O" 11 "N" 12 "D" ///
			 13 "J" 14 "F" 15 "M" 16 "A" 17 "M" 18 `""J" "2020""' 19 "J" 20 "A" 21 "S" 22 "O" 23 "N" 24 "D" ///
			 25 "J" 26 "F" 27 "M" 28 "A" 29 "M" 30 `""J" "2021""' 31 "J" 32 "A" 33 "S" 34 "O" 35 "N" 36 "D", labsize(small)) ///
			 yscale(r(0(5)25)) ytitle("Incidence per 10,000 person-years") xtitle("Month and Year") ysize(10cm) xsize(16cm)
graph export "outputs/tics_rates_graph.png", replace
