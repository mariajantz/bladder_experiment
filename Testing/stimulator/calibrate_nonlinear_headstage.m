%find out how far off a headstage is

clear all; 
%load('R:\data_raw\test\nano_multiChannelTesting\NanoStim Testing\NanoStim Front Ends\R02014-0016\3-16-2018\Analysis.mat')
%load('R:\data_raw\test\nano_multiChannelTesting\NanoStim Testing\NanoStim Front Ends\R02014-0017\3-19-2018\Analysis.mat')
%load('R:\data_raw\test\nano_multiChannelTesting\NanoStim Testing\NanoStim Front Ends\R02014-0018\3-1-2016\Analysis.mat')
%load('R:\data_raw\test\nano_multiChannelTesting\NanoStim Testing\NanoStim Front Ends\R02014-0019\3-21-2018\Analysis.mat')
load('R:\data_raw\test\nano_multiChannelTesting\NanoStim Testing\NanoStim Front Ends\R02014-0028\6-27-2018\Analysis.mat')


i = 1; 
for chan = 1:32
for res = 1:5
    for step = 1:127
        %amps in order: resolution, commanded, calculated anode, calculated cathode
        amps{chan}(i, :) = LUT(step + 127*(res-1), 1:4, chan); 
        i = i+1;         
    end
end
i = 1; 
end

key = {'resolution', 'commanded', 'calculated anode', 'calculated cathode'}; 


for i=1:length(amps)
    %calculate how far off anode, then cathode are
    anode_err = abs(amps{i}(:, 2)-amps{i}(:, 3))./amps{i}(:, 2); 
    cathode_err = abs(amps{i}(:, 2)-abs(amps{i}(:, 4)))./amps{i}(:, 2); 
    chan_err{i} = [anode_err cathode_err]; 
    
    %count instances greater than 5 and 10%, and get mean error
    checkrange = 50:635; 
    fiveoff = length(find(abs(chan_err{i}(checkrange, :))>.05)); 
    tenoff = length(find(abs(chan_err{i}(checkrange, :))>.1)); 
    fprintf('Chan %d has %d stimulation amplitudes with >5%% error and %d with >10%% error\n', i, fiveoff, tenoff); 
    
end
