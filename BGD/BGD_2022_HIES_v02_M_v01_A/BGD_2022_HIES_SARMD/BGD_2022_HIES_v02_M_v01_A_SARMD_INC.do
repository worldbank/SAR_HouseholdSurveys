/*------------------------------------------------------------------------------
SARMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	BGD_2022_HIES_v01_M_v01_A_SAMRD_INC.do	   </_Program name_>
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
global module       	"INC"
local yearfolder   	"`code'_`year'_`survey'"
local SARMDfolder  	"`yearfolder'_v`vm'_M_v`va'_A_SARMD"
local filename     	"`yearfolder'_v`vm'_M_v`va'_A_SARMD_INC"
*</_Program setup_>


*<_Datalibweb request_>
use "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\\`yearfolder'_v`vm'_M.dta", clear
*</_Datalibweb request_>
capture drop hhid



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
capture drop wgt
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
gen  isep_nm = .
*</_isep_nm_>

*<_iempp_m_>
*<_iempp_m_note_> Income by employer in the main occupation - monetary *</_iempp_m_note_>
egen 	iempp_m = rsum(agri_net_1 month_nonagri_1), missing
replace iempp_m = .			if  w_cat_1!=3
*</_iempp_m_>

*<_iempp_nm_>
*<_iempp_nm_note_> Income by employer in the main occupation - non-monetary *</_iempp_nm_note_>
gen  iempp_nm = .
*</_iempp_nm_>

*<_iolp_m_>
*<_iolp_m_note_> Other labor income in the main occupation - monetary *</_iolp_m_note_>
egen iolp_m = rsum(aux_ot1 aux_ot2), missing
*</_iolp_m_>

*<_iolp_nm_>
*<_iolp_nm_note_> Other labor income in the main occupation - non-monetary *</_iolp_nm_note_>
gen  iolp_nm = .
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
gen  isenp_nm = .
*</_isenp_nm_>

*<_iempnp_m_>
*<_iempnp_m_note_> Income by employer in the non-principal occupation - monetary *</_iempnp_m_note_>
egen iempnp_m = rsum(aux_em2 aux_em3 aux_em4 aux_em5 aux_em6 aux_em7), missing
*</_iempnp_m_>

*<_iempnp_nm_>
*<_iempnp_nm_note_> Income by employer in the non- principal occupation - non-monetary *</_iempnp_nm_note_>
gen  iempnp_nm = .
*</_iempnp_nm_>

*<_iolnp_m_>
*<_iolnp_m_note_> Other labor income in the non-principal - monetary occupation *</_iolnp_m_note_>
egen iolnp_m = rsum(aux_ot2 aux_ot3 aux_ot4 aux_ot5 aux_ot6 aux_ot7), missing
*</_iolnp_m_>

*<_iolnp_nm_>
*<_iolnp_nm_note_> Other labor income in the non-principal occupation - non-monetary *</_iolnp_nm_note_>
gen  iolnp_nm = .
*</_iolnp_nm_>
drop aux_se* aux_em* aux_ot*


*<_ijubi_con_>
*<_ijubi_con_note_> Income for retirement and contributory pensions *</_ijubi_con_note_>
gen  ijubi_con = .
*</_ijubi_con_>

*<_ijubi_ncon_>
*<_ijubi_ncon_note_> Income for retirement and non-contributory pensions *</_ijubi_ncon_note_>
gen  ijubi_ncon = .
*</_ijubi_ncon_>

*<_ijubi_o_>
*<_ijubi_o_note_> Income for retirement and pensions (not identified if contributory or not) *</_ijubi_o_note_>
gen  ijubi_o = .
*</_ijubi_o_>



*<_icap_>
*<_icap_note_> Income from capital *</_icap_note_>
replace agri_asset_inc = .		if  S1AQ02!=1
egen icap = rsum(S8BQ01 S8BQ02 S8BQ04 S8BQ12 agri_asset_inc), missing
*</_icap_>



*<_icct_>
*<_icct_note_> Income from conditional cash transfer programs *</_icct_note_>
gen  icct = .
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
gen  itrane_ns = .
*</_itrane_ns_>



*<_itranext_m_>
*<_itranext_m_note_> Income from foreign remittances - monetary *</_itranext_m_note_>
egen itranext_m = rsum(S8BQ09), missing
*</_itranext_m_>

*<_itranext_nm_>
*<_itranext_nm_note_> Revenue from remittances from abroad - non-monetary *</_itranext_nm_note_>
gen  itranext_nm = .
*</_itranext_nm_>

*<_itranint_m_>
*<_itranint_m_note_> Income by private transfers from the country - monetary *</_itranint_m_note_>
egen itranint_m = rsum(S8BQ08), missing
*</_itranint_m_>

*<_itranint_nm_>
*<_itranint_nm_note_> Income by private transfers from the country - non-monetary *</_itranint_nm_note_>
gen  itranint_nm = .
*</_itranint_nm_>

*<_itran_ns_>
*<_itran_ns_note_> Income from unspecified private transfers *</_itran_ns_note_>
gen  itran_ns =.
*</_itran_ns_>

 
*<_inla_otro_>
*<_inla_otro_note_> Other non-labor income *</_inla_otro_note_>
egen inla_otro = rsum(S8BQ11 S8BQ13 stipend_inc), missing
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
do   "$rootdofiles\_aux\SecondOrder_INC.do"
save "$rootdatalib\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`filename'.dta", replace
*</_Save data file_>
