function Om = fSAS_step(Ps,par,~)
% function to compute a step fSAS function 
% note this is a "left" step, so the function is uniform up to a point Ps=u
% Om = Ps/u if Ps<u, Om = 1 if Ps>=u
% Om = fSAS_pl(Ps,par=[u])    %u defines the interval where Om is linear

% Synopsis
% Om = the cumulative Omega function, evaluated over each element of Ps
% Ps = cumulative storage age distribution (S_T/S)
% par  = vector with parameter k. 
%--------------------------------------------------------------------------

% do some error check
if length(par)~=1 %error in parameter input
    error('wrong number of input parameters')
end
if any(par)<=0 && any(par)>1
    error('parameter of the step function must be 0 < par <=1')
end

% assign the variables
u=par(1);

% compute omega
Om=Ps./u;
Om(Ps>=u)=1;

end