
%% Initializations
% Clean the world
close all; fclose('all'); clc; clear all;
xippmex('close')

status = xippmex ;   %('tcp');
if status == 1; fprintf('Xippmex connected successfully \n\n'); end
if status ~= 1; error('Xippmex Did Not Initialize');  end

%mux_startup(3) % MUX ID = 3

%Load information about the animal and recording parameters. Here, I'm
%ignoring most of the extra information that we usually include since you
%don't need it to run this.
C.ACTIVE_CHAN = 128+[1:128]; %This assumes that you are plugging this headstage into port A
%Numbers relevant to each port B, C, D are in the xippmex docs.
C.STIM_POLARITY = 0; % 1 - positive (anodic) phase first, we usually do cathodic first
C.STIM_PW_MS = 0.2; % pulse width in milliseconds for each phase.
C.THRESH_REPS = 200; %how many pulses to include in the stimulus train
C.QUIET_REC = 1; %time in seconds to record without stimulation before and after

cathAmp = 100; %microamps of stimulation on each electrode
freq = 30; % stimulation frequency in Hz

fpath = 'D:\DataTanks\2019\Nelson\Grapevine\datafile';
%fpath = 'D:\DataTanks\2019\MUXtest\datafile';

%% stim one channel at a time for testing
for i = [1:12]        
        %stimChan = mux_connect([i]);
        stimChan = i;
        %pause(.5)
        fprintf('Stim on Electrode %d, Ripple Channel %d\n', i, stimChan);        
        
%         xippmex('stim','enable',0);  % Xippmex gives an error if Stim is not disabled before changing the resoultion 
%         xippmex ('stim', 'res', stimChan, 5);   % Resolution = 20 µA
%         xippmex('stim','enable'); % Enable stimulation
%         
%         stimString = sprintf('Elect=%d;TL=2000.0; TD=0.0;FS=0.0;PL=1;',stimChan);
        
        single_amp_stim(C, stimChan, cathAmp, freq, fpath);       
        pause(.5);
end


%% stim three channels for testing
for i = 0:61
        ele = [0,1,2] + i
        stimChan = mux_connect(ele);
        fprintf('Stim on Electrode %d,%d,%d, Ripple Channel %d,%d,%d\n', ele(1),ele(2),ele(3), stimChan(1), stimChan(2),stimChan(3));        
        
        xippmex('stim','enable',0);  % Xippmex gives an error if Stim is not disabled before changing the resoultion 
        xippmex ('stim', 'res', stimChan, 5);   % Resolution = 20 µA
        xippmex('stim','enable'); % Enable stimulation
        
        stimString = sprintf('Elect=%d,%d,%d,;TL=10000.0,10000.0,10000.0,; Freq=30,30,30,; Dur=0.2,0.2,0.2,;Amp=255,255,255,;TD=0.0,0.0,0.0,;FS=0.0,0.0,0.0,;PL=1,1,1,;',stimChan(1), stimChan(2), stimChan(3));
        xippmex ('stim', stimString);
        pause(4);
end