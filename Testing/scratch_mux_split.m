%script to test mux electrode survey splitting

datapath = 'R:\data_raw\cat\2019\Molson-20190702\Grapevine';
survey_filenum = 1737;


chanSnips = elec_survey_split_mux(C, sprintf('%s\\datafile%04d', datapath, survey_filenum));

%% 

for i = 1:size(chanSnips, 2)
    figure; 
    tempArr = cell2mat(cellfun(@(x) mean(x, 1), chanSnips(:, i), 'UniformOutput', 0)); 
    plot(tempArr')
end