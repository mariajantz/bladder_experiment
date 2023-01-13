function [stimChan, plotHandles, anlsStruct] = plot_channel_MG(stimVarPath)
% %plot all the traces from the most recent channel
% stimVarPath = where to find the filenumbers, channels, and amplitudes
% example usage: plot_channel(C,
% 'X:\2018\Bellatrix\Documents\Experiment_Files\Epidural - L6\stimChan_trial2165.mat', 
% 'X:\2018\Bellatrix\Grapevine'); 
% '\\share.files.pitt.edu\RnelShare\data_raw\cat\2022\R01_SCS_Fisher-Project\Aqua-20221201'
% outputs the stimulation channel used, the plot handles generated, and a
% structure with the analysis generated. 
% '\\share.files.pitt.edu\RnelShare\data_raw\cat\2022\R01_SCS_Fisher-Project\Aqua-20221201\Documents\Experiment_Files\Epidural
% - L6\stimChan_trial0640.mat'

dataPath = fullfile(fileparts(stimVarPath), '..\..\..\Grapevine'); 
constnames = dir(fullfile(fileparts(stimVarPath), 'experiment_cons*')); 
const_idx = cellfun(@(x) str2double(x(21:24)), {constnames.name}); 
cfilenum = find(const_idx<str2double(stimVarPath(end-7:end-4)), 1, 'last'); 

%load the stimulation info (filenums, channels, amplitudes) 
load(stimVarPath); 
load(fullfile(constnames(cfilenum).folder, constnames(cfilenum).name));

%load baseline
[~,hFilens5] = ns_OpenFile(fullfile(dataPath, sprintf('datafile%04d.ns5', filenums.baseline)), 'single');
numChans = length(C.BIPOLAR.CUFF_CHANNELS);
startIdx = 1;
endIdx = hFilens5.FileInfo(end).TimeStamps(2);
[b,a] = butter(C.NCUFF_FILTER_ARGS{1}, C.NCUFF_FILTER_ARGS{2}/(C.REC_FS/2), C.NCUFF_FILTER_ARGS{3});
baseline_wf = cell(numChans, 1);

for j = 1:numChans
    fprintf('Load analog data for channels %d, %d\n', C.BIPOLAR.CUFF_CHANNELS{j})
    chanIdx1 = find(strcmp({hFilens5.Entity.Label}, sprintf('raw %d', C.BIPOLAR.CUFF_CHANNELS{j}(1)+1)));
    [~, ~, tmpchan1] = ns_GetAnalogData(hFilens5, chanIdx1, startIdx, endIdx);
    chanIdx2 = find(strcmp({hFilens5.Entity.Label}, sprintf('raw %d', C.BIPOLAR.CUFF_CHANNELS{j}(2)+1)));
    [~, ~, tmpchan2] = ns_GetAnalogData(hFilens5, chanIdx2, startIdx, endIdx);
    %difference the channels and filter
    baseline_wf{j} = filter(b,a,tmpchan1-tmpchan2);
end

ns_CloseFile(hFilens5); clear hFilens5;

%load individual traces
chanSnips = cell(size(C.BIPOLAR.CUFF_CHANNELS, 2), length(prev_amps));
for iAmp = 1:length(prev_amps)
    % split all channels into snippets
    chanSnips(:, iAmp) = single_amp_split(C, fullfile(dataPath, sprintf('datafile%04d', filenums.stim(iAmp))));
end

[amps, amp_idx] = sort(prev_amps);
%find where responses were found TODO fix this!!
[~, anlsStruct.recruitLocs, anlsStruct.timeWindows, anlsStruct.channelRMS] = find_response(C, chanSnips, baseline_wf, 'outputs', [1 1 1 1]);

num_subplots = 15;
plot_count = 1;
plotHandles = zeros(1, ceil(length(amps)/num_subplots)+1); 
plotHandles(1) = figure('units','normalized','outerposition',[0 0 1 1]); 
%clrs = get(gca, 'ColorOrder'); 
clrs = [10,100,113; 217,95,2; 236,169,0; 84,0,121;...
102,166,30; 175,0,3; 60,136,255; 231,41,138; 150 150 150]/255; 
for i = 1:length(amps)
    %if necessary, make a new figure and reset count
    if plot_count>num_subplots
        plotHandles(find(plotHandles==0, 1, 'first')) = figure('units','normalized','outerposition',[0 0 1 1]);
        plot_count = 1;
    end
    %choose constant to determine level on y axis of bars for plot
    minvals = 0;
    for j = 1:size(chanSnips, 1)
        subplot(4, 4, plot_count); hold on;
        %plot the mean traces for each nerve cuff
        temptrace = mean(chanSnips{j, amp_idx(i)}, 1);
        xvals = [1/C.REC_FS:1/C.REC_FS:length(temptrace)/C.REC_FS]*1000; 
        h(j) = plot(xvals, temptrace, 'Linewidth', 2, 'Color', clrs(j, :));
        %choose y level to plot the zones where a response was found for each nerve cuff
        minvals = min(min(temptrace), minvals);
    end
    %TODO plot the bars where there are responses
    yLvl = minvals*.1+minvals;
    for j = 1:size(chanSnips, 1)
        if ~isempty(anlsStruct.timeWindows{amp_idx(i), j})
            for k = 1:size(anlsStruct.timeWindows{amp_idx(i), j})
                plot(anlsStruct.timeWindows{amp_idx(i), j}(k, :)*1000, [yLvl+j*minvals*.05 yLvl+j*minvals*.05], 'Linewidth', 3, 'Color', clrs(j, :));
            end
        end
    end
    
    plot_count = plot_count+1;
    axis tight; 
    ylimits = ylim; 
    min_y = ylimits(1)+minvals*.1; 
    ylim([min_y ylimits(2)]); 
    title(amps(i)); 
    set(gca, 'TickDir', 'out'); 
    p = patch([xvals(1) xvals(end) xvals(end) xvals(1)],[min_y min_y yLvl yLvl],[.85 .85 .85], 'EdgeColor', 'none');
    uistack(p, 'bottom'); 
end

subplot(4, 4, plot_count); hold on; 
for j = 1:size(chanSnips, 1)
    h(j) = plot(1, 1, 'Linewidth', 2, 'Color', clrs(j, :));
end
legend(h, C.BIPOLAR.CUFF_LABELS); 
axis off

%plot the recruitment curve (in terms of RMS)
%within response windows, get RMS value, plot those
rms_results = nan(size(chanSnips)); 
mnSnips = cellfun(@mean, chanSnips, 'UniformOutput', 0);
for i = 1:size(chanSnips, 2) %for each amplitude
    for j=1:size(chanSnips, 1) %for each nerve
        idx = ceil(anlsStruct.timeWindows{amp_idx(i), j}*30e3); 
        %make array of response amplitudes within only the time windows with response
        snp = nan(1, max(idx(:))); 
        for k = 1:size(idx, 1)
            snp(idx(k, 1):idx(k, 2)) = mnSnips{j, amp_idx(i)}(idx(k, 1):idx(k, 2));
        end
        snp(isnan(snp)) = []; 
        rms_results(j, i) = rms(snp);
    end
end
plotHandles(end) = figure; 
hold on; 
for i = 1:size(rms_results, 1)
    plot(amps, rms_results(i, :)', 'o-', 'Color', clrs(i, :), 'MarkerFaceColor', clrs(i, :), 'Linewidth', 2)
end

box off; 
set(gca, 'TickDir', 'out', 'FontSize', 14, 'YScale', 'log', 'FontName', 'Arial')
xlabel('Stimulation Amplitude (\muA)'); 
ylabel('Response Amplitude RMS (\muV)'); 
title('RMS Recruitment curve'); 
legend(C.BIPOLAR.CUFF_LABELS, 'Location', 'northwest'); 


%return the online analysis to be saved
%reorganize this into the correct order by ampIdx
anlsStruct.timeWindows = anlsStruct.timeWindows(amp_idx, :); 
anlsStruct.recruitLocs = anlsStruct.recruitLocs(amp_idx, :); 
anlsStruct.stimAmps = amps; 
anlsStruct.NEVfile = filenums.stim; 
anlsStruct.stimChan = stimChan; 
anlsStruct.chanSnips = chanSnips(:, amp_idx); 




