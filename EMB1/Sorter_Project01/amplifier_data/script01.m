% read csv
data01 = csvread('C1small00001.csv');
data02 = csvread('C2small00001.csv');

figure(1);
hFig = figure(1);
set(hFig, 'Position', [0 0 500 320])
plot(data01(:,1), data01(:,2), data02(:,1), data02(:,2))
xlim([0.004148 0.00614802])
xlabel('Time (s)')
ylabel('Amplitude (V)')
title('Photodiode')
legend('Photodiode','Red LED','Location','southeast')