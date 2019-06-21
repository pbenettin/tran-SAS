function Om = fSAS_normtr(Ps,par,~)
% function to compute a (truncated) normal fSAS function
% Om = fSAS_pl(Ps,par=[m,s],)  

% Synopsis
% Om = the cumulative Omega function, evaluated over each element of Ps
% Ps = cumulative storage age distribution (S_T/S)
% par  = vector with parameters. The first one is the mean and the second
% one is the standard deviation
% (wi = value between 0 and 1 that represents the system state.)

%--------------------------------------------------------------------------

% assign the variables
m=par(1);
s=par(2);

% do some error check
if length(par)~=2 %error in parameter input
    error('wrong number of input parameters')
end
if s<0
    error('parameter s must be positive')
end

% compute some constants to get a more compact final formula
a=0; b=1;
phi_a=erf((a-m)/(s*sqrt(2)));
phi_b=erf((b-m)/(s*sqrt(2)));
Z=phi_b-phi_a;


% compute omega
Om=(erf((Ps-m)/(s*sqrt(2)))-phi_a)/Z; 

end