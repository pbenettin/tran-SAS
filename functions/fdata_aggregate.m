function [data]=fdata_aggregate(A,dt_aggr)
% this function aggregates data from cell array A 

% A includes the following data at hourly timestep:
% A{1}=measurements dates
% A{2}=precipitation J
% A{3}=discharge Q
% A{4}=evapotranspiration ET
% A{5}=precipitation concentration Cin
% A{6}=index of catchment wetness wi
% A{7}=measured discharge concentration measC_Q


% check that dt_aggr is integer
if dt_aggr-floor(dt_aggr)~=0
    error('dt_aggr must be integer')
end


% aggregate the hourly timeseries to dt_aggr timestep, and insert into the structure 'data'
data.dt=dt_aggr;
data.J=aggreg(A{2},dt_aggr);
data.Q=aggreg(A{3},dt_aggr);
data.ET=aggreg(A{4},dt_aggr);
data.wi=aggreg(A{6},dt_aggr);

% create a time-axis which points to the END of the timestep, as
% computations refer to the end of a timestep
date0=datenum(A{1}(1,:),'yyyy-mm-dd HH:MM');
N=length(data.J);
data.dates=(date0:data.dt/24:date0+data.dt/24*(N-1))';

% compute aggregated C_J by conserving input mass
data.C_J=aggreg(A{5}.*A{2},dt_aggr)./data.J; data.C_J(isnan(data.C_J))=0;

% extract available C_Q and set an index to find the corresponding aggregated dates
% this is done to allow comparisons in the aggregated timestep but note
% that it may compare values with a temporal distance up to dt_aggr
pos=find(A{7}~=-999); %positions where measC_Q is different from -999
data.measC_Q=A{7}(pos);  
data.indexC_Q=zeros(size(data.measC_Q));
for i=1:length(data.indexC_Q)
    [~,data.indexC_Q(i)]=min(abs(datenum(A{1}(pos(i),:),'yyyy-mm-dd HH:MM')-data.dates));
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