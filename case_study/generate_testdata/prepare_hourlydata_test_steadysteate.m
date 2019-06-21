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

%--------------------------------------------------------------------------
% DATA generation parameters
%--------------------------------------------------------------------------
% data are imported into the cell array A
Nyears=5; %number of years of data to be generated
yearly_J=1000; % mm/year of precipitation
Q_ET_partition=0.5; %partitioning [-] between Q and ET fluxes


%--------------------------------------------------------------------------
% generate all hydrologic fluxes
%--------------------------------------------------------------------------
date=datenum('01-Jan-2050'):1/24:datenum('01-Jan-2050')+round(Nyears*365.25); %virtual dates
N=length(date);
J=yearly_J*Nyears/N*ones(N,1); %hourly precipitation in mm/h
Q=J*Q_ET_partition; %hourly discharge in mm/h
ET=J-Q; %hourly ET in mm/h

% generate a wetness index wi, which is useless at steady state but is needed for compatibility
wi=0.5*ones(N,1);

%--------------------------------------------------------------------------
% GENERATE Cin and Cout
%--------------------------------------------------------------------------
% parameters for sinusoidal concentration input
per=1*365.25; %period [d]
ampl=25; %amplitude [-]
shif=0; %phase [d]
offs=0; %signal mean [arbitrary units]

% generate the timeseries
Cin=offs+ampl*sin(2*pi*(date-date(1))'/per+2*pi*shif/per); %sinusoidal input concentration
Cout=-999.00*ones(size(Cin)); %avoid measured output

% plot Cin if requested
plot_Cin=0;
if plot_Cin==1
    plot(date,Cin)
    datetick
end



%--------------------------------------------------------------------------
% export to textfile
%--------------------------------------------------------------------------
filename='testdata_steadystate.dat';
fid=fopen(['../',filename],'w');
fprintf(fid,'%25s %8s %8s %9s %8s %8s %12s\n',... %headers
        'date [yyyy-mm-dd HH:MM]','J [mm/h]','Q [mm/h]','ET [mm/h]',...
        'Cin [-]','wi [-]','measC_Q [-]');
for i=1:N
    fprintf(fid,'%25s %8.3f %8.3f %9.3f %8.3f %8.2f %12.2f\n',...
    datestr(date(i),'yyyy-mm-dd HH:MM'),J(i),Q(i),ET(i),...
    Cin(i),wi(i),Cout(i));
end
fclose(fid);




