C = experiment_constants_Molson;
savepath = sprintf('D:\\DataTanks\\2019\\%s\\Documents\\Experiment_Files\\', C.CAT_NAME); %file path for saving constants/run info
savepath = [savepath C.LOCATION '\'];
datapath = sprintf('D:\\DataTanks\\2019\\%s\\Grapevine', C.CAT_NAME);

% define constants
%input channel vector, amp vector, freq vector, stimTime scalar
%inter stimulus time (for several bursts of stim)

%chans = cell2mat(C.STIM_MAP);
chans = [8 24]'; 
%chans = [3 7; 4 8; 14 18; 15 19; 18 22; 19 23; 21 25]; %make vertical array
%chans = chans + C.ACTIVE_CHAN(1) - 1;
amps = [25];
freqs = [3 33];
interstim_time = 30; %in seconds, time between stim sequences applied within a single trial
repeats = 1;
stimTime = 30; %length of time to stimulate 20
pre_quiet = 30; %quiet recording before stim 10
post_quiet = 60; %quiet recording after stim 15
long_rec = 120; %length of longer quiet recordings
bladder_fill_ml = 15; %amount of bladder fill at beginning

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
for c = 2:size(chans, 1)
    filenums = [];
    [curFile, ~] = find_curFile(datapath, 'testing', 0, 'datafiles', []);
    stimChan = chans(c, :);

    for a = 1:length(amps)
        if c==2 && a==1
            continue
        end
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
            pause(pre_quiet);
            
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
                'repeats', 'filenums', 'curFile', 'pre_quiet', 'post_quiet', 'cmd', 'bladder_fill_ml');
            curFile = curFile + 1;
        end
    end
end
%save(sprintf('%sfunctional_stim_set%04d', savepath, curFile), 'chans', 'amps', 'freq', 'C', 'interstim_time', 'repeats', 'filenums');

disp('Done with stimulation');
