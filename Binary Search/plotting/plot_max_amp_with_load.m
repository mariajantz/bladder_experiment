% plot the results of the most recent maximum amplitude survey trial
testing = false; 
%C = experiment_constants; 
%load constants
switch testing
    case true
        datapath = 'R:\users\mkj8\testing\experiment_testing\testfiles';
        savepath = 'R:\users\mkj8\testing\experiment_testing\testAnimal\DRG - S1\';
    case false
        %NOTE: FIX THIS SO IT DOESN'T DEPEND ON C (or C gets loaded first)
        savepath = sprintf('C:\\DataTanks\\2018\\%s\\Experiment_Files\\', C.CAT_NAME); %file path for saving constants/run info
        savepath = [savepath C.LOCATION '\'];
        datapath = sprintf('C:\\DataTanks\\2018\\%s\\Grapevine', C.CAT_NAME);
end
allTrials = dir(sprintf('%ssingle_amp_survey*', savepath));
fprintf('Loading file %s\n', allTrials(end).name); 
load([savepath allTrials(end).name]);

%load actual results
%load baseline
[~,hFilens5] = ns_OpenFile(fullfile(datapath, sprintf('datafile%04d.ns5', filenums.baseline)), 'single');
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

ns_CloseFile(hFilens5);
%TODO temporary testing! works for datafile0001
if testing
    baseline_wf = cellfun(@(x) x(4e5:end), baseline_wf, 'UniformOutput', false);
    baseline_wf = cellfun(@(x) [x; flipud(x)], baseline_wf, 'UniformOutput', 0);
end

% load the the max amp file and split it by stimulation times
chanSnips = max_amp_split(C, sprintf('%s\\datafile%04d', datapath, filenums.single_amp));

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

%[~, plotidx] = sort(plotlocs); 
[plotrows, plotcols] = find(ismember(chanLayout, plotlocs));
plotrows = length(unique(plotrows)); 
plotcols = length(unique(plotcols)); 
%plot
figure; 
cutoff_ms = 1000./min(stim_freqs, [], 2);
for i = 1:length(stimChan)
    subplot(plotrows, plotcols, i); 
    iChan = [stimChan{i, :}];
    hold on; 
    for j = 1:size(chanSnips, 1)
        xvals = 1/30:1/30:size(chanSnips{j, i}, 2)/30; %give xvals in ms
        plot(xvals, mean(chanSnips{j, i}, 1), 'Linewidth', 2); 
    end
    axis tight
    title(sprintf('Channels %d %d %d', iChan));
    %plot stim time
    ylimits = ylim; 
    plot([C.PRE_WINDOW C.PRE_WINDOW], ylim, '--r', 'Linewidth', 2);
    %plot cutoff frequency that was determined
    plot([cutoff_ms(i) cutoff_ms(i)]+1, ylim, '--b', 'Linewidth', 2); 
end

% add legend
legend(C.BIPOLAR.CUFF_LABELS); 

% save in format datafile0330_500uA
savefig([savepath sprintf('datafile%04d_%duA', filenums.single_amp, C.MAX_AMP)]); 



