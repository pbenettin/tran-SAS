% script to prepare some test hourly data to use in the SAS model

% the code takes synthetic measurements from file 
% 'virtual_measurements.dat', and computes a few more variables. All 
% variables are exported to file 'hourlydata_test.dat'

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
% MEASURED DATA IMPORT from TEXTFILE
%--------------------------------------------------------------------------

% data are imported into the cell array A
filename='virtual_measurements.dat';
fid=fopen(filename);
A=textscan(fid,'%16c %f %f %f %f %f','HeaderLines',1); %dates,J,Q,ET,Cin,Cout
fclose(fid);


%--------------------------------------------------------------------------
% COMPUTE V and wi
%--------------------------------------------------------------------------

% hydrologic balance to compute normalized storage variations V
V=zeros(size(A{2}));
dt=1; %hourly time step
V(1)=0; %arbitrary initial condition
for i=1:size(V,1)-1
    V(i+1)=V(i)+(A{2}(i)-A{3}(i)-A{4}(i))*dt;
end
V=V-mean(V);
    
% create an index wi in [0,1] representing some catchment wetness state
% here wi is proportional to the water storage V
wi=(V-min(V))./(max(V)-min(V));



%--------------------------------------------------------------------------
% modify Cin and Cout (if needed)
%--------------------------------------------------------------------------
C_choice=1;
% C_choice=1 takes virtual example measurements
% C_choice=2 is to make hypothetical tests, hence no measured output is considered

if C_choice==1
    Cin=A{5}; % virtual Cin from file
    Cout=A{6}; % virtual Cout from file
elseif C_choice==2 
    Cin=50*ones(length(A{2}),1); %preallocate a constant input
    Cin(round(0.25*length(A{2}))-1:end)=40; %induce an input step reduction by 20%
    Cout=-999.00*ones(size(Cin)); %avoid measured output
end



%--------------------------------------------------------------------------
% export to textfile
%--------------------------------------------------------------------------
filename='testdata.dat';
fid=fopen(['../',filename],'w');
fprintf(fid,'%25s %8s %8s %9s %8s %8s %12s\n',... %headers
        'date [yyyy-mm-dd HH:MM]','J [mm/h]','Q [mm/h]','ET [mm/h]',...
        'Cin [-]','wi [-]','measC_Q [-]');
for i=1:length(V)
    fprintf(fid,'%25s %8.2f %8.2f %9.2f %8.2f %8.2f %12.2f\n',...
    A{1}(i,:),A{2}(i),A{3}(i),A{4}(i),...
    Cin(i),wi(i),Cout(i));
end
fclose(fid);




