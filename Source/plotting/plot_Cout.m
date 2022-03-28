  % figure
    figure(101)
    hold on
    
    % plot the measured timeseries
    tmp=get(gcf,'Children'); tmp=get(tmp,'Children');
    if isempty(tmp) %only add the plot if not done before
        stairs(data.dates(data.C_J~=0),data.C_J(data.C_J~=0),'-','MarkerSize',3,...
            'DisplayName','input','Color',[.8 .8 .8])
        pm=plot(data.dates(data.indexC_Q),data.measC_Q,'-og','DisplayName','measured',...
            'MarkerSize',3,'MarkerEdgeColor',[.5 1 .5],'MarkerFaceColor','g');
    end
    
    % plot the modeled timeseries
    pmod=plot(data.dates,C_Q,'-','DisplayName','modeled (continuous)');
    col=get(pmod,'Color');
    plot(data.dates(data.indexC_Q),C_Q(data.indexC_Q),'o','MarkerEdgeColor',col,...
        'DisplayName','modeled (during measurements)',...
       'MarkerSize',3)
    
    % complete the plot
    datetick('x','mmm-yy','keepticks')
    box on
    title('\bf Simulation timeseries','FontSize',12)
    ylabel('C')
    legend('show')
    xlim([t_1,t_2]); %x-axis limits
        
    
%     % uncomment this block to display the residual timeseries
%     % some settings
%     res=C_Q(data.indexC_Q)-data.measC_Q; %residual
%     absres=abs(res(~isnan(res))); %absolute residual
%     meanres=mean(absres); %mean absolute residual
%     Yresmax=max(absres)+0.05*abs(meanres); %max YLim for the error axes
%     Yresmin=-max(absres)-0.05*abs(meanres); %min YLim for the error axes
% 
%     figure(102)
%     hold all    
%     l1=line([0,data.dates(end)-data.dates(1)],[meanres,meanres],...
%         'Color',[.8 .8 .8],'DisplayName','+/- mean residual');
%     l2=line([0,data.dates(end)-data.dates(1)],[-meanres,-meanres],...
%         'Color',[.8 .8 .8],'DisplayName','- mean abs residual');
%     line([0,data.dates(end)-data.dates(1)],[0,0],'Color',[0 0 0])
%     s1=stairs(data.dates(data.indexC_Q)-data.dates(1)-data.ini_shift*data.dt/24,res,...
%         'Color',[0 0 0],'DisplayName','residual');
%         
%     % complete the plot
%     axis([0 data.dates(end)-data.dates(1)-data.ini_shift*data.dt/24 Yresmin Yresmax]); box on
%     title('\bf residual timeseries','FontSize',12)
%     ylabel('residual')
%     xlabel('time [d]')
%     legend([l1,s1])