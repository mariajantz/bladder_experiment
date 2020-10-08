function [] = max_amp_stim(C, delay_time)
% C = experiment constants struct for a given animal
% outputs the channels which have responses, and which nerve cuffs
% responded, at what latency to first peak/end (to choose frequency later)

% choose correct port numbers
if C.STIM_MAP{1}<C.ACTIVE_CHAN(1)
    C.STIM_MAP = cellfun(@(x) C.ACTIVE_CHAN(1)+x-1, C.STIM_MAP, 'UniformOutput', 0);
end

stimChan = unique(cell2mat({C.STIM_MAP{:}})); %all channels used to stimulate

% set up to trigger recording
status = xippmex;
if status == 0
    error('Xippmex is not connecting.')
end

%xippmex('stim', 'enable', 0)
% choose appropriate stimulation resolution and adjust amplitudes
% step 1: 1 uA steps, 2: 2 uA, 3: 5 uA, 4: 10 uA, 5: 20 uA
% ranges: 0-127 uA, 2-254 uA, 5-635, 10-1270, 20-1500 uA
cathAmp = C.MAX_AMP;
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
        warning('Stimulation amplitude is above 1.5 mA per electrode')
    end
    xippmex('stim','res',stimChan, 5);
    cathAmp = ceil(cathAmp/20);
end

%xippmex('stim', 'enable', 1)
% calculate amplitudes of anodic stimulation, as split across channels and
% correcting for any differences in length of time stimulating on
% cathode/anode
if size(C.STIM_MAP, 2)==1
    %monopolar stimulation
    anAmp = 0;
    numAnodes = 0;
    polarity = C.STIM_POLARITY; %first cathodic stim; anodic first is defined by 1
elseif size(C.STIM_MAP, 2)==2
    %multipolar stimulation
    try
        numAnodes = size(cell2mat({C.STIM_MAP{:, 2}}'), 2);
    catch
        error('Incorrect formatting of stimulation map, check that all sets include the same number of channels.');
    end
    
    % make an array of stimulus values
    if rem(cathAmp, numAnodes)
        anAmp = repmat(floor(cathAmp/numAnodes), 1, numAnodes);
        if anAmp(1)==0
            warning('Amplitude split between channels is a decimal value; some channels set to zero');
        end
        for j=1:(cathAmp-anAmp(1)*numAnodes)
            anAmp(j) = anAmp(j)+1;
        end
    else
        anAmp = repmat(floor(cathAmp/numAnodes), 1, numAnodes);
    end
    %define polarity (this makes it bipolar) - cathodic first 0, anodic first 1
    polarity = [C.STIM_POLARITY ~C.STIM_POLARITY*ones(1, numAnodes)];
else
    error('Incorrect formatting of stimulation map');
end

% randomize channel order
shuffle_map = C.STIM_MAP(randperm(length(C.STIM_MAP)), :);
% deal with duplicates
tempchan = [];
tempidx = [];
for i = 1:size(shuffle_map, 1)
    if ~any(ismember(tempchan, [shuffle_map{i, :}]))
        tempidx = [tempidx i];
        tempchan = [tempchan [shuffle_map{i, :}]];
    end
end

% as long as there are indices of channel sets that haven't been added, add
% the channel set and index to array to stimulate
splitidx = [];
if length(tempidx)~=size(shuffle_map, 1)
    searchidx = setdiff(1:size(shuffle_map, 1), tempidx);
    while ~isempty(searchidx)
        splitidx = [splitidx length(tempchan)];
        %find subsequent indices
        for j = searchidx
            if ~any(ismember(tempchan(splitidx(end)+1:end), [shuffle_map{j, :}]))
                tempidx = [tempidx j];
                tempchan = [tempchan [shuffle_map{j, :}]];
            end
        end
        searchidx = setdiff(searchidx, tempidx); 
    end
end
splitidx = unique([0 splitidx length(tempchan)]);
chanNums = tempchan;

freq = C.STIM_FREQUENCY(1);
if any(freq == [20 30 60 120 180])
    freq = freq - 1; %remove harmonics of 60 Hz
end

% calculate array of delays between each pulse based on frequency and number of
% channels, as well as multipolar/monopolar configuration
interleave_delay = 1000/freq;
delay_times = zeros(1, (1+numAnodes)*size(shuffle_map, 1));
for i = 1:size(shuffle_map, 1)
    idx = i*(1+numAnodes);
    delay_times((idx-numAnodes):idx) = ones(1, 1+numAnodes)*interleave_delay*(i-1);
end

%convert remaining variables to stimulation array format
polarity = repmat(polarity, 1, size(shuffle_map, 1));
if anAmp == 0
    amps = repmat(cathAmp, 1, size(shuffle_map, 1));
else
    amps = repmat([cathAmp anAmp], 1, size(shuffle_map, 1));
end

clock_cycle = 1/(30*1000); %30 kHz clock
%TODO move this inside the loop
%period = ceil(1/(freq/(splitidx(2)/(numAnodes+1))*clock_cycle)); %time between pulse series, in 33.3 us units
pw_cyc = C.STIM_PW_MS/clock_cycle/1000;

%trigger recording TODO test this time period
stimTime = size(C.STIM_MAP, 1)/freq*C.MAX_AMP_REPS;
full_pause = ceil(stimTime+2*C.QUIET_REC+length(splitidx)*delay_time); 
xippmex('trial', 'recording', [], full_pause);
%xippmex('trial', 'recording'); pause(0.5); 
pause(delay_time);%just in case it doesn't quite catch recording of first stim
full_pause = full_pause-delay_time;  
%xippmex('digout', C.DIG_TRIGGER_CHAN, 1);
%pause(0.5)

% quiet recording
fprintf('Quiet recording for %.1f s\n', C.QUIET_REC);
pause(C.QUIET_REC); 
full_pause = full_pause-C.QUIET_REC; 
% must use splitidx for multipolar because duplicated channel numbers are ignored
% TODO: hack method = increase amount of recording time, good method =
% update the period within the loop so it's correct even with different
% numbers of virtual channels being stimulated
for i = 1:length(splitidx)-1
    clear cmd
    strIdx = splitidx(i)+1:splitidx(i+1);
    iter = splitidx(i+1)-splitidx(i);
    new_freq = freq/iter*(numAnodes+1);%original freq / total length of channel array * number of channels per virtual channel
    period = ceil(1/(new_freq*clock_cycle)); 
    for j = iter:-1:1
        %set up first part of cmd
        temp = struct('elec', chanNums(strIdx(j)), 'period', period, 'repeats', C.MAX_AMP_REPS, 'action', 'curcyc');
        if delay_times(j)~=0
            % create a delay phase before stimulation begins this
            % causes problems for the times when delay = 0
            temp.seq(1) = struct('length', ceil(delay_times(j)/clock_cycle/1000), 'ampl', 0, 'pol', 0, ...
                'fs', 0, 'enable', 0, 'delay', 0, 'ampSelect', 0);
            % Create the first phase (cathodic) for stimulation - don't allow
            % fastsettle (fs)
            temp.seq(2) = struct('length', pw_cyc, 'ampl', amps(strIdx(j)), 'pol', polarity(strIdx(j)), ...
                'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);
            % Create the inter-phase interval. Use previous default duration of 66 us
            % (2 clock cycles at 30 kHz). The amplitude is zero. The
            % stimulation amp is still used so that the stim markers sent by
            % the NIP will properly contain this phase.
            temp.seq(3) = struct('length', 2, 'ampl', 0, 'pol', 0, 'fs', 0, ...
                'enable', 0, 'delay', 0, 'ampSelect', 1);
            % Create the second, anodic phase.
            temp.seq(4) = struct('length', pw_cyc, 'ampl', amps(strIdx(j)), 'pol', double(~polarity(strIdx(j))), ...
                'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);
        else
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
        end
        cmd(j) = temp;
    end
    %stimulate here, and pause
    
    xippmex('stimseq', cmd);
    stimTime = C.MAX_AMP_REPS/freq*iter/(numAnodes+1);
    disp(splitidx); 
    fprintf('Stimulating for %.1f s\n', stimTime);
    pause(stimTime+delay_time) %pause to let stimulation finish
    full_pause = full_pause-(stimTime+delay_time); 
    
end

% quiet recording again
fprintf('Quiet recording for %.1f s\n', C.QUIET_REC);
pause(C.QUIET_REC);
full_pause = full_pause-C.QUIET_REC; 
pause(full_pause); 

%xippmex('trial', 'stopped'); pause(0.5); 

% xippmex('digout', C.DIG_TRIGGER_CHAN, 0);
% pause(0.5)

