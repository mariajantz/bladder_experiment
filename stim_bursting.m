%do pulsing - designed for functional tests where animal voided AFTER stim
%ended, so that we could start/stop rapidly

C = experiment_constants_Rumpus;
yr = num2str(year(datetime(datestr(now))));
savepath = sprintf('D:\\DataTanks\\%s\\%s\\Documents\\Experiment_Files\\', yr, C.CAT_NAME); %file path for saving constants/run info
savepath = [savepath C.LOCATION '\'];
datapath = sprintf('D:\\DataTanks\\%s\\%s\\Grapevine', yr, C.CAT_NAME);

% define constants
%input channel vector, amp vector, freq vector, stimTime scalar
%inter stimulus time (for several bursts of stim)

plot_chan = [1]; %analog channels to plot

bladder_fill_ml = 7; %amount of bladder fill at beginning
stimChan = [10 18];
amp = 400;%{[500]}; %get several amplitudes - sub threshold eng, emg, super, long latency {300,[100 200],300}
freq = 33; %quick - 33

number_burst_cycles = 12; %number of times to burst/gap
each_burst_time = 3; %length of each burst in seconds
gap_time = 2; %time between bursts in seconds

pre_quiet = 30; %quiet recording before stim 60 - quick 10
post_quiet = 30; %quiet recording after stim 60 - quick 10

%% Do stim

[curFile, ~] = find_curFile(datapath, 'testing', 0, 'datafiles', []);

total_burst_time = number_burst_cycles*(each_burst_time+gap_time); %time of full train in seconds
fprintf('Will burst for a total time of %d seconds\n', total_burst_time);

%start data collection and track time
xippmex('trial', 'recording', [datapath '\datafile'], 0, 1);
fprintf('Quiet recording for %.1f s\n', pre_quiet);
pause(pre_quiet)

for i = 1:number_burst_cycles
    %build pulse, wait until ready to send
    C.THRESH_REPS = each_burst_time*freq;
    [cmd, stimTime] = single_elec_stim_cmd(C, stimChan, amp, freq);
    
    %apply pulse
    xippmex('stimseq', cmd);
    fprintf('Stimulating for %.1f s\n', stimTime)
    pause(stimTime); %pause to let stimulation finish
    
    %gap time
    if i < number_burst_cycles
        pause(gap_time);
    end
end

% post stim time
fprintf('Quiet recording for %.1f s\n', post_quiet);
pause(post_quiet);

xippmex('trial', 'stopped');
pause(1);

save(sprintf('%sfunctional_stim_burst%04d', savepath, curFile), 'stimChan', 'amp', 'freq', 'C', ...
    'curFile', 'pre_quiet', 'post_quiet', 'cmd', 'bladder_fill_ml', 'number_burst_cycles', 'each_burst_time', 'gap_time');

%% plotting yikes
curFile = curFile + 1; 
last_file = [datapath sprintf('\\datafile%04d', curFile-1)];

%load stim data
[~, hFile] = ns_OpenFile([last_file '.nev']);
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
for j=1:4
    cathWf(j, :) = read_continuousData([last_file '.ns5'], 'analog', j);
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
for c = fliplr(plot_chan)
    plot(1/30e3:1/30e3:length(cathWf(c, :))/30e3, cathWf(c, :), 'LineWidth', lwidth(c));
end
xlabel('Time (s)');
ylabel('Pressure (mmHg)');
xlim([0 length(cathWf(c, :))/30e3]);
ylim([0 60]);
title(sprintf('Stim chan: %d %d, Freq: %d, Amp: %d, File: %d', last_stimChan, last_freq, last_amp, curFile-1));
%plot stimChan
plot(sort([stimTimes stimTimes stimTimes]), repmat([0 3 NaN], 1, length(stimTimes)));
box off;
set(gca, 'TickDir', 'out', 'FontSize', 14);
%legend({'Urethra 1', 'Urethra 2', 'Bladder', 'Stim'}, 'northeast');

savefig(fullfile(savepath, sprintf('fxnltest_%d', curFile-1)));
saveas(gcf, fullfile(savepath, sprintf('fxnltest_%d.png', curFile-1)));

