# tran-SAS

The tran-SAS package includes a set of MATLAB codes to compute 
catchment-scale hydrologic transport using StorAge Selection (SAS) 
functions. The model addresses the transport of a conservative solute 
through a hydrologic system (e.g., a catchment or a lysimeter) and 
computes streamflow age and concentration.  

The package is introduced and discussed in: 
Benettin, P., & Bertuzzo, E. (2018). tran-SAS v1.0: a numerical model 
to compute catchment-scale hydrologic transport using StorAge Selection 
functions. Geoscientific Model Development, 11(4), 1627–1639. 
https://doi.org/10.5194/gmd-11-1627-2018

The code is compatible with MATLAB versions after R2018a.

## Running the model

The current model version can be run by executing the script `model_STARTER.m`. The starter will search the file `case_study_name.txt` for the name of the case study to run. Then, it will read the associated configuration file (case_studies > {case study name} > `config_file.m`) and run the model according to that configuration. A synthetic dataset (`TestData`) is provided for testing. You can modify the model parameters and simulation settings through the configuration file.

To run the model on your own data, you need to prepare a new case study:

- create a new directory inside the 'case_studies' folder
- prepare a .csv data table formatted as the example testdata.csv (see also the associated README file)
- fill-in a config_file for your case study
- write the new case study name into the text file case_study_name.txt, such that the model starter selects the right case study