function ver = read_ver(ser)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    fwrite(ser, [MLMUX.FIRMWARE_VER]);
    pause(0.1)
    ver = fread(ser,ser.BytesAvailable);

end

