
% Runs the full binary search procedure to determine
% thresholds of stimulation

%% parameter setup - use testing params if necessary
% load experiment constants
clear filenums
C = experiment_constants_Longbottom;
yr = '2020';
testing = false;

if any(C.STIM_FREQUENCY(1) == [20 30 60 90 120 180])
    C.STIM_FREQUENCY(1) = C.STIM_FREQUENCY(1) - 1; %remove harmonics of 60 Hz
end

switch testing
    case true
        datafiles = [1 3];
        datapath = 'R:\users\mkj8\testing\experiment_testing\testfiles';
        savepath = 'R:\users\mkj8\testing\experiment_testing\testAnimal\';
    case false
        datafiles = [];
        savepath = sprintf('D:\\DataTanks\\%s\\%s\\Experiment_Files\\', yr, C.CAT_NAME); %file path for saving constants/run info
        datapath = sprintf('D:\\DataTanks\\%s\\%s\\Grapevine', yr, C.CAT_NAME);
end

[curFile, datafiles] = find_curFile(datapath, 'testing', testing, 'datafiles', datafiles);

%% high amplitude survey
% make data folder for this location if necessary
if ~exist([savepath C.LOCATION], 'dir')
    mkdir([savepath C.LOCATION]);
end

savepath = [savepath C.LOCATION '\'];
if ~exist(sprintf('%sexperiment_constants%04d.mat', savepath, curFile), 'file')
    save(sprintf('%sexperiment_constants%04d', savepath, curFile), 'C') %lolz this filepath
else
    error('File number not incremented, not overwriting previous file.'); 
end
recTime = C.MAX_AMP_REPS/C.STIM_FREQUENCY(1)*size(C.STIM_MAP, 1)+1;
% set up to trigger recording
status = xippmex;
if status == 0
    error('Xippmex is not connecting.')
end

% record baseline data
baseline_wf = collect_baseline(C, recTime, sprintf('%s\\datafile%04d', datapath, curFile));
%TODO temporary testing! works for datafile0001
if testing
    baseline_wf = cellfun(@(x) x(4e5:end), baseline_wf, 'UniformOutput', false);
    baseline_wf = cellfun(@(x) [x; flipud(x)], baseline_wf, 'UniformOutput', 0);
end
% stimulate and record
pause(1); 
max_amp_stim(C, 0.2);
%max_amp_stim_old(C);
% split the file into the correct segments (separate out diff channels)
%TODO: this currently doesn't group concurrent stim sets of channels
chanSnips = max_amp_split(C, sprintf('%s\\datafile%04d', datapath, curFile+1));
% find responses:
% choose frequencies, channels to stimulate and which nerve cuffs to look
% for responses on
[stim_freqs, response_locs, ~] = find_response(C, chanSnips(C.SEARCH_CUFFS_IDX, :), baseline_wf); %TODO test for both max amp and single amp
%[stim_freqs, response_locs, ~] = find_response(C, chanSnips, baseline_wf); %TODO test for both max amp and single amp
% format: stim_freqs, response_locs are arrays of size stimChan x cuffChan
% add allowance of some time (5ms) in stim freqs following end of response
stim_freqs = floor(1./(1./stim_freqs+.005));
% save values that were chosen to mat file for plotting elsewhere
filenums.baseline = curFile; filenums.single_amp = curFile +1;
save(sprintf('%ssingle_amp_survey%04d', savepath, curFile), 'C', 'filenums', 'stim_freqs', 'response_locs');
plot_max_amp(C, chanSnips, stim_freqs, filenums, savepath);
%clear filenums

fprintf('High Amplitude Survey complete.\n'); 

%% for each stimulation channel:
if size(C.STIM_MAP, 2)==2
    if size(C.STIM_MAP{1, 2}, 2) == 1
        sorted_chan = sortrows([[C.STIM_MAP{:, 1}]', [C.STIM_MAP{:, 2}]']);
    elseif size(C.STIM_MAP{1, 2}, 2) == 2
        %TODO: use this method for all of the types of stim, not just
        %tripolar
        sorted_chan = sortrows(cell2mat(C.STIM_MAP)); 
    end
else
    sorted_chan =  sortrows([C.STIM_MAP{:, 1}]'); 
end

for iChan = 1:size(response_locs, 1)
    %if there are responses on the channel, stimulate
    if any(response_locs(iChan, :))
        %find sorted stim map so it's in the same order as responses
        fprintf('Testing for responses on channels %d %d %d', sorted_chan(iChan, :)); 
        fprintf('\n'); 
        stimChan = sorted_chan(iChan, :);
        %set up control of stimulation amplitudes
        prev_amps = [];
        num_responses = []; %sum(response_locs(iChan, :));
        %TODO: should I re-run at max amp first for just this channel? YES
        next_amp = C.MAX_AMP; %determine_amplitude(num_responses, C.MAX_AMP, prev_amps, C.AMP_MIN_DIFF);
        freq = min(min(stim_freqs(iChan, :)), C.STIM_FREQUENCY(2)); %set frequency to either the max
        % value where a response was found or the max stim rate defined
        if any(freq == [20 30 60 90 120 180])
            freq = freq - 1; %remove harmonics of 60 Hz
        end
        
        % quiet recording for as long as the maximum stimulation time
        recTime = C.THRESH_REPS/freq + 1;
        %TODO: fix curFile finding for a test case that is more than one
        %loop of stimulation channels or duplicate files
        curFile = find_curFile(datapath, 'testing', testing, 'datafiles', datafiles);
        baseline_wf = collect_baseline(C, recTime, sprintf('%s\\datafile%04d', datapath, curFile));
        %TODO temporary testing! works for datafile0001
        if testing
            baseline_wf = cellfun(@(x) x(4e5:end), baseline_wf, 'UniformOutput', false);
            baseline_wf = cellfun(@(x) [x; flipud(x); x; flipud(x)], baseline_wf, 'UniformOutput', 0);
        end
        filenums.baseline = curFile;
        filenums.stim = [];
        
        while next_amp ~= 0 %TODO double check exit clause
            b = tic; 
            this_amp = next_amp;
            curFile = curFile + 1;
            filenums.stim = [filenums.stim curFile];
            % for each amplitude:
            % stimulate and record
            % display parameters are being used
            fprintf('Stimulation of channels %d %d %d', sorted_chan(iChan, :));
            fprintf(' at %d uA and %d Hz in datafile%04d\n', this_amp, freq, curFile);
            single_amp_stim(C, sorted_chan(iChan, :), this_amp, freq, fullfile(datapath, 'datafile'));
            % split all channels into snippets
            toc(b); 
            a = tic; 
            chanSnips = single_amp_split(C, fullfile(datapath, sprintf('datafile%04d', curFile)));
            % find_response for all cuffs
            [~, cuff_resp, ~] = find_response(C, chanSnips(C.SEARCH_CUFFS_IDX, :), baseline_wf); %TODO test for both max amp and single amp
            num_responses = [num_responses sum(cuff_resp)];
            fprintf('Number of responses found: %d\n', sum(cuff_resp)); 
            % determine_amplitude
            %TODO maybe add an amplitude one higher than the last one 
            prev_amps = [prev_amps this_amp];
            next_amp = determine_amplitude(num_responses, prev_amps, C.AMP_MIN_DIFF, C.AMP_MAX_DIFF);
            save(sprintf('%sstimChan_trial%04d', savepath, filenums.baseline), 'filenums', 'prev_amps', 'freq', 'stimChan', 'num_responses');
            fprintf('Processing time\n'); 
            toc(a); 
        end
        % save final info for that run
        save(sprintf('%sstimChan_trial%04d', savepath, filenums.baseline), 'filenums', 'prev_amps', 'freq', 'stimChan', 'num_responses');
    end
end

fprintf('Done with binary search.\n'); 
