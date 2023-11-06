/*------------------------------------------------------------------------------
SAMRD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	BGD_2022_HIES_v01_M_v01_A_SAMRD_INC.do		</_Program name_>
<_Application_>    	STATA 16.0									<_Application_>
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
File:				BGD_2022_HIES_v01_M_v01_A_SAMRD_INC.do
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
local va           	"01"
local type         	"SARMD"
glo   module       "INC"
local yearfolder   "`code'_`year'_`survey'"
local SARMDfolder  "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
*</_Program setup_>

*<_Folder creation_>
*
*</_Folder creation_>


*<_Datalibweb request_>

* INDIVIDUAL ROSTER
tempfile roster 
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_1A1.dta) clear
drop    TERM S1AQ0A S1AQ08-S1AQ15 S1AQ04-S1AQ06
gen     PID = S1AQ00
order   PSU HHID PID
save   `roster'
********************************************


* INCOMES FROM SECTION 4: DAY LABOURERS and EMPLOYEES    
* Day labourers (S4AQ07==1 | S4AQ08==1)                                                      
* Employees     (S4AQ07==4 | S4AQ08==4)   
tempfile sect4
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_4A.dta) clear
keep if  S4AQ08==1 | S4AQ07==1 | S4AQ08==4 | S4AQ07==4
drop if  S4AQ02==. & S4AQ03==. & S4AQ04==.
gen PID = S4AQ00

* Monthly Income of those working as day labourers
* S4BQ02C: What was the daily wage in cash in the past 12 months? (TAKA)
* S4BQ05B: How much did you receive in-kind per day? (TAKA)
*  S4AQ03: On average, how many days per month did you work?
*  S4AQ02: How many months did you do this activity in the last 12 months?
gen daylab_cash = S4BQ02C * S4AQ03 * (S4AQ02/12)	if  S4BQ01==1 	
gen daylab_kind = S4BQ05B * S4AQ03 * (S4AQ02/12)	if  S4BQ01==1 & S4BQ03==1

* Monthly Income of those working as employees
* S4BQ08: What is your total net take-home monthly remuneration after all deduction at source?
* S4BQ08: What is the total value of in-kind or other benefits you received over the past 12 months?
gen employee_cash = S4BQ08							if  S4BQ01==2
gen employee_kind = S4BQ09/12						if  S4BQ01==2

order  PSU HHID PID S4AQ0A
sort   PSU HHID PID S4AQ0A
drop   TERM S4AQ00 S4AQ0A S4AQ05A S4AQ05B S4BQ01 S4BQ02A S4BQ02B S4BQ02C S4BQ03 S4BQ04 S4BQ05A S4BQ05B S4BQ07 S4BQ08 S4BQ09    
save `sect4'
********************************************


* INCOMES FROM SECTION 5: NON-AGRICULTURAL BUSINESSES                                               
* Self-Employed (S4AQ08==2)                                                         
* Employers     (S4AQ08==3) 
* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
tempfile sect5
tempfile section5
tempfile section5_1
tempfile section5_2
tempfile section5_2aux
tempfile section5_3

* Preparation of Section 4 (to be merged with Section 5)
tempfile section4
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_4A.dta) clear
keep  if S4AQ08==2 | S4AQ08==3
gen   PID = S4AQ00
drop  if PSU==248 & HHID==64 & S4AQ0A=="B" & PID==1

* Keeping the activity with the most worked hours
gen   hours = S4AQ02 * S4AQ03 * S4AQ04
egen  aux_hours = sum(hours), by(PSU HHID PID)
egen  max_hours = max(hours), by(PSU HHID PID)
drop  if hours!=max_hours
duplicates tag PSU HHID PID, gen(tag)
drop  if S4AQ0A=="B" & tag==1
drop  if PSU==482 & HHID==125 & S4AQ0A=="C"
replace hours = aux_hours

* Share of individual hours in household hours
egen  hours_hh = sum(hours), by(PSU HHID)
gen   share_ind = hours/hours_hh
order PSU HHID PID 
sort  PSU HHID PID 
drop  TERM S4AQ00 S4AQ0A S4AQ05A S4AQ05B S4BQ01 S4BQ02A S4BQ02B S4BQ02C S4BQ03 S4BQ04 S4BQ05A S4BQ05B S4BQ07 S4BQ08 S4BQ09 max_hours tag  hours_hh aux_hours
save `section4'
****************

datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_05.dta) clear
* Duplicated business, with missing info in S5Q00 (activity number)
drop if (PSU==494 & HHID==17  & S5Q00==.) | (PSU==515 & HHID==17  & S5Q00==.) | (PSU==631 & HHID==90  & S5Q00==.) | (PSU==632 & HHID==1   & S5Q00==.) 
drop if (PSU==632 & HHID==17  & S5Q00==.) | (PSU==632 & HHID==19  & S5Q00==.) | (PSU==632 & HHID==27  & S5Q00==.) | (PSU==633 & HHID==109 & S5Q00==.) 
drop if (PSU==635 & HHID==66  & S5Q00==.) | (PSU==635 & HHID==91  & S5Q00==.) | (PSU==637 & HHID==90  & S5Q00==.) | (PSU==638 & HHID==36  & S5Q00==.)
drop if (PSU==639 & HHID==85  & S5Q00==.) | (PSU==641 & HHID==27  & S5Q00==.) | (PSU==643 & HHID==96  & S5Q00==.) | (PSU==645 & HHID==19  & S5Q00==.)

* Total Non-Agricultural Income by Activity
* S5Q20: Net revenues over the past 12 months?
* S5Q07: What share of profit is owned by household?
gen month_nonagri = (S5Q20 * (S5Q07/100)) / 12
collapse (sum) month_nonagri, by(PSU HHID)
sort PSU HHID
save `section5'	

use  `section4'	
sort  PSU HHID PID
merge m:1 PSU HHID using `section5'

* Save info for those with income info but without employment info
preserve
tempfile only_income_info
keep if _merge==2 
keep PSU HHID month_nonagri
sort PSU HHID
save `only_income_info'	
restore

replace month_nonagri = month_nonagri*share_ind
drop if _merge==2
gen   x1 = 1	if  _merge==1
drop _merge share_ind
sort  PSU HHID PID
save `section5_1'
****************

* FOR THOSE WITH INCOME INFO BUT WITHOUT MATCHING EMPLOYMENT INFO
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_05.dta) clear
sort      PSU HHID
merge m:1 PSU HHID using `only_income_info'
drop if _merge!=3
drop _merge 

keep if S5Q00==1
keep PSU HHID S5Q01B month_nonagri
sort PSU HHID
save `section5_2aux'

datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_4A.dta) clear
gen  PID = S4AQ00
drop if S4AQ08==2 | S4AQ08==3

gen hours = S4AQ02 * S4AQ03 * S4AQ04
collapse (sum) hours, by(PSU HHID PID)
egen share_tot = sum(hours), by(PSU HHID)
gen  share_ind = hours/share_tot
sort PSU HHID PID
merge m:1 PSU HHID using `section5_2aux'	

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep PSU HHID S5Q01B month_nonagri
sort PSU HHID
tempfile only_income_info_2
save `only_income_info_2'	
restore

replace month_nonagri = month_nonagri*share_ind
drop if _merge!=3
drop _merge share_ind
keep  PSU HHID PID S5Q01B month_nonagri
order PSU HHID PID S5Q01B month_nonagri
tempfile section5_2
sort PSU HHID PID
gen  x2 = 1
save `section5_2'	
****************

* FOR THOSE WITH INCOME INFO BUT WITHOUT EMPLOYMENT INFO AT ALL
use `roster', clear
merge m:1 PSU HHID using `only_income_info_2'
drop if _merge!=3
drop if S1AQ02!=1
drop _merge
keep PSU HHID PID S5Q01B month_nonagri
gen  x3 = 1
sort PSU HHID PID
save `section5_3'
****************

* APPEND SECTION 5
use          `section5_1'
append using `section5_2'
append using `section5_3'	

gen     anomalies = 1	if  x1==1
replace anomalies = 2	if  x2==1
replace anomalies = 3    if  x3==1
drop x*
sort PSU HHID PID
save    `sect5'
********************************************


* INCOMES FROM SECTION 7: AGRICULTURAL ACTIVITIES
* Self-Employed (S4AQ07==2)
* Employers     (S4AQ07==3)
tempfile sect7
tempfile section7
tempfile section7b
tempfile section7c1
tempfile section7c2
tempfile section7c3
tempfile section7c4
tempfile section7d
tempfile section7_1
tempfile section7_2
tempfile section7_3

* Preparation of Section 4 (to be merged with Section 7)
tempfile section4
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_4A.dta) clear
keep if S4AQ07==2 | S4AQ07==3
gen  PID = S4AQ00

* Keeping the activity with the most worked hours
gen  hours = S4AQ02 * S4AQ03 * S4AQ04
egen aux_hours = sum(hours), by(PSU HHID PID)
egen max_hours = max(hours), by(PSU HHID PID)
drop if hours!=max_hours
duplicates tag PSU HHID PID, gen(tag)
drop if S4AQ0A=="B" & tag==1
drop if PSU==459 & HHID==83 & S4AQ0A=="E"
drop if PSU==493 & HHID==59 & S4AQ0A=="C"
drop if PSU==493 & HHID==98 & S4AQ0A=="C"
drop if PSU==623 & HHID==26 & S4AQ0A=="C"
duplicates report
replace hours = aux_hours

* Share of individual hours in household hours
egen hours_hh = sum(hours), by(PSU HHID)
gen  share_ind = hours/hours_hh
order PSU HHID PID 
sort  PSU HHID PID 
drop  TERM S4AQ05A S4AQ05B S4BQ02A S4BQ02B S4AQ00 S4BQ07 S4BQ08 S4BQ09 S4BQ02C S4BQ05B S4BQ01 S4BQ03 S4BQ04 S4BQ05A max_hours tag S4AQ0A hours_hh aux_hours
save `section4'
****************

* SECTION 7B  - CROP PRODUCTION at household/crop level
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_7B.dta) clear
keep 	if  S7BQ02==1
* S7BQ04A: How much in total of crop did you produce in the last 12 months? (kg)
* S7BQ04B: How much in total of crop did you produce in the last 12 months? (taka/kg)
*  S7BQ05: How much did your household consumed in the last 12 months?
*  S7BQ06: How much did your household sell in the last 12 months?
drop if S7BQ05==0 & S7BQ06==0
gen crop_cons = S7BQ05 * S7BQ04B/12	
gen crop_sold = S7BQ06 * S7BQ04B/12	
collapse (sum) crop_cons crop_sold, by(PSU HHID)
sort  PSU HHID
save `section7b', replace
****************

* SECTION 7C1 - LIVESTOCK and POULTRY at household/animal level
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_7C1.dta) clear
* S7C1Q04B:  How many died/did your household sell in the last 12 months? (taka)
* S7C1Q05B:  How many did your household consume in the 12 months? (taka)
drop if S7C1Q04B==. & S7C1Q05B==.
gen livestock_cons = S7C1Q04B/12
gen livestock_sold = S7C1Q05B/12
collapse (sum) livestock_cons livestock_sold, by(PSU HHID)
sort  PSU HHID
save `section7c1', replace
****************

* SECTION 7C2 - LIVESTOCK and POULTRY BY-PRODUCTS at household/by-product level
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_7C2.dta) clear
* S7C2Q07B: How much did you sell in the last 12 months? (taka)
* S7C2Q08B: How much did you consume in the last 12 months? (taka)
drop if S7C2Q06A==. & S7C2Q06B==. & S7C2Q07A==. & S7C2Q07B==. & S7C2Q08A==. & S7C2Q08B==.						/* missing en cantidades y valores 				*/
drop if S7C2Q06A==0 & S7C2Q06B==. & S7C2Q07A==0 & S7C2Q07B==. & S7C2Q08A==0 & S7C2Q08B==.						/* 0s en cantidad, missing en valores			*/
drop if S7C2Q06A==. & S7C2Q06B==. & S7C2Q07A==. & S7C2Q07B==. & S7C2Q08A==. & S7C2Q08B==0						/* missing en casi todo o 0s					*/
drop if S7C2Q06B==. & S7C2Q07B==. & S7C2Q08B==0
drop if S7C2Q06B==. & S7C2Q07B==0 & S7C2Q08B==.
drop if S7C2Q06B==0 & S7C2Q07B==. & S7C2Q08B==.
drop if (S7C2Q06B>0 & S7C2Q06B<.) & S7C2Q07A==0 & S7C2Q08A==0												/* positivo en producción, 0 en consumo o venta */
replace S7C2Q07B = S7C2Q06B	if (S7C2Q06B>0 & S7C2Q06B<.) & (S7C2Q07B==0 | S7C2Q07B==.) & (S7C2Q06A==S7C2Q07A)
replace S7C2Q08B = S7C2Q06B	if (S7C2Q06B>0 & S7C2Q06B<.) & (S7C2Q08B==0 | S7C2Q08B==.) & (S7C2Q06A==S7C2Q08A)
egen x = rsum(S7C2Q07B S7C2Q08B), missing
drop if x==0 | x==.

gen byproduct_cons = S7C2Q08B/12
gen byproduct_sold = S7C2Q07B/12
collapse (sum) byproduct_cons byproduct_sold, by(PSU HHID)
sort  PSU HHID
save `section7c2', replace
****************

* SECTION 7C3 - FISH FARMING and FISH CAPTURE at household/fish level
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_7C3.dta) clear
* S7C3Q11B: How much did your household sell in the past 12 months? (taka)
* S7C3Q12B: How much did your household consume in the 12 months? (taka)
drop if S7C3Q11B==. & S7C3Q12B==.
gen fish_cons = S7C3Q12B/12
gen fish_sold = S7C3Q11B/12
collapse (sum) fish_cons fish_sold, by(PSU HHID)
sort  PSU HHID
save `section7c3', replace
****************

* SECTION 7C4 - FARM FORESTRY at household/tree level
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_7C4.dta) clear
*  S7C4Q15: How much did your household sell in the last 12 months? (taka)
*  S7C4Q16: How much did your household consume in the last 12 months? (taka)
drop if S7C4Q15==0 & S7C4Q16==0
drop if S7C4Q15==. & S7C4Q16==.
gen tree_cons = S7C4Q16/12
gen tree_sold = S7C4Q15/12
collapse (sum) tree_cons tree_sold, by(PSU HHID)
sort  PSU HHID
save `section7c4', replace
****************

* Sección 7D - EXPENSES ON AGRICULTURAL INPUTS at household/input level
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_7D.dta) clear
keep	if  S7DQ02==1
* S7DQ03B: How much did your household spend on the (item) in the last 12 months? (Taka)
gen     agri_expenditure = S7DQ03B/12
replace agri_expenditure = agri_expenditure*(-1)
collapse (sum) agri_expenditure, by(PSU HHID)
drop if agri_expenditure==0
sort  PSU HHID
save `section7d', replace
****************

use  `section7b', clear
merge 1:1 PSU HHID using `section7c1'
drop _merge
sort  PSU HHID
merge 1:1 PSU HHID using `section7c2'
drop _merge
sort  PSU HHID
merge 1:1 PSU HHID using `section7c3'
drop _merge
sort  PSU HHID
merge 1:1 PSU HHID using `section7c4'
drop _merge
sort  PSU HHID
merge 1:1 PSU HHID using `section7d'
drop _merge
sort  PSU HHID
egen agri_income = rsum(crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold), missing

gen     type_agri = 1	if  agri_income==.					/* no agricultural income, but agricultural expenditure		*/
replace type_agri = 2	if  agri_expend==.					/* no agricultural expenditure, but agricultural income 	*/
replace type_agri = 3	if  agri_income!=. & agri_expend!=.	/* both agricultural income and agricultural expenditure 	*/

egen  agri_net = rsum(agri_income agri_expend), missing

keep  PSU HHID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
order PSU HHID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort  PSU HHID
save `section7'
****************

* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
use  `section4'	
sort  PSU HHID PID
merge m:1 PSU HHID using `section7'

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep PSU HHID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort PSU HHID
tempfile only_income_info3
save `only_income_info3'	
restore

local lista "agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold"
foreach income in `lista' {
	replace `income' = `income'*share_ind
	}
drop if _merge==2
gen    x1 = 1	if  _merge==1
drop _merge share_ind
order PSU HHID PID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort  PSU HHID PID
save `section7_1'	
****************

* FOR THOSE WITH INCOME INFO BUT WITHOUT MATCHING EMPLOYMENT INFO
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_4A.dta) clear
gen  PID = S4AQ00
drop if S4AQ07==2 | S4AQ07==3
gen hours = S4AQ02 * S4AQ03 * S4AQ04
collapse (sum) hours, by(PSU HHID PID)
egen share_tot = sum(hours), by(PSU HHID)
gen  share_ind = hours/share_tot
keep PSU HHID PID share_ind
sort PSU HHID PID
merge m:1 PSU HHID using `only_income_info3'	

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep PSU HHID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort PSU HHID
tempfile only_income_info_4
save `only_income_info_4'	
restore

local lista "agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold"
foreach income in `lista' {
	replace `income' = `income'*share_ind
	}
drop if _merge!=3
drop    _merge

keep  PSU HHID PID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
order PSU HHID PID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort  PSU HHID PID
gen   x2=1
save `section7_2'	
****************

* FOR THOSE WITH INCOME INFO BUT WITHOUT EMPLOYMENT INFO AT ALL
use `roster', clear
merge m:1 PSU HHID using `only_income_info_4'
drop if _merge!=3
drop if S1AQ02!=1
drop _merge
keep PSU HHID PID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
gen  x3 = 1
sort PSU HHID PID
save `section7_3'
****************

* APPEND SECTION 7
use          `section7_1'
append using `section7_2'	
append using `section7_3'	

gen     anomalies2 = 4	if  x1==1
replace anomalies2 = 5	if  x2==1
replace anomalies2 = 6	if  x3==1
drop x*
sort PSU HHID PID
save    `sect7'
********************************************


* APPEND SECTIONS 4, 5 & 7
tempfile sect_4_5_7
use          `sect4'
append using `sect5'	
append using `sect7'

replace anomalies = anomalies2 	if  anomalies==.
notes   anomalies: "=1 if it is non-agricultural self-employed or employer, but without income information"
notes   anomalies: "=2 if it has non-agricultural income, but it is employed in another sector"
notes   anomalies: "=3 if it has non-agricultural income, but is it not employed"
notes   anomalies: "=4 if it is agricultural self-employed or employer, but without income information"
notes   anomalies: "=5 if it has agricultural income, but it is employed in another sector"
notes   anomalies: "=6 if it has agricultural income, but is it not employed"
drop    anomalies2 

* Employment Categories
gen 	w_cat = 1 				if  S4AQ07==1 | S4AQ08==1
replace w_cat = 2 				if  S4AQ07==2 | S4AQ08==2
replace w_cat = 3 				if  S4AQ07==3 | S4AQ08==3
replace w_cat = 4 				if  S4AQ07==4 | S4AQ08==4

* Worked Hours (Year)
capture drop hours
gen     hours = S4AQ02 * S4AQ03 * S4AQ04

* Worked Months
gen     months = S4AQ02

* Industry
replace S4AQ01B = S5Q01B			if  S4AQ01B==.
replace S4AQ01B = 1				if  anomalies==5 | anomalies==6

egen    income = rsum(daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net), missing
replace income = income*(-1)

local var "w_cat hours months S4AQ01A S4AQ01B S4BQ06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net anomalies"
foreach v in `var' {
	rename `v' `v'_
	}
sort PSU HHID PID income
by   PSU HHID PID: gen act = _n				   

keep  PSU HHID PID	w_cat hours months S4AQ01A S4AQ01B S4BQ06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net act anomalies
order PSU HHID PID	w_cat hours months S4AQ01A S4AQ01B S4BQ06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net act anomalies
reshape wide      	w_cat hours months S4AQ01A S4AQ01B S4BQ06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net anomalies, j(act) i(PSU HHI PID)
label   define worker 1 Daily 2 SelfEmployed 3 Employer 4 Employee 
label   values  w_cat_1 worker
label   values  w_cat_2 worker
label   values  w_cat_3 worker
label   values  w_cat_4 worker

forvalues t = 1(1)4 {
label var hours_`t' 				"Yearly Hours of work in activity `t'"
label var months_`t' 				"Months of work in activity `t'"
label var w_cat_`t' 				"Employment Category - Activity `t'"
label var S4AQ01B_`t' 			"Industry Code - Activity `t'"
label var S4AQ01A_`t' 			"Occupation Code - Activity `t'"
label var S4BQ06_`t' 			"Sector of Occupation - Activity `t'"
label var daylab_cash_`t' 		"Monthly income (CASH) of daily labourers (taka) - Activity `t'"
label var daylab_kind_`t' 		"Monthly income (IN-KIND) of daily labourers (taka) - Activity `t'"
label var employee_cash_`t' 		"Monthly income (CASH) of employees (taka) - Activity `t'"
label var employee_kind_`t' 		"Monthly income (KIND) of employees (taka) - Activity `t'"
label var month_nonagri_`t' 		"Monthly income in non-agricultural activities as self-employed or employer (taka) - Activity `t'"
label var agri_net_`t' 			"Monthly income in agricultural activities as self-employed or employer (taka) - Activity `t'"
}
sort PSU HHID PID
save `sect_4_5_7'

use `roster', clear
merge 1:1 PSU HHID PID using `sect_4_5_7'
drop if _merge==2
drop _merge
tempfile sect_4_5_7
sort PSU HHID PID

local var "daylab_cash_ daylab_kind_ employee_cash_ employee_kind_ month_nonagri_ agri_net_"
foreach income in `var' {
	forvalues j = 1(1)4 {
	replace `income'`j' = .	if `income'`j'==0
	}
	}
save `sect_4_5_7'
********************************************


* INCOMES FROM SECTION 8: OTHER INCOME 
tempfile sect8
tempfile sect_4_5_7_8
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_8B.dta) clear
keep PSU HHID S8BQ01 S8BQ02 S8BQ03A S8BQ03B S8BQ03C S8BQ04 S8BQ05 S8BQ06 S8BQ07 S8BQ08 S8BQ09 S8BQ11 S8BQ12 S8BQ13

unab xvars: S8BQ01 S8BQ02 S8BQ03A S8BQ03B S8BQ03C S8BQ04 S8BQ05 S8BQ06 S8BQ07 S8BQ08 S8BQ09 S8BQ11 S8BQ12 S8BQ13
foreach x of local xvars { 
    replace `x' = `x'/12
}
keep PSU HHID S8BQ01 S8BQ02 S8BQ03A S8BQ03B S8BQ03C S8BQ04 S8BQ05 S8BQ06 S8BQ07 S8BQ08 S8BQ09 S8BQ11 S8BQ12 S8BQ13
sort PSU HHID
save `sect8'

use `sect_4_5_7'
merge m:1 PSU HHID using `sect8'
drop _merge
unab xvars: S8BQ01 S8BQ02 S8BQ03A S8BQ03B S8BQ03C S8BQ04 S8BQ05 S8BQ06 S8BQ07 S8BQ08 S8BQ09 S8BQ11 S8BQ12 S8BQ13
foreach x of local xvars { 
    replace `x' = . 	if  S1AQ02!=1
	replace `x' = .		if  `x'==0
	}
sort PSU HHID PID
save `sect_4_5_7_8'
********************************************


* INCOMES FROM SECTION 9: HOUSING RENT 
tempfile sect9
tempfile sect_4_5_7_8_9
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_9D1.dta) clear
keep  if  S9D1Q02==42111
duplicates report PSU HHID
gen   housing_rent = S9D1Q05/12
sort  PSU HHID
save `sect9', replace

use `sect_4_5_7_8'
merge m:1 PSU HHID using `sect9'
drop _merge
sort  PSU HHID PID
save `sect_4_5_7_8_9'
********************************************


* INCOMES FROM SECTION 1C: SOCIAL SAFETY NETS
tempfile sect1
tempfile sect_4_5_7_8_9_1
datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(HH_SEC_1C.dta) clear
gen   PID = S1CQ00
order PSU HHID PID

*  S1CQ10A: How much did you receive in cash in last 12 months?
* S1CQ101D: How much did you receive in-kind in last 12 months? 1
* S1CQ102D: How much did you receive in-kind in last 12 months? 2
replace  S1CQ10A = .				if  S1CQ10A==0
replace  S1CQ10A = S1CQ10A/12
replace S1CQ101D = .				if  S1CQ101D==0
replace S1CQ101D = S1CQ101D/12
replace S1CQ102D = S1CQ102D/12
replace S1CQ102D = .				if  S1CQ102D==0
drop if S1CQ10A==. & S1CQ101D==. & S1CQ102D==.

egen    ssn_cash = rsum(S1CQ10A), missing
egen	ssn_kind = rsum(S1CQ101D S1CQ102D), missing

collapse (sum) ssn_cash (sum) ssn_kind, by(PSU HHID PID)
sort  PSU HHID PID
save `sect1', replace

use `sect_4_5_7_8_9'
merge 1:1 PSU HHID PID using `sect1'
drop _merge
sort PSU HHID PID
save `sect_4_5_7_8_9_1'

datalibweb, country(BGD) year(2022) type(SARRAW) surveyid(BGD_2022_HIES_v01_M) filename(weight_final_2022.dta) clear 
sort PSU HHID
tempfile weight
save `weight'

use `sect_4_5_7_8_9_1'
merge m:1 PSU HHID using `weight'
drop _merge
sort PSU HHID PID
*/
/*
********************************************************************************************************************
cd "D:\Dropbox2\datalib\SARMD\WORKINGDATA\BGD\BGD_2022_HIES\BGD_2022_HIES_v01_M\Data\Stata"

***********************
* INDIVIDUAL ROSTER
***********************
use "HH_SEC_1A1.dta", clear
drop TERM S1AQ0A S1AQ08-S1AQ15 S1AQ04-S1AQ06
rename  S1AQ00 PID
order PSU HHID PID
tempfile roster 
save    `roster'


********************************************************
* INCOMES FROM SECTION 4: DAY LABOURERS and EMPLOYEES    
* Day labourers (S4AQ07==1 | S4AQ08==1)                                                      
* Employees     (S4AQ07==4 | S4AQ08==4)   
********************************************************                                                 
tempfile sect4
use "HH_SEC_4A.dta", clear
keep if  S4AQ08==1 | S4AQ07==1 | S4AQ08==4 | S4AQ07==4
drop if  S4AQ02==. & S4AQ03==. & S4AQ04==.
gen PID = S4AQ00

* Monthly Income of those working as day labourers
* S4BQ02C: What was the daily wage in cash in the past 12 months? (TAKA)
* S4BQ05B: How much did you receive in-kind per day? (TAKA)
*  S4AQ03: On average, how many days per month did you work?
*  S4AQ02: How many months did you do this activity in the last 12 months?
gen daylab_cash = S4BQ02C * S4AQ03 * (S4AQ02/12)	if  S4BQ01==1 	
gen daylab_kind = S4BQ05B * S4AQ03 * (S4AQ02/12)	if  S4BQ01==1 & S4BQ03==1

* Monthly Income of those working as employees
* S4BQ08: What is your total net take-home monthly remuneration after all deduction at source?
* S4BQ08: What is the total value of in-kind or other benefits you received over the past 12 months?
gen employee_cash = S4BQ08							if  S4BQ01==2
gen employee_kind = S4BQ09/12						if  S4BQ01==2

order PSU HHID PID S4AQ0A
sort  PSU HHID PID S4AQ0A
drop   TERM S4AQ00 S4AQ0A S4AQ05A S4AQ05B S4BQ01 S4BQ02A S4BQ02B S4BQ02C S4BQ03 S4BQ04 S4BQ05A S4BQ05B S4BQ07 S4BQ08 S4BQ09    
save `sect4'


********************************************************
* INCOMES FROM SECTION 5: NON-AGRICULTURAL BUSINESSES                                               
* Self-Employed (S4AQ08==2)                                                         
* Employers     (S4AQ08==3) 
********************************************************      
tempfile section4
use  "HH_SEC_4A.dta", clear
keep if S4AQ08==2 | S4AQ08==3
gen  PID = S4AQ00
drop if PSU==248 & HHID==64 & S4AQ0A=="B" & PID==1

* Keeping the activity with the most worked hours
gen  hours = S4AQ02 * S4AQ03 * S4AQ04
egen aux_hours = sum(hours), by(PSU HHID PID)
egen max_hours = max(hours), by(PSU HHID PID)
drop if hours!=max_hours
duplicates tag PSU HHID PID, gen(tag)
drop if S4AQ0A=="B" & tag==1
drop if PSU==482 & HHID==125 & S4AQ0A=="C"
replace hours = aux_hours

* Share of individual hours in household hours
egen hours_hh = sum(hours), by(PSU HHID)
gen  share_ind = hours/hours_hh
order PSU HHID PID 
sort  PSU HHID PID 
drop  TERM S4AQ00 S4AQ0A S4AQ05A S4AQ05B S4BQ01 S4BQ02A S4BQ02B S4BQ02C S4BQ03 S4BQ04 S4BQ05A S4BQ05B S4BQ07 S4BQ08 S4BQ09 max_hours tag  hours_hh aux_hours
save `section4'


************************************************************
* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
************************************************************
tempfile section5
use "HH_SEC_05.dta", clear
* Negocios duplicados, con missing en S5Q00 (número de actividad)
drop if (PSU==494 & HHID==17  & S5Q00==.) | (PSU==515 & HHID==17  & S5Q00==.) | (PSU==631 & HHID==90  & S5Q00==.) | (PSU==632 & HHID==1   & S5Q00==.) 
drop if (PSU==632 & HHID==17  & S5Q00==.) | (PSU==632 & HHID==19  & S5Q00==.) | (PSU==632 & HHID==27  & S5Q00==.) | (PSU==633 & HHID==109 & S5Q00==.) 
drop if (PSU==635 & HHID==66  & S5Q00==.) | (PSU==635 & HHID==91  & S5Q00==.) | (PSU==637 & HHID==90  & S5Q00==.) | (PSU==638 & HHID==36  & S5Q00==.)
drop if (PSU==639 & HHID==85  & S5Q00==.) | (PSU==641 & HHID==27  & S5Q00==.) | (PSU==643 & HHID==96  & S5Q00==.) | (PSU==645 & HHID==19  & S5Q00==.)

* Total Non-Agricultural Income by Activity
* S5Q20: Net revenues over the past 12 months?
* S5Q07: What share of profit is owned by household?
gen month_nonagri = (S5Q20 * (S5Q07/100)) / 12
collapse (sum) month_nonagri, by(PSU HHID)
sort PSU HHID
save `section5'	

use  `section4'	
sort  PSU HHID PID
merge m:1 PSU HHID using `section5'

* Save info for those with income info but without employment info
preserve
tempfile only_income_info
keep if _merge==2 
keep PSU HHID month_nonagri
sort PSU HHID
save `only_income_info'	
restore

replace month_nonagri = month_nonagri*share_ind
drop if _merge==2
gen   x1 = 1	if  _merge==1
drop _merge share_ind

tempfile section5_1
sort  PSU HHID PID
save `section5_1'	


********************************************************************
* FOR THOSE WITH INCOME INFO BUT WITHOUT MATCHING EMPLOYMENT INFO
********************************************************************
use "HH_SEC_05.dta", clear
sort      PSU HHID
merge m:1 PSU HHID using `only_income_info'
drop if _merge!=3
drop _merge 

keep if S5Q00==1
keep PSU HHID S5Q01B month_nonagri
sort PSU HHID
tempfile section5_2aux
save    `section5_2aux'


use "HH_SEC_4A.dta", clear
gen  PID = S4AQ00
drop if S4AQ08==2 | S4AQ08==3

gen hours = S4AQ02 * S4AQ03 * S4AQ04
collapse (sum) hours, by(PSU HHID PID)
egen share_tot = sum(hours), by(PSU HHID)
gen  share_ind = hours/share_tot
sort PSU HHID PID
merge m:1 PSU HHID using `section5_2aux'	

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep PSU HHID S5Q01B month_nonagri
sort PSU HHID
tempfile only_income_info_2
save `only_income_info_2'	
restore

replace month_nonagri = month_nonagri*share_ind
drop if _merge!=3
drop _merge share_ind
keep  PSU HHID PID S5Q01B month_nonagri
order PSU HHID PID S5Q01B month_nonagri
tempfile section5_2
sort PSU HHID PID
gen  x2 = 1
save `section5_2'	


********************************************************************
* FOR THOSE WITH INCOME INFO BUT WITHOUT EMPLOYMENT INFO AT ALL
********************************************************************
use `roster', clear
merge m:1 PSU HHID using `only_income_info_2'
drop if _merge!=3
drop if S1AQ02!=1
drop _merge
keep PSU HHID PID S5Q01B month_nonagri
gen  x3 = 1
sort PSU HHID PID
tempfile section5_3
save `section5_3'


********************
* Append Section 5
********************
use          `section5_1'
append using `section5_2'
append using `section5_3'	

gen     anomalies = 1	if  x1==1
replace anomalies = 2	if  x2==1
replace anomalies = 3    if  x3==1
drop x*
tempfile sect5
sort PSU HHID PID
save    `sect5'



***************************************************
* INCOMES FROM SECTION 7: AGRICULTURAL ACTIVITIES
* Self-Employed (S4AQ07==2)
* Employers     (S4AQ07==3)
***************************************************
tempfile section7
tempfile section4
use  "HH_SEC_4A.dta", clear
keep if S4AQ07==2 | S4AQ07==3
gen  PID = S4AQ00

* Keeping the activity with the most worked hours
gen  hours = S4AQ02 * S4AQ03 * S4AQ04
egen aux_hours = sum(hours), by(PSU HHID PID)
egen max_hours = max(hours), by(PSU HHID PID)
drop if hours!=max_hours
duplicates tag PSU HHID PID, gen(tag)
drop if S4AQ0A=="B" & tag==1
drop if PSU==459 & HHID==83 & S4AQ0A=="E"
drop if PSU==493 & HHID==59 & S4AQ0A=="C"
drop if PSU==493 & HHID==98 & S4AQ0A=="C"
drop if PSU==623 & HHID==26 & S4AQ0A=="C"
duplicates report
replace hours = aux_hours

* Share of individual hours in household hours
egen hours_hh = sum(hours), by(PSU HHID)
gen  share_ind = hours/hours_hh
order PSU HHID PID 
sort  PSU HHID PID 
drop  TERM S4AQ05A S4AQ05B S4BQ02A S4BQ02B S4AQ00 S4BQ07 S4BQ08 S4BQ09 S4BQ02C S4BQ05B S4BQ01 S4BQ03 S4BQ04 S4BQ05A max_hours tag S4AQ0A hours_hh aux_hours
save `section4'


*********************************************************
* Section 7B  - CROP PRODUCTION at household/crop level
*********************************************************
tempfile section7b
use 	"HH_SEC_7B.dta", clear
keep 	if  S7BQ02==1
* S7BQ04A: How much in total of crop did you produce in the last 12 months? (kg)
* S7BQ04B: How much in total of crop did you produce in the last 12 months? (taka/kg)
*  S7BQ05: How much did your household consumed in the last 12 months?
*  S7BQ06: How much did your household sell in the last 12 months?
drop if S7BQ05==0 & S7BQ06==0
gen crop_cons = S7BQ05 * S7BQ04B/12	
gen crop_sold = S7BQ06 * S7BQ04B/12	
collapse (sum) crop_cons crop_sold, by(PSU HHID)
sort  PSU HHID
save `section7b', replace

*****************************************************************
* Sección 7C1 - LIVESTOCK and POULTRY at household/animal level
*****************************************************************
tempfile section7c1
use 	"HH_SEC_7C1.dta", clear
* S7C1Q04B:  How many died/did your household sell in the last 12 months? (taka)
* S7C1Q05B:  How many did your household consume in the 12 months? (taka)
drop if S7C1Q04B==. & S7C1Q05B==.
gen livestock_cons = S7C1Q04B/12
gen livestock_sold = S7C1Q05B/12
collapse (sum) livestock_cons livestock_sold, by(PSU HHID)
sort  PSU HHID
save `section7c1', replace

*********************************************************************************
* Sección 7C2 - LIVESTOCK and POULTRY BY-PRODUCTS at household/by-product level
*********************************************************************************
tempfile section7c2
use 	"HH_SEC_7C2.dta", clear
* S7C2Q07B: How much did you sell in the last 12 months? (taka)
* S7C2Q08B: How much did you consume in the last 12 months? (taka)
drop if S7C2Q06A==. & S7C2Q06B==. & S7C2Q07A==. & S7C2Q07B==. & S7C2Q08A==. & S7C2Q08B==.							/* missing en cantidades y valores 				*/
drop if S7C2Q06A==0 & S7C2Q06B==. & S7C2Q07A==0 & S7C2Q07B==. & S7C2Q08A==0 & S7C2Q08B==.							/* 0s en cantidad, missing en valores			*/
drop if S7C2Q06A==. & S7C2Q06B==. & S7C2Q07A==. & S7C2Q07B==. & S7C2Q08A==. & S7C2Q08B==0							/* missing en casi todo o 0s					*/
drop if S7C2Q06B==. & S7C2Q07B==. & S7C2Q08B==0
drop if S7C2Q06B==. & S7C2Q07B==0 & S7C2Q08B==.
drop if S7C2Q06B==0 & S7C2Q07B==. & S7C2Q08B==.
drop if (S7C2Q06B>0 & S7C2Q06B<.) & S7C2Q07A==0 & S7C2Q08A==0													/* positivo en producción, 0 en consumo o venta */
replace S7C2Q07B = S7C2Q06B	if (S7C2Q06B>0 & S7C2Q06B<.) & (S7C2Q07B==0 | S7C2Q07B==.) & (S7C2Q06A==S7C2Q07A)
replace S7C2Q08B = S7C2Q06B	if (S7C2Q06B>0 & S7C2Q06B<.) & (S7C2Q08B==0 | S7C2Q08B==.) & (S7C2Q06A==S7C2Q08A)
egen x = rsum(S7C2Q07B S7C2Q08B), missing
drop if x==0 | x==.

gen byproduct_cons = S7C2Q08B/12
gen byproduct_sold = S7C2Q07B/12
collapse (sum) byproduct_cons byproduct_sold, by(PSU HHID)
sort  PSU HHID
save `section7c2', replace

***********************************************************************
* Sección 7C3 - FISH FARMING and FISH CAPTURE at household/fish level
***********************************************************************
tempfile section7c3
use 	"HH_SEC_7C3.dta", clear
* S7C3Q11B: How much did your household sell in the past 12 months? (taka)
* S7C3Q12B: How much did your household consume in the 12 months? (taka)
drop if S7C3Q11B==. & S7C3Q12B==.
gen fish_cons = S7C3Q12B/12
gen fish_sold = S7C3Q11B/12
collapse (sum) fish_cons fish_sold, by(PSU HHID)
sort  PSU HHID
save `section7c3', replace

******************************************************
* Sección 7C4 - FARM FORESTRY at household/tree level
******************************************************
tempfile section7c4
use 	"HH_SEC_7C4.dta", clear
*  S7C4Q15: How much did your household sell in the last 12 months? (taka)
*  S7C4Q16: How much did your household consume in the last 12 months? (taka)
drop if S7C4Q15==0 & S7C4Q16==0
drop if S7C4Q15==. & S7C4Q16==.
gen tree_cons = S7C4Q16/12
gen tree_sold = S7C4Q15/12
collapse (sum) tree_cons tree_sold, by(PSU HHID)
sort  PSU HHID
save `section7c4', replace

*************************************************************************
* Sección 7D - EXPENSES ON AGRICULTURAL INPUTS at household/input level
*************************************************************************
tempfile section7d
use 	"HH_SEC_7D.dta", clear
keep	if  S7DQ02==1
* S7DQ03B: How much did your household spend on the (item) in the last 12 months? (Taka)
gen     agri_expenditure = S7DQ03B/12
replace agri_expenditure = agri_expenditure*(-1)
collapse (sum) agri_expenditure, by(PSU HHID)
drop if agri_expenditure==0
sort  PSU HHID
save `section7d', replace


use  `section7b', clear
merge 1:1 PSU HHID using `section7c1'
drop _merge
sort  PSU HHID
merge 1:1 PSU HHID using `section7c2'
drop _merge
sort  PSU HHID
merge 1:1 PSU HHID using `section7c3'
drop _merge
sort  PSU HHID
merge 1:1 PSU HHID using `section7c4'
drop _merge
sort  PSU HHID
merge 1:1 PSU HHID using `section7d'
drop _merge
sort  PSU HHID
egen agri_income = rsum(crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold), missing

gen     type_agri = 1	if  agri_income==.					/* no agricultural income, but agricultural expenditure		*/
replace type_agri = 2	if  agri_expend==.					/* no agricultural expenditure, but agricultural income 	*/
replace type_agri = 3	if  agri_income!=. & agri_expend!=.	/* both agricultural income and agricultural expenditure 	*/

egen  agri_net = rsum(agri_income agri_expend), missing

keep  PSU HHID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
order PSU HHID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort  PSU HHID
save `section7'	


************************************************************
* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
************************************************************
tempfile section7_1
use  `section4'	
sort  PSU HHID PID
merge m:1 PSU HHID using `section7'

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep PSU HHID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort PSU HHID
tempfile only_income_info3
save `only_income_info3'	
restore

local lista "agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold"
foreach income in `lista' {
	replace `income' = `income'*share_ind
	}
drop if _merge==2
gen    x1 = 1	if  _merge==1
drop _merge share_ind
order PSU HHID PID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold 
sort  PSU HHID PID
save `section7_1'	


*******************************************************************
* FOR THOSE WITH INCOME INFO BUT WITHOUT MARCHING EMPLOYMENT INFO
*******************************************************************
tempfile section7_2
use "HH_SEC_4A.dta", clear
gen  PID = S4AQ00
drop if S4AQ07==2 | S4AQ07==3
gen hours = S4AQ02 * S4AQ03 * S4AQ04
collapse (sum) hours, by(PSU HHID PID)
egen share_tot = sum(hours), by(PSU HHID)
gen  share_ind = hours/share_tot
keep PSU HHID PID share_ind
sort PSU HHID PID
merge m:1 PSU HHID using `only_income_info3'	

* Save info for those with income info but without employment info
preserve
keep if _merge==2 
keep PSU HHID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
sort PSU HHID
tempfile only_income_info_4
save `only_income_info_4'	
restore

local lista "agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold"
foreach income in `lista' {
	replace `income' = `income'*share_ind
	}
drop if _merge!=3
drop    _merge

keep  PSU HHID PID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold 
order PSU HHID PID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold 
sort  PSU HHID PID
gen   x2=1
save `section7_2'	


********************************************************************
* FOR THOSE WITH INCOME INFO BUT WITHOUT EMPLOYMENT INFO AT ALL
********************************************************************
use `roster', clear
merge m:1 PSU HHID using `only_income_info_4'
drop if _merge!=3
drop if S1AQ02!=1
drop _merge
keep PSU HHID PID agri_net agri_income agri_expend crop_cons crop_sold livestock_cons livestock_sold byproduct_cons byproduct_sold fish_cons fish_sold tree_cons tree_sold
gen  x3 = 1
sort PSU HHID PID

tempfile section7_3
save `section7_3'

********************
* Append Section 7
********************
use          `section7_1'
append using `section7_2'	
append using `section7_3'	

gen     anomalies2 = 4	if  x1==1
replace anomalies2 = 5	if  x2==1
replace anomalies2 = 6	if  x3==1
drop x*
sort PSU HHID PID
tempfile sect7
save    `sect7'


**************************
* Append Sections 4-5-7
**************************
use          `sect4'
append using `sect5'	
append using `sect7'

replace anomalies = anomalies2 	if  anomalies==.
notes   anomalies: "=1 if it is non-agricultural self-employed or employer, but without income information"
notes   anomalies: "=2 if it has non-agricultural income, but it is employed in another sector"
notes   anomalies: "=3 if it has non-agricultural income, but is it not employed"
notes   anomalies: "=4 if it is agricultural self-employed or employer, but without income information"
notes   anomalies: "=5 if it has agricultural income, but it is employed in another sector"
notes   anomalies: "=6 if it has agricultural income, but is it not employed"
drop    anomalies2 

* Employment Categories
gen 	w_cat = 1 				if  S4AQ07==1 | S4AQ08==1
replace w_cat = 2 				if  S4AQ07==2 | S4AQ08==2
replace w_cat = 3 				if  S4AQ07==3 | S4AQ08==3
replace w_cat = 4 				if  S4AQ07==4 | S4AQ08==4

* Worked Hours (Year)
capture drop hours
gen     hours = S4AQ02 * S4AQ03 * S4AQ04

* Worked Months
gen     months = S4AQ02

* Industry
replace S4AQ01B = S5Q01B			if  S4AQ01B==.
replace S4AQ01B = 1				if  anomalies==5 | anomalies==6

egen    income = rsum(daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net), missing
replace income = income*(-1)

local var "w_cat hours months S4AQ01A S4AQ01B S4BQ06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net anomalies"
foreach v in `var' {
	rename `v' `v'_
	}
sort PSU HHID PID income
by   PSU HHID PID: gen act = _n				   

keep  PSU HHID PID w_cat 	hours months S4AQ01A S4AQ01B S4BQ06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net act anomalies
order PSU HHID PID w_cat 	hours months S4AQ01A S4AQ01B S4BQ06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net act anomalies
reshape wide      w_cat 	hours months S4AQ01A S4AQ01B S4BQ06 daylab_cash daylab_kind employee_cash employee_kind month_nonagri agri_net anomalies, j(act) i(PSU HHI PID)

label   define worker 1 Daily 2 SelfEmployed 3 Employer 4 Employee 
label   values  w_cat_1 worker
label   values  w_cat_2 worker
label   values  w_cat_3 worker
label   values  w_cat_4 worker

forvalues t = 1(1)4 {
label var hours_`t' 				"Yearly Hours of work in activity `t'"
label var months_`t' 			"Months of work in activity `t'"
label var w_cat_`t' 				"Employment Category - Activity `t'"
label var S4AQ01B_`t' 			"Industry Code - Activity `t'"
label var S4AQ01A_`t' 			"Occupation Code - Activity `t'"
label var S4BQ06_`t' 			"Sector of Occupation - Activity `t'"
label var daylab_cash_`t' 		"Monthly income (CASH) of daily labourers (taka) - Activity `t'"
label var daylab_kind_`t' 		"Monthly income (IN-KIND) of daily labourers (taka) - Activity `t'"
label var employee_cash_`t' 		"Monthly income (CASH) of employees (taka) - Activity `t'"
label var employee_kind_`t' 		"Monthly income (KIND) of employees (taka) - Activity `t'"
label var month_nonagri_`t' 		"Monthly income in non-agricultural activities as self-employed or employer (taka) - Activity `t'"
label var agri_net_`t' 			"Monthly income in agricultural activities as self-employed or employer (taka) - Activity `t'"
}
tempfile sect_4_5_7
sort PSU HHID PID
save `sect_4_5_7'

use `roster', clear
merge 1:1 PSU HHID PID using `sect_4_5_7'
drop if _merge==2
drop _merge
tempfile sect_4_5_7
sort PSU HHID PID

local var "daylab_cash_ daylab_kind_ employee_cash_ employee_kind_ month_nonagri_ agri_net_"
foreach income in `var' {
	forvalues j = 1(1)4 {
	replace `income'`j' = .	if `income'`j'==0
	}
	}
save `sect_4_5_7'


****************************************
* INCOMES FROM SECTION 8: OTHER INCOME 
****************************************
tempfile sect8
use "HH_SEC_8B.dta", clear
keep PSU HHID S8BQ01 S8BQ02 S8BQ03A S8BQ03B S8BQ03C S8BQ04 S8BQ05 S8BQ06 S8BQ07 S8BQ08 S8BQ09 S8BQ11 S8BQ12 S8BQ13

unab xvars: S8BQ01 S8BQ02 S8BQ03A S8BQ03B S8BQ03C S8BQ04 S8BQ05 S8BQ06 S8BQ07 S8BQ08 S8BQ09 S8BQ11 S8BQ12 S8BQ13
foreach x of local xvars { 
    replace `x' = `x'/12
}
keep PSU HHID S8BQ01 S8BQ02 S8BQ03A S8BQ03B S8BQ03C S8BQ04 S8BQ05 S8BQ06 S8BQ07 S8BQ08 S8BQ09 S8BQ11 S8BQ12 S8BQ13
sort PSU HHID
save `sect8'

use `sect_4_5_7'
merge m:1 PSU HHID using `sect8'
drop _merge
unab xvars: S8BQ01 S8BQ02 S8BQ03A S8BQ03B S8BQ03C S8BQ04 S8BQ05 S8BQ06 S8BQ07 S8BQ08 S8BQ09 S8BQ11 S8BQ12 S8BQ13
foreach x of local xvars { 
    replace `x' = . 	if  S1AQ02!=1
	replace `x' = .		if  `x'==0
	}
sort PSU HHID PID
tempfile sect_4_5_7_8
save `sect_4_5_7_8'


****************************************
* INCOMES FROM SECTION 9: HOUSING RENT 
****************************************
tempfile sect9
use "HH_SEC_9D1.dta", clear
keep  if  S9D1Q02==42111
duplicates report PSU HHID
gen   housing_rent = S9D1Q05/12
sort  PSU HHID
save `sect9', replace

use `sect_4_5_7_8'
merge m:1 PSU HHID using `sect9'
drop _merge
sort PSU HHID PID
tempfile sect_4_5_7_8_9
save    `sect_4_5_7_8_9'


***********************************************
* INCOMES FROM SECTION 1C: SOCIAL SAFETY NETS
***********************************************
tempfile sect1
use "HH_SEC_1C.dta", clear
gen PID = S1CQ00
order PSU HHID PID

*  S1CQ10A: How much did you receive in cash in last 12 months?
* S1CQ101D: How much did you receive in-kind in last 12 months? 1
* S1CQ102D: How much did you receive in-kind in last 12 months? 2
replace  S1CQ10A = .				if  S1CQ10A==0
replace  S1CQ10A = S1CQ10A/12
replace S1CQ101D = .				if  S1CQ101D==0
replace S1CQ101D = S1CQ101D/12
replace S1CQ102D = S1CQ102D/12
replace S1CQ102D = .				if  S1CQ102D==0
drop if S1CQ10A==. & S1CQ101D==. & S1CQ102D==.

egen    ssn_cash = rsum(S1CQ10A), missing
egen	ssn_kind = rsum(S1CQ101D S1CQ102D), missing

collapse (sum) ssn_cash (sum) ssn_kind, by(PSU HHID PID)
sort  PSU HHID PID

save `sect1', replace

use `sect_4_5_7_8_9'
merge 1:1 PSU HHID PID using `sect1'
drop _merge
sort PSU HHID PID
tempfile sect_4_5_7_8_9_1
save `sect_4_5_7_8_9_1'

use "weight_final_2022.dta"
sort PSU HHID
tempfile weight
save `weight'

use `sect_4_5_7_8_9_1'
merge m:1 PSU HHID using `weight'
drop _merge
sort PSU HHID PID
*/
*</_Datalibweb request_>




* COUNTRYCODE
*<_countrycode_>
*<_countrycode_note_> Country code according to ISO-3166 Alpha-3 *</_countrycode_note_>
gen str countrycode = "`code'"
*</_countrycode_>

* YEAR
*<_year_>
*<_year_note_> 4-digit year of survey based on IHSN standards *</_year_note_>
gen int year = `year'
*</_year_>

* HOUSEHOLD IDENTIFIER
*<_idh_>
*<_idh_note_> Household identifier  *</_idh_note_>
egen idh = concat(PSU HHID), punct(-)
*</_idh_>

* PERSONAL IDENTIFIER
*<_idp_>
*<_idp_note_> Personal identifier  *</_idp_note_>
egen idp = concat(idh PID), punct(-)
*</_idp_>

gen hhid = idh
gen pid = idp
gen weighttype = "PW"

*<_wgt_>
*<_wgt_note_> Variables used to construct Household identifier  *</_wgt_note_>
gen wgt = hh_wgt
*</_wgt_>


**************************************************
*** INCOME Variables
**************************************************

*** FIRST ECONOMIC ACTIVITY
*<_isalp_m_>
*<_isalp_m_note_> Salaried income in the main occupation - monetary *</_isalp_m_note_>
egen isalp_m = rsum(daylab_cash_1 employee_cash_1), missing
*</_isalp_m_>

*<_isalp_nm_>
*<_isalp_nm_note_> Salaried income in the main occupation - non-monetary *</_isalp_nm_note_>
egen isalp_nm = rsum(daylab_kind_1 employee_kind_1), missing
*</_isalp_nm_>

* Auxiliar variables
gen aux_ot1 = agri_net_1		if  w_cat_1!=3 & w_cat_1!=2
gen aux_ot2 = month_nonagri_1	if  w_cat_1!=3 & w_cat_1!=2

*<_isep_m_>
*<_isep_m_note_> Self-employed income in the main occupation - monetary *</_isep_m_note_>
egen    isep_m = rsum(agri_net_1 month_nonagri_1), missing
replace isep_m = .			if  w_cat_1!=2
*</_isep_m_>

*<_isep_nm_>
*<_isep_nm_note_> Self-employed income in the main occupation - non-monetary *</_isep_nm_note_>
gen isep_nm = .
*</_isep_nm_>

*<_iempp_m_>
*<_iempp_m_note_> Income by employer in the main occupation - monetary *</_iempp_m_note_>
egen 	iempp_m = rsum(agri_net_1 month_nonagri_1), missing
replace iempp_m = .			if  w_cat_1!=3
*</_iempp_m_>

*<_iempp_nm_>
*<_iempp_nm_note_> Income by employer in the main occupation - non-monetary *</_iempp_nm_note_>
gen iempp_nm = .
*</_iempp_nm_>

*<_iolp_m_>
*<_iolp_m_note_> Other labor income in the main occupation - monetary *</_iolp_m_note_>
egen iolp_m = rsum(aux_ot1 aux_ot2), missing
*</_iolp_m_>

*<_iolp_nm_>
*<_iolp_nm_note_> Other labor income in the main occupation - non-monetary *</_iolp_nm_note_>
gen iolp_nm = .
*</_iolp_nm_>
drop aux*


*** SECOND AND OTHER ECONOMIC ACTIVITIES

*<_isalnp_m_>
*<_isalnp_m_note_> Salaried income in the non-principal occupation - monetary *</_isalnp_m_note_>
egen isalnp_m = rsum(daylab_cash_2 daylab_cash_3 daylab_cash_4 employee_cash_2 employee_cash_3 employee_cash_4), missing
*</_isalnp_m_>

*<_isalnp_nm_>
*<_isalnp_nm_note_> Salaried income in the non-principal occupation - non-monetary *</_isalnp_nm_note_>
egen isalnp_nm = rsum(daylab_kind_2 daylab_kind_3 daylab_kind_4 employee_kind_2 employee_kind_3 employee_kind_4), missing
*</_isalnp_nm_>


* Auxiliar variables
gen aux_se2 = agri_net_2		if  w_cat_2==2
gen aux_se3 = agri_net_3		if  w_cat_3==2
gen aux_se4 = agri_net_4		if  w_cat_4==2
gen aux_se5 = month_nonagri_2	if  w_cat_2==2
gen aux_se6 = month_nonagri_3	if  w_cat_3==2
gen aux_se7 = month_nonagri_4	if  w_cat_4==2

gen aux_em2 = agri_net_2		if  w_cat_2==3
gen aux_em3 = agri_net_3		if  w_cat_3==3
gen aux_em4 = agri_net_4		if  w_cat_4==3
gen aux_em5 = month_nonagri_2	if  w_cat_2==3
gen aux_em6 = month_nonagri_3	if  w_cat_3==3
gen aux_em7 = month_nonagri_4	if  w_cat_4==3

gen aux_ot2 = agri_net_2		if  w_cat_2!=3 & w_cat_2!=2
gen aux_ot3 = agri_net_3		if  w_cat_3!=3 & w_cat_3!=2
gen aux_ot4 = agri_net_4		if  w_cat_4!=3 & w_cat_4!=2
gen aux_ot5 = month_nonagri_2	if  w_cat_2!=3 & w_cat_2!=2
gen aux_ot6 = month_nonagri_3	if  w_cat_3!=3 & w_cat_3!=2
gen aux_ot7 = month_nonagri_4	if  w_cat_4!=3 & w_cat_4!=2


*<_isenp_m_>
*<_isenp_m_note_> Self-employed income in the non- principal occupation - monetary *</_isenp_m_note_>
egen isenp_m = rsum(aux_se2 aux_se3 aux_se4 aux_se5 aux_se6 aux_se7), missing
*</_isenp_m_>

*<_isenp_nm_>
*<_isenp_nm_note_> Self-employed income in the non- principal occupation - non-monetary *</_isenp_nm_note_>
gen isenp_nm = .
*</_isenp_nm_>

*<_iempnp_m_>
*<_iempnp_m_note_> Income by employer in the non-principal occupation - monetary *</_iempnp_m_note_>
egen iempnp_m = rsum(aux_em2 aux_em3 aux_em4 aux_em5 aux_em6 aux_em7), missing
*</_iempnp_m_>

*<_iempnp_nm_>
*<_iempnp_nm_note_> Income by employer in the non- principal occupation - non-monetary *</_iempnp_nm_note_>
gen iempnp_nm = .
*</_iempnp_nm_>

*<_iolnp_m_>
*<_iolnp_m_note_> Other labor income in the non-principal - monetary occupation *</_iolnp_m_note_>
egen iolnp_m = rsum(aux_ot2 aux_ot3 aux_ot4 aux_ot5 aux_ot6 aux_ot7), missing
*</_iolnp_m_>

*<_iolnp_nm_>
*<_iolnp_nm_note_> Other labor income in the non-principal occupation - non-monetary *</_iolnp_nm_note_>
gen iolnp_nm = .
*</_iolnp_nm_>
drop aux_se* aux_em* aux_ot*


*<_ijubi_con_>
*<_ijubi_con_note_> Income for retirement and contributory pensions *</_ijubi_con_note_>
gen ijubi_con = .
*</_ijubi_con_>

*<_ijubi_ncon_>
*<_ijubi_ncon_note_> Income for retirement and non-contributory pensions *</_ijubi_ncon_note_>
gen ijubi_ncon = .
*</_ijubi_ncon_>

*<_ijubi_o_>
*<_ijubi_o_note_> Income for retirement and pensions (not identified if contributory or not) *</_ijubi_o_note_>
gen ijubi_o = .
*</_ijubi_o_>



*<_icap_>
*<_icap_note_> Income from capital *</_icap_note_>
egen icap = rsum(S8BQ01 S8BQ02 S8BQ04 S8BQ12), missing
*</_icap_>



*<_icct_>
*<_icct_note_> Income from conditional cash transfer programs *</_icct_note_>
gen icct = .
*</_icct_>

*<_inocct_m_>
*<_inocct_m_note_> Income from public transfers not CCT - monetary *</_inocct_m_note_>
egen inocct_m = rsum(S8BQ06 ssn_cash), missing
*</_inocct_m_>

*<_inocct_nm_>
*<_inocct_nm_note_> Income from public transfers not CCT - non-monetary *</_inocct_nm_note_>
egen inocct_nm = rsum(S8BQ07 ssn_kind)
*</_inocct_nm_>

*<_itrane_ns_>
*<_itrane_ns_note_> Income from unspecified public transfers *</_itrane_ns_note_>
gen itrane_ns = .
*</_itrane_ns_>



*<_itranext_m_>
*<_itranext_m_note_> Income from foreign remittances - monetary *</_itranext_m_note_>
egen itranext_m = rsum(S8BQ09), missing
*</_itranext_m_>

*<_itranext_nm_>
*<_itranext_nm_note_> Revenue from remittances from abroad - non-monetary *</_itranext_nm_note_>
gen itranext_nm = .
*</_itranext_nm_>

*<_itranint_m_>
*<_itranint_m_note_> Income by private transfers from the country - monetary *</_itranint_m_note_>
egen itranint_m = rsum(S8BQ08), missing
*</_itranint_m_>

*<_itranint_nm_>
*<_itranint_nm_note_> Income by private transfers from the country - non-monetary *</_itranint_nm_note_>
gen itranint_nm = .
*</_itranint_nm_>

*<_itran_ns_>
*<_itran_ns_note_> Income from unspecified private transfers *</_itran_ns_note_>
gen itran_ns =.
*</_itran_ns_>



*<_inla_otro_>
*<_inla_otro_note_> Other non-labor income *</_inla_otro_note_>
egen inla_otro = rsum(S8BQ11 S8BQ13), missing
*</_inla_otro_>


*<_renta_imp_>
*<_renta_imp_note_> Imputed rent for own-housing *</_renta_imp_note_>
egen renta_imp = rsum(housing_rent), missing
*</_renta_imp_>

*<_members_>
*<_members_note_> Number of members of the household *</_members_note_>
gen  uno = 1
egen members = sum(uno), by(hhid)
*</_members_>

drop S8BQ01-S9D1Q05

*<_Save data file_>
do   "P:\SARMD\SARDATABANK\SARMDdofiles\_aux\SecondOrder_INC.do"
save "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`filename'.dta", replace
*</_Save data file_>
