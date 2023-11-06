/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	BGD_2022_HIES_v01_M_v01_A_SARMD_COR.do		</_Program name_>
<_Application_>    	STATA 16.0									<_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		</_Author(s)_>
<_Date created_>   	06-2023										</_Date created_>
<_Date modified>    June 2023									</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	BGD											</_Country_>
<_Survey Title_>   	HIES										</_Survey Title_>
<_Survey Year_>    	2022										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				06-2023
File:				BGD_2022_HIES_v01_M_v01_A_SARMD_COR.do
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
local cpiversion     "09"
glo   module       "COR"
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
tempfile IND
datalibweb, country(BGD) year(2022) type(SARMD) survey(HIES) vermast(01) veralt(01) mod(IND) clear 
*/

* VARIABLES FROM (IND-SARMD) MODULE
tempfile IND
use "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\BGD_2022_HIES_v01_M_v01_A_SARMD_IND.dta", clear
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

*<_converfactor_>
*<_converfactor_note_> Conversion factor *</_converfactor_note_>
/*<_converfactor_note_> *</_converfactor_note_>*/
*<_converfactor_note_> converfactor brought in from metadata *</_converfactor_note_>
gen converfactor = .a
*</_converfactor_>

*<_cpi_2011_vxx_>
*<_cpi_2011_vxx_note_> CPI ratio value of survey (rebased to 2005 on base 1) *</_cpi_2011_vxx_note_>
/*<_cpi_2011_vxx_note_>  *</_cpi_2011_vxx_note_>*/
*<_cpi_2011_vxx_note_> cpi_2011_vxx brought in from datalibweb CPI database V08 *</_cpi_2011_vxx_note_>
gen cpi_2011_v`cpiversion' = .a
*</_cpi_2011_vxx_>

*<_cpi_2017_vxx_>
*<_cpi_2017_vxx_note_> CPI ratio value of survey (rebased to 2005 on base 1) *</_cpi_2017_vxx_note_>
/*<_cpi_2017_vxx_note_>  *</_cpi_2017_vxx_note_>*/
*<_cpi_2017_vxx_note_> cpi_2017_vxx brought in from datalibweb CPI database V08 *</_cpi_2017_vxx_note_>
gen cpi_2017_v`cpiversion' = .a
*</_cpi_2017_vxx_>

*<_cpiperiod_>
*<_cpiperiod_note_> Periodicity of CPI (year, year&month, year&quarter, weighted) *</_cpiperiod_note_>
/*<_cpiperiod_note_>  *</_cpiperiod_note_>*/
*<_cpiperiod_note_> cpiperiod brought in from metadata *</_cpiperiod_note_>
cap clonevar cpiperiod = cpiperiod
*</_cpiperiod_>

*<_harmonization_>
*<_harmonization_note_> Type of harmonization *</_harmonization_note_>
/*<_harmonization_note_>  *</_harmonization_note_>*/
*<_harmonization_note_> harmonization brought in from rawdata *</_harmonization_note_>
gen harmonization = "GMD"
*</_harmonization_>

*<_ppp_2011_>
*<_ppp_2011_note_> PPP conversion factor *</_ppp_2011_note_>
/*<_ppp_2011_note_>  *</_ppp_2011_note_>*/
*<_ppp_2011_note_> ppp_2011 brought in from datalibweb CPI database V08 *</_ppp_2011_note_>
gen ppp_2011 = .a
*</_ppp_2011_>

*<_ppp_2017_>
*<_ppp_2017_note_> PPP conversion factor *</_ppp_2017_note_>
/*<_ppp_2017_note_>  *</_ppp_2017_note_>*/
*<_ppp_2017_note_> ppp_2017 brought in from datalibweb CPI database V08 *</_ppp_2017_note_>
gen ppp_2017 = .a
*</_ppp_2017_>

*<_educat7_>
*<_educat7_note_> Highest level of education completed (7 categories) *</_educat7_note_>
/*<_educat7_note_>  1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Post secondary but not university" 7 "University" *</_educat7_note_>*/
*<_educat7_note_> educat7 brought in from SARMD *</_educat7_note_>
*</_educat7_>

*<_educat5_>
*<_educat5_note_> Highest level of education completed (5 categories) *</_educat5_note_>
/*<_educat5_note_>  1 "No education" 2 "Primary incomplete" 3 "Primary complete but Secondary incomplete" 4 "Secondary complete" 5 "Tertiary (completed or incomplete)" *</_educat5_note_>*/
*<_educat5_note_> educat5 brought in from SARMD *</_educat5_note_>
*</_educat5_>

*<_educat4_>
*<_educat4_note_> Highest level of education completed (4 categories) *</_educat4_note_>
/*<_educat4_note_>  1 "No education" 2 "Primary (complete or incomplete)" 3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)" *</_educat4_note_>*/
*<_educat4_note_> educat4 brought in from SARMD *</_educat4_note_>
*</_educat4_>

*<_educy_>
*<_educy_note_> Years of completed education *</_educy_note_>
/*<_educy_note_>  *</_educy_note_>*/
*<_educy_note_> educy brought in from SARMD *</_educy_note_>
replace educy = . 	if  educy>=age & educy!=. & age!=.
*</_educy_>

*<_hsize_>
*<_hsize_note_> Household size *</_hsize_note_>
/*<_hsize_note_> *</_hsize_note_>*/
*<_hsize_note_> hsize brought in from SARMD *</_hsize_note_>
*</_hsize_>

*<_literacy_>
*<_literacy_note_> Individual can read and write *</_literacy_note_>
/*<_literacy_note_> 1 " Yes, can read and write" 0 " No, cannot read or write" *</_literacy_note_>*/
*<_literacy_note_> literacy brought in from SARMD *</_literacy_note_>
*</_literacy_>

*<_primarycomp_>
*<_primarycomp_note_> Primary school completion *</_primarycomp_note_>
/*<_primarycomp_note_>  1 "Yes" 0 "No" *</_primarycomp_note_>*/
*<_primarycomp_note_> primarycomp brought in from SARMD *</_primarycomp_note_>
recode educat7 (1 2=0) (3 4 5 6 7=1) (8=.) if everattend==1, gen(primarycomp)
*</_primarycomp_>

*<_school_>
*<_school_note_> Currently enrolled in or attending school *</_school_note_>
/*<_school_note_>  1 "Yes" 0 "No" *</_school_note_>*/
*<_school_note_> school brought in from SARMD *</_school_note_>
gen school= atschool
*</_school_>

*<_survey_>
*<_survey_note_> Type of survey *</_survey_note_>
/*<_survey_note_>  *</_survey_note_>*/
*<_survey_note_> survey brought in from metadata *</_survey_note_>
*</_survey_>

*<_veralt_>
*<_veralt_note_> Version number of adaptation to the master data file *</_veralt_note_>
/*<_veralt_note_>  *</_veralt_note_>*/
*<_veralt_note_> veralt brought in from metadata *</_veralt_note_>
*</_veralt_>

*<_vermast_>
*<_vermast_note_> Version number of master data file *</_vermast_note_>
/*<_vermast_note_>  *</_vermast_note_>*/
*<_vermast_note_> vermast brought in from metadata *</_vermast_note_>
*</_vermast_>

*<_welfare_>
*<_welfare_note_> Welfare aggregate used for estimating international poverty (provided to PovcalNet) *</_welfare_note_>
/*<_welfare_note_>  *</_welfare_note_>*/
*<_welfare_note_> welfare brought in from SARMD *</_welfare_note_>
*</_welfare_>

*<_welfaredef_>
*<_welfaredef_note_> Welfare aggregate spatially deflated *</_welfaredef_note_>
/*<_welfaredef_note_>  *</_welfaredef_note_>*/
*<_welfaredef_note_> welfaredef brought in from SARMD *</_welfaredef_note_>
*</_welfaredef_>

*<_welfarenom_>
*<_welfarenom_note_> Welfare aggregate in nominal terms *</_welfarenom_note_>
/*<_welfarenom_note_>  *</_welfarenom_note_>*/
*<_welfarenom_note_> welfarenom brought in from SARMD *</_welfarenom_note_>
*</_welfarenom_>

*<_welfareother_>
*<_welfareother_note_> Welfare aggregate if different welfare type is used from welfare, welfarenom, welfaredef *</_welfareother_note_>
/*<_welfareother_note_>  *</_welfareother_note_>*/
*<_welfareother_note_> welfareother brought in from SARMD *</_welfareother_note_>
*</_welfareother_>

*<_welfareothertype_>
*<_welfareothertype_note_> Type of welfare measure (income, consumption or expenditure) for welfareother *</_welfareothertype_note_>
/*<_welfareothertype_note_>  *</_welfareothertype_note_>*/
*<_welfareothertype_note_> welfareothertype brought in from SARMD *</_welfareothertype_note_>
*</_welfareothertype_>

*<_welfaretype_>
*<_welfaretype_note_> Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef *</_welfaretype_note_>
/*<_welfaretype_note_>  *</_welfaretype_note_>*/
*<_welfaretype_note_> welfaretype brought in from SARMD *</_welfaretype_note_>
*</_welfaretype_>

*<_welfshprosperity_>
*<_welfshprosperity_note_> Welfare aggregate for shared prosperity (if different from poverty) *</_welfshprosperity_note_>
/*<_welfshprosperity_note_>  *</_welfshprosperity_note_>*/
*<_welfshprosperity_note_> welfshprosperity brought in from SARMD *</_welfshprosperity_note_>
*</_welfshprosperity_>

*<_welfshprtype_>
*<_welfshprtype_note_> Welfare type for shared prosperity indicator (income, consumption or expenditure) *</_welfshprtype_note_>
/*<_welfshprtype_note_>  *</_welfshprtype_note_>*/
*<_welfshprtype_note_> welfshprtype brought in from SARMD *</_welfshprtype_note_>
gen welfshprtype = welfaretype
*</_welfshprtype_>

*<_spdef_>
*<_spdef_note_> Spatial deflator (if one is used) *</_spdef_note_>
/*<_spdef_note_>  *</_spdef_note_>*/
*<_spdef_note_> spdef brought in from SARMD *</_spdef_note_>
*</_spdef_>


*<_Keep variables_>
sort 	hhid pid
*</_Keep variables_>


*<_Save data file_>
do   "P:\SARMD\SARDATABANK\SARMDdofiles\_aux\Labels_SARMD.do"
save "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>




