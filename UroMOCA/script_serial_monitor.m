
% Just read, parse, and display the serial port data stream

% Serial Port
s = serial('COM5','BaudRate',9600);
%to delete stuff: 
%delete(instrfindall)
%clear s
%then re-run

fopen(s);

% Open a figure window that user can close to quit this read loop
fh = figure('Name', 'Close to stop reading serial data stream.', 'NumberTitle','off');

while ishandle(fh)
    if s.BytesAvailable > 0

        str = fscanf(s, '%s');
    %         disp(str);
        pstr = parse_serial(str);

    %         datalog{i} = pstr.Pressure1;
        if ~isempty(pstr.TimeStamp.datetime)
            fprintf('[%s] %s -- Pressure: %0.2f,  Volume: %0.2f, Battery: %0.2f, Timestamp: %s\n', ...
                datestr(now, 'HH:MM:SS.FFF AM'), pstr.SerialStr, pstr.Pressure1, pstr.Conductance, pstr.Battery, datestr(pstr.TimeStamp.datetime, 'HH:MM:SS.FFF'));
        else
            fprintf('[%s] %s\n', datestr(now, 'HH:MM:SS.FFF AM'), pstr.SerialStr);
        end
    end
    pause(.01);
end


fclose(s);
delete(s);

