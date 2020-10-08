function sendByte(in_byte)
xippmex('digout',5, bitand(in_byte, hex2dec('ff'))); % 8-bit data on D8 to D1
pause(0.1)
xippmex('digout',5,256 + bitand(in_byte, hex2dec('ff'))); % rising edge clk signal on D9
pause(0.1)
end