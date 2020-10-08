function test_shorted_boards
%run loop to test multiple configurations
fileroot = 'R:\data_raw\test\nano_multiChannelTesting\NanoStim Testing\Shorted_boards\'; 

test_elecs = {0};% {1, 5, 31, [1 3], [8 10], [15 28], [4 2 9], [25 24 26]}; 
test_amps = [20 450 1250 2400 2800 3000]; 

% test_elecs = {1};
% test_amps = [2400 2800 3000];
for e = 1:length(test_elecs)
    for a = 1:length(test_amps)
        elec = test_elecs{e}; amp = test_amps(a); 
        data = run_daq_collect(elec, amp, fileroot); 
        %save data
        files = dir(sprintf('%sdatafile*', fileroot)); 
        NEVfile = files(end).name(9:12); 
        save(sprintf('%smultisurvey%s', fileroot, NEVfile), 'NEVfile', 'data', 'elec', 'amp', '-v7.3');
    end
end

end

function ret = run_daq_collect(elecs, amps, datapath)
%set up DAQ
session = DAQ.initialize(1:32);
session.Rate = 99999;
%session.IsContinuous = 1;
session.DurationInSeconds = 100;
session.NotifyWhenDataAvailableExceeds = ceil(session.Rate);

global daqData 
daqData = []; 


C = experiment_constants_example;
%data = session.startForeground();

data = addlistener(session,'DataAvailable',@acquireData);
session.startBackground(); 

tic;
pause(1)

%single_elec_stim(C, elecs, amps, 31)
C.MAX_AMP = amps;
elec_survey_stim(C, 0.2, datapath)

pause(1)

toc

ret = daqData*1000; %return values in uA

end


function acquireData(src,event)
global daqData 
daqData = [daqData; event.Data]; % Set the global daq data
end