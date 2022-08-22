function stop_mux(ser, level)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% level = 1; disconnect all E to stim input
% level = 2; remove power to the paddle

    fwrite(ser, [encode_cobs([level]) 0 MLMUX.EMG_STOP]);


end

