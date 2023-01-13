function [] = single_amp_stim_multi_bipole(C, stimChan, cathAmp, freq, fpath)
% C = experiment constants struct for a given animal
% input channel (for multichannel input cathode first), amplitude and frequency chosen
% the way you should input stimChan is: [cathode_1, anode_1; cathode_2;
% anode_2..] and they cannot be duplicates 

% choose correct port numbers
if stimChan(1)<C.ACTIVE_CHAN(1)
    stimChan = C.ACTIVE_CHAN(1)+stimChan-1; 
end

% set up to trigger recording
status = xippmex;
if status == 0
    error('Xippmex is not connecting.')
end

% choose appropriate stimulation resolution and adjust amplitudes
% step 1: 1 uA steps, 2: 2 uA, 3: 5 uA, 4: 10 uA, 5: 20 uA
% ranges: 0-127 uA, 2-254 uA, 5-635, 10-1270, 20-1500 uA
xippmex('stim', 'enable',0)
if cathAmp<=127
    %set resolution of stimulation channels to 1 uA
    
    xippmex('stim','res',stimChan, 1);
elseif cathAmp<=254
    %set resolution of stimulation channels, and adjust the uA value of the
    %cathode amplitude to the unitless stimulation command value in terms
    %of stimulation resolution
    xippmex('stim','res',stimChan, 2);
    cathAmp = ceil(cathAmp/2);
elseif cathAmp<=635
    xippmex('stim','res',stimChan, 3);
    cathAmp = ceil(cathAmp/5);
elseif cathAmp<=1270
    xippmex('stim','res',stimChan, 4);
    cathAmp = ceil(cathAmp/10);
else
    if cathAmp>1500
        warning('Commanded stimulation amplitude is above 1.5 mA per electrode, may not reach that value')
    end
    xippmex('stim','res',stimChan, 5);
    cathAmp = ceil(cathAmp/20);
end
 xippmex('stim','enable',1)
% calculate amplitudes of anodic stimulation, as split across channels and
% correcting for any differences in length of time stimulating on
% cathode/anode

%multipolar stimulation
%define polarity (this makes it bipolar) - cathodic first 0, anodic first 1
polarity = repmat([C.STIM_POLARITY ~C.STIM_POLARITY], size(stimChan, 1), 1);

stimChan = reshape(stimChan.', 1, []); 
polarity = reshape(polarity.', 1, []);
amps = cathAmp*ones(size(stimChan)); 

%make array of train length, frequency, etc values - all identical
%trainLength = repmat(C.THRESH_REPS/freq*1000, 1, length(stimChan));
%freq = repmat(freq, 1, length(stimChan));
%delay_times = zeros(1, length(stimChan)); 
%note: anode and cathode duration apply to all electrodes - refer to stim phase,
%not the role of a specific electrode in multipolar stimulation
%pwDur = repmat(C.STIM_PW_MS, 1, length(stimChan)); 

% convert all parameters to a stimulation string
% TODO: test this - especially with bipolar, tripolar stim. Do doubled
% channel numbers work?
%stimString = stim_param_to_string(stimChan, trainLength, freq, pwDur, ...
%    amps, delay_times, polarity); 

clock_cycle = 1/(30*1000); %30 kHz clock
period = ceil(1/(freq*clock_cycle)); %time between pulses, in 33.3 us units
pw_cyc = C.STIM_PW_MS/clock_cycle/1000; 

%build stimseq command (go backwards to preallocate array)
for i = length(stimChan):-1:1
    %set up first part of cmd
    temp = struct('elec', stimChan(i), 'period', period, 'repeats', C.THRESH_REPS);
    % Create the first phase (cathodic) for stimulation - don't allow
    % fastsettle (fs)
    temp.seq(1) = struct('length', pw_cyc, 'ampl', amps(i), 'pol', polarity(i), ...
        'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);
    % Create the inter-phase interval. Use previous default duration of 66 us
    % (2 clock cycles at 30 kHz). The amplitude is zero. The
    % stimulation amp is still used so that the stim markers sent by
    % the NIP will properly contain this phase.
    temp.seq(2) = struct('length', 2, 'ampl', 0, 'pol', 0, 'fs', 0, ...
        'enable', 0, 'delay', 0, 'ampSelect', 1);
    % Create the second, anodic phase.
    temp.seq(3) = struct('length', pw_cyc, 'ampl', amps(i), 'pol', double(~polarity(i)), ...
        'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);
    
    cmd(i) = temp;
end

stimTime = period*clock_cycle*C.THRESH_REPS; 
%opers = xippmex('opers'); 

% trigger recording
%xippmex('trial', 'recording', [], ceil(stimTime+2*C.QUIET_REC)); %remote control

recTime = ceil(stimTime+2*C.QUIET_REC); 
a = tic; 
%new option without auto stop to avoid errors
xippmex('trial', 'recording', fpath, 0, 1); 

% xippmex('trial', opers, 'recording'); 
%xippmex('digout', C.DIG_TRIGGER_CHAN, 1); %digital triggering
%pause(0.5)

% quiet recording
fprintf('Quiet recording for %.1f s\n', C.QUIET_REC); 
pause(C.QUIET_REC); 
% stimulate on all channels
xippmex('stimseq', cmd);
fprintf('Stimulating for %.1f s\n', stimTime)
pause(stimTime); %pause to let stimulation finish

% quiet recording again
fprintf('Quiet recording for %.1f s\n', C.QUIET_REC); 
pause(C.QUIET_REC);

%added to get rid of auto stop
xippmex('trial', 'stopped');

b = toc(a)-0.5; %give time to let recording save 
if b<recTime
    pause(recTime-b)
end

xippstatus = xippmex('trial'); 
if ~strcmp(xippstatus.status, 'stopped')
    warning('Long pause time')
    xippmex('trial', 'stopped');
    pause(2); 
end

% xippmex('trial', opers, 'stopped'); 
%xippmex('digout', C.DIG_TRIGGER_CHAN, 0); % digital triggering
%pause(0.5)
% TODO test whether this works, and whether it would work to just set the
% value of total wait time above in initial recording trigger. Also, is it
% necessary to have a wait time in here before I try to load any files? 
%xippmex('trial', opers, 'stopped');

