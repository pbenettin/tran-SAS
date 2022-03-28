% script to prepare some test hourly data to use in the SAS model

% the code takes synthetic measurements from file 
% 'virtual_measurements.csv', and computes a few more variables. All 
% variables are exported to file 'hourlydata_test.csv'

% complete list of data exported through this script:
% hourly time stamps (dates)
% precipitation (J) 
% discharge (Q) 
% evapotranspiration (ET) 
% input concentration (Cin)
% an index of catchment wetness (wi)
% measured solute concentration in streamflow (measC_Q )

clear variables
close all
clc


% -------------------------------------------------------------------------
% ASSIGN MAIN PARAMETERS AND GENERAL SETTINGS
% -------------------------------------------------------------------------
flag_dataexport = 1; %export data as textfile
import_filename = 'virtual_measurements.csv';
export_filename = 'testdata.csv'; %export data filename


%--------------------------------------------------------------------------
% BUILD THE DATASET
%--------------------------------------------------------------------------

% import data into a table 
A = readtable(import_filename);
dt = 1; %hourly time step

% hydrologic balance to compute normalized storage variations V
V = zeros(size(A,1),1);
V(1) = 0; %arbitrary initial condition
for i = 1:size(V,1)-1
    V(i+1) = V(i)+(A.J(i)-A.Q(i)-A.ET(i))*dt;
end
V = V-mean(V);
    
% create an index wi in [0,1] representing some catchment wetness state
% here wi is proportional to the water storage V
wi = (V-min(V))./(max(V)-min(V));

% define/modify Cin and Cout
C_choice = 1;
    % C_choice=1 takes virtual example measurements
    % C_choice=2 is to make hypothetical tests, hence no measured output is considered

if C_choice == 1
    Cin = A.Cin; % virtual Cin from file
    Cout = A.Cout; % virtual Cout from file
elseif C_choice==2 
    Cin = 50*ones(size(A,1),1); %preallocate a constant input
    Cin(round(0.25*size(A,1))-1:end) = 40; %induce an input step reduction by 20%
    Cout = NaN(size(Cin)); %avoid measured output
end



%--------------------------------------------------------------------------
% export to textfile for tran-SAS
%--------------------------------------------------------------------------

if flag_dataexport == 1
    fprintf('Exporting data to file %s...',export_filename)
      
    % prepare the table
    T = array2table(A.date); T.Properties.VariableNames = {'date'};
    T.J = A.J;
    T.Q = A.Q;
    T.ET = A.ET;
    T.Cin = Cin;
    T.measC_Q = Cout;
    T.wi = wi;

    % print a csv file with all the data
    writetable(T,fullfile('..',export_filename));
    
    % print a readme file with some info
    fid = fopen(fullfile('..',[export_filename,'_README.txt']),'w');
    fprintf(fid,'# Automatic README file generated for ''%s''\n\n',export_filename);
    fprintf(fid,'The file ''%s'' includes tabular data at hourly timesteps:\n\n',export_filename);
    fprintf(fid,'- date, formatted as datetime dd-mmm-yyyy HH:MM:SS (e.g. 01-Jan-2020 00:00:00)\n');
    fprintf(fid,'- J, precipitation in mm/h\n');
    fprintf(fid,'- Q, streamflow in mm/h\n');
    fprintf(fid,'- ET, evapotranspiration in mm/h\n');
    fprintf(fid,'- Cin, input tracer concentration\n');
    fprintf(fid,'- wi, indicator of wetness index, non-dimensional and confined within [0-1]. Here, it is the storage normalized to [0-1]\n');
    fprintf(fid,'- measC_Q, output sampled concentration\n\n');
    fprintf(fid,'Missing values are indicates as NaN');
    fclose(fid);

    fprintf(' done\n')
end




