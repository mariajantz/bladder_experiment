
C = experiment_constants_Rubeus;
yr = num2str(year(datetime(datestr(now))));
savepath = sprintf('D:\\DataTanks\\%s\\%s\\Documents\\Experiment_Files\\', yr, C.CAT_NAME); %file path for saving constants/run info
savepath = [savepath C.LOCATION '\'];
datapath = sprintf('D:\\DataTanks\\%s\\%s\\Grapevine', yr, C.CAT_NAME);

% define constants
%input channel vector, amp vector, freq vector, stimTime scalar
%inter stimulus time (for several bursts of stim)

plot_chan = [1]; %analog channels to plot

%chans = cell2mat(C.STIM_MAP); %n x 2 array - for fast sweep use this
chans = [5 6; 4 11; 6 13; 31 32]; %for mult amps: 31 32 400; 6 13 100, 200, 300. 
%chans = [2 9]; 
all_amps = {[500]};%{[500]}; %get several amplitudes - sub threshold eng, emg, super, long latency {300,[100 200],300}
%all_amps = {}
freqs = [3 33]; %quick - 33, slow - [3 33]
interstim_time = 30; %ignore in seconds, time between stim sequences applied within a single trial
repeats = 1; %ignore
stimTime_cmd = [60 20]; %length of time to stimulate [60 20] - quick 15
pre_quiet = 60; %quiet recording before stim 60 - quick 10
post_quiet = 60; %quiet recording after stim 60 - quick 10
long_rec = 0; %length of longer quiet recordings
bladder_fill_ml = 14; %amount of bladder fill at beginning


total_est_time = (((pre_quiet+post_quiet+sum(stimTime_cmd))*repeats + (repeats-1)*interstim_time))*length(all_amps{1})*length(freqs)*size(chans, 1);

fprintf('Total time to complete: %.02f hours \n', total_est_time/60/60);

%get a longer quiet recording
%[curFile, ~] = find_curFile(datapath, 'testing', 0, 'datafiles', []);
% fprintf('Quiet recording for %.1f s\n', long_rec);
% xippmex('trial', 'recording', [datapath '\datafile'], 0, 1);
% pause(long_rec);
%
% xippmex('trial', 'stopped');
% pause(1);
% save(sprintf('%squiet_rec%04d', savepath, curFile), 'C', 'curFile', 'long_rec');
%%
for c = 1:size(chans, 1)
    filenums = [];
    [curFile, ~] = find_curFile(datapath, 'testing', 0, 'datafiles', []);
    stimChan = chans(c, :); %chans{c};
    amps = all_amps{1}; %switch between 1 and c
    
    for a = 1:length(amps)
        %amp = amps(c) + (a-1)*10; %switch to amps(a) if looping multiple amps
        amp = amps(a);
        for f = 1:length(freqs)
            freq = freqs(f);
            fprintf('Stim on channel %s at %d uA and %d Hz\n', mat2str(stimChan), amp, freq);
            C.THRESH_REPS = stimTime_cmd(f)*freq;
            %fprintf('Channel %d Frequency %d\n', chans(c), freq(f));
            % find the command necessary for this burst
            %[cmd, stimTime] = single_amp_cathodal_stim(C, chans(c), amps, freq(f));
            %[cmd, stimTime] = single_amp_cathodal_stim(C, stimChan, amp, freq); %many monopoles stim (whack the cord)
            [cmd, stimTime] = single_elec_stim_cmd(C, stimChan, amp, freq); %multipolar stim
            %add the number of repeats necessary
            totalTime = ceil(stimTime * repeats + pre_quiet + post_quiet + interstim_time*(repeats-1));
            
            % trigger recording
            xippmex('trial', 'recording', [datapath '\datafile'], 0, 1);
            %xippmex('trial', 'recording', [datapath '\datafile'], 0, 1, [], 148);
            % xippmex('trial', opers, 'recording');
            %xippmex('digout', C.DIG_TRIGGER_CHAN, 1); %digital triggering
            
            % quiet recording
            fprintf('Quiet recording for %.1f s\n', pre_quiet);
            temptime = tic;
            
            %during this time, load the last file analog and stim data
            try
                close(h);
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
                for lr = fliplr(plot_chan)
                    plot(1/30e3:1/30e3:length(cathWf(lr, :))/30e3, cathWf(lr, :), 'LineWidth', lwidth(lr));
                end
                xlabel('Time (s)');
                ylabel('Pressure (mmHg)');
                xlim([0 length(cathWf(lr, :))/30e3]);
                ylim([0 60]);
                title(sprintf('Stim chan: %s, Freq: %d, Amp: %d, File: %d', mat2str(last_stimChan), last_freq, last_amp, curFile-1));
                %plot stimChan
                plot(sort([stimTimes stimTimes stimTimes]), repmat([0 3 NaN], 1, length(stimTimes)));
                box off;
                set(gca, 'TickDir', 'out', 'FontSize', 14);
                %legend({'Urethra 1', 'Urethra 2', 'Bladder', 'Stim'}, 'northeast');
                
                savefig(fullfile(savepath, sprintf('fxnltest_%d', curFile-1)));
                saveas(gcf, fullfile(savepath, sprintf('fxnltest_%d.png', curFile-1)));
                
            catch ME
                disp('No open plot to close');
                h = figure;
            end
            
            extra_pause = pre_quiet-toc(temptime);
            if extra_pause > 0
                pause(extra_pause);
            end
            
            for i = 1:repeats
                % stimulate on all channels
                xippmex('stimseq', cmd);
                fprintf('Stimulating for %.1f s\n', stimTime)
                pause(stimTime); %pause to let stimulation finish
                
                if i~=repeats
                    disp('Pause before repeat');
                    pause(interstim_time);
                end
                
            end
            
            % post stim time
            fprintf('Quiet recording for %.1f s\n', post_quiet);
            pause(post_quiet);
            
            xippmex('trial', 'stopped');
            pause(1);
            
            filenums = [filenums curFile];
            last_stimChan = stimChan;
            last_freq = freq;
            last_amp = amp;
            
            save(sprintf('%sfunctional_stim%04d', savepath, curFile), 'stimChan', 'amp', 'freq', 'C', 'interstim_time',...
                'repeats', 'filenums', 'curFile', 'pre_quiet', 'post_quiet', 'cmd', 'bladder_fill_ml', 'c', 'a', 'f');
            curFile = curFile + 1;
            clear cathWf;
        end
    end
end
%save(sprintf('%sfunctional_stim_set%04d', savepath, curFile), 'chans', 'amps', 'freq', 'C', 'interstim_time', 'repeats', 'filenums');

close(h);
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

disp('Done with stimulation');
