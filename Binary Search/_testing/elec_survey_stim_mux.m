function [stimChan] = elec_survey_stim_mux(C, delay_time, datapath)
% use this for a single amp/high amp survey
% C = experiment constants struct for a given animal
% delay_time = time to let xippmex respond (by default this should be
% about 0.2 seconds)
% outputs the channels which have responses, and which nerve cuffs
% responded, at what latency to first peak/end (to choose frequency later)

% set up to trigger recording
status = xippmex;
if status == 0
    error('Xippmex is not connecting.')
end

%initialize mux
mux_startup; 

% randomize channel order
shuffle_map = C.STIM_MAP(randperm(length(C.STIM_MAP)), :);

% choose correct port numbers, stimulation resolution, and amplitude of
% stimulation
if contains(C.ARRAY_TYPE, 'MUX')
    [xippRes, stimVal, stimChan, ~] = set_resolution(C, C.MAX_AMP, [1:32]');
    %TODO: deal with multipolar stimulation
else
    [xippRes, stimVal, stimChan, ~] = set_resolution(C, C.MAX_AMP, cell2mat(shuffle_map));
end

%set resolution
xippmex('stim', 'enable', 0)

for i = 1:length(xippRes)
    xippmex('stim', 'res', unique(stimChan(:, :, i)), xippRes(i));
end

xippmex('stim', 'enable', 1)

stimChan = cell2mat(shuffle_map);
% calculate amplitudes of anodic stimulation, as split across channels and
% correcting for any differences in length of time stimulating on
% cathode/anode
if size(stimChan, 2)==1
    %monopolar stimulation
    anAmp = 0;
    numAnodes = 0;
    polarity = C.STIM_POLARITY; %first cathodic stim; anodic first is defined by 0
elseif size(stimChan, 2)>1
    %multipolar stimulation
    numAnodes = size(stimChan, 2)-1;
    
    % make an array of stimulus values with rows = values to each
    % stimulator and cols = values split across anodes
    for s = 1:size(stimChan, 3)
        if rem(stimVal(s), numAnodes)
            anAmp(:, s) = repmat(floor(stimVal(s)/numAnodes), 1, numAnodes);
            if anAmp(1, s)==0
                warning('Amplitude split between channels is a decimal value; some channels set to zero');
            end
            for j=1:(stimVal(s)-anAmp(1, s)*numAnodes)
                anAmp(j, s) = anAmp(j, s)+1;
            end
        else
            anAmp(:, s) = repmat(floor(stimVal(s)/numAnodes), 1, numAnodes);
        end
    end
    
    %define polarity (this makes it bipolar) - cathodic first 0, anodic first 1
    polarity = [C.STIM_POLARITY ~C.STIM_POLARITY*ones(1, numAnodes)];
end
polarity = repmat(polarity, 1, size(stimChan, 3));

% as long as there are indices of channel sets that haven't been added, add
% the channel set and index to array to stimulate
%chanNums = reshape(stimChan(tempidx, :)', 1, []);


freq = C.STIM_FREQUENCY(1);
if any(freq == [20 30 60 120 180])
    freq = freq - 1; %remove harmonics of 60 Hz
end

% calculate array of delays between each pulse based on frequency and number of
% channels, as well as multipolar/monopolar configuration
interleave_delay = 1000/freq;
%TODO: change this part to match electrode array
delay_times = zeros(1, length(stimChan));
for i = 2:size(shuffle_map, 1)
    numElec = size(stimChan, 2)*size(stimChan, 3);
    idx = i*numElec;
    delay_times(idx-numElec+1:idx) = ones(1, numElec)*interleave_delay*(i-1);
end

%convert remaining variables to stimulation array format
%TODO: change this part to match electrode array
polarity = repmat(polarity, 1, size(shuffle_map, 1));
if all(anAmp == 0)
    amps = repmat(stimVal, 1, size(shuffle_map, 1));
else
    ampArr = reshape([stimVal; anAmp], 1, []);
    amps = repmat(ampArr, 1, size(shuffle_map, 1));
end

clock_cycle = 1/(30*1000); %30 kHz clock
%TODO move this inside the loop
%period = ceil(1/(freq/(splitidx(2)/(numAnodes+1))*clock_cycle)); %time between pulse series, in 33.3 us units
pw_cyc = C.STIM_PW_MS/clock_cycle/1000;

%trigger recording TODO test this time period
stimTime = size(C.STIM_MAP, 1)/freq*C.MAX_AMP_REPS;
%TODO: change next line -- no split, no delay time
full_pause = ceil(stimTime+2*C.QUIET_REC+size(stimChan, 1)*delay_time);

if C.DIG_TRIGGER_CHAN == 0
    xippmex('trial', 'recording', datapath, 0, 1);
else
    xippmex('digout', C.DIG_TRIGGER_CHAN, 1);
    pause(0.2); %this version needs a little additional time
end
pause(delay_time);%just in case it doesn't quite catch recording of first stim
full_pause = full_pause-delay_time;

% quiet recording
fprintf('Quiet recording for %.1f s\n', C.QUIET_REC);
pause(C.QUIET_REC);
full_pause = full_pause-C.QUIET_REC;

%since mux can only do one tripole at a time, do everything here in loop
%rather than sequential
%TODO initialize mux before this
for i = 1:size(stimChan, 1) %TODO not sure if this or chanNums
    clear cmd
    %set up first part of cmd
    idx = i*numElec;
    strIdx = idx-numElec+1:idx; %index of the info for electrode/electrodes to stimulate
    period = ceil(1/(freq*clock_cycle));
    %set mux
    stimChan_mux = mux_connect(stimChan(strIdx))+C.ACTIVE_CHAN(1)-1;
    
    pause(1); 
    
    for j = numElec:-1:1
        temp = struct('elec', stimChan_mux(j), 'period', period, 'repeats', C.MAX_AMP_REPS, 'action', 'curcyc');
        %delay times is always zero for this version
        % Create the first phase (cathodic) for stimulation - don't allow
        % fastsettle (fs)
        temp.seq(1) = struct('length', pw_cyc, 'ampl', amps(strIdx(j)), 'pol', polarity(strIdx(j)), ...
            'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);
        % Create the inter-phase interval. Use previous default duration of 66 us
        % (2 clock cycles at 30 kHz). The amplitude is zero. The
        % stimulation amp is still used so that the stim markers sent by
        % the NIP will properly contain this phase.
        temp.seq(2) = struct('length', 2, 'ampl', 0, 'pol', 0, 'fs', 0, ...
            'enable', 0, 'delay', 0, 'ampSelect', 1);
        % Create the second, anodic phase.
        temp.seq(3) = struct('length', pw_cyc, 'ampl', amps(strIdx(j)), 'pol', double(~polarity(strIdx(j))), ...
            'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);
        cmd(j) = temp;
    end
    
    %stim on this set of electrodes
    %stimulate here, and pause
    xippmex('stimseq', cmd);
    stimTime = C.MAX_AMP_REPS/freq;
    disp(i);
    fprintf('Stimulating for %.1f s\n', stimTime);
    pause(stimTime+delay_time) %pause to let stimulation finish
    full_pause = full_pause-(stimTime+delay_time);
end
% must use splitidx for multipolar because duplicated channel numbers are ignored


% quiet recording again
fprintf('Quiet recording for %.1f s\n', C.QUIET_REC);
pause(C.QUIET_REC);
full_pause = full_pause-C.QUIET_REC;
pause(full_pause); %pause for remaining time

if C.DIG_TRIGGER_CHAN == 0
    xippmex('trial', 'stopped'); 
else
    xippmex('digout', C.DIG_TRIGGER_CHAN, 0);
end

pause(1)
