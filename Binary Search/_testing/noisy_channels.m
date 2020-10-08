%test to deal with noisy channels
%944 955 976 995 1031 1073 1089, 1113, 1132
%trial options: 656, 813, 1244
load('R:\data_raw\cat\2018\Dageraad-20180712\Documents\Experiment_Files\Epidural - L7\stimChan_trial1132.mat');
load(sprintf('R:\\data_raw\\cat\\2018\\Dageraad-20180712\\Documents\\Experiment_Files\\Epidural - L7\\experiment_constants%04d', filenums.single_amp-1)); 

%load baseline wf
baseline_wf = load_baseline(C, sprintf('R:\\data_raw\\cat\\2018\\Dageraad-20180712\\Grapevine\\datafile%04d', filenums.baseline));
filenums.baseline
chanSnips = single_amp_split(C, sprintf('R:\\data_raw\\cat\\2018\\Dageraad-20180712\\Grapevine\\datafile%04d', filenums.stim(3)));

[freqs, cuff_resp, resp_times, rms_vals] = find_response(C, chanSnips, baseline_wf, 'outputs', [1 1 1 1])


