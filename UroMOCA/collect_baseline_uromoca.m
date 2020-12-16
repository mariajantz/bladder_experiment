function baseline_wf = collect_baseline_uromoca(C, recTime, fpath, s, session, ao_scale)
% trigger recording of baseline data, extract traces for nerve cuff
% channels
% inputs: experiment constants struct, length of time to quiet record, and
% the full filepath (including "datafile0001" or whatever ending is chosen,
% with 4 digits at the end) where the data will be saved
% s - serial object, session - daq session

fprintf('Quiet recording for %0.1f seconds\n', recTime); 

% xippmex('digout', C.DIG_TRIGGER_CHAN, 1);
% pause(0.5)
% opers = xippmex('opers');
%xippmex('trial', 'recording', [], ceil(recTime)+1); 

% xippmex('trial', 'recording', fpath(1:end-4), 0, 1, [], 148); %use this
% version for TCP
xippmex('trial', 'recording', fpath(1:end-4), 0, 1); 

tempTime = tic; 

while toc(tempTime)<(ceil(recTime)+1)
    while s.BytesAvailable > 0

        str = fscanf(s, '%s');
%         disp(str);
        pstr = parse_serial(str);

%         datalog{i} = pstr.Pressure1;
        if ~isempty(pstr.TimeStamp.datetime)
            fprintf('[%s] Pressure: %0.2f,  Volume: %0.2f, Battery: %0.2f, Timestamp: %s\n', ...
                datestr(now, 'HH:MM:SS.FFF AM'), pstr.Pressure1, pstr.Conductance, pstr.Battery, datestr(pstr.TimeStamp.datetime, 'HH:MM:SS.FFF'));
            
            analog_out(session, [pstr.Pressure1, pstr.Conductance], ao_scale); % output the analog waveform
        else
            fprintf('[%s] %s\n', datestr(now, 'HH:MM:SS.FFF AM'), pstr.SerialStr);
            
            analog_out(session, [-10, -10], 1); % output -10V as the analog waveform
        end
    end
    pause(.01);
end

%pause(ceil(recTime)+1); 

xippmex('trial', 'stopped'); 

% xippmex('digout', C.DIG_TRIGGER_CHAN, 0);
outputSingleScan(session, [0,0]);
pause(0.7)


xippStatus = xippmex('trial'); 
disp(xippStatus.status); 

baseline_wf = load_baseline(C, fpath); 