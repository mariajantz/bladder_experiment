function C = experiment_constants
C.CAT_NAME            = 'Cerberus';
C.STIMULATOR_TYPE     = 'grapevine';            % iz2/grapevine
C.BUFFER_TYPE         = 'ripple';               % ripple/xipprtma
headstage             = 'surfs2_raw';            % surfs2_raw/surfs_raw/surfd_raw/nano2_raw/nano_raw
C.DRG_LOCATION        = 'DRG - S1';             % DRG/VR L5/6/7 S1/2
C.ELECTRODE_TYPE      = 'Utah-Array-4x8';       % FMA-32Chan/Utah-Array-4x8/RippleSurfaceV3

C.AMPLITUDE_RANGE     = [0 50];                 % [min max] uA
C.STA_REPS_PER_SET        = 50;
C.THRESH_REPS_PER_SET     = 50;
C.SELECTIVTY_REPS_PER_SET = 50;

% =========================================================================
% STIMULATION PARAMETERS 
% =========================================================================
% C.REPS_PER_SET        = [150 175 275];
C.STIM_FREQUENCY      = 32;
C.FREQUENCY_RANGE     = [50 150];
C.STIM_EVENT_CHANNEL  = 2;
C.IRIG_CHANNEL        = 3;
C.MAX_CHANNELS        = 4;
C.EXTRACT_TIME_RANGE      =0.9/C.STIM_FREQUENCY;
% C.DEFAULT_FREQUENCY        = 20;

C.STIM_STEP = 1;    % nano2 step
C.STIM_MULTIPLIER = find([1,2,5,10,20] == C.STIM_STEP);  % stim res
C.STIM_CATH_DUR_MS = 0.2;       % ms
C.STIM_ANOD_DUR_MS = 0.4;       % ms
C.STIM_POLARITY = 1;            % 1 - cathodic first

% =========================================================================
% ANALYSIS PARAMETERS 
% =========================================================================
C.AMP_MIN_DIFF = 1;
C.SLIDING_WINDOW_DURATION  = 250e-6;
C.SLIDING_WINDOW_STEP      = 25e-6;
C.RMS_THRESHOLD_MULTIPLIER = 5;
C.MIN_RESPONSE_LATENCY     = 0.7e-3;
C.MAX_CV = 120;
C.MIN_CV = 30;

% =========================================================================
% TRIPOLAR PARAMETERS
% =========================================================================

% cuff_mapping    = { ...
%     [0 1] 'Femoral Proximal'
%     [2 3] 'Femoral Distal'
%     [4 5] 'Sciatic Proximal' 
%     [6 7] 'Sciatic Distal' 
%     };

cuff_mapping    = { ...
     [4 5]  'Sciatic Proximal' 
     [6 7]  'Sciatic Distal' 
    };
if strcmp(headstage, 'surfd_raw')
    if unique(cellfun(@(x) length(x), cuff_mapping(:,1)))~=1
        error('incorrect cuff mapping for surfD headstage')
    end
else
    if unique(cellfun(@(x) length(x), cuff_mapping(:,1)))~=2
        error('incorrect cuff mapping for surfS/nano2 headstage')
    end
end

C.TRIPOLAR.CUFF_TYPE       = headstage;
C.TRIPOLAR.CUFF_CHANNELS   = cuff_mapping(:,1)';
C.TRIPOLAR.CUFF_LABELS     = cuff_mapping(:,2)';
C.TRIPOLAR.UPSAMPLE        = 10;
C.TRIPOLAR.FILTER_PIPELINE = { ...
    ButterworthFilterSpec('filtfiltm',2,300,'highpass')};
% Whether or not the selected channel is inverted before evaluating 

C.TRIPOLAR.INVERT_CHANNEL = {[false false] [false false] [false false] [false false]};

% =========================================================================
% BIPOLAR PARAMETERS
% =========================================================================

cuff_mapping = { ...
        [0 1] 'Pelv'
        [2 3] 'Pelv 2'
        [8 9] 'Pudendal'
        [10 11] 'Sens Branch'
        [12 13] 'Dor Pen'
        [14 15] 'Caud Rect'
        [16 17] 'Deep Per'
    };

if strcmp(headstage, 'surfd_raw')
    if unique(cellfun(@(x) length(x), cuff_mapping(:,1)))~=1
        error('incorrect cuff mapping for surfD headstage')
    end
else
    if unique(cellfun(@(x) length(x), cuff_mapping(:,1)))~=2
        error('incorrect cuff mapping for surfS/nano2 headstage')
    end
end

C.BIPOLAR.CUFF_COLORS     = '';
C.BIPOLAR.CUFF_TYPE       = headstage;
C.BIPOLAR.CUFF_CHANNELS   = [cuff_mapping(:,1)'];
C.BIPOLAR.CUFF_LABELS     = cuff_mapping(:,2)';
C.BIPOLAR.UPSAMPLE        = 1;
C.BIPOLAR.FILTER_PIPELINE = {ButterworthFilterSpec('filterm',2,300,'highpass')};

% % =========================================================================
% % EMG PARAMETERS
% % =========================================================================
% 
% EMG.mapping = {...
%     0   'L. Sart'
%     1   'L. Semi M'
%     2   'L. Semi T'
%     3   'L. MG'
%     4   'L. LG'
%     5   'L. BiFem'
%     6   'L. TA'
%     7   'L. EDL'
%     8   'L VL'
%     9   'L. TFL'
%     };
% 
% % EMG.mapping = EMG.mapping(8,:);
% 
% C.EMG.TYPE     = headstage;
% C.EMG.CHANNELS = [EMG.mapping{:,1}];
% C.EMG.LABELS   = EMG.mapping(:,2)';
% C.EMG.UPSAMPLE = 10;
% C.EMG.FILTER_PIPELINE = { ...
%     ButterworthFilterSpec('filtfiltm',2,70,'high')};
end