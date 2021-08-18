function [e,ripple] = read_mux(ser)
e = [];
ripple = [];
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
fwrite(ser, [MLMUX.QUERY_MUX])
pause(1)
tmp = fread(ser,ser.BytesAvailable);
if tmp(1) == 1 && length(tmp)==26
   tmp = tmp(2:26); 
   for i = 1:3:24
       out((i-1)/3*8+1) = bitshift(tmp(i),-5);
       out((i-1)/3*8+2) = bitand(bitshift(tmp(i),-2),7);
       out((i-1)/3*8+3) = bitand(tmp(i),3)*2 + bitand(bitshift(tmp(i+1),-7),1);
       out((i-1)/3*8+4) = bitand(bitshift(tmp(i+1),-4),7);
       out((i-1)/3*8+5) = bitand(bitshift(tmp(i+1),-1),7);
       out((i-1)/3*8+6) = bitand(tmp(i+1),1)*4 + bitand(bitshift(tmp(i+2),-6),3);
       out((i-1)/3*8+7) = bitand(bitshift(tmp(i+2),-3),7);
       out((i-1)/3*8+8) = bitand(tmp(i+2),7);
   end
   out(65) = bitand(bitshift(tmp(25),5),7);
   for i = 1:65
       if out(i) ~= 0
           e = [e i-1];
           switch out(i)
               case 4
                   ripple = [ripple MLMUX.RIPPLE(1+MLMUX.MUX_ID_2(i,1))];
               case 6
                   ripple = [ripple MLMUX.RIPPLE(1+MLMUX.MUX_ID_2(i,3))];  
               case 1
                   ripple = [ripple MLMUX.RIPPLE(1+MLMUX.MUX_ID_2(i,4))];
               case 3
                   ripple = [ripple MLMUX.RIPPLE(1+MLMUX.MUX_ID_2(i,6))];                    
               otherwise                 
                   ripple = [ripple MLMUX.RIPPLE(1+MLMUX.MUX_ID_2(i,out(i)))];
           end
       end
   end

end

