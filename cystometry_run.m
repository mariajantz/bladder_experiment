%Run the entire code: it starts the recording, saves variables, manual stop

%===========================================================================================
%EDIT THESE VARIABLES
stim_on = false;  %stim without using mux
stim_mux = true;  %stim using mux
C = experiment_constants_Dill;

stimChan = {[47]}; %cell array of stim channel rows
amp = 210; %amplitudes of stim for each electrode
freq = [33]; %array of frequencies of stim to test for each electrode
stimTime = 60; %time in seconds (30-60s for 33Hz, 60-120s for 3Hz)

max_fill = 14.5; %maximum fill volume capacity; update per cat
fill_rate = 2; %mls per minute
fill_start = 10; %seconds into recording that fill was started **Give notice
notes =  'Stim cystometry, minimal response on this channel in isovolumetric trials'; %Make sure this is correct each time
%============================================================================================

% Built in pause to check; this begins recording 
input('Are the volume fill info and notes set correctly for this trial? Enter to continue to recording')

%start trial - set up folders and then start recording on Trellis
yr = num2str(year(datetime(datestr(now))));
rootpath = ['D:\DataTanks\' yr '\'];
catFolder = dir([rootpath C.CAT_NAME '*']);
% datapath = fullfile(rootpath, catFolder.name, 'Grapevine');
% savepath = fullfile(rootpath, catFolder.name, 'Documents\\Experiment_Files', C.LOCATION);

[curFile, ~] = find_curFile(datapath, 'testing', 0, 'datafiles', []);
fpath = char(sprintf('%s\\datafile', datapath));

fprintf('Starting recording of cystometry trial NEVfile %d\n', curFile);
%  xippmex('trial', 'recording',fpath)
xippmex('trial', 'recording', fpath, 0, 1, [], 148);
recStart = tic;

%save: C files, max volume, fill rate, file number
save([savepath sprintf('\\cystometry%04d', curFile)], 'C', 'curFile', 'max_fill', 'fill_rate', 'fill_start', 'notes')

%% stim
if stim_mux
    cmd = [];
    %get command and run stimulation
    %for each electrode included in that stim set
    set_monitor(ser,true);
    [mux_chan, ripple_chan, mux_cmd] = mux_assign(stimChan{1});
    fprintf("Ripple ch%d <==> E%d \n", [ripple_chan;mux_chan])
    switch_mux(ser, mux_cmd); 
    
    for i = 1:size(stimChan, 1)
        C.THRESH_REPS = stimTime*freq;
        %[cmd(i), ~] = single_amp_cathodal_stim(C, stimChan(i, :), amps(i), freqs(i)); %all cathodal stim
        [cmd2, ~] = single_elec_stim_cmd(C, ripple_chan(i), amp, freq); %multichannel stim
        cmd = [cmd cmd2];
    end
    
    input('Press Enter to execute stimulation pulse ')
    set_monitor(ser, false);
    xippmex('stimseq', cmd);
    fprintf('Stimulating for %.1f s\n', stimTime)
    
    %for stim: save file number, stimulation channel, stim frequency,
    %amplitude, time period, pulsewidth, polarity
    if ~exist(fullfile(savepath, sprintf('cysStim%04d.mat', curFile)), 'file')
        save(fullfile(savepath, sprintf('cysStim%04d', curFile)), 'C', 'curFile', 'stimChan', ...
            'ripple_chan', 'mux_chan', 'amp', 'freq', 'stimTime', 'max_fill', 'fill_rate', 'fill_start', 'cmd');
    else
        tempfile = dir(fullfile(savepath, sprintf('cysStim%04d*', curFile)));
        warning('Saving additional set of stim for this trial, if running additional stim pulses after this the save will overwrite.')
        save(fullfile(savepath, sprintf('cysStim%04d_%02d', curFile, length(tempfile))), 'C', 'curFile', 'stimChan', ...
            'ripple_chan', 'mux_chan', 'amp', 'freq', 'stimTime', 'max_fill', 'fill_rate', 'fill_start', 'cmd');
    end
    

elseif stim_on
    cmd = [];
    %get command and run stimulation
    %for each electrode included in that stim set
    
    for i = 1:size(stimChan, 1)
        C.THRESH_REPS = stimTime*freq;
        %[cmd(i), ~] = single_amp_cathodal_stim(C, stimChan(i, :), amps(i), freqs(i)); %all cathodal stim
        [cmd2, ~] = single_elec_stim_cmd(C, stimChan{i}, amp, freq); %multichannel stim
        cmd = [cmd cmd2];
    end
    
    input('Press Enter to execute stimulation pulse ')
    
    xippmex('stimseq', cmd);
    fprintf('Stimulating for %.1f s\n', stimTime)
    
    %for stim: save file number, stimulation channel, stim frequency,
    %amplitude, time period, pulsewidth, polarity
    if ~exist(fullfile(savepath, sprintf('cysStim%04d.mat', curFile)), 'file')
        save(fullfile(savepath, sprintf('cysStim%04d', curFile)), 'C', 'curFile', 'stimChan', ...
            'amp', 'freq', 'stimTime', 'max_fill', 'fill_rate', 'fill_start', 'cmd');
    else
        warning('Saving second set of stim for this trial, if running additional stim pulses after this the save will overwrite.')
        save(fullfile(savepath, sprintf('cysStim%04d_%02d', curFile, 2)), 'C', 'curFile', 'stimChan', ...
            'amp', 'freq', 'stimTime', 'max_fill', 'fill_rate', 'fill_start', 'cmd');
    end
    
    
end


