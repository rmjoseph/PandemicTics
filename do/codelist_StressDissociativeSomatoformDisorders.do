** Created 2021-12-08 by Rebecca Joseph, University of Nottingham
*************************************
* Name:	codelist_StressDissociativeSomatoformDisorders.do
* Creator:	RMJ
* Date:	20211208
* Desc:	Applying search terms to dictionary to start making these code lists
* Requires: Stata 17
* Version History:
*	Date	Reference	Update
*	20211208	codelist_StressDissociativeSomatoformDisorders	Create file
*	20220526	codelist_StressDissociativeSomatoformDisorders	Move to project folder and update file path
*************************************

frames reset

**# F43 Reaction to severe stress, and adjustment disorders
/*
F43	Reaction to severe stress, and adjustment disorders
F43.0	Acute stress reaction
F43.1	Post-traumatic stress disorder
F43.2	Adjustment disorders
F43.8	Other reactions to severe stress
F43.9	Reaction to severe stress, unspecified
*/
use "data_prepared/medical.dta"

replace cleansed = originalreadcode if cleansed==""
keep medcodeid term cleansedreadcode

replace term=lower(term)
replace term=strtrim(term)
replace term=stritrim(term)

format term %60s
sort cleansedreadcode

order term, after(cleansed)

gen acutestress1=regexs(0) if regexm(term,"stress|combat fatigue|crisis reaction|crisis state|psychic shock|traumatic neurosis|culture shock|grief reaction|hospitalism|ptsd|adjustment disorder")==1

gen acutestress2=regexs(0) if regexm(cleansedreadcode,"^E28|^E29|^Eu43")==1
bro if acutestress2!=""


**# F44 Dissociative [conversion] disorders
/*
F44	Dissociative [conversion] disorders
F44.0	Dissociative amnesia
F44.1	Dissociative fugue
F44.2	Dissociative stupor
F44.3	Trance and possession disorders
F44.4	Dissociative motor disorders
F44.5	Dissociative convulsions
F44.6	Dissociative anaesthesia and sensory loss
F44.7	Mixed dissociative [conversion] disoders
F44.8	Other dissociatve [conversion] disorders
F44.9	Dissociative [conversion] disoder, unspecified
*/

gen dissociative1=regexs(0) if regexm(term,"conversion|dissociative|hysteria|hysterical psychosis|psychogenic|trance|fugue|stupor|amnesia|ganser|multiple personality")==1

bro if dissociative1!=""

gen dissociative2=regexs(0) if regexm(cleansedreadcode,"^E201|^Eu44")==1
bro if dissociative2!=""



**# F45 Somatoform disorders
/*
F45	Somatoform disorders
F45.0	Somatization disorder
F45.1	Undifferentiated somatoform disorder
F45.2	Hypochondriacal disorder
F45.3	Somatoform autonomic dysfunction
F45.4	Persistent somatoform pain disorder
F45.8	Other somatoform disorders
F45.9	Somatoform disorder, unspecified
*/

gen somatoform1=regexs(0) if regexm(term,"briquet|psychosomatic|somatoform|somatization|somatisation|hypochondriac|dysmorphic|hypochondriasis|nosophobia|cardiac neurosis|da costa|gastric neurosis|neurocirculatory asthenia|psychogenic|psychalgia")==1

bro if somatoform1!=""

gen somatoform2=regexs(0) if regexm(cleansedreadcode,"^E207|^E20y|^E26|^E278|^Eu45")==1
bro if somatoform2!=""

bro if regexm(cleansed,"^E20")==1

**# all
egen any=rownonmiss(acutestress1-somatoform2), strok
keep if any>0

drop if regexm(cleansed,"^[0,3-7]")==1

order medcodeid cleansed term acutestress1 dissociative1 somatoform1
bro



frames reset