function [data]=fdata_aggregate(data,datasetName,dt_aggr)
% this function aggregates data from csv table datasetName

flag_show_aggregated = 0; %show the aggregated data?

% import the table into a Matlab table
A = readtable(datasetName);
% A includes at least the following variables at hourly timestep:
% date: measurements dates
% J: precipitation 
% Q: streamflow
% ET: evapotranspiration
% Cin: input tracer concentration (or isotopic composition)
% wi: some indicator of catchment wetness 
% measC_Q: measured tracer concentration (or isotopic composition) in Q


% check that dt_aggr is integer
if dt_aggr-floor(dt_aggr)~=0
    error('dt_aggr must be integer. Please modify the config_file accordingly.')
end


% aggregate the hourly timeseries to dt_aggr timestep, and insert into the structure 'data'
data.dt=dt_aggr;
data.J=aggreg(A.J,dt_aggr);
data.Q=aggreg(A.Q,dt_aggr);
data.ET=aggreg(A.ET,dt_aggr);
data.wi=aggreg(A.wi,dt_aggr);

% create a new time-axis at dt_aggr timesteps
date0 = datenum(A.date(1));
N = length(data.J);
data.dates = transpose(date0:data.dt/24:date0+data.dt/24*(N-1));

% compute aggregated C_J by conserving input mass
data.C_J = aggreg(A.Cin.*A.J,dt_aggr)./data.J; 
data.C_J(isnan(data.C_J)) = 0; %give 0 when there is no precipitation

% extract available C_Q and set an index to find the corresponding aggregated dates
% this is done to allow comparisons in the aggregated timestep but note
% that it may compare values with a temporal distance up to dt_aggr
pos = find(~isnan(A.measC_Q)); %indexes where measC_Q is available
data.measC_Q = A.measC_Q(pos);  
data.indexC_Q=zeros(size(data.measC_Q));
tmp1 = datenum(data.dates);
for i=1:length(data.indexC_Q)
    [~,data.indexC_Q(i)]=min(abs(datenum(A.date(pos(i)))-tmp1));
end


% make a plot with the original and aggregated data
if flag_show_aggregated == 1
    dates_aggreg = transpose(A.date(1):hours(data.dt):A.date(1)+hours(data.dt)*(N-1));
    s = zeros(5,1);
    figure
    s(1) = subplot(5,1,1,'NextPlot','add');
    stairs(A.date,A.J,'DisplayName','hourly')
    stairs(dates_aggreg,data.J,'DisplayName',sprintf('aggr %d h',dt_aggr))
    legend('show')
    ylabel('J mm/h')
    s(2) = subplot(5,1,2,'NextPlot','add');
    stairs(A.date,A.Q,'DisplayName','hourly')
    stairs(dates_aggreg,data.Q,'DisplayName',sprintf('aggr %d h',dt_aggr))
    ylabel('Q mm/h')
    s(3) = subplot(5,1,3,'NextPlot','add');
    stairs(A.date,A.ET,'DisplayName','hourly')
    stairs(dates_aggreg,data.ET,'DisplayName',sprintf('aggr %d h',dt_aggr))
    ylabel('ET mm/h')
    s(4) = subplot(5,1,4,'NextPlot','add');
    stairs(A.date,A.wi,'DisplayName','hourly')
    stairs(dates_aggreg,data.wi,'DisplayName',sprintf('aggr %d h',dt_aggr))
    ylabel('wi [-]')
    s(5)= subplot(5,1,5,'NextPlot','add');
    stairs(A.date,A.Cin,'DisplayName','hourly')
    stairs(dates_aggreg,data.C_J,'DisplayName',sprintf('aggr %d h',dt_aggr))
    ylabel('Cin [units]')
    linkaxes(s,'x')
end



end


function [dataggr] = aggreg(data,dt)
% aggregate data from hour to multi-hour time step

% description
% data: matrix that includes as columns all the datasets that need to be aggregated
% dt: (integer) new desired timestep
% dataggr: matrix with aggregated data

% preallocate the datasets
[N,n_sets] = size(data);
Naggr = length(1:dt:N);
dataggr = zeros(Naggr,n_sets);


% little checks
if dt-floor(dt)>0 
    error('dt must be an integer')
end

if n_sets>N
    warning(['number of datasets to be aggregated is larger ',...
        'than the dataset length. Rows and column in the input ',...
        'matrix may have been inverted.'])
end


% averaging the data from each column of the input data matrix
for j=1:n_sets        
    for i = 1:dt:N
       index = min(N,i+dt-1); %the min is to make sure we don't exceed N
       dataggr(1+(i-1)/dt,j) = mean(data(i:index),j);
    end
end
end