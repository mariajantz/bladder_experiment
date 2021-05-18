function mux_switch(me_list, mux_pos)
sendByte(hex2dec('90')) % const   SWITCH_MUX = $90
sendByte(length(me_list)*2)
for i=1:length(me_list)
    sendByte(me_list(i))
    sendByte(mux_pos(i))
end
sendByte(hex2dec('ff')) % end_of_cmd
disp('command sent')
end