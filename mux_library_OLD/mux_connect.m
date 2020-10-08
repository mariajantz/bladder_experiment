function rch_list = mux_connect(me_list)
 global MUXID
 if MUXID == 2 | MUXID == 3
    [rch_list, m] = assign_me_to_rch(me_list, MUXID);
    if length(rch_list)==0
         disp('no action take')
    else
        mux_switch(me_list, m)
        disp('command sent')
    end
    
 else
     disp('MUXID global variable not set correctly; run mux_startup(MUXID) first; MUXID=2 OR 3')
 end 
 
end



%% internal functions
function sendByte(in_byte)
xippmex('digout',5, bitand(in_byte, hex2dec('ff'))); % 8-bit data on D8 to D1
pause(0.1)
xippmex('digout',5,256 + bitand(in_byte, hex2dec('ff'))); % rising edge clk signal on D9
pause(0.1)
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

function [rch_list,mux_sw] = assign_me_to_rch(me_list, mux_id)
%assign Micro-leads electrode (me) list to Ripple stim channel list (rch)
%   input electrode numbers (a list length <= 3)
%   output corresponding ripple stim channel numbers
%   note that me is 0-indexed 0 to 63; whereas rch is 1-indexed

% turn mux 0-indexed s-ch to Ripple 1-indexed channel numbers
rch_list = [];
mux_sw = [];

if mux_id == 2
    dict = [[0,9];[6,8];[10,11];[14,5];[6,7];[9,11];[12,8];[13,9];[15,9];[5,7];[0,2];[4,11];[3,10];[0,10];[1,11];[1,3];[2,7];[7,9];[2,9];[1,10];[14,8];[13,6];[12,3];[14,3];[4,6];[5,8];[2,10];[6,9];[13,8];[4,10];[6,10];[7,8];[12,6];[3,7];[3,4];[1,5];[4,7];[5,6];[1,4];[2,11];[5,11];[0,11];[3,11];[0,4];[0,7];[8,9];[1,7];[8,10];[6,11];[7,10];[0,5];[2,4];[5,10];[7,11];[5,9];[4,8];[15,8];[4,9];[15,6];[15,5];[4,5];[14,6];[13,2];[12,1]]+1;
elseif mux_id == 3
    dict = [[0,7];[4,10];[14,8];[12,3];[14,3];[5,8];[6,10];[8,10];[5,11];[4,11];[5,7];[12,6];[15,5];[4,5];[5,6];[2,7];[1,11];[0,11];[6,11];[1,10];[0,9];[15,9];[13,6];[4,6];[7,9];[13,9];[2,10];[7,11];[3,10];[8,9];[1,7];[0,10];[7,10];[3,7];[0,5];[2,4];[4,7];[5,10];[2,9];[2,11];[3,4];[1,3];[3,11];[6,9];[5,9];[1,4];[0,4];[4,9];[13,8];[4,8];[0,2];[1,5];[15,8];[7,8];[6,8];[15,6];[14,6];[12,8];[10,11];[13,2];[12,1];[9,11];[14,5];[6,7]]+1;
else
    return 
end

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













