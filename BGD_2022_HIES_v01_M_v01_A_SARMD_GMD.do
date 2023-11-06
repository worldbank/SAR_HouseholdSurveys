/*------------------------------------------------------------------------------
					GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BGD_2016_HIES_v01_M_v01_A_GMD_DWL.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Navishti Das and Javier Parada	</_Author(s)_>
<_Date created_>   03-03-2019	</_Date created_>
<_Date modified>    3 Mar 2020	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        BGD	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2016	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	03-03-2019
File:	BGD_2016_HIES_v01_M_v01_A_GMD_DWL.do
- First version
</_Version Control_>
------------------------------------------------------------------------------*/

*<_Program setup_>
clear all
set more off

local code         "BGD"
local year         "2022"
local survey       "HIES"
local vm           "01"
local va           "01"
local type         "SARMD"
local type         "SARMD"
local yearfolder   "`code'_`year'_`survey'"
local SARMDfolder  "`yearfolder'_v`vm'_M_v`va'_A_SARMD"
local filename     "`yearfolder'_v`vm'_M_v`va'_A_SARMD_GMD"

*</_Program setup_>
glo harmonized "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized"
*</_Merge file_>
*Merge files
use "${harmonized}\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_IDN.dta", clear
noi di "`mod'"
sort hhid pid
local mods COR GEO DEM LBR DWL UTL 
foreach mod of local mods {
    sort hhid pid
	if (inlist("`mod'","COR", "DEM", "LBR", "GEO", "DWL", "UTL")) {
	merge 1:1 hhid pid using "${harmonized}\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.dta", gen(`mod')
	}
	if (inlist("`mod'", "XXX" )) {
	merge m:1 hhid using "${harmonized}\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD_`mod'.dta", gen(`mod')
    }
    noi di "`mod'"
	tab `mod'    
}
*</_Merge file_>

*</_Save data file_>
save "${rootdatalib}\\`code'\\`yearfolder'\\`SARMDfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
