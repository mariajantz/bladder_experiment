function switch_mux(ser,arr)
% send command string to ML MUX controller box over the active serial port
%  ser -- active serial port
%  arr -- MUX command bytes = [length, e-cell, 1-or-2, e-cell, 1-or-2, ...]

    fwrite(ser, [encode_cobs([length(arr) arr]) 0 MLMUX.SWITCH_MUX]);
    %ser.write(encode_cobs([length(arr) arr 0 MLMUX.SWITCH_MUX]),'uint8')
end

