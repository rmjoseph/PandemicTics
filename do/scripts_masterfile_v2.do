** Created 2022-01-10 by Rebecca Joseph, University of Nottingham
*************************************
* Name:	scripts_masterfile.do
* Creator:	RMJ
* Date:	20220110
* Desc:	All data preparation and analysis scripts for tics project
* Requires: Stata 17
* Version History:
*	Date	Reference	Update
*	20220110	scripts_masterfile	Create file
*	20220110	scripts_masterfile	Add code to import medical and product dicts
*	20220526	scripts_masterfile	Save _v2 after preparing for upload
*************************************

**# set up environment
frames reset
set more off
cd "FILE PATH" // SPECIFY WORKING DIRECTORY HERE
pwd

**# log file
capture log close masterlog
local date: display %dCYND date("`c(current_date)'", "DMY")
log using "logs/Masterfile_`date'.txt", text append name(masterlog)

**# import some key files
import delimited "data_raw/202201_Lookups_CPRDAurum/202201_EMISMedicalDictionary.txt", stringcol(_all)
save data_prepared/medical, replace
clear

import delimited "data_raw/202201_Lookups_CPRDAurum/202201_EMISProductDictionary.txt", stringcol(_all)
save data_prepared/product, replace
clear



**# Data extraction
*do "do/linkage_eligibility2.do" // list of people to add to linkage request 



**# Data preparation
do "do/prep_eligibilityanddates.do" // define follow-up dates and make tic flag
do "do/prep_extractcodedrecords.do" // extract info for comorbidities and ethnicity
do "do/prep_defineethnicity.do" // define ethnicity
do "do/prep_diagnosesatindex.do" // define other covars wrt index
do "do/prep_combinevars.do" // combine variables, inc. IMD
do "do/prep_ticstimeseries.do" // format for monthly rates



**# Analysis
// para 1 (eligible cohort definition, counts & follow-up, top-level descriptions)
do "do/analysis_participantcounts"	// results paragraph 1 (cohort definition)
do "do/analysis_tabgroups.do" // short file outputting numbers of people with tics each year by group

// Table 1 (comparison of characteristics wrt tic date, also by age-sex group)
do "do/analysis_comparison.do" 
do "do/analysis_comparison_outcomes_chi2.do" 

// Table 2, Yearly incidence rates (all groups, all time periods, all years)
do "do/analysis_yearlyrates.do"	// table showing incidence rates by age/sex/year

// Table 3, Poisson regression with interactions
do "do/analysis_poisson.do"

// Figure 1, monthly incidence rates
do "do/analysis_rates_graph.do"



**# other useful scripts
*do "do/export_codelists.do"
*do "do/codelist_StressDissociativeSomatoformDisorders.do" // code to help browse for relevant Read codes



**# Close
frames reset
log close masterlog
exit
