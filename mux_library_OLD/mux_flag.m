function mux_flag(flag)
sendByte(hex2dec('85')) % const SET_FLAG = $85
sendByte(flag)  
sendByte(hex2dec('ff')) % end_of_cmd
disp('command sent')
end