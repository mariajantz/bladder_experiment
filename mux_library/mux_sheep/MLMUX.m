%% Constants
% MUX driver CONSTANTS

classdef MLMUX
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant = true)
        SET_FLAG = hex2dec('85')
        FLAG_STARTUP = 25
        FLAG_MONITOR = 30
        FLAG_MONITOR_OFF = 31
        EMG_STOP = hex2dec('a5')
        QUERY_MUX = hex2dec('a6')
        FIRMWARE_VER = hex2dec('a7')
        COBS_MAX = 41    
        SWITCH_MUX = hex2dec('90')
        START_MUX = hex2dec('95')
        %MUX_ID_2 = reshape([[0 NaN] [6 6] [NaN 2] [13 4] [6 7] [NaN 2] [7 6] [13 NaN] [3 NaN] [4 7] [0 2] [4 2] [3 NaN] [0 NaN] [1 2] [1 3] [2 7] [7 NaN] [2 NaN] [1 NaN] [13 6] [13 6] [7 3] [13 3] [4 6] [4 6] [2 NaN] [6 NaN] [13 6] [4 NaN] [6 NaN] [7 6] [7 6] [3 7] [3 4] [1 4] [4 7] [4 6] [1 4] [2 2] [4 2] [0 2] [3 2] [0 4] [0 7] [6 NaN] [1 7] [6 NaN] [6 2] [7 NaN] [0 4] [2 4] [4 NaN] [7 2] [4 NaN] [4 6] [3 6] [4 NaN] [3 6] [3 4] [4 4] [13 6] [13 2] [7 1] [7 1]], [2,65])'
        %MUX_ID_2 = [1 1 9 5 22; 9 6 18 11 22; 0 1 7 8 8; 5 6 8 9 10; 0 1 7 8 22; 0 10 7 9 22; 0 1 11 8 22; 1 8 5 8 11; 6 5 6 10 22; 0 8 11 8 22; 1 11 18 22 22; 1 1 8 22 22; 6 11 18 8 22; 1 6 8 9 10; 1 5 8 9 11; 1 5 9 10 7; 0 5 7 11 18; 0 1 8 10 18; 0 1 7 5 18; 0 9 5 9 22; 0 1 5 9 11; 0 1 7 6 8; 9 10 9 18 22; 7 11 7 8 11; 0 6 10 5 18; 8 10 18 11 22; 5 6 8 5 8; 1 7 8 10 7; 7 6 9 18 22; 1 1 11 8 10; 6 10 6 18 8; 0 5 6 9 18; 0 1 11 18 22; 9 10 6 7 10; 0 1 10 6 18; 6 5 6 8 18; 1 5 10 18 11; 5 6 11 7 9; 1 1 6 11 5; 1 5 11 5 10; 1 7 18 11 22; 0 1 0 8 7; 10 7 10 11 22; 0 11 6 18 22; 0 1 7 9 18; 0 10 7 18 22; 11 8 10 18 11; 1 6 7 10 5; 7 9 10 18 11; 1 6 8 8 18; 0 7 8 9 8; 1 6 8 9 18; 0 1 9 9 22; 0 1 8 6 18; 1 9 7 18 22; 9 7 8 10 22; 1 5 10 11 8; 1 1 6 9 8; 0 1 8 9 10; 0 5 7 8 8; 1 1 5 18 22; 7 11 6 11 8; 0 8 8 22 22; 1 5 6 5 9; 0 10 8 10 22];
        %MUX_ID_2 = [1 4 9 12 22; 9 13 18 12 22; 0 4 7 15 8; 5 6 8 9 10; 0 1 7 8 23; 0 10 14 16 22; 0 1 11 8 22; 1 8 12 15 12; 6 12 13 9 23; 0 8 12 8 23; 1 11 18 22 23; 1 4 8 22 23; 6 11 19 8 22; 1 13 15 16 9; 1 12 15 16 12; 1 5 9 10 14; 0 5 7 11 19; 0 4 8 9 18; 0 4 7 12 19; 0 9 12 16 23; 0 4 5 9 12; 0 1 7 13 8; 9 10 16 18 23; 7 11 14 15 12; 0 6 10 12 19; 8 9 19 12 22; 5 6 8 12 8; 1 7 8 10 14; 7 13 16 18 23; 1 1 11 15 9; 6 10 13 18 8; 0 5 6 16 19; 0 4 11 18 22; 9 10 13 14 9; 0 4 10 13 18; 6 12 13 15 18; 1 5 9 19 12; 5 6 11 14 16; 1 4 6 11 12; 1 5 11 12 9; 1 7 19 12 23; 0 1 0 8 14; 10 14 9 12 23; 0 11 13 18 23; 0 4 14 16 18; 0 10 14 19 22; 11 15 9 19 12; 1 6 7 10 12; 7 9 9 19 12; 4 6 8 15 19; 0 7 8 9 15; 1 13 15 16 18; 0 4 9 16 23; 0 1 8 13 18; 1 9 14 19 22; 9 14 15 9 23; 1 5 10 11 8; 1 4 6 9 8; 0 4 8 16 9; 0 5 14 15 8; 1 1 5 18 22; 7 11 13 12 8; 0 8 8 22 23; 1 5 6 12 16; 0 10 15 9 22];

        MUX_ID_2 = [NaN NaN NaN 12 22; NaN 13 18 12 22; NaN NaN NaN NaN 8; NaN 6 8 NaN NaN; NaN NaN NaN 8 23; NaN NaN 14 16 22; NaN NaN 11 8 22; NaN 8 12 NaN 12; 6 12 13 NaN 23; NaN 8 12 8 23; NaN 11 18 22 23; NaN NaN 8 22 23; 6 11 19 8 22; NaN 13 NaN 16 NaN; NaN 12 NaN 16 12; NaN NaN NaN NaN 14; NaN NaN NaN 11 19; NaN NaN 8 NaN 18; NaN NaN NaN 12 19; NaN NaN 12 16 23; NaN NaN NaN NaN 12; NaN NaN NaN 13 8; NaN NaN 16 18 23; NaN 11 14 NaN 12; NaN 6 NaN 12 19; 8 NaN 19 12 22; NaN 6 8 12 8; NaN NaN 8 NaN 14; NaN 13 16 18 23; NaN NaN 11 NaN NaN; 6 NaN 13 18 8; NaN NaN 6 16 19; NaN NaN 11 18 22; NaN NaN 13 14 NaN; NaN NaN NaN 13 18; 6 12 13 NaN 18; NaN NaN NaN 19 12; NaN 6 11 14 16; NaN NaN 6 11 12; NaN NaN 11 12 NaN; NaN NaN 19 12 23; NaN NaN NaN 8 14; NaN 14 NaN 12 23; NaN 11 13 18 23; NaN NaN 14 16 18; NaN NaN 14 19 22; 11 NaN NaN 19 12; NaN 6 NaN NaN 12; NaN NaN NaN 19 12; NaN 6 8 NaN 19; NaN NaN 8 NaN NaN; NaN 13 NaN 16 18; NaN NaN NaN 16 23; NaN NaN 8 13 18; NaN NaN 14 19 22; NaN 14 NaN NaN 23; NaN NaN NaN 11 8; NaN NaN 6 NaN 8; NaN NaN 8 16 NaN; NaN NaN 14 NaN 8; NaN NaN NaN 18 22; NaN 11 13 12 8; NaN 8 8 22 23; NaN NaN 6 12 16; NaN NaN NaN NaN 22];



        %RIPPLE = [15,16,NaN,NaN,NaN,13,9,4,10,6,12,11,NaN,NaN,NaN,NaN,NaN,NaN,8,NaN,NaN,NaN,14,NaN]; % Ripple stimultor channel #
        RIPPLE = [9, 4, NaN, NaN, 6, 11, 13, 15, 8, 10, 12, 17, 19, 21, 23, 14, 16, NaN, 18, 24, NaN, NaN, 22, 20];
    end
    
    
end

