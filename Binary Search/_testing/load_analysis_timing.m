datapath = 'D:\DataTanks\TestAnimal\Grapevine';
savepath = 'D:\DataTanks\TestAnimal\testSave\';
curFile = [1554, 1737]; %small, medium files
this_amp = 1000;
load('D:\DataTanks\TestAnimal\Experiment_Files\experiment_constants1306.mat');

times = struct.empty(10, 0);
for i = 1:10
    for j = 1:length(curFile)
        prev_amps = [];
        num_responses = [];
        %load baseline time
        a = tic;
        baseline_wf = load_baseline(C, sprintf('%s\\datafile%04d', datapath, curFile(j)-1));
        times(i, j).load_baseline = toc(a);
        a = tic;
        chanSnips = single_amp_split(C, fullfile(datapath, sprintf('datafile%04d', curFile(j))));
        times(i, j).load_stimResponses = toc(a);
        % find_response for all cuffs
        a = tic;
        [~, cuff_resp, ~] = find_response(C, chanSnips, baseline_wf);
        num_responses = [num_responses sum(cuff_resp)];
        fprintf('Number of responses found: %d\n', sum(cuff_resp));
        times(i, j).find_response = toc(a);
        % determine_amplitude
        %TODO maybe add an amplitude one higher than the last one
        a = tic;
        prev_amps = [prev_amps this_amp];
        next_amp = determine_amplitude(num_responses, prev_amps, C.AMP_MIN_DIFF, C.AMP_MAX_DIFF);
        times(i, j).find_nextAmplitude = toc(a);
        a = tic;
        save(sprintf('%sstimChan_trial%04d', savepath, curFile), 'prev_amps', 'num_responses');
        times(i, j).saveFile = toc(a);
    end
end

%large file
% datapath = 'D:\data_raw\cat\2018\Dageraad-20180712\Grapevine';
load('D:\DataTanks\TestAnimal\Experiment_Files\experiment_constants1652.mat')
curFile = 1653;
for i = 1:10
    a = tic;
    baseline_wf = load_baseline(C, sprintf('%s\\datafile%04d', datapath, curFile-1));
    times(i, 3).load_baseline = toc(a);
    a = tic;
    chanSnips = max_amp_split(C, sprintf('%s\\datafile%04d', datapath, curFile));
    times(i, 3).load_stimResponses = toc(a);
    a = tic;
    [stim_freqs, response_locs, ~] = find_response(C, chanSnips, baseline_wf); %TODO test for both max amp and single amp
    stim_freqs = floor(1./(1./stim_freqs+.005));
    times(i, 3).find_response = toc(a);
    % save values that were chosen to mat file for plotting elsewhere
    a = tic;
    filenums.baseline = curFile; filenums.single_amp = curFile +1;
    save(sprintf('%ssingle_amp_survey%04d', savepath, curFile), 'C', 'filenums', 'stim_freqs', 'response_locs');
    times(i, 3).saveFile = toc(a);
end

save([savepath 'allTiming'], 'times'); 