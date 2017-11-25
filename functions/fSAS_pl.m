function Om = fSAS_pl(Ps,par,~)
% function to compute a pl (power-law) fSAS function: Om = Ps^k
% Om = fSAS_pl(Ps,par=[k])         %power law with fixed exponent k

% Synopsis
% Om = the cumulative Omega function, evaluated over each element of Ps
% Ps = cumulative storage age distribution (S_T/S)
% par  = vector with parameter k. 
%--------------------------------------------------------------------------

% do some error check
if length(par)~=1 %error in parameter input
    error('wrong number of input parameters')
end
if any(par)<0
    error('parameter of the power-law function must be positive')
end

% assign the variables
k=par(1);

% compute omega
Om=Ps.^k;    

end