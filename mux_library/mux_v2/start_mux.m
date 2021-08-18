%function start_mux(ser)
function start_mux(ser)
% initialize MUX hardware over serial port
% Input
%  ser -- active serial port
%  
%    arguments
 %       ser 
  %      
  %  end
   fwrite(ser, [encode_cobs(MLMUX.FLAG_STARTUP) 0 MLMUX.SET_FLAG])
   % ser.write([encode_cobs(id) 0 MLMUX.START_MUX],'uint8')
end

