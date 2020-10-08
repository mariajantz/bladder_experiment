%function start_mux(ser, id)
function start_mux(ser)
% initialize MUX hardware over serial port
% Input
%  ser -- active serial port
%  id -- MUX device ID (default = 2)
%    arguments
 %       ser 
  %      id = MLMUX.MUX_ID 
  %  end
   fwrite(ser, [encode_cobs(MLMUX.MUX_ID) 0 MLMUX.START_MUX])
   % ser.write([encode_cobs(id) 0 MLMUX.START_MUX],'uint8')
end

