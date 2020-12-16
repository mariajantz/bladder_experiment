function h = plot_stim_trial(fpath, anChan, stimChan, freq, amp)

%load stim data
[~, hFile] = ns_OpenFile([fpath '.nev']);
tempLabel = {hFile.Entity.Label};
for lbl = 1:length(tempLabel)
    if iscell(tempLabel{lbl})
        tempLabel{lbl} = tempLabel{lbl}{1};
    elseif isempty(tempLabel{lbl})
        tempLabel{lbl} = ''; %convert to string for finding ability
    end
end
stim_in = find(contains(tempLabel, 'stim'));
numEvts = hFile.Entity(stim_in).Count;
stimTimes = zeros(1,numEvts);
for i = numEvts:-1:1
    [~, stimTimes(i), ~, ~] = ns_GetSegmentData(hFile, stim_in(1), i);
end
ns_CloseFile(hFile);

%load analog data
for j=anChan
    cathWf(j, :) = read_continuousData([fpath '.ns5'], 'analog', j);
    if j==1 || j==2
        disp('convert transbridge')
        cathWf(j, :) = cathWf(j, :)/50;
    else
        disp('convert millar');
        cathWf(j, :) = cathWf(j, :)/10;
    end
end

%plot
h = figure('Position', [339 417 953 533]); hold on;
lwidth = [1.5, 1.5, 1.5, 1.5];
for lr = fliplr(anChan)
    plot(1/30e3:1/30e3:length(cathWf(lr, :))/30e3, cathWf(lr, :), 'LineWidth', lwidth(lr));
end
xlabel('Time (s)');
ylabel('Pressure (mmHg)');
xlim([0 length(cathWf(lr, :))/30e3]);
ylim([0 60]);
title(sprintf('Stim chan: %s, Freq: %d, Amp: %d, File: %s', mat2str(stimChan), freq, amp, fpath(end-3:end)));
%plot stimChan
plot(sort([stimTimes stimTimes stimTimes]), repmat([0 3 NaN], 1, length(stimTimes)));
box off;
set(gca, 'TickDir', 'out', 'FontSize', 14);
%legend({'Urethra 1', 'Urethra 2', 'Bladder', 'Stim'}, 'northeast');

