C = experiment_constants_Molson;
savepath = sprintf('D:\\DataTanks\\2019\\%s\\Documents\\Experiment_Files\\', C.CAT_NAME); %file path for saving constants/run info
savepath = [savepath C.LOCATION '\'];
datapath = sprintf('D:\\DataTanks\\2019\\%s\\Grapevine', C.CAT_NAME);

% define constants
%input channel vector, amp vector, freq vector, stimTime scalar
%inter stimulus time (for several bursts of stim)

plot_chan = [1:3];

chans = cell2mat(C.STIM_MAP);
%chans = [3 7; 4 8; 14 18; 15 19; 18 22; 19 23; 21 25]; %make vertical array
%chans = chans + C.ACTIVE_CHAN(1) - 1;
amps = [25 26 27 28 29]; %get several amplitudes - sub threshold eng, emg, super, long latency
freqs = [3 33];
interstim_time = 30; %in seconds, time between stim sequences applied within a single trial
repeats = 2;
stimTime = 30; %length of time to stimulate 20
pre_quiet = 60; %quiet recording before stim 10
post_quiet = 60; %quiet recording after stim 15
long_rec = 120; %length of longer quiet recordings
bladder_fill_ml = 15; %amount of bladder fill at beginning

total_est_time = ((pre_quiet+post_quiet+stimTime)*repeats + (repeats-1)*interstim_time)*length(amps)*length(freqs)*size(chans, 1);

fprintf('Total time to complete: %.02f hours \n', total_est_time/60/60);

%get a longer quiet recording
[curFile, ~] = find_curFile(datapath, 'testing', 0, 'datafiles', []);
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
    stimChan = chans(c, :);
    
    for a = 1:length(amps)
        %amp = amps(c) + (a-1)*10; %switch to amps(a) if looping multiple amps
        amp = amps(a);
        for f = 1:length(freqs)
            freq = freqs(f);
            fprintf('Stim on channel %d at %d uA and %d Hz\n', stimChan, amp, freq);
            C.THRESH_REPS = stimTime*freq;
            %fprintf('Channel %d Frequency %d\n', chans(c), freq(f));
            % find the command necessary for this burst
            %[cmd, stimTime] = single_amp_cathodal_stim(C, chans(c), amps, freq(f));
            %[cmd, stimTime] = single_amp_cathodal_stim(C, stimChan, amp, freq); %many monopoles stim (whack the cord)
            [cmd, stimTime] = single_elec_stim_cmd(C, stimChan, amp, freq); %multipolar stim
            %add the number of repeats necessary
            totalTime = ceil(stimTime * repeats + pre_quiet + post_quiet + interstim_time*(repeats-1));
            
            % trigger recording
            xippmex('trial', 'recording', [datapath '\datafile'], 0, 1);
            % xippmex('trial', opers, 'recording');
            %xippmex('digout', C.DIG_TRIGGER_CHAN, 1); %digital triggering
            
            % quiet recording
            fprintf('Quiet recording for %.1f s\n', pre_quiet);
            temptime = tic;
            
            %during this time, load the last file analog and stim data
            close(h);
            last_file = [datapath sprintf('\\datafile%04d', filenums(end))];
            
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
            stimTime = zeros(1,numEvts);
            for i = numEvts:-1:1
                [~, stimTime(i), ~, ~] = ns_GetSegmentData(hFile, stim_in(1), i);
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
            title(sprintf('Stim chan: %d %d, Freq: %d, Amp: %d, File: %d', stimChan, freq, amp, filenums(end)));
            %plot stimChan
            plot(sort([stimTime stimTime stimTime]), repmat([0 3 NaN], 1, length(stimTime)));
            box off;
            set(gca, 'TickDir', 'out', 'FontSize', 14);
            %legend({'Urethra 1', 'Urethra 2', 'Bladder', 'Stim'}, 'northeast');
            
            savefig(fullfile(savepath, sprintf('fxnltest_%d', filenums(end))));
            clear cathWf;
            
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
            
            save(sprintf('%sfunctional_stim%04d', savepath, curFile), 'stimChan', 'amp', 'freq', 'C', 'interstim_time',...
                'repeats', 'filenums', 'curFile', 'pre_quiet', 'post_quiet', 'cmd', 'bladder_fill_ml', 'c', 'a', 'f');
            curFile = curFile + 1;
        end
    end
end
%save(sprintf('%sfunctional_stim_set%04d', savepath, curFile), 'chans', 'amps', 'freq', 'C', 'interstim_time', 'repeats', 'filenums');

disp('Done with stimulation');
