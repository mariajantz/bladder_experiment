%MUX stimulator high amplitude surveys, monopolar only
% Because the MUX has a standard layout and channels contradict each other,
% this uses a hard-coded order of stimulus

%% 1 STARTUP: check fastsettle, set save folders
%import cat information
C = experiment_constants_Beans;
%set save folders
yr = C.SURGERY_DATE(1:4);% num2str(year(datetime(datestr(now))));
rootpath = ['D:\DataTanks\' yr '\'];

if ~exist([rootpath C.CAT_NAME], 'dir')
    mkdir([rootpath C.CAT_NAME])
    mkdir(fullfile(rootpath, catFolder.name, 'Grapevine'))
end
%rootpath = 'R:\data_raw\cat\' yr '\';
%set save folders
catFolder = dir([rootpath C.CAT_NAME '*']);
%savepath = fullfile(rootpath, catFolder.name, 'Documents\\Experiment_Files', C.LOCATION);
savepath = fullfile(rootpath, catFolder.name, 'Documents\\Experiment_Files', date, C.LOCATION);
datapath = fullfile(rootpath, catFolder.name, 'Grapevine');

if ~exist(savepath)
    mkdir(savepath)
end

status = xippmex;
if status == 0
    error('Xippmex is not connecting.')
end

%% connect to trellis, connect to MUX
uro_on = false;

warning('Is fast-settle on?')

keyboard

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
ser = serial("COM4", "BaudRate",9600)
fopen(ser)

start_mux(ser) 



%% 2 Define cat variables

%layout in terms of MUX channel label
channel_layout = [18, 1, 5, 17, 37; 32, 8, 2, 6, 27; 28, 0, 4, 16, 26; ...
    19, 9, 3, 7, 31; 39, 20, 23, 15, 51; 50, 34, 21, 24, 42; ...
    40, 11, 13, 35, 46; 45, 10, 22, 25, 41];

%choose all the channel sets, excluding any sets that would error
test_order = [18, 0, 23, 35; ...
    1, 4, 15, 46; ...
    5, 16, 51, 40; ...
    17, 26, 20, 13; ...
    37, 28, 21, 25; ...
    32, 9, 24, 41; ...
    8, 3, 39, 11; ...
    2, 7, 42, 45; ...
    6, 31, 50, 10; ...
    27, 19, 34, 22]; 

%test_order = [5, 50, 42, 8; 4, 13, 20, 39; 3, 9, 24, 2]; 

% Stimulation 
%for each channel set, switch MUX, check for success, build staggered train
%then collect baseline data for those channels, then stim 
%Basically, this runs 10 separate high-amplitude surveys back-to-back.
C.MAX_AMP = 190; %avo - start 200, beans - start 120
bladder_fill = '3.5 ml'; 

baseline_filenum = find_curFile(datapath); 
recTime = C.MAX_AMP_REPS/C.STIM_FREQUENCY(1)*size(test_order, 2)+1;
full_sta = cell(size(channel_layout));
ripple_chan = nan(size(test_order));
baseline_nums = nan(size(test_order, 1), 1); 
survey_nums = nan(size(test_order, 1), 1); 

fwrite(ser, [2, 100, 0, 133])  % to disable MUX check

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
    
    fwrite(ser, [2, 30, 0, 133]) % To enable MUX check again
    
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
    fwrite(ser, [2, 100, 0, 133])  % to disable MUX check
    pause(1); 
    
end

test_order(isnan(ripple_chan)) = nan;
fwrite(ser, [2, 30, 0, 133]) % To enable MUX check again

% Plotting
%layout according to the test_order layout

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



%% indiv channel tests
%Avocado: 9 at 170 is fine, 200 she doesn't like, chan 15 at 170 has strong
%leg shakes and at 100 is uncomfortable, 115 is absolute max; chan 50 is fine at 100
%but she's uncomfortable at 120. 
test_chan = {17, 37};
cathAmp = 150; 
freq = 33;
stimTime = 20;
C.THRESH_REPS = stimTime*freq;
C.QUIET_REC = 20; 
bladder_fill = '1.3 ml'; 
%datapath = fullfile(rootpath, catFolder.name, 'Grapevine');

for i = 1:length(test_chan)
    fwrite(ser, [2, 100, 0, 133])  % to disable MUX check
    trial_chan = test_chan{i}; 
    [e,s,p] = mux_assign(trial_chan);
    fprintf("Ripple ch%d <==> E%d \n", [s;e])
    
    switch_mux(ser, p); 
    %pause?
    %rename datapath
    baseline_filenum = find_curFile(datapath); 
    %fpath = sprintf('%s\\datafile%04d', datapath, baseline_filenum); 
    fpath = sprintf('%s\\datafile', datapath); 
    single_amp_stim(C, s, cathAmp, freq, fpath)
    fprintf('Save info!!\n')
    save(sprintf('%s\\trial_vars%04d', savepath, baseline_filenum), 'trial_chan', 'channel_layout', 'bladder_fill', 'C', 'stimTime', 'cathAmp', 'freq')
    
    fpath = sprintf('%s\\datafile%04d', datapath, baseline_filenum); 
    h = plot_stim_trial(fpath, 1, trial_chan, freq, cathAmp)
    savefig(fullfile(savepath, sprintf('fxnltest_%d', baseline_filenum)));
    saveas(gcf, fullfile(savepath, sprintf('fxnltest_%d.png', baseline_filenum)));

end

disp('Stim complete and data saved');
