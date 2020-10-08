
xippmex('close');
clear_timers; clear_sockets; clear classes; clear
monopolar = false;

%% Create DAQ Session
s = daq.createSession('ni');
daq_modules = daq.getDevices;
ch_list = 1:8; 

%% Add Analog Channels and Match Name to NanoStim Channel

%Find 9220 module locations using (NI 9220 (DSUB)
I = strcmp({daq_modules(:).Model},'NI 9220 (DSUB)');
modules = {daq_modules(I).ID};

daq_map{length(ch_list),4} = zeros(length(ch_list),4);

for n= 1:length(ch_list)
    
if n < 17
    addAnalogInputChannel(s,modules{1}, (n-1),'Voltage');
else
    addAnalogInputChannel(s,modules{2}, (n-17),'Voltage');
end

s.Channels(n).Name = ['Channel_' num2str(ch_list(n))];
daq_map{n,1} = s.Channels(n).Device.Model;
daq_map{n,2} = s.Channels(n).Device.ID;
daq_map{n,3} = s.Channels(n).ID;
daq_map{n,4} = s.Channels(n).Name;

end

%% Acquisition Parameters
record_time = 40;                        %Recording length in seconds

s.DurationInSeconds = record_time;
s.Rate = s.RateLimit(2);                %Set to max sample rate of 100kHz

disp('DAQ Unit is ready...Hit any key to continue')
pause


if monopolar
    stimch = setdiff([129:160], [132 134 137 138 140 142 146 148 150 154 156 158]);
    for i=stimch
        disp(i);
        for a = [1:8 10:5:30 40 50]
            stimDesign_presetAmps(i,'A',a,320,32,0.2,2,2, 'digTrigger_enable', true)
        end
    end
    
else
    %input array with cathode first, then anode
    stimch = {132 133};
    for i=1:size(stimch, 1)
        disp(stimch(i, :));
        for a = [1500]
            daqData = scratch_stimDesign_presetAmpsMultichan(s, stimch{i, 1}, stimch{i, 2}, 'A', a, ...
                320, 32, 0.2, 2, 2, 'digTrigger_enable', true);
            save(sprintf('multichan_test%d_amp%d', i, a), 'daqData'); 
        end
    end
end

stop(s);