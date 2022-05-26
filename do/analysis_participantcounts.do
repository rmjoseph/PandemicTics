** Created 2022-05-03 by Rebecca Joseph, University of Nottingham
*************************************
* Name:	analysis_participantcounts.do
* Creator:	RMJ
* Date:	20220503
* Desc:	Writes to a word document the flow of people in the study & outputs a paragraph for the results
* Requires: Stata 17
* Version History:
*	Date	Reference	Update
*	20220503	new file	Create file
*************************************


**# Set up scalars containing values of interest 
frames reset
use if eligiblefup==1 using "data_prepared/eligibilityflags_allpats.dta"
merge 1:1 patid using "data_prepared/cohortwithdates.dta", keepusing(sex fupstart fupend tic) nogen
merge 1:1 patid using "data_prepared/prepared_comparison.dta", keepusing(agefirsttic) nogen

keep if eligiblefup==1
count
scalar def sc_elig1 = string(`r(N)',"%12.0gc") // eligible age and follow-up

count if eligibletic==0
scalar def sc_excl1 = string(`r(N)',"%12.0gc") // drop if first tic record before study entry
drop if eligibletic==0

count if sex==.
scalar def sc_excl2 = string(`r(N)',"%12.0gc") // drop if sex was unrecorded or unclassified
drop if sex==.

count
scalar def sc_elig2 = string(`r(N)',"%12.0gc") // final study population

gen fup = (fupend-fupstart + 1)/365.25
egen sumfup = sum(fup)
scalar def sc_fup = string(sumfup[1],"%12.0gc") // total follow-up

keep if tic==1
count
scalar def sc_tics = string(`r(N)',"%12.0gc") // number of tics

count if sex==0
scalar def sc_male = string(`r(N)', "%12.0gc") + " (" + string(100*`r(N)'/_N,"%5.1fc") + "%)"

sum agefirsttic,d
scalar def sc_agemed = string(`r(p50)', "%12.0gc")
scalar def sc_ageiqr = string(`r(p25)', "%12.0gc") + " to " + string(`r(p75)', "%12.0gc") 




**# Write bullet points of counts
putdocx begin, pagesize(A4) font(calibri, 11) pagenum(decimal) footer(npage)
putdocx paragraph, tofooter(npage)
putdocx pagenumber

putdocx paragraph, style(Heading1)
putdocx text ("Definition of study population")

putdocx paragraph
putdocx text ("Number of people with eligible follow-up and aged 4 to 18 years between 01 January 2015 and 31 December 2021: ")
putdocx text (sc_elig1)

putdocx paragraph
putdocx text ("Number of people excluded for having a tic record before study entry: ")
putdocx text (sc_excl1)

putdocx paragraph
putdocx text ("Number of people excluded for having missing or unclassified sex information: ")
putdocx text (sc_excl2)

putdocx paragraph
putdocx text ("Final study population: ")
putdocx text (sc_elig2)

putdocx paragraph
putdocx text ("Total follow-up (note this is stop-start+1 for all): ")
putdocx text (sc_fup)
putdocx text (" years")

putdocx paragraph
putdocx text ("Number of people with a first tic record during the study period: ")
putdocx text (sc_tics)





**# Write a paragraph to begin results
putdocx paragraph, style(Heading1)
putdocx text ("Results paragraph 1")
putdocx paragraph
putdocx text ("Between 01 January 2015 and 31 December 2021, ")
putdocx text (sc_elig1)
putdocx text (" people aged 4 to 18 years had eligible follow-up within CPRD. After excluding ")
putdocx text (sc_excl1)
putdocx text (" people who had a tic record before study entry and ")
putdocx text (sc_excl2)
putdocx text (" people with missing or unclassified sex information, the final study population was ")
putdocx text (sc_elig2)
putdocx text (" people. Over a total of ")
putdocx text (sc_fup)
putdocx text (" person-years of follow-up, ")
putdocx text (sc_tics)
putdocx text (" people had a first tic record during the study window.")

putdocx text (" Overall, ")
putdocx text (sc_male)
putdocx text (" people with a tic record were male and the median age at first tic record was ")
putdocx text (sc_agemed)
putdocx text (" years (interquartile range ")
putdocx text (sc_ageiqr)
putdocx text (" years).")






putdocx save outputs/studypopulationdef, replace

frames reset
exit
