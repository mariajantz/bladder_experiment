function mux_startup(mux_id)
global MUXID
MUXID = mux_id;
sendByte(hex2dec('95')) % const START_MUX = $95
sendByte(mux_id) % MUX_ID = 2 or 3
sendByte(hex2dec('ff')) % end_of_cmd
disp('command sent; check LED')
end

function sendByte(in_byte)
xippmex('digout',5, bitand(in_byte, hex2dec('ff'))); % 8-bit data on D8 to D1
pause(0.1)
xippmex('digout',5,256 + bitand(in_byte, hex2dec('ff'))); % rising edge clk signal on D9
pause(0.1)
end