function C = experiment_constants_Laertes
% =========================================================================
% ANIMAL AND HEADSTAGE BACKGROUND
% =========================================================================
C.CAT_NAME            = 'Laertes';   % Animal name
C.STIMULATOR_TYPE     = 'Grapevine';
%C.ARRAY_TYPE          = 'Rootlet Cuffs, Peripheral nerve stim';       % Brand of array, ie 'MicroLeads', 'Ripple', 'Blackrock'
C.ARRAY_TYPE          = 'Rootlet Cuffs';
C.LOCATION            = 'Rootlet - S1_S2_S3_L7_Ventral_rootlets';     % Options: 'DRG - S1', 'Epidural - L6', etc
% C.ELECTRODE_DIM       = [4 4];          % 4x4, 4x8, etc - first dimension is electrodes 1, 2, 3...
C.REC_HEADSTAGE       = 'surfs2_raw';   % surfs2_raw/surfs_raw/surfd_raw/nano2_raw/nano_raw
C.REC_HEADSTAGE_LOC   = 'A';            % Trellis value of recording headstage, usually 'A'
C.STIM_HEADSTAGE      = 'nano2+stim';   
C.STIM_HEADSTAGE_LOC  = 'B1';           % Trellis value of stim headstage, options 'B1'/'B2'/'B3'
C.HIGHAMP_HEADSTAGE_LOC = '';         % if using two headstages to stimulate, include this - otherwise, leave as empty string ''
C.REC_FS              = 30e3;           % recording at 30k Hz
C.ANALOG_CHAN         = {'Bladder'}; 
C.TEST_TYPE           = 'Isoflurane'; % 'Behaving', 'Dex', 'Alpha Chloralose'

% Switch channels to match location of the stimulation headstage
chanOrder             = {1:32, 129:160, 161:192, 193:224, 129:224, 385:416}; 
stimLocation          = {'A', 'B1', 'B2', 'B3', 'B123', 'D'};
C.ACTIVE_CHAN         = chanOrder{ismember(stimLocation, C.STIM_HEADSTAGE_LOC)};
C.HIGHAMP_ACTIVE_CHAN = [chanOrder{ismember(stimLocation, C.HIGHAMP_HEADSTAGE_LOC)}]; %this is empty if the high amp headstage loc variable is empty

% C.LAYOUT_MAP          = ([1:2:12; 2:2:12]);   %RITESH: change this value according to how many hooks/cuffs will be tested in each root
 C.LAYOUT_MAP          = ([1:2:8; 2:2:8]);
%C.LAYOUT_MAP          = ([1;2]);
%EXAMPLE: 
%If connecting 5 channels, all bipolar, where channels 1-2 are a pair, 3-4, and so on, use: [1:2:10; 2:2:10]
%Then stimulate using this map:
%  C.STIM_MAP            = num2cell([1:6; 7:12]'); % this sets up the pairs
 C.STIM_MAP            = num2cell([1:4; 5:8]');
%C.STIM_MAP            = num2cell([1;2]');

% =========================================================================
% STIMULATION PARAMETERS 
% =========================================================================
C.MAX_AMP             = 600;            % maximum amplitude stimulation on cathode in uA RITESH
C.MAX_AMP_REPS        = 50;             % number of pulses applied in a high amplitude survey trial       
C.THRESH_REPS         = 320;            % number of pulses applied in full data collection trials
C.STIM_FREQUENCY      = [20 100];       % first (low) freq used for high amp survey to capture 
%long latency responses, high freq is maximum value that can be applied
C.DIG_TRIGGER_CHAN    = 0;              % if using digital triggering looped back, set this channel number; otherwise use 0
C.STIM_PW_MS          = 0.2;            % pulse width, in ms - currently cathode and anode
%are applied with equal pulse widths
C.STIM_POLARITY       = 0;              % 1 - positive phase first

if any(C.STIM_FREQUENCY(1) == [20 30 60 90 120 180])
    C.STIM_FREQUENCY(1) = C.STIM_FREQUENCY(1) - 1; %remove harmonics of 60 Hz
end

% choose the channels (monopolar or multipolar) to stim - format as a cell,
% either nx1 for monopolar or nx2 for multipolar with all anodes in second
% column. Index starting at 1; code will auto set active channel number
% Layout assumes numbers begin at 1 and increase across each row, for example: 
% 1 2 3 4
% 5 6 7 8
% this is then remapped onto the channel layout provided above

%====================================STIMULATION TYPES============================================
%Ripple (32 channel arrays)
%C.STIM_MAP = num2cell(1:32)'; % MONOPOLAR 
%-------------------------------------------------------------------------------------------------
% C.STIM_MAP            = num2cell([setdiff([1:31], [4:4:32]); setdiff(2:32, 1:4:29)]'); %BIPOLAR HORIZONTAL
%-------------------------------------------------------------------------------------------------
% C.STIM_MAP            = num2cell([1:28; 5:32]'); % BIPOLAR VERTICAL
%-------------------------------------------------------------------------------------------------
% a = [1:24]';           % TRIPOLAR (VERTICAL)
% C.STIM_MAP = mat2cell([a+4 a a+8], ones(length(a), 1), [1 2]);

%Microleads (24 channel arrays)
% C.STIM_MAP = num2cell([1:24])';        %MONOPOLAR
%-------------------------------------------------------------------------------------------------------------
% C.STIM_MAP            = num2cell([[1:7 9:15 17:23]' [[1:7 9:15 17:23] + 1]']); %BIPOLAR HORIZONTAL
% C.STIM_MAP            = num2cell([[2:6 9:14 17:22]' [[2 4:6 9:14 17:22] + 2]']); % BIPOLAR _WIDE HORIZONTAL
%-------------------------------------------------------------------------------------------------------------
% C.STIM_MAP            = num2cell([[1:16]' [[1:16] + 8]']); %BIPOLAR VERTICAL
%-------------------------------------------------------------------------------------------------------------
%  C.STIM_MAP   = sortrows({9 [1 17]; 10 [2 18]; 11 [3 19]; 12 [4 20]; 13 [5 21]; 14 [6 22]; 15 [7 23]; 16 [8 24]},1);  %TRIPOLAR VERTICAL
%-------------------------------------------------------------------------------------------------------------
%=================================================================================================

%Check if any channels are being excluded that shouldn't be (the tired
%person setup check)
if any(~ismember(unique([C.STIM_MAP{:}]), C.LAYOUT_MAP))
    warning('Are you deliberately excluding channels from the stimulation map?');
    keyboard; 
end

C.QUIET_REC           = 0.5;            % quiet recording duration before and after stim train, in seconds
% make sure stim array is vertical
if size(C.STIM_MAP, 2)>size(C.STIM_MAP, 1)
    warning('Stimulation map array had incorrect dimensions, attempting to auto-correct.'); 
    C.STIM_MAP = C.STIM_MAP'; 
end
%remap stimulation to put contacts in the right place
C.STIM_MAP = remap_stim(C.LAYOUT_MAP, C.STIM_MAP); 
% =========================================================================
% ANALYSIS PARAMETERS 
% =========================================================================
C.AMP_MIN_DIFF = 2; % uA; this determines step size in binary search RITESH - if you want finer selectivity steps change this value, it's uA between steps
C.AMP_MAX_DIFF = 20; 
C.PRE_WINDOW = 1; % ms; sets the amount of time prior to stimulation in window
% C.SLIDING_WINDOW_DURATION  = 250e-6;
% C.SLIDING_WINDOW_STEP      = 25e-6;
C.RMS_THRESHOLD_MULTIPLIER = 4; %how high above threshold must something be to register as a response
C.MIN_RESPONSE_LATENCY     = 1e-3; %has to be > PWcath+PWanode+IPI (default IPI 66us)

total_pulse_time = ceil((C.STIM_PW_MS*2+.066)*10)/10 * 1e-3; 
if total_pulse_time > C.MIN_RESPONSE_LATENCY
    C.MIN_RESPONSE_LATENCY = total_pulse_time; 
    warning('Resetting minimum response latency to be longer than pulse time')
end

% =========================================================================
% NERVE CUFF PARAMETERS
% =========================================================================

C.SEARCH_CUFFS_IDX = 1:7; 
% channel maps for bipolar nerve cuffs: remember to zero-index them. 
bipolar_cuff_mapping = { ...  
        [0 1] 'Pelv'
        [2 3] 'Pudendal'
        [4 5] 'Combined'
        [6 7] 'Deep Per'
        [8 9] 'Sensory'
        [10 11] 'Caudal Rectal'
        [12 13] 'Sciatic Prox'
};

tripolar_cuff_mapping    = { ...
      [15 16]  'Sciatic Distal' 
};

if strcmp(C.REC_HEADSTAGE, 'surfd_raw')
    if ( unique(cellfun(@(x) length(x), bipolar_cuff_mapping(:,1)))~=1 ...
        || unique(cellfun(@(x) length(x), tripolar_cuff_mapping(:,1)))~=1 )
        error('incorrect cuff mapping for surfD headstage')
    end
else
    if ( unique(cellfun(@(x) length(x), bipolar_cuff_mapping(:,1)))~=2 ...
        || unique(cellfun(@(x) length(x), tripolar_cuff_mapping(:,1)))~=2 )
        error('incorrect cuff mapping for surfS/nano2 headstage')
    end
end

C.TRIPOLAR.CUFF_CHANNELS   = tripolar_cuff_mapping(:,1)';
C.TRIPOLAR.CUFF_LABELS     = tripolar_cuff_mapping(:,2)';
C.BIPOLAR.CUFF_CHANNELS   = [bipolar_cuff_mapping(:,1)'];
C.BIPOLAR.CUFF_LABELS     = bipolar_cuff_mapping(:,2)';
C.NCUFF_FILTER_ARGS = {2, 300, 'high'}; %Args are input to Butterworth, then applied with filtfilt

end

