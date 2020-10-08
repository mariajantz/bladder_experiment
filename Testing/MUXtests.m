%Root file to run stimulation.
%Maria Jantz 05/31/19

%Load information about the animal and recording parameters. Here, I'm
%ignoring most of the extra information that we usually include since you
%don't need it to run this.
C.ACTIVE_CHAN = 128+[1:128]; %This assumes that you are plugging this headstage into port A
%Numbers relevant to each port B, C, D are in the xippmex docs.
C.STIM_POLARITY = 0; % 1 - positive (anodic) phase first, we usually do cathodic first
C.STIM_PW_MS = 0.2; % pulse width in milliseconds for each phase.
C.THRESH_REPS = 200; %how many pulses to include in the stimulus train
C.QUIET_REC = 0.5; %time in seconds to record without stimulation before and after

cathAmp = 500; %microamps of stimulation on each electrode
freq = 10; % stimulation frequency in Hz

fpath = 'D:\DataTanks\2019\MUXtest\datafile'; %set this to be whatever directory you want your
%files to be saved to -- it will be saved as 'datafile0001' and
%autoincrement the file number based on what is already in that directory

% added for mux control
%stimChan = [1 2]; %first stimulation channel will be cathodal; anodal current will be split
%between all remaining electrodes. Any number of electrodes should work.
xippmex

mux_startup

    for i = 0:63
        stimChan = mux_connect(i);
        fprintf('Stim on channel %d, ripple chan %d\n', i, stimChan);
        temp(i+1, :) = [i stimChan];
        
        %stimulate on 1 cathode, 0-31 anodes:
        single_amp_stim(C, stimChan, cathAmp, freq, fpath)

    end
    keyboard

