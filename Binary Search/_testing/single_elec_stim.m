function [actualAmp] = single_elec_stim(C, stimChan, cathAmp, freq, datapath)
% C = experiment constants struct for a given animal
% input channel (for multichannel input cathode first), amplitude and frequency chosen
% stimChan dimensions input: must have one row (single electrode), columns
% where the first column is cathode and the rest are anodes.

% set up to trigger recording
status = xippmex;
if status == 0
    error('Xippmex is not connecting.')
end

% choose correct port numbers, stimulation resolution, and amplitude of
% stimulation
[xippRes, stimVal, stimChan, actualAmp] = set_resolution(C, cathAmp, stimChan);

%TODO check this changes resolution on both stimulators - otherwise need
%loop
for i = 1:length(xippRes)
xippmex('stim','res',stimChan(1, 1, i), xippRes(i));
end
% calculate amplitudes of anodic stimulation, as split across channels and
% correcting for any differences in length of time stimulating on
% cathode/anode
if size(stimChan, 2)==1
    %monopolar stimulation
    anAmp = 0;
    numAnodes = 0;
    polarity = C.STIM_POLARITY; %first cathodic stim; anodic first is defined by 1 (*note: 0 causes negative pulse first)
elseif size(stimChan, 2)>1
    %multipolar stimulation
    numAnodes = size(stimChan, 2)-1;
    
    % make an array of stimulus values, with extra stimulator if necessary
    for s = 1:size(stimChan, 3)
        if rem(stimVal(s), numAnodes)
            anAmp(:, :, s) = repmat(floor(stimVal(s)/numAnodes), 1, numAnodes);
            if anAmp(1, 1, s)==0
                warning('Amplitude split between channels is a decimal value; some channels set to zero');
            end
            for j=1:(stimVal(s)-anAmp(1, 1, s)*numAnodes)
                anAmp(j, 1, s) = anAmp(j, 1, s)+1;
            end
        else
            anAmp(:, :, s) = repmat(floor(stimVal(s)/numAnodes), 1, numAnodes);
        end
    end

    %define polarity (this makes it bipolar) - cathodic first 0, anodic first 1
    polarity = [C.STIM_POLARITY ~C.STIM_POLARITY*ones(1, numAnodes)];
end

polarity = repmat(polarity, 1, size(stimChan, 3));

if anAmp == 0
    amps = stimVal;
else
    anAmp(1, end+1, :) = stimVal;
    amps = fliplr(anAmp);
    amps = amps(:);
end
stimChan = stimChan(:);

%make array of train length, frequency, etc values - all identical
%trainLength = repmat(C.THRESH_REPS/freq*1000, 1, length(stimChan));
%freq = repmat(freq, 1, length(stimChan));
%delay_times = zeros(1, length(stimChan));
%note: anode and cathode duration apply to all electrodes - refer to stim phase,
%not the role of a specific electrode in multipolar stimulation
%pwDur = repmat(C.STIM_PW_MS, 1, length(stimChan));

% convert all parameters to a stimulation string

clock_cycle = 1/(30*1000); %30 kHz clock
period = ceil(1/(freq*clock_cycle)); %time between pulses, in 33.3 us units
pw_cyc = C.STIM_PW_MS/clock_cycle/1000;

% deal with polarity, make sure amps are right
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
if C.DIG_TRIGGER_CHAN == 0
    try
        xippmex('trial', 'recording', datapath, 0, 1); %remote control
    catch ME
        warning('Check recording is turned on'); 
        keyboard
    end
else
    xippmex('digout', C.DIG_TRIGGER_CHAN, 1); %digital triggering
    pause(0.4)
end

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

if C.DIG_TRIGGER_CHAN == 0
    try
        xippmex('trial', 'stopped');
    catch ME
        warning('Check recording has stopped'); 
        keyboard
    end
else
    xippmex('digout', C.DIG_TRIGGER_CHAN, 0);
    pause(0.5)
end 

%check that it actually exited
try
xippStatus = xippmex('trial'); pause(0.3); 
catch %try again?
xippStatus = xippmex('trial'); pause(0.3); 
end
loopcount = 0; %also make sure it doesn't get stuck in the loop
while ~strcmp(xippStatus.status, 'stopped')
    if loopcount > 10
        error('Took too long to stop recording'); 
    end
    warning('Giving extra time to stop recording')
    xippmex('trial', 'stopped');
    pause(1); %if it hasn't stopped recording, give it time 
    xippStatus = xippmex('trial'); 
    loopcount = loopcount + 1; 
end

