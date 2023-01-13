% Read UroMoca datalog txt file to extract pressure values and plot
clc; clear;

%==========================================================================
%EDIT THESE VARIABLES
Str = fileread('datalog-210729-131730.txt'); 
% Str = fileread('datalog-201210-135708.txt');
%==========================================================================

key1 = 'Pressure: ';
key2 = 'Timestamp: ';
key3 = 'Battery: ';
pindex = strfind(Str, key1);
tindex = strfind(Str, key2);
bindex = strfind(Str, key3);
pressures = zeros(size(pindex));
times = cell(1,length(tindex));
bat = zeros(size(bindex));

for i = 1:length(pindex)
    pressures(i) = sscanf(Str(pindex(i) + length(key1):end), '%f');
    times{i} = sscanf(Str(tindex(i) + length(key2):end), '%s.');
    bat(i) = sscanf(Str(bindex(i) + length(key3):end), '%f');
end

t = datetime(times, 'InputFormat', 'HH:mm:ss.SSS');

% % Remove outliers 
% dp = diff(pressures);
% out = (find(dp>400)+1);
% pressures(out) = [];
% t(out) = [];
% bat(out) = [];
% dp = diff(pressures);
% out = (find(abs(dp)>400)+1);
% pressures(out) = [];
% t(out) = [];
% bat(out) = [];

t2 = seconds(t-t(1));
figure
yyaxis left
plot(t2, (pressures), '.') 
title('UroMoca Data')
xlabel('Time (s)')
ylabel('Pressure (mmHg)')
% ylim([5 40])
% xlim([0 300])

yyaxis right
plot(t2, bat, '.r')
ylabel('Battery (V)')
ylim([2.0 2.70])