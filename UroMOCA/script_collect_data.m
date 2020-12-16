% Serial Port
% fclose(instrfind);
% delete(instrfind);
s = serial('COM5','BaudRate',9600);

% DAQ
daq_ch_pressure = 0;
daq_ch_volume = 1;
ao_sr = 100; % DAQ output sampling rate Hz
ao_scale = 10; %.1 V/unit = 10 = 1/10 (invert scale factor)
d = daq.getDevices;
if ~isempty(d)
    dev = d.ID;
    session = daq.createSession('ni');
    addAnalogOutputChannel(session, dev, daq_ch_pressure, 'Voltage');% adds a channel
    addAnalogOutputChannel(session, dev, daq_ch_volume, 'Voltage');% adds a channel
    % send control signal to set voltage to 0, prior to switching to Current Mode
    outputSingleScan(session,[0,0]);
    session.IsContinuous = true;
    session.Rate = ao_sr;
else
    obj = [];
    error('DAQ device not found');
end
            
            
% nsamp = 300;

% Log file
fname = ['datalog-' datestr(now, 'yymmdd-HHMMSS') '.txt'];
fID = fopen(fname, 'wt');

% Open a figure window that user can close to quit this read loop
fh = figure('Name', 'Close to stop reading serial data stream.', 'NumberTitle','off');

fprintf('Analog output scaling is %0.1f Volts/unit of measurement.\n', 1/ao_scale);
fprintf(fID, 'Analog output scaling is %0.1f Volts/unit of measurement.\n', 1/ao_scale); % write to file


fopen(s);
% tic;
while ishandle(fh)
    while s.BytesAvailable > 0

        str = fscanf(s, '%s');
%         disp(str);
        pstr = parse_serial(str);

%         datalog{i} = pstr.Pressure1;
        if ~isempty(pstr.TimeStamp.datetime)
            fprintf('[%s] Pressure: %0.2f,  Volume: %0.2f, Battery: %0.2f, Timestamp: %s\n', ...
                datestr(now, 'HH:MM:SS.FFF AM'), pstr.Pressure1, pstr.Conductance, pstr.Battery, datestr(pstr.TimeStamp.datetime, 'HH:MM:SS.FFF'));
            fprintf(fID, '[%s] Pressure: %0.2f,  Volume: %0.2f, Battery: %0.2f, Timestamp: %s\n', ... % write to file
                datestr(now, 'HH:MM:SS.FFF AM'), pstr.Pressure1, pstr.Conductance, pstr.Battery, datestr(pstr.TimeStamp.datetime, 'HH:MM:SS.FFF')); 
            
            analog_out(session, [pstr.Pressure1, pstr.Conductance], ao_scale); % output the analog waveform
        else
            fprintf('[%s] %s\n', datestr(now, 'HH:MM:SS.FFF AM'), pstr.SerialStr);
            fprintf(fID, '[%s] %s\n', datestr(now, 'HH:MM:SS.FFF AM'), pstr.SerialStr); % write to file
            
            analog_out(session, [-10, -10], 1); % output -10V as the analog waveform
        end
    end
    pause(.01);
end

outputSingleScan(session, [0,0]);
session.stop;

fclose(s);
delete(s);

fclose(fID);