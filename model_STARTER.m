%**************************************************************************
% STARTER PROGRAM for the transport model based on SAS functions.
% The code is described in:
% 
% The numerical model is described by:
% Benettin, P., & Bertuzzo, E. (2018). tran-SAS v1.0: a numerical model 
% to compute catchment-scale hydrologic transport using StorAge Selection 
% functions. Geoscientific Model Development, 11(4), 1627–1639. 
% https://doi.org/10.5194/gmd-11-1627-2018
%
% The codes implements the transport model described by:
% Rinaldo, A., Benettin, P., Harman, C. J., Hrachowitz, M., McGuire, K. J.,
% van der Velde, Y., Bertuzzo, E., and Botter, G. (2015). Storage selection 
% functions: A coherent framework for quantifying how catchments store and 
% release water and solutes. Water Resources Research, 51(6), 4840–4847. 
% http://doi.org/10.1002/2015WR017273
%**************************************************************************

% This script imports data from a case study and runs the SAS model to
% compute tracer transport and travel time distributions

% The code is organized as follows:
% 1) initial settings (e.g. choose model, case study, etc... )
% 2) load data from the case study and modify the timestep
% 3) set parameters for the specific case study and model
% 4) (if desired) select dates in which to save age computations
% 5) (if required) set/generate initial conditions
% 6) run the model
% 7) call some simple results visualization

clear variables
addpath('models')
addpath('functions')
addpath('case_study')


%--------------------------------------------------------------------------
% 1-GENERAL SIMULATION SETTINGS
%--------------------------------------------------------------------------

% select the CASE STUDY and the MODEL 
datasetName='testdata.dat';  %text file with data (check formatting specs)
ModelName='SAS_EFs';         %model to be run (SAS_EFs and SAS_odesolver are available)

% two model implementations are available:
% 1-SAS_EFs, which includes a (modified) Euler Forward solution 
% 2-SAS_odesolver, which uses Matlab built-in ode solvers. The numerical 
% accuracy is improved but the code runs > 50 times slower

% select the AGGREGATION timestep and the STORAGE threshold (numerical parameters)
dt_aggr=12;          %dt for the computations [h] (must be integer)
f_thresh=1;          %fraction of rank storage [-] after which the storage is sampled uniformly
                     %(just leave f_thresh=1 if not interested in this option)

% some further options
create_spinup=1;     %generate a spinup period: 1=yes
save_output=1;       %save model variables: 1=yes
load_output=1;       %display the output at the end: 1=yes 


%--------------------------------------------------------------------------
% 2-DATA IMPORT and AGGREGATION
%--------------------------------------------------------------------------

% the dataset needs to include the following data: 
% J, ET, Q, dates       %continuous, at hourly time step
% C_J,                  %continuous, at hourly time step
% wi                    %continuous, at hourly time step
% measC_Q               %where available, at hourly time step 

% (automatic) hourly data are imported from textfile 'datasetName' into cell array A
fid=fopen(datasetName);
A=textscan(fid,...
    '%16c %f %f %f %f %f %f',...
    'HeaderLines',1); %dates,J,Q,ET,Cin,wi,measC_Q
fclose(fid);

% (automatic) aggregate hourly data to timestep dt_aggr using a separate script
data=fdata_aggregate(A,dt_aggr);
clear A



%--------------------------------------------------------------------------
% 3-PARAMETERS
%--------------------------------------------------------------------------

% some examples are provided below. Choose between 1,2 and 3
example=1;


% EXAMPLE 1 : SASQ with fixed power-law shape
if example==1
    % select the SAS
    data.SASQName='fSAS_pl'; %power-law SAS
    data.SASETName='fSAS_pl'; %power-law SAS

    % parameter names and values
    SASQparamnames={'k_Q'};      Pars(1)=0.7;  %[-]
    SASETparamnames={'k_ET'};    Pars(2)=0.7;  %[-]
    otherparamnames={'S0'};      Pars(3)=1000; %[mm]
end

% EXAMPLE 2: SASQ with time-variant power-law shape
if example==2
    % select the SAS
    data.SASQName='fSAS_pltv'; %time-variant power-law SAS
    data.SASETName='fSAS_pl'; %power-law SAS

    % parameter names and values
    SASQparamnames={'kmin_Q','kmax_Q'}; Pars(1:2)=[0.3,0.9]; %[-]
    SASETparamnames={'beta_ET'};        Pars(3)=1; %[-]
    otherparamnames={'S0'};             Pars(4)=1000; %[mm]
end

% EXAMPLE 3 : SASQ with Beta shape
if example==3
    % select the SAS
    data.SASQName='fSAS_beta'; %beta SAS
    data.SASETName='fSAS_pl'; %power-law SAS

    % parameter names and values
    SASQparamnames={'alpha','beta'};    Pars(1:2)=[1.5,0.8]; %[-]
    SASETparamnames={'beta_ET'};        Pars(3)=1; %[-]
    otherparamnames={'S0'};             Pars(4)=1000; %[mm]
end


% (automatic) unify the parameters into one series and print some info to screen
data.SASQl=length(SASQparamnames);
data.SASETl=length(SASETparamnames);
data.paramnames=[SASQparamnames,SASETparamnames,otherparamnames];  
disp(' ')
disp(['Model:   ',ModelName])
disp(['dt:      ',num2str(dt_aggr),'h'])
disp(['SAS Q:   ',data.SASQName])
disp(['SAS ET:  ',data.SASETName])
disp('parameters:')
for i=1:length(Pars)
    fprintf(1,'%9s = %7.2f \n',char(data.paramnames(i)),Pars(i));
end



%--------------------------------------------------------------------------
% 4-SELECT THE AGE DISTRIBUTIONS TO EXTRACT
%--------------------------------------------------------------------------
% define a vector of dates in matlab format. Discharge age distributions 
% will be evaluated on the closest available day and will be stored into 
% the matrix age_matr. If not interested in evaluating age distributions,
% simply leave data.datesel={}

% select the dates 
data.datesel={...
    '15-Aug-2015',...
    '15-Feb-2016',...
    };
dateform='dd-mmm-yyyy'; %date format

% (automatic) check that desired dates actually exist and find the index 
% of the closest time in the dataset
tmp=zeros(size(data.datesel));
for i=1:length(data.datesel)
    if datenum(data.datesel(i))<data.dates(1) ||...
            datenum(data.datesel(i))>data.dates(end)
        warning(['the date ',data.datesel{i},...
            ' selected for streamflow age evaluation ',...
            'does not exist in the dataset'])
    else 
        [~,tmp(i)]=min(abs(data.dates-...
            datenum(data.datesel(i),dateform))); %closest date in the dataset
    end
end
data.index_datesel=tmp(tmp>0);



%--------------------------------------------------------------------------
% 5-INITIAL CONDITIONS
%--------------------------------------------------------------------------

% assign the concentration of the initial storage
data.C_S0=50;   

% spinup settings (only used if create_spinup=1)
period_rep=[1,365*4]; %starting and ending day of the datasets which will be repeated
n_rep=1; % (integer) number of times that period_rep will be repeated; if n_rep=0, then no spinup is created

% (automatic) if needed, create the spinup
if create_spinup==1
    data=fgenerate_spinup(data,period_rep,n_rep); %use an external function
else
    data.ini_shift=0; %no shift in the dataset if no spinup is used
end



%--------------------------------------------------------------------------
% 6-RUN THE MODEL
%--------------------------------------------------------------------------

% store few more entries into the structure 'data'
data.f_thresh=f_thresh;       %pass storage threshold information to the model
data.save_output=save_output;  %pass saving information to the model

% let's go for the model run
disp(' ')
disp('calculating model output...')
tic
feval(ModelName,Pars,data) %run the model 'ModelName' using parameters 'Pars' and data 'data'
toc



%--------------------------------------------------------------------------
% 7-SHOW RESULTS
%--------------------------------------------------------------------------

if load_output==1

    % additional optional flags to display just part of the outputs
    flag_eff=1;          %compute model efficiency
    flag_plot.Cout=1;    %plot with modeled/measured streamflow concentration
    flag_plot.TTDs=1;    %plot TTDs for selected days

    % load the default output 'all_output' saved to the results folder
    load 'results\all_output'

    % compute some model efficiency
    if flag_eff==1
        % use the external function Eff-SAS
        [eff, eff_info]=Eff_SAS(data.measC_Q,C_Q(data.indexC_Q));
    end

    % plot the output
    if flag_plot.Cout || flag_plot.TTDs ==1
        run('plot_results'); %run a script that plots some results
    end
    
end


%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%  END OF FILE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%