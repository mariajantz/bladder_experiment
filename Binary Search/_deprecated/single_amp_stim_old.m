function [] = single_amp_stim(C, stimChan, cathAmp, freq)
% C = experiment constants struct for a given animal
% input channel (for multichannel input cathode first), amplitude and frequency chosen
% OLD VERSION FOR TRELLIS 1.7

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

% calculate amplitudes of anodic stimulation, as split across channels and
% correcting for any differences in length of time stimulating on
% cathode/anode
if length(stimChan)==1
    %monopolar stimulation
    anAmp = 0;
    numAnodes = 0; 
    polarity = 1; %first cathodic stim; anodic first is defined by 0
elseif length(stimChan)>1
    %multipolar stimulation
    numAnodes = length(stimChan)-1;
        
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
end

if anAmp == 0
    amps = cathAmp;
else
    amps = [cathAmp anAmp];
end

%make array of train length, frequency, etc values - all identical
trainLength = repmat(C.THRESH_REPS/freq*1000, 1, length(stimChan));
freq = repmat(freq, 1, length(stimChan));
delay_times = zeros(1, length(stimChan)); 
%note: anode and cathode duration apply to all electrodes - refer to stim phase,
%not the role of a specific electrode in multipolar stimulation
pwDur = repmat(C.STIM_PW_MS, 1, length(stimChan)); 

% convert all parameters to a stimulation string
% TODO: test this - especially with bipolar, tripolar stim. Do doubled
% channel numbers work?
stimString = stim_param_to_string(stimChan, trainLength, freq, pwDur, ...
    amps, delay_times, polarity); 

% TODO trigger stimulation quicker - get feedback on state...
xippmex('digout', C.DIG_TRIGGER_CHAN, 1);
pause(0.5)

% quiet recording
fprintf('Quiet recording for %.1f s\n', C.QUIET_REC); 
pause(C.QUIET_REC); 

% stimulate on all channels
xippmex('stim',stimString); 
fprintf('Stimulating for %.1f s\n', trainLength(1)/1000)
pause(trainLength/1000 + 0.5) %pause to let stimulation finish

% quiet recording again
fprintf('Quiet recording for %.1f s\n', C.QUIET_REC); 
pause(C.QUIET_REC);

% TODO trigger stimulation quicker - get feedback on state...
xippmex('digout', C.DIG_TRIGGER_CHAN, 0);
pause(0.5)

