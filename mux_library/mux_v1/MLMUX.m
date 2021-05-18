%% Constants
% MUX driver CONSTANTS

classdef MLMUX
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant = true)
        MUX_ID = 2
        COBS_MAX = 41    
        SWITCH_MUX = hex2dec('90')
        START_MUX = hex2dec('95')
        MUX_ID_2 = reshape([[0 NaN] [6 6] [NaN 2] [13 4] [6 7] [NaN 2] [7 6] [13 NaN] [3 NaN] [4 7] [0 2] [4 2] [3 NaN] [0 NaN] [1 2] [1 3] [2 7] [7 NaN] [2 NaN] [1 NaN] [13 6] [13 6] [7 3] [13 3] [4 6] [4 6] [2 NaN] [6 NaN] [13 6] [4 NaN] [6 NaN] [7 6] [7 6] [3 7] [3 4] [1 4] [4 7] [4 6] [1 4] [2 2] [4 2] [0 2] [3 2] [0 4] [0 7] [6 NaN] [1 7] [6 NaN] [6 2] [7 NaN] [0 4] [2 4] [4 NaN] [7 2] [4 NaN] [4 6] [3 6] [4 NaN] [3 6] [3 4] [4 4] [13 6] [13 2] [7 1] [7 1]], [2,65])'
        RIPPLE = [9,7,5,1,15,NaN,3,11,NaN,NaN,NaN,NaN,NaN,13]; % Ripple stimultor channel #
    end
    
    
end

