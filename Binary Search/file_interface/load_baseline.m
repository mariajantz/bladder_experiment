function baseline_wf = load_baseline(C, filepath)

% extract quiet recording trace 
fprintf('Load quiet recording NS5 file\n');
[~,hFilens5] = ns_OpenFile([filepath '.ns5'], 'single');

fprintf('Load traces from quiet recording\n');
numChans = length(C.BIPOLAR.CUFF_CHANNELS);
startIdx = 1;
endIdx = hFilens5.FileInfo(end).TimeStamps(2);
[b,a] = butter(C.NCUFF_FILTER_ARGS{1}, C.NCUFF_FILTER_ARGS{2}/(C.REC_FS/2), C.NCUFF_FILTER_ARGS{3});
baseline_wf = cell(numChans, 1); 

for j = 1:numChans
    fprintf('Load analog data for channels %d, %d\n', C.BIPOLAR.CUFF_CHANNELS{j})
    chanIdx1 = find(strcmp({hFilens5.Entity.Label}, sprintf('raw %d', C.BIPOLAR.CUFF_CHANNELS{j}(1)+1)));
    [~, ~, tmpchan1] = ns_GetAnalogData(hFilens5, chanIdx1, startIdx, endIdx);
    chanIdx2 = find(strcmp({hFilens5.Entity.Label}, sprintf('raw %d', C.BIPOLAR.CUFF_CHANNELS{j}(2)+1)));
    [~, ~, tmpchan2] = ns_GetAnalogData(hFilens5, chanIdx2, startIdx, endIdx);
    %difference the channels and filter
    baseline_wf{j} = filter(b,a,tmpchan1-tmpchan2);
end

ns_CloseFile(hFilens5);