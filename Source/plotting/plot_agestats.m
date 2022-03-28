% show some age quantile (e.g. the median)
figure

% plot 1: discharge
ax1=subplot(3,1,3,'TickDir','out','XLim',[t_1,t_2],'NextPlot','add');
datetick('x','mmm-yy','keepticks')
ylabel('Q [mm/h]')
p1=plot(data.dates,data.Q,'-','Color',[.6 .6 .6],'DisplayName','discharge','Parent',ax1);

% plot 2: streamflow age
p2 = zeros(1,size(med,2));
ax2=subplot(3,1,[1,2],'XLim',[t_1,t_2],'NextPlot','add',...
    'TickDir','out','Box','on');
title('age quantile timeseries')
datetick('x','mmm-yy','keepticks')
ylabel('days')
for ii = 1:length(pp)
    p2(ii) = plot(data.dates,med(:,ii)/(24/data.dt),'-','DisplayName',sprintf('q %.2f',pp(ii)),'Parent',ax2);
end
legend(p2)
linkaxes([ax1,ax2],'x')


% show the young water fraction (Fyw)
figure

% plot 1: discharge
ax1=subplot(3,1,3,'TickDir','out','XLim',[t_1,t_2],'NextPlot','add','YScale','linear');
datetick('x','mmm-yy','keepticks')
ylabel('Q [mm/h]')
p1=plot(data.dates,data.Q,'-','Color',[.6 .6 .6],'DisplayName','discharge','Parent',ax1);

% plot 2: young water fraction
col_Fyw = cool(size(Fyw(:,ii_sel),2));
p2 = zeros(1,size(Fyw(:,ii_sel),2));
ax2=subplot(3,1,[1,2],'XLim',[t_1,t_2],'NextPlot','add',...
    'TickDir','out','Box','on');
title('Young Water Fraction timeseries')
datetick('x','mmm-yy','keepticks')
ylabel('Fyw [-]')
for ii = (ii_sel)
    p2(ii) = plot(data.dates,Fyw(:,ii),'-','Color',col_Fyw(ii,:),'Parent',ax2,...
        'DisplayName',sprintf('ywt = %.0f d',ywt(ii)));
end
legend(p2)
linkaxes([ax1,ax2],'x')