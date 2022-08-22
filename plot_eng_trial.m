function plotHandle = plot_eng_trial(dataPath, C, stimChan, freq, amp)
% %plot all the ENG/EMG traces from the most recent channel
% C = experiment constants for a trial
% dataPath = where to find the Trellis data

%load individual traces
chanSnips = cell(size(C.BIPOLAR.CUFF_CHANNELS, 2), 1);

% split all channels into snippets
chanSnips(:) = single_amp_split(C, dataPath);
clrs = [10,100,113; 217,95,2; 236,169,0; 84,0,121;...
102,166,30; 175,0,3; 60,136,255; 231,41,138]/255;
figure; hold on; 
for j = 1:size(chanSnips, 1)
    %plot the mean traces for each nerve cuff
    temptrace = mean(chanSnips{j, 1}, 1);
    xvals = [1/C.REC_FS:1/C.REC_FS:length(temptrace)/C.REC_FS]*1000;
    plotHandle = plot(xvals, temptrace, 'Linewidth', 2, 'Color', clrs(j, :));
end

box off;
set(gca, 'TickDir', 'out', 'FontSize', 14);
axis tight;
title(sprintf('Stim chan: %s, Freq: %d, Amp: %d, File: %s', mat2str(stimChan), freq, amp, dataPath(end-3:end)));
legend(C.BIPOLAR.CUFF_LABELS); 
