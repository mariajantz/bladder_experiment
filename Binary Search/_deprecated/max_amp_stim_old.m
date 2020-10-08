function [] = max_amp_stim_old(C)
% C = experiment constants struct for a given animal
% outputs the channels which have responses, and which nerve cuffs
% responded, at what latency to first peak/end (to choose frequency later)
% OLD VERSION FOR TRELLIS 1.7

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

% calculate amplitudes of anodic stimulation, as split across channels and
% correcting for any differences in length of time stimulating on
% cathode/anode
if size(C.STIM_MAP, 2)==1
    %monopolar stimulation
    anAmp = 0;
    numAnodes = 0;
    polarity = 1; %first cathodic stim; anodic first is defined by 0
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
    %define polarity (this makes it bipolar) - cathodic first 1, anodic first 0
    polarity = [1 zeros(1, numAnodes)];
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

% calculate array of delays between each pulse based on frequency and number of
% channels, as well as multipolar/monopolar configuration
interleave_delay = 1000/C.STIM_FREQUENCY(1);
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

%make array of train length, frequency, etc values - all identical
%TODO: check that train length and freq refer to total not per channel
freq = repmat(ceil(C.STIM_FREQUENCY(1)/splitidx(2)), 1, length(chanNums));
trainLength = repmat(ceil(C.MAX_AMP_REPS/freq(1)*1000), 1, length(chanNums));
pwDur = repmat(C.STIM_PW_MS, 1, length(chanNums));

% TODO trigger stimulation quicker - get feedback on state...
% xippmex('digout', C.DIG_TRIGGER_CHAN, 1);
xippmex('trial', 'recording'); 
pause(0.5)

% quiet recording
fprintf('Quiet recording for %.1f s\n', C.QUIET_REC);
pause(C.QUIET_REC);
% convert all parameters to a stimulation string
% must use splitidx for multipolar because duplicated channel numbers are ignored
for i = 1:length(unique(splitidx))-1
    strIdx = splitidx(i)+1:splitidx(i+1);
    %delay times set differently so delay doesn't shift each set
    stimString = stim_param_to_string(chanNums(strIdx), trainLength(strIdx),...
        freq(strIdx), pwDur(strIdx), amps(strIdx), delay_times(1:length(strIdx)), polarity(strIdx));
    % stimulate on all channels
    xippmex('stim',stimString);
    fprintf('Stimulating for %.1f s\n', trainLength(1)/1000); 
    pause(trainLength/1000 + 0.5) %pause to let stimulation finish
end

% quiet recording again
fprintf('Quiet recording for %.1f s\n', C.QUIET_REC);
pause(C.QUIET_REC);

% TODO trigger stimulation quicker - get feedback on state...
%xippmex('digout', C.DIG_TRIGGER_CHAN, 0);
xippmex('trial', 'stopped'); 
pause(0.5)

