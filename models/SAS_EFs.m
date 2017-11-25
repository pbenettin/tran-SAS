% implementation of the age Master Equation using a modified Euler Forward 
% scheme (EF*) that accounts for the presence of 'event' water in streamflow
% and evapotranspiration. 
% Details on the model variables can be found at the bottom of the file

function SAS_EFs(Pars,data)


%--------------------------------------------------------------------------
% prepare the run
%--------------------------------------------------------------------------

% assign CALIBRATION parameters
parQ=Pars(1:data.SASQl); %SASQ parameters
parET=Pars(data.SASQl+1:data.SASQl+data.SASETl); %SASET parameters
S0=Pars(data.SASQl+data.SASETl+1); %initial storage parameter

% set a few constants
NN=length(data.J); %length of the timeseries
ndistr=length(data.index_datesel); %number of age distributions that will be saved

% preallocate variables
S_T=zeros(NN,1); %rank storage (function of age T)
C_ST=zeros(NN,1); %rank storage concentration (function of age T)
C_Q=zeros(NN,1); %stream concentration (function of time t)
% C_ET=zeros(NN,1); %evapotranspiration concentration (function of time t)
% C_S=zeros(NN,1); %mean storage concentration (function of time t)
age_matr=zeros(NN,ndistr); %matrix to store the desired age distributions
% med=zeros(NN,1); %median discharge age
% Fyw=zeros(NN,1); %young water fraction

% initial conditions
C_Q(1)=data.C_S0;  %initial streamflow concentration equal to the initial storage
% C_ET(1)=data.C_S0; %initial streamflow concentration equal to the initial storage
% C_S(1)=data.C_S0;  %initial streamflow concentration equal to the initial storage
length_s=1;        %rank storage vector length 
S_T(length_s)=S0;  %initial rank storage [mm]
C_ST(length_s)=data.C_S0; %mean concentration of the initial rank storage
Omega_Q=feval(data.SASQName,S_T(1:length_s)/S_T(length_s),parQ,data.wi(1)); %[-]
Omega_ET=feval(data.SASETName,S_T(1:length_s)/S_T(length_s),parET,data.wi(1)); %[-]

%--------------------------------------------------------------------------
% MODEL LOOPS
%--------------------------------------------------------------------------

% let's go
for j=1:NN-1   
    
    %------------------------------------------------------------------
    % SOLVE THE AGE BALANCE and evaluate the rank storage concentration
    %------------------------------------------------------------------
    % 0) define the domain for the SAS function evaluation (basically a shifted S_T with new water addition)
    age1=max(0,data.dt*(data.J(j)-data.Q(j)*Omega_Q(1)-data.ET(j)*Omega_ET(1))); %estimate of resident water with age 1
    dom=([0;S_T(1:length_s)]+age1)/(S_T(length_s)+age1); %rescaled domain for SAS evaluation

    % 1) evaluate the SAS functions Omega over the domain 'dom'
    Omega_Q=feval(data.SASQName,dom,parQ,data.wi(j)); %[-]
    Omega_ET=feval(data.SASETName,dom,parET,data.wi(j)); %[-]
    
    % 2) solve the master equation balance
    S_T(1:length_s+1)=max(0,[0;S_T(1:length_s)]... 
        +data.dt*data.J(j)... 
        -data.dt*(data.Q(j)*Omega_Q+data.ET(j)*Omega_ET));
    for i=2:length_s+1; S_T(i)=max(S_T(i),S_T(i-1)); end % ensure that S_T is not decreasing

    % 3) update solute concentration for each parcel 
    C_ST(2:length_s+1)=C_ST(1:length_s);   %conservative transport of the elements
    C_ST(1)=data.C_J(j);                   %concentration of the new input    
          
    % 4) check if the vectors need to grow or not 
    if j==1 || S_T(length_s)<data.f_thresh*S_T(length_s+1) %still need to grow 
        length_s=length_s+1;
    else % oldest element are merged into an old pool   
        C_ST(length_s)=max(0,(C_ST(length_s+1)*(S_T(length_s+1)-S_T(length_s))...
            +C_ST(length_s)*(S_T(length_s)-S_T(length_s-1)))...
            /(S_T(length_s+1)-S_T(length_s-1))); %update mean concentration of the pool                                           
        S_T(length_s)=S_T(length_s+1); %merge the oldest elements of S_T
        Omega_Q(length_s)=Omega_Q(length_s+1); Omega_Q(length_s+1)=[];  % merge the oldest values of the Omega functions
        Omega_ET(length_s)=Omega_ET(length_s+1); Omega_ET(length_s+1)=[];  % merge the oldest values of the Omega functions
    end

    
    %----------------------------------------
    % COMPUTE output: stream concentration
    %----------------------------------------
    % compute discharge age distribution (pQ) and concentration (C_Q)
    pQ=diff([0;Omega_Q]);  %[-] this is pQ(T)*dT and it is equivalent to omegaQ(S_T)*dS_T
    C_Q(j+1)=C_ST(1:length_s)'*pQ;   %streamflow modeled concentration

    
    %-------------------------
    % COMPUTE output: other
    %-------------------------
    % for the selected dates, store discharge age distributions in a matrix
    if any(data.index_datesel-1==j)==1
        age_matr(1:length_s,data.index_datesel-1==j)=pQ;
    end
    
%     % many distributions and age metrics can be defined, computed and saved
%     % here. Examples are provided below (need to uncomment the variables
%     % preallocation on top)
%     
%     % ex1-compute age distribution and concentration for ET and storage   
%     pET=diff([0;Omega_ET]);       %[-] this is pET(T)*dT and it is equivalent to omegaET(S)*dS (usually not needed)    
%     pS=diff([0;S_T(1:length_s)./S_T(length_s)]);   %[-] this is pS(T)*dT equivalent to dS/V(t)
%     C_ET(j+1)=C_ST(1:length_s)'*pET; %ET modeled concentration
%     C_S(j+1)=C_ST(1:length_s)'*pS;   %storage modeled concentration
%         
%     % ex2-compute some percentile age
%     pp=0.5; %percentile [-], (note pp=0.5 is the median)
%     med(j+1)=find(Omega_Q>=pp,1,'first');
%     
%     % ex3-compute some young water fractions    
%     ywt=7; %young water threshold [days]
%     Fyw(j+1)=Omega_Q(min(length(pQ),round(ywt*24/data.dt)));

    
end



%--------------------------------------------------------------------------
% save output
%--------------------------------------------------------------------------

% option to save some output
if isfield(data,'save_output')
    if data.save_output==1
        outfilename='results\all_output';          %choose the output filename
        varlist={... %list here the variables that you want to save
            'data',...
            'Pars',...
            'C_Q',...
            'age_matr',...
            };  
        save(outfilename,varlist{:}) %save selected variables as Matlab file
    end
end



end



%--------------------------------------------------------------------------
% notation details:
% T: age
% t: time
% S: total system storage
% pS: storage age distribution
% pQ: discharge age distribution
% Ps: cumulative age distribution of the system storage
% S_T=S*P_S: rank storage
% Omega: cumulative StorAge Selection function

% all the 'diff' functions return the derivative (df/dx) multiplied by some increment:
% diff(T) represents dT
% diff(Ps) represents (dPs/dT)*dT=pS*dT
% diff(S_T) represents (dS_T/dT)*dT=S*pS*dT
% diff(Omega) represents omega(S_T)*dS_T or equally omega(Ps)*dPs or pQ(T)*dT

% so if one wants the 'classic' variables, some conversion is needed:
% Ps = S_T/S
% omega(S_T) = diff(Omega(S_T))/diff(S_T)
% omega(Ps) = diff(Omega(Ps))/diff(Ps)
% pS(T) = diff(Ps)/diff(T)
% pQ(T) = diff(OmegaQ)/diff(T)
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%  END OF FILE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%