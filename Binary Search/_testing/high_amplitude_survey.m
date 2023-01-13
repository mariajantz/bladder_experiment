function [stim_freqs, response_locs] = high_amplitude_survey(C, savepath, datapath, baseline_filenum, varargin)
% high amplitude survey
% inputs: if testing, input baseline datafile number, survey number
% REQUIRED ARGS IN:
% C - experiment constants
% savepath - full filepath for location to save the experiment constants
% file and the final plots
% datapath - location of datafiles from Grapevine
% baseline_filenum - integer number of the baseline file (either from find_curfile or as
% an input when testing
%
% VAR ARGS IN:
% 'testing', boolean whether this is a test run or actually recording data
% 'survey_filenum', integer number of survey recording (required if testing)
% if testing is set to false but there is a non-NaN survey file number
% present, stimulation will occur but the data will be loaded from the
% given file
% 'plotting', boolean whether or not to plot the results

varargin = sanitizeVarargin(varargin);
DEFINE_CONSTANTS
testing = false;
survey_filenum = NaN;
plotting = true; 
END_DEFINE_CONSTANTS

if ~exist(sprintf('%s\\experiment_constants%04d.mat', savepath, baseline_filenum), 'file')
    save(sprintf('%s\\experiment_constants%04d', savepath, baseline_filenum), 'C') 
else
    error('File number not incremented, stopping now to avoid overwriting previous file.');
end

recTime = C.MAX_AMP_REPS/C.STIM_FREQUENCY(1)*size(C.STIM_MAP, 1)+1;
% set up to trigger recording
if ~testing
    status = xippmex;
    if status == 0
        error('Xippmex is not connecting.')
    end
end

% collect baseline data and do max amp stimulation
if testing && ~isnan(survey_filenum)
    %testing without stimulation (only load from file)
    baseline_wf = load_baseline(C, sprintf('%s\\datafile%04d', datapath, baseline_filenum));
elseif ~isnan(survey_filenum)
    %testing with stimulation/recording (load actual data from files)
    baseline_wf = collect_baseline(C, recTime, sprintf('%s\\datafile%04d', datapath, baseline_filenum));
    pause(1);
    elec_survey_stim(C, 0.2);
else
    %actual run of experiment (load data from actual stimulated/recorded
    %files)
    baseline_wf = collect_baseline(C, recTime, sprintf('%s\\datafile%04d', datapath, baseline_filenum));
    % stimulate and record
    pause(1);

    elec_survey_stim(C, 0.2, sprintf('%s\\datafile', datapath));
    survey_filenum = baseline_filenum+1;
end

% split the file into the correct segments (separate out diff channels)
%TODO: this currently doesn't group concurrent stim sets of channels
chanSnips = elec_survey_split(C, sprintf('%s\\datafile%04d', datapath, survey_filenum));
% find responses:
% choose frequencies, channels to stimulate and which nerve cuffs to look
% for responses on
[stim_freqs, response_locs, ~] = find_response(C, chanSnips(C.SEARCH_CUFFS_IDX, :), baseline_wf); %TODO test for both max amp and single amp
% format: stim_freqs, response_locs are arrays of size stimChan x cuffChan
% add allowance of some time (5ms) in stim freqs following end of response
stim_freqs = floor(1./(1./stim_freqs+.005));
% save values that were chosen to mat file for plotting elsewhere
filenums.baseline = baseline_filenum; filenums.single_amp = survey_filenum;
save(sprintf('%s\\single_amp_survey%04d', savepath, baseline_filenum), 'C', 'filenums', 'stim_freqs', 'response_locs');

if plotting
    plot_max_amp(C, chanSnips, stim_freqs, filenums, [savepath '\']);
end

fprintf('High Amplitude Survey complete.\n');
