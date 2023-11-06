/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	BGD_2022_HIES_v01_M_v01_A_SARMD_IDN.do		</_Program name_>
<_Application_>    	STATA 17.0									<_Application_>
<_Author(s)_>      	Leo Tornarolli 	<tornarolli@gmail.com>		</_Author(s)_>
<_Date created_>   	06-2023										</_Date created_>
<_Date modified>    June 2023									</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	BGD											</_Country_>
<_Survey Title_>   	HIES										</_Survey Title_>
<_Survey Year_>    	2022										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				06-2023
File:				BGD_2022_HIES_v01_M_v01_A_SARMD_IDN.do
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
glo   module       "IDN"
local yearfolder   "`code'_`year'_`survey'"
local SARMDfolder  "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
local filename     "`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_${module}"
*</_Program setup_>

*<_Folder creation_>
cap mkdir "$rootdatalib\GMD"
cap mkdir "$rootdatalib\GMD\\`code'"
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'"
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'"
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data"
cap mkdir "$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized"
*</_Folder creation_>


*<_Datalibweb request_>
/*
* VARIABLES FROM (IND-SARMD) MODULE
*datalibweb, country(`code') year(`year') type(`type') survey(`survey') vermast(`vm') veralt(`va') mod(IND) clear 
use "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\BGD_2022_HIES_v01_M_v01_A_SARMD_IND.dta", clear
*/

* VARIABLES FROM (IND-SARMD) MODULE
*
use "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\BGD_2022_HIES_v01_M_v01_A_SARMD_IND.dta", clear
*/
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

*<_int_year_>
*<_int_year_note_> interview year *</_int_year_note_>
/*<_int_year_note_> . *</_int_year_note_>*/
*<_int_year_note_> int_year brought in from SARMD *</_int_year_note_>
*</_int_year_>

*<_int_month_>
*<_int_month_note_> interview month *</_int_month_note_>
/*<_int_month_note_> . *</_int_month_note_>*/
*<_int_month_note_> int_month brought in from SARMD *</_int_month_note_>
*</_int_month_>

*<_hhid_>
*<_hhid_note_> Household identifier  *</_hhid_note_>
/*<_hhid_note_> . *</_hhid_note_>*/
*<_hhid_note_> hhid brought in from SARMD *</_hhid_note_>
*</_hhid_>

*<_hhid_org_>
*<_hhid_org_note_>  Household identifier in the raw data  *</_hhid_org_note_>
/*<_hhid_org_note_> Household identifier variables in the raw data are PSU and HHID *</_hhid_org_note_>*/
*<_hhid_org_note_>  hhid_org brought in from SARMD *</_hhid_org_note_>
gen hhid_orig = idh_org
*</_hhid_org_>

*<_pid_>
*<_pid_note_> Personal identifier  *</_pid_note_>
/*<_pid_note_> country specific *</_pid_note_>*/
*<_pid_note_> pid brought in from SARMD *</_pid_note_>
*</_pid_>

*<_pid_orig_>
*<_pid_orig_note_> Personal identifier in the raw data  *</_pid_orig_note_>
/*<_pid_orig_note_> country specific *</_pid_orig_note_>*/
*<_pid_orig_note_> pid_orig brought in from SARMD *</_pid_orig_note_>
gen pid_orig = idp_org
*</_pid_orig_>

*<_hhidkeyvars_>
*<_hhidkeyvars_note_>  Variables used to construct Household identifier  *</_hhidkeyvars_note_>
/*<_hhidkeyvars_note_> Household identifier variables in the raw data are PSU and HHID *</_hhidkeyvars_note_>*/
*<_hhidkeyvars_note_>  hhidkeyvars brought in from SARMD *</_hhidkeyvars_note_>
gen hhidkeyvars = "PSU HHID"
*</_hhidkeyvars_>

*<_pidkeyvars_>
*<_pidkeyvars_note_>  Variables used to construct Personal identifier  *</_pidkeyvars_note_>
/*<_pidkeyvars_note_> Personal identifier variables in the raw data are PSU, HHID and PID *</_pidkeyvars_note_>*/
*<_pidkeyvars_note_>  pidkeyvars brought in from SARMD *</_pidkeyvars_note_>
gen pidkeyvars = "PSU HHID PID"
*</_pidkeyvars_>

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
*</_weighttype_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid 
*</_Keep variables_>


*<_Save data file_>
do   "P:\SARMD\SARDATABANK\SARMDdofiles\_aux\Labels_SARMD.do"
save "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
