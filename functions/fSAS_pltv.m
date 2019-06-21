function Om = fSAS_pltv(Ps,par,wi)
% function to compute a pl (power) fSAS function: Om = Ps^k(wi)
% Om = fSAS_pl(Ps,par=[kmin,kmax],wi)  %power function with variable exponent 
% between kmin and kmax, depending on the system state wi

% Synopsis
% Om = the cumulative Omega function, evaluated over each element of Ps
% Ps = cumulative storage age distribution (S_T/S)
% par  = vector with parameters. The first one is kmin (minum value) and 
% the second one is kmax (max value)
% wi = value between 0 and 1 that represents the system state.

% Note that a high state (sstate = 1) corresponds to kmin, while a low
% state (sstate = 0) corresponds to kmax.

%--------------------------------------------------------------------------

% assign the variables
kmin=par(1);
kmax=par(2);
sstate=wi;
k=kmin+(1-sstate)*(kmax-kmin);   

% do some error check
if length(par)~=2 %error in parameter input
    error('wrong number of input parameters')
end
if any(par)<0
    error('parameters of the power-law function must be positive')
end


% compute omega
Om=Ps.^k;    

end