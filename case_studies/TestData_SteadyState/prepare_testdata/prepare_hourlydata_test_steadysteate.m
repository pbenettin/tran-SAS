% script to prepare some test hourly data to use in the SAS model

% the code defines the costant hydrologic fluxes, the duration of the
% dataset and generates a sinusoidal input concentration

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
export_filename = 'testdata_steadystate.csv';
Nyears=5; %number of years of data to be generated
yearly_J=1000; % mm/year of precipitation
Q_ET_partition=0.5; %partitioning [-] between Q and ET fluxes


%--------------------------------------------------------------------------
% generate dates and hydrologic fluxes
%--------------------------------------------------------------------------

% generate dates
startdate = '01-Jan-2050';
dt = hours(1);
dates = transpose(datetime(startdate):dt:datetime(startdate)+years(Nyears)); %virtual dates
N = length(dates);

% hydrologic fluxes
J = yearly_J*Nyears/N*ones(N,1); %hourly precipitation in mm/h
Q = J*Q_ET_partition; %hourly discharge in mm/h
ET = J-Q; %hourly ET in mm/h

% generate a wetness index wi, which is useless at steady state but is needed for compatibility
wi = 0.5*ones(N,1);

%--------------------------------------------------------------------------
% GENERATE Cin and Cout
%--------------------------------------------------------------------------
% parameters for sinusoidal concentration input
per = 1*365.25; %period [d]
ampl = 25; %amplitude [-]
shif = 0; %phase [d]
offs = 0; %signal mean [arbitrary units]

% generate the timeseries
Cin = offs+ampl*sin(2*pi*(datenum(dates)-datenum(dates(1)))/per+2*pi*shif/per); %sinusoidal input concentration
Cout = NaN(size(Cin)); %avoid measured output

% plot Cin if requested
plot_Cin=0;
if plot_Cin==1
    plot(dates,Cin)
    datetick
end



%--------------------------------------------------------------------------
% export to textfile
%--------------------------------------------------------------------------
T = array2table(dates); T.Properties.VariableNames = {'date'};
T.J = J;
T.Q = Q;
T.ET = ET;
T.wi = wi;
T.Cin = Cin;
T.measC_Q = Cout;

%--------------------------------------------------------------------------
% export to textfile for tran-SAS
%--------------------------------------------------------------------------

if flag_dataexport == 1
    fprintf('Exporting data to file %s...',export_filename)
      
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







