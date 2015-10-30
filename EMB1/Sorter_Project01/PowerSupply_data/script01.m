% read csv
data = csvread('C15V_33R_A0800000.csv');

voltage = data(:,2);

v_min = min(voltage);
v_max = max(voltage);
v_avg = mean(voltage);

supply_voltage = 15;
supply_current = 0.08;
power_input = supply_current * supply_voltage ;

load_resistor = 33;
power_output_min = v_min^2 / load_resistor;
power_output_max = v_max^2 / load_resistor;
power_output_avg = v_avg^2 / load_resistor;

efficiency_min = power_output_min / power_input
efficiency_avg = power_output_avg / power_input
efficiency_max = power_output_max / power_input

v_min;
v_avg;
v_max;

