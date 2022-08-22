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
        MUX_ID_2 = [1 1 9 5 22; 9 6 18 11 22; 0 1 7 8 8; 5 6 8 9 10; 0 1 7 8 22; 0 10 7 9 22; 0 1 11 8 22; 1 8 5 8 11; 6 5 6 10 22; 0 8 11 8 22; 1 11 18 22 22; 1 1 8 22 22; 6 11 18 8 22; 1 6 8 9 10; 1 5 8 9 11; 1 5 9 10 7; 0 5 7 11 18; 0 1 8 10 18; 0 1 7 5 18; 0 9 5 9 22; 0 1 5 9 11; 0 1 7 6 8; 9 10 9 18 22; 7 11 7 8 11; 0 6 10 5 18; 8 10 18 11 22; 5 6 8 5 8; 1 7 8 10 7; 7 6 9 18 22; 1 1 11 8 10; 6 10 6 18 8; 0 5 6 9 18; 0 1 11 18 22; 9 10 6 7 10; 0 1 10 6 18; 6 5 6 8 18; 1 5 10 18 11; 5 6 11 7 9; 1 1 6 11 5; 1 5 11 5 10; 1 7 18 11 22; 0 1 0 8 7; 10 7 10 11 22; 0 11 6 18 22; 0 1 7 9 18; 0 10 7 18 22; 11 8 10 18 11; 1 6 7 10 5; 7 9 10 18 11; 1 6 8 8 18; 0 7 8 9 8; 1 6 8 9 18; 0 1 9 9 22; 0 1 8 6 18; 1 9 7 18 22; 9 7 8 10 22; 1 5 10 11 8; 1 1 6 9 8; 0 1 8 9 10; 0 5 7 8 8; 1 1 5 18 22; 7 11 6 11 8; 0 8 8 22 22; 1 5 6 5 9; 0 10 8 10 22];
        RIPPLE = [15,16,NaN,NaN,NaN,13,9,4,10,6,12,11,NaN,NaN,NaN,NaN,NaN,NaN,8,NaN,NaN,NaN,14,NaN]; % Ripple stimultor channel #
    end
    
    
end

