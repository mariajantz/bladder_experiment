%MUX stimulator high amplitude surveys, monopolar only
% Because the MUX has a standard layout and channels contradict each other,
% this uses a hard-coded order of stimulus

%% STARTUP: check fastsettle, connect to trellis, connect to MUX
%import cat information
C = experiment_constants_Neville;

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
status = xippmex;
if status == 0
    error('Xippmex is not connecting.')
end

%MUX setup
ser = serial("COM4", "BaudRate",9600)
fopen(ser)

start_mux(ser) 

%set save folders
yr = num2str(year(datetime(datestr(now))));
rootpath = ['D:\DataTanks\' yr '\'];
%rootpath = 'R:\data_raw\cat\' yr '\';
%set save folders
catFolder = dir([rootpath C.CAT_NAME '*']);
savepath = fullfile(rootpath, catFolder.name, 'Documents\\Experiment_Files', C.LOCATION);
datapath = fullfile(rootpath, catFolder.name, 'Grapevine');
baseline_filenum = find_curFile(datapath); 

%% Define cat variables

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


    
%% Stimulation 
%for each channel set, switch MUX, check for success, build staggered train
%then collect baseline data for those channels, then stim 
%Basically, this runs 10 separate high-amplitude surveys back-to-back.
recTime = C.MAX_AMP_REPS/C.STIM_FREQUENCY(1)*size(test_order, 2)+1;
full_sta = cell(size(test_order)); 

for chan = 1:size(test_order, 1)
    %Switch MUX
    [e,s,p] = mux_assign(test_order(chan, :)); %doesn't run stim yet, just spits out electrode numbers - e: electrode site, s: ripple channel, p: command for switching
    switch_mux(ser, p)
    fprintf("Ripple ch%d <==> E%d \n", [s;e])
    
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
    pause(1); 
    
    %TODO check indexing
    baseline_filenum = baseline_filenum+1; 
    %Then stim on "s"
    elec_survey_stim(C, 0.2, sprintf('%s\\datafile', datapath))
    
    chanSnips = elec_survey_split(C, sprintf('%s\\datafile%04d', datapath, baseline_filenum));
    [stim_freqs, response_locs, ~] = find_response(C, chanSnips(C.SEARCH_CUFFS_IDX, :), baseline_wf); 
    stim_freqs = floor(1./(1./stim_freqs+.005));
    
    %TODO remap the means of these snips onto the test_order array
    
    baseline_filenum = baseline_filenum+1; 
    % TODO now figure out how to store all important info and move on to next set
    keyboard
end


%% Plotting
%layout according to the test_order layout







