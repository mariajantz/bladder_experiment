function [] = single_amp_stim_combined(C, stimChan, cathAmp, freq, fpath)
% This differs from single_amp_stim in that it is designed to do
% stimulation on two headstages, not just one
% C = experiment constants struct for a given animal
% input channel (for multichannel input cathode first), amplitude and frequency chosen

[cmd, stimTime] = single_elec_stim_cmd(C, stimChan, cathAmp, freq); 

%opers = xippmex('opers'); 

% trigger recording
%xippmex('trial', 'recording', [], ceil(stimTime+2*C.QUIET_REC)); %remote control

recTime = ceil(stimTime+2*C.QUIET_REC); 
a = tic; 
%new option without auto stop to avoid errors
xippmex('trial', 'recording', fpath, 0, 1); 

% xippmex('trial', opers, 'recording'); 
%xippmex('digout', C.DIG_TRIGGER_CHAN, 1); %digital triggering
%pause(0.5)

% quiet recording
fprintf('Quiet recording for %.1f s\n', C.QUIET_REC); 
pause(C.QUIET_REC); 
% stimulate on all channels
xippmex('stimseq', cmd);
fprintf('Stimulating for %.1f s\n', stimTime)
pause(stimTime); %pause to let stimulation finish

% quiet recording again
fprintf('Quiet recording for %.1f s\n', C.QUIET_REC); 
pause(C.QUIET_REC);

%added to get rid of auto stop
xippmex('trial', 'stopped');

b = toc(a)-0.5; %give time to let recording save 
if b<recTime
    pause(recTime-b)
end

xippstatus = xippmex('trial'); 
if ~strcmp(xippstatus.status, 'stopped')
    warning('Long pause time')
    xippmex('trial', 'stopped');
    pause(2); 
end

% xippmex('trial', opers, 'stopped'); 
%xippmex('digout', C.DIG_TRIGGER_CHAN, 0); % digital triggering
%pause(0.5)
% TODO test whether this works, and whether it would work to just set the
% value of total wait time above in initial recording trigger. Also, is it
% necessary to have a wait time in here before I try to load any files? 
%xippmex('trial', opers, 'stopped');

