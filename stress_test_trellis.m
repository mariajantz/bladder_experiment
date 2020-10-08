datapath = 'D:\DataTanks\2019\stress_test';

stimChan = 129:130;
freq = 33;
pw_ms = .2;
amps = 100;
repeats = 200;

clock_cycle = 1/(30*1000); %30 kHz clock
period = ceil(1/(freq*clock_cycle)); %time between pulses, in 33.3 us units
pw_cyc = pw_ms/clock_cycle/1000;
stimTime = period*clock_cycle*repeats;

for i = length(stimChan):-1:1
    %set up first part of cmd
    temp = struct('elec', stimChan(i), 'period', period, 'repeats', repeats);
    % Create the first phase (cathodic) for stimulation - don't allow
    % fastsettle (fs)
    temp.seq(1) = struct('length', pw_cyc, 'ampl', amps, 'pol', 0, ...
        'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);
    % Create the inter-phase interval. Use previous default duration of 66 us
    % (2 clock cycles at 30 kHz). The amplitude is zero. The
    % stimulation amp is still used so that the stim markers sent by
    % the NIP will properly contain this phase.
    temp.seq(2) = struct('length', 2, 'ampl', 0, 'pol', 0, 'fs', 0, ...
        'enable', 0, 'delay', 0, 'ampSelect', 1);
    % Create the second, anodic phase.
    temp.seq(3) = struct('length', pw_cyc, 'ampl', amps, 'pol', 1, ...
        'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);
    
    cmd(i) = temp;
end

%track errors
errs = [];
%%
status = xippmex('tcp');
pause(1); 
xippmex('addoper', 148);
pause(.5);

for i = 1:1000
    try
        %connect to xippmex
%         status = xippmex('tcp');
        
        %set resolution
        xippmex('stim', 'enable', 0); 
        xippmex('stim','res', 1, 1);
        xippmex('stim', 'enable', 1); 
        
        %start recording
%         xippmex('addoper', 148);
        xippmex('trial', 'recording', [datapath '\datafile'], 0, 1, [], 148);
        
        %send stimulation pulse
        xippmex('stimseq', cmd);
        fprintf('Stimulating for %.1f s\n', stimTime)
        pause(stimTime + 0.2);
        
        %send digital out pulse
         xippmex('digout', 5, 2153);
         pause(0.2);
        
        %stop recording
        xippmex('trial', 'stopped');
        
        %close xippmex
%         xippmex('close');
    catch ME
        xippmex('close')
        errs(end+1) = i;
        rethrow(ME)
    end
    pause(0.5)
end

xippmex('close')
