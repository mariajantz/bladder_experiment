%% RIPPLE EXAMPLE ONE
% create the overall header values defining electrode, frequency,
% and number of repeats. This will stimulate on electrode 1 at 30
% Hz for one second.
cmd = struct('elec', 1, 'period', 1000, 'repeats', 30);
% Create the first phase (cathodic) for stimulation. This has a
% duration of 200 us (6 clock cycles at 30 kHz), an amplitude of
% 10, and negative polarity.
cmd.seq(1) = struct('length', 6, 'ampl', 10, 'pol', 0, ...
    'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);
% Create the inter-phase interval. This has a duration of 100 us
% (3 clock cycles at 30 kHz). The amplitude is zero. The
% stimulation amp is still used so that the stim markers sent by
% the NIP will properly contain this phase.
cmd.seq(2) = struct('length', 3, 'ampl', 0, 'pol', 0, 'fs', 0, ...
    'enable', 0, 'delay', 0, 'ampSelect', 1);
% Create the second, anodic phase. This has a duration of 200 us
% (6 cycles at 30 kHz), and amplitude of 10, and positive polarity.
cmd.seq(3) = struct('length', 6, 'ampl', 10, 'pol', 1, ...
    'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);
% Send the stimulation
xippmex('stimseq', cmd);


%% RIPPLE EXAMPLE TWO
% xippmex('stimseq') example producing a symmetric biphasic pulse with
% phases of 50 us and an inter-phase interval of 100 us. This example
% makes use of the stimulation control word's 'delay' field.
%
% single clock cycle in microseconds
clock_cycle = 1 / 30 * 1000;
% calculate the length of a single unit of delay in microseconds
delay_length = 1 / 30 * 1000 / 32;
% Setup the basic header elements. This will produce stimulation at 30
% Hz for one second
cmd = struct('elec', 1, 'period', 1000, 'repeats', 30);
% first command word. Produce 1 clock cycle worth of stimulation, for
% 33.3 us of the first 50 us phase.
cmd.seq(1) = struct('length', 1, 'ampl', 10, 'pol', 0, 'fs', 0, ...
    'enable', 1, 'delay', 0, 'ampSelect', 1);
% calculate the remaining duration of the cathodic phase. Because
% this is less than one clock cycle period the delay field will need
% to be used
cath_remaining = 50.0 - clock_cycle;
% the actual delay parameter must be an integer between 0 and 31
cath_delay = floor(cath_remaining / delay_length);
% This word will produce the full cathodic phase and a bit of the
% inter-phase interval. Here, the 'enable' field set to zero, sets
% the pulse to start high and transition to off.
cmd.seq(2) = struct('length', 1, 'ampl', 10, 'pol', 0, 'fs', 0, ...
    'enable', 0, 'delay', cath_delay, 'ampSelect', 1);
% The inter-phase interval is 100 us, so add two more full clock
% cycles worth of stimulation for 66.6 us more.
cmd.seq(3) = struct('length', 2, 'ampl', 0, 'pol', 0, 'fs', 0, ...
    'enable', 0, 'delay', 0, 'ampSelect', 1);
% calculate how much more of the inter-phase interval is remaining
% being careful to account for the quantization of the delay at the
% end of the cathodic phase
ipi_remaining = 100.0 - (clock_cycle - cath_delay * delay_length) - ...
    2 * clock_cycle;
ipi_delay = floor(ipi_remaining / delay_length);
% add this to the sequence list. Here the enable field sets the
% pulse to start off and transition to on.
cmd.seq(4) = struct('length', 1, 'ampl', 10, 'pol', 1, 'fs', 0, ...
    'enable', 1, 'delay', ipi_delay, 'ampSelect', 1);
% At this point there is not a full clock cycle's worth of stim left,
% so the pulse will be finished with one use of the delay field
anod_remaining = 50.0 - (clock_cycle - ipi_delay * delay_length);
anod_delay = floor(anod_remaining / delay_length);
% add the last command word
cmd.seq(5) = struct('length', 1, 'ampl', 10, 'pol', 1, 'fs', 0, ...
    'enable', 0, 'delay', anod_delay, 'ampSelect', 1);
% fire off stimulation
xippmex('stimseq', cmd);

%% in which maria attempts to build a command for one channel
%variables defined in code already
stimChan = 1;
trainLength = round(320/29*1000);
freq = 29;
pwDur = .2;
amps = 50;
delay_times = 0;
polarity = 1;
%variables that need to be defined in code
clock_cycle = 1/(30*1000); %30 kHz clock
period = ceil(1/(freq*clock_cycle));
%set up first part of cmd
cmd = struct('elec', stimChan, 'period', period, 'repeats', C.THRESH_REPS);
% Create the first phase (cathodic) for stimulation - don't allow
% fastsettle (fs)
pw_cyc = pwDur/clock_cycle/1000;
cmd.seq(1) = struct('length', pw_cyc, 'ampl', amps, 'pol', polarity, ...
    'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);
% Create the inter-phase interval. Use previous default duration of 66 us
% (2 clock cycles at 30 kHz). The amplitude is zero. The
% stimulation amp is still used so that the stim markers sent by
% the NIP will properly contain this phase.
cmd.seq(2) = struct('length', 2, 'ampl', 0, 'pol', 0, 'fs', 0, ...
    'enable', 0, 'delay', 0, 'ampSelect', 1);
% Create the second, anodic phase.
cmd.seq(3) = struct('length', pw_cyc, 'ampl', amps, 'pol', ~polarity, ...
    'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);


%% in which maria attempts to make multichannel stim work
%variables defined in code already
stimChan = [1 2];
trainLength = [round(320/29*1000) round(320/29*1000)];
freq = 29; %should switch this from repmat version
pwDur = .2; %should switch this from repmat version
amps = [50 50];
delay_times = 0;
polarity = [1 0];
%variables that need to be defined in code
clock_cycle = 1/(30*1000); %30 kHz clock
period = ceil(1/(freq*clock_cycle)); %time between pulses, in 33.3 us units
pw_cyc = pwDur/clock_cycle/1000;

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
    temp.seq(3) = struct('length', pw_cyc, 'ampl', amps(i), 'pol', ~polarity(i), ...
        'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);
    
    cmd(i) = temp;
end

%% in which maria attempts to make a max amp survey

cathAmp = 50;
anAmp = 25;
shuffle_map = C.STIM_MAP(randperm(length(C.STIM_MAP)), :);
numAnodes = size(cell2mat({C.STIM_MAP{:, 2}}'), 2);
% deal with duplicates
tempchan = [];
tempidx = [];
for i = 1:size(shuffle_map, 1)
    if ~any(ismember(tempchan, [shuffle_map{i, :}]))
        tempidx = [tempidx i];
        tempchan = [tempchan [shuffle_map{i, :}]];
    end
end
%assume that the same amount of overlap will be possible for all trials
splitidx = [];
if length(tempidx)~=size(shuffle_map, 1)
    for i = 1:ceil((1+numAnodes)*size(shuffle_map, 1)/length(tempchan))-1
        splitidx = [splitidx length(tempchan)];
        searchidx = setdiff(1:size(shuffle_map, 1), tempidx);
        %find subsequent indices
        for i = searchidx
            if ~any(ismember(tempchan(splitidx(end)+1:end), [shuffle_map{i, :}]))
                tempidx = [tempidx i];
                tempchan = [tempchan [shuffle_map{i, :}]];
            end
        end
    end
    
end
splitidx = [0 splitidx length(tempchan)];
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

%TODO: change the freq variable?
%freq = repmat(floor(C.STIM_FREQUENCY(1)/splitidx(2)), 1, length(chanNums));
%trainLength = repmat(ceil(C.MAX_AMP_REPS/freq(1)*1000), 1, length(chanNums));
%pwDur = repmat(C.STIM_PW_MS, 1, length(chanNums));

%variables that need to be defined in code
clock_cycle = 1/(30*1000); %30 kHz clock
period = ceil(1/(freq/splitidx(2)*clock_cycle)); %time between pulse series, in 33.3 us units
pw_cyc = C.STIM_PW_MS/clock_cycle/1000;

for i = 1:length(unique(splitidx))-1
    strIdx = splitidx(i)+1:splitidx(i+1);
    iter = splitidx(i+1)-splitidx(i); 
    for j = iter:-1:1
        %set up first part of cmd
        temp = struct('elec', chanNums(strIdx(j)), 'period', period, 'repeats', C.MAX_AMP_REPS, 'action', 'allcyc');
        % create a delay phase before stimulation begins TODO test if this
        % causes problems for the times when delay = 0
        temp.seq(1) = struct('length', delay_times(j)/clock_cycle/1000, 'ampl', 0, 'pol', 0, ...
            'fs', 0, 'enable', 0, 'delay', 0, 'ampSelect', 1); 
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
        temp.seq(4) = struct('length', pw_cyc, 'ampl', amps(strIdx(j)), 'pol', ~polarity(strIdx(j)), ...
            'fs', 0, 'enable', 1, 'delay', 0, 'ampSelect', 1);
        
        cmd(j) = temp;
    end
    %stimulate here, and pause
end








