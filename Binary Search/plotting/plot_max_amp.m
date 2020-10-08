function plot_max_amp(C, chanSnips, stim_freqs, filenums, savepath)
% plot the results of a maximum amplitude survey trial

% plot each channel in a grid
stimChan = C.STIM_MAP; %TODO: double check randomized channel order...
chanLayout = C.LAYOUT_MAP; %reshape(1:prod(C.ELECTRODE_DIM), C.ELECTRODE_DIM(1), C.ELECTRODE_DIM(2))';
% do math to figure out where each item should be plotted
plotlocs = [];
for i = 1:length(stimChan)
    iChan = [stimChan{i, :}];
    [j, k] = find(ismember(chanLayout, iChan));
    plotlocs = [plotlocs min(unique(chanLayout(j, k)))];
end

% if ~all(sort(plotlocs)==plotlocs)
%     fprintf('Re-sorting channel order before plotting\n');
%     [sorted_plotlocs, p_idx] = sort(plotlocs); 
%     %check for duplicates
%     dup_idx = find(diff(sorted_plotlocs)==0);
%     sorted_plotlocs(dup_idx) = []; p_idx(dup_idx) = []; 
%     %reshuffle chanSnips to sorted version
%     chanSnips = chanSnips(:, p_idx);
%     plotlocs = sorted_plotlocs; 
% end

%[~, plotidx] = sort(plotlocs);
[plotrows, plotcols] = find(ismember(chanLayout, plotlocs));
plotrows = length(unique(plotrows));
plotcols = length(unique(plotcols));

%sort the original dataset so plotting is in the right order
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

%plot
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
cutoff_ms = 1000./min(stim_freqs, [], 2);
for i = 1:length(stimChan)
    subplot(plotrows, plotcols, i);
    iChan = [stimChan{i, :}];
    stimIdx = find(ismember(sorted_chan, iChan, 'rows')); %necessary for correct plot layout
    if length(stimIdx) >1
        stimIdx = stimIdx(1);
    end
    hold on;
    for j = 1:size(chanSnips, 1)
        xvals = 1/30:1/30:size(chanSnips{j, stimIdx}, 2)/30; %give xvals in ms
        plot(xvals, mean(chanSnips{j, stimIdx}, 1), 'Linewidth', 2);
    end
    axis tight
    title(sprintf('Channels %d %d %d', iChan));
    %plot stim time
    ylimits = ylim;
    plot([C.PRE_WINDOW C.PRE_WINDOW], ylim, '--r', 'Linewidth', 2);
    %plot cutoff frequency that was determined
    plot([cutoff_ms(stimIdx) cutoff_ms(stimIdx)]+1, ylim, '--b', 'Linewidth', 2);
end

% add legend
legend(C.BIPOLAR.CUFF_LABELS);

% save in format datafile0330_500uA
if ~isempty(savepath)
    savefig([savepath sprintf('datafile%04d_%duA', filenums.single_amp, C.MAX_AMP)]);
end



