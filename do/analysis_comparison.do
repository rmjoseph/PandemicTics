* Created 2022-02-15 by Rebecca Joseph at the University of Nottingham
*************************************
* Name:	analysis_comparison
* Creator:	RMJ
* Date:	20220215
* Desc:	Comparison of people according to when they first had a tic
* Version History:
*	Date	Reference	Update
*	20220215	analysis_comparison	create file
*	20220216	analysis_comparison	Experimenting with putdocx
*	20220324	analysis_comparison	Editing to update to new end date (Nov 2021) and exclude people with no sex recorded [RHJ]
*									ORIGINAL TABLE NOW NOT RUNNING, have added new version that works
*	20220412	analysis_comparison	Editing text to expand follow-up to end December 2021 [RHJ]
*	20220526	analysis_comparison	Restored original table (still runs for me!) but retained new in case [RMJ]
*	20220526	analysis_comparison	Add annotations
*************************************

version 17.0
frames reset

** Start putdocx commands, setting formatting choices
putdocx begin, pagesize(A4) font(arial) pagenum(decimal) footer(npage)
putdocx paragraph, tofooter(npage)
putdocx pagenumber


** Intro paragraph text box (now superceded)
putdocx paragraph, style(Heading1)
putdocx text ("Results")

use data_prepared/cohortwithdates.dta
count if tic==1
local tic = `r(N)'
count if sex==.
local sex_nk = `r(N)'
count if sex==. & tic==1
local sex_nk_tic = `r(N)'
count if sex!=.
local pop_known_sex = `r(N)'
count

putdocx textblock begin
Between 01 January 2015 and 31 December 2021, <<dd_docx_display: %9.0fc `r(N)'>>
 people aged 4 to 18 years met the study inclusion criteria. 
 Of these, <<dd_docx_display: %6.0fc `tic'>> had a first tic record during study follow-up. 
putdocx textblock end


** Continuing intro paragraph, adding details about number of tics/number of males etc
frame create comparison
frame change comparison
use data_prepared/prepared_comparison.dta, clear 
drop if sex==.

count if sex==0
local male = `r(N)'

count
local tic = `r(N)'

summarize agefirst,d

putdocx textblock append
<<dd_docx_display: %3.0fc `sex_nk'>> people did not have a sex recorded, and of these, 
putdocx textblock end

if (`sex_nk_tic'==1) {
    putdocx text ("one person ")
	}
else if (`sex_nk_tic'==0) {
    putdocx text ("none ")
}
else if {
	putdocx text (`sex_nk_tic' " people ")
	}
	
putdocx textblock append 
had a first tic recorded during the study period.  These people were excluded from further analysis, leaving <<dd_docx_display: %9.0fc `pop_known_sex'>> people in the study, and <<dd_docx_display: %6.0fc `tic'>> 
with a first tic record during the study follow-up.  Overall, <<dd_docx_display: %5.0fc `male'>> (<<dd_docx_display: %4.1f 100*`male'/`tic'>>%) people with a tic record were male and the median age at first tic record was <<dd_docx_display: `r(p50)'>> years (interquartile range <<dd_docx_display: `r(p25)'>> to <<dd_docx_display: `r(p75)'>> years).
putdocx textblock end

putdocx textblock begin
The characteristics of people with a first tic recorded in 2015 to 2019, in 2020, and in 2021 are shown in Table 1.
putdocx textblock end



** Comparison table
putdocx paragraph
putdocx text ("Table 1 Characteristics on date of first tic record"), bold

table (var) (yeargrp), nototals ///
	stat(fvfrequency agegrp sex ethnicity region imd adhd anxiety autism depression eatingdisorder ocd selfharm somatoform stressreaction) ///
	stat(fvpercent agegrp sex ethnicity region imd adhd anxiety autism depression eatingdisorder ocd selfharm somatoform stressreaction) ///
	nformat(%9.1f fvpercent)

collect style row stack, nobinder 
collect style cell border_block, border(right, pattern(nil))
collect style cell result[fvpercent], sformat("%s%%")
collect label levels result fvfrequency "N", modify
collect label levels result fvpercent "%", modify

collect layout (agegrp sex[1] region ethnicity imd adhd[1] anxiety[1] autism[1] depression[1] eatingdisorder[1] ocd[1] selfharm[1] somatoform[1] stressreaction[1]) (yeargrp#result)

*collect layout (var) (yeargrp#result)	// alternative in case above doesn't run

collect preview

putdocx collect


** Save the prepared word doc
local date: display %dCYND date("`c(current_date)'", "DMY")
putdocx save outputs/comparison_table_`date', replace


frames reset
exit
