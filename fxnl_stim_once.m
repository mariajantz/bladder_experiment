C = experiment_constants_Janus;

%pns_amp = 100; 

stimChan = [[8 16 24 32]-1];
amp = 10;
freq = 33;
bladder_fill_ml = '10'; 
stimTime = 10;
C.THRESH_REPS = stimTime*freq;

[curFile, ~] = find_curFile(datapath, 'testing', 0, 'datafiles', []);

% %[cmd, stimTime] = single_elec_stim_cmd(C, stimChan, amp, freq); %multipolar stim
[cmd, stimTime] = single_amp_cathodal_stim(C, stimChan, amp, freq); %multichannel stim
% 
% %do stuff for peripheral stim
% C.STIM_HEADSTAGE_LOC = 'D'; %which port nerve cuff board goes into
% 
% % Switch channels to match location of the stimulation headstage
% chanOrder             = {1:32, 129:160, 161:192, 193:224, 129:224, 385:416};
% stimLocation          = {'A', 'B1', 'B2', 'B3', 'B123', 'D'};
% C.ACTIVE_CHAN         = chanOrder{ismember(stimLocation, C.STIM_HEADSTAGE_LOC)};
% C.QUIET_REC           = 10; %seconds before and after stim
% 
% [cmd2, stimTime2] = single_amp_cathodal_stim(C, [3 4], pns_amp, freq);
% 
% cmd = [cmd cmd2];
%add the number of repeats necessary
totalTime = ceil(stimTime * repeats + pre_quiet + post_quiet);

% stimulate on all channels
xippmex('stimseq', cmd);
fprintf('Stimulating for %.1f s\n', stimTime)
pause(stimTime); %pause to let stimulation finish

% post stim time
% fprintf('Quiet recording for %.1f s\n', post_quiet);
% pause(post_quiet);

filenums = curFile;
save(sprintf('%sstimSCalone%04d', savepath, curFile), 'stimChan', 'amp', 'freq', 'C', 'interstim_time',...
    'repeats', 'filenums', 'curFile', 'pre_quiet', 'post_quiet', 'cmd', 'bladder_fill_ml');