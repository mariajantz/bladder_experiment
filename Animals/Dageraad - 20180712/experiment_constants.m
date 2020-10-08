function C = experiment_constants
% =========================================================================
% ANIMAL AND HEADSTAGE BACKGROUND
% =========================================================================
C.CAT_NAME            = 'Dageraad';
C.STIMULATOR_TYPE     = 'Grapevine';           
C.LOCATION            = 'Epidural - L6';     % Options: 'DRG - S1', 'Epidural - L6', etc
C.ELECTRODE_DIM       = [4 4];          % 4x4, 4x8, etc - first dimension is electrodes 1, 2, 3...
C.REC_HEADSTAGE       = 'surfs2_raw';   % surfs2_raw/surfs_raw/surfd_raw/nano2_raw/nano_raw
C.REC_HEADSTAGE_LOC   = 'A'; 
C.STIM_HEADSTAGE      = 'nano2+stim'; 
C.STIM_HEADSTAGE_LOC  = 'B1'; 
C.REC_FS              = 30e3; %recording at 30 Hz

chanOrder             = {129:160, 161:192, 193:224}; %switches channels a, b
stimLocation          = {'B1', 'B2', 'B3'}; 
C.ACTIVE_CHAN         = chanOrder{ismember(stimLocation, C.STIM_HEADSTAGE_LOC)};

% =========================================================================
% STIMULATION PARAMETERS 
% =========================================================================
C.MAX_AMP             = 1500;  % maximum amplitude stimulation on cathode in uA
C.MAX_AMP_REPS        = 50;  %number of times the stimulus is applied for high amp survey
C.THRESH_REPS         = 320; %number of times the stimulus is applied for thresholding
C.STIM_FREQUENCY      = [30 100]; %low freq used for high amp survey to capture 
%long latency responses, high freq is maximum that can be applied
C.DIG_TRIGGER_CHAN    = 2;   
C.STIM_PW_MS    = 0.2;       % pulse width, in ms - currently cathode and anode
%are applied with equal pulse widths
C.STIM_POLARITY       = 0;            % 1 - positive phase first

% choose the channels (monopolar or multipolar) to stim - format as a cell,
% either nx1 for monopolar or nx2 for multipolar with all anodes in second
% column. Index starting at 1; code will auto add active channel number
% example monopolar: mat2cell(1:16, 1, ones(16, 1))'
%C.STIM_MAP            = mat2cell(1:16, 1, ones(16, 1))'; %monopolar
%C.STIM_MAP             = generateElecMap([1 2]); %bipolar horizontal
%C.STIM_MAP            = {129 133; 130 134; 131 135; 132 136; 133 137; 134 138; ...
%                            135 139; 136 140; 137 141; 138 142; 139 143; 140 144}; %vertical pairs
%C.STIM_MAP = cellfun(@(x) x-128, C.STIM_MAP, 'UniformOutput', false);
C.STIM_MAP            = sortrows({5 [1 9]; 9 [5 13]; 6 [2 10]; 10 [6 14]; 7 [3 11]; 11 [7 15]; 8 [4 12]; 12 [8 16]}, 1); % choose the channels (monopolar or multipolar) to stim 
C.QUIET_REC           = 0.5; %quiet recording duration before and after stim train, in seconds
% make sure array is vertical
if size(C.STIM_MAP, 2)>size(C.STIM_MAP, 1)
    warning('Stimulation map array had incorrect dimensions, attempting to auto-correct.'); 
    C.STIM_MAP = C.STIM_MAP'; 
end
% =========================================================================
% ANALYSIS PARAMETERS 
% =========================================================================
C.AMP_MIN_DIFF = 20; %uA; this determines step size in binary search 
C.AMP_MAX_DIFF = 100;
C.PRE_WINDOW = 1; %ms; sets the amount of time prior to stimulation in window
% C.SLIDING_WINDOW_DURATION  = 250e-6;
% C.SLIDING_WINDOW_STEP      = 25e-6;
C.RMS_THRESHOLD_MULTIPLIER = 4;
C.MIN_RESPONSE_LATENCY     = 1e-3; %has to be > PWcath+PWanode+IPI (default IPI 66us)

% =========================================================================
% NERVE CUFF PARAMETERS
% =========================================================================

bipolar_cuff_mapping = { ...
        [0 1] 'Pelv'
        [2 3] 'Pudendal'
        [4 5] 'Sens Branch'
        [6 7] 'Caud Rect'
        [8 9] 'Deep Per'
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
