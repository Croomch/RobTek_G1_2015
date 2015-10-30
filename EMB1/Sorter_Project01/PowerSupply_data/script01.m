% read csv
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


5v_min = min(voltage_5v);
5v_max = max(voltage_5v);
5v_avg = mean(voltage_5v);

6v_min = min(voltage_6v);
6v_max = max(voltage_6v);
6v_avg = mean(voltage_6v);

12v_min = min(voltage_12v);
12v_max = max(voltage_12v);
12v_avg = mean(voltage_12v);

i_5v = [0.38 0.28 0.15 0.08];
i_6v = [1.55 0.83 0.42];
i_12v = [1.11 0.75 0.38];

r_5v = [5 7.5 15 33];
r_6v = [4 7.5 15];
r_12v = [11 16.5 33];




supply_voltage = 15;
supply_current = 0.08;
power_input = supply_current * supply_voltage ;

load_resistor = 33;
%power_output_min = v_min^2 / load_resistor;
%power_output_max = v_max^2 / load_resistor;
%power_output_avg = v_avg^2 / load_resistor;

%efficiency_min = power_output_min / power_input
%efficiency_avg = power_output_avg / power_input
%efficiency_max = power_output_max / power_input

%v_min;
%v_avg;
%v_max;

