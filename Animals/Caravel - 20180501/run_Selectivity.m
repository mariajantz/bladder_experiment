% clear all the experiment control objects from memory. They are sneaky and
% like to hid where you can't find them!
clear_timers; clear_sockets; clear all;clear classes
clc

% Load the constants that define this experiment
C = experiment_constants;

% ask the user whether they want to continue after testing each channel
prompt_user = true;

% Stimulation Parameters ==================================================
% Channels to test
stim_channels = 128+[1:2];%32];

% Amplitudes to test [min max], uA 
amplitude_range = C.AMPLITUDE_RANGE;

% Stimulation frequency, Hz
frequency = C.STIM_FREQUENCY;

% Stimulation Parameters ==================================================
stimulation_parameters = struct( ...
    'channels',                 stim_channels,...
    'event_names',              {arrayfun(@(x)sprintf('EVT%02d',x),stim_channels,'un',0)},...
    'amplitude_min_difference', C.AMP_MIN_DIFF,...
    'amplitude_range',          amplitude_range,...
    'frequency',                frequency,...
    'frequency_range',          C.FREQUENCY_RANGE,...
    'duration',                 C.EXTRACT_TIME_RANGE,...
    'reps_per_set',             C.SELECTIVTY_REPS_PER_SET,...
    'stim_step',                C.STIM_STEP,...
    'stim_multiplier',          C.STIM_MULTIPLIER,...
    'cathode_duration',         C.STIM_CATH_DUR_MS,...
    'anode_duration',           C.STIM_ANOD_DUR_MS,...
    'stim_polarity',            C.STIM_POLARITY,...
    'nanostim_active_chan',     C.NANOSTIM_ACTIVE_CHAN);

recording_parameters = struct(...
    'baseline_duration', ceil(C.SELECTIVTY_REPS_PER_SET*C.EXTRACT_TIME_RANGE*1.5),...          %round(sum(reps_per_set)/frequency)*1.5,...
    'analog',   [],...
    'digital',  [],...
    'spikes',   []);

recording_parameters.analog  =  struct( ...
    'type',             C.BIPOLAR.CUFF_TYPE,...
    'channels',         {C.BIPOLAR.CUFF_CHANNELS{:}},...    %num2cell(C.BIPOLAR.CUFF_CHANNELS), ...
    'upsample',         C.BIPOLAR.UPSAMPLE,...
    'filter_pipeline',  {C.BIPOLAR.FILTER_PIPELINE},...
    'invert',           false, ...
    'labels',           C.BIPOLAR.CUFF_LABELS);

recording_parameters.digital = struct( ...
    'channels', C.STIM_EVENT_CHANNEL);

analysis_parameters = struct( ...
    'cuff_electrode_separation',8e-3,       ...
    'max_cv',                   C.MAX_CV,        ...
    'min_cv',                   C.MIN_CV,         ...
    'minimum_response_latency', C.MIN_RESPONSE_LATENCY,       ...
    'sliding_window_duration',  C.SLIDING_WINDOW_DURATION,     ...
    'sliding_window_step',      C.SLIDING_WINDOW_STEP,      ...
    'extract_time_range',       [0 C.EXTRACT_TIME_RANGE], ...
    'rms_threshold_multiplier', C.RMS_THRESHOLD_MULTIPLIER);

protocol = SelectivityExperimentProtocol( ...
    'catName',                  C.CAT_NAME,...
    'electrode_location',       C.DRG_LOCATION,...
    'electrode_type',           C.ELECTRODE_TYPE,...
    'stimulator_type',          C.STIMULATOR_TYPE,...
    'buffer_type',              C.BUFFER_TYPE,...
    'stimulation_parameters',   stimulation_parameters,...
    'recording_parameters',     recording_parameters,...\
    'demultiplex_events',       true,...
    'analysis_parameters',      analysis_parameters);

initialize(protocol)
protocol.bPromptUser = prompt_user;
run(protocol)