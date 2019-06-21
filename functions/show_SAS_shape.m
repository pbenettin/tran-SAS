% script to quickly display the SAS functions over the normalized rank storage
% (also known as 'fractional' fSAS)

% some examples are provided below (examples 1-3)
example=1; %can choose between 1,2 and 3


% EXAMPLE 1 : SASQ with fixed power-function shape (one parameter)
if example==1
    SASname='fSAS_pl'; 
    SASpar=0.5;
end

% EXAMPLE 2: SASQ with time-variant power-function shape (two parameters)
if example==2
    SASname='fSAS_pltv'; 
    SASpar=[0.4,0.8];
end

% EXAMPLE 3 : SASQ with Beta shape (two parameters)
if example==3
    SASname='fSAS_beta'; 
    SASpar=[0.6,1];
end


% compute Omegas
Ps=0:0.01:1; %create the [0,1] fSAS domain
if strcmp(SASname,'fSAS_pltv')==0
    Om=feval(SASname,Ps',SASpar); %[-]
else
    Om=zeros(length(Ps),2);
    Om(:,1)=feval(SASname,Ps',SASpar,0); %lowest index 
    Om(:,2)=feval(SASname,Ps',SASpar,1); %highest index
end
om=diff(Om)./repmat(diff(Ps'),1,size(Om,2)); %get an approximation of the pdf


% plot
%figure
subplot(1,2,1); hold all
plot(Ps,Om,'-')
axis square
xlabel('normalized rank storage [-]')
ylabel('CDF [-]')
title('\Omega function','FontSize',12,'FontWeight','bold')

subplot(1,2,2); hold all
plot(Ps(2:end),om,'-')
axis square
xlabel('normalized rank storage [-]')
ylabel('pdf [-]')
title('\omega function','FontSize',12,'FontWeight','bold')



