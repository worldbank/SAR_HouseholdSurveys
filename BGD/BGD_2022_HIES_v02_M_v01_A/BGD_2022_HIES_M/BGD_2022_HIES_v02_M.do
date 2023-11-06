/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   		BGD_2022_HIES_v01_M.do				   </_Program name_>
<_Application_>    		STATA 17.0							     <_Application_>
<_Author(s)_>      		acastillocastill@worldbank.org	          </_Author(s)_>
<_Author(s)_>      		tornarolli@gmail.com	          		  </_Author(s)_>
<_Date created_>   		10-28-2023	                           </_Date created_>
<_Date modified>   		19-10-2023	                          </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        		BGD											</_Country_>
<_Survey Title_>   		HIES								   </_Survey Title_>
<_Survey Year_>    		2022									</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:					19-10-2023
File:					BGD_2022_HIES_v01_M.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

global cpiver       	"09"
local code         	"BGD"
local year         	"2022"
local survey       	"HIES"
local vm           	"02"
local yearfolder   	"`code'_`year'_`survey'"
global input       	"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
global output      	"${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata"
*</_Program setup_>

	
*<_Datalibweb request_>

***************************************************************************************************
**** INCOME
***************************************************************************************************
* INDIVIDUAL ROSTER
tempfile roster
use "${input}\HH_SEC_1A1.dta", clear
drop TERM S1AQ0A S1AQ08-S1AQ15 S1AQ04-S1AQ06
rename  S1AQ00 PID
order PSU HHID PID
 save    `roster'

* INCOMES FROM SECTION 4: DAY LABOURERS and EMPLOYEES    
* Day labourers (S4AQ07==1 | S4AQ08==1)                                                      
* Employees     (S4AQ07==4 | S4AQ08==4)   
tempfile sect4
use "${input}\HH_SEC_4A.dta", clear
keep if  S4AQ08==1 | S4AQ07==1 | S4AQ08==4 | S4AQ07==4
drop if  S4AQ02==. & S4AQ03==. & S4AQ04==.
gen PID = S4AQ00

*******************************************************************************************************************************
* Merge with weights database
merge m:1 PSU HHID using "${input}\weight_final_2022.dta", keepusing (domain16 hh_wgt pop_wgt urbrural div rmo)
drop if _merge==2
	
****** 1 - CALCULATE MEDIANS  
	
*** A - By stratum and industry
foreach var in S4BQ02C S4BQ05B S4BQ08 S4BQ09 {
	gen medstr`var' = .
	}
levelsof domain16, 	local(strat)
levelsof S4AQ01B, 		local(industry)
foreach var in S4BQ02C S4BQ05B S4BQ08 S4BQ09 {
			foreach s of local strat {
				foreach i of local industry {
					qui sum `var' [aw=hh_wgt] 				if  domain16==`s' & S4AQ01B==`i' & `var'!=0, detail
					qui replace medstr`var' = r(p50) 		if  domain16==`s' & S4AQ01B==`i' & medstr`var'==.
					}
				}
			}

*** B - By urban/rural and industry		 
foreach var in S4BQ02C S4BQ05B S4BQ08 S4BQ09 {
	gen medur`var' = .
	}
levelsof urbrural, 	local(strat)
levelsof S4AQ01B, 		local(industry)	  	 
foreach var in S4BQ02C S4BQ05B S4BQ08 S4BQ09 {
	 	    foreach s of local strat {
	            foreach i of local industry {
				    qui sum `var' [aw=hh_wgt] 				if  urbrural==`s' & S4AQ01B==`i' & `var'!=0, detail
		            qui replace medur`var' = r(p50) 			if  urbrural==`s' & S4AQ01B==`i' & medur`var'==.
					}
				} 
			}
	  	   	  
*** C - By industry
foreach var in S4BQ02C S4BQ05B S4BQ08 S4BQ09 {
	gen medcnt`var' = .
	}
levelsof S4AQ01B, 		local(industry)	 
foreach var in S4BQ02C S4BQ05B S4BQ08 S4BQ09 {
	  	    foreach i of local industry {
				qui sum `var' [aw=hh_wgt] 				if  S4AQ01B==`i' & `var'!=0, detail
				replace medcnt`var' = r(p50) 			if  medcnt`var'==.
				}
			}
   
   
****** 2 - COUNT NUMBER OF OBS WITHIUT MISSINGS AND ZERIOS BY STRATUM, URBAN AND RURAL, AND INDUSTRY 		
foreach var in S4BQ02C S4BQ05B S4BQ08 S4BQ09 {
	bysort domain16 S4AQ01B:  egen countstratum16`var'	= count(`var') 	if  `var'!=0
	bysort urbrural S4AQ01B:  egen countarea`var'		= count(`var') 	if  `var'!=0
	}
	  
 	
****** 3 - We impute the MEDIAN values at different levels. We start from the lowest (stratum) to the highest level (national)
noi di as error "Replacing missing values by stratum median values per industry"	
replace S4BQ02C = medstrS4BQ02C 		if  S4BQ02C==. & S4BQ01==1 & countstratum16S4BQ02C>30
replace S4BQ05B = medstrS4BQ05B 		if  S4BQ05B==. & S4BQ03==1 & countstratum16S4BQ05B>30
replace  S4BQ08 = medstrS4BQ08 		if   S4BQ08==. & S4BQ01==2 & countstratum16S4BQ08>30
replace  S4BQ09 = medstrS4BQ09 		if   S4BQ09==. & S4BQ01==2 & countstratum16S4BQ09>30
noi di as error "Replacing missing values by urban/rural median values per industry"	
replace S4BQ02C = medurS4BQ02C 		if  S4BQ02C==. & S4BQ01==1 & countareaS4BQ02C>30
replace S4BQ05B = medurS4BQ05B 		if  S4BQ05B==. & S4BQ03==1 & countareaS4BQ05B>30
replace  S4BQ08 = medurS4BQ08 		if   S4BQ08==. & S4BQ01==2 & countareaS4BQ08>30
replace  S4BQ09 = medurS4BQ09 		if   S4BQ09==. & S4BQ01==2 & countareaS4BQ09>30
noi di as error "Replacing missing values by country median values per industry"	
replace S4BQ02C = medcntS4BQ02C 		if  S4BQ02C==. & S4BQ01==1 
replace S4BQ05B = medcntS4BQ05B 		if  S4BQ05B==. & S4BQ03==1
replace  S4BQ08 = medcntS4BQ08 		if  S4BQ08==.  & S4BQ01==2
replace  S4BQ09 = medcntS4BQ09 		if  S4BQ09==.  & S4BQ01==2
*******************************************************************************************************************************

* Monthly Income of those working as day labourers
* S4BQ02C: What was the daily wage in cash in the past 12 months? (TAKA)
* S4BQ05B: How much did you receive in-kind per day? (TAKA)
*  S4AQ03: On average, how many days per month did you work?
*  S4AQ02: How many months did you do this activity in the last 12 months?
gen daylab_cash = S4BQ02C * S4AQ03 * (S4AQ02/12)	if  S4BQ01==1 	
gen daylab_kind = S4BQ05B * S4AQ03 * (S4AQ02/12)	if  S4BQ01==1 & S4BQ03==1

* Monthly Income of those working as employees
* S4BQ08: What is your total net take-home monthly remuneration after all deduction at source?
* S4BQ09: What is the total value of in-kind or other benefits you received over the past 12 months?
gen employee_cash = S4BQ08							if  S4BQ01==2
gen employee_kind = S4BQ09/12						if  S4BQ01==2

order PSU HHID PID S4AQ0A
sort  PSU HHID PID S4AQ0A
drop  TERM S4AQ00 S4AQ0A S4AQ05A S4AQ05B S4BQ01 S4BQ02A S4BQ02B S4BQ02C S4BQ03 S4BQ04 S4BQ05A S4BQ05B S4BQ07 S4BQ08 S4BQ09    
save `sect4'


**** INCOMES FROM SECTION 5: NON-AGRICULTURAL BUSINESSES                                               
* Self-Employed (S4AQ08==2)                                                         
* Employers     (S4AQ08==3) 
tempfile section4
tempfile sect5
tempfile section5
tempfile section5_1
tempfile section5_2
tempfile section5_2aux
tempfile section5_3

* Preparation of Section 4 (to be merged with Section 5)
use "${input}\HH_SEC_4A.dta", clear
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


* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
use "${input}\HH_SEC_05.dta", clear
rename *, upper

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
sort  PSU HHID PID
save `section5_1'	

* FOR THOSE WITH INCOME INFO BUT WITHOUT MATCHING EMPLOYMENT INFO
use "${input}\HH_SEC_05.dta", clear
rename *, upper
sort      PSU HHID
merge m:1 PSU HHID using `only_income_info'
drop if _merge!=3
drop _merge 
keep if S5Q00==1
keep PSU HHID S5Q01B month_nonagri
sort PSU HHID
save    `section5_2aux'

use "${input}\HH_SEC_4A.dta", clear
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
sort PSU HHID PID
gen  x2 = 1
save `section5_2'	

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

* Append Section 5
use          `section5_1'
append using `section5_2'
append using `section5_3'	

gen     anomalies = 1	if  x1==1
replace anomalies = 2	if  x2==1
replace anomalies = 3    if  x3==1
drop x*
sort PSU HHID PID
save    `sect5'


**** INCOMES FROM SECTION 7: AGRICULTURAL ACTIVITIES
* Self-Employed (S4AQ07==2)
* Employers     (S4AQ07==3)
tempfile section7
tempfile section4
use "${input}\HH_SEC_4A.dta", clear
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


**** Section 7B  - CROP PRODUCTION at household/crop level
tempfile section7b
use "${input}\HH_SEC_7B.dta", clear
keep if  S7BQ02==1
* S7BQ04A: How much in total of crop did you produce in the last 12 months? (kg)
* S7BQ04B: How much in total of crop did you produce in the last 12 months? (taka/kg)
*  S7BQ05: How much did your household consumed in the last 12 months?
*  S7BQ06: How much did your household sell in the last 12 months?
drop if S7BQ05==0 & S7BQ06==0

******************************************************************************************************************
merge m:1 PSU HHID using "${input}\weight_final_2022.dta", keepusing(domain16 hh_wgt pop_wgt urbrural div rmo)
drop if _merge==2

* Rural variable	 
gen rural = (urbrural==1)

****** 1 - We found outliers in the unit values (S7BQ04B) that were affecting the gini. 

* When S7BQ04A>0 and the unit value is zero we replace these values for missing and we use the medians to impute those prices
gen 	p = S7BQ04B
replace p = . 		if  (S7BQ04A>0 & S7BQ04A~=.) & p==0
gen   lnp = ln(p) 
	

* A - Identify and replace outliers as missings
levelsof S7BQ00, local (crop) 	
foreach f of local crop {
			sum p [aw=hh_wgt] 	if  S7BQ00==`f', detail	

			* When the variance of p exists and is different from zero we detect and delete outliers
			if r(Var)!=0 & r(Var)<. {
					levelsof domain16, local(strat)
					foreach s of local strat {
							sum p [aw=hh_wgt] 	if  p>0 & p<. & domain16==`s' & S7BQ00==`f'
							local antp = r(N)
							sum lnp [aw=hh_wgt] if  domain16==`s' & S7BQ00==`f', detail
							local ameanp = r(mean)
							local asdp   = r(sd)			
      						replace p = . 		if (abs((lnp-`ameanp')/`asdp')>3.5 & ~mi(lnp)) & domain16==`s' & S7BQ00==`f'
							count if p>0 & ~mi(p) & domain16==`s' & S7BQ00==`f'
							local postp = r(N)
							}
					}
			}
gen outlier = (p==.)

* B - Count number of observations without outliers
bysort domain16 S7BQ00: egen countstratum16 = count(p)
bysort rural    S7BQ00: egen countarea  = count(p)	
	
* C - Calculate medians 

* By stratum and crop	
levelsof domain16, local(strat)
levelsof S7BQ00,   local(crop)
gen medianstratum = . 
foreach s of local strat {
				foreach f of local crop {
					sum p [aw=hh_wgt] 				if  domain16==`s' & S7BQ00==`f' & p!=0, detail
					replace medianstratum = r(p50) 	if  domain16==`s' & S7BQ00==`f' & medianstratum==.
					}
				}		
		
* By urban/rural and crop		 
levelsof rural,  local(strat)
levelsof S7BQ00, local(crop)
gen medianarea = . 
foreach s of local strat {
				foreach f of local crop {
					sum p [aw=hh_wgt] 				if  rural==`s' & S7BQ00==`f' & p!=0, detail
					replace medianarea = r(p50) 		if  rural==`s' & S7BQ00==`f' & medianarea==.
					}
				}

* By country and crop
levelsof S7BQ00, local(crop)
gen mediancountry =.
foreach f of local crop {
				sum p [aw=hh_wgt] 					if  S7BQ00==`f' & p!=0, detail
				replace mediancountry = r(p50) 
				}
	  

* C - We impute the MEDIAN values at different levels. We start from the lowest (stratum) to the highest level (national)	
noi di as error "Replacing outliers by stratum median price per S7BQ00"	
replace p = medianstratum 		if  p==. & countstratum16>30
noi di as error "Replacing outliers by area median price per S7BQ00"	
replace p = medianarea 			if  p==. & countarea>30
noi di as error "Replacing outliers by country median price per S7BQ00"	
replace p = mediancountry 		if  p==. 
******************************************************************************************************************
replace S7BQ04B = p

gen crop_cons = S7BQ05 * S7BQ04B/12	
gen crop_sold = S7BQ06 * S7BQ04B/12	
collapse (sum) crop_cons crop_sold, by(PSU HHID)
sort  PSU HHID
save `section7b', replace


**** Section 7C1 - LIVESTOCK and POULTRY at household/animal level
tempfile section7c1
use "${input}\HH_SEC_7C1.dta", clear
* S7C1Q04B:  How many died/did your household sell in the last 12 months? (taka)
* S7C1Q05B:  How many did your household consume in the 12 months? (taka)
drop if S7C1Q04B==. & S7C1Q05B==.

gen livestock_cons = S7C1Q04B/12
gen livestock_sold = S7C1Q05B/12
collapse (sum) livestock_cons livestock_sold, by(PSU HHID)
sort  PSU HHID
save `section7c1', replace


**** Section 7C2 - LIVESTOCK and POULTRY BY-PRODUCTS at household/by-product level
tempfile section7c2
use "${input}\HH_SEC_7C2.dta", clear
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


**** Section 7C3 - FISH FARMING and FISH CAPTURE at household/fish level
tempfile section7c3
use "${input}\HH_SEC_7C3.dta", clear
* S7C3Q11B: How much did your household sell in the past 12 months? (taka)
* S7C3Q12B: How much did your household consume in the 12 months? (taka)
drop if S7C3Q11B==. & S7C3Q12B==.
gen fish_cons = S7C3Q12B/12
gen fish_sold = S7C3Q11B/12
collapse (sum) fish_cons fish_sold, by(PSU HHID)
sort  PSU HHID
save `section7c3', replace


**** Section 7C4 - FARM FORESTRY at household/tree level
tempfile section7c4
use "${input}\HH_SEC_7C4.dta", clear
*  S7C4Q15: How much did your household sell in the last 12 months? (taka)
*  S7C4Q16: How much did your household consume in the last 12 months? (taka)
drop if S7C4Q15==0 & S7C4Q16==0
drop if S7C4Q15==. & S7C4Q16==.
gen tree_cons = S7C4Q16/12
gen tree_sold = S7C4Q15/12
collapse (sum) tree_cons tree_sold, by(PSU HHID)
sort  PSU HHID
save `section7c4', replace


**** Section 7D - EXPENSES ON AGRICULTURAL INPUTS at household/input level
tempfile section7d
use "${input}\HH_SEC_7D.dta", clear
keep	if  S7DQ02==1
* S7DQ03B: How much did your household spend on the (item) in the last 12 months? (Taka)
gen     agri_expenditure = S7DQ03B/12
replace agri_expenditure = agri_expenditure*(-1)
collapse (sum) agri_expenditure, by(PSU HHID)
drop if agri_expenditure==0
sort  PSU HHID
save `section7d', replace


**** Section 7E - AGRICULTURAL ASSETS
tempfile section7e
use "${input}\HH_SEC_7E.dta", clear
gen agri_asset_inc = S7EQ04/12 	if  S7EQ00~=420
collapse (sum) agri_asset_inc, by(PSU HHID)
drop if agri_asset_inc==0
sort PSU HHID
save `section7e', replace


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


* FOR THOSE WITH INCOME INFO AND MATCHING EMPLOYMENT INFO
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


* FOR THOSE WITH INCOME INFO BUT WITHOUT MARCHING EMPLOYMENT INFO
tempfile section7_2
use "${input}\HH_SEC_4A.dta", clear
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


* FOR THOSE WITH INCOME INFO BUT WITHOUT EMPLOYMENT INFO AT ALL
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


* APPEND SECTION 7
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


* APPEND SECTIONS 4-5-7
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


**** Section 8 - OTHER INCOME 
tempfile sect8
use "${input}\HH_SEC_8B.dta", clear
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


**** Section 9 - HOUSING RENT 
tempfile sect9
use "${input}\HH_SEC_9D1.dta", clear
keep  if  S9D1Q02==42111
duplicates report PSU HHID
gen   housing_rent = S9D1Q05/12
sort  PSU HHID
save `sect9', replace

use `sect_4_5_7_8'
merge m:1 PSU HHID using `sect9'
drop _merge
sort PSU HHID PID

merge m:1 PSU HHID using `section7e'
drop _merge
sort  PSU HHID PID

tempfile sect_4_5_7_8_9
save    `sect_4_5_7_8_9'


**** Section 1C - SAFETY NETS
tempfile sect1
use "${input}\HH_SEC_1C.dta", clear
gen   PID = S1CQ00
order PSU HHID PID

*  S1CQ10A: How much did you receive in cash in last 12 months?
* S1CQ101D: How much did you receive in-kind in last 12 months? 1
* S1CQ102D: How much did you receive in-kind in last 12 months? 2
replace  S1CQ10A = .					if  S1CQ10A==0
replace  S1CQ10A = S1CQ10A/12
replace S1CQ101D = .					if  S1CQ101D==0
replace S1CQ101D = S1CQ101D/12
replace S1CQ102D = S1CQ102D/12
replace S1CQ102D = .					if  S1CQ102D==0
drop if S1CQ10A==. & S1CQ101D==. & S1CQ102D==.

egen    ssn_cash = rsum(S1CQ10A), missing
replace ssn_cash = 0 				if  S1CQ01==1 & (S1CQ02==20 | S1CQ02==21 | S1CQ02==22 | S1CQ02==23)

egen	ssn_kind = rsum(S1CQ101D S1CQ102D), missing

* Last payment
gen  snet_cash_last = S1CQ05A/12
egen snet_kind_last = rsum(S1CQ071D S1CQ072D) 	if  S1CQ06==1
replace snet_kind_last = snet_kind_last/12

replace ssn_cash = snet_cash_last		if (ssn_cash==. | ssn_cash==0) & snet_cash_last>0 & snet_cash_last<.
replace ssn_kind = snet_kind_last		if (ssn_kind==. | ssn_kind==0) & snet_kind_last>0 & snet_kind_last<.

collapse (sum) ssn_cash ssn_kind, by(PSU HHID PID)
sort  PSU HHID PID
save `sect1', replace

use `sect_4_5_7_8_9'
merge 1:1 PSU HHID PID using `sect1'
drop _merge
sort PSU HHID PID
tempfile sect_4_5_7_8_9_1
save `sect_4_5_7_8_9_1'


**** Section 2B - EDUCATIONAL STIPEND
use "${input}\HH_SEC_2B.dta", clear
tempfile stipend
gen PID = S2BQ00
gen stipend_inc = S2BQ06/12

collapse (sum) stipend_inc, by(PSU HHID PID)
sort PSU HHID PID
save `stipend'

use `sect_4_5_7_8_9_1'
merge 1:1 PSU HHID PID using `stipend'
drop _merge
sort PSU HHID PID
tempfile sect_4_5_7_8_9_1
save `sect_4_5_7_8_9_1'


use "${input}\weight_final_2022.dta"
sort PSU HHID
tempfile weight
save `weight'

use `sect_4_5_7_8_9_1'
merge m:1 PSU HHID using `weight'
drop _merge
sort PSU HHID PID
tempfile income
save `income'


**** Section 1A - HOUSEHOLD ROSTER
use "${input}\HH_SEC_1A.dta", clear
tempfile hh_roster
duplicates report PSU HHID
sort  PSU HHID
save `hh_roster'


**** Section 1A1 - INDIVIDUAL ROSTER
use "${input}\HH_SEC_1A1.dta", clear
tempfile ind_roster
duplicates report PSU HHID S1AQ00
gen   PID = S1AQ00
sort  PSU HHID PID
save `ind_roster'


**** Section 1A2 - DISABILITIES
use "${input}\HH_SEC_1A2.dta", clear
tempfile disabilities
duplicates report PSU HHID S1AQ0C
gen   PID = S1AQ0C
sort  PSU HHID PID
save `disabilities'


**** Section 1B - EMPLOYMENT LAST WEEK/MONTH
use "${input}\HH_SEC_1B.dta", clear
tempfile employment
duplicates report PSU HHID S1BQ00
gen   PID = S1BQ00
sort  PSU HHID PID
save `employment'


**** Section 4A - EMPLOYMENT 12 MONTHS
use "${input}\HH_SEC_4A.dta", clear 
tempfile employment12
collapse (sum) S4AQ02, by(PSU HHID S4AQ00)
gen aux_emp = 1	if  S4AQ02>0 & S4AQ02<.
gen   PID = S4AQ00
sort  PSU HHID PID
save `employment12'


**** Section 2A - EDUCATION/LITERACY AND ATTAINMENT
use "${input}\HH_SEC_2A.dta", clear
tempfile education_all
duplicates tag PSU HHID S2AQ00, gen(tag)
drop if S2AQ00==.
gen   PID = S2AQ00
sort  PSU HHID PID
save `education_all'


**** Section 2B - EDUCATION/ENROLLMENT
use "${input}\HH_SEC_2B.dta", clear
tempfile education_current
duplicates tag PSU HHID S2BQ00, gen(tag)
drop if S2BQ00==.
gen   PID = S2BQ00
sort  PSU HHID PID
save `education_current'


**** Section 7C1 - ASSETS/ANIMALS
use "${input}\HH_SEC_7C1.dta", clear
tempfile assets_animal
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
save `assets_animal'


**** Section 9E - ASSETS/MATERIALS
use "${input}\HH_SEC_9E.dta", clear
tempfile assets
keep PSU HHID S9EQ00 S9EQ01
rename  S9EQ00 item_
replace S9EQ01=999 	if  S9EQ01==.
reshape wide S9EQ01, i(PSU HHID) j(item_) 
duplicates report PSU HHID
rename S9EQ01* item_* 
sort  PSU HHID
save `assets'


**** Section 6A - HOUSING
use "${input}\HH_SEC_6A.dta", clear
tempfile housing
duplicates report PSU HHID
sort  PSU HHID
save `housing'


**** CONSUMPTION AND POVERTY
use "${input}\HIES2022_HH_08_16_23.dta", clear 
tempfile consumption
sort  PSU HHID
save `consumption'
		

**** Section 9C -  EXPENDITURES 1 (MONTHLY EXPENSES)
tempfile expenditures1
use "${input}\HH_SEC_9C.dta", clear
keep if S9CQ00==44111 | S9CQ00==44211 | S9CQ00==44311 | S9CQ00==44411 | S9CQ00==44412 | S9CQ00==45111 | S9CQ00==45211 | S9CQ00==45212 | S9CQ00==45213 | S9CQ00==45311 | S9CQ00==45411 | S9CQ00==45412 | S9CQ00==45413 | S9CQ00==45414 | S9CQ00==45415 | S9CQ00==45419 | S9CQ00==72211 | S9CQ00==72212 | S9CQ00==72213 | S9CQ00==72214 | S9CQ00==72215 | S9CQ00==72216 | S9CQ00==83011 | S9CQ00==83012 | S9CQ00==83013 | S9CQ00==83014

collapse (sum) S9CQ01 S9CQ02 S9CQ03, by(PSU HHID S9CQ00)
rename S9CQ01 S9CQ01_
rename S9CQ02 S9CQ02_
rename S9CQ03 S9CQ03_
keep PSU HHID S9CQ00 S9CQ01_ S9CQ02_ S9CQ03_
reshape wide S9CQ01_ S9CQ02_ S9CQ03_, j(S9CQ00) i(PSU HHID)
duplicates report PSU HHID
egen  hhid = concat(PSU HHID), punct(-)
sort  hhid
save `expenditures1'
	
	
**** Section 9D2 - EXPENDITURES 2 (ANNUAL EXPENSES)
tempfile expenditures2
use "${input}\HH_SEC_9D1.dta", clear
keep if S9D1Q02==43111 | S9D1Q02==43112 | S9D1Q02==43113 | S9D1Q02==43114 | S9D1Q02==43115 | S9D1Q02==43116 | S9D1Q02==43117 | S9D1Q02==43118 | S9D1Q02==43119 | S9D1Q02==431110 | S9D1Q02==431199| S9D1Q02==43211 | S9D1Q02==43212 | S9D1Q02==43213 | S9D1Q02==43214 | S9D1Q02==43215 | S9D1Q02==43219
rename S9D1Q05 S9D1Q05_
keep PSU HHID S9D1Q02 S9D1Q05_
reshape wide S9D1Q05_, j(S9D1Q02) i(PSU HHID)
duplicates report PSU HHID
egen  hhid = concat(PSU HHID), punct(-)
sort  hhid
save `expenditures2'
	
	
**** Section 7A - LANDHOLDING
use "${input}\HH_SEC_7A.dta", clear 
tempfile land
duplicates report PSU HHID
egen  hhid = concat(PSU HHID), punct(-)
sort  hhid
save `land'

	
***************************************************************************************************
**** MERGE DATASETS
***************************************************************************************************
* Individual-level datasets
use `ind_roster', clear
foreach i in disabilities employment employment12 education_all education_current income {
	merge 1:1 PSU HHID PID using  ``i'', keep(1 3) nogen
	}
	
* Household-level datasets
foreach j in hh_roster housing assets assets_animal land expenditures1 expenditures2 {
	merge m:1 PSU HHID using ``j'', keep(1 3) nogen
	}
	
	merge m:1 PSU HHID using `consumption', keep(3) nogen	
	
order  PSU HHID PID hh_wgt
sort   PSU HHID PID
*</_Datalibweb request_>


*<_Save data file_>
compress
save "${output}/`yearfolder'_v`vm'_M.dta", replace
*</_Save data file_>


