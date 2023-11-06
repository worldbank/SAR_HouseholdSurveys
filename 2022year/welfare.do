/*------------------------------------------------------------------------------
					SAMRD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   BGD_2022_aux.do	</_Program name_>
<_Application_>    STATA 16.0	<_Application_>
<_Author(s)_>      Adriana Castillo Castillo 	</_Author(s)_>
<_Date created_>   04-2023	</_Date created_>
<_Date modified>    4 Apr 2023	</_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        BGD	</_Country_>
<_Survey Title_>   HIES	</_Survey Title_>
<_Survey Year_>    2022	</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:	04-2023
File:	BGD_2022_aux.do
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
local yearfolder   "BGD_2022_HIES"
local SARMDfolder  "BGD_2022_HIES_v01_M_v01_A_SARMD"
*local filename     "BGD_2022_HIES_v01_M_v01_A_SAMRD_IND"
*</_Program setup_>

** DIRECTORY
	global input "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M"
	global output "${rootdatalib}\\`code'\\`code'_`year'_`survey'\\`code'_`year'_`survey'_v`vm'_M_v`va'_A_SARMD"
	
   
** MONTH OF INTERVIEW - Database 
	use "${input}\Data\Stata\HH_SEC_9A1_hies2022_qty_gm_new.dta", clear //14,388 obs 
    rename *,  lower
	keep       term psu hhid s9a1q06 s9a1q07 item day 
	drop       if hhid==.
	gen        hhold=psu*1000+hhid 
	rename     s9a1q06 month 
	rename     s9a1q07 year 
	egen       mode_month=mode(month), by(psu)
	bys        psu term hhold: gen id=_n
	sort       psu term hhold item year month day id
	replace    mode_month=month if id==1 & mode_month==.
	gen        mode_year = year if mode_month==month
	egen       mode_year_max=max(mode_year),by(psu)
	order      psu term hhold item year month day mode_*
	keep       psu term hh* mode_*
	rename     mode_year_max year
	rename     mode_month month
	drop       mode_year
	unique     psu hhid // 14,388 hh  
    duplicates drop psu term month year hhold, force
	unique     psu hhid // 14,388 hh  
	drop       if month==. // no obs dropped. all included
	
** CPI from IMF 
	preserve 
    import   excel "${input}\Data\Stata\IMF_BGD_CPI_Indexes_And_Weights.xlsx", sheet("datalibweb") firstrow clear //24 obs: 12 months for each year 
	keep     code year month monthly_cpi yearly_cpi
	keep     if year>=2021 & year<=2022
	tempfile CPI_dlw_2022
	save     `CPI_dlw_2022'
	restore 
    merge    m:1 month year using  `CPI_dlw_2022', nogen keep(match)
	rename   (code year month) (countrycode year_survey month_survey)
	tempfile CPI_BGD_2022 //14,388 obs 
	save     `CPI_BGD_2022'
	* Note average montly_cpi if year==2017 = 161.226455688476563  
	* same CPI in datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v09_M) filename(Monthly_CPI.dta)
   
** WELFARE
    *use "${input}\Data\Stata\longhh_hies2022.dta", clear 
	use "${input}\Data\Stata\longhh_hies2022_excl_new_items.dta", clear //14,395 obs
	notes: This information is not deflated spatially. 
	rename *, lower
	* duplicates report psu hhid = 14,395hh, more than households with month of interview 
	keep     psu hhold hhsize hhid p_cons2  consexp2 hh_wgt pop_wgt realpcexp fexp
	*gen      welfarenom = hhsize*p_cons2
	rename   (p_cons2 hh_wgt) (welfarenom weight)
	drop     if welfarenom==.  //14,304 hh, less than household with month. All household have months
	merge    1:1 psu hhold using `CPI_BGD_2022'
	* ALL observations from master data merge with month and CPI
	keep if _merge==3
	drop _merge
	
	gen      welfare=welfarenom*yearly_cpi/monthly_cpi
	tempfile CPI_BGD_2022 //14,304 obs hh 
	save     `CPI_BGD_2022'
	
   
** CPI from datalibweb 
   datalibweb, country(Support) year(2005) type(GMDRAW) surveyid(Support_2005_CPI_v09_M) filename(Final_CPI_PPP_to_be_used.dta) 
   keep       if code=="BGD"
   keep       code icp2017
   rename     code countrycode
   duplicates drop countrycode, force
   merge 1:m  countrycode using `CPI_BGD_2022', nogen
 
   gen  cpi2017 = yearly_cpi/161.226455688476563   
   egen idh     = concat(psu hhid), punct(-)
   replace hhid=(psu*1000)+hhid
   drop hhid   
   clonevar hhid = idh   
   
   save "${rootdatalib}\\`code'\\`yearfolder'\\`yearfolder'_v`vm'_M\Data\Stata\welfare_`year'.dta", replace //14,304 hhid 
   
   exit 
   cap drop welfare_ppp
    gen welfare_ppp=(welfare*12)/cpi2017/icp2017/365
	*gen  cpi2017 = yearly_cpi/161.226455688476563 
	*gen welfare_ppp=(p_cons2*12)/cpi2017/icp2017/365
	apoverty welfare_ppp [aw=pop_wgt], line(2.15) 
	apoverty welfare_ppp [aw=pop_wgt], line(3.65) 
	apoverty welfare_ppp [aw=pop_wgt], line(6.85) 
	*2.15 = 9.576%
	*3.65 = 42.322%
	*6.85 = 83.145%
	* Gini: 0.31788
	
	gen welfare_ppp2=(realpcexp*12)/(152.5291403222770/161.226455688476563 ) /icp2017/365
	apoverty welfare_ppp2 [aw=pop_wgt], line(2.15) 
	apoverty welfare_ppp2 [aw=pop_wgt], line(3.65) 
	apoverty welfare_ppp2 [aw=pop_wgt], line(6.85) 
	*2.15 =  8.899%
	*3.65 =  40.615%
	*6.85 =  82.199%
	*Gini 0.31767
	
	tempfile welfare
	drop hhid
	rename idh hhid
	keep hhid welfare_ppp
	save `welfare', replace

** IND database 
	*datalibweb, country(BGD) year(2022) type(SARRAW) localpath($rootdatalib) local
	*datalibweb, country(BGD) year(2022) type(SARMD) localpath($rootdatalib) local
	* unique hhid 14293
	*merge m:1 hhid using `welfare'
	*apoverty welfare_ppp [aw=weight], line(2.15)  -- 11% deleted
	
	use "${input}\BGD\BGD_2022_HIES\BGD_2022_HIES_v01_M_v01_A_SARMD\Data\Harmonized\BGD_2022_HIES_v01_M_v01_A_SARMD_IND.dta" 
	merge m:1 hhid using `welfare'
	apoverty welfare_ppp [aw=weight], line(2.15)
	*Headcount ratio % |       9.576


   
*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*
*<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*
