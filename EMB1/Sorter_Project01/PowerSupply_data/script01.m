clc; clear;
% read csv
voltage_5v = zeros(100002,4);
voltage_6v = zeros(100002,3);
voltage_12v = zeros(100002,3);

data = csvread('C15V_5R_A3800000.csv');
voltage_5v(:,1) = data(:,2);
data = csvread('C15V_7R5_A2800000.csv');
voltage_5v(:,2) = data(:,2);
data = csvread('C15V_15R_A1500000.csv');
voltage_5v(:,3) = data(:,2);
data = csvread('C15V_33R_A0800000.csv');
voltage_5v(:,4) = data(:,2);
data = csvread('C16V_4R_1A5500000.csv');
voltage_6v(:,1) = data(:,2);
data = csvread('C16V_7R5_A8300000.csv');
voltage_6v(:,2) = data(:,2);
data = csvread('C16V_15R_A4200000.csv');
voltage_6v(:,3) = data(:,2);
data = csvread('C112V_11R_1A1100000.csv');
voltage_12v(:,1) = data(:,2);
data = csvread('C112V_16R5_A7500000.csv');
voltage_12v(:,2) = data(:,2);
data = csvread('C112V_33R_A3800000.csv');
voltage_12v(:,3) = data(:,2);



min_5v = min(voltage_5v);
max_5v = max(voltage_5v);
avg_5v = mean(voltage_5v);

min_6v = min(voltage_6v);
max_6v = max(voltage_6v);
avg_6v = mean(voltage_6v);

min_12v = min(voltage_12v);
max_12v = max(voltage_12v);
avg_12v = mean(voltage_12v);

%%

% input
i_5v = [0.38 0.28 0.15 0.08];
i_6v = [1.55 0.83 0.42];
i_12v = [1.11 0.75 0.38];

% resistances used
r_5v = [5 7.5 15 33];
r_6v = [4 7.5 15];
r_12v = [11 16.5 33];

% output
io_5v = avg_5v ./ r_5v;
io_6v = avg_6v ./ r_6v;
io_12v = avg_12v ./ r_12v;



%supply_voltage = 15;
%power_input = supply_current * supply_voltage ;

%power_output_min = v_min^2 / load_resistor;
%power_output_max = v_max^2 / load_resistor;
%power_output_avg = v_avg^2 / load_resistor;

%efficiency_min = power_output_min / power_input
%efficiency_avg = power_output_avg / power_input
%efficiency_max = power_output_max / power_input

figure(1);
hFig = figure(1);
set(hFig, 'Position', [0 0 500 320])
plot(io_5v,avg_5v, io_6v, avg_6v, io_12v,avg_12v)
xlabel('Output Current (A)')
ylabel('Output Voltage (V)')
title('Power Supplies')
legend('5V','6V','12V')
