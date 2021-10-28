clear all; clear vars; clc;

% statistical analysis of poerty rate on concentration of microplastics 
data6 = readtable('pov_conc.xlsx');
data6arr = table2array(data6);

poverty_rate  = data6arr(:,2);
conc = data6arr(:,3);

lmdl6 = fitlm(poverty_rate, conc);

data5 = readtable('percap.xlsx');
data5arr = table2array(data5(:, [1,2,4,5]));

percapitaabv = data5arr(:,1);
percapitablw = rmmissing(data5arr(:,3));

concabv = data5arr(:,2);
concblw = rmmissing(data5arr(:,4));

ldml5b = fitlm(percapitablw, concblw);
ldml5a = fitlm(percapitaabv, concabv);


