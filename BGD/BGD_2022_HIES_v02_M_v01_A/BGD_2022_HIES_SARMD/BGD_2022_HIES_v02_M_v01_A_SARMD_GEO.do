/*------------------------------------------------------------------------------
GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	BGD_2022_HIES_v01_M_v01_A_SARMD_GEO.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   	10-2023									   </_Date created_>
<_Date modified>   	October 2023							  </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	BGD											    </_Country_>
<_Survey Title_>   	HIES									   </_Survey Title_>
<_Survey Year_>    	2022										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				10-2023
File:				BGD_2022_HIES_v01_M_v01_A_SARMD_GEO.do
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
global module       	"GEO"
local yearfolder   	"`code'_`year'_`survey'"
local SARMDfolder  	"`yearfolder'_v`vm'_M_v`va'_A_SARMD"
local filename     	"`yearfolder'_v`vm'_M_v`va'_A_SARMD_GEO"
*</_Program setup_>


*<_Datalibweb request_>
use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
egen idh = concat(PSU HHID), punct(-)
egen idp = concat(idh PID), punct(-)
sort idp
merge 1:1 idp using "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`yearfolder'_v`vm'_M_v`va'_A_`type'_IND.dta" 
drop _merge
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
*</_weighttype_>

*<_subnatid1_>
*<_subnatid1_note_> Subnational ID - highest level *</_subnatid1_note_>
/*<_subnatid1_note_> code-name *</_subnatid1_note_>*/
*<_subnatid1_note_> subnatid1 brought in from rawdata *</_subnatid1_note_>
*</_subnatid1_>

*<_subnatid2_>
*<_subnatid2_note_> Subnational ID - second highest level *</_subnatid2_note_>
/*<_subnatid2_note_> code-name *</_subnatid2_note_>*/
*<_subnatid2_note_> subnatid2 brought in from rawdata *</_subnatid2_note_>
*</_subnatid2_>

*<_subnatid3_>
*<_subnatid3_note_> Subnational ID - third highest level *</_subnatid3_note_>
/*<_subnatid3_note_> code-name *</_subnatid3_note_>*/
*<_subnatid3_note_> subnatid3 brought in from rawdata *</_subnatid3_note_>
*</_subnatid3_>

*<_subnatid4_>
*<_subnatid4_note_> Subnational ID - lowest level *</_subnatid4_note_>
/*<_subnatid4_note_> code-name *</_subnatid4_note_>*/
*<_subnatid4_note_> subnatid4 brought in from rawdata *</_subnatid4_note_>
gen subnatid4 = ""
*</_subnatid4_>

*<_subnatidsurvey_>
*<_subnatidsurvey_note_> Survey representation of geographical units *</_subnatidsurvey_note_>
/*<_subnatidsurvey_note_> . *</_subnatidsurvey_note_>*/
*<_subnatidsurvey_note_> subnatidsurvey brought in from rawdata *</_subnatidsurvey_note_>
gen subnatidsurvey = .
*</_subnatidsurvey_>

*<_strata_>
*<_strata_note_> Strata *</_strata_note_>
/*<_strata_note_> . *</_strata_note_>*/
*<_strata_note_> strata brought in from rawdata *</_strata_note_>
*</_strata_>

*<_psu_>
*<_psu_note_> PSU *</_psu_note_>
/*<_psu_note_> . *</_psu_note_>*/
*<_psu_note_> psu brought in from rawdata *</_psu_note_>
*</_psu_>

*<_subnatid1_prev_>
*<_subnatid1_prev_note_> Subnatid *</_subnatid1_prev_note_>
/*<_subnatid1_prev_note_> . *</_subnatid1_prev_note_>*/
*<_subnatid1_prev_note_> subnatid1_prev brought in from rawdata *</_subnatid1_prev_note_>
gen subnatid1_prev = subnatid1
*</_subnatid1_prev_>

*<_subnatid2_prev_>
*<_subnatid2_prev_note_> Subnatid *</_subnatid2_prev_note_>
/*<_subnatid2_prev_note_> . *</_subnatid2_prev_note_>*/
*<_subnatid2_prev_note_> subnatid2_prev brought in from rawdata *</_subnatid2_prev_note_>
gen subnatid2_prev = subnatid2
*</_subnatid2_prev_>

*<_subnatid3_prev_>
*<_subnatid3_prev_note_> Subnatid *</_subnatid3_prev_note_>
/*<_subnatid3_prev_note_> . *</_subnatid3_prev_note_>*/
*<_subnatid3_prev_note_> subnatid3_prev brought in from rawdata *</_subnatid3_prev_note_>
gen subnatid3_prev = ""
*</_subnatid3_prev_>

*<_subnatid4_prev_>
*<_subnatid4_prev_note_> Subnatid *</_subnatid4_prev_note_>
/*<_subnatid4_prev_note_> . *</_subnatid4_prev_note_>*/
*<_subnatid4_prev_note_> subnatid4_prev brought in from rawdata *</_subnatid4_prev_note_>
gen subnatid4_prev = ""
*</_subnatid4_prev_>

*<_gaul_adm1_code_>
*<_gaul_adm1_code_note_> Gaul Code *</_gaul_adm1_code_note_>
/*<_gaul_adm1_code_note_> . *</_gaul_adm1_code_note_>*/
*<_gaul_adm1_code_note_> gaul_adm1_code brought in from rawdata *</_gaul_adm1_code_note_>
gen     gaul_adm1_code = .
replace gaul_adm1_code = 575		if  ID_01_CODE==10
replace gaul_adm1_code = 576		if  ID_01_CODE==20
replace gaul_adm1_code = 577		if  ID_01_CODE==30 | ID_01_CODE==45
replace gaul_adm1_code = 578		if  ID_01_CODE==40
replace gaul_adm1_code = 579		if  ID_01_CODE==50 | ID_01_CODE==55
replace gaul_adm1_code = 580		if  ID_01_CODE==60
*</_gaul_adm1_code_>

*<_gaul_adm2_code_>
*<_gaul_adm2_code_note_> Gaul Code *</_gaul_adm2_code_note_>
/*<_gaul_adm2_code_note_> . *</_gaul_adm2_code_note_>*/
*<_gaul_adm2_code_note_> gaul_adm2_code brought in from rawdata *</_gaul_adm2_code_note_>
gen 	gaul_adm2_code = .
replace gaul_adm2_code = 5761		if  ID_02_CODE==4
replace gaul_adm2_code = 5762		if  ID_02_CODE==6
replace gaul_adm2_code = 5763		if  ID_02_CODE==9
replace gaul_adm2_code = 5764		if  ID_02_CODE==42
replace gaul_adm2_code = 5765		if  ID_02_CODE==78
replace gaul_adm2_code = 5766		if  ID_02_CODE==79
replace gaul_adm2_code = 5767		if  ID_02_CODE==3
replace gaul_adm2_code = 5768		if  ID_02_CODE==12
replace gaul_adm2_code = 5769		if  ID_02_CODE==13
replace gaul_adm2_code = 5770		if  ID_02_CODE==15
replace gaul_adm2_code = 5771		if  ID_02_CODE==19
replace gaul_adm2_code = 5772		if  ID_02_CODE==22
replace gaul_adm2_code = 5773		if  ID_02_CODE==30
replace gaul_adm2_code = 5774		if  ID_02_CODE==46
replace gaul_adm2_code = 5775		if  ID_02_CODE==51
replace gaul_adm2_code = 5776		if  ID_02_CODE==75
replace gaul_adm2_code = 5777		if  ID_02_CODE==84
replace gaul_adm2_code = 5778		if  ID_02_CODE==26
replace gaul_adm2_code = 5779		if  ID_02_CODE==29
replace gaul_adm2_code = 5780		if  ID_02_CODE==33
replace gaul_adm2_code = 5781		if  ID_02_CODE==35
replace gaul_adm2_code = 5782		if  ID_02_CODE==39
replace gaul_adm2_code = 5783		if  ID_02_CODE==48
replace gaul_adm2_code = 5784		if  ID_02_CODE==54
replace gaul_adm2_code = 5785		if  ID_02_CODE==56
replace gaul_adm2_code = 5786		if  ID_02_CODE==59
replace gaul_adm2_code = 5787		if  ID_02_CODE==61
replace gaul_adm2_code = 5788		if  ID_02_CODE==67
replace gaul_adm2_code = 5789		if  ID_02_CODE==68
replace gaul_adm2_code = 5790		if  ID_02_CODE==72
replace gaul_adm2_code = 5791		if  ID_02_CODE==82
replace gaul_adm2_code = 5792		if  ID_02_CODE==86
replace gaul_adm2_code = 5793		if  ID_02_CODE==89
replace gaul_adm2_code = 5794		if  ID_02_CODE==93
replace gaul_adm2_code = 5795		if  ID_02_CODE==1
replace gaul_adm2_code = 5796		if  ID_02_CODE==18
replace gaul_adm2_code = 5797		if  ID_02_CODE==41
replace gaul_adm2_code = 5798		if  ID_02_CODE==44
replace gaul_adm2_code = 5799		if  ID_02_CODE==47
replace gaul_adm2_code = 5800		if  ID_02_CODE==50
replace gaul_adm2_code = 5801		if  ID_02_CODE==55
replace gaul_adm2_code = 5802		if  ID_02_CODE==57
replace gaul_adm2_code = 5803		if  ID_02_CODE==65
replace gaul_adm2_code = 5804		if  ID_02_CODE==87
replace gaul_adm2_code = 5805		if  ID_02_CODE==10
replace gaul_adm2_code = 5806		if  ID_02_CODE==27
replace gaul_adm2_code = 5807		if  ID_02_CODE==32
replace gaul_adm2_code = 5808		if  ID_02_CODE==38
replace gaul_adm2_code = 5809		if  ID_02_CODE==49
replace gaul_adm2_code = 5810		if  ID_02_CODE==52
replace gaul_adm2_code = 5811		if  ID_02_CODE==64
replace gaul_adm2_code = 5812		if  ID_02_CODE==69
replace gaul_adm2_code = 5813		if  ID_02_CODE==70
replace gaul_adm2_code = 5814		if  ID_02_CODE==73
replace gaul_adm2_code = 5815		if  ID_02_CODE==76
replace gaul_adm2_code = 5816		if  ID_02_CODE==77
replace gaul_adm2_code = 5817		if  ID_02_CODE==81
replace gaul_adm2_code = 5818		if  ID_02_CODE==85
replace gaul_adm2_code = 5819		if  ID_02_CODE==88
replace gaul_adm2_code = 5820		if  ID_02_CODE==94
replace gaul_adm2_code = 5821		if  ID_02_CODE==36
replace gaul_adm2_code = 5822		if  ID_02_CODE==58
replace gaul_adm2_code = 5823		if  ID_02_CODE==90
replace gaul_adm2_code = 5824		if  ID_02_CODE==91
*</_gaul_adm2_code_>

*<_gaul_adm3_code_>
*<_gaul_adm3_code_note_> Gaul Code *</_gaul_adm3_code_note_>
/*<_gaul_adm3_code_note_> . *</_gaul_adm3_code_note_>*/
*<_gaul_adm3_code_note_> gaul_adm3_code brought in from rawdata *</_gaul_adm3_code_note_>
gen gaul_adm3_code = .
*</_gaul_adm3_code_>

*<_urban_>
*<_urban_note_> Urban (1) or rural (0) *</_urban_note_>
/*<_urban_note_> . *</_urban_note_>*/
*<_urban_note_> urban brought in from SARMD *</_urban_note_>
*</_urban_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save 		"$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta", replace
*</_Save data file_>
