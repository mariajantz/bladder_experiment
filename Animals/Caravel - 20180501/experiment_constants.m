function C = experiment_constants
C.CAT_NAME            = 'Caravel';
C.STIMULATOR_TYPE     = 'grapevine';            % iz2/grapevine
C.BUFFER_TYPE         = 'ripple';               % ripple/xipprtma
headstage             = 'surfs2_raw';            % surfs2_raw/surfs_raw/surfd_raw/nano2_raw/nano_raw
C.DRG_LOCATION        = 'DRG - S1';             % DRG/VR L5/6/7 S1/2
C.ELECTRODE_TYPE      = 'Utah-Array-4x8';       % FMA-32Chan/Utah-Array-4x8/RippleSurfaceV3

C.AMPLITUDE_RANGE     = [0 300];                 % [min max] uA
C.STA_REPS_PER_SET        = 50;
C.THRESH_REPS_PER_SET     = 320;
C.SELECTIVTY_REPS_PER_SET = 320;

% =========================================================================
% STIMULATION PARAMETERS 
% =========================================================================
% C.REPS_PER_SET        = [150 175 275];
C.STIM_FREQUENCY      = 83;
C.FREQUENCY_RANGE     = [50 150];
C.STIM_EVENT_CHANNEL  = 2;
C.IRIG_CHANNEL        = 3;
C.MAX_CHANNELS        = 4;
C.EXTRACT_TIME_RANGE      =0.9/C.STIM_FREQUENCY;
% C.DEFAULT_FREQUENCY        = 20;

C.STIM_STEP = 4;    % nano2 step
stim_array = [1 2 5 10 20];
C.STIM_MULTIPLIER = stim_array(C.STIM_STEP); %find([1,2,5,10,20] == C.STIM_STEP);  % stim res
if min(C.STIM_MULTIPLIER*127, 1500)<max(C.AMPLITUDE_RANGE)
    error('Set a stimulation step/multiplier that allows an amplitude as large as the max amplitude'); 
end
C.STIM_CATH_DUR_MS = 0.2;       % ms
C.STIM_ANOD_DUR_MS = 0.4;       % ms
C.STIM_POLARITY = 1;            % 1 - cathodic first

% =========================================================================
% NIP CONFIG 
% =========================================================================
nanostim_location = {'DRG - S1', 'DRG - S2', 'DRG - S3'};
nanostim_chanOrder = {129:160, 161:192, 193:224};

C.NANOSTIM_ACTIVE_CHAN = nanostim_chanOrder{ismember(nanostim_location, C.DRG_LOCATION)};

% =========================================================================
% ANALYSIS PARAMETERS 
% =========================================================================
C.AMP_MIN_DIFF = 5; %uA; this determines step size in binary search 
C.SLIDING_WINDOW_DURATION  = 250e-6;
C.SLIDING_WINDOW_STEP      = 25e-6;
C.RMS_THRESHOLD_MULTIPLIER = 3;
C.MIN_RESPONSE_LATENCY     = 1e-3; %has to be over PWcath+PWanode+IPI (default IPI 66us)
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
% 
cuff_mapping    = { ...
%     [10 11]  'Sciatic Proximal' 
      [12 13]  'Sciatic Distal' 
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
        [2 3] 'Pudendal' 
        [4 5] 'Sens Branch'
        [6 7] 'Deep Per'
        [8 9] 'Caud Rect'
        [10 11]  'Sci Prox' 
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