# PandemicTics
Stata do-files for preparation and analysis of CPRD data for a project about tics incidence rates during the COVID-19 Coronavirus pandemic.

## Introduction
This repository contains all the Stata do-files and code lists required to prepare and analyse CPRD Aurum datasets for a project comparing the incidence of tics in children and young people in England before (2015-2019) and during (2020, 2021) the COVID-19 pandemic.The data contain anonymised health records from England and are provided under licence from CPRD and cannot be shared. For more information see https://www.cprd.com/. The code and additional information should allow anybody to repeat the analysis if they have permission to access CPRD.

The analysis, including the protocol and the Stata code in this repository, was designed and written by researchers at the University of Nottingham. The work was funded by the NIHR Nottingham Biomedical Research Centre. This code underpins all of the results of this study, including those presented in published works, and has been shared for purposes of transparency and reproducibility. Any views represented are the views of the authors alone and do not necessarily represent the views of the Department of Health in England, NHS, or the National Institute for Health Research.

We request that any use of or reference to the Stata code within this repository is cited appropriately using the information provided on its Zenodo entry.

## Using the files
### Stata information
This project was performed using Stata/MP v17. Reuse requires at least Stata 16 as the frames function is used throughout. The following Stata packages are required:
- frameappend (ssc install frameappend)

### Data
The data were provided under licence by the Clinical Practice Research Datalink (CPRD, CPRD AURUM dataset March 2022). The database query used to define primary care data has been provided (Define_March22.docx). The linked data (patient- and practice-level Index of Multiple Deprivation quintiles) were provided directly by CPRD for a subset of patients (the code to define these patients is provided).

The code lists and related information used in the analysis have been provided in this upload. No other data are attached (no raw or processed CPRD files are included). 

To repeat the analysis without altering file paths, you will require the following data files in the specified directories:

File path | File description
--------- | ----------------
data_raw/202201_Lookups_CPRDAurum/202201_EMISMedicalDictionary.txt | Jan 2022 CPRD Aurum Medical Dictionary as provided by CPRD
data_raw/202201_Lookups_CPRDAurum/202201_EMISProductDictionary.txt | Jan 2022 CPRD Aurum Product Dictionary as provided by CPRD
data_raw/AurumDenominator_202203/202203_CPRDAurum_AcceptablePats.txt | Mar 2022 CPRD Aurum 'Acceptable patients' denominator file as provided by CPRD
data_raw/AurumDenominator_202201/202201_CPRDAurum_AcceptablePats.txt | Jan 2022 CPRD Aurum 'Acceptable patients' denominator file (used to define linkage eligibility)
data_raw/Aurum_extract_2022-03/tics202203_Define_results.txt | List of patients meeting eligibility criteria after querying CPRD Define (Mar 2022)
data_raw/Aurum_extract_2022-03/tics202203_Extract_Observation_001.txt | Observation file for eligible patients as extracted from CPRD (Mar 2022)
data_raw/codelists/TicsProject_ReadCodes_v2.xlsx | Code list lookup file, provided in this repository
data_raw/imd/patient_imd2015_21_001650.txt | Linked data set, patient-level IMD, provided by CPRD, based on Jan 2022 linkage
data_raw/imd/practice_imd_21_001650.txt | Linked data set, practice level IMD, provided by CPRD, based on Jan 2022 linkage
data_raw/set_21_Source_Aurum/linkage_eligibility.txt | Linkage set 21 source file provided by CPRD

### Running the code
- The file 'do/scripts_masterfile_v2.do' should be used to run the analysis. The path to the working directory must be set at **line 17**. All other scripts use relative paths.
