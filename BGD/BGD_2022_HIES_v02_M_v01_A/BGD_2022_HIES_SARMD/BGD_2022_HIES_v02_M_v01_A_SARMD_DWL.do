/*------------------------------------------------------------------------------
GMD Harmonization
--------------------------------------------------------------------------------
<_Program name_>   	BGD_2022_HIES_v01_M_v01_A_SARMD_DWL.do	   </_Program name_>
<_Application_>    	STATA 17.0									 <_Application_>
<_Author(s)_>      	Leo Tornarolli <tornarolli@gmail.com>		  </_Author(s)_>
<_Date created_>   	10-2023									   </_Date created_>
<_Date modified>    October 2023							  </_Date modified_>
--------------------------------------------------------------------------------
<_Country_>        	BGD											    </_Country_>
<_Survey Title_>   	HIES									   </_Survey Title_>
<_Survey Year_>    	2022										</_Survey Year_>
--------------------------------------------------------------------------------
<_Version Control_>
Date:				10-2023
File:				BGD_2022_HIES_v01_M_v01_A_SARMD_DWL.do
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
global module       	"DWL"
local yearfolder   	"`code'_`year'_`survey'"
local SARMDfolder  	"`yearfolder'_v`vm'_M_v`va'_A_SARMD"
local filename     	"`yearfolder'_v`vm'_M_v`va'_A_SARMD_DWL"
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

*<_landphone_>
*<_landphone_note_> Ownership of a land phone (household) *</_landphone_note_>
/*<_landphone_note_> 1 "Yes" 0 "No" *</_landphone_note_>*/
*<_landphone_note_> landphone brought in from rawdata *</_landphone_note_>
gen landphone = lphone
*</_landphone_>

*<_cellphone_>
*<_cellphone_note_> Ownership of a cell phone (household) *</_cellphone_note_>
/*<_cellphone_note_> 1 "Yes" 0 "No" *</_cellphone_note_>*/
*<_cellphone_note_> cellphone brought in from raw data *</_cellphone_note_>
*</_cellphone_>

*<_cellphone_i_>
*<_cellphone_i_note_> Ownership of a cell phone (individual) *</_cellphone_i_note_>
/*<_cellphone_i_note_>  *</_cellphone_i_note_>*/
*<_cellphone_i_note_> cellphone_i brought in from raw data *</_cellphone_i_note_>
gen 	cellphone_i = .
replace cellphone_i = 0		if  S1AQ10==2
replace cellphone_i = 1		if  S1AQ10==1
*</_cellphone_i_>

*<_phone_>
*<_phone_note_> Ownership of a telephone (household) *</_phone_note_>
/*<_phone_note_> 1 "Yes" 0 "No" *</_phone_note_>*/
*<_phone_note_> phone brought in from raw data *</_phone_note_>
gen 	phone = .
replace phone = 0		if  landphone==0 & cellphone==0
replace phone = 1		if  landphone==1 | cellphone==1
*</_phone_>

*<_computer_>
*<_computer_note_> Ownership of a computer *</_computer_note_>
/*<_computer_note_> 1 "Yes" 0 "No" *</_computer_note_>*/
*<_computer_note_> computer brought in from raw data *</_computer_note_>
*</_computer_>

*<_etablet_>
*<_etablet_note_> Ownership of a electronic tablet *</_etablet_note_>
/*<_etablet_note_> 1 "Yes" 0 "No" *</_etablet_note_>*/
*<_etablet_note_> etablet brought in from raw data *</_etablet_note_>
gen   etablet = .
notes etablet: HIES only includes a binary question asking if the household owns a computer/laptop/notebook/tablet
*</_etablet_>

*<_internet_>
*<_internet_note_>  Ownership of a internet *</_internet_note_>
/*<_internet_note_> 1 "Subscribed in the house" 2 "Accessible outside the house" 3 "Either" 4 "No internet" *</_internet_note_>*/
*<_internet_note_> internet brought in from raw data *</_internet_note_>
capture drop internet
gen  aux_cellphone = 1		if  S1AQ15==1
egen aux_mobile = max(aux_cellphone), by(hhid)

gen 	internet = .
replace internet = 3			if  item_1023==1  & aux_mobile==1
replace internet = 1			if  item_1023==1  & internet==.
replace internet = 2			if  aux_mobile==1 & internet==.
replace internet = 4			if  item_1023!=1  & aux_mobile==.
*</_internet_>

*<_internet_mobile_>
*<_internet_mobile_note_> Ownership of a internet (mobile 2G 3G LTE 4G 5G) *</_internet_mobile_note_>
/*<_internet_mobile_note_>  *</_internet_mobile_note_>*/
*<_internet_mobile_note_> internet_mobile brought in from raw data *</_internet_mobile_note_>
gen     internet_mobile = .
replace internet_mobile = 0	if  aux_mobile==.
replace internet_mobile = 1	if  aux_mobile==1
drop aux_cellphone aux_mobile
*</_internet_mobile_>

*<_internet_mobile4G_>
*<_internet_mobile4G_note_> Ownership of a internet (mobile LTE 4G 5G) *</_internet_mobile4G_note_>
/*<_internet_mobile4G_note_>  *</_internet_mobile4G_note_>*/
*<_internet_mobile4G_note_> internet_mobile4G brought in from raw data *</_internet_mobile4G_note_>
gen   internet_mobile4G = .a
notes internet_mobile4G: the HIES does not contain information specific enough to define this variable
*</_internet_mobile4G_>

*<_radio_>
*<_radio_note_> Ownership of a radio *</_radio_note_>
/*<_radio_note_> 1 "Yes" 0 "No" *</_radio_note_>*/
*<_radio_note_> radio brought in from raw data *</_radio_note_>
*</_radio_>

*<_tv_>
*<_tv_note_> Ownership of a tv *</_tv_note_>
/*<_tv_note_> 1 "Yes" 0 "No" *</_tv_note_>*/
*<_tv_note_> tv brought in from television in SARMD *</_tv_note_>
gen tv = television
*</_tv_>

*<_tv_cable_>
*<_tv_cable_note_> Ownership of a cable tv *</_tv_cable_note_>
/*<_tv_cable_note_> 1 "Yes" 0 "No" *</_tv_cable_note_>*/
*<_tv_cable_note_> tv_cable brought in from raw data *</_tv_cable_note_>
gen   tv_cable = .a
notes tv_cable: the HIES does not contain information to define this variable
*</_tv_cable_>

*<_video_>
*<_video_note_> Ownership of a video *</_video_note_>
/*<_video_note_> 1 "Yes" 0 "No" *</_video_note_>*/
*<_video_note_> video brought in from raw data *</_video_note_>
gen   video = .a
notes video: the HIES does not contain information to define this variable
*</_video_>

*<_fridge_>
*<_fridge_note_> Ownership of a refrigerator *</_fridge_note_>
/*<_fridge_note_> 1 "Yes" 0 "No" *</_fridge_note_>*/
*<_fridge_note_> fridge brought in from refrigerator in SARMD *</_fridge_note_>
gen fridge = refrigerator
*</_fridge_>

*<_sewmach_>
*<_sewmach_note_> Ownership of a sewing machine *</_sewmach_note_>
/*<_sewmach_note_> 1 "Yes" 0 "No" *</_sewmach_note_>*/
*<_sewmach_note_> sewmach brought in from sewingmachine in SARMD *</_sewmach_note_>
gen sewmach = sewingmachine
*</_sewmach_>

*<_washmach_>
*<_washmach_note_> Ownership of a washing machine *</_washmach_note_>
/*<_washmach_note_> 1 "Yes" 0 "No" *</_washmach_note_>*/
*<_washmach_note_> washmach brought in from washingmachine in SARMD *</_washmach_note_>
gen washmach = washingmachine
*</_washmach_>

*<_stove_>
*<_stove_note_> Ownership of a stove *</_stove_note_>
/*<_stove_note_> 1 "Yes" 0 "No" *</_stove_note_>*/
*<_stove_note_> stove brought in from raw data *</_stove_note_>
gen 	stove = 0
replace stove = 1		if  item_1026==1				// microwave-electric oven //
replace stove = 1		if  S6AQ20>=1 & S6AQ20<=6	
notes   stove: category "traditional wood stove" is considered as stove==1
notes   stove: category "three stone or brick ovens/open ovens" is considered as stove==0
*</_stove_>

*<_ricecook_>
*<_ricecook_note_> Ownership of a rice cooker *</_ricecook_note_>
/*<_ricecook_note_> 1 "Yes" 0 "No" *</_ricecook_note_>*/
*<_ricecook_note_> ricecook brought in from raw data *</_ricecook_note_>
gen   ricecook = .a
notes ricecook: the HIES does not contain information to define this variable
*</_ricecook_>

*<_fan_>
*<_fan_note_> Ownership of an electric fan *</_fan_note_>
/*<_fan_note_> 1 "Yes" 0 "No" *</_fan_note_>*/
*<_fan_note_> fan brought in from raw data *</_fan_note_>
*</_fan_>

*<_ac_>
*<_ac_note_> Ownership of a central or wall air conditioner *</_ac_note_>
/*<_ac_note_> 1 "Yes" 0 "No" *</_ac_note_>*/
*<_ac_note_> ac brought in from raw data *</_ac_note_>
gen 	ac = 0
replace ac = 1			if  item_1028==1
*</_ac_>

*<_ewpump_>
*<_ewpump_note_> Ownership of a electric water pump *</_ewpump_note_>
/*<_ewpump_note_> 1 "Yes" 0 "No" *</_ewpump_note_>*/
*<_ewpump_note_> ewpump brought in from raw data *</_ewpump_note_>
gen 	ewpump = 0
replace ewpump = 1		if  item_1042==1		// water pump-motor	//
notes   ewpump: the raw variable refers to "Water Pump-Motor"
*</_ewpump_>

*<_bcycle_>
*<_bcycle_note_> Ownership of a bicycle *</_bcycle_note_>
/*<_bcycle_note_>  1 "Yes" 0 "No" *</_bcycle_note_>*/
*<_bcycle_note_> bcycle brought in from bicycle in SARMD *</_bcycle_note_>
gen bcycle = bicycle
*</_bcycle_>

*<_mcycle_>
*<_mcycle_note_> Ownership of a motorcycle *</_mcycle_note_>
/*<_mcycle_note_> 1 "Yes" 0 "No" *</_mcycle_note_>*/
*<_mcycle_note_> mcycle brought in from motorcycle in SARMD *</_mcycle_note_>
gen mcycle = motorcycle
*</_mcycle_>

*<_oxcart_>
*<_oxcart_note_> Ownership of a oxcart *</_oxcart_note_>
/*<_oxcart_note_> 1 "Yes" 0 "No" *</_oxcart_note_>*/
*<_oxcart_note_> oxcart brought in from raw data *</_oxcart_note_>
gen   oxcart = .a
notes oxcart: the HIES does not contain information to define this variable
*</_oxcart_>

*<_boat_>
*<_boat_note_> Ownership of a boat *</_boat_note_>
/*<_boat_note_> 1 "Yes" 0 "No" *</_boat_note_>*/
*<_boat_note_> boat brought in from raw data *</_boat_note_>
gen 	boat = 0
replace boat = 1			if  item_1043==1		// boat-engine boat	//
notes   boat: the raw variable refers to "Boat-Engine Boat"
*</_boat_>

*<_car_>
*<_car_note_> Ownership of a Car *</_car_note_>
/*<_car_note_> 1 "Yes" 0 "No" *</_car_note_>*/
*<_car_note_> car brought in from motorcar in SARMD *</_car_note_>
gen car = motorcar
*</_car_>

*<_canoe_>
*<_canoe_note_> Ownership of a canoes *</_canoe_note_>
/*<_canoe_note_> 1 "Yes" 0 "No" *</_canoe_note_>*/
*<_canoe_note_> canoe brought in from raw data *</_canoe_note_>
gen   canoe = .a
notes canoe: the HIES does not contain information to define this variable
*</_canoe_>


*<_roof_>
*<_roof_note_> Main material used for roof *</_roof_note_>
/*<_roof_note_> 1 "Natural–Thatch/palm leaf" 2 "Natural–Sod" 3 "Natural–Other" 4 "Rudimentary–Rustic mat" 5 "Rudimentary–Palm/bamboo" 6 "Rudimentary–Wood planks" 7 "Rudimentary-Other" 8 "Finished–Roofing" 9 "Finished–Asbestos" 10 "Finished–Tile" 11 "Finished–Concrete" 12 "Finished–Metal tile" 13 "Finished–Roofing shingles" 14 "Finished–Other" 15 "Other–Specific" *</_roof_note_>*/
*<_roof_note_> roof brought in from raw data *</_roof_note_>
gen     roof = .
replace roof = 1			if  S6AQ05==1	// straw-bamboo-polythene-plastic-canvas 	//
replace roof = 8			if  S6AQ05==2	// tin (CI sheet)							//
replace roof = 10		if  S6AQ05==3	// tally									//		
replace roof = 11		if  S6AQ05==4	// brick-cement								//
replace roof = 15		if  S6AQ05==5	// other 									//
notes roof: there are 64 households without information on materials of the roof
notes roof: information refers to materials of the roof of the main room
*</_roof_>

*<_wall_>
*<_wall_note_> Main material used for external walls *</_wall_note_>
/*<_wall_note_> 1 "Natural–Cane/palm/trunks" 2 "Natural–Dirt" 3 "Natural–Other" 4 "Rudimentary–Bamboo with mud" 5 "Rudimentary–Stone with mud" 6 "Rudimentary–Uncovered adobe" 7 "Rudimentary–Plywood" 8 "Rudimentary–Cardboard" 9 "Rudimentary–Reused wood" 10 "Rudimentary–Other" 11 "Finished–Woven Bamboo" 12 "Finished–Stone with lime/cement" 13 "Finished–Cement blocks"14 "Finished–Covered adobe" 15 "Finished–Wood planks/shingles" 16 "Finished–Plaster wire" 17 "Finished– GRC/Gypsum/Asbestos" 18 "Finished–Other" 19 "Other" *</_wall_note_>*/
*<_wall_note_> wall brought in from raw data *</_wall_note_>
gen 	wall = .
replace wall = 1			if  S6AQ04==1	// straw-bamboo-polythene-plastic-canvas 	//
replace wall = 6 		if  S6AQ04==2	// mud-urburnt brick 						//
replace wall = 10		if  S6AQ04==3	// tin (CI sheet) 							//
replace wall = 15		if  S6AQ04==4	// wood 									//
replace wall = 13		if  S6AQ04==5	// brick-cement 							//
replace wall = 19		if  S6AQ04==6	// other 									//
notes wall: there are 64 households without information on materials of the walls
notes wall: information refers to materials of the walls of the main room
*</_wall_>

*<_floor_>
*<_floor_note_> Main material used for floor *</_floor_note_>
/*<_floor_note_> 1 "Natural–Earth/sand" 2 "Natural–Dung" 3 "Natural–Other" 4 "Rudimentary–Wood planks" 5 "Rudimentary–Palm/bamboo" 6 "Rudimentary–Other" 7 "Finished–Parquet or polished wood" 8 "Finished–Vinyl or asphalt strips" 9 "Finished–Ceramic/marble/granite" 10 "Finished–Floor tiles/teraso" 11 "Finished–Cement/red bricks" 12 "Finished–Carpet" 13 "Finished–Other" 14 "Other–Specific" *</_floor_note_>*/
*<_floor_note_> floor brought in from raw data *</_floor_note_>
gen   floor = .
notes floor: the HIES does not contain information to define this variable
*</_floor_>

*<_kitchen_>
*<_kitchen_note_> Separate kitchen in the dwelling *</_kitchen_note_>
/*<_kitchen_note_> 1 "Yes" 0 "No" *</_kitchen_note_>*/
*<_kitchen_note_> kitchen brought in from raw data *</_kitchen_note_>
gen  	kitchen = .
replace kitchen = 0		if  S6AQ24>=1 & S6AQ24<=6
replace kitchen = 1		if  S6AQ24==2 | S6AQ24==3 	// cooking is done in the main house in a separate room-building //
*</_kitchen_>

*<_bath_>
*<_bath_note_> Bathing facility in the dwelling *</_bath_note_>
/*<_bath_note_> 1 "Yes" 0 "No" *</_bath_note_>*/
*<_bath_note_> bath brought in from raw data *</_bath_note_>
gen   bath = .a
notes bath: the HIES does not contain information to define this variable
*</_bath_>

*<_rooms_>
*<_rooms_note_> Number of habitable rooms *</_rooms_note_>
/*<_rooms_note_>  *</_rooms_note_>*/
*<_rooms_note_> rooms brought in from raw data *</_rooms_note_>
gen   rooms = S6AQ02
notes rooms: there are 64 households without information on number of rooms
notes rooms: there is a household reporting occupying 83 rooms
*</_rooms_>

*<_areaspace_>
*<_areaspace_note_> Area *</_areaspace_note_>
/*<_areaspace_note_>     *</_areaspace_note_>*/
*<_areaspace_note_> areaspace brought in from raw data *</_areaspace_note_>
gen   areaspace = S6AQ02*0.092903
notes areaspace: raw data is in sq ft, converted to sq meters using 0.092903 factor
*</_areaspace_>

*<_ybuilt_>
*<_ybuilt_note_> Year the dwelling built *</_ybuilt_note_>
/*<_ybuilt_note_>  *</_ybuilt_note_>*/
*<_ybuilt_note_> ybuilt brought in from raw data *</_ybuilt_note_>
gen   ybuilt = .a
notes ybuilt: the HIES does not contain information to define this variable
*</_ybuilt_>

*<_ownhouse_>
*<_ownhouse_note_> Ownership of house *</_ownhouse_note_>
/*<_ownhouse_note_> 1 "Ownership/secure rights" 2 "Renting" 3 "Provided for free" 4 "Without permission" *</_ownhouse_note_>*/
*<_ownhouse_note_> ownhouse brought in from typehouse in SARMD *</_ownhouse_note_>
capture drop ownhouse
gen ownhouse = typehouse
*</_ownhouse_>

*<_acqui_house_>
*<_acqui_house_note_> Acquisition of house *</_acqui_house_note_>
/*<_acqui_house_note_> 1 "Purchased" 2 "Inherited" 3 "Other" *</_acqui_house_note_>*/
*<_acqui_house_note_> acqui_house brought in from raw data *</_acqui_house_note_>
gen   acqui_house = .a
notes acqui_house: the HIES does not contain information to define this variable
*</_acqui_house_>

*<_dwelownlti_>
*<_dwelownlti_note_> Legal title for Ownership *</_dwelownlti_note_>
/*<_dwelownlti_note_> 1 "Yes" 0 "No" *</_dwelownlti_note_>*/
*<_dwelownlti_note_> dwelownlti brought in from raw data *</_dwelownlti_note_>
gen   dwelownlti = .a
notes dwelownlti: the HIES does not contain information to define this variable
*</_dwelownlti_>

*<_fem_dwelownlti_>
*<_fem_dwelownlti_note_> Legal title for Ownership - Female *</_fem_dwelownlti_note_>
/*<_fem_dwelownlti_note_> 1 "Yes" 0 "No" *</_fem_dwelownlti_note_>*/
*<_fem_dwelownlti_note_> fem_dwelownlti brought in from raw data *</_fem_dwelownlti_note_>
gen   fem_dwelownlti = .a
notes fem_dwelownlti: the HIES does not contain information to define this variable
*</_fem_dwelownlti_>

*<_dwelownti_>
*<_dwelownti_note_> Type of Legal document *</_dwelownti_note_>
/*<_dwelownti_note_> 1 "Title, deed, freehold" 2 "Government issued leasehold" 3 "Occupancy certificate – govt issued" 4 "legal document in the name of group (community  cooperative)" 5 "condominium (apartment)" 6 "Other" *</_dwelownti_note_>*/
*<_dwelownti_note_> dwelownti brought in from raw data *</_dwelownti_note_>
gen   dwelownti = .a
notes dwelownti: the HIES does not contain information to define this variable
*</_dwelownti_>

*<_selldwel_>
*<_selldwel_note_> Right to sell dwelling *</_selldwel_note_>
/*<_selldwel_note_> 1 "Yes" 0 "No" *</_selldwel_note_>*/
*<_selldwel_note_> selldwel brought in from raw data *</_selldwel_note_>
gen   selldwel = .a
notes selldwel: the HIES does not contain information to define this variable
*</_selldwel_>

*<_transdwel_>
*<_transdwel_note_> Right to transfer dwelling *</_transdwel_note_>
/*<_transdwel_note_> 1 "Yes" 0 "No" *</_transdwel_note_>*/
*<_transdwel_note_> transdwel brought in from raw data *</_transdwel_note_>
gen   transdwel = .a
notes transdwel: the HIES does not contain information to define this variable
*</_transdwel_>

*<_ownland_>
*<_ownland_note_> Ownership of land *</_ownland_note_>
/*<_ownland_note_> 1 "Yes" 0 "No" *</_ownland_note_>*/
*<_ownland_note_> ownland brought in from raw data *</_ownland_note_>
gen 	ownland = 0
replace ownland = 1			if  S7AQ02>0 & S7AQ02<.
notes   ownland: variable defined using information on "total dwelling-house/homestead land owned"
*</_ownland_>

*<_acqui_land_>
*<_acqui_land_note_> Acquisition of residential land *</_acqui_land_note_>
/*<_acqui_land_note_> 1 "Purchased" 2 "Inherited" 3 "Other" *</_acqui_land_note_>*/
*<_acqui_land_note_> acqui_land brought in from raw data *</_acqui_land_note_>
gen   acqui_land = .a
notes acqui_land: the HIES does not contain information to define this variable
*</_acqui_land_>

*<_doculand_>
*<_doculand_note_> Legal document for residential land *</_doculand_note_>
/*<_doculand_note_> 1 "Yes" 0 "No" *</_doculand_note_>*/
*<_doculand_note_> doculand brought in from raw data *</_doculand_note_>
gen   doculand = .a
notes doculand: the HIES does not contain information to define this variable
*</_doculand_>

*<_fem_doculand_>
*<_fem_doculand_note_> Legal document for residential land - female *</_fem_doculand_note_>
/*<_fem_doculand_note_> 1 "Yes" 0 "No" *</_fem_doculand_note_>*/
*<_fem_doculand_note_> fem_doculand brought in from raw data *</_fem_doculand_note_>
gen   fem_doculand = .a
notes fem_doculand: the HIES does not contain information to define this variable
*</_fem_doculand_>

*<_landownti_>
*<_landownti_note_> Land Ownership *</_landownti_note_>
/*<_landownti_note_> 1 "Title deed" 2 "leasehold (govt issued)" 3 "Customary land certificate/plot level" 4 "Customary based/group right" 5 "Cooperative group right" 6 "Other" *</_landownti_note_>*/
*<_landownti_note_> landownti brought in from raw data *</_landownti_note_>
gen   landownti = .a
notes landownti: the HIES does not contain information to define this variable
*</_landownti_>

*<_sellland_>
*<_sellland_note_> Right to sell land *</_sellland_note_>
/*<_sellland_note_> 1 "Yes" 0 "No" *</_sellland_note_>*/
*<_sellland_note_> sellland brought in from raw data *</_sellland_note_>
gen   sellland = .a
notes sellland: the HIES does not contain information to define this variable
*</_sellland_>

*<_transland_>
*<_transland_note_> Right to transfer land *</_transland_note_>
/*<_transland_note_> 1 "Yes" 0 "No" *</_transland_note_>*/
*<_transland_note_> transland brought in from raw data *</_transland_note_>
gen   transland = .a
notes transland: the HIES does not contain information to define this variable
*</_transland_>

*<_agriland_>
*<_agriland_note_> Agriculture Land *</_agriland_note_>
/*<_agriland_note_> 1 "Yes" 0 "No" *</_agriland_note_>*/
*<_agriland_note_> agriland brought in from raw data *</_agriland_note_>
gen 	agriland = 0
replace agriland = 1			if  S7AQ06>0 & S7AQ06<.
*</_agriland_>

*<_area_agriland_>
*<_area_agriland_note_> Area of Agriculture land *</_area_agriland_note_>
/*<_area_agriland_note_> *</_area_agriland_note_>*/
*<_area_agriland_note_> area_agriland brought in from raw data *</_area_agriland_note_>
gen     area_agriland = S7AQ06/2.471
replace area_agriland = .		if  area_agriland==0
*</_area_agriland_>

*<_ownagriland_>
*<_ownagriland_note_> Ownership of agriculture land *</_ownagriland_note_>
/*<_ownagriland_note_> 1 "Yes" 0 "No" *</_ownagriland_note_>*/
*<_ownagriland_note_> ownagriland brought in from raw data *</_ownagriland_note_>
egen aux_land = rsum(S7AQ01 S7AQ02 S7AQ03 S7AQ05)
gen 	ownagriland = 0
replace ownagriland = 1		if  aux_land>0 & aux_land<.
replace ownagriland = .		if  agriland!=1
*</_ownagriland_>

*<_area_ownagriland_>
*<_area_ownagriland_note_> Area of agriculture land owned *</_area_ownagriland_note_>
/*<_area_ownagriland_note_> *</_area_ownagriland_note_>*/
*<_area_ownagriland_note_> area_ownagriland brought in from raw data *</_area_ownagriland_note_>
gen     area_ownagriland = aux_land/2.471
replace area_ownagriland = .	if  area_ownagriland==0
replace area_ownagriland = .	if  ownagriland!=1
drop aux_land
*</_area_ownagriland_>

*<_purch_agriland_>
*<_purch_agriland_note_> Purchased agri land *</_purch_agriland_note_>
/*<_purch_agriland_note_> 1 "Yes" 0 "No" *</_purch_agriland_note_>*/
*<_purch_agriland_note_> purch_agriland brought in from raw data *</_purch_agriland_note_>
gen   purch_agriland = .a
notes purch_agriland: the HIES does not contain information to define this variable
*</_purch_agriland_>

*<_areapurch_agriland_>
*<_areapurch_agriland_note_> Area of purchased agriculture land *</_areapurch_agriland_note_>
/*<_areapurch_agriland_note_>  *</_areapurch_agriland_note_>*/
*<_areapurch_agriland_note_> areapurch_agriland brought in from raw data *</_areapurch_agriland_note_>
gen   areapurch_agriland = .a
notes areapurch_agriland: the HIES does not contain information to define this variable
*</_areapurch_agriland_>

*<_inher_agriland_>
*<_inher_agriland_note_> Inherit agriculture land *</_inher_agriland_note_>
/*<_inher_agriland_note_> 1 "Yes" 0 "No" *</_inher_agriland_note_>*/
*<_inher_agriland_note_> inher_agriland brought in from raw data *</_inher_agriland_note_>
gen   inher_agriland = .a
notes inher_agriland: the HIES does not contain information to define this variable
*</_inher_agriland_>

*<_areainher_agriland_>
*<_areainher_agriland_note_> Area of inherited agriculture land *</_areainher_agriland_note_>
/*<_areainher_agriland_note_>  *</_areainher_agriland_note_>*/
*<_areainher_agriland_note_> areainher_agriland brought in from raw data *</_areainher_agriland_note_>
gen   areainher_agriland = .a
notes areainher_agriland: the HIES does not contain information to define this variable
*</_areainher_agriland_>

*<_rentout_agriland_>
*<_rentout_agriland_note_> Rent Out Land *</_rentout_agriland_note_>
/*<_rentout_agriland_note_> 1 "Yes" 0 "No" *</_rentout_agriland_note_>*/
*<_rentout_agriland_note_> rentout_agriland brought in from raw data *</_rentout_agriland_note_>
gen     rentout_agriland = 0
replace rentout_agriland = 1		if  S7AQ05>0 & S7AQ05<.
replace rentout_agriland = .		if  ownagriland!=1
*</_rentout_agriland_>

*<_arearentout_agriland_>
*<_arearentout_agriland_note_> Area of rent out agri land *</_arearentout_agriland_note_>
/*<_arearentout_agriland_note_> *</_arearentout_agriland_note_>*/
*<_arearentout_agriland_note_> arearentout_agriland brought in from raw data *</_arearentout_agriland_note_>
gen     arearentout_agriland = S7AQ05/2.471
replace arearentout_agriland = .	if  rentout_agriland!=1
*</_arearentout_agriland_>

*<_rentin_agriland_>
*<_rentin_agriland_note_> Rent in Land *</_rentin_agriland_note_>
/*<_rentin_agriland_note_> 1 "Yes" 0 "No" *</_rentin_agriland_note_>*/
*<_rentin_agriland_note_> rentin_agriland brought in from raw data *</_rentin_agriland_note_>
gen     rentin_agriland = 0
replace rentin_agriland = 1		if  S7AQ04>0 & S7AQ04<.
replace rentin_agriland =.		if  agriland!=1
*</_rentin_agriland_>

*<_arearentin_agriland_>
*<_arearentin_agriland_note_> Area of rent in agri land *</_arearentin_agriland_note_>
/*<_arearentin_agriland_note_>  *</_arearentin_agriland_note_>*/
*<_arearentin_agriland_note_> arearentin_agriland brought in from raw data *</_arearentin_agriland_note_>
gen     arearentin_agriland = S7AQ04/2.471
replace arearentin_agriland = .	if  rentin_agriland!=1
*</_arearentin_agriland_>

*<_docuagriland_>
*<_docuagriland_note_> Documented Agri Land *</_docuagriland_note_>
/*<_docuagriland_note_> 1 "Yes" 0 "No" *</_docuagriland_note_>*/
*<_docuagriland_note_> docuagriland brought in from raw data *</_docuagriland_note_>
gen   docuagriland = .a
notes docuagriland: the HIES does not contain information to define this variable
*</_docuagriland_>

*<_area_docuagriland_>
*<_area_docuagriland_note_> Area of documented agri land *</_area_docuagriland_note_>
/*<_area_docuagriland_note_>  *</_area_docuagriland_note_>*/
*<_area_docuagriland_note_> area_docuagriland brought in from raw data *</_area_docuagriland_note_>
gen   area_docuagriland = .a
notes area_docuagriland: the HIES does not contain information to define this variable
*</_area_docuagriland_>

*<_fem_agrilandownti_>
*<_fem_agrilandownti_note_> Ownership Agri Land - Female *</_fem_agrilandownti_note_>
/*<_fem_agrilandownti_note_> 1 "Yes" 0 "No" *</_fem_agrilandownti_note_>*/
*<_fem_agrilandownti_note_> fem_agrilandownti brought in from raw data *</_fem_agrilandownti_note_>
gen   fem_agrilandownti = .a
notes fem_agrilandownti: the HIES does not contain information to define this variable
*</_fem_agrilandownti_>

*<_agrilandownti_>
*<_agrilandownti_note_> Type Agri Land ownership doc *</_agrilandownti_note_>
/*<_agrilandownti_note_> 1 "Title  deed" 2 "Leasehold (govt issued)" 3 "Customary land certificate/plot level" 4 "Customary based / group right" 5 "Cooperative" 6 "Other" *</_agrilandownti_note_>*/
*<_agrilandownti_note_> agrilandownti brought in from raw data *</_agrilandownti_note_>
gen   agrilandownti = .a
notes agrilandownti: the HIES does not contain information to define this variable
*</_agrilandownti_>

*<_sellagriland_>
*<_sellagriland_note_> Right to sell agri land *</_sellagriland_note_>
/*<_sellagriland_note_> 1 "Yes" 0 "No" *</_sellagriland_note_>*/
*<_sellagriland_note_> sellagriland brought in from raw data *</_sellagriland_note_>
gen   sellagriland = .a
notes sellagriland: the HIES does not contain information to define this variable
*</_sellagriland_>

*<_transagriland_>
*<_transagriland_note_> Right to transfer agri land *</_transagriland_note_>
/*<_transagriland_note_> 1 "Yes" 0 "No" *</_transagriland_note_>*/
*<_transagriland_note_> transagriland brought in from raw data *</_transagriland_note_>
gen   transagriland = .a
notes transagriland: the HIES does not contain information to define this variable
*</_transagriland_>

*<_dweltyp_>
*<_dweltyp_note_> Types of Dwelling *</_dweltyp_note_>
/*<_dweltyp_note_> 1 "Detached house" 2 "Multi-family house" 3 "Separate apartment" 4 "Communal apartment" 5 "Room in a larger dwelling" 6 "Several buildings connected" 7 "Several separate buildings" 8 "Improvised housing unit" 9 "Other" *</_dweltyp_note_>*/
*<_dweltyp_note_> dweltyp brought in from raw data *</_dweltyp_note_>
gen   dweltyp = .a
notes dweltyp: the HIES does not contain information to define this variable
*</_dweltyp_>

*<_typlivqrt_>
*<_typlivqrt_note_> Types of living quarters *</_typlivqrt_note_>
/*<_typlivqrt_note_>  1 "Housing units, conventional dwelling with basic facilities" 2 "Housing units, conventional dwelling without basic facilities" 3 "Other" *</_typlivqrt_note_>*/
*<_typlivqrt_note_> typlivqrt brought in from raw data *</_typlivqrt_note_>
gen   typlivqrt = .a
notes typlivqrt: the HIES does not contain information to define this variable
*</_typlivqrt_>


*<_Keep variables_>
order countrycode year hhid pid weight weighttype
sort  hhid pid
*</_Keep variables_>


*<_Save data file_>
quietly do 	"$rootdofiles\_aux\Labels_GMD2.0.do"
save 		"$rootdatalib\GMD\\`code'\\`yearfolder'\\`gmdfolder'\Data\Harmonized\\`filename'.dta" , replace
*</_Save data file_>
