# SAR_HouseholdSurveys
This repository allows to harmonize the Household Surveys (HIES) for the South Asia Region.
<br>
<br>
<br>

## Description
Here you can find all the Stata do files codes for the Household Surveys used by the South Asia Regional (SAR) Statistical Team at the World Bank. 
In this repository, we have the following years available:

| Year    | Afghanistan | Bangladesh | Bhutan | India  | Maldives | Nepal  | Pakistan | Sri Lanka | 
| :----   | :----:      | :----:     | :----: | :----: |  :----:  | :----: | :----:   | :----:    | 
| 2000    |     --      | A          | --  | --   | --  | --   | --  |  --  | 
| 2005    |     --      | A          | --  | --   | --  | --   | --  |  --  | 
| 2010    |     --      | A          | --  | --   | --  | --   | --  |  --  | 
| 2016    |     --      | A          | --  | --   | --  | --   | --  |  --  | 
| 2022    |     --      | A          | A  | --   | --  | --   | --  |  --  | 

## Getting Started
### Step-by-step explanation
1. Run the Master do file available in the "Master" directory for each country and year: "code_year_survey_M". 
  
2. Run the SARMD do files available in the "SARMD" directory for each country and year: "code_year_survey_SARMD".
   <br>
   a. First, please run the Income do file "code_year_survey__INC.do".
   <br>
   b. Then, run the IND do file "code_year_survey__IND.do".
   
4. Run the SARMD do files available in the "GMD" directory for each country and year, in the following order:
   <br>
   a. Run the COR, DEM, DWL,GEO,IDN,LBR, UTL do files.
   <br>
   b. Run the GMD do file (that will allow you to have the final GMD database that is uploaded to datalibweb).

## Help
For any questions, please get in contact with the SAR Statistical Team at: sardatalab@worldbank.org

## Authors
SAR Stats Team
* Leopoldo Tornarolli
* Adriana Castillo-Castillo

## Version History
* 0.1
    * Initial Release
