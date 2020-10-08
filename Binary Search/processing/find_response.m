function varargout = find_response(C, chanSnips, baseline_wf, varargin)
%[max_freqs, response_locs, time_windows]
% Function to determine presence of a response
% INPUTS
% C = Animal constants, must be a struct that contains the following
% fields: C.PRE_WINDOW (how long in ms before a stimulus pulse the channels
% are snipped), C.REC_FS (frequency of the recording, usually 30e3 Hz), and
% C.RMS_THRESHOLD_MULTIPLIER (how high above RMS threshold a trace must be
% to count as a "response")
%
% chanSnips = trace for nerve cuffs, split by stimulation trigger time - in the format
% of {nervecuffnum, stimchannum}, where each cell is [numsnippets, windowlen]
% Nerve cuff wave form should already be stim blanked by this point
%
% baseline_wf = Quiet recording traces to determine RMS threshold - should be cell of
% length numberOfNerveCuffs, with recording traces already differenced
% between bipolar nerve cuff contacts
%
% varargin = if desired, you can limit the calculation of output variables
% with the argument 'outputs', [0 1 0 0], where the array is a boolean
% array of the inclusion of arguments 'max_freqs', 'response_locs',
% 'time_windows', and 'chan_rms'
%
% OUTPUTS
% varargout = max_freqs, response_locs, time_windows, chan_rms, in that
% order (inclusion of each field depends on varargin)
% max_freqs = maximum frequency possible to be sure you capture all
% responses observed
% response_locs = which cuffs responded for each stimulation channel
% time_windows = the time windows within which each channel responds
% chan_rms = the rms found from baseline for each channel

varargin = sanitizeVarargin(varargin);
DEFINE_CONSTANTS
outputs = [1 1 1 0]; %by default return first three outputs
END_DEFINE_CONSTANTS

warning('Check that this is up to date with validated response parameters'); 
fprintf('Finding responses\n')
% define constants (hard code for now...)
debug_plot = false;
numWindows = 200; %split into 200 pieces for moving window with RMS threshold
numStimEvts = size(chanSnips{1}, 1)-2; %deal with cases where stim is slightly misaligned
N = round(0.8*numStimEvts); %TODO check dimensions
RMSfn = @(y) sqrt(mean(y.^2));
windowlen = min(min(cellfun(@(x) size(x, 2), chanSnips), [], 2)); %size(chanSnips{1}, 2); %set window length to shortest snip
bootstrap_thresh = .95;
windowSize_sec       = 2.5e-4;      % sec, TODO fix
winDisplace = 2.5e-5;
pre_window = C.PRE_WINDOW/1000 + C.MIN_RESPONSE_LATENCY; % in seconds
varargout = cell(1, sum(outputs));

% find baseline RMS for full baseline trace: split into windows, choose
% 99th percentile level window to determine threshold
splitN = min(numWindows, numStimEvts); %just in case it's a short recording period
rms_mean = zeros(length(baseline_wf), splitN); %number of channels by number of trials
rms_std  = zeros(length(baseline_wf), splitN);
baseline_snips = cellfun(@(x) reshape(x(1:end-mod(length(x), windowlen)), floor(length(x)/windowlen), windowlen), baseline_wf, 'UniformOutput', 0);
if size(baseline_snips{1}, 1)<numStimEvts %some cases have a slightly shorter baseline recording; add extra snips
    warning('Doubling to add longer baseline time'); 
    baseline_snips = cellfun(@(x) [x; x], baseline_snips, 'UniformOutput', false); 
end
bootstrap_samples = randi([1 numStimEvts],[splitN N]);
for iFold = 1:splitN
    idx = bootstrap_samples(iFold,:);
    %find a subset of baseline wf snips to compare
    avg_baseline_wf = cellfun(@(x) mean(x(idx,:)), baseline_snips, 'UniformOutput', false);
    [baseline_rms, ~] = cellfun(@(x) moving_window_fast(x, C.REC_FS, RMSfn, windowSize_sec, winDisplace), avg_baseline_wf, 'UniformOutput', false);
    baseline_rms = cell2mat(baseline_rms);
    rms_mean(:, iFold) = mean(baseline_rms, 2);
    rms_std(:, iFold) = std(baseline_rms, 0, 2);
end
rms_mean      = sort(rms_mean, 2);
rms_std       = sort(rms_std, 2);
rms_threshold = rms_mean(:, round(.99*splitN))+C.RMS_THRESHOLD_MULTIPLIER*rms_std(:, round(.99*splitN));
%baseRMS = cellfun(@rms, baseline_wf); %the lazy way

%check: is there an outlier, is median absolute deviation large enough to
%worry about it
try
    if any(isoutlier(rms_threshold)) && mad(rms_threshold)>.15
        %if there are channels matching these parameters, check if each channel is
        %a larger outlier
        outlier_idx = find(isoutlier(rms_threshold));
        for i= outlier_idx
            if rms_threshold(i)>median(rms_threshold)
                fprintf('Adjusting noise threshold for outlier channel %d\n', i)
                %if so, increase the noise threshold necessary to detect a
                %response
                rms_threshold(i) = (rms_threshold(i)-median(rms_threshold))+rms_threshold(2);
            end
        end
    end
catch
    warning('There is an error because this matlab version is terrible'); 
end

%initialize the output arrays
for i = find(outputs)
    if i==3
        varargout{find(outputs)==i} = cell(size(chanSnips'));
    else
        varargout{find(outputs)==i} = NaN(size(chanSnips'));
    end
end
%add as an output if necessary
if outputs(4)
    varargout{end} = rms_threshold;
end

% for each channel that was stimulated
for iStim = 1:size(chanSnips, 2)
    fprintf('Trial %d of %d\n', iStim, size(chanSnips, 2)); 
    % for each nerve cuff
    for iChan = 1:size(chanSnips, 1)
        % calculate ENG RMS within a window
        bootstrap_samples = randi([1 numStimEvts],[splitN N]);
        full_rms = zeros(size(baseline_rms, 2), splitN);
        for iiFold = 1:splitN
            %disp(iiFold);
            idx = bootstrap_samples(iiFold,:);
            %fprintf('%d %d %d\n',iStim, iChan, iiFold);
            avg_wf = mean(chanSnips{iChan, iStim}(idx,:));
            [rms, rms_time]= moving_window_fast(avg_wf, C.REC_FS, RMSfn, windowSize_sec, winDisplace);
            full_rms(:,iiFold) = rms(:);                % TODO initialize this array rms(1:size(baseline_rms, 2))
        end
        
        
        % compare where ENG > baseline RMS
        percent_significant_windows = sum(full_rms >= rms_threshold(iChan),2)/splitN;
        sig_mask    = percent_significant_windows > bootstrap_thresh;
        sig_mask(rms_time<pre_window) = 0; %eliminate times that are significant during blanking period.
        consec_sig_windows = cumsum(sig_mask);
        if any(consec_sig_windows > 3)
            edge_idx = diff(diff(consec_sig_windows));  % second difference gives all rising and falling edges. not foolproof logic in cases of edges that dont fall, but good enough
            winStart_idx = find(edge_idx==1)+2;         % MATH!!
            winEnd_idx = find(edge_idx==-1)+1;
            if length(consec_sig_windows)==length(unique(consec_sig_windows))
                disp(winStart_idx)
                disp(winEnd_idx)
                keyboard
                winStart_idx = 1; 
                winEnd_idx = consec_sig_windows(end); 
            end
            if outputs(1)
                varargout{find(outputs)==1}(iStim, iChan) = 1/(rms_time(max([winStart_idx; winEnd_idx]))-pre_window);
            end
            if outputs(2)
                varargout{find(outputs)==2}(iStim, iChan) = 1;
            end
            if outputs(3)
                for iEdge = 1:min(length(winStart_idx), length(winEnd_idx))    % assuming there are even numbered edges...else add a check
                    varargout{find(outputs)==3}{iStim, iChan}     = [varargout{find(outputs)==3}{iStim, iChan}; [rms_time(winStart_idx(iEdge))-windowSize_sec/2 rms_time(winEnd_idx(iEdge))+windowSize_sec/2]];
                end
            end
        end
        
        %plot for debugging
        if debug_plot
            %redefine these - not sampled this time, but with the first N
            %number of trials - these are the "official" values for plotting
            avg_baseline_wf = mean(baseline_snips{iChan}(1:N,:));
            avg_wf          = mean(chanSnips{iChan, iStim}(1:N,:));
            
            figure;
            hold on
            plot(linspace(0,length(avg_baseline_wf)/C.REC_FS,length(avg_baseline_wf)),avg_baseline_wf,'-', ...
                'linewidth',2,...
                'color',[.8 .8 .8])
            plot(linspace(0,length(avg_wf)/C.REC_FS,length(avg_wf)),avg_wf,'-',...
                'color',    [0 0 1],...
                'linewidth',2)
            xlim([0 length(avg_baseline_wf)/C.REC_FS])
            
            if any(consec_sig_windows > 3)
                for iEdge = 1:length(winStart_idx)         % assuming there are even numbered edges...else add a check
                    time_window     = [rms_time(winStart_idx(iEdge))-windowSize_sec/2 rms_time(winEnd_idx(iEdge))+ windowSize_sec/2];
                    %time_window_mask  = rms_time >= time_window(1) & rms_time <= time_window(2);
                    %SNR = var(avg_wf(time_window_mask))/var(avg_baseline_wf);
                    %rms_max           = sqrt(mean(avg_wf(time_window_mask).^2));
                    %response_mag      = max(abs(avg_wf(time_window_mask)));
                    
                    ylimits = get(gca,'YLim');
                    x = time_window([1 2 2 1]);
                    y = ylimits([1 1 2 2]);
                    uistack(patch(x,y,[.8 .8 .9],...
                        'edgecolor','none'),'bottom');
                end
            end
        end
        
    end
end

if outputs(2)
    varargout{find(outputs)==2} = ~isnan(varargout{find(outputs)==2});
    %replace all nans with 0s
end
