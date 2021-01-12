
%run and save variables for cystometry trials
%starts recording itself, saves variables

%EDIT THESE VARIABLES
stim_on = true;
C = experiment_constants_Beans;

stimChan = {[17]}; %cell array of stim channel rows
amp = 120; %amplitudes of stim for each electrode
freq = [3]; %array of frequencies of stim to test for each electrode
stimTime = 240; %time in seconds, same for all stim (60s for 33Hz, 120s for 3Hz)
max_fill = 10; %maximum fill volume
fill_rate = 1; %mls per minute
fill_start = 10; %seconds into recording that fill was started
notes = 'Cystometry with 3 Hz stuimulation. Single lumen with 3-way connector. We dont have UroMoca recordings.'; 

input('Are the volume fill info and notes set correctly for this trial? Enter to continue ')

%start trial - set up folders and then start recording on Trellis
yr = num2str(year(datetime(datestr(now))));
rootpath = ['D:\DataTanks\' yr '\'];
catFolder = dir([rootpath C.CAT_NAME '*']);
% datapath = fullfile(rootpath, catFolder.name, 'Grapevine');
% savepath = fullfile(rootpath, catFolder.name, 'Documents\\Experiment_Files', C.LOCATION);

[curFile, ~] = find_curFile(datapath, 'testing', 0, 'datafiles', []);
fpath = char(sprintf('%s\\datafile', datapath));

fprintf('Starting recording of cystometry trial NEVfile %d\n', curFile);
% xippmex('trial', 'recording',fpath)
xippmex('trial', 'recording', fpath, 0, 1, [], 148);
recStart = tic;

%save: C files, max volume, fill rate, file number
save([savepath sprintf('\\cystometry%04d', curFile)], 'C', 'curFile', 'max_fill', 'fill_rate', 'fill_start', 'notes')

%% stim

if stim_on
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
    if ~exist(fullfile(savepath, sprintf('cysStim%04d', curFile)), 'file')
        save(fullfile(savepath, sprintf('cysStim%04d', curFile)), 'C', 'curFile', 'stimChan', ...
            'amp', 'freq', 'stimTime', 'max_fill', 'fill_rate', 'fill_start', 'cmd');
    else
        warning('Saving second set of stim for this trial, if running additional stim pulses after this the save will overwrite.')
        save(fullfile(savepath, sprintf('cysStim%04d_%02d', curFile, 2)), 'C', 'curFile', 'stimChan', ...
            'amp', 'freq', 'stimTime', 'max_fill', 'fill_rate', 'fill_start', 'cmd');
    end
    
    
end


