function [cmd, stimTime] = single_amp_cathodal_stim(C, stimChan, cathAmp, freq)
% C = experiment constants struct for a given animal
% input channel (for multichannel input cathode first), amplitude and frequency chosen

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
if max(cathAmp)<=127
    %set resolution of stimulation channels to 1 uA
    xippmex('stim','res',stimChan, 1);
    actualAmp = cathAmp; 
elseif max(cathAmp)<=254
    %set resolution of stimulation channels, and adjust the uA value of the
    %cathode amplitude to the unitless stimulation command value in terms
    %of stimulation resolution
    xippmex('stim','res',stimChan, 2);
    cathAmp = ceil(cathAmp/2);
    actualAmp = cathAmp*2; 
elseif max(cathAmp)<=635
    xippmex('stim','res',stimChan, 3);
    cathAmp = ceil(cathAmp/5);
    actualAmp = cathAmp*5; 
elseif max(cathAmp)<=1270
    xippmex('stim','res',stimChan, 4);
    cathAmp = ceil(cathAmp/10);
    actualAmp = cathAmp*10; 
else
    if max(cathAmp)>1500
        warning('Commanded stimulation amplitude is above 1.5 mA per electrode, may not reach that value')
    end
    xippmex('stim','res',stimChan, 5);
    cathAmp = ceil(cathAmp/20);
    actualAmp = cathAmp*20; 
end

fprintf('Actual amps of stim at %s\n', num2str(actualAmp)); 

%define polarity ALL CATHODAL
polarity = ones(1, length(stimChan)); 
if length(cathAmp) == 1
    %if you input one amplitude for several channels, it will 
    %set all channels to the same amplitude
    amps = cathAmp*ones(1, length(stimChan));
else
    amps = cathAmp;
end
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

