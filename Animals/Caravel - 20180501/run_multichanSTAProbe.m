% HIGH AMPLITUDE SURVEY
% to run, update the experiment_constants file variables 
% C.AMPLITUDE_RANGE = [0 value to run the high amplitude survey]
% 

% close all
%xippmex('close');
clear_timers; clear_sockets; clear classes; clear all; 
clc

% Load the constants that define this experiment
C = experiment_constants;

% Stimulation Parameters ==================================================
% Stimulation frequency, Hz
frequency = C.STIM_FREQUENCY;

% Channels to test
%TODO: update this as tuples
stim_channels = 128+(1:16);

% Amplitudes to test [min max], uA 
amplitude_range = C.AMPLITUDE_RANGE;

% Number of repetitions to run per set. Additional reps are run whenever
% a set does not produce a significant response
nReps = 50;

% Recording Parameters ==================================================
invert_channel = false;

save_trial = false;
% =========================================================================
stimulation_parameters = struct( ...
    'channels',         stim_channels,...
    'event_names',      {arrayfun(@(x)sprintf('EVT%02d',x),stim_channels,'un',0)},...
    'amplitude_min_difference',  1,  ...
    'amplitude_range',  amplitude_range,...
    'frequency_range',  C.FREQUENCY_RANGE,...
    'frequency',        frequency,...
    'duration',         C.EXTRACT_TIME_RANGE,...
    'reps_per_set',     C.STA_REPS_PER_SET,...
    'stim_step',                C.STIM_STEP,...
    'stim_multiplier',          C.STIM_MULTIPLIER,...
    'cathode_duration',         C.STIM_CATH_DUR_MS,...
    'anode_duration',           C.STIM_ANOD_DUR_MS,...
    'stim_polarity',            C.STIM_POLARITY,...
    'nanostim_active_chan',     C.NANOSTIM_ACTIVE_CHAN);
                
channels = C.BIPOLAR.CUFF_CHANNELS;
labels   = C.BIPOLAR.CUFF_LABELS;

nCuffs   = length(channels)/2;
recording_parameters = struct( ...
    'baseline_duration',    1,...
    'analog',               [],...
    'digital',              [],...
    'spikes',               []);
recording_parameters.analog  =  struct( ...
    'type',             C.BIPOLAR.CUFF_TYPE,...
    'channels',         {C.BIPOLAR.CUFF_CHANNELS{:}}, ...
    'filter_pipeline',  {C.BIPOLAR.FILTER_PIPELINE}, ...
    'upsample',         C.BIPOLAR.UPSAMPLE, ...
    'invert',           invert_channel, ...
    'labels',           labels);

recording_parameters.digital = struct( ...
    'channels', C.STIM_EVENT_CHANNEL);
recording_parameters.spikes  = struct( ...
    'channels', []);

%TODO: change this part
protocol = STAProbeExperimentProtocol(  ...
    'catName',                  C.CAT_NAME,...
    'electrode_location',       C.DRG_LOCATION,...
    'electrode_type',           C.ELECTRODE_TYPE,...
    'save_trial',               save_trial,...
    'stimulator_type',          C.STIMULATOR_TYPE,...
    'buffer_type',              C.BUFFER_TYPE,...
    'stimulation_parameters',   stimulation_parameters,...
    'recording_parameters',     recording_parameters,...
    'demultiplex_events',       true);


initialize(protocol)

if save_trial digTrigger_recording(1, digTrigger_chan); end
run(protocol)
if save_trial digTrigger_recording(0, digTrigger_chan); end
xippmex('close');