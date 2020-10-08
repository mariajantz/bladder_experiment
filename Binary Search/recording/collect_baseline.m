function baseline_wf = collect_baseline(C, recTime, fpath)
% trigger recording of baseline data, extract traces for nerve cuff
% channels
% inputs: experiment constants struct, length of time to quiet record, and
% the full filepath (including "datafile0001" or whatever ending is chosen,
% with 4 digits at the end) where the data will be saved

fprintf('Quiet recording for %0.1f seconds\n', recTime); 

% xippmex('digout', C.DIG_TRIGGER_CHAN, 1);
% pause(0.5)
% opers = xippmex('opers');
%xippmex('trial', 'recording', [], ceil(recTime)+1); 

% xippmex('trial', 'recording', fpath(1:end-4), 0, 1, [], 148); %use this
% version for TCP
xippmex('trial', 'recording', fpath(1:end-4), 0, 1); 
pause(ceil(recTime)+1); 

xippmex('trial', 'stopped'); 

% xippmex('digout', C.DIG_TRIGGER_CHAN, 0);
pause(0.7)

xippStatus = xippmex('trial'); 
disp(xippStatus.status); 

baseline_wf = load_baseline(C, fpath); 