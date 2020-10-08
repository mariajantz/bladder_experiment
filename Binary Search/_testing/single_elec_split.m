function chanSnips = single_elec_split(C, filepath, varargin)
% loads the maximum amplitude file and splits it into arrays for each
% electrode (or pair/set of electrodes)

% filepath = 'R:\data_raw\cat\2018\Caravel-20180501\Grapevine\datafile0400'; %for testing
% C = experiment_constants_example;
% assume stim blanking is on unless defined otherwise
varargin = sanitizeVarargin(varargin);
DEFINE_CONSTANTS
stim_blanking = true;
END_DEFINE_CONSTANTS

%load the files to split data
fprintf('Load NEV file\n');
[~,hFile] = ns_OpenFile([filepath '.nev'], 'single');
fprintf('Load NS5 file\n');
[~,hFilens5] = ns_OpenFile([filepath '.ns5'], 'single');

%get stim events
tempLabel = {hFile.Entity.Label};
for lbl = 1:length(tempLabel)
    if iscell(tempLabel{lbl})
        tempLabel{lbl} = tempLabel{lbl}{1};
    elseif isempty(tempLabel{lbl})
        tempLabel{lbl} = ''; %convert to string for finding ability
    end
end

try
stim_in = find(contains(tempLabel, 'stim'));
catch 
    stim_in = find(~cellfun(@isempty, strfind(tempLabel, 'stim'))); 
end
%TODO: fix this...
numEvts = zeros(length(stim_in), 1);
for j=1:length(stim_in)
    numEvts(j) = hFile.Entity(stim_in(j)).Count;
end

%find the correct number of events, sometimes off by one 
% for i = -1:1
%     if any(C.THRESH_REPS + i == numEvts)
%         evtIdx = find(C.THRESH_REPS + i == numEvts);
%     end
% end
evtIdx = 1; 

%deal with junk that shows up on recording channels
stimTime = zeros(length(stim_in(evtIdx)),max(numEvts(evtIdx)));
for j = evtIdx'
    fprintf('Reading Stimulation Data for channel %s\n', tempLabel{stim_in(j)});
    for i = numEvts(j):-1:1
        [~, stimTime(j, i), ~, ~] = ns_GetSegmentData(hFile, stim_in(j), i);
    end
end

%Trellis saves files with long stimulation pulses with a 17 ms snippet
%separate because that's the same length as a spike - it's ridiculous but
%this fixes it
if numEvts/C.THRESH_REPS>1
    tempDiff = diff(stimTime); 
    if round(tempDiff(1), 2, 'significant')==0.0017 && mod(numEvts, C.THRESH_REPS)==0
        stimTime = stimTime(1:numEvts/C.THRESH_REPS:end);
        numEvts = C.THRESH_REPS; 
    else
        warning('Splitting by stimulation index error due to incorrect number of events'); 
    end
end

stimIdx = ceil(stimTime(1, :)*C.REC_FS);

%define parameters of the split
window_len = median(diff(stimIdx)); %number of samples between stimuli
pre_window = C.PRE_WINDOW*C.REC_FS/1000; %include 1 ms of time before stimulation
%numChans = length(C.BIPOLAR.CUFF_CHANNELS);
startIdx = 1;
endIdx = hFilens5.FileInfo(end).TimeStamps(2);
[b,a] = butter(C.NCUFF_FILTER_ARGS{1}, C.NCUFF_FILTER_ARGS{2}/(C.REC_FS/2), C.NCUFF_FILTER_ARGS{3});

%TODO: split these into sets of channels if they're stimulated together -
%use the defined value but check with actual stim time stamps

%extract analog data for all channels
for j = C.SEARCH_CUFFS_IDX
    fprintf('Load analog data for channels %d, %d\n', C.BIPOLAR.CUFF_CHANNELS{j})
    chanIdx1 = find(strcmp({hFilens5.Entity.Label}, sprintf('raw %d', C.BIPOLAR.CUFF_CHANNELS{j}(1)+1)));
    [~, ~, tmpchan1] = ns_GetAnalogData(hFilens5, chanIdx1, startIdx, endIdx);
    chanIdx2 = find(strcmp({hFilens5.Entity.Label}, sprintf('raw %d', C.BIPOLAR.CUFF_CHANNELS{j}(2)+1)));
    [~, ~, tmpchan2] = ns_GetAnalogData(hFilens5, chanIdx2, startIdx, endIdx);
    
    %difference the channels
    diffchan = tmpchan1-tmpchan2; 
    
    %stim blanking
    if stim_blanking
        blankTime = C.MIN_RESPONSE_LATENCY*C.REC_FS;
        for k=1:length(stimIdx)
            temp = interp1([stimIdx(k)-1 (stimIdx(k)+1+blankTime)], ...
                diffchan([stimIdx(k)-1 (stimIdx(k)+1+blankTime)])', ...
                stimIdx(k):(stimIdx(k)+blankTime))';
            diffchan(stimIdx(k):(stimIdx(k)+blankTime)) = temp; 
        end
    end
    %filter
    tmpChan = filter(b,a, diffchan);
    %split the data according to which set of channels is being stimulated
    for i = 1:length(evtIdx)
        %get segment just before and for a bit after stimulation on channel
        %set
        tmpIdx = ceil(median(diff(stimIdx(i, :))));
        %put results in an array that is chanSnips{nervecuffnum, stimchannum}
        chanSnips{j, i} = cell2mat(arrayfun(@(x) tmpChan((x-pre_window):(x+window_len)), stimIdx(i, 1:numEvts(i)-2),'UniformOutput',false))';
    end
end


ns_CloseFile(hFile);
ns_CloseFile(hFilens5);


