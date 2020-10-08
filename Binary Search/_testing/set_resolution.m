function [xippRes, stimVal, stimChan, actualAmp] = set_resolution(C, amp_uA, stimChan)
%function to set resolution of xippmex and the integer value for a certain
%amplitude of stimulation
%INPUT
%stimChan: one or several channel numbers 1-32
%amp_uA: total amplitude of stimulation to be applied
%C: experiment_constants
%OUTPUT
%xippRes: what resolution to set stimulation channels to
%stimVal: what the unitless stimulation amplitude is to send to ripple
%stimChan: channels to stimulate (put in terms of active channels - if using
%multiple stimulators, this will be in the dimensions of row x col x depth
%where the original input was row x col)
%actualAmp: actual amplitude of stimulation that will be applied (based on
%resolutions available

if stimChan > 32
    warning('Attempting to adjust for input stim channels not in range 1-32'); 
    tempChan = stimChan - C.ACTIVE_CHAN(1) - 1; 
    if all(tempChan>0) && all(tempChan<=32)
        stimChan = tempChan; 
    else
        error('Adjustment failed; make sure stimulation channels are correct.'); 
    end
end

% make arrays to determine resolution and range
% choose appropriate stimulation resolution and adjust amplitudes
% step 1: 1 uA steps, 2: 2 uA, 3: 5 uA, 4: 10 uA, 5: 20 uA
% ranges: 0-127 uA, 2-254 uA, 5-635, 10-1270, 20-1500 uA
stepRes = [1 2 5 10 20];
stepRange = [stepRes(1:4)*127 1500]; 

if isempty(C.HIGHAMP_HEADSTAGE_LOC) || amp_uA<=127
    %if there's only one stimulator, (or you need to use only one stimulator) this process is straightforward.
    
    %given a certain input amp, determine resolution
    if amp_uA>1500
        warning('Commanded stimulation amplitude is above 1.5 mA per electrode, may not reach that value');
    end
    
    %set resolution of stimulation channels, and adjust the uA value of the
    %cathode amplitude to the unitless stimulation command value in terms
    %of stimulation resolution
    xippRes = find(stepRange>=amp_uA, 1, 'first'); 
    stimVal = ceil(amp_uA/stepRes(xippRes)); 
    actualAmp = stimVal*stepRes(xippRes); 
    if actualAmp ~= amp_uA
        warning('Commanded amplitude is changed from %d to %d due to resolution of stimulator', amp_uA, actualAmp); 
    end
    
    %put the stimChan on the active channels
    stimChan = C.ACTIVE_CHAN(1)+stimChan-1;
    
else
    %when there is an extra headstage used for high amplitude stimulation,
    %also use that headstage to have more specific values available at
    %lower amplitudes.
    xippRes = find(stepRange<=amp_uA, 1, 'last'); 
    xippRes(2) = find(stepRange>=(amp_uA-stepRange(xippRes)), 1, 'first'); 
    
    stimVal = [stepRange(xippRes(1))/stepRes(xippRes(1)) ... %max value at this resolution
        ceil((amp_uA-stepRange(xippRes(1)))/stepRes(xippRes(2)))]; %remaining current applied here
    actualAmp = sum(stimVal.*stepRes(xippRes)); 
    
    if actualAmp ~= amp_uA
        warning('Commanded amplitude is changed from %d to %d due to resolution of stimulator', amp_uA, actualAmp); 
    end
    
    tempChan = [C.ACTIVE_CHAN(1)+stimChan-1];
    tempChan(:, :, 2) = [C.HIGHAMP_ACTIVE_CHAN(1)+stimChan-1];
    stimChan = tempChan; 
        
end




