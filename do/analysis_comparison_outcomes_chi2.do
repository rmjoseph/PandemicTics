* Created 2022-04-11 by Ruth Jack at the University of Nottingham
*************************************
* Name:	analysis_comparison_outcomes_chi2
* Creator:	RHJ
* Date:	20220411
* Desc:	New tables of comorbidities / associated features by year group and Chi2 values
* Version History:
*	Date	Reference	Update
*	20220411	analysis_comparison_outcomes_chi2	create file
*************************************

version 17.0
use data_prepared/prepared_comparison.dta, clear 

** Exclude people with no sex recorded and create sex-age groups with labels
drop if sex==.
gen sex_s="m"
replace sex_s="f" if sex==1
egen sex_age1=concat(sex_s agegrp), punct(_)
encode sex_age1, gen(sex_age)
drop sex_s sex_age1
lab def sex_age 1 "Female 4-11" 2 "Female 12-18" 3 "Male 4-11" 4 "Male 12-18", modify

** Define comorbidities / associated features
local outcomes "adhd anxiety autism depression eatingdisorder ocd selfharm somatoform stressreaction"

** Open Word document and add table with headings for overall figures
putdocx begin
putdocx table a = (2, 6)
putdocx table a(1, 2) = ("2015-2019"), halign(center)
putdocx table a(1, 3) = ("2020"), halign(center)
putdocx table a(1, 4) = ("2021"), halign(center)

putdocx table a(2, 2) = ("n (%)"), halign(center)
putdocx table a(2, 3) = ("n (%)"), halign(center)
putdocx table a(2, 4) = ("n (%)"), halign(center)
putdocx table a(2, 5) = ("Chi2"), halign(center)
putdocx table a(2, 6) = ("p-value"), halign(center)

local row 2
putdocx table a(`row', . ), addrows(1)

** Tabulate each comorbidity / associated feature with year group and add to Word table
foreach v of local outcomes {
	local ++row

	tabulate `v' yeargrp, chi2 matcell(`v'_t) 
	putdocx table a(`row', . ), addrows(`=r(r)+1')
	putdocx table a(`row', 1) = ("`:variable label `v''")
	mata : st_matrix("`v'_ts", colsum(st_matrix("`v'_t"))) 

	local tmp1: display %4.1f `v'_t[2, 1]/`v'_ts[1,1]*100 
	local tmp2: display %4.1f `v'_t[2, 2]/`v'_ts[1,2]*100 
	local tmp3: display %4.1f `v'_t[2, 3]/`v'_ts[1,3]*100 

	putdocx table a(`row', 2) = (`v'_t[2, 1]), halign(center) 
	putdocx table a(`row', 2) = (" (" + "`tmp1'" + "%)"), halign(center) append

	putdocx table a(`row', 3) = (`v'_t[2, 2]), halign(center) 
	putdocx table a(`row', 3) = (" (" + "`tmp2'" + "%)"), halign(center) append

	putdocx table a(`row', 4) = (`v'_t[2, 3]), halign(center)
	putdocx table a(`row', 4) = (" (" + "`tmp3'" + "%)"), halign(center) append

	putdocx table a(`row', 5) = (r(chi2)), nformat(%6.2f) halign(right)
	putdocx table a(`row', 6) = (cond(r(p)<0.001, "<0.001", string(r(p)))), nformat(%8.3f) halign(right)
}

** Repeat above table for different sex-age groups
forvalues x=1/4 {
	putdocx table a`x' = (3, 6)
	putdocx table a`x'(1, 2) = ("2015-2019"), halign(center)
	putdocx table a`x'(1, 3) = ("2020"), halign(center)
	putdocx table a`x'(1, 4) = ("2021"), halign(center)

	putdocx table a`x'(2, 2) = ("n (%)"), halign(center)
	putdocx table a`x'(2, 3) = ("n (%)"), halign(center)
	putdocx table a`x'(2, 4) = ("n (%)"), halign(center)
	putdocx table a`x'(2, 5) = ("Chi2"), halign(center)
	putdocx table a`x'(2, 6) = ("p-value"), halign(center)

	putdocx table a`x'(3, 1) = ("`:label sex_age `x''")
	
	local row 3
	putdocx table a`x'(`row', . ), addrows(1)


	foreach v of local outcomes {
		local ++row

		di "`v' :label sex_age `x''"
		tabulate `v' yeargrp if sex_age==`x', chi2 matcell(`v'_`x'_t)
		putdocx table a`x'(`row', . ), addrows(`=r(r)+1')
		putdocx table a`x'(`row', 1) = ("`:variable label `v''") 
		mata : st_matrix("`v'_`x'_ts", colsum(st_matrix("`v'_`x'_t"))) 

		local tmp1: display %4.1f `v'_`x'_t[2, 1]/`v'_`x'_ts[1,1]*100 
		local tmp2: display %4.1f `v'_`x'_t[2, 2]/`v'_`x'_ts[1,2]*100 
		local tmp3: display %4.1f `v'_`x'_t[2, 3]/`v'_`x'_ts[1,3]*100 

		putdocx table a`x'(`row', 2) = (`v'_`x'_t[2, 1]), halign(right) 
		putdocx table a`x'(`row', 2) = (" (" + "`tmp1'" + "%)"), halign(right) append

		putdocx table a`x'(`row', 3) = (`v'_`x'_t[2, 2]), halign(right) 
		putdocx table a`x'(`row', 3) = (" (" + "`tmp2'" + "%)"), halign(right) append

		putdocx table a`x'(`row', 4) = (`v'_`x'_t[2, 3]), halign(right)
		putdocx table a`x'(`row', 4) = (" (" + "`tmp3'" + "%)"), halign(right) append

		putdocx table a`x'(`row', 5) = (r(chi2)), nformat(%6.2f) halign(right)
		putdocx table a`x'(`row', 6) = (cond(r(p)<0.001, "<0.001", string(r(p)))), nformat(%8.3f) halign(right)
	}
}

local date: display %dCYND date("`c(current_date)'", "DMY")
putdocx save "R:/QResearch/Tics/analysis/outputs/outcome_chi2_results_`date'", replace




frames reset
exit
