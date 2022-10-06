# tran-SAS

The tran-SAS package includes a set of MATLAB codes to compute catchment-scale hydrologic transport using StorAge Selection (SAS) functions. The model addresses the transport of a conservative solute through a hydrologic system (e.g., a catchment or a lysimeter) and computes streamflow age and concentration.  

The package is introduced and discussed in: Benettin, P., & Bertuzzo, E. (2018). tran-SAS v1.0: a numerical model to compute catchment-scale hydrologic transport using StorAge Selection functions. Geoscientific Model Development, 11(4), 1627–1639. https://doi.org/10.5194/gmd-11-1627-2018

The code is expected to be compatible with all MATLAB versions after R2018a and likely also with earlier versions. No toolboxes are used by default, but the use of some probability density functions (e.g. the beta distribution) requires the Statistics Toolbox.

## Versions

- v2.0: the code at the heart of the package is unchanged, but the code organization has been reformatted to make development and applications easier. The documentation has not yet been updated.

- v1.0: original release, described by Benettin and Bertuzzo (2018). The code is mainly intended for educational use and the user needs to adapt the code to use it on a case study.

## Running the model (version v2.0)

The current model version can be run by executing the script `model_STARTER.m`. The starter will open the file `case_study_name.txt` to read the name of the case study to run. Then, it will read the associated configuration file (case_studies > {case study name} > `config_file.m`) and run the model according to that configuration. A synthetic dataset (`TestData`) is provided for testing. You can modify the model parameters and simulation settings through the configuration file.

To run the model on your own data, you need to prepare a new case study:

- create a new directory inside the 'case_studies' folder
- prepare a .csv data table formatted as the example testdata.csv (see also the associated README file)
- fill-in a config_file for your case study
- write the new case study name into the text file case_study_name.txt, such that the model starter selects the right case study