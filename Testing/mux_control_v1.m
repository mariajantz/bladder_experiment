%% internal functions for mux control
function sendByte(in_byte)
xippmex('digout',5, bitand(in_byte, hex2dec('ff'))); % 8-bit data on D8 to D1
pause(0.1)
xippmex('digout',5,256 + bitand(in_byte, hex2dec('ff'))); % rising edge clk signal on D9
pause(0.1)
end


function mux_startup
sendByte(hex2dec('85')) % const SET_FLAG = $85
sendByte(25) % const FLAG_STARTUP = 25
sendByte(hex2dec('ff')) % end_of_cmd
disp('command sent; check LED')
end

function mux_flag(flag)
sendByte(hex2dec('85')) % const SET_FLAG = $85
sendByte(flag)  
sendByte(hex2dec('ff')) % end_of_cmd
disp('command sent')
end

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

function [rch_list,mux_sw] = assign_me_to_rch(me_list)
%assign Micro-leads electrode (me) list to Ripple stim channel list (rch)
%   input electrode numbers (a list length <= 3)
%   output corresponding ripple stim channel numbers
%   note that me is 0-indexed 0 to 63; whereas rch is 1-indexed

% turn mux 0-indexed s-ch to Ripple 1-indexed channel numbers
dict = [[0,9];[6,8];[10,11];[14,5];[6,7];[9,11];[12,8];[13,9];[15,9];[5,7];[0,2];[4,11];[3,10];[0,10];[1,11];[1,3];[2,7];[7,9];[2,9];[1,10];[14,8];[13,6];[12,3];[14,3];[4,6];[5,8];[2,10];[6,9];[13,8];[4,10];[6,10];[7,8];[12,6];[3,7];[3,4];[1,5];[4,7];[5,6];[1,4];[2,11];[5,11];[0,11];[3,11];[0,4];[0,7];[8,9];[1,7];[8,10];[6,11];[7,10];[0,5];[2,4];[5,10];[7,11];[5,9];[4,8];[15,8];[4,9];[15,6];[15,5];[4,5];[14,6];[13,2];[12,1]]+1;

rch_list = [];
mux_sw = [];
e_len = length(me_list);
if  e_len > 3
    disp("this function only works with input list length <= 3")
    
elseif e_len == 1
    rch_list = [dict(me_list(1)+1,1)];    % one electrode, direct lookup
    rch_list(rch_list==13)=1;
    rch_list(rch_list==14)=2;
    rch_list(rch_list==15)=3;
    rch_list(rch_list==16)=4;
    mux_sw = [1];
elseif e_len == 2
    [x, y] = meshgrid([1,2],[1,2]);
    p = [x(:) y(:)];
    for n=1:4
        rch_list = [dict(me_list(1)+1,p(n,1)), dict(me_list(2)+1,p(n,2))];
        rch_list(rch_list==13)=1;
        rch_list(rch_list==14)=2;
        rch_list(rch_list==15)=3;
        rch_list(rch_list==16)=4;
        mux_sw = p(n,:);
        if length(unique(rch_list))==2
            return
        else
            rch_list = [];
        end
    end
    
elseif e_len == 3
    [x, y, z] = meshgrid([1,2],[1,2],[1,2]);
    p = [x(:) y(:) z(:)];
    for n=1:8
        rch_list = [dict(me_list(1)+1,p(n,1)), dict(me_list(2)+1,p(n,2)),dict(me_list(3)+1,p(n,3))];
        rch_list(rch_list==13)=1;
        rch_list(rch_list==14)=2;
        rch_list(rch_list==15)=3;
        rch_list(rch_list==16)=4;
        mux_sw = p(n,:);
        if length(unique(rch_list))==3
            return
        else
            rch_list = [];
        end
    end
    
    
end

    
end

function rch_list = mux_connect(me_list)
 [rch_list, m] = assign_me_to_rch(me_list);
 if length(rch_list)==0
     disp('no action take')
 else
    mux_switch(me_list, m)
    disp('command sent')
 end
end










