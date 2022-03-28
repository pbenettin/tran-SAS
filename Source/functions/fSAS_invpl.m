function Om = fSAS_invpl(Ps,par,wi)
% function to compute an inverse power aSAS function: Om = (1-Ps)^a
% Om = fSAS_pl(Ps,par=[a],wi)         %power function with fixed exponent a
% Om = fSAS_pl(Ps,par=[amin,amax],wi)  %power function with variable exponent 
% between amin and amax, depending on the system state

% Synopsis
% Om = the cumulative Omega function, evaluated over each element of Ps
% Ps = cumulative storage age distribution (normalized S)
% par  = vector with parameters. If there is one element, then it's a
% constant exponent. If there are two elements, the first one is amin
% (minum value) and the second one is amax (max value)
% wi = value between 0 and 1 that represents the system state.

% Note that a high state (sstate = 1) corresponds to amin, while a low
% state (sstate = 0) corresponds to amax.

%--------------------------------------------------------------------------

% assign the variables
if length(par)==1 
    a=par;
else
    amin=par(1);
    amax=par(2);
    %sstate=other.wi;
    sstate=wi;
    a=amin+(1-sstate)*(amax-amin);   
end

% do some error check
if length(par)~=1 && length(par)~=2 %error in parameter input
    error('wrong number of input parameters')
end


% compute omega
Om=1-(1-Ps).^a;    

end