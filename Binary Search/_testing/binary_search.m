function [] = binary_search(C, savepath, datapath, stim_freqs, response_locs, varargin)
% REQUIRED ARGS IN: 
% C - experiment constants
% savepath - full filepath for location to save the experiment constants
% file and the final plots
% datapath - location of datafiles from Grapevine
% stim_freqs - minimum frequencies for each location; this is an array with
% # channels rows and # nerve cuffs columns
% response_locs - boolean array of whether there was a response on each
% nerve (columns) at each channel index (rows)
% VAR ARGS IN: 
% 'testing', boolean whether this is a test run or actually recording data
% 'data_filenums', integer number (array) of data recordings (required if testing)
% this should be in format m x n where rows m include all channels to test,
% and cols n include each file number tested
% 'loadpath', string path of location to load data from (required if testing)
% if testing is set to false but there is a non-NaN data file number
% present, stimulation will occur but the data will be loaded from the
% given file

%TODO: testing only partly works...

varargin = sanitizeVarargin(varargin);
DEFINE_CONSTANTS
testing = false;
data_filenums = NaN;
loadpath = NaN; 
END_DEFINE_CONSTANTS

% for each stimulation channel:
% sort the channels so that the order is the same as the order that comes
% out of the high amplitude survey, which is automatically sorted
if size(C.STIM_MAP, 2)==2
    sorted_chan = sortrows([[C.STIM_MAP{:, 1}]', reshape([C.STIM_MAP{:, 2}], [length([C.STIM_MAP{:, 2}])/size(C.STIM_MAP, 1) size(C.STIM_MAP, 1)])']);
else
    sorted_chan =  sortrows([C.STIM_MAP{:, 1}]'); 
end

if ~isnan(loadpath)
    response_idx = 0; 
    baseline_file = data_filenums(1)-1; 
end

chan_idx = 1:size(response_locs, 1);
warning('Currently set to ONLY RUN FIRST CHANNEL')
keyboard
for iChan = 1%chan_idx
    if iChan ~=1 && iChan == chan_idx(1)
        warning('Has the start value for the binary search loop been updated?')
        keyboard
    end
    %if there are responses on the channel, stimulate
    if any(response_locs(iChan, :))
        if ~isnan(loadpath) %if loading files...
            response_idx = response_idx + 1; 
        end
        %find sorted stim map so it's in the same order as responses
        fprintf('Testing for responses from iChan %d on channels %d %d %d', iChan, sorted_chan(iChan, :)); 
        fprintf('\n'); 
        stimChan = sorted_chan(iChan, :);
        %set up control of stimulation amplitudes
        prev_amps = [];
        actual_amps = []; 
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
        if ~isnan(loadpath) %if loading data from old files
            curFile = data_filenums(response_idx); 
            baseline_wf = load_baseline(C, sprintf('%s\\datafile%04d', datapath, baseline_file)); 
        else
            curFile = find_curFile(datapath);
            baseline_wf = collect_baseline(C, recTime, sprintf('%s\\datafile%04d', datapath, curFile));
        end

        filenums.baseline = curFile;
        filenums.stim = [];
        
        while next_amp ~= 0 %TODO double check exit clause
            %b = tic; 
            this_amp = next_amp;
            curFile = curFile + 1;
            filenums.stim = [filenums.stim curFile];
            % for each amplitude:
            % stimulate and record
            % display parameters are being used
            fprintf('Stimulation of channels %d %d %d', sorted_chan(iChan, :));
            fprintf(' at %d uA and %d Hz in datafile%04d\n', this_amp, freq, curFile);
            
            if ~testing
                %call stimulation below
                actual_amps = [actual_amps single_elec_stim(C, sorted_chan(iChan, :), this_amp, freq, sprintf('%s\\datafile', datapath))];
            end
            % split all channels into snippets
            %toc(b); 
            %a = tic; 
            chanSnips = single_elec_split(C, fullfile(datapath, sprintf('datafile%04d', curFile)));
            % find_response for all cuffs
            [~, cuff_resp, ~] = find_response(C, chanSnips(C.SEARCH_CUFFS_IDX, :), baseline_wf); %TODO test for both max amp and single amp
            num_responses = [num_responses sum(cuff_resp)];
            fprintf('Number of responses found: %d\n', sum(cuff_resp)); 
            % determine_amplitude
            %TODO maybe add an amplitude one higher than the last one 
            prev_amps = [prev_amps this_amp];
            next_amp = determine_amplitude(num_responses, prev_amps, C.AMP_MIN_DIFF, C.AMP_MAX_DIFF);
            save(sprintf('%s\\stimChan_trial%04d', savepath, filenums.baseline), 'filenums', 'prev_amps', 'freq', 'stimChan', 'num_responses', 'actual_amps');
            %fprintf('Processing time\n'); 
            %toc(a); 
        end
        % save final info for that run
        %save(sprintf('%s\\stimChan_trial%04d', savepath, filenums.baseline), 'filenums', 'prev_amps', 'freq', 'stimChan', 'num_responses', 'actual_amps');
    end
end

fprintf('Done with binary search.\n'); 
