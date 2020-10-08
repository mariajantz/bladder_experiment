function C = experiment_constants_Fuggles
% =========================================================================
% ANIMAL AND HEADSTAGE BACKGROUND
% =========================================================================
C.CAT_NAME            = 'Fuggles';   % Animal name
C.STIMULATOR_TYPE     = 'Grapevine';
C.ARRAY_TYPE          = 'ripple';       % Brand of array, ie 'MicroLeads', 'Ripple'
C.LOCATION            = 'Epidural - S1';     % Options: 'DRG - S1', 'Epidural - L6', etc
% C.ELECTRODE_DIM       = [4 4];          % 4x4, 4x8, etc - first dimension is electrodes 1, 2, 3...
C.REC_HEADSTAGE       = 'surfs2_raw';   % surfs2_raw/surfs_raw/surfd_raw/nano2_raw/nano_raw
C.REC_HEADSTAGE_LOC   = 'B1';            % Trellis value of recording headstage, usually 'A'
C.STIM_HEADSTAGE      = 'nano2+stim';   
C.STIM_HEADSTAGE_LOC  = 'A';           % Trellis value of stim headstage, options 'B1'/'B2'/'B3'
C.REC_FS              = 30e3;           % recording at 30k Hz

% Switch channels to match location of the stimulation headstage
chanOrder             = {1:32, 129:160, 161:192, 193:224}; 
stimLocation          = {'A', 'B1', 'B2', 'B3'}; 
C.ACTIVE_CHAN         = chanOrder{ismember(stimLocation, C.STIM_HEADSTAGE_LOC)};

C.LAYOUT_MAP          = ([1:8;9:16;17:24]);
% =========================================================================
% STIMULATION PARAMETERS 
% =========================================================================
C.MAX_AMP             = 1500;            % maximum amplitude stimulation on cathode in uA
C.MAX_AMP_REPS        = 50;             % number of pulses applied in a high amplitude survey trial       
C.THRESH_REPS         = 320;            % number of pulses applied in full data collection trials
C.STIM_FREQUENCY      = [20 100];       % first (low) freq used for high amp survey to capture 
%long latency responses, high freq is maximum value that can be applied
C.DIG_TRIGGER_CHAN    = 2;              % if using digital triggering, set this channel number
C.STIM_PW_MS          = 0.2;                  % pulse width, in ms - currently cathode and anode
%are applied with equal pulse widths
C.STIM_POLARITY       = 0;              % 1 - positive phase first **NOTE this is not currently doing anything

% choose the channels (monopolar or multipolar) to stim - format as a cell,
% either nx1 for monopolar or nx2 for multipolar with all anodes in second
% column. Index starting at 1; code will auto add active channel number

% ----------------------choose the channels (monopolar or multipolar) to stim --------------------------------
%-------------------------------------------------------------------------------------------------------------
% C.STIM_MAP = num2cell([1:24])';        %MONOPOLAR
%------------------------------------------------------------------------------------------------------------- 
% C.STIM_MAP            = num2cell([[1  4:7 9:15 17:19]' [[1  4:7 9:15 17:19] + 1]']); %BIPOLAR HORIZONTAL
% C.STIM_MAP            = num2cell([[2 4:6 9:14 17:18 20]' [[2 4:6 9:14 17:18 20] + 2]']);
%-------------------------------------------------------------------------------------------------------------
% C.STIM_MAP            = num2cell([[1 2 4:12 14 16]' [[1 2 4:12 14 16] + 8]']); %BIPOLAR VERTICAL
%-------------------------------------------------------------------------------------------------------------
C.STIM_MAP   = sortrows({9 [1 17]; 10 [2 18]; 12 [4 20]; 14 [6 22]; 16 [8 24]},1);  %TRIPOLAR VERTICAL
% C.STIM_MAP   = sortrows({5 [4 6]; 6 [5 7]; 7 [6 8]; 10 [9 11]; ...
% 11 [10 12]; 12 [11 13]; 13 [12 14]; 14 [13 15]; 15 [14 16]; 18 [17 19]; ...
% 19 [18 20]},1); % TRIPOLAR HORIZONTAL
%-------------------------------------------------------------------------------------------------------------
C.QUIET_REC           = 0.5;            % quiet recording duration before and after stim train, in seconds
% make sure stim array is vertical
if size(C.STIM_MAP, 2)>size(C.STIM_MAP, 1)
    warning('Stimulation map array had incorrect dimensions, attempting to auto-correct.'); 
    C.STIM_MAP = C.STIM_MAP'; 
end
% =========================================================================
% ANALYSIS PARAMETERS 
% =========================================================================
C.AMP_MIN_DIFF = 10; % uA; this determines step size in binary search 
C.AMP_MAX_DIFF = 100; 
C.PRE_WINDOW = 1; % ms; sets the amount of time prior to stimulation in window
% C.SLIDING_WINDOW_DURATION  = 250e-6;
% C.SLIDING_WINDOW_STEP      = 25e-6;
C.RMS_THRESHOLD_MULTIPLIER = 4; %how high above threshold must something be to register as a response
C.MIN_RESPONSE_LATENCY     = 1e-3; %has to be > PWcath+PWanode+IPI (default IPI 66us)

% =========================================================================
% NERVE CUFF PARAMETERS
% =========================================================================

% channel maps for bipolar nerve cuffs: remember to zero-index them. 
bipolar_cuff_mapping = { ...  
        [0 1] 'Pelv'
        [2 3] 'Pudendal'
        [4 5] 'Sens Branch'
        [6 7] 'Deep Per'
        [8 9] 'Caud Rect'
        [10 11]  'Sci Prox' 
};

tripolar_cuff_mapping    = { ...
%     [10 11]  'Sciatic Proximal' 
      [12 13]  'Sciatic Distal' 
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
