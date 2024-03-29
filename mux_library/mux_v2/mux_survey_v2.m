%Run these section by section
%% (1) STARTUP: check fastsettle, set save folders
%import cat information; is this your cat?
C = experiment_constants_Dill;
%set save folders
yr = C.SURGERY_DATE(1:4);% num2str(year(datetime(datestr(now))));
rootpath = ['D:\DataTanks\' yr '\'];

if ~exist([rootpath C.CAT_NAME], 'dir')
    mkdir([rootpath C.CAT_NAME])
    catFolder = dir([rootpath C.CAT_NAME '*']);
    mkdir(fullfile(rootpath, catFolder.name, 'Grapevine'))
else
    catFolder = dir([rootpath C.CAT_NAME '*']);
end
%rootpath = 'R:\data_raw\cat\' yr '\';
%set save folders

savepath = 'C:\Dill_explant_10_21\Epidural - MUX';
% savepath = fullfile(rootpath, catFolder.name, 'Documents\\Experiment_Files', date, C.LOCATION);
% datapath = fullfile(rootpath, catFolder.name, 'Grapevine');
datapath = 'C:\Dill_explant_10_21\Grapevine';

if ~exist(savepath)
    mkdir(savepath)
end

status = xippmex;
if status == 0
    error('Xippmex is not connecting.')
end

warning('Is fast-settle on?')
keyboard

%% (2.1) Connect to Trellis and to MUX
% uro_on = false;
%If in TCP mode, run this one time at the beginning of testing
% set up to trigger recording
% status = xippmex('tcp');
% if status == 0
%     error('Xippmex is not connecting.')
% end
% 
% oper = 148;
% xippmex('addoper', oper);

%MUX setup
ser = serial("COM6", "BaudRate",9600)
fopen(ser)

%to delete stuff: 
%delete(instrfindall)
%clear ser
%then re-run

%% (2.2) After connecting to the cat, try running this - 
%If it is connecting it should do the long flashes then turn off the blue
%LED, if it's not connecting to the array it should do long blue flashes 
%and then quick flashes.
start_mux(ser) 
pause(12); %Wait to see if the mux connects
set_monitor(ser,true) % monitor on
% set_monitor(ser, false) % monitor off

%% (3) High Amp Survey
%Use this until you settle on amp then move to (4) Individual channel tests
%Amp will depend on stim/comfort
%MUX stimulator high amplitude surveys, monopolar only
% Because the MUX has a standard layout and channels contradict each other,
% this uses a hard-coded order of stimulus

C.MAX_AMP = 500; % uA
bladder_fill = 'unknown post surgery'; 
%layout in terms of MUX channel label
channel_layout = C.LAYOUT_MAP; 

%choose all the channel sets, excluding any sets that would error
test_order = [30 1 25 35; ...
    2 5 42 50; ...
    6 9 57 40; ...
    28 52 39 33; ...
    58 38 22 34; ...
    55 0 23 27; ...
    20 4 26 43; ...
    3 8 44 48; ...
    7 45 56 32; ...
    36 47 41 24]; 

%test_order = [5, 50, 42, 8; 4, 13, 20, 39; 3, 9, 24, 2]; 

% Stimulation 
%for each channel set, switch MUX, check for success, build staggered train
%then collect baseline data for those channels, then stim 
%Basically, this runs 10 separate high-amplitude surveys back-to-back.

baseline_filenum = find_curFile(datapath); 
recTime = C.MAX_AMP_REPS/C.STIM_FREQUENCY(1)*size(test_order, 2)+1;
full_sta = cell(size(channel_layout));
ripple_chan = nan(size(test_order));
baseline_nums = nan(size(test_order, 1), 1); 
survey_nums = nan(size(test_order, 1), 1); 

set_monitor(ser, false) % monitor off % to disable MUX check

for chan = 1:size(test_order, 1)
    %Switch MUX
    [e,s,p] = mux_assign(test_order(chan, :)); %doesn't run stim yet, just spits out electrode numbers - e: electrode site, s: ripple channel, p: command for switching
    switch_mux(ser, p)
    fprintf("Ripple ch%d <==> E%d \n", [s;e])
    if length(s)== size(test_order, 2)
        ripple_chan(chan, :) = s; 
    else
        fprintf('Chan to test were %d %d %d %d, Actual were %d %d %d\n. Label associated Ripple channels (s) and non-tested channels in test_order array will be set automatically.\n', ...
            test_order(chan, :), e)
        ripple_chan(chan, 1:3) = s;
    end
    
    %Update C to include only these 4 channels
    C.STIM_MAP = num2cell(s)';
    
    %save the file with info here
    if ~exist(sprintf('%s\\experiment_constants%04d.mat', savepath, baseline_filenum), 'file')
        save(sprintf('%s\\experiment_constants%04d', savepath, baseline_filenum), 'C')
    else
        error('File number not incremented, stopping now to avoid overwriting previous file.');
    end
    
    %Collect baseline data for these trials
    baseline_wf = collect_baseline(C, recTime, sprintf('%s\\datafile%04d', datapath, baseline_filenum));
    %baseline_wf = collect_baseline_uromoca(C, recTime, sprintf('%s\\datafile%04d', datapath, baseline_filenum), s, session, ao_scale); 
    pause(1); 
    
    %TODO check indexing
    baseline_filenum = baseline_filenum+1; 
    %Then stim on "s"
    elec_survey_stim(C, 0.2, sprintf('%s\\datafile', datapath))
    
    set_monitor(ser, true) % monitor off% To enable MUX check again
    
    chanSnips = elec_survey_split(C, sprintf('%s\\datafile%04d', datapath, baseline_filenum));
    [stim_freqs, response_locs, ~] = find_response(C, chanSnips(C.SEARCH_CUFFS_IDX, :), baseline_wf); 
    stim_freqs = floor(1./(1./stim_freqs+.005));
    
    % TODO now store all important info and move on to next set
    %Mean snips need to go into channel layout array locations for plotting
    mnSnips = cellfun(@mean,chanSnips, 'UniformOutput', 0); 
    for i = 1:length(e)
        [row, col] = find(channel_layout==e(i));
        full_sta(row, col) = {cell2mat(mnSnips(:, i))}; 
        
    end
    %save the baseline and survey file numbers
    baseline_nums(chan) = baseline_filenum-1; 
    survey_nums(chan) = baseline_filenum;
    
    baseline_filenum = baseline_filenum+1; 
    pause(2); 
    set_monitor(ser, false) % monitor off % to disable MUX check
    pause(1); 
    
end

test_order(isnan(ripple_chan)) = nan;
fwrite(ser, [2, 30, 0, 133]) % To enable MUX check again

% Plotting
%layout according to the test_order layout %TODO check this

figure;
plotchan = 1:5; 
channel_layout_rotate = channel_layout'; 
full_sta_rotate = full_sta'; 
%loop all channels
for i = 1:numel(channel_layout)
    if isempty(full_sta_rotate{i})
        continue
    end
    subplot(size(channel_layout, 1), size(channel_layout, 2), i);
    hold on
    plot(full_sta_rotate{i}(plotchan, :)'); 
    axis tight
    title(sprintf('Channel %d',channel_layout_rotate(i))); 
end

set(gcf, 'Position', [1681 11 1920 963])
legend(C.BIPOLAR.CUFF_LABELS)

savefig(sprintf('%s\\survey%04d_%duA', savepath, baseline_filenum, C.MAX_AMP))
save(sprintf('%s\\survey_vars%04d', savepath, baseline_filenum), 'baseline_nums', 'survey_nums', 'ripple_chan', 'full_sta', 'test_order', 'channel_layout', 'bladder_fill')

disp('Survey complete');

%% (4) Individual channel tests (Isovolumetric)
%This informs our channels for behavior trials; keep note of strong
%responses.
channel_layout = C.LAYOUT_MAP; 

%============================================================================================================
%EDIT THESE VARIABLES
%test_chan = num2cell(reshape(channel_layout, 1, numel(channel_layout))); %all the channels
% byrow = {[30, 2, 6, 28, 58], [55, 20, 3, 7, 36], [38, 1, 5, 9, 52], [47, 0, 4, 8, 45], [39, 22, 25, 42, 57], [56, 41, 23, 26, 44], [40, 33, 34, 35, 50], [48, 32, 24,27, 43]};
test_chan = {57}; %0
%22,25,42,57,0 CP on grounded board dex
% {40, 47, 27, 33, 5, 6, 20}; % 3Hz relax candidates
% {57,42,22,39,8,25,0,23}; % 33Hz void candidates {42} 3Hz void
cathAmp = 210; 
freq = 3; %33Hz to evoke void, 3Hz to relax bladder generally
stimTime = 20; %time in seconds (20s for 33Hz, 60 for 3Hz)
C.THRESH_REPS = stimTime*freq;
C.QUIET_REC = 20; %10 for dex, 20 for behaving 33, 40 for behaving 3
bladder_fill = 'about 16 ml'; %Update this before you start running!
%datapath = fullfile(rootpath, catFolder.name, 'Grapevine');
%============================================================================================================

for i = 1:length(test_chan)
%     fwrite(ser, [2, 100, 0, 133])  % to disable MUX check
    trial_chan = test_chan{i}; 
    %trial_chan = test_chan{1}; used for impedance 
    [e,s,p] = mux_assign(trial_chan); %p is a command sent to mux; s is ripple; e is original chan
    fprintf("Ripple ch%d <==> E%d \n", [s;e])
    
    switch_mux(ser, p); 
    %pause?
    %rename datapath
    baseline_filenum = find_curFile(datapath); 
    %fpath = sprintf('%s\\datafile%04d', datapath, baseline_filenum); 
    fpath = sprintf('%s\\datafile', datapath); 
    set_monitor(ser, false);  % to disable MUX check
    single_amp_stim(C, s, cathAmp, freq, fpath)
    
%     cmd = single_elec_stim_cmd(C, s, cathAmp, freq);
%     pause(C.QUIET_REC); 
%     set_monitor(ser, false);
%     xippmex('stimseq', cmd);
%     set_monitor(ser, true); 
%     pause(C.QUIET_REC); 
    fprintf('Save info!!\n')
    save(sprintf('%s\\trial_vars%04d', savepath, baseline_filenum), 'trial_chan', 'channel_layout', 'bladder_fill', 'C', 'stimTime', 'cathAmp', 'freq')
    set_monitor(ser, true); 
    fpath = sprintf('%s\\datafile%04d', datapath, baseline_filenum); 
    h = plot_stim_trial(fpath, 1, trial_chan, freq, cathAmp)
    savefig(fullfile(savepath, sprintf('fxnltest_%d', baseline_filenum)));
    saveas(gcf, fullfile(savepath, sprintf('fxnltest_%d.png', baseline_filenum)));
% Comment plot below out if not recording from SurfS2-EMG/ENG
    h2 = plot_eng_trial(fpath, C, trial_chan, freq, cathAmp)
    savefig(fullfile(savepath, sprintf('fxnltesteng_%d', baseline_filenum)));
    saveas(gcf, fullfile(savepath, sprintf('fxnltesteng_%d.png', baseline_filenum)));
end

disp('Stim complete and data saved');
