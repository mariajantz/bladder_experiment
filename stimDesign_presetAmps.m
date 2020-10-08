function [] = stimDesign_presetAmps(stimChan, stimFEport, cathAmp_uA, numPulses, freq, phaseDur_ms,  preQuietT_s, postQuietT_s, varargin)
    % one electrode at a time; multiple amplitudes are fine
    % each stim amplitude generates a single file
    

    DEFINE_CONSTANTS
    digTrigger_enable = false;
    digTrigger_chan   = 1;
    END_DEFINE_CONSTANTS
    
    status = xippmex;
    if status == 0
        error('We have a problem...You dont say?')
    end
%     
%     if digTrigger_enable
%         xippmex('digout', digTrigger_chan, 0);
%         pause(1)
%     end
    
    switch stimFEport
        case 'B'
            stimChan = 128+stimChan;
        case 'C'
            stimChan = 256+stimChan;
        case 'D'
            stimChan = 384+stimChan;
    end
    
%     if xippmex('stim','res',stimChan) ~= 1
%         xippmex('stim','res',stimChan, 1);
%         pause(1)
%     end
    
    %step 1: 1 uA steps, 2: 2 uA, 3: 5 uA, 4: 10 uA, 5: 20 uA
%ranges: 0-127 uA, 2-254 uA, 5-635, 10-1270, 20-1500 uA
tempAmp = max(cathAmp_uA); 
if tempAmp<=127
    %set resolution of stimulation channels to 1 uA
    xippmex('stim','res',stimChan, 1);
elseif tempAmp<=254
    xippmex('stim','res',stimChan, 2);
    cathAmp_uA = ceil(cathAmp_uA/2); 
elseif tempAmp<=635
    xippmex('stim','res',stimChan, 3);
    cathAmp_uA = ceil(cathAmp_uA/5); 
elseif tempAmp<=1270
    xippmex('stim','res',stimChan, 4);
    cathAmp_uA = ceil(cathAmp_uA/10);
else
    if tempAmp>1500
        warning('Stimulation amplitude is above 1.5 mA per electrode')
    end
    xippmex('stim','res',stimChan, 5);
    cathAmp_uA = ceil(cathAmp_uA/20);
end
%pause(1)
    
    trainLength_ms         = numPulses/freq*1000;
    for i = 1:length(cathAmp_uA)
        
        stimString = stim_param_to_string(stimChan, trainLength_ms, freq, phaseDur_ms, cathAmp_uA(i), 0, 1);

        if digTrigger_enable
            %pause(2)
            xippmex('digout', digTrigger_chan, 1);
            pause(0.5)
        else
            disp('Manually start recording and press any key')
            pause
        end
        
        disp('Pre-stim quiet recording')
        pause(preQuietT_s)
        
        disp('starting stim')
        xippmex('stim',stimString)
        pause(trainLength_ms/1000)
        disp('stim ended')

        disp('Post-stim quiet recording')
        pause(postQuietT_s)

        if digTrigger_enable
            xippmex('digout', digTrigger_chan, 0);
            pause(0.5)
        else
            disp('Manually stop recording and press any key') 
            pause
        end
    end
end
