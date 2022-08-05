function catheter_data = parse_serial(str)
    % Example string: 011815760H36201C35896V15657P2510B15657Q21T
% Delimiter Definition Unit Max value Min value UroMOCA ColoMOCA Conversion Value for the example
% 
% H Time stamp starts from when the ChataMOCA turns ons. Format Hr:Min:Sec:ms SAME SAME e.g. 011815760 : Hr : 01; Min: 18; Sec: 15; ms: 760; 011815760
% 
% C Conductivity values AU ~65000 0 when no current SAME SAME Value in volts = AU/ 19480 36201
% 
% V Conductance value AU ~65000 0 when no current SAME SAME Value in volts = AU/ 19480 35896
% 
% P Pressure value 1 AU ~15000 PRESSURE FRONT PRESSURE Value in cmH2O = (AU/16.98)-935.87 15657
% 
% B Battery value AU ~65000 SAME SAME Battery in Volts = 1.5*1023/AU 2510
% 
% Q Pressure value 2 AU ~15000 SAME AS PRESSURE VALUE 1 TAIL PRESSURE Value in cmH2O = (AU/16.98)-935.87 15657
% 
% T Third electrode value AU ~65000 TIMER 0 - 29 THIRD ELECTRODE VALUE Value in volts = AU/ 19480 21
        
    catheter_data = struct('SerialStr', '', 'TimeStamp', struct('HH', 0, 'MM', 0, 'SS', 0, 'ms', 0, 'datetime', ''), ...
        'Conductivity', 0, 'Conductance', 0, 'Pressure1', 0, 'Battery', 0, 'Pressure2', 0, 'Third', 0);
    catheter_data.SerialStr = str;
       
    splitStr = split(str,["H","C","V","P","B","Q","T"]); % split according to documentation
    if length(splitStr) < 8
        return; % don't fill in anything if the string was the wrong format, i.e. could be an error/status message.
    end
  
    
    catheter_data.TimeStamp.HH = str2double(splitStr{1}(1:2));
    catheter_data.TimeStamp.MM = str2double(splitStr{1}(3:4));
    catheter_data.TimeStamp.SS = str2double(splitStr{1}(5:6));
    catheter_data.TimeStamp.ms = str2double(splitStr{1}(7:9));
    catheter_data.TimeStamp.datetime = TimeStamp2datetime(splitStr{1});
    catheter_data.Conductivity = str2double(splitStr{2}) / 19480; % value in volts
    catheter_data.Conductance = str2double(splitStr{3}) / 19480; % value in volts
    catheter_data.Pressure1 = 0.735559*((str2double(splitStr{4})/ 16.98) - 935.87); % value in mmHg  
    % catheter_data.Battery = (1.5 * 1023) / str2double(splitStr{5});% battery value in volts

    % Convert to binary to get rid of device ID number; "take lower 10 bits"
    bin = dec2bin(str2double(splitStr{5}));
%     n_leading_zeros = 16 - length(bin);
%     bin = [repmat('0', 1, n_leading_zeros) bin];
    if length(bin) >= 10
        truncated_bin = bin2dec(bin(3:end));
        catheter_data.Battery = (1.5 * 1023) / truncated_bin;% battery value in volts
    else
        msg = 'Error: insufficient length(bin)';
        disp(msg)
        catheter_data.Battery = NaN;
    end

    catheter_data.Pressure2 = 0.735559*((str2double(splitStr{6}) / 16.98) - 935.87); % value in mmHg (8/13 Dill calibration +51.2)
    % Does Pressure2 ever get used? 
    catheter_data.Third = str2double(splitStr{7}) / 19480; % value in volts
    
%     catheter_data.Conductivity.converted = catheter_data.Conductivity.raw / 19480; % value in volts
%     catheter_data.Conductance.converted = catheter_data.Conductance.raw / 19480; % value in volts
%     catheter_data.Pressure1.converted = (catheter_data.Pressure1.raw / 16.98) - 935.87; % value in cmH20
%     catheter_data.Battery.converted = (1.5 * 1023) / catheter_data.Battery.raw; % battery value in volts
%     catheter_data.Pressure2.converted = (catheter_data.Pressure2.raw / 16.98) - 935.87; % value in cmH20
%     catheter_data.Third.converted = catheter_data.Third.raw / 19480; % value in volts
    
end

function dt = TimeStamp2datetime(str)
    dateformat_in = 'HHmmssSSS';
%     dateformat_out = 'HH:MM:SS.FFF';
    dt = datetime(str, 'InputFormat', dateformat_in);
end