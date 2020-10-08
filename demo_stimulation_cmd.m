%Root file to run stimulation.
%Maria Jantz 05/31/19

%Load information about the animal and recording parameters. Here, I'm
%ignoring most of the extra information that we usually include since you
%don't need it to run this.
C.ACTIVE_CHAN = [1:128]; %This assumes that you are plugging this headstage into port A
%Numbers relevant to each port B, C, D are in the xippmex docs.
C.STIM_POLARITY = 0; % 1 - positive (anodic) phase first, we usually do cathodic first
C.STIM_PW_MS = 0.2; % pulse width in milliseconds for each phase.
C.THRESH_REPS = 300; %how many pulses to include in the stimulus train
C.QUIET_REC = 0.5; %time in seconds to record without stimulation before and after

stimChan = [1 2]; %first stimulation channel will be cathodal; anodal current will be split
%between all remaining electrodes. Any number of electrodes should work.

cathAmp = 200; %microamps of stimulation on each electrode
freq = 20; % stimulation frequency in Hz

fpath = 'R:\data_raw\cat\2018\datafile'; %set this to be whatever directory you want your
%files to be saved to -- it will be saved as 'datafile0001' and
%autoincrement the file number based on what is already in that directory

%stimulate on 1 cathode, 0-31 anodes:
single_amp_stim(C, stimChan, cathAmp, freq, fpath)

%stimulate on as many cathods as you want:
pre_quiet = 1;
post_quiet = 1;
[cmd, stimTime] = single_amp_cathodal_stim(C, stimChan, cathAmp, freq);

% trigger recording
xippmex('trial', 'recording', fpath, 0, 1);

% quiet recording
fprintf('Quiet recording for %.1f s\n', pre_quiet);
pause(pre_quiet);

% stimulate on all channels
xippmex('stimseq', cmd);
fprintf('Stimulating for %.1f s\n', stimTime)
pause(stimTime); %pause to let stimulation finish

% post stim time
fprintf('Quiet recording for %.1f s\n', post_quiet);
pause(post_quiet);

xippmex('trial', 'stopped');




