/*------------------------------------------------------------------------------
GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	BGD_2022_HIES_v01_M_v01_A_SARMD_LBR.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   	07-2023									   </_Date created_>
<_Date modified>    July 2023								  </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	BGD											    </_Country_>
<_Survey Title_>   	HIES									   </_Survey Title_>
<_Survey Year_>    	2022										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				07-2023
File:				BGD_2022_HIES_v01_M_v01_A_SARMD_LBR.do
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
global module       	"LBR"
local yearfolder   	"`code'_`year'_`survey'"
local SARMDfolder  	"`yearfolder'_v`vm'_M_v`va'_A_SARMD"
local filename     	"`yearfolder'_v`vm'_M_v`va'_A_SARMD_LBR"
*</_Program setup_>


*<_Datalibweb request_>
use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
sort  PSU HHID PID
merge 1:1 PSU HHID PID using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_INC.dta" 
drop _merge
sort  pid
merge 1:1 pid  using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
drop _merge
*** There are 2 households included in INC but not in IND (check this)
*</_Datalibweb request_>


*<_countrycode_>
*<_countrycode_note_> country code *</_countrycode_note_>
/*<_countrycode_note_> iso3 code upper letter *</_countrycode_note_>*/
*<_countrycode_note_> countrycode brought in from SARMD *</_countrycode_note_>
*</_countrycode_>

*<_year_>
*<_year_note_> Year *</_year_note_>
/*<_year_note_> field work start at *</_year_note_>*/
*<_year_note_> year brought in from SARMD *</_year_note_>
*</_year_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
/*<_hhid_note_> . *</_hhid_note_>*/
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
*</_hhid_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
/*<_pid_note_> country specific *</_pid_note_>*/
*<_pid_note_> pid brought in from SARMD *</_pid_note_>
*</_pid_>

*<_weight_>
*<_weight_note_> Household weight *</_weight_note_>
/*<_weight_note_> . *</_weight_note_>*/
*<_weight_note_> weight brought in from SARMD *</_weight_note_>
clonevar weight = wgt
*</_weight_>

*<_weighttype_>
*<_weighttype_note_> Weight type (frequency, probability, analytical, importance) *</_weighttype_note_>
/*<_weighttype_note_> . *</_weighttype_note_>*/
*<_weighttype_note_> weighttype brought in from SARMD *</_weighttype_note_>
*gen weighttype = "PW"
*</_weighttype_>

*<_age_>
*<_age_note_> Age of individual (continuous) *</_age_note_>
/*<_age_note_>  *</_age_note_>*/
*<_age_note_> age brought in from SARMD *</_age_note_>
*</_age_>

*<_minlaborage_>
*<_minlaborage_note_> Labor module application age *</_minlaborage_note_>
/*<_minlaborage_note_>  *</_minlaborage_note_>*/
*<_minlaborage_note_> lb_mod_age brought in from SARMD *</_minlaborage_note_>
gen minlaborage = lb_mod_age
*</_minlaborage_>

*<_minlaborage_year_>
*<_minlaborage_year_note_> Labor module application age (12-mon ref period) *</_minlaborage_year_note_>
/*<_minlaborage_year_note_>  *</_minlaborage_year_note_>*/
*<_minlaborage_year_note_> lb_mod_age brought in from SARMD *</_minlaborage_year_note_>
gen minlaborage_year = lb_mod_age
*</_minlaborage_year_>

*<_lstatus_>
*<_lstatus_note_> Labor status *</_lstatus_note_>
/*<_lstatus_note_> 1 "Employed" 2 "Unemployed" 3 "Not in labor force" *</_lstatus_note_>*/
*<_lstatus_note_> lstatus brought in from SARMD *</_lstatus_note_>
*</_lstatus_>

*<_lstatus_year_>
*<_lstatus_year_note_> Labor status (12-mon ref period) *</_lstatus_year_note_>
/*<_lstatus_year_note_> 1 "Employed" 2 "Unemployed" 3 "Not in labor force" *</_lstatus_year_note_>*/
*<_lstatus_year_note_> lstatus_year brought in from rawdata *</_lstatus_year_note_>
egen auxi = rsum(daylab_cash_1 daylab_kind_1 employee_cash_1 employee_kind_1 agri_net_1 month_nonagri_1), missing	

gen   lstatus_year = 1		if  auxi!=0 & auxi!=.
notes lstatus: the HIES only allows to identify those who were employed at some point in the last 12 months
drop auxi 
*</_lstatus_year_>

*<_nlfreason_>
*<_nlfreason_note_> Reason not in the labor force *</_nlfreason_note_>
/*<_nlfreason_note_>  1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5"Others" *</_nlfreason_note_>*/
*<_nlfreason_note_> nlfreason brought in from SARMD *</_nlfreason_note_>
*</_nlfreason_>

*<_nlfreason_year_>
*<_nlfreason_year_note_> Reason not in the labor force (12-mon ref period) *</_nlfreason_year_note_>
/*<_nlfreason_year_note_>  1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5"Others" *</_nlfreason_year_note_>*/
*<_nlfreason_year_note_> nlfreason_year brought in from rawdata *</_nlfreason_year_note_>
gen   nlfreason_year = .
notes nlfreason_year: the HIES does not contain the information needed to define this variable
*</_nlfreason_year_>

*<_unempldur_l_>
*<_unempldur_l_note_> Unemployment duration (months) lower bracket *</_unempldur_l_note_>
/*<_unempldur_l_note_>  *</_unempldur_l_note_>*/
*<_unempldur_l_note_> unempldur_l brought in from SARMD *</_unempldur_l_note_>
*</_unempldur_l_>

*<_unempldur_u_>
*<_unempldur_u_note_> Unemployment duration (months) upper bracket *</_unempldur_u_note_>
/*<_unempldur_u_note_>  *</_unempldur_u_note_>*/
*<_unempldur_u_note_> unempldur_u brought in from SARMD *</_unempldur_u_note_>
*</_unempldur_u_>

*<_unempldur_l_year_>
*<_unempldur_l_year_note_> Unemployment duration (months) lower bracket (12-mon ref period) *</_unempldur_l_year_note_>
/*<_unempldur_l_year_note_>  *</_unempldur_l_year_note_>*/
*<_unempldur_l_year_note_> unempldur_l_year brought in from rawdata *</_unempldur_l_year_note_>
gen   unempldur_l_year = .
notes unempldur_l_year: the HIES does not contain the information needed to define this variable
*</_unempldur_l_year_>

*<_unempldur_u_year_>
*<_unempldur_u_year_note_> Unemployment duration (months) upper bracket (12-mon ref period) *</_unempldur_u_year_note_>
/*<_unempldur_u_year_note_>  *</_unempldur_u_year_note_>*/
*<_unempldur_u_year_note_> unempldur_u_year brought in from rawdata *</_unempldur_u_year_note_>
gen   unempldur_u_year=.
notes unempldur_u_year: the HIES does not contain the information needed to define this variable
*</_unempldur_u_year_>

*<_empstat_>
*<_empstat_note_> Employment status *</_empstat_note_>
/*<_empstat_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_note_>*/
*<_empstat_note_> empstat brought in from SARMD *</_empstat_note_>
*</_empstat_>

*<_empstat_2_>
*<_empstat_2_note_> Employment status - second job *</_empstat_2_note_>
/*<_empstat_2_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_2_note_>*/
*<_empstat_2_note_> empstat_2 brought in from SARMD *</_empstat_2_note_>
*</_empstat_2_>

*<_empstat_year_>
*<_empstat_year_note_> Employment status, primary job (12-mon ref period) *</_empstat_year_note_>
/*<_empstat_year_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_year_note_>*/
*<_empstat_year_note_> empstat_year brought in from SARMD *</_empstat_year_note_>
*</_empstat_year_>

*<_empstat_2_year_>
*<_empstat_2_year_note_> Employment status - second job (12-mon ref period) *</_empstat_2_year_note_>
/*<_empstat_2_year_note_> 1 "Paid Employee" 2 "Non-Paid Employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status" *</_empstat_2_year_note_>*/
*<_empstat_2_year_note_> empstat_2_year brought in from SARMD *</_empstat_2_year_note_>
*</_empstat_2_year_>

*<_ocusec_>
*<_ocusec_note_> Sector of activity *</_ocusec_note_>
/*<_ocusec_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_note_>*/
*<_ocusec_note_> ocusec brought in from SARMD *</_ocusec_note_>
*</_ocusec_>

*<_ocusec_2_>
*<_ocusec_2_note_> Sector of activity for second job *</_ocusec_2_note_>
/*<_ocusec_2_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_2_note_>*/
*<_ocusec_2_note_> ocusec_2 brought in from rawdata *</_ocusec_2_note_>
gen   ocusec_2 = .
notes ocusec_2: the HIES does not contain the information needed to define this variable
*</_ocusec_2_>

*<_ocusec_year_>
*<_ocusec_year_note_> Sector of activity, primary job (12-mon ref period) *</_ocusec_year_note_>
/*<_ocusec_year_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_year_note_>*/
*<_ocusec_year_note_> ocusec_year brought in from rawdata *</_ocusec_year_note_>
gen     ocusec_year = .
replace ocusec_year = 1 		if  S4BQ06_1==1 | S4BQ06_1==2 | S4BQ06_1==4 | S4BQ06_1==6 
replace ocusec_year = 2 		if  S4BQ06_1==3 | S4BQ06_1==5 | S4BQ06_1==8 | S4BQ06_1==7
notes   ocusec_year: variable defined only for workers working as paid employees
*</_ocusec_year_>

*<_ocusec_2_year_>
*<_ocusec_2_year_note_> Sector of activity for second job (12-mon ref period) *</_ocusec_2_year_note_>
/*<_ocusec_2_year_note_> 1 "Public sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish" *</_ocusec_2_year_note_>*/
*<_ocusec_2_year_note_> ocusec_2_year brought in from rawdata *</_ocusec_2_year_note_>
gen     ocusec_2_year = .
replace ocusec_2_year = 1 	if  S4BQ06_2==1 | S4BQ06_2==2 | S4BQ06_2==4 | S4BQ06_2==6 
replace ocusec_2_year = 2 	if  S4BQ06_2==3 | S4BQ06_2==5 | S4BQ06_2==8 | S4BQ06_2==7
notes   ocusec_2_year: variable defined only for workers working as paid employees
*</_ocusec_2_year_>

*<_industry_orig_>
*<_industry_orig_note_> original industry codes *</_industry_orig_note_>
/*<_industry_orig_note_>  *</_industry_orig_note_>*/
*<_industry_orig_note_> industry_orig brought in from SARMD *</_industry_orig_note_>
*</_industry_orig_>

*<_industrycat10_>
*<_industrycat10_note_> 1 digit industry classification *</_industrycat10_note_>
/*<_industrycat10_note_> 1 "Agriculture, Hunting, Fishing, etc." 2 "Mining" 3 "Manufacturing" 4 "Public Utility Services" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Others *</_industrycat10_note_>*/
*<_industrycat10_note_> industrycat10 brought in from rawdata *</_industrycat10_note_>
gen   industrycat10 = .
notes industrycat10: HIES does not collect information on sector of employment (industry) in the last 7 days
*</_industrycat10_>

*<_industrycat4_>
*<_industrycat4_note_> 1 digit industry classification (Broad Economic Activities) *</_industrycat4_note_>
/*<_industrycat4_note_> 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other" *</_industrycat4_note_>*/
*<_industrycat4_note_> industrycat4 brought in from rawdata *</_industrycat4_note_>
gen   industrycat4 = .
notes industrycat4: HIES does not collect information on sector of employment (industry) in the last 7 days
*</_industrycat4_>

*<_industry_orig_2_>
*<_industry_orig_2_note_> original industry codes for second job *</_industry_orig_2_note_>
/*<_industry_orig_2_note_>  *</_industry_orig_2_note_>*/
*<_industry_orig_2_note_> industry_orig_2 brought in from SARMD *</_industry_orig_2_note_>
*</_industry_orig_2_>

*<_industrycat10_2_>
*<_industrycat10_2_note_> 1 digit industry classification for second job *</_industrycat10_2_note_>
/*<_industrycat10_2_note_> 1 "Agriculture, Hunting, Fishing, etc." 2 "Mining" 3 "Manufacturing" 4 "Public Utility Services" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Others *</_industrycat10_2_note_>*/
*<_industrycat10_2_note_> industrycat10_2 brought in from rawdata *</_industrycat10_2_note_>
gen   industrycat10_2 = .
notes industrycat10_2: HIES does not collect information on sector of employment (industry) in the last 7 days
*</_industrycat10_2_>

*<_industrycat4_2_>
*<_industrycat4_2_note_> 1 digit industry classification (Broad Economic Activities) for second job *</_industrycat4_2_note_>
/*<_industrycat4_2_note_> 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other" *</_industrycat4_2_note_>*/
*<_industrycat4_2_note_> industrycat4_2 brought in from rawdata *</_industrycat4_2_note_>
gen   industrycat4_2 = .
notes industrycat4_2: HIES does not collect information on sector of employment (industry) in the last 7 days
*</_industrycat4_2_>

*<_industry_orig_year_>
*<_industry_orig_year_note_> Original industry code, primary job (12-mon ref period) *</_industry_orig_year_note_>
/*<_industry_orig_year_note_>  *</_industry_orig_year_note_>*/
*<_industry_orig_year_note_> industry_orig_year brought in from SARMD *</_industry_orig_year_note_>
*</_industry_orig_year_>

*<_industry_year_>
*<_industry_year_note_> 1 digit industry classification - main job - last 12 months *</_industry_year_note_>
/*<_industry_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any individual with a job (lstatus=1) and is missing otherwise. The codes for the main job are given here based on the UN-ISIC (Rev. 3.1). The main categories subsume the following codes: 1 = Agriculture, Hunting, Fishing and Forestry 2 = Mining 3 = Manufacturing 4 = Electricity and Utilities 5 = Construction 6 = Commerce 7 = Transportation, Storage and Communication 8 = Financial, Insurance and Real Estate 9 = Public Administration 10 = Other Services. In the case of different classifications, recoding has been done to best match the ISIC-31 codes. Code 10 is also assigned for unspecified categories or items. *</_industry_year_note_>*/
*<_industry_year_note_>  *</_industry_year_note_>
gen 	industry_year = .
replace industry_year = 1			if  S4AQ01B_1==1  | S4AQ01B_1==2 | S4AQ01B_1==5
replace industry_year = 2			if  S4AQ01B_1>=10 & S4AQ01B_1<=14
replace industry_year = 3  		if  S4AQ01B_1>=15 & S4AQ01B_1<=37
replace industry_year = 4			if  S4AQ01B_1==40 | S4AQ01B_1==41
replace industry_year = 5			if  S4AQ01B_1==45
replace industry_year = 6  		if  S4AQ01B_1>=50 & S4AQ01B_1<=55
replace industry_year = 7 		if  S4AQ01B_1>=60 & S4AQ01B_1<=64
replace industry_year = 8 		if  S4AQ01B_1>=65 & S4AQ01B_1<=74
replace industry_year = 9			if  S4AQ01B_1==75
replace industry_year = 10		if  S4AQ01B_1>=80 & S4AQ01B_1<=99
*</_industry_year_>

*<_industrycat10_year_>
*<_industrycat10_year_note_> 1 digit industry classification, primary job (12-mon ref period) *</_industrycat10_year_note_>
/*<_industrycat10_year_note_> 1 "Agriculture, Hunting, Fishing, etc." 2 "Mining" 3 "Manufacturing" 4 "Public Utility Services" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Others *</_industrycat10_year_note_>*/
*<_industrycat10_year_note_> industrycat10_year brought in from SARMD *</_industrycat10_year_note_>
gen industrycat10_year = industry_year
*</_industrycat10_year_>

*<_industrycat4_year_>
*<_industrycat4_year_note_> 4-category industry classification primary job (12-mon ref period) *</_industrycat4_year_note_>
/*<_industrycat4_year_note_> 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other" *</_industrycat4_year_note_>*/
*<_industrycat4_year_note_> industrycat4_year brought in from rawdata *</_industrycat4_year_note_>
gen    industrycat4_year = industrycat10_year
recode industrycat4_year (1 = 1) (2/5 = 2) (6/9 = 3) (10 = 4)
*</_industrycat4_year_>

*<_industry_orig_2_year_>
*<_industry_orig_2_year_note_> original industry codes for second job (12-mon ref period) *</_industry_orig_2_year_note_>
/*<_industry_orig_2_year_note_>  *</_industry_orig_2_year_note_>*/
*<_industry_orig_2_year_note_> industry_orig_2_year brought in from SARMD *</_industry_orig_2_year_note_>
*</_industry_orig_2_year_>

*<_industry_2_year_>
*<_industry_2_year_note_>  1 digit industry classification - second job - last 12 months *</_industry_2_year_note_>
/*<_industry_2_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country.
Classifies the seco *</_industry_2_year_note_>*/
*<_industry_2_year_note_>  *</_industry_2_year_note_>
gen 	industry_2_year = .
replace industry_2_year = 1		if  S4AQ01B_2==1  | S4AQ01B_2==2 | S4AQ01B_2==5
replace industry_2_year = 2		if  S4AQ01B_2>=10 & S4AQ01B_2<=14
replace industry_2_year = 3  		if  S4AQ01B_2>=15 & S4AQ01B_2<=37
replace industry_2_year = 4		if  S4AQ01B_2==40 | S4AQ01B_2==41
replace industry_2_year = 5		if  S4AQ01B_2==45
replace industry_2_year = 6  		if  S4AQ01B_2>=50 & S4AQ01B_2<=55
replace industry_2_year = 7 		if  S4AQ01B_2>=60 & S4AQ01B_2<=64
replace industry_2_year = 8 		if  S4AQ01B_2>=65 & S4AQ01B_2<=74
replace industry_2_year = 9		if  S4AQ01B_2==75
replace industry_2_year = 10		if  S4AQ01B_2>=80 & S4AQ01B_2<=99
*</_industry_2_year_>

*<_industrycat10_2_year_>
*<_industrycat10_2_year_note_> 1 digit industry classification for second job (12-mon ref period) *</_industrycat10_2_year_note_>
/*<_industrycat10_2_year_note_> 1 "Agriculture, Hunting, Fishing, etc." 2 "Mining" 3 "Manufacturing" 4 "Public Utility Services" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Others *</_industrycat10_2_year_note_>*/
*<_industrycat10_2_year_note_> industrycat10_2_year brought in from SARMD *</_industrycat10_2_year_note_>
gen industrycat10_2_year = industry_2_year
*</_industrycat10_2_year_>

*<_industrycat4_2_year_>
*<_industrycat4_2_year_note_> 4-category industry classification, secondary job (12-mon ref period) *</_industrycat4_2_year_note_>
/*<_industrycat4_2_year_note_> 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other" *</_industrycat4_2_year_note_>*/
*<_industrycat4_2_year_note_> industrycat4_2_year brought in from rawdata *</_industrycat4_2_year_note_>
gen    industrycat4_2_year = industrycat10_2_year
recode industrycat4_2_year (1 = 1) (2/5 = 2) (6/9 = 3) (10 = 4)
*</_industrycat4_2_year_>

*<_occup_>
*<_occup_note_> 1 digit occupational classification *</_occup_note_>
/*<_occup_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified"  *</_occup_note_>*/
*<_occup_note_> occup brought in from SARMD *</_occup_note_>
*</_occup_>

*<_occup_year_>
*<_occup_year_note_> 1 digit occupational classification, primary job (12-mon ref period) *</_occup_year_note_>
/*<_occup_year_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified"  *</_occup_year_note_>*/
*<_occup_year_note_> occup_year brought in from SARMD *</_occup_year_note_>
*</_occup_year_>

*<_occup_orig_>
*<_occup_orig_note_> original occupation code *</_occup_orig_note_>
/*<_occup_orig_note_>  *</_occup_orig_note_>*/
*<_occup_orig_note_> occup_orig brought in from rawdata *</_occup_orig_note_>
gen   occup_orig = .
notes occup_orig: HIES does not collect information on occupational status for the main job in the last 7 days
*</_occup_orig_>

*<_occup_orig_year_>
*<_occup_orig_year_note_> Original occupational classification, primary job (12-mon ref period) *</_occup_orig_year_note_>
/*<_occup_orig_year_note_>  *</_occup_orig_year_note_>*/
*<_occup_orig_year_note_> occup_orig_year brought in from rawdata *</_occup_orig_year_note_>
gen occup_orig_year = S4AQ01A_1
*</_occup_orig_year_>

*<_occup_2_>
*<_occup_2_note_> 1 digit occupational classification for second job *</_occup_2_note_>
/*<_occup_2_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified"  *</_occup_2_note_>*/
*<_occup_2_note_> occup_2 brought in from rawdata *</_occup_2_note_>
capture gen   occup_2 = .
notes occup_2: HIES does not collect information on occupational status for the main job in the last 7 days
*</_occup_2_>

*<_occup_2_year_>
*<_occup_2_year_note_> 1 digit occupational classification, secondary job (12-mon ref period) *</_occup_2_year_note_>
/*<_occup_2_year_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified"  *</_occup_2_year_note_>*/
*<_occup_2_year_note_> occup_2_year brought in from rawdata *</_occup_2_year_note_>
gen     occup_2_year = .
replace occup_2_year = 1		if  S4AQ01A_2==20 | S4AQ01A_2==21  | S4AQ01A_2==30  | S4AQ01A_2==40  | S4AQ01A_2==50  
replace occup_2_year = 2		if  S4AQ01A_2==2  | S4AQ01A_2==4   | (S4AQ01A_2>=6  & S4AQ01A_2<=13) | (S4AQ01A_2>=15 & S4AQ01A_2<=19)
replace occup_2_year = 3		if  S4AQ01A_2==1  | S4AQ01A_2==3   | S4AQ01A_2==5   | S4AQ01A_2==14  | S4AQ01A_2==42  | S4AQ01A_2==43  | S4AQ01A_2==44 | S4AQ01A_2==86
replace occup_2_year = 4		if (S4AQ01A_2>=31 & S4AQ01A_2<=33) | (S4AQ01A_2>=37 & S4AQ01A_2<=39)
replace occup_2_year = 5		if  S4AQ01A_2==36 | S4AQ01A_2==45  | (S4AQ01A_2>=51 & S4AQ01A_2<=54) | S4AQ01A_2==49  | S4AQ01A_2==58  | S4AQ01A_2==59 
replace occup_2_year = 6		if  S4AQ01A_2==70 | S4AQ01A_2==60  | S4AQ01A_2==61  | S4AQ01A_2==63  | S4AQ01A_2==64
replace occup_2_year = 7		if  S4AQ01A_2==71 | S4AQ01A_2==72  | (S4AQ01A_2>=75 & S4AQ01A_2<=85) | (S4AQ01A_2>=87 & S4AQ01A_2<=89) | S4AQ01A_2==92 
replace occup_2_year = 8		if  S4AQ01A_2==34 | S4AQ01A_2==35  | S4AQ01A_2==74  | S4AQ01A_2==90  | S4AQ01A_2==91
replace occup_2_year = 9		if  S4AQ01A_2==55 | S4AQ01A_2==56    
*</_occup_2_year_>

*<_occup_year_>
*<_occup_year_note_> 1 digit occupational classification *</_occup_year_note_>
/*<_occup_year_note_> Variable is constructed for all persons administered this module in each questionnaire. For this reason the lower age cutoff (and perhaps upper age cutoff) at which information is collected will vary from country to country. Classifies the main job of any indiviudal with a job (lstatus=1) and is missing otherwise. The classification is based on the International Standard Classification of Occupations (ISCO) 88. In the case of different classifications re-coding has been done to best match the ISCO-88. *</_occup_year_note_>*/
*<_occup_year_note_> 1 "Managers" 2 "Professionals" 3 "Technicians and associate professionals" 4 "Clerical support workers" 5 "Service and sales workers" 6 "Skilled agricultural, forestry and fishery workers" 7 "Craft and related trades workers" 8 "Plant and machine operators, and assemblers" 9 "Elementary occupations" 10 "Armed forces occupations" 99 "Other/unspecified" *</_occup_year_note_>
gen     occup_year = .
replace occup_year = 1		if  S4AQ01A_1==20 | S4AQ01A_1==21  | S4AQ01A_1==30  | S4AQ01A_1==40  | S4AQ01A_1==50  
replace occup_year = 2		if  S4AQ01A_1==2  | S4AQ01A_1==4   | (S4AQ01A_1>=6  & S4AQ01A_1<=13) | (S4AQ01A_1>=15 & S4AQ01A_1<=19)
replace occup_year = 3		if  S4AQ01A_1==1  | S4AQ01A_1==3   | S4AQ01A_1==5   | S4AQ01A_1==14  | S4AQ01A_1==42  | S4AQ01A_1==43  | S4AQ01A_1==44 | S4AQ01A_1==86
replace occup_year = 4		if (S4AQ01A_1>=31 & S4AQ01A_1<=33) | (S4AQ01A_1>=37 & S4AQ01A_1<=39)
replace occup_year = 5		if  S4AQ01A_1==36 | S4AQ01A_1==45  | (S4AQ01A_1>=51 & S4AQ01A_1<=54) | S4AQ01A_1==49  | S4AQ01A_1==58  | S4AQ01A_1==59 
replace occup_year = 6		if  S4AQ01A_1==70 | S4AQ01A_1==60  | S4AQ01A_1==61  | S4AQ01A_1==63  | S4AQ01A_1==64
replace occup_year = 7		if  S4AQ01A_1==71 | S4AQ01A_1==72  | (S4AQ01A_1>=75 & S4AQ01A_1<=85) | (S4AQ01A_1>=87 & S4AQ01A_1<=89) | S4AQ01A_1==92 
replace occup_year = 8		if  S4AQ01A_1==34 | S4AQ01A_1==35  | S4AQ01A_1==74  | S4AQ01A_1==90  | S4AQ01A_1==91
replace occup_year = 9		if  S4AQ01A_1==55 | S4AQ01A_1==56  
*</_occup_>

*<_occup_orig_2_>
*<_occup_orig_2_note_> original occupation code for second job *</_occup_orig_2_note_>
/*<_occup_orig_2_note_>  *</_occup_orig_2_note_>*/
*<_occup_orig_2_note_> occup_orig_2 brought in from rawdata *</_occup_orig_2_note_>
gen   occup_orig_2 = .
notes occup_orig_2: HIES does not collect information on occupational status for the main job in the last 7 days
*</_occup_orig_2_>

*<_occup_orig_2_year_>
*<_occup_orig_2_year_note_> Original occupational classification, secondary job (12-mon ref period) *</_occup_orig_2_year_note_>
/*<_occup_orig_2_year_note_>  *</_occup_orig_2_year_note_>*/
*<_occup_orig_2_year_note_> occup_orig_2_year brought in from rawdata *</_occup_orig_2_year_note_>
gen occup_orig_2_year = S4AQ01A_2
*</_occup_orig_2_year_>

*<_wage_nc_>
*<_wage_nc_note_> Last wage payment *</_wage_nc_note_>
/*<_wage_nc_note_>  *</_wage_nc_note_>*/
*<_wage_nc_note_> wage_nc brought in from rawdata *</_wage_nc_note_>
gen   wage_nc = .
notes wage_nc: HIES does not collect information on labor income for the main job in the last 7 days
*</_wage_nc_>

*<_wage_nc_2_>
*<_wage_nc_2_note_> Last wage payment second job *</_wage_nc_2_note_>
/*<_wage_nc_2_note_>  *</_wage_nc_2_note_>*/
*<_wage_nc_2_note_> wage_nc_2 brought in from rawdata *</_wage_nc_2_note_>
gen   wage_nc_2 = .
notes wage_nc_2: HIES does not collect information on labor income for the secondary job in the last 7 days
*</_wage_nc_2_>

*<_wage_nc_year_>
*<_wage_nc_year_note_> Last wage payment, primary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_year_note_>
/*<_wage_nc_year_note_>  *</_wage_nc_year_note_>*/
*<_wage_nc_year_note_> wage_nc_year brought in from rawdata *</_wage_nc_year_note_>
egen wage_nc_year = rsum(daylab_cash_1 employee_cash_1 agri_net_1 month_nonagri_1), missing
*</_wage_nc_year_>

*<_wage_nc_2_year_>
*<_wage_nc_2_year_note_> last wage payment, secondary job, excl. bonuses, etc. (12-mon ref period) *</_wage_nc_2_year_note_>
/*<_wage_nc_2_year_note_>  *</_wage_nc_2_year_note_>*/
*<_wage_nc_2_year_note_> wage_nc_2_year brought in from rawdata *</_wage_nc_2_year_note_>
egen wage_nc_2_year = rsum(daylab_cash_2 employee_cash_2 agri_net_2 month_nonagri_2), missing
*</_wage_nc_2_year_>

*<_unitwage_>
*<_unitwage_note_> Last wages time unit *</_unitwage_note_>
/*<_unitwage_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_note_>*/
*<_unitwage_note_> unitwage brought in from SARMD *</_unitwage_note_>
*</_unitwage_>

*<_unitwage_2_>
*<_unitwage_2_note_> Last wages time unit second job *</_unitwage_2_note_>
/*<_unitwage_2_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_2_note_>*/
*<_unitwage_2_note_> unitwage_2 brought in from SARMD *</_unitwage_2_note_>
*</_unitwage_2_>

*<_unitwage_year_>
*<_unitwage_year_note_> Time unit of last wages payment, primary job (12-mon ref period) *</_unitwage_year_note_>
/*<_unitwage_year_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_year_note_>*/
*<_unitwage_year_note_> unitwage_year brought in from rawdata *</_unitwage_year_note_>
gen  unitwage_year = 5
note unitwage_year: last wage payment is harmonized to be expressed in monthly basis
*</_unitwage_year_>

*<_unitwage_2_year_>
*<_unitwage_2_year_note_> Time unit of last wages payment, secondary job (12-mon ref period) *</_unitwage_2_year_note_>
/*<_unitwage_2_year_note_> 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months" 5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other" *</_unitwage_2_year_note_>*/
*<_unitwage_2_year_note_> unitwage_2_year brought in from rawdata *</_unitwage_2_year_note_>
gen  unitwage_2_year = 5
note unitwage_2_year: last wage payment is harmonized to be expressed in monthly basis
*</_unitwage_2_year_>

*<_whours_>
*<_whours_note_> Hours of work in last week *</_whours_note_>
/*<_whours_note_>  *</_whours_note_>*/
*<_whours_note_> whours brought in from SARMD *</_whours_note_>
*</_whours_>

*<_whours_2_>
*<_whours_2_note_> Hours of work in last week for the secondary job *</_whours_2_note_>
/*<_whours_2_note_>  *</_whours_2_note_>*/
*<_whours_2_note_> whours_2 brought in from rawdata *</_whours_2_note_>
gen   whours_2 = .
notes whours_2: HIES does not collect information on hours of work for the secondary job in the last 7 days
*</_whours_2_>

*<_whours_year_>
*<_whours_year_note_> Hours of work in last week, primary job (12-mon ref period) *</_whours_year_note_>
/*<_whours_year_note_>  *</_whours_year_note_>*/
*<_whours_year_note_> whours_year brought in from rawdata *</_whours_year_note_>
gen whours_year = round(hours_1/(12*4.2))
*</_whours_year_>

*<_whours_2_year_>
*<_whours_2_year_note_> Hours of work in last week, secondary job (12-mon ref period) *</_whours_2_year_note_>
/*<_whours_2_year_note_>  *</_whours_2_year_note_>*/
*<_whours_2_year_note_> whours_2_year brought in from rawdata *</_whours_2_year_note_>
gen whours_2_year = round(hours_2/(12*4.2))
*</_whours_2_year_>

*<_wmonths_>
*<_wmonths_note_> Months worked in the last 12 months *</_wmonths_note_>
/*<_wmonths_note_>  *</_wmonths_note_>*/
*<_wmonths_note_> wmonths brought in from rawdata *</_wmonths_note_>
gen   wmonths = .
notes wmonths: HIES does not collect information on months of work for the main job in the last 7 days
*</_wmonths_>

*<_wmonths_2_>
*<_wmonths_2_note_> Months worked in the last 12 months for the secondary job *</_wmonths_2_note_>
/*<_wmonths_2_note_>  *</_wmonths_2_note_>*/
*<_wmonths_2_note_> wmonths_2 brought in from rawdata *</_wmonths_2_note_>
gen   wmonths_2 = .
notes wmonths_2: HIES does not collect information on months of work for the secondary job in the last 7 days
*</_wmonths_2_>

*<_wmonths_year_>
*<_wmonths_year_note_> Months worked in the last 12 months, primary job (12-mon ref period) *</_wmonths_year_note_>
/*<_wmonths_year_note_>  *</_wmonths_year_note_>*/
*<_wmonths_year_note_> wmonths_year brought in from rawdata *</_wmonths_year_note_>
gen wmonths_year = months_1
*</_wmonths_year_>

*<_wmonths_2_year_>
*<_wmonths_2_year_note_> Months worked in the last 12 months, secondary job (12-mon ref period) *</_wmonths_2_year_note_>
/*<_wmonths_2_year_note_>  *</_wmonths_2_year_note_>*/
*<_wmonths_2_year_note_> wmonths_2_year brought in from rawdata *</_wmonths_2_year_note_>
gen wmonths_2_year = months_2
*</_wmonths_2_year_>

*<_wage_total_>
*<_wage_total_note_> Primary job total wage  *</_wage_total_note_>
/*<_wage_total_note_>  *</_wage_total_note_>*/
*<_wage_total_note_> wage_total brought in from rawdata *</_wage_total_note_>
gen   wage_total = .
notes wage_total: HIES does not collect information on labor income for the main job in the last 7 days
*</_wage_total_>

*<_wage_total_2_>
*<_wage_total_2_note_> Secondary job total wage  *</_wage_total_2_note_>
/*<_wage_total_2_note_>  *</_wage_total_2_note_>*/
*<_wage_total_2_note_> wage_total_2 brought in from rawdata *</_wage_total_2_note_>
gen   wage_total_2 = .
notes wage_total_2: HIES does not collect information on labor income for the secondary job in the last 7 days
*</_wage_total_2_>

*<_wage_total_year_>
*<_wage_total_year_note_> Annualized total wage, primary job (12-mon ref period) *</_wage_total_year_note_>
/*<_wage_total_year_note_>  *</_wage_total_year_note_>*/
*<_wage_total_year_note_> wage_total_year brought in from rawdata *</_wage_total_year_note_>
egen    wage_total_year = rsum(daylab_cash_1 employee_cash_1 agri_net_1 month_nonagri_1 daylab_kind_1 employee_kind_1), missing
replace wage_total_year = wage_total_year*12
*</_wage_total_year_>

*<_wage_total_2_year_>
*<_wage_total_2_year_note_> Annualized total wage, secondary job (12-mon ref period) *</_wage_total_2_year_note_>
/*<_wage_total_2_year_note_>  *</_wage_total_2_year_note_>*/
*<_wage_total_2_year_note_> wage_total_2_year brought in from rawdata *</_wage_total_2_year_note_>
egen    wage_total_2_year = rsum(daylab_cash_2 employee_cash_2 agri_net_2 month_nonagri_2 daylab_kind_2 employee_kind_2), missing
replace wage_total_2_year = wage_total_2_year*12
*</_wage_total_2_year_>

*<_contract_>
*<_contract_note_> Contract *</_contract_note_>
/*<_contract_note_> 1 "Yes" 0 "No" *</_contract_note_>*/
*<_contract_note_> contract brought in from rawdata *</_contract_note_>
*</_contract_>

*<_contract_year_>
*<_contract_year_note_> Contract (12-mon ref period) *</_contract_year_note_>
/*<_contract_year_note_> 1 "Yes" 0 "No" *</_contract_year_note_>*/
*<_contract_year_note_> contract_year brought in from rawdata *</_contract_year_note_>
gen   contract_year = .
notes contract_year: the HIES does not collect information on labour contract for the main job in the last 12 months
*</_contract_year_>

*<_healthins_>
*<_healthins_note_> Health insurance *</_healthins_note_>
/*<_healthins_note_> 1 "Yes" 0 "No" *</_healthins_note_>*/
*<_healthins_note_> healthins brought in from rawdata *</_healthins_note_>
*</_healthins_>

*<_healthins_year_>
*<_healthins_year_note_> Health insurance (12-mon ref period) *</_healthins_year_note_>
/*<_healthins_year_note_> 1 "Yes" 0 "No" *</_healthins_year_note_>*/
*<_healthins_year_note_> healthins_year brought in from rawdata *</_healthins_year_note_>
gen   healthins_year = .
notes healthins_year: the HIES does not collect information on health insurance from employment for the main job in the last 12 months
*</_healthins_year_>

*<_socialsec_>
*<_socialsec_note_> Social security *</_socialsec_note_>
/*<_socialsec_note_> 1 "Yes" 0 "No" *</_socialsec_note_>*/
*<_socialsec_note_> socialsec brought in from rawdata *</_socialsec_note_>
*</_socialsec_>

*<_socialsec_year_>
*<_socialsec_year_note_> Social security (12-mon ref period) *</_socialsec_year_note_>
/*<_socialsec_year_note_> 1 "Yes" 0 "No" *</_socialsec_year_note_>*/
*<_socialsec_year_note_> socialsec_year brought in from rawdata *</_socialsec_year_note_>
gen   socialsec_year = .
notes socialsec_year: the HIES does not collect information on social security rights from employment for the main job in the last 12 months
*</_socialsec_year_>

*<_union_>
*<_union_note_> Union membership *</_union_note_>
/*<_union_note_> 1 "Yes" 0 "No" *</_union_note_>*/
*<_union_note_> union brought in from rawdata *</_union_note_>
*</_union_>

*<_union_year_>
*<_union_year_note_> Union membership (12-mon ref period) *</_union_year_note_>
/*<_union_year_note_> 1 "Yes" 0 "No" *</_union_year_note_>*/
*<_union_year_note_> union_year brought in from rawdata *</_union_year_note_>
gen   union_year = .
notes union_year: the HIES does not collect information on union membership for the main job in the last 12 months
*</_union_year_>

*<_firmsize_l_>
*<_firmsize_l_note_> Firm size (lower bracket) *</_firmsize_l_note_>
/*<_firmsize_l_note_>  *</_firmsize_l_note_>*/
*<_firmsize_l_note_> firmsize_l brought in from SARMD *</_firmsize_l_note_>
*</_firmsize_l_>

*<_firmsize_u_>
*<_firmsize_u_note_> Firm size (upper bracket) *</_firmsize_u_note_>
/*<_firmsize_u_note_>  *</_firmsize_u_note_>*/
*<_firmsize_u_note_> firmsize_u brought in from SARMD *</_firmsize_u_note_>
*</_firmsize_u_>

*<_firmsize_l_year_>
*<_firmsize_l_year_note_> Firm size (lower bracket) (12-mon ref period) *</_firmsize_l_year_note_>
/*<_firmsize_l_year_note_>  *</_firmsize_l_year_note_>*/
*<_firmsize_l_year_note_> firmsize_l_year brought in from rawdata *</_firmsize_l_year_note_>
gen   firmsize_l_year = .
notes firmsize_l_year: the HIES does not collect information on firm size
*</_firmsize_l_year_>

*<_firmsize_u_year_>
*<_firmsize_u_year_note_> Firm size (upper bracket) (12-mon ref period) *</_firmsize_u_year_note_>
/*<_firmsize_u_year_note_>  *</_firmsize_u_year_note_>*/
*<_firmsize_u_year_note_> firmsize_u_year brought in from rawdata *</_firmsize_u_year_note_>
gen   firmsize_u_year = .
notes firmsize_u_year: the HIES does not collect information on firm size
*</_firmsize_u_year_>

*<_firmsize_l_2_>
*<_firmsize_l_2_note_> Firm size (lower bracket) for the secondary job *</_firmsize_l_2_note_>
/*<_firmsize_l_2_note_>  *</_firmsize_l_2_note_>*/
*<_firmsize_l_2_note_> firmsize_l_2 brought in from rawdata *</_firmsize_l_2_note_>
gen   firmsize_l_2 = .
notes firmsize_l_2: the HIES does not collect information on firm size
*</_firmsize_l_2_>

*<_firmsize_u_2_>
*<_firmsize_u_2_note_> Firm size (upper bracket) for the secondary job *</_firmsize_u_2_note_>
/*<_firmsize_u_2_note_>  *</_firmsize_u_2_note_>*/
*<_firmsize_u_2_note_> firmsize_u_2 brought in from rawdata *</_firmsize_u_2_note_>
gen   firmsize_u_2 = .
notes firmsize_u_2: the HIES does not collect information on firm size
*</_firmsize_u_2_>

*<_firmsize_l_2_year_>
*<_firmsize_l_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_l_2_year_note_>
/*<_firmsize_l_2_year_note_>  *</_firmsize_l_2_year_note_>*/
*<_firmsize_l_2_year_note_> firmsize_l_2_year brought in from rawdata *</_firmsize_l_2_year_note_>
gen   firmsize_l_2_year = .
notes firmsize_l_2_year: the HIES does not collect information on firm size
*</_firmsize_l_2_year_>

*<_firmsize_u_2_year_>
*<_firmsize_u_2_year_note_> Firm size (lower bracket), secondary job (12-mon ref period) *</_firmsize_u_2_year_note_>
/*<_firmsize_u_2_year_note_>  *</_firmsize_u_2_year_note_>*/
*<_firmsize_u_2_year_note_> firmsize_u_2_year brought in from rawdata *</_firmsize_u_2_year_note_>
gen   firmsize_u_2_year = .
notes firmsize_u_2_year: the HIES does not collect information on firm size
*</_firmsize_u_2_year_>

*<_t_wage_nc_others_>
*<_t_wage_nc_others_note_> Annualized wage in all jobs excluding the primary and secondary ones (excluding tips, bonuses, etc.). *</_t_wage_nc_others_note_>
/*<_t_wage_nc_others_note_>  *</_t_wage_nc_others_note_>*/
*<_t_wage_nc_others_note_> t_wage_nc_others brought in from rawdata *</_t_wage_nc_others_note_>
gen   t_wage_nc_others = .
notes t_wage_nc_others: the HIES does not include the information needed to define this variable
*</_t_wage_nc_others_>

*<_t_hours_others_>
*<_t_hours_others_note_> Total hours of work in the last 12 months in other jobs excluding the primary and secondary ones *</_t_hours_others_note_>
/*<_t_hours_others_note_>  *</_t_hours_others_note_>*/
*<_t_hours_others_note_> t_hours_others brought in from rawdata *</_t_hours_others_note_>
gen   t_hours_others = .
notes t_hours_others: the HIES does not include the information needed to define this variable
*</_t_hours_others_>

*<_t_wage_others_>
*<_t_wage_others_note_> Annualized wage (including tips, bonuses, etc.) in all other jobs excluding the primary and secondary ones. *</_t_wage_others_note_>
/*<_t_wage_others_note_>  *</_t_wage_others_note_>*/
*<_t_wage_others_note_> t_wage_others brought in from rawdata *</_t_wage_others_note_>
gen   t_wage_others = .
notes t_wage_others: the HIES does not include the information needed to define this variable
*</_t_wage_others_>

*<_t_hours_total_>
*<_t_hours_total_note_> Annualized hours worked in all jobs (7-day ref period) *</_t_hours_total_note_>
/*<_t_hours_total_note_>  *</_t_hours_total_note_>*/
*<_t_hours_total_note_> t_hours_total brought in from rawdata *</_t_hours_total_note_>
gen   t_hours_total = .
notes t_hours_total: the HIES does not include the information needed to define this variable
*</_t_hours_total_>

*<_t_wage_nc_total_>
*<_t_wage_nc_total_note_> Annualized wage in all jobs excl. bonuses, etc. (7-day ref period) *</_t_wage_nc_total_note_>
/*<_t_wage_nc_total_note_>  *</_t_wage_nc_total_note_>*/
*<_t_wage_nc_total_note_> t_wage_nc_total brought in from rawdata *</_t_wage_nc_total_note_>
gen   t_wage_nc_total = .
notes t_wage_nc_total: the HIES does not include the information needed to define this variable
*</_t_wage_nc_total_>

*<_t_wage_total_>
*<_t_wage_total_note_> Annualized total wage for all jobs (7-day ref period) *</_t_wage_total_note_>
/*<_t_wage_total_note_>  *</_t_wage_total_note_>*/
*<_t_wage_total_note_> t_wage_total brought in from rawdata *</_t_wage_total_note_>
gen   t_wage_total = .
notes t_wage_total: the HIES does not include the information needed to define this variable
*</_t_wage_total_>


*<_t_hours_others_year_>
*<_t_hours_others_year_note_> Annualized hours worked in all but primary and secondary jobs (12-mon ref period) *</_t_hours_others_year_note_>
/*<_t_hours_others_year_note_>  *</_t_hours_others_year_note_>*/
*<_t_hours_others_year_note_> t_hours_others_year brought in from rawdata *</_t_hours_others_year_note_>
egen t_hours_others_year = rsum(hours_3 hours_4), missing
*</_t_hours_others_year_>

*<_t_wage_nc_others_year_>
*<_t_wage_nc_others_year_note_> Annualized wage in all but primary & secondary jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_others_year_note_>
/*<_t_wage_nc_others_year_note_>  *</_t_wage_nc_others_year_note_>*/
*<_t_wage_nc_others_year_note_> t_wage_nc_others_year brought in from rawdata *</_t_wage_nc_others_year_note_>
egen    t_wage_nc_others_year = rsum(daylab_cash_3 employee_cash_3 daylab_cash_4 employee_cash_4 agri_net_3 month_nonagri_3 agri_net_4 month_nonagri_4), missing
replace t_wage_nc_others_year = t_wage_nc_others_year*12
*</_t_wage_nc_others_year_>

*<_t_wage_others_year_>
*<_t_wage_others_year_note_> Annualized wage in all but primary and secondary jobs (12-mon ref period) *</_t_wage_others_year_note_>
/*<_t_wage_others_year_note_>  *</_t_wage_others_year_note_>*/
*<_t_wage_others_year_note_> t_wage_others_year brought in from rawdata *</_t_wage_others_year_note_>
egen    t_wage_others_year = rsum(daylab_cash_3 employee_cash_3 daylab_cash_4 employee_cash_4 daylab_kind_3 employee_kind_3 daylab_kind_4 employee_kind_4 agri_net_3 month_nonagri_3 agri_net_4 month_nonagri_4), missing
replace t_wage_others_year = t_wage_nc_others_year*12
*</_t_wage_others_year_>

*<_t_hours_total_year_>
*<_t_hours_total_year_note_> Annualized hours worked in all jobs (12-mon ref period) *</_t_hours_total_year_note_>
/*<_t_hours_total_year_note_>  *</_t_hours_total_year_note_>*/
*<_t_hours_total_year_note_> t_hours_total_year brought in from rawdata *</_t_hours_total_year_note_>
egen t_hours_total_year = rsum(hours_1 hours_2 hours_3 hours_4), missing
*</_t_hours_total_year_>

*<_t_wage_nc_total_year_>
*<_t_wage_nc_total_year_note_> Annualized wage in all jobs excl. bonuses, etc. (12-mon ref period) *</_t_wage_nc_total_year_note_>
/*<_t_wage_nc_total_year_note_>  *</_t_wage_nc_total_year_note_>*/
*<_t_wage_nc_total_year_note_> t_wage_nc_total_year brought in from rawdata *</_t_wage_nc_total_year_note_>
gen aux_wage_nc_1_year = wage_nc_year*12
gen aux_wage_nc_2_year = wage_nc_2_year*12

egen t_wage_nc_total_year = rsum(aux_wage_nc_1_year aux_wage_nc_2_year t_wage_nc_others_year), missing
drop aux_wage*
*</_t_wage_nc_total_year_>

*<_t_wage_total_year_>
*<_t_wage_total_year_note_> Annualized total wage for all jobs (12-mon ref period) *</_t_wage_total_year_note_>
/*<_t_wage_total_year_note_>  *</_t_wage_total_year_note_>*/
*<_t_wage_total_year_note_> t_wage_total_year brought in from rawdata *</_t_wage_total_year_note_>
egen t_wage_total_year = rsum(wage_total_year wage_total_2_year t_wage_others_year), missing
*</_t_wage_total_year_>

*<_njobs_>
*<_njobs_note_> Total number of jobs *</_njobs_note_>
/*<_njobs_note_>  *</_njobs_note_>*/
*<_njobs_note_> njobs brought in from rawdata *</_njobs_note_>
*</_njobs_>

*<_t_hours_annual_>
*<_t_hours_annual_note_> Total hours worked in all jobs in the previous 12 months *</_t_hours_annual_note_>
/*<_t_hours_annual_note_>  *</_t_hours_annual_note_>*/
*<_t_hours_annual_note_> t_hours_annual brought in from rawdata *</_t_hours_annual_note_>
clonevar t_hours_annual = t_hours_total_year
*</_t_hours_annual_>

*<_linc_nc_>
*<_linc_nc_note_> Total annual wage income in all jobs, excl. bonuses, etc. *</_linc_nc_note_>
/*<_linc_nc_note_>  *</_linc_nc_note_>*/
*<_linc_nc_note_> linc_nc brought in from rawdata *</_linc_nc_note_>
gen linc_nc = t_wage_nc_total_year
*</_linc_nc_>

*<_laborincome_>
*<_laborincome_note_> Total annual individual labor income in all jobs, incl. bonuses, etc. *</_laborincome_note_>
/*<_laborincome_note_>  *</_laborincome_note_>*/
*<_laborincome_note_> laborincome brought in from rawdata *</_laborincome_note_>
gen laborincome = t_wage_total_year
*</_laborincome_>

*<_industry_orig_year_>
*<_industry_orig_year_note_> Original industry codes - main job - last 12 months *</_industry_orig_year_note_>
/*<_industry_orig_year_note_>  *</_industry_orig_year_note_>*/
*<_industry_orig_year_note_>   *</_industry_orig_year_note_>
gen   industry_orig_year = S4AQ01B_1
notes industry_orig_year: Original variable for sector of employment is S4AQ01B. It is converted to S4AQ01B_1 when defining main job (based on income)
*</_industry_orig_year_>

*<_industry_orig_2_year_>
*<_industry_orig_2_year_note_> Original industry codes - second job - last 12 months *</_industry_orig_2_year_note_>
/*<_industry_orig_2_year_note_> This variable correspond to whatever is in the original file with no recoding *</_industry_orig_2_year_note_>*/
*<_industry_orig_2_year_note_>  *</_industry_orig_2_year_note_>
gen   industry_orig_2_year = S4AQ01B_2
notes industry_orig_2_year: Original variable for sector of employment is S4AQ01B. It is converted to S4AQ01B_2 when defining main job (based on income)
*</_industry_orig_2_year_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save 		"$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`filename'.dta", replace
*</_Save data file_>
