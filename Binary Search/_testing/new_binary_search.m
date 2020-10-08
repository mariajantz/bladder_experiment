% a new binary search setup that allows easier testing (input certain
% files) as well as splitting up the max amp survey and the actual binary
% search.

%TODO: update monopolar multi headstage stim splitting.
C = experiment_constants_Neville;

warning('Is fast-settle on?')
keyboard

% set up to trigger recording
% status = xippmex('tcp');
% if status == 0
%     error('Xippmex is not connecting.')
% end
% 
% oper = 148;
% xippmex('addoper', oper);

%% set up testing parameters and paths

stim_on = true; % whether or not to stimulate; true in actual experiment
load_existing_data = false; % whether or not to use recorded files for processing; false in actual experiment

if load_existing_data
    single_amp_num = 585; %change this as necessary 
    
    rootpath = 'R:\data_raw\cat\2019\';
    %set save folders
    catFolder = dir([rootpath C.CAT_NAME '*']);
    loadpath = fullfile(rootpath, catFolder.name, 'Documents\\Experiment_Files', C.LOCATION);
    savepath = 'R:\users\mkj8\testing\experiment_testing';
    datapath = fullfile(rootpath, catFolder.name, 'Grapevine');
    
    %load file numbers for testing TODO make better
    
    %check if single amp num given is the last one before the next stimChan
    %files
    all_surveys = dir([loadpath '\single_amp*']); 
    all_survey_nums = cellfun(@(x) str2num(x(end-7:end-4)), {all_surveys.name}, 'UniformOutput', true); 
    all_searchChan = dir([loadpath '\stimChan*']); 
    all_searchChan_nums = cellfun(@(x) str2num(x(end-7:end-4)), {all_searchChan.name}, 'UniformOutput', true); 
    first_searchChan = all_searchChan_nums(find(all_searchChan_nums>single_amp_num, 1)); 
    last_survey_idx = find(all_survey_nums<first_searchChan, 1, 'last'); 
    if all_survey_nums(last_survey_idx) ~= single_amp_num
        %it's possible you want to troubleshoot a weird survey so don't
        %force this issue: 
        tf = input(sprintf('Update survey to number %d so it is last one before the search continued? Enter true/false: ', last_survey));
        if tf 
            single_amp_num = all_survey_nums(last_survey_idx); 
        end
    end
    %find all the files that were used for stimulation of individual channels
    searchChan_files = all_searchChan_nums(all_searchChan_nums>all_survey_nums(last_survey_idx) & all_searchChan_nums<all_survey_nums(last_survey_idx+1)); 
    
    load(fullfile(loadpath, sprintf('single_amp_survey%04d.mat', single_amp_num))); 
    baselinefile = filenums.baseline;
    surveyfile = filenums.single_amp;
else
    yr = num2str(year(datetime(datestr(now))));
    rootpath = ['D:\DataTanks\' yr '\'];
    %rootpath = 'R:\data_raw\cat\' yr '\';
    %set save folders
    catFolder = dir([rootpath C.CAT_NAME '*']);
    savepath = fullfile(rootpath, catFolder.name, 'Documents\\Experiment_Files', C.LOCATION);
    datapath = fullfile(rootpath, catFolder.name, 'Grapevine');
    baselinefile = find_curFile(datapath); 
    %set up xippmex as tcp on first run through ONLY
%     if baselinefile == 1
%         status = xippmex('tcp');
%         pause(1)
%         if status == 0
%             error('Xippmex is not connecting.')
%         end
%         
%         oper = 148;
%         xippmex('addoper', oper);
%     end
    surveyfile = NaN;
    searchChan_files = NaN; 
    loadpath = NaN; 
end
if ~exist(savepath, 'dir')
    mkdir(savepath);
    warning('Looks like this is a new location, have you taken photos?')
    keyboard;
end

%% run the high amplitude survey (or analyze the survey based on existing
%files)
[stim_freqs, response_locs] = high_amplitude_survey(C, savepath, datapath, baselinefile, 'testing', ~stim_on, 'survey_filenum', surveyfile, 'plotting', true);

input('Press Enter to continue to binary search (or Ctrl+C to exit)')

%run the binary search (or analyze the search based on existing files)
binary_search(C, savepath, datapath, stim_freqs, response_locs, 'testing', ~stim_on, 'data_filenums', searchChan_files, 'loadpath', loadpath)



