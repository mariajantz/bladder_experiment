function plot_singleAmp(stimChan, recChan, recChanLabels, datapath, amplitude, startFileNum)
%startFileNum is the first file of stimulation
%lay out plots as subplots for as many channels/pairs (it's multipolar if
%input is a cell) - for 32 chan arrays lay out width-wise
cols = max(ceil(length(stimChan)/4), 4);
rows = min(ceil(length(stimChan)/4), 4);
fileinfo = dir([datapath '\*.nev']);
%label cuffs, etc
headstage = 'surfs';
colors = [0,121,248; 255,107,0; 0,187,38; 209,0,0; 54,0,219; 255,206,0; 255,0,224]/255;

%starting with the first file number, load each file
figure('Name', [num2str(amplitude) 'uA_datafile' num2str(startFileNum)]);
for i=1:length(stimChan)
    %extract stimulus times
    f = startFileNum + i-1;
    %use grapevine tools (see ns_OpenFile) to extract the raw (ns5) and
    %stim (nev)
    [~,hFile] = ns_OpenFile(fullfile([datapath],fileinfo(f).name));
    [~,hFilens5] = ns_OpenFile(fullfile([filepath],sprintf('datafile%04d.ns5', f)));
    
    %extract analog data
    %get times of stim events
    %TODO: fix this plotting
    [~, chanSnips] = get_analog_filtered(hFile, hFilens5, recChan, headstage);
    
    %take mean and plot
    subplot(rows, cols, i); hold on;
    for j=1:length(recChan)
        plot((-30:(size(chanSnips{1}, 2)-31))/30e3*1000, mean(chanSnips{j}), 'Color', colors(j, :), 'Linewidth', 2)
    end
    title(sprintf('Chan %d - %d %d', stimChan{i, 1}, stimChan{i,2}));
    box off; set(gca,'TickDir','out');
    xlabel('time (ms)')
    ylabel('uV')
    axis tight
end

%make a separate legend
f = figure('Name', 'Legend');
for j=1:length(recChan)
    plot(1, 1, 'Color', colors(j, :), 'Linewidth', 2)
end
set(gca, 'FontSize', 16, 'visible', 'off');
l = legend(recChanLabels);
r = round(f.Position.*l.Position)*1.4;
set(gcf, 'Position', [f.Position(1:2) r(3:4)]);
