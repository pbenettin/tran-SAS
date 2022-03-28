function [data]=fgenerate_spinup(data,period_rep,n_rep)
% this short script is used to plug a spinup dataset at the beginning of 
% the computations. The scalar 'data.ini_shift' stores information on the 
% number of timesteps that are plugged at the beginning and it is used to
% reset simulation dates.

% identify the dataset to be repeated
index_rep=...
    floor((period_rep(1)-1)*(24/data.dt)+1):...
    floor(period_rep(2)*(24/data.dt)); %index of timesteps that will be repeated
data.ini_shift=length(index_rep)*n_rep; %total number of timesteps to add at the beginning

% plug the spinup at the beginning of the datasets
data.dates=[...
    (data.dates(1)-(data.ini_shift)*data.dt/24:...
    data.dt/24:...
    data.dates(1)-data.dt/24)';data.dates];  
data.J=[repmat(data.J(index_rep),n_rep,1);data.J];
data.ET=[repmat(data.ET(index_rep),n_rep,1);data.ET];
data.Q=[repmat(data.Q(index_rep),n_rep,1);data.Q];
data.C_J=[repmat(data.C_J(index_rep),n_rep,1);data.C_J];
data.wi=[repmat(data.wi(index_rep),n_rep,1);data.wi];

% rescale streamflow during the spinup to avoid long-term trends in the total water storage
tmp = sum(data.J(1:data.ini_shift)-data.ET(1:data.ini_shift)-data.Q(1:data.ini_shift))*data.dt;
tmp2 = tmp/(data.ini_shift*data.dt); %flow to remove at every time step
data.Q(1:data.ini_shift) = data.Q(1:data.ini_shift)+tmp2*ones(data.ini_shift,1);
if tmp>50
    fprintf('\nRescaled Q during spinup to avoid a storage drift of %.2f mm over %.0f days\n',tmp,floor(data.ini_shift*data.dt/24))
end

% shift the indexes for C_Q and age 
data.indexC_Q=data.indexC_Q+data.ini_shift; %update measurement dates index
data.index_datesel=data.index_datesel+data.ini_shift; %update index with dates for age computation

end