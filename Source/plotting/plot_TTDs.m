% check the actual length of the age vectors
lastel=zeros(1,size(age_matr,2));
for i=1:size(age_matr,2)
    lastel(i)=find(age_matr(:,i)>0,1,'last');
end

figure

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