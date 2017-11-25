function [eff, eff_info] = Eff_SAS(obs,mod)

% function to compute some model efficiencies. Default include mean
% absolute errore and Nash-Sutcliffe Efficiency.

% obs = observation (can include NaN, that are here removed)
% mod = modeled value during observation day (must be same length)
% eff = list of efficiency performances
% eff_info = info on the eff metric (e.g. the name!)

% settings
display_eff=1; % flag to print efficiencies: 1=yes, 0=no


% just check obs and mod have the same length
if length(obs)~=length(mod)
    warning(idwarn,'modeled and observed data have different lengths')
end

% preallocate vectors
nonan=isnan(obs)==0; %identify non-NaN measured values
obs=obs(nonan);      %remove possible NaNs from measurements
mod=mod(nonan);      %remove model values corresponding to meas NaNs

% some useful quantities
measvar=var(obs);           % measurement variance
err=obs-mod;                % residual      

% MEAN ERROR
merr=mean(abs(err));

% NS efficiency
NS=1-mean(err.^2)/measvar;

% can add as many as you want!

% insert efficiencies into function output
eff=[merr, NS];
eff_info=[{'mean residual'},{'NS'}];

% also display
if display_eff==1
    disp(' ')
    for i=1:length(eff)
        display([eff_info{i},' = ',num2str(eff(i),'%.2f')])
    end
    disp(' ')
end

end



%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%  END OF FILE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%