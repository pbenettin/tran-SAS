% this file stores all the main model configurations

% GENERAL SIMULATION SETTINGS
% select the CASE STUDY and the MODEL
datasetName = 'testdata.csv'; 
ModelName = 'SAS_EFs';  %weathering model with isotope fractionation
outfilename = 'all_output';     %output filename (both for .mat and .csv outputs)

% select the AGGREGATION timestep and the STORAGE threshold (numerical parameters)
dt_aggr = 12;          %dt for the computations [h] (must be integer)
f_thresh = 1;          %fraction of rank storage [-] after which the storage is sampled uniformly
                       %(just leave f_thresh=1 if not interested in this option)

% select the variable 'out' that is returned when calling the model
% 'C_Qsampl': modeled data during time steps with measurements only
% 'C_Qmodel': modeled data over all time steps
data.outputchoice='C_Qsampl'; 

% some further options
create_spinup = true;        %generate a spinup period
extract_agedistrib = false;  %save TTDs over selected days
save_output = true;          %save model variables
display_output = true;       %display the output at the end
export_output = false;        %print output to csvfile


% MODEL PARAMETERS
% select the SAS
data.SASQName='fSAS_pltv'; %time-variant power-law SAS
data.SASETName='fSAS_step'; %step SAS

% set parameter names and values
SASQparamnames={'kmin_Q','kmax_Q'}; Param.SAS(1:2)=[.7, 1]; %[-]
SASETparamnames={'k_ET'};    Param.SAS(3)=.8;  %[-]
otherparamnames={'S0'};      Param.SAS(4)=1500; %[mm]

% set chemical parameters and values (2 reactions, for major and rare isotopes)
%data.frac_reaction = @c_n_FF; %rare isotope reaction model (Fixed Fractionation model)

% SELECT SOME AGE DISTRIBUTIONS TO EXTRACT
% choose dates for which TTDs are saved (only used if extract_agedistrib=1)
data.datesel={...
    '01-Jun-2015';...
    '01-Jul-2015';...
    };

% spinup settings (only used if create_spinup=1)
data.C_S0 = 50; %concentration of the initial storage
period_rep = [1,365*1]; %starting and ending day of the datasets which will be repeated
n_rep = 2; % (integer) number of times that period_rep will be repeated; if n_rep=0, then no spinup is created
data.show_spinup = false; %show spinup along with the results?

% display some stuff (optional flags)
flag_eff = 1;          %compute and display model efficiency
flag_plot.active = 1;  %to activate/disactivate all plotting
flag_plot.Cout = 1;       %main plot with the full concentration timeseries
flag_plot.TTDs = 0;       %plot TTDs for selected days
flag_plot.agestats = 0;   %plot with additional age timeseries
