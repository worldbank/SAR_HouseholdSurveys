/*------------------------------------------------------------------------------
SARMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	BGD_2022_HIES_v01_M_v01_A_SARMD_IND.do		</_Program name_>
<_Application_>    	STATA 17.0									<_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		</_Author(s)_>
<_Date created_>   	06-2023										</_Date created_>
<_Date modified>   	June 2023									</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	BGD											</_Country_>
<_Survey Title_>   	HIES										</_Survey Title_>
<_Survey Year_>    	2022										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				06-2023
File:				BGD_2022_HIES_v01_M_v01_A_SARMD_IND.do
First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         	"BGD"
local year         	"2022"
local survey       	"HIES"
local vm           	"01"
local va          	"01"
glo   module       "IND"
local yearfolder   "`code'_`year'_`survey'"
local SARMDfolder  "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
*</_Program setup_>

*<_Folder creation_>
*
*</_Folder creation_>


*<_Datalibweb request_>

* HOUSEHOLD ROSTER
tempfile hh_roster
*datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_1A.dta) clear 
use "$rootdatalib\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\HH_SEC_1A.dta", clear
duplicates report PSU HHID
sort  PSU HHID
save `hh_roster', replace

* INDIVIDUAL ROSTER
tempfile ind_roster
*datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_1A1.dta) clear 
use "$rootdatalib\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\HH_SEC_1A1.dta", clear
duplicates report PSU HHID S1AQ00
gen   PID = S1AQ00
sort  PSU HHID PID
save `ind_roster', replace

* EMPLOYMENT INFORMATION
tempfile employment
*datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_1B.dta) clear 
use "$rootdatalib\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\HH_SEC_1B.dta", clear
duplicates report PSU HHID S1BQ00
gen   PID = S1BQ00
sort  PSU HHID PID
save `employment', replace

* EDUCATION
tempfile education
*datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_2A.dta) clear 
use "$rootdatalib\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\HH_SEC_2A.dta", clear
duplicates tag PSU HHID S2AQ00, gen(tag)
drop if S2AQ00==.
gen   PID = S2AQ00
sort  PSU HHID PID
save `education', replace
/*
. unique PSU HHID
Number of unique values of PSU HHID is  14386
Number of records is  56583
*/

* EDUCATION 2
tempfile education2
*datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_2B.dta) clear 
use "$rootdatalib\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\HH_SEC_2B.dta", clear
duplicates tag PSU HHID S2BQ00, gen(tag)
drop if S2BQ00==.
gen   PID = S2BQ00
sort  PSU HHID PID
save `education2', replace
/*
 unique PSU HHID
Number of unique values of PSU HHID is  14376
Number of records is  56538
*/

* ECONOMIC ACTIVITIES
tempfile economic_act
*datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_4A.dta) clear //proposal 13152 hhid 21,772 obs
use "$rootdatalib\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\HH_SEC_4A.dta", clear
duplicates report PSU HHID 
*sort  PSU HHID PID //change
sort  PSU HHID 
save `economic_act', replace

* WEIGHTS
tempfile weights
*datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(weight_final_2022.dta) clear 
use "$rootdatalib\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\weight_final_2022.dta", clear
duplicates report PSU HHID
sort  PSU HHID
save `weights', replace

* HOUSING INFORMATION (DWELLING)
tempfile housing
*datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_6A.dta) clear 
use "$rootdatalib\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\HH_SEC_6A.dta", clear
duplicates report PSU HHID
sort  PSU HHID
save `housing', replace

* LIVESTOCK
tempfile livestock
*datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_7C1.dta) clear 
use "$rootdatalib\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\HH_SEC_7C1.dta", clear
keep PSU HHID S7C1Q00 S7C1Q02A
duplicates drop PSU HHID S7C1Q00, force
rename S7C1Q02A item_
drop if S7C1Q00==.
reshape wide item_, j(S7C1Q00) i(PSU HHID)
replace item_201 = 1		if  item_201>1 & item_201<.
replace item_204 = 1		if  item_204>1 & item_204<.
replace item_205 = 1		if  item_205>1 & item_205<.
duplicates report PSU HHID
sort  PSU HHID
save `livestock', replace

* DURABLE GOODS
tempfile durables
*datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_9E.dta) clear 
use "$rootdatalib\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\HH_SEC_9E.dta", clear
keep PSU HHID S9EQ00 S9EQ01
rename  S9EQ00 item_
replace S9EQ01=999 	if  S9EQ01==.
reshape wide S9EQ01, i(PSU HHID) j(item_) 
duplicates report PSU HHID
rename S9EQ01* item_* 
sort  PSU HHID
save `durables', replace

* * VARIABLES FROM (INC-SARMD) MODULE
tempfile INC
use "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_SARMD_INC.dta", clear 
drop  countrycode year wgt weighttype hhid pid
sort  PSU HHID PID
save `INC', replace
*/

/*
****************************************************************************************************
cd "D:\Dropbox2\datalib\SARMD\WORKINGDATA\BGD\BGD_2022_HIES\BGD_2022_HIES_v01_M\Data\Stata"

* HOUSEHOLD ROSTER
tempfile hh_roster
use "HH_SEC_1A.dta", clear
duplicates report PSU HHID
sort  PSU HHID
save `hh_roster', replace

* INDIVIDUAL ROSTER
tempfile ind_roster
use "HH_SEC_1A1.dta", clear
duplicates report PSU HHID S1AQ00
gen   PID = S1AQ00
sort  PSU HHID PID
save `ind_roster', replace

* EMPLOYMENT INFORMATION
tempfile employment
use "HH_SEC_1B.dta", clear
duplicates report PSU HHID S1BQ00
gen   PID = S1BQ00
sort  PSU HHID PID
save `employment', replace

* EDUCATION
tempfile education
use "HH_SEC_2A.dta", clear
duplicates tag PSU HHID S2AQ00, gen(tag)
drop if S2AQ00==.
gen   PID = S2AQ00
sort  PSU HHID PID
save `education', replace

* EDUCATION 2
tempfile education2
use "HH_SEC_2B.dta", clear
duplicates tag PSU HHID S2BQ00, gen(tag)
drop if S2BQ00==.
gen   PID = S2BQ00
sort  PSU HHID PID
save `education2', replace

* WEIGHTS
tempfile weights
use "weight_final_2022.dta", clear
duplicates report PSU HHID
sort  PSU HHID
save `weights', replace

* HOUSING
tempfile housing
use "HH_SEC_6A.dta", clear
duplicates report PSU HHID
sort  PSU HHID
save `housing', replace

* LIVESTOCK
tempfile livestock
use "HH_SEC_7C1.dta", clear
keep PSU HHID S7C1Q00 S7C1Q02A
duplicates drop PSU HHID S7C1Q00, force
rename S7C1Q02A item_
drop if S7C1Q00==.
reshape wide item_, j(S7C1Q00) i(PSU HHID)
replace item_201 = 1		if  item_201>1 & item_201<.
replace item_204 = 1		if  item_204>1 & item_204<.
replace item_205 = 1		if  item_205>1 & item_205<.
duplicates report PSU HHID
sort  PSU HHID
save `livestock', replace

* DURABLE GOODS
tempfile durables
use "HH_SEC_9E.dta", clear
keep PSU HHID S9EQ00 S9EQ01
rename  S9EQ00 item_
replace S9EQ01=999 	if  S9EQ01==.
reshape wide S9EQ01, i(PSU HHID) j(item_) 
duplicates report PSU HHID
rename S9EQ01* item_* 
sort  PSU HHID
save `durables', replace

* VARIABLES FROM (INC-SARMD) MODULE
tempfile INC
use "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\BGD_2022_HIES_v01_M_v01_A_SARMD_INC.dta", clear
drop  countrycode year wgt hhid pid
sort  PSU HHID PID
save `INC', replace
*/

* Merge raw modules
use `hh_roster', clear
merge 1:1 PSU HHID using `weights'
drop _merge
sort  PSU HHID
merge 1:1 PSU HHID using `housing'
drop _merge
sort  PSU HHID
merge 1:1 PSU HHID using `durables'
drop _merge
sort  PSU HHID
merge 1:1 PSU HHID using `livestock'
drop _merge
sort  PSU HHID
merge 1:m PSU HHID using `ind_roster'
drop _merge
sort  PSU HHID PID
merge 1:1 PSU HHID PID using `education'
drop _merge
sort  PSU HHID PID
merge 1:1 PSU HHID PID using `education2'
drop _merge
sort  PSU HHID PID
merge 1:1 PSU HHID PID using `employment'
drop _merge
sort  PSU HHID PID
merge 1:1 PSU HHID PID using `INC'
drop _merge
sort  PSU HHID PID
*</_Datalibweb request_>


* COUNTRYCODE
*<_countrycode_> 
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
gen countrycode = "`code'"  
*</_countrycode_>

* CODE
*<_code_> //proposal
gen code = "`code'"  
*</_code_>

* YEAR
*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
gen year = `year'  //proposal
*</_year_>

* SURVEY NAME
*<_survey_>
*<_survey_note_> Survey acronym *</_survey_note_>
gen str survey = "`survey'"
label var survey "Household Income and Expenditure Survey"
*</_survey_>

* HARMONIZATION VERSION
*<_veralt_>
*<_veralt_note_> Harmonization version *</_veralt_note_>
gen veralt = "`va'"
*</_veralt_>

* MASTER VERSION
*<_vermast_>
*<_vermast_note_> Master version *</_vermast_note_>
gen vermast = "`vm'"
*</_vermast_>

* INTERVIEW YEAR
*<_int_year_>
*<_int_year_note_> Interview Year *</_int_year_note_>
gen int_year = 2022
*</_int_year_>

* INTERVIEW MONTH
*<_int_month_>
*<_int_month_note_> Interview Month *</_int_month_note_>
*<_int_month_note_> 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December" *</_int_month_note_>
gen byte int_month = .
label define int_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
label values int_month int_month
*</_int_month_>


* MONTH
clonevar month = int_month

* HOUSEHOLD IDENTIFIER
*<_idh_>
*<_idh_note_> Household identifier  *</_idh_note_>
notes  idh: household identifiers in raw data are variables PSU HHID
clonevar hhid = idh
notes hhid: household identifiers in raw data are variables PSU HHID
*</_idh_>

* HOUSEHOLD IDENTIFIER - RAW DATA VARIABLES
*<_idh_orig_>
*<_idh_orig_note_> Household identifier variables in the raw data are PSU and HHID *</_idh_org_note_>
gen idh_orig = "PSU HHID"
clonevar idh_org = idh_orig
*</_idh_orig_>

* PERSONAL IDENTIFIER
*<_idp_>
*<_idp_note_> Personal identifier  *</_idp_note_>
notes idp: individual identifier (within household) in raw data is variable PID
clonevar pid = idp
notes pid: individual identifier (within household) in raw data is variable PID
*</_idp_>

* PERSONAL IDENTIFIER - RAW DATA VARIABLES
*<_idp_orig_>
*<_idp_orig_note_> Personal identifier variables in the raw data depends on the module *</_idp_org_note_>
gen idp_orig = "PSU HHID PID"
clonevar idp_org = idp_orig
*</_idp_orig_>

*<_wgt_>
*<_wgt_note_> Household weight  *</_wgt_note_>
/*<_wgt_note_> Survey specific information *</_wgt_note_>*/
clonevar wgt = hh_wgt 
clonevar weight = hh_wgt 
clonevar finalweight = hh_wgt 
*</_wgt_>

*<_psu_>
*<_psu_note_> Primary sampling units *</_psu_note_>
gen psu = PSU
*</_psu_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
/*<_strata_note_> Survey specific information *</_strata_note_>*/
*<_strata_note_>  *</_strata_note_>
gen strata = domain16
*</_strata_>

gen weighttype = "PW"

****************************************************************
**** GEOGRAPHICAL VARIABLES
****************************************************************

*<_urban_>
*<_urban_note_> uban/rural *</_urban_note_>
/*<_urban_note_> Urban or rural location of households *</_urban_note_>*/
*<_urban_note_> 0 "Rural"  1 "Urban"  *</_urban_note_>
gen 	urban = .
replace urban = 0	if  urbrural==1
replace urban = 1	if  urbrural==2
*</_urban_>

*<_subnatid1_>
*<_subnatid1_note_> Subnational ID - highest level *</_subnatid1_note_>
/*<_subnatid1_note_> Subnational id - subnational regional identifiers at which survey is representative - highest level *</_subnatid1_note_>*/
*<_subnatid1_note_>  *</_subnatid1_note_>
gen 	subnatid1 = "."
replace subnatid1 = "1 - Barisal"		if  ID_01_CODE==10
replace subnatid1 = "2 - Chittagong"		if  ID_01_CODE==20
replace subnatid1 = "3 - Dhaka"			if  ID_01_CODE==30
replace subnatid1 = "4 - Khulna"			if  ID_01_CODE==40
replace subnatid1 = "5 - Mymensingh"		if  ID_01_CODE==45
replace subnatid1 = "6 - Rajshahi"		if  ID_01_CODE==50
replace subnatid1 = "7 - Rangpur"		if  ID_01_CODE==55
replace subnatid1 = "8 - Sylhet"			if  ID_01_CODE==60
notes subnatid1: Division Level
*</_subnatid1_>

*<_subnatid2_>
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>
/*<_subnatid2_note_> Subnational id - subnational regional identifiers at which survey is representative - second highest level *</_subnatid2_note_>*/
*<_subnatid2_note_>  *</_subnatid2_note_>
gen 	subnatid2 = "."
replace subnatid2 = " 1 - Barisal rural" 	if  domain16==1
replace subnatid2 = " 2 - Barisal urban" 	if  domain16==2
replace subnatid2 = " 3 - Chittagong rural" 	if  domain16==3
replace subnatid2 = " 4 - Chittagong urban" 	if  domain16==4
replace subnatid2 = " 5 - Dhaka rural" 		if  domain16==5
replace subnatid2 = " 6 - Dhaka urban" 		if  domain16==6
replace subnatid2 = " 7 - Khulna rural" 		if  domain16==7
replace subnatid2 = " 8 - Khulna urban" 		if  domain16==8
replace subnatid2 = " 9 - Mymensingh rural" 	if  domain16==9
replace subnatid2 = "10 - Mymensingh urban" 	if  domain16==10
replace subnatid2 = "11 - Ragshashi rural" 	if  domain16==11
replace subnatid2 = "12 - Ragshashi urban" 	if  domain16==12
replace subnatid2 = "13 - Rangpur rural" 	if  domain16==13
replace subnatid2 = "14 - Rangpur urban" 	if  domain16==14
replace subnatid2 = "15 - Sylhet rural" 		if  domain16==15
replace subnatid2 = "16 - Sylhet urban" 		if  domain16==16
notes subnatid2: Division by urban and rural Level
*</_subnatid2_>


*<_subnatid3_>
*<_subnatid3_note_>  Subnational ID - third highest level *</_subnatid3_note_>
/*<_subnatid3_note_> Subnational id - subnational regional identifiers at which survey is representative - third highest level *</_subnatid3_note_>*/
*<_subnatid3_note_>  *</_subnatid3_note_>
gen   subnatid3 = ""
notes subnatid3: the survey does not have a smaller level of representativeness than division by urban and rural
*</_subnatid3_>   



****************************************************************
**** DWELLING CHARACTERISTICS
****************************************************************



*<_ownhouse_>
*<_ownhouse_note_> SARMD ownhouse variable *</_ownhouse_note_>
/*<_ownhouse_note_> Refers to ownership status of the dwelling unit by the household residing in it. 
                    Raw Data variable is S6AQ28: what is your present occupancy status? *</_ownhouse_note_>*/
*<_ownhouse_note_>  1 "Ownership/secure rights" 2 "Renting" 3 "Provided for free" 4 "Without permission" *</_ownhouse_note_>
gen byte ownhouse = .
replace ownhouse = 1 		if  S6AQ28==1					/* S6AQ28 = 1 = Own			*/
replace ownhouse = 2 		if  S6AQ28==2					/* S6AQ28 = 2 = Rented		*/
replace ownhouse = 3 		if  S6AQ28==3					/* S6AQ28 = 3 = Rent Free 	*/
*</_ownhouse_>

*<_typehouse_>
*<_typehouse_note_> GMD ownhouse variable *</_typehouse_note_>
*<_typehouse_note_> typehouse brought in from GMD *</_typehouse_note_>
clonevar typehouse = ownhouse
*</_typehouse_>


*<_water_orig_>
*<_water_orig_note_> Source of Drinking Water-Original from raw file *</_water_orig_note_>
/*<_water_orig_note_> Original categories from source of drinking water *</_water_orig_note_>*/
*<_water_orig_note_>  *</_water_orig_note_>
gen 	water_orig = "."
replace water_orig = " 1 - Pipes in the house"					if  S6AQ09==1
replace water_orig = " 2 - Pipes in the yard"					if  S6AQ09==2
replace water_orig = " 3 - Pipes in the neighbords house"		if  S6AQ09==3
replace water_orig = " 4 - Government tap/permanent tap"			if  S6AQ09==4
replace water_orig = " 5 - Tubewell"								if  S6AQ09==5
replace water_orig = " 6 - Protected well/Idara"					if  S6AQ09==6
replace water_orig = " 7 - Unprotected well/Idara"				if  S6AQ09==7
replace water_orig = " 8 - Safe shower"							if  S6AQ09==8
replace water_orig = " 9 - Unprotected shower"					if  S6AQ09==9
replace water_orig = "10 - Collected rainwater"					if  S6AQ09==10
replace water_orig = "11 - Tanker-truck"							if  S6AQ09==11
replace water_orig = "12 - Small tank or drum car"				if  S6AQ09==12
replace water_orig = "13 - Water kiosk plant"					if  S6AQ09==13
replace water_orig = "14 - Surface water"						if  S6AQ09==14
replace water_orig = "15 - Bottled water"						if  S6AQ09==15
replace water_orig = "16 - Small packaged water"					if  S6AQ09==16
replace water_orig = "99 - Other"								if  S6AQ09==99
*</_water_orig_>

*<_water_jmp_>
*<_water_jmp_note_> Source of drinking water, using Joint Monitoring Program categories *</_water_jmp_note_>
/*
/*<_water_jmp_note_> Variable taking categories based on JMP guidelines. This variable is created from question asking about main source of drinking water. Ambigous categories are classified as missing/other *</_water_jmp_note_>*/
*<_wate_jmp_note_> 1 "Piped into dwelling" 2 "Piped into compound, yard or plot" 3 "Public tap/standpipe" 4 "Tubewell, Borehole" 5 "Protected well" 6 "Unprotected well" 7 "Protected spring" 8 "Unprotected spring" 9 "Rain water" 10 "Tanker-truck or other vendor" 11 "Cart with small tank/drum" 12 "Surface water (river, stream, dam, lake, pond) 13 "Bottled water" 14 "Other" *</_wate_jmp_note_>
*/
gen 	water_jmp = .
replace water_jmp = 1		if  S6AQ09==1
replace water_jmp = 2		if  S6AQ09==2 | S6AQ09==3
replace water_jmp = 3		if  S6AQ09==4
replace water_jmp = 4		if  S6AQ09==5
replace water_jmp = 5		if  S6AQ09==6

replace water_jmp = 6		if  S6AQ09==7
replace water_jmp = 9		if  S6AQ09==10
replace water_jmp = 10		if  S6AQ09==11
replace water_jmp = 11		if  S6AQ09==12 
replace water_jmp = 12		if  S6AQ09==14
replace water_jmp = 13		if  S6AQ09==15 | S6AQ09==16
replace water_jmp = 14		if  S6AQ09==8  | S6AQ09==9 | S6AQ09==99
replace water_jmp = 15		if  S6AQ09==13
notes water_jmp: Other (water_jmp=14) includes: "safe shower" + "unprotected shower" + "other"
notes water_jmp: Bottled Water (water_jmp=13) includes: "bottled water" + "small packaged water"
*</_water_jmp_>

*<_piped_water_>
*<_piped_water_note_> Household has access to piped water *</_piped_water_note_>
/*<_piped_water_note_> Variable takes the value of 1 if household has access to piped water. *</_piped_water_note_>*/
*<_piped_water_note_>  1 "Yes" 0 "No" *</_piped_water_note_>
gen 	piped_water = .
replace piped_water = 0		if  S6AQ09>=1 & S6AQ09<=99
replace piped_water = 1		if  S6AQ09>=1 & S6AQ09<=5		
*</_piped_water_>

*<_sar_improved_water_>
*<_sar_improved_water_note_> Improved source of drinking water-using country-specific definitions *</_sar_improved_water_note_>
/*<_sar_improved_water_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_sar_improved_water_note_>*/
*<_sar_improved_water_note_>  1 "Yes" 0 "No" *</_sar_improved_water_note_>
gen  	sar_improved_water = .
replace sar_improved_water = 1	if (water_jmp>=1 & water_jmp<=5) | water_jmp==7 | water_jmp==9
replace sar_improved_water = 0	if  water_jmp==6 | water_jmp==8 | (water_jmp>=10 & water_jmp<=14)
*</_sar_improved_water_>

*<_improved_water_>
*<_improved_water_note_> Improved source of drinking water-using country-specific definitions *</_improved_water_note_>
/*<_improved_water_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_improved_water_note_>*/
*<_improved_water_note_>  1 "Yes" 0 "No" *</_improved_water_note_>
gen improved_water = sar_improved_water
*</__improved_water_>

*<_toilet_orig_>
*<_toilet_orig_note_> sanitation facility original *</_toilet_orig_note_>
/*<_toilet_orig_note_> Original categories from access to toilet *</_toilet_orig_note_>*/
*<_toilet_orig_note_>  *</_toilet_orig_note_>
gen     toilet_orig = "."
replace toilet_orig = " 1 - Flush removal to through the pipe to the sewer system"	if  S6AQ07==1
replace toilet_orig = " 2 - Flush and hold in safe tank"								if  S6AQ07==2
replace toilet_orig = " 3 - Flush and hold in safe pit (pit latrine)"					if  S6AQ07==3
replace toilet_orig = " 4 - Flush removal in open drain"								if  S6AQ07==4
replace toilet_orig = " 5 - I dont know where it is removed by flush"					if  S6AQ07==5
replace toilet_orig = " 6 - Ventilated improved pit (VIP) latrine"					if  S6AQ07==6
replace toilet_orig = " 7 - Pit latrine with slab"									if  S6AQ07==7
replace toilet_orig = " 8 - Slabless pit latrine/open pit"							if  S6AQ07==8
replace toilet_orig = " 9 - Composting toilet"										if  S6AQ07==9
replace toilet_orig = "10 - Bucket"													if  S6AQ07==10
replace toilet_orig = "11 - Open/Hanging latrine"										if  S6AQ07==11
replace toilet_orig = "12 - No latrine/Bush/Field"									if  S6AQ07==12
replace toilet_orig = "99 - Other"													if  S6AQ07==99
*</_toilet_orig_>

*<_sewage_toilet_>
*<_sewage_toilet_note_> Household has access to sewage toilet *</_sewage_toilet_note_>
/*<_sewage_toilet_note_> Variable takes the value of 1 if household has access to sewage toilet. *</_sewage_toilet_note_>*/
*<_sewage_toilet_note_>  1 "Yes" 0 "No" *</_sewage_toilet_note_>
gen     sewage_toilet = .
replace sewage_toilet = 0		if  S6AQ07>=1 & S6AQ07<=99
replace sewage_toilet = 1		if  S6AQ07==1					/* S6AQ07 = 1 = Flush removal through the pipe to the sewer system	*/ 	
*</_sewage_toilet_>

*<_toilet_jmp_>
*<_toilet_jmp_note_> Access to sanitation facility-using Joint Monitoring Program categories *</_toilet_jmp_note_>
/*<_toilet_jmp_note_> Variable taking categories based on JMP guidelines. This variable is created from question asking about toilet type. Ambigous categories are classified as missing/other *</_toilet_jmp_note_>*/
*<_toilet_jmp_note_> 1 "Flush to piped sewer system" 2 "Flush to septic tank" 3 "Flush to pit latrine" 4 "Flush to somewhere else" 5 "Flush, don't know where" 6 "Ventilated improved pit latrine" 7 "Pit latrine with slab" 8 "Pit latrine without slab/open pit" 9 "Composting toilet" 10 "Bucket toilet" 11 "Hanging toilet/Hanging latrine" 12 "No facility/bush/field" 13 "Other" *</_toilet_jmp_note_>
gen 	toilet_jmp = .
replace toilet_jmp = S6AQ07
replace toilet_jmp = 13		if  toilet_jmp==99
*</_toilet_jmp_>

*<_sar_improved_toilet_>
*<_sar_improved_toilet_note_> Improved type of sanitation facility-using country-specific definitions *</_sar_improved_toilet_note_>
/*<_sar_improved_toilet_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_sar_improved_toilet_note_>*/
*<_sar_improved_toilet_note_>  1 "Yes" 0 "No" *</_sar_improved_toilet_note_>
gen 	sar_improved_toilet = .
replace sar_improved_toilet = 1	if (toilet_jmp>=1 & toilet_jmp<=3) | toilet_jmp==6 | toilet_jmp==7 | toilet_jmp==9
replace sar_improved_toilet = 0	if  toilet_jmp==4 | toilet_jmp==5 | (toilet_jmp>=8 & toilet_jmp<=13)
replace sar_improved_toilet = 0	if  S6AQ08==1
*</_sar_improved_toilet_>

*<_improved_sanitation_>
*<_improved_sanitation_note_> Improved type of sanitation facility-using country-specific definitions *</_improved_sanitation_note_>
/*<_improved_sanitation_note_> Dummy variable: 1=improved, 0=unimproved source following JMP guidelines *</_improved_sanitation_note_>*/
*<_improved_sanitation_note_>  1 "Yes" 0 "No" *</_improved_sanitation_note_>
clonevar improved_sanitation = sar_improved_toilet
*</_improved_sanitation_>

*<_electricity_>
*<_electricity_note_> Access to electricity *</_electricity_note_>
/*<_electricity_note_> Refers to Public or quasi public service availability of electricity from mains. 
Note that having an electrical connection says nothing about the actual electrical service received by the household in a given country or area.
This variable must have the same value for all members of the household *</_electricity_note_>*/
*<_electricity_note_> 1 "Yes" 0 "No" *</_electricity_note_>
gen 	electricity = .
replace electricity = 0		if  S6AQ18>=1 & S6AQ18<=99
replace electricity = 1		if  S6AQ18==1
*</_electricity_>

*<_lphone_>
*<_lphone_note_> Household has landphone *</_lphone_note_>
/*<_lphone_note_> Availability of landphones in household. Question on quantity or specific availability should be present *</_lphone_note_>*/
*<_lphone_note_>  1 "Yes" 0 "No" *</_lphone_note_>
gen 	lphone = .
replace lphone = 0			if  S6AQ26==2
replace lphone = 1			if  S6AQ26==1
*</_lphone_>

*<_cellphone_>
*<_cellphone_note_> Own mobile phone (at least one) *</_cellphone_note_>
/*<_cellphone_note_> Refers to cell phone availability in the household.
This variable is only constructed if there is an explicit question about cell phones availability.
This variable must have the same value for all members of the household. *</_cellphone_note_>*/
*<_cellphone_note_>  1 "Yes" 0 "No" *</_cellphone_note_>
egen aux_cellphone = min(S1AQ10), by(hhid)
gen 	cellphone = .
replace cellphone = 1		if  aux_cellphone==1
replace cellphone = 0		if  aux_cellphone==2
drop aux_cellphone
*</_cellphone_>

*<_computer_>
*<_computer_note_> Own Computer *</_computer_note_>
/*<_computer_note_> Presence of a computer. Refers to actual ownership of the asset irrespective of who owns it within the household and regardless of what condition the asset is in. 
This variable is only constructed if there is an explicit question about computer *</_computer_note_>*/
*<_computer_note_>  1 "Yes" 0 "No" *</_computer_note_>
gen 	computer = .
replace computer = 0			if  S6AQ27==2
replace computer = 1			if  S6AQ27==1 | item_1017==1 | item_1018==1
*</_computer_>

*<_internet_>
*<_internet_note_>  Internet connection *</_internet_note_>
/*<_internet_note_> Availability of internet connection. Refers to internet connection availability at home irrespective of who owns it within the household. 
This variable is only constructed if there is an explicit question about internet connection. 
This variab *</_internet_note_>*/
*<_internet_note_>  1 "Yes" 0 "No" *</_internet_note_>
gen   internet = .
notes internet: there is not an explicit question about Internet connection in the survey (although there is a question about availability of wifi router)
*</_internet_>



****************************************************************
**** DEMOGRAPHIC CHARACTERISTICS
****************************************************************

*<_hsize_>
*<_hsize_note_> Household size *</_hsize_note_>
/*<_hsize_note_> specifies varname for the household size number in the data file. It has to be compatible with the numbers of national and international poverty at household size when weights are used in any computation *</_hsize_note_>*/
*<_hsize_note_>  *</_hsize_note_>
gen aux_size = round(pop_wgt/hh_wgt)
gen 	hsize = .
replace hsize = aux_size
notes hsize: variable was defined as the ratio between the population weight and the household weight
*</_hsize_>

*<_pop_wgt_>
*<_pop_wgt_note_> Population weight *</_pop_wgt_note_>
/*<_pop_wgt_note_> Survey specific information *</_pop_wgt_note_>*/
*<_pop_wgt_note_>  *</_pop_wgt_note_>
rename pop_wgt pop_wgt_hies
gen pop_wgt = pop_wgt_hies
*</_pop_wgt_>

*<_relationcs_>
*<_relationcs_note_> Relationship to head of household country/region specific *</_relationcs_note_>
/*<_relationcs_note_> country or regionally specific categories *</_relationcs_note_>*/
*<_relationcs_note_>  1 "Head of the household" 2 "Wife/Husband" 3 "Son/Daughter" 4 "Parents of head of the household/spouse" 5 "Other Relative" 6 "Domestic Servant/Driver/Watcher" 7 "Boarder" 9 "Other" *</_relationcs_note_>
gen		relationcs = "."
replace relationcs = "1 - Head of the household"						if  S1AQ02==1 
replace relationcs = "2 - Wife/Husband"								if  S1AQ02==2 
replace relationcs = "3 - Son/Daughter"								if  S1AQ02==3 
replace relationcs = "4 - Parents of the head of household/spouse"	if  S1AQ02==6 | S1AQ02==9
replace relationcs = "5 - Other relative"							if  S1AQ02==4 | S1AQ02==5 | S1AQ02==7 | S1AQ02==8 | S1AQ02==10 | S1AQ02==11
replace relationcs = "6 - Domestic servant/Driver/Watcher"			if  S1AQ02==12 | S1AQ02==13
replace relationcs = "9 - Other"										if  S1AQ02==99
*</_relationcs_>

*<_relationharm_>
*<_relationharm_note_> Relationship to head of household harmonized across all regions *</_relationharm_note_>
/*<_relationharm_note_> Harmonized categories across all regions. *</_relationharm_note_>*/
*<_relationharm_note_>  1 "Head" 2 "Spouse" 3 "Child" 4 "Parents" 5 "Other relative" 6 "Non-relative" *</_relationharm_note_>
gen 	relationharm = .
replace relationharm = 1		if  S1AQ02==1 
replace relationharm = 2		if  S1AQ02==2 
replace relationharm = 3		if  S1AQ02==3 
replace relationharm = 4		if  S1AQ02==6 
replace relationharm = 5		if (S1AQ02>=4 & S1AQ02<=11) & S1AQ02!=6 
replace relationharm = 6		if  S1AQ02==12 | S1AQ02==13 
notes relationharm: there 137 observations with missing values, they correspond to code = 99 ("other")
*</_relationharm_>

*<_male_>
*<_male_note_> Sex of household member (male=1) *</_male_note_>
/*<_male_note_> specifies varname for sex of household member (head), where 1 = Male and 0 = Female. *</_male_note_>*/
*<_male_note_>  1 " Male" 0 "Female" *</_male_note_>
gen 	male = .
replace male = 0		if  S1AQ01==2
replace male = 1		if  S1AQ01==1
*</_male_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
/*<_age_note_> Age is an important variable for most socio-economic analysis and must be established as accurately as possible. Especially for children aged less than 5 years, this is used to interpret Anthropometrics data. Ages >= 98 must be coded as 98.  (N *</_age_note_>*/
*<_age_note_>  *</_age_note_>
gen 	age = S1AQ03
replace age = 98		if  age==99
*</_age_>

*<_soc_>
*<_soc_note_> Social group *</_soc_note_>
/*<_soc_note_> Classification by religion.
The classification is country specific.
It not needs to be present for every country/year. *</_soc_note_>*/
*<_soc_note_>  1 "Islam" 2 "Hindu" 3 "Buddhist" 4 "Christian" *</_soc_note_>
gen 	soc = "."
replace soc = "1 - Islam"		if  S1AQ04==1
replace soc = "2 - Hindu"		if  S1AQ04==2
replace soc = "3 - Buddhist"		if  S1AQ04==3
replace soc = "4 - Christian"	if  S1AQ04==4
*</_soc_>

*<_marital_>
*<_marital_note_> Marital status *</_marital_note_>
/*<_marital_note_> Do not impute.  Calculate only for those to whom the question was asked (in other words, the youngest age at which information is collected may differ depending on the survey). Living together includes common-law marriages, union coutumiere, uni *</_marital_note_>*/
*<_marital_note_>  1 "Married" 2 "Never married" 3 "Living together" 4 "Divorced/Separated" 5 "Widowed" *</_marital_note_>
gen 	marital = .
replace marital = 1			if  S1AQ05==1
replace marital = 2 			if  S1AQ05==2
replace marital = 4 			if  S1AQ05==4 | S1AQ05==5
replace marital = 5 			if  S1AQ05==3
notes marital: variable defined for individuals aged 10 and older
*</_marital_>

*<_rbirth_juris_>
*<_rbirth_juris_note_>  Region of Birth Jurisdiction *</_rbirth_juris_note_>
/*<_rbirth_juris_note_> Variable is constructed for all persons administered this module in each questionnaire.  It identifies the level at which region of birth is coded in the survey  *</_rbirth_juris_note_>*/
*<_rbirth_juris_note_>  *</_rbirth_juris_note_>
gen   rbirth_juris = .
notes rbirth_juris: HIES does not collect the information needed to define this variable
*</_rbirth_juris_>

*<_rbirth_>
*<_rbirth_note_>  Region of Birth *</_rbirth_note_>
/*<_rbirth_note_> Corresponds to reg01 if rbirth_juris=1, reg02 if rbirth_juris=2, reg03 if rbirth_juris=3, ISO 3166-1 if rbirth_juris=5, and original code if rbirth_juris=9 *</_rbirth_note_>*/
*<_rbirth_note_>  *</_rbirth_note_>
gen   rbirth = .
notes rbirth: HIES does not collect the information needed to define this variable
*</_rbirth_>

*<_rprevious_juris_>
*<_rprevious_juris_note_>  Region of previous residence *</_rprevious_juris_note_>
/*<_rprevious_juris_note_> Variable is constructed for all persons administered this module in each questionnaire.  It identifies the level at which previous region is coded in the survey  *</_rprevious_juris_note_>*/
*<_rprevious_juris_note_>  *</_rprevious_juris_note_>
gen   rprevious_juris = .
notes rprevious_juris: HIES does not collect the information needed to define this variable
*</_rprevious_juris_>

*<_rprevious_>
*<_rprevious_note_>  Region Previous Residence *</_rprevious_note_>
/*<_rprevious_note_> Corresponds to reg01 if rprevious_juris=1, reg02 if rprevious_juris=2, reg03 if rprevious_juris=3, ISO 3166-1 if rprevious_juris=5, and original code if rbitrh_juris=9 *</_rprevious_note_>*/
*<_rprevious_note_>  *</_rprevious_note_>
gen   rprevious = .
notes rprevious: HIES does not collect the information needed to define this variable
*</_rprevious_>

*<_yrmove_>
*<_yrmove_note_>  Year of most recent move *</_yrmove_note_>
/*<_yrmove_note_> Indicates year of most recent move from rprevious *</_yrmove_note_>*/
*<_yrmove_note_>  *</_yrmove_note_>
gen   yrmove = .
notes yrmove: HIES does not collect the information needed to define this variable
*</_yrmove_>



****************************************************************
**** EDUCATION VARIABLES
****************************************************************

*<_ed_mod_age_>
*<_ed_mod_age_note_> Education module application age *</_ed_mod_age_note_>
/*<_ed_mod_age_note_> Age at which the education module starts being applied *</_ed_mod_age_note_>*/
*<_ed_mod_age_note_>  *</_ed_mod_age_note_>
gen ed_mod_age = 5
notes ed_mod_age: the education module is applied to all persons 5 years and above
*</_ed_mod_age_>

*<_literacy_>
*<_literacy_note_> Individual can read and write *</_literacy_note_>
/*<_literacy_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff at which information is collected will vary from country to country. Value must be missing for all others. No imputatio *</_literacy_note_>*/
*<_literacy_note_>  1 "Yes" 0 "No" *</_literacy_note_>
gen 	literacy = .
replace literacy = 0		if  S2AQ01==2 | S2AQ02==2
replace literacy = 1		if  S2AQ01==1 & S2AQ02==1
*</_literacy_>

*<_atschool_>
*<_atschool_note_> Attending school *</_atschool_note_>
/*<_atschool_note_> Variable is constructed for all persons administered this module in each questionnaire, typically of primary age and older.  For this reason the lower age cutoff will vary from country to country. 
If person on short school holiday when intervie *</_atschool_note_>*/
*<_atschool_note_>  1 "Yes" 0 "No" *</_atschool_note_>
gen 	atschool = .
replace atschool = 0		if  S2BQ01==2
replace atschool = 1		if  S2BQ01==1
*</_atschool_>

*<_educy_>
*<_educy_note_> Years of education *</_educy_note_>
/*<_educy_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff at which information is collected will vary from country to country. 
This is a continuous variable of the number of years of formal schooling completed *</_educy_note_>*/
*<_educy_note_>  *</_educy_note_>
gen 	educy = .
replace educy = 0 			if  S2AQ01==2
replace educy = 0			if  S2AQ03==2
replace educy = S2AQ04		if  S2AQ04>=0 & S2AQ04<.
replace educy = 12			if  S2AQ04==11
replace educy = 14			if  S2AQ04==12
replace educy = 16			if  S2AQ04==13
replace educy = 16			if  S2AQ04==15
replace educy = 19			if  S2AQ04==16
replace educy = S2BQ03 		if  educy==.  & S2BQ03!=.
replace educy = educy-1 		if  S2AQ04==. & S2BQ03<=11 & S2BQ03!=.
recode  educy (10 = 11) (15 = 15) (18 = 17) (16 = 18) (17 = 16) (12 = 13) (14 = 13) (13 = 15) (19 = .) (21 = .) if  S2AQ04==. & S2BQ03!=.
replace educy = 0 			if  educy==-1
replace educy = . 			if  educy==50
replace educy = . 			if  age<ed_mod_age
replace educy = . 			if  educy>age & educy!=. & age!=.
notes   educy: it is not possible to identify how many years of education has been completed after secondary education
/*check: https://www.winona.edu/socialwork/Media/Prodhan%20The%20Educational%20System%20in%20Bangladesh%20and%20Scope%20for%20Improvement.pdf*/
*</_educy_>

*<_educat7_>
*<_educat7_note_> Level of education 7 categories *</_educat7_note_>
/*<_educat7_note_> Secondary is everything from the end of primary to before tertiary (for example, grade 7 through 12). Vocational training is country-specific and will be defined by each region.  *</_educat7_note_>*/
*<_educat7_note_>  1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Post secondary but not university" 7 "University" *</_educat7_note_>
gen	 	educat7 = .
replace educat7 = 1		if  S2AQ03==2  | S2AQ04==0
replace educat7 = 2		if  S2AQ04>=1  & S2AQ04<=4
replace educat7 = 3		if  S2AQ04==5  & atschool==0
replace educat7 = 4		if  S2AQ04==5  & atschool==1
replace educat7 = 4		if  S2AQ04>=6  & S2AQ04<=10
replace educat7 = 5		if  S2AQ04>=11 & S2AQ04<=12 & atschool==0
replace educat7 = 6		if  S2AQ04>=11 & S2AQ04<=12 & atschool==1
replace educat7 = 7		if  S2AQ04>=13 & S2AQ04<=14
replace educat7 = 6		if  S2AQ04>=11 & S2AQ04<=12 & atschool==1 & S2BQ03>=13 & S2BQ03<=14
replace educat7 = 7		if  S2AQ04>=11 & S2AQ04<=12 & atschool==1 & S2BQ03>=15 & S2BQ03<=18
replace educat7 = 7		if  S2AQ04>=15 & S2AQ04<=18
*</_educat7_>

*<_educat5_>
*<_educat5_note_> Level of education 5 categories *</_educat5_note_>
/*<_educat5_note_> At least educat4 will have to be included (if it is unclear whether primary or secondary is completed or not). If educat5 is available, educat4 can be created. Secondary is everything from the end of primary to before tertiary (for example, grad *</_educat5_note_>*/
*<_educat5_note_>  1 "No education" 2 "Primary incomplete" 3 "Primary complete but Secondary incomplete" 4 "Secondary complete" 5 "Tertiary (completed or incomplete)" *</_educat5_note_>
recode educat7 (1=1) (2=2) (3 4=3) (5=4) (6 7=5), gen(educat5)
label define lbleducat5 1 "No education" 2 "Primary incomplete" 3 "Primary complete but secondary incomplete" 4 "Secondary complete" 5 "Some tertiary/post-secondary"
label values educat5 lbleducat5
label var educat5 "Level of education 5 categories"
*</_educat5_>

*<_educat4_>
*<_educat4_note_> Level of education 4 categories *</_educat4_note_>
/*<_educat4_note_> At least educat4 will have to be included (if it is unclear whether primary or secondary is completed or not). If educat5 is available, educat4 can be created. Secondary is everything from the end of primary to before tertiary (for example, grad *</_educat4_note_>*/
*<_educat4_note_>  1 "No education" 2 "Primary (complete or incomplete)" 3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)" *</_educat4_note_>
recode educat7 (1=1) (2 3=2) (4 5=3) (6 7=4), gen(educat4)
label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" 3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
label values educat4 lbleducat4
label var educat4 "Level of education 4 categories"
*</_educat4_>

*<_everattend_>
*<_everattend_note_> Ever attended school *</_everattend_note_>
/*<_everattend_note_> All persons of primary school age or above. `Primary school age’ will vary by country. 
This is country-specific and depends on how school attendance is defined. Pre-school is not included here. Also, in some countries, ever attended is yes  *</_everattend_note_>*/
*<_everattend_note_>  1 "Yes" 0 "No" *</_everattend_note_>
gen 	everattend = .
replace everattend = 0	if  S2AQ03==2
replace everattend = 1	if  S2AQ03==1
replace everattend = 1	if  atschool==1
*</_everattend_>

foreach v of varlist educat7 educat5 educat4 educy atschool literacy everattend { 
	replace `v'=. if age<ed_mod_age 
}



****************************************************************
**** LABOR VARIABLES
****************************************************************

*<_lb_mod_age_>
*<_lb_mod_age_note_> Labor module application age *</_lb_mod_age_note_>
/*<_lb_mod_age_note_> Age at which the labor module starts being applied (working age: people at which can start legally working) *</_lb_mod_age_note_>*/
*<_lb_mod_age_note_>  *</_lb_mod_age_note_>
gen   lb_mod_age = 5
notes lb_mod_age: the employment module is applied to all persons 5 years and above
*</_lb_mod_age_>

*<_lstatus_>
*<_lstatus_note_> Labor Force Status *</_lstatus_note_>
/*<_lstatus_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. 
All persons are co *</_lstatus_note_>*/
*<_lstatus_note_>  1 "Employed" 2 "Unemployed" 3 "Not in labor force" *</_lstatus_note_>
gen 	lstatus = .
replace lstatus = 1		if  S1BQ01==1 | S1BQ02==1 | S1BQ03==1 | S1BQ04==1
replace lstatus = 2		if  S1BQ05==1 | S1BQ06==1 | S1BQ07==1 | S1BQ07==4 | S1BQ08==1
replace lstatus = 3		if  S1BQ08==2
notes   lstatus: period of reference is last 7 days for employment, last 30 days for unemployment and inactivity

*<_empstat_>
*<_empstat_note_>  Employment status - main job - last 7 days *</_empstat_note_>
/*<_empstat_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Definitions taken from the ILO’s Classification of Status in Employment with some revisions to take into account the data available. Classifies the main job employment status of any individual with a job (lstatus=1) and is missing otherwise.  
Paid employee includes anyone whose basic remuneration is not directly dependent on the revenue of the unit they work for, typically remunerated by wages and salaries but may be paid for piece work or in-kind. The ‘continuous’ criteria used in the ILO definition is not used here as data are often absent and due to country specificity. 
Non paid employee includes contributing family workers are those workers who hold a self-employment job in a market-oriented establishment operated by a related person living in the same households who cannot be regarded as a partner because of their degree of commitment to the operation of the establishment, in terms of working time or other factors, is not at a level comparable to that of the head of the establishment. 
Employer is a business owner (whether alone or in partnership) with employees. If the only people working in the business are the owner and ‘contributing family workers, the person is not considered an employer (as has no employees) and is, instead classified as own account. 
Own account or self-employment includes jobs are those where remuneration is directly dependent from the goods and service produced (where home consumption is considered to be part of the profits) and have not engaged any permanent employees to work for them on a continuous basis during the reference period. 
Members of producers’ cooperatives are workers who hold a self-employment job in a cooperative producing goods and services in which each member takes part on an equal footing with other members in determining the organization of production, sales and/or other work of the establishment, the investments and the distribution of the proceeds of the establishment amongst the members. 
Other, workers not classifiable by status include those for whom insufficient relevant information is available and/or who cannot be included in any of the preceding categories. *</_empstat_note_>*/
*<_empstat_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_note_>
gen   empstat = .
notes empstat: HIES does not collect information on employment status for the main job in the last 7 days
*</_empstat_>

*<_occup_>
*<_occup_note_> 1 digit occupational classification - main job - last 7 days *</_occup_note_>
/*<_occup_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any indiviudal with a job (lstatus=1) and is missing otherwise. The classification is based on the International Standard Classification of Occupations (ISCO) 88. In the case of different classifications re-coding has been done to best match the ISCO-88. *</_occup_note_>*/
*<_occup_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified" *</_occup_note_>
gen   occup = .a
notes occup: HIES does not collect information on occupational status for the main job in the last 7 days
*</_occup_>

gen   occup_2 = .
notes occup_2: HIES does not collect information on occupational status for the main job in the last 7 days

*<_ocusec_>
*<_ocusec_note_>  Sector of activity - main job - last 7 days *</_ocusec_note_>
/*<_ocusec_note_> Variable is constructed for all persons administered this module in each questionnaire. Classifies the main job's sector of activity of any individual with a job (lstatus=1) and is missing otherwise. Public sector includes non-governmental organizations and armed forces. Private sector is that part of the economy which is both run for private profit and is not controlled by the state. State owned includes para-statal firms and all others in which the government has control (participation over 50%). *</_ocusec_note_>*/
*<_ocusec_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_note_>
gen   ocusec = .
notes ocusec: HIES does not collect information on sector of activity for the main job in the last 7 days
*</_ocusec_>

*<_nlfreason_>
*<_nlfreason_note_> Reason not in the labor force *</_nlfreason_note_>
/*<_nlfreason_note_> This variable is constructed for all those who are not presently employed and are not looking for work (lstatus=3) and missing otherwise.
Student, the person is studying. 
Housekeeping is the person takes care of the house, older people, or chil *</_nlfreason_note_>*/
*<_nlfreason_note_> 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Others" *</_nlfreason_note_>
gen 	nlfreason = .
replace nlfreason = 1	if  S1BQ09==1
replace nlfreason = 2	if  S1BQ09==2
replace nlfreason = 4	if  S1BQ09==3
replace nlfreason = 3	if  S1BQ09==4
replace nlfreason = 5	if  S1BQ09==5 | S1BQ09==6 | S1BQ09==7 | S1BQ09==9
notes   nlfreason: = 1 includes "in educational institution/training"
notes   nlfreason: = 2 includes "family responsabilities"
notes   nlfreason: = 3 includes "too old/retired"
notes   nlfreason: = 4 includes "sick/injured/disabled"
notes   nlfreason: = 5 includes "too young" + "recession season" + "not willing to work" + "others"
notes   nlfreason: period of reference is the last 30 days
*</_nlfreason_>

*<_industry_orig_>
*<_industry_orig_note_> Original industry codes - main job - last 7 days *</_industry_orig_note_>
/*<_industry_orig_note_>  *</_industry_orig_note_>*/
*<_industry_orig_note_>   *</_industry_orig_note_>
gen   industry_orig = .
notes industry_orig: HIES does not collect information on sector of employment (industry) in the last 7 days
*</_industry_orig_>

*<_industry_>
*<_industry_note_> 1 digit industry classification - main job - last 7 days *</_industry_note_>
/*<_industry_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any individual with a job (lstatus=1) and is missing otherwise. The codes for the main job are given here based on the UN-ISIC (Rev. 3.1). The main categories subsume the following codes: 1 = Agriculture, Hunting, Fishing and Forestry 2 = Mining 3 = Manufacturing 4 = Electricity and Utilities 5 = Construction 6 = Commerce 7 = Transportation, Storage and Communication 8 = Financial, Insurance and Real Estate 9 = Public Administration 10 = Other Services. In the case of different classifications, recoding has been done to best match the ISIC-31 codes. Code 10 is also assigned for unspecified categories or items. *</_industry_note_>*/
*<_industry_note_>  *</_industry_note_>
gen 	industry = .
notes   industry: HIES does not collect information on sector of employment (industry) in the last 7 days
*</_industry_>

*<_industry_orig_2_>
*<_industry_orig_2_note_> Original industry codes - second job - last 7 days *</_industry_orig_2_note_>
/*<_industry_orig_2_note_> This variable correspond to whatever is in the original file with no recoding *</_industry_orig_2_note_>*/
*<_industry_orig_2_note_>  *</_industry_orig_2_note_>
gen   industry_orig_2 = .
notes industry_orig_2: HIES does not collect information on sector of employment (industry) in the last 7 days
*</_industry_orig_2_>

*<_empstat_2_>
*<_empstat_2_note_>  Employment status - second job - last 7 days *</_empstat_2_note_>
/*<_empstat_2_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Definitions taken from the ILO’s Classification of Status in Employment with some revisions to take into account the data available. Classifies the main job employment status of any individual with a job (lstatus=1) and is missing otherwise.  
Paid employee includes anyone whose basic remuneration is not directly dependent on the revenue of the unit they work for, typically remunerated by wages and salaries but may be paid for piece work or in-kind. The ‘continuous’ criteria used in the ILO definition is not used here as data are often absent and due to country specificity. 
Non paid employee includes contributing family workers are those workers who hold a self-employment job in a market-oriented establishment operated by a related person living in the same households who cannot be regarded as a partner because of their degree of commitment to the operation of the establishment, in terms of working time or other factors, is not at a level comparable to that of the head of the establishment. 
Employer is a business owner (whether alone or in partnership) with employees. If the only people working in the business are the owner and ‘contributing family workers, the person is not considered an employer (as has no employees) and is, instead classified as own account. 
Own account or self-employment includes jobs are those where remuneration is directly dependent from the goods and service produced (where home consumption is considered to be part of the profits) and have not engaged any permanent employees to work for them on a continuous basis during the reference period. 
Members of producers’ cooperatives are workers who hold a self-employment job in a cooperative producing goods and services in which each member takes part on an equal footing with other members in determining the organization of production, sales and/or other work of the establishment, the investments and the distribution of the proceeds of the establishment amongst the members. 
Other, workers not classifiable by status include those for whom insufficient relevant information is available and/or who cannot be included in any of the preceding categories. *</_empstat_2_note_>*/
*<_empstat_2_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_2_note_>
gen   empstat_2 = .
notes empstat_2: HIES does not collect information on employment status for the secondary job in the last 7 days
*</_empstat_2_>

*<_empstat_2_year_>
*<_empstat_2_year_note_>  Employment status - second job - last 12 months *</_empstat_2_year_note_>
/*<_empstat_2_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Definitions taken from the ILO’s Classification of Status in Employment with some revisions to take into account the data available. Classifies the main job employment status of any individual with a job (lstatus=1) and is missing otherwise.  
Paid employee includes anyone whose basic remuneration is not directly dependent on the revenue of the unit they work for, typically remunerated by wages and salaries but may be paid for piece work or in-kind. The ‘continuous’ criteria used in the ILO definition is not used here as data are often absent and due to country specificity. 
Non paid employee includes contributing family workers are those workers who hold a self-employment job in a market-oriented establishment operated by a related person living in the same households who cannot be regarded as a partner because of their degree of commitment to the operation of the establishment, in terms of working time or other factors, is not at a level comparable to that of the head of the establishment. 
Employer is a business owner (whether alone or in partnership) with employees. If the only people working in the business are the owner and ‘contributing family workers, the person is not considered an employer (as has no employees) and is, instead classified as own account. 
Own account or self-employment includes jobs are those where remuneration is directly dependent from the goods and service produced (where home consumption is considered to be part of the profits) and have not engaged any permanent employees to work for them on a continuous basis during the reference period. 
Members of producers’ cooperatives are workers who hold a self-employment job in a cooperative producing goods and services in which each member takes part on an equal footing with other members in determining the organization of production, sales and/or other work of the establishment, the investments and the distribution of the proceeds of the establishment amongst the members. 
Other, workers not classifiable by status include those for whom insufficient relevant information is available and/or who cannot be included in any of the preceding categories. *</_empstat_2_year_note_>*/
*<_empstat_2_year_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_2_year_note_>
egen aux2 = rsum(month_nonagri_2 agri_net_2), missing

gen 	empstat_2_year = .
replace empstat_2_year = 1		if  w_cat_2==1 | w_cat_2==4
replace empstat_2_year = 3		if  w_cat_2==3
replace empstat_2_year = 4 		if  w_cat_2==2
replace empstat_2_year = 4 		if  empstat_2_year==. & aux2!=.
notes   empstat_2_year: we include as self-employed to all those with information on agricultural or non-agricultural income, but without employment information
drop aux*
*</_empstat_2_year_>

*<_wage_>
*<_wage_note_>  Last wage payment *</_wage_note_>
/*<_wage_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) will vary from country to country. States the main job's wage earner of any individual (lstatus=1 & empstat<=4) and is missing otherwise. Wage from main job. This excludes tips, bonuses, and other payments. For all those with self-employment or owners of own businesses, this should be net revenues (net of all costs EXCEPT for tax payments) or the amount of salary taken from the business. Due to the almost complete lack of information on taxes, the wage from main job is NOT net of taxes. By definition non-paid employees (empstat=2) should have wage=0. *</_wage_note_>*/
*<_wage_note_> *</_wage_note_>
egen  wage = rsum(daylab_cash_1 employee_cash_1 daylab_kind_1 employee_kind_1 agri_net_1 month_nonagri_1), missing
notes wage: average monthly labour income in the last 12 months in the main job
*</_wage_>

*<_industry_2_>
*<_industry_2_note_>  1 digit industry classification - second job - last 7 days *</_industry_2_note_>
/*<_industry_2_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country.
Classifies the seco *</_industry_2_note_>*/
*<_industry_2_note_>  *</_industry_2_note_>
gen 	industry_2 = .
notes   industry_2: HIES does not collect information on sector of employment (industry) in the last 7 days
*</_industry_2_>

*<_empstat_year_>
*<_empstat_year_note_>  Employment status - main job - last 12 months *</_empstat_year_note_>
/*<_empstat_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Definitions taken from the ILO’s Classification of Status in Employment with some revisions to take into account the data available. Classifies the main job employment status of any individual with a job (lstatus=1) and is missing otherwise.  
Paid employee includes anyone whose basic remuneration is not directly dependent on the revenue of the unit they work for, typically remunerated by wages and salaries but may be paid for piece work or in-kind. The ‘continuous’ criteria used in the ILO definition is not used here as data are often absent and due to country specificity. 
Non paid employee includes contributing family workers are those workers who hold a self-employment job in a market-oriented establishment operated by a related person living in the same households who cannot be regarded as a partner because of their degree of commitment to the operation of the establishment, in terms of working time or other factors, is not at a level comparable to that of the head of the establishment. 
Employer is a business owner (whether alone or in partnership) with employees. If the only people working in the business are the owner and ‘contributing family workers, the person is not considered an employer (as has no employees) and is, instead classified as own account. 
Own account or self-employment includes jobs are those where remuneration is directly dependent from the goods and service produced (where home consumption is considered to be part of the profits) and have not engaged any permanent employees to work for them on a continuous basis during the reference period. 
Members of producers’ cooperatives are workers who hold a self-employment job in a cooperative producing goods and services in which each member takes part on an equal footing with other members in determining the organization of production, sales and/or other work of the establishment, the investments and the distribution of the proceeds of the establishment amongst the members. 
Other, workers not classifiable by status include those for whom insufficient relevant information is available and/or who cannot be included in any of the preceding categories. *</_empstat_year_note_>*/
*<_empstat_year_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_year_note_>
egen aux1 = rsum(month_nonagri_1 agri_net_1), missing
gen 	empstat_year = .
replace empstat_year = 1			if  w_cat_1==1 | w_cat_1==4
replace empstat_year = 3			if  w_cat_1==3
replace empstat_year = 4 			if  w_cat_1==2
replace empstat_year = 4 			if  empstat_year==. & aux1!=.
notes   empstat_year: we include as self-employed to all those with information on agricultural or non-agricultural income, but without employment information
drop aux*
*</_empstat_year_>

*<_whours_>
*<_whours_note_>  Hours of work in last week *</_whours_note_>
/*<_whours_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any individual with a job (lstatus=1) and is missing otherwise. This is the number of hours worked in the last 7 days or the reference week in the person’s main job. Main job defined as that occupation to which the person dedicated more time. For persons absent from their job in the week preceding the survey due to holidays, vacation or sick leave, the time worked in the last week the person worked is recorded. For individuals who only give information on how many hours they work per day and no information on number of days worked a week, multiply the hours by 5 days. In the case of a question that has hours worked per month, divide by 4.2 to get weekly hours. *</_whours_note_>*/
*<_whours_note_>  *</_whours_note_>
gen     whours = hours_1/(12*4.2)
replace whours = .		if  whours>150
*</_whours_>

*<_wage_2_>
*<_wage_2_note_>  Last wage payment second job *</_wage_2_note_>
/*<_wage_2_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) will vary from country to country. States the second job's wage earner of any individual (lstatus=1 & empstat_2<=4) and is missing otherwise. Wage from second job. This excludes tips, bonuses, and other payments. For all those with self-employment or owners of own businesses, this should be net revenues (net of all costs EXCEPT for tax payments) or the amount of salary taken from the business.  Due to the almost complete lack of information on taxes, the wage from second job is NOT net of taxes. By definition non-paid employees (empstat_2=2) should have wage=0. *</_wage_2_note_>*/
*<_wage_2_note_> *</_wage_2_note_>
egen  wage_2 = rsum(daylab_cash_2 employee_cash_2 daylab_kind_2 employee_kind_2 agri_net_2 month_nonagri_2), missing
notes wage_2: average monthly labour income in the last 12 months in the second job
*</_wage_2_>

*<_njobs_>
*<_njobs_note_>  Number of total jobs *</_njobs_note_>
/*<_njobs_note_> Number of jobs besides the main one coming from main occupation *</_njobs_note_>*/
*<_njobs_note_>  *</_njobs_note_>
egen aux1 = rsum(daylab_cash_1 daylab_kind_1 employee_cash_1 employee_kind_1 month_nonagri_1 agri_net_1), missing
egen aux2 = rsum(daylab_cash_2 daylab_kind_2 employee_cash_2 employee_kind_2 month_nonagri_2 agri_net_2), missing
egen aux3 = rsum(daylab_cash_3 daylab_kind_3 employee_cash_3 employee_kind_3 month_nonagri_3 agri_net_3), missing
egen aux4 = rsum(daylab_cash_4 daylab_kind_4 employee_cash_4 employee_kind_4 month_nonagri_4 agri_net_4), missing

gen 	njobs = .
replace njobs = 1	if  aux1!=. | w_cat_1!=.
replace njobs = 2	if  aux2!=. | w_cat_2!=.
replace njobs = 3	if  aux3!=. | w_cat_3!=.
replace njobs = 4	if  aux4!=. | w_cat_4!=.
notes   njobs: period of reference is the last 12 months
drop aux*
*</_njobs_>

*<_firmsize_l_>
*<_firmsize_l_note_>  Firm size (lower bracket) *</_firmsize_l_note_>
/*<_firmsize_l_note_> Variable is constructed for all persons who are employed. If continuous records the number of people working for the same employer. If the variable is categorical it records the lower boundary of the bracket. *</_firmsize_l_note_>*/
*<_firmsize_l_note_>  *</_firmsize_l_note_>
gen   firmsize_l = .
notes firmsize_l: the HIES does not collect information on firm size
*</_firmsize_l_>

*<_firmsize_u_>
*<_firmsize_u_note_>  Firm size (upper bracket) *</_firmsize_u_note_>
/*<_firmsize_u_note_> Variable is constructed for all persons who are employed. If continuous records the number of people working for the same employer. If the variable is categorical it records the upper boundary of the bracket. *</_firmsize_u_note_>*/
*<_firmsize_u_note_>  *</_firmsize_u_note_>
gen   firmsize_u = .
notes firmsize_u: the HIES does not collect information on firm size
*</_firmsize_u_>

*<_unempldur_l_>
*<_unempldur_l_note_> Unemployment duration (months) lower bracket *</_unempldur_l_note_>
/*<_unempldur_l_note_> Variable is constructed for all persons who are unemployed (lstatus=2, otherwise missing). If continuous records the numbers of months in unemployment. If the variable is categorical it records the lower boundary of the bracket. *</_unempldur_l_note_>*/
*<_unempldur_l_note_>  *</_unempldur_l_note_>
gen   unempldur_l = .
notes unempldur_l: the HIES does not contain the information needed to define this variable
*</_unempldur_l_>

*<_unempldur_u_>
*<_unempldur_u_note_> Unemployment duration (months) upper bracket *</_unempldur_u_note_>
/*<_unempldur_u_note_> Variable is constructed for all persons who are unemployed (lstatus=2, otherwise missing). If continuous records the numbers of months in unemployment. If the variable is categorical it records the upper boundary of the bracket. If the right bra *</_unempldur_u_note_>*/
*<_unempldur_u_note_>  *</_unempldur_u_note_>
gen   unempldur_u = .
notes unempldur_u: the HIES does not contain the information needed to define this variable
*</_unempldur_u_>

*<_ocusec_year_>
*<_ocusec_year_note_>  Sector of activity - main job - last 12 months *</_ocusec_year_note_>
/*<_ocusec_year_note_> Variable is constructed for all persons administered this module in each questionnaire. Classifies the main job's sector of activity of any individual with a job (lstatus=1) and is missing otherwise. Public sector includes non-governmental organizations and armed forces. Private sector is that part of the economy which is both run for private profit and is not controlled by the state. State owned includes para-statal firms and all others in which the government has control (participation over 50%). *</_ocusec_year_note_>*/
*<_ocusec_year_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_year_note_>
gen     ocusec_year = .
replace ocusec_year = 1		if  S4BQ06_1==1 | S4BQ06_1==2 | S4BQ06_1==6
replace ocusec_year = 2		if  S4BQ06_1==3 | S4BQ06_1==5 | S4BQ06_1==7 | S4BQ06_1==8 | S4BQ06_1==9
replace ocusec_year = 3		if  S4BQ06_1==4
replace ocusec_year = 2		if  w_cat_1>=1 & w_cat_1<=3 & ocusec_year==.
*</_ocusec_year_>

*<_contract_>
*<_contract_note_>  Contract *</_contract_note_>
/*<_contract_note_> Variable is constructed for all persons administered this module in each questionnaire.  Indicates if a person has a signed (formal) contract, regardless of duration. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the contract status of any individual with a job (lstatus=1) and is missing otherwise. This variable is only constructed if there is an explicit question about contracts. *</_contract_note_>*/
*<_contract_note_>  1 "Yes" 0 "No" *</_contract_note_>
gen   contract = .
notes contract: HIES does not collect information on labour contract for the main job in the last 7 days
*</_contract_>

*<_healthins_>
*<_healthins_note_>  Health insurance *</_healthins_note_>
/*<_healthins_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the social security status of any individual with a job (lstatus=1) and is missing otherwise. This variable is only constructed if there is an explicit question about health security. *</_healthins_note_>*/
*<_healthins_note_>  1 "Yes" 0 "No" *</_healthins_note_>
gen   healthins = .
notes healthins: HIES does not collect information on health insurance from employment for the main job in the last 7 days
*</_healthins_>

*<_socialsec_>
*<_socialsec_note_>  Social security *</_socialsec_note_>
/*<_socialsec_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the social security status of any individual with a job (lstatus=1) and is missing otherwise. This variable is only constructed if there is an explicit question about pension plans or social security. *</_socialsec_note_>*/
*<_socialsec_note_>  1 "Yes" 0 "No" *</_socialsec_note_>
gen   socialsec = .
notes socialsec: HIES does not collect information on social security rights from employment for the main job in the last 7 days
*</_socialsec_>

*<_union_>
*<_union_note_> Union membership *</_union_note_>
/*<_union_note_> Variable is constructed for all persons administered this module in each questionnaire.  For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the union membership status of any individual with a job (lstatus=1) and is missing otherwise. This variable is only constructed if there is an explicit question about trade unions. *</_union_note_>*/
*<_union_note_> 1 "Yes" 0 "No" *</_union_note_>
gen   union = .
notes union: HIES does not collect information on union membership for the main job in the last 7 days
*</_union_>

*<_unitwage_>
*<_unitwage_note_>  Last wages time unit - main job *</_unitwage_note_>
/*<_unitwage_note_> Type of reference for the wage variable. States the main job's wage earner time unit measurement of any individual (lstatus=1 & empstat<=4) and is missing otherwise. *</_unitwage_note_>*/
*<_unitwage_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_note_>
gen   unitwage = 5			if  wage!=.
notes unitwage: variable WAGE was defined using a monthly basis
*</_unitwage_>

*<_unitwage_2_>
*<_unitwage_2_note_>  Last wages time unit - second job *</_unitwage_2_note_>
/*<_unitwage_2_note_> Type of reference for the wage variable. States the second job's wage earner time unit measurement of any individual (lstatus=1 & empstat_2<=4) and is missing otherwise. *</_unitwage_2_note_>*/
*<_unitwage_2_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_2_note_>
gen   unitwage_2 = 5			if  wage_2!=.
notes unitwage_2: variable WAGE_2 was defined using a monthly basis
*</_unitwage_2_>



****************************************************************
**** ASSETS
****************************************************************

*<_television_>
*<_television_note_> Household has television *</_television_note_>
/*<_television_note_> Availability of televisions in household. Question on quantity or specific availability should be present *</_television_note_>*/
*<_television_note_>  1 "Yes" 0 "No" *</_television_note_>
gen 	television = 0
replace television = 1  		if  item_1016==1 
*</_television_>

*<_radio_>
*<_radio_note_> Household has radio *</_radio_note_>
/*<_radio_note_> Availability of radios in household. Question on quantity or specific availability should be present *</_radio_note_>*/
*<_radio_note_>  1 "Yes" 0 "No" *</_radio_note_>
gen 	radio = .
notes radio: the survey does not have specific question on radio availability
*</_radio_>

*<_fan_>
*<_fan_note_> Household has fan *</_fan_note_>
/*<_fan_note_> Availability of fans in household. Question on quantity or specific availability should be present *</_fan_note_>*/
*<_fan_note_>  1 "Yes" 0 "No" *</_fan_note_>
gen 	fan = 0
replace fan = 1				if  item_1025==1
notes fan: the raw variable refers to "Fan (ceiling/table)"
*</_fan_>

*<_washingmachine_>
*<_washingmachine_note_> Household has washing machine *</_washingmachine_note_>
/*<_washingmachine_note_> Availability of washing machines in household. Question on quantity or specific availability should be present *</_washingmachine_note_>*/
*<_washingmachine_note_>  1 "Yes" 0 "No" *</_washingmachine_note_>
gen 	washingmachine = 0
replace washingmachine = 1  	if  item_1029==1 
*</_washingmachine_>

*<_sewingmachine_>
*<_sewingmachine_note_> Household has sewing machine *</_sewingmachine_note_>
/*<_sewingmachine_note_> Availability of sewing machines  in household. Question on quantity or specific availability should be present *</_sewingmachine_note_>*/
*<_sewingmachine_note_>  1 "Yes" 0 "No" *</_sewingmachine_note_>
gen 	sewingmachine = 0
replace sewingmachine = 1  	if  item_1036==1 
*</_sewingmachine_>

*<_refrigerator_>
*<_refrigerator_note_> Household has refrigerator *</_refrigerator_note_>
/*<_refrigerator_note_> Availability of refrigerator  in household. Question on quantity or specific availability should be present *</_refrigerator_note_>*/
*<_refrigerator_note_>  1 "Yes" 0 "No" *</_refrigerator_note_>
gen 	refrigerator = 0
replace refrigerator = 1  	if  item_1027==1 
notes refrigerator: the raw variable refers to "Refrigerator/Fridge"
*</_refrigerator_>

*<_bicycle_>
*<_bicycle_note_> Household has bicycle *</_bicycle_note_>
/*<_bicycle_note_> Availability of bicycle in household. Question on quantity or specific availability should be present *</_bicycle_note_>*/
*<_bicycle_note_>  1 "Yes" 0 "No" *</_bicycle_note_>
gen 	bicycle = 0
replace bicycle = 1  		if  item_1031==1 | item_1032==1 
notes bicycle: the raw variable includes "Rickshaw/Easy bicycle"
*</_bicycle_>

*<_motorcar_>
*<_motorcar_note_> Household has motorcar *</_motorcar_note_>
/*<_motorcar_note_> Availability of motorcars in household. Question on quantity or specific availability should be present *</_motorcar_note_>*/
*<_motorcar_note_>  1 "Yes" 0 "No" *</_motorcar_note_>
gen 	motorcar = 0
replace motorcar = 1  		if  item_1034==1 
*</_motorcar_>

*<_motorcycle_>
*<_motorcycle_note_> Household has motorcycle *</_motorcycle_note_>
/*<_motorcycle_note_> Availability of motor cycles (bikes) in household. Question on quantity or specific availability should be present *</_motorcycle_note_>*/
*<_motorcycle_note_>  1 "Yes" 0 "No" *</_motorcycle_note_>
gen 	motorcycle = 0
replace motorcycle = 1  		if  item_1033==1 
notes motorcycle: the raw variable refers to "Motorcycle/Scooter"
*</_motorcycle_>

*<_buffalo_>
*<_buffalo_note_> Household has buffalo *</_buffalo_note_>
/*<_buffalo_note_> Availability of buffalos in household. Question on quantity or specific availability should be present *</_buffalo_note_>*/
*<_buffalo_note_>  1 "Yes" 0 "No" *</_buffalo_note_>
gen 	buffalo = 0
replace buffalo = 1			if  item_204==1
*</_buffalo_>

*<_chicken_>
*<_chicken_note_> Household has chicken *</_chicken_note_>
/*<_chicken_note_> Availability of chicken in household. Question on quantity or specific availability should be present *</_chicken_note_>*/
*<_chicken_note_>  1 "Yes" 0 "No" *</_chicken_note_>
gen 	chicken = 0
replace chicken = 1			if  item_205==1
*</_chicken_>

*<_cow_>
*<_cow_note_> Household has cow *</_cow_note_>
/*<_cow_note_> Availability of cows in household. Question on quantity or specific availability should be present *</_cow_note_>*/
*<_cow_note_>  1 "Yes" 0 "No" *</_cow_note_>
gen 	cow = 0
replace cow = 1				if  item_201==1
notes cow: the raw variable refers to "Cattle"
*</_cow_>

*<_lamp_>
*<_lamp_note_> Household has lamp *</_lamp_note_>
/*<_lamp_note_> Availability of lamp in household. Question on quantity or specific availability should be present *</_lamp_note_>*/
*<_lamp_note_>  1 "Yes" 0 "No" *</_lamp_note_>
gen 	lamp = 0
replace lamp = 1				if  item_1035==1
notes lamp: the raw variable refers to "pressure lamp":
*</_lamp_>



***************************************************************************
**** WELFARE MODULE 
***************************************************************************

preserve 
use      "$rootdatalib\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\BGD HIES 2022 new welfare aggregate.dta", clear
drop     wgt 
drop     if hhid==""
tempfile new_welfare
save     `new_welfare'
restore 

merge 1:1 psu hhid pid using `new_welfare'

preserve
datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v09_M) filename(Final_CPI_PPP_to_be_used.dta)
	keep if code=="BGD" & year==2022
	collapse (mean) icp2017 cpi2017, by(code year)
    tempfile data
    save `data', replace
	restore 
	merge m:1 code using `data', nogen keep(match)


*merge m:1 psu idh hhid using "$rootdatalib\\`code'\\`yearfolder'\BGD_2022_HIES_v01_M\Data\Stata\welfare_2022.dta", keep(match)
cap drop welfare_ppp
gen      welfare_ppp = (welfare*12)/cpi2017/icp2017/365
apoverty welfare_ppp [aw=weight] 	if  _merge==3, line(2.15) 
apoverty welfare_ppp [aw=weight] 	if  _merge==3, line(3.65) 
apoverty welfare_ppp [aw=weight] 	if  _merge==3, line(6.85) 

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
*<_weighttype_note_> weighttype brought in from rawdata *</_weighttype_note_>
*gen weighttype = "PW"
*</_weighttype_>

*<_spdef_>
*<_spdef_note_>  Spatial deflator. *</_spdef_note_>
/*<_spdef_note_> Specifies varname for a spatial deflator if one is used. This variable can only be used in combination with a subnational ID. *</_spdef_note_>*/
*<_spdef_note_>  *</_spdef_note_>
gen spdef = .a
*</_spdef_>

*<_welfare_>
*<_welfare_note_>  Welfare aggregate used for estimating international poverty (provided to PovcalNet). *</_welfare_note_>
/*<_welfare_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file that is provided to Povcalnet as input into the estimation of international poverty. This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of these three welfare aggregates will be the same. *</_welfare_note_>*/
*<_welfare_note_>  *</_welfare_note_>
*gen welfare = welfare
*</_welfare_>

*<_welfarenom_>
*<_welfarenom_note_>  Welfare aggregate in nominal terms. *</_welfarenom_note_>
/*<_welfarenom_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file in nominal terms. This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of thes three welfare aggregates will be the same. *</_welfarenom_note_>*/
*<_welfarenom_note_>  *</_welfarenom_note_>
gen welfarenom = welfare
*</_welfarenom_>

*<_welfaredef_>
*<_welfaredef_note_>  Welfare aggregate spatially deflated. *</_welfaredef_note_>
/*<_welfaredef_note_> Specifies varname for the welfare aggregate (e.g. per capita consumption) in the data file spatially deflated (spatial or within year inflaction adjustment).  This variable should be annual and in LCU at current prices. The variables welfare, welfarenom, and welfaredef have to be in the same welfare type (either income, consumption or expenditure) and two of thes three welfare aggregates will be the same. *</_welfaredef_note_>*/
*<_welfaredef_note_>  *</_welfaredef_note_>
gen welfaredef = .a
*</_welfaredef_>

*<_welfshprosperity_>
*<_welfshprosperity_note_>  Welfare aggregate for shared prosperity (if different from poverty) *</_welfshprosperity_note_>
/*<_welfshprosperity_note_> specifies varname for the welfare variable used to compute the shared prosperity indicator (e.g. per capita consumption) in the data file. This variable should be annual and in LCU at current prices. This variable is either the same as welfare ( *</_welfshprosperity_note_>*/
*<_welfshprosperity_note_>  *</_welfshprosperity_note_>
gen welfshprosperity = .a
*</_welfshprosperity_>

*<_welfaretype_>
*<_welfaretype_note_>  Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef. *</_welfaretype_note_>
/*<_welfaretype_note_> Specifies the type of welfare measure for the variables welfare, welfarenom and welfaredef. Accepted values are: INC for income, CONS for consumption, or EXP for expenditure. Welfaretype is case-sensitive and upper case has to be used. *</_welfaretype_note_>*/
*<_welfaretype_note_>  *</_welfaretype_note_>
gen welfaretype = "EXP"
*</_welfaretype_>

*<_welfareother_>
*<_welfareother_note_>  Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef. *</_welfareother_note_>
/*<_welfareother_note_> Specifies varname for the welfare aggregate in the data file if a different welfare type is used from the variables welfare, welfarenom, welfaredef. For example, if consumption is used for welfare, welfarenom and welfaredef but income also exists, it could be included here. This variable should be annual and in LCU at current prices. *</_welfareother_note_>*/
*<_welfareother_note_>  *</_welfareother_note_>
gen   welfareother = ipcf*12
notes welfareother: variable is defined as household per capita income
*</_welfareother_>

*<_welfareothertype_>
*<_welfareothertype_note_>  Type of welfare measure (income, consumption or expenditure) for welfareother. *</_welfareothertype_note_>
/*<_welfareothertype_note_> Specifies the type of welfare measure for the variable welfareother. Accepted values are: INC for income, CONS for consumption, or EXP for expenditure. This variable is only entered if the type of welfare is different from what is provided in welfare, welfarenom, and welfaredef. For example, if consumption is used for welfare, welfarenom and welfaredef but income also exists, it could be included here. Welfaretype is case-sensitive and upper case has to be used. *</_welfareothertype_note_>*/
*<_welfareothertype_note_>  *</_welfareothertype_note_>
gen welfareothertype = "INC"
*</_welfareothertype_>

*<_welfarenat_>
*<_welfarenat_note_>  Welfare aggregate for national poverty. *</_welfarenat_note_>
/*<_welfarenat_note_> Welfare aggregate for national poverty. *</_welfarenat_note_>*/
*<_welfarenat_note_>  1 "Yes" 0 "No" *</_welfarenat_note_>
gen welfarenat = welfare
*</_welfarenat_>


* QUINTILE AND DECILE OF CONSUMPTION AGGREGATE 
levelsof year, loc(y)
*merge m:1 idh using "${shares}\BGD_fnf_`y'", keepusing (quintile_cons_aggregate decile_cons_aggregate) nogen

*<_quintile_cons_aggregate_>
*<_quintile_cons_aggregate_note_> Quintile of welfarenat *</_quintile_cons_aggregate_note_>
/*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>*/
*<_quintile_cons_aggregate_note_>  *</_quintile_cons_aggregate_note_>
_ebin welfare [aw=weight], gen(quintile_cons_aggregate) nq(5) 
*</_quintile_cons_aggregate_>

*<_food_share_>
*<_food_share_note_> Food share *</_food_share_note_>
/*<_food_share_note_>  *</_food_share_note_>*/
*<_food_share_note_>  *</_food_share_note_>
*gen food_share = (fexp/consexp2)*100 //thsi should be updated
gen food_share = .
*</_food_share_>

*<_nfood_share_>
*<_nfood_share_note_> Non-food share *</_nfood_share_note_>
/*<_nfood_share_note_>  *</_nfood_share_note_>*/
*<_nfood_share_note_>  *</_nfood_share_note_>
gen nfood_share =  100-food_share 
*</_nfood_share_>



****************************************************************
**** NATIONAL POVERTY
****************************************************************

*<_pline_nat_>
*<_pline_nat_note_>  Poverty line (National). *</_pline_nat_note_>
/*<_pline_nat_note_> Poverty line based on the nationl methodology. *</_pline_nat_note_>*/
*<_pline_nat_note_>  *</_pline_nat_note_>
gen pline_nat = .a
*</_pline_nat_>

*<_poor_nat_>
*<_poor_nat_note_>  People below Poverty Line (National). *</_poor_nat_note_>
/*<_poor_nat_note_> People below Poverty Line (National). *</_poor_nat_note_>*/
*<_poor_nat_note_>  *</_poor_nat_note_>
gen poor_nat = welfarenat<pline_nat 	if  welfare!=. 
*</_poor_nat_>



****************************************************************
**** INTERNATIONAL POVERTY
****************************************************************
global cpiyear = 2017
	
** USE SARMD CPI AND PPP 
*<_cpi_>
capture drop _merge
gen   cpi = .
label var cpi "CPI (Base ${cpiyear}=1)"
*</_cpi_>	

** PPP VARIABLE 
*<_ppp_>
gen   ppp = icp2017
label var ppp "PPP ${cpiyear}"
*</_ppp_>

** CPI PERIOD  
*<_cpiperiod_>
gen   cpiperiod = .
label var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
*</_cpiperiod_>	

*<_pline_int_>
*<_pline_int_note_>  Poverty line Povcalnet. *</_pline_int_note_>
/*<_pline_int_note_> Poverty line constructed based on international comparison program standards (ICP). *</_pline_int_note_>*/
*<_pline_int_note_>  *</_pline_int_note_>
gen pline_int = 1.90*cpi*ppp*365/12 
*</_pline_int_>

*<_poor_int_>
*<_poor_int_note_>  People below Poverty Line (International). *</_poor_int_note_>
/*<_poor_int_note_> People below poverty line based on PovCalnet methodology. May not be equal to standard country definition. *</_poor_int_note_>*/
*<_poor_int_note_>  *</_poor_int_note_>
gen poor_int = welfare<pline_int if welfare!=. 
*</_poor_int_>

rename month_* mnth_*

*<_Keep variables_>
order countrycode year hhid pid weight weighttype 
sort  hhid pid
*</_Keep variables_>

*<_Save data file_>
do   "P:\SARMD\SARDATABANK\SARMDdofiles\_aux\Labels_SARMD.do"
save "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
