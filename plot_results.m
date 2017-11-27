% script to plot the results of a model single-run. This script is 
% standalone but it can be automatically called at the end of the model
% starter if any plot_flag is set to 1

disp('plotting results...')

%--------------------------------------------------------------------------
% load the data
%--------------------------------------------------------------------------
% reload the results if not already done in the model starter
if exist('C_Q','var')==0
    % edit here if you want to modify the selected output file or the plot flags 
    load 'results\all_output' %loading the default output file 'all_output'
    flag_plot.Cout=1;         %show plot with residuals
    flag_plot.TTDs=1;         %show plot with the selection of TTDs
end


%--------------------------------------------------------------------------
% FIGURE: SHOW OUTPUT C_Q
%--------------------------------------------------------------------------
if flag_plot.Cout==1
    
    % show the spinup period in the plot? (1=yes)
    show_spinup=0;
    
    % figure
    figure(101)
    
    % plot the measured and modeled timeseries
    hold on
    stairs(data.dates(data.C_J>0),data.C_J(data.C_J>0),'-','MarkerSize',3,...
        'DisplayName','input','Color',[.8 .8 .8])
    plot(data.dates(data.indexC_Q),data.measC_Q,'og','DisplayName','measured',...
        'MarkerSize',3,'MarkerEdgeColor',[.5 1 .5],'MarkerFaceColor','g')
    plot(data.dates,C_Q,'-','DisplayName','modeled (continuous)')
    plot(data.dates(data.indexC_Q),C_Q(data.indexC_Q),'o','DisplayName',...
        'modeled (during measurements)',...
       'MarkerSize',3,'MarkerEdgeColor','k')
    
    % complete the plot
    datetick('x','mmm-yy','keepticks')
    if show_spinup==0
        axis([data.dates(1)+data.ini_shift*data.dt/24, data.dates(end), -Inf +Inf]);
    else
        axis([data.dates(1), data.dates(end), -Inf +Inf]); 
    end
    box on
    title('\bf Simulation timeseries','FontSize',12)
    ylabel('C')
    legend('show')
        
    
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

end
  


%--------------------------------------------------------------------------
% FIGURE: SHOW THE SELECTED TTDs
%--------------------------------------------------------------------------
if flag_plot.TTDs==1 && ~isempty(data.index_datesel)==1

    % check the actual length of the age vectors
    lastel=zeros(1,size(age_matr,2));
    for i=1:size(age_matr,2)
        lastel(i)=find(age_matr(:,i)>0,1,'last');
    end
    
    
    figure(103)
    
    % plot with the pdf's
    subplot(1,2,1)
    hold all
    legend off
    for i=1:length(lastel)
        plot(data.dt/24*(1:lastel(i)-1),age_matr(1:lastel(i)-1,i),...
            'DisplayName',datestr(data.dates(data.index_datesel(i)),'dd-mmm-yyyy'))
    end
    axis([0 1.1*data.dt/24*max(lastel) 0 +Inf]); axis square
    set(gca,'TickDir','out')
    xlabel('time [d]')
    ylabel('frequency [1/d]')
    title('\bf selected streamflow age pdf','FontSize',12)
    legend('show')
    subplot(1,2,2)

    % plot with the CDF's
    subplot(1,2,2)
    hold all
    for i=1:length(lastel)
        plot(data.dt/24*(1:lastel(i)-1),cumsum(age_matr(1:lastel(i)-1,i)),...
            'DisplayName',datestr(data.dates(data.index_datesel(i)),'dd-mmm-yyyy'))
    end
    axis([0 1.1*data.dt/24*max(lastel) 0 1]); axis square
    set(gca,'TickDir','out')
    xlabel('time [d]')
    ylabel('cumulative frequency [-]')
    title('\bf selected streamflow age CDF','FontSize',12)
end


%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%  END OF FILE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%