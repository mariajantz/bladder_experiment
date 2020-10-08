function [daqData] = scratch_stimDesign_presetAmpsMultichan(daq, cathChan, anChan, stimFEport, cathAmp_uA, numPulses, freq, phaseDur_ms,  preQuietT_s, postQuietT_s, varargin)
% multiple electrodes at a time is fine; one amplitude
% each stim amplitude generates a single file


DEFINE_CONSTANTS
digTrigger_enable = false;
digTrigger_chan   = 1;
END_DEFINE_CONSTANTS

status = xippmex;
if status == 0
    error('Xippmex did not initialize...good luck')
end

if digTrigger_enable
    xippmex('digout', digTrigger_chan, 0);
    pause(1)
end

switch stimFEport
    case 'B'
        anChan = 128+anChan;
        cathChan = 128+cathChan;
    case 'C'
        anChan = 256+anChan;
        cathChan = 256+cathChan;
    case 'D'
        anChan = 384+anChan;
        cathChan = 384+cathChan;
end

if xippmex('stim','res',[anChan cathChan]) ~= 1
    %set resolution of stimulation channels to 1 uA
    %step 1: 1 uA steps, 2: 2 uA, 3: 5 uA, 4: 10 uA, 5: 20 uA
    xippmex('stim','res',[anChan cathChan], 5);
    pause(1)
end
xippmex('stim','res',[anChan cathChan], 5);
cathAmp_uA = ceil(cathAmp_uA/20); 

%make array of train length, frequency, etc values - all identical
trainLength_ms         = repmat(numPulses/freq*1000, 1, length(anChan)+length(cathChan));
freq = repmat(freq, 1, length(anChan) + length(cathChan));
phaseDur_ms = repmat(phaseDur_ms, 1, length(anChan)+length(cathChan));
elecDelay_ms = zeros(1, length(anChan)+length(cathChan)); %no delay

%for i = 1:length(cathAmp_uA) %defunct usage...

%calculate list of amplitudes - split the number that will be
%passed according to how many are in list of channels for each cath and
%anode
if rem(cathAmp_uA, length(cathChan))
    
    %find the closest distribution of integer values to reach goal
    cathAmp = repmat(floor(cathAmp_uA/length(cathChan)), 1, length(cathChan));
    if cathAmp(1)==0
        warning('Amplitude split between channels is a decimal value; some channels set to zero');
    end
    for j=1:(cathAmp_uA-cathAmp(1)*length(cathChan))
        cathAmp(j) = cathAmp(j)+1;
    end
else
    cathAmp = repmat(floor(cathAmp_uA/length(cathChan)), 1, length(cathChan));
end
if rem(cathAmp_uA, length(anChan))
    anAmp = repmat(floor(cathAmp_uA/length(anChan)), 1, length(anChan));
    if anAmp(1)==0
        warning('Amplitude split between channels is a decimal value; some channels set to zero');
    end
    for j=1:(cathAmp_uA-anAmp(1)*length(anChan))
        anAmp(j) = anAmp(j)+1;
    end
else
    anAmp = repmat(floor(cathAmp_uA/length(anChan)), 1, length(anChan));
end
%define polarity (this makes it bipolar) - cath first 1, anode first 0
polarity = [zeros(1, length(anChan)) ones(1, length(cathChan))];

stimString = stim_param_to_string([anChan cathChan], trainLength_ms,...
    freq, phaseDur_ms, [anAmp cathAmp], elecDelay_ms, polarity);

if digTrigger_enable
    pause(2)
    xippmex('digout', digTrigger_chan, 1);
    pause(1)
else
    disp('Manually start recording and press any key')
    pause
end

disp('Pre-stim quiet recording')
pause(preQuietT_s)

disp('starting stim')
xippmex('stim',stimString)
daqData = daq.startForeground; 
pause(trainLength_ms/1000+2)
disp('stim ended')

disp('Post-stim quiet recording')
pause(postQuietT_s)

if digTrigger_enable
    xippmex('digout', digTrigger_chan, 0);
    pause(2)
else
    disp('Manually stop recording and press any key')
    pause
end
%end
end
