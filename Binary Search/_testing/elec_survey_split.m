function chanSnips = elec_survey_split(C, filepath, varargin)
% loads the maximum amplitude file and splits it into arrays for each
% electrode (or pair/set of electrodes)

% filepath = 'R:\users\mkj8\testing\experiment_testing\testfiles\datafile1192'; %for testing
% load('R:\data_raw\cat\2018\Albus-20180724\Experiment_Files\Epidural - L6\experiment_constants1191.mat');
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

stim_in = find(contains(tempLabel, 'stim'));
%TODO: this will need to be adapted for multi board stimulation

%TODO: fix this...
numEvts = zeros(length(stim_in), 1);
for j=1:length(stim_in)
    numEvts(j) = hFile.Entity(stim_in(j)).Count;
end

%find correct number of events
evtIdx = find(mod(numEvts, C.MAX_AMP_REPS)==0);

%deal with junk that shows up on recording channels
stimTime = zeros(length(stim_in(evtIdx)),max(numEvts(evtIdx)));
for j = evtIdx'
    fprintf('Reading Stimulation Data for channel %s\n', tempLabel{stim_in(j)});
    for i = numEvts(j):-1:1
        [~, stimTime(j, i), ~, ~] = ns_GetSegmentData(hFile, stim_in(j), i);
    end
end

stimIdx = ceil(stimTime*C.REC_FS);

%define parameters of the split
window_len = C.REC_FS/C.STIM_FREQUENCY(1); %number of samples between stimuli
pre_window = C.PRE_WINDOW*C.REC_FS/1000; %include 1 ms of time before stimulation
numChans = length(C.BIPOLAR.CUFF_CHANNELS);
startIdx = 1;
endIdx = hFilens5.FileInfo(end).TimeStamps(2);
[b,a] = butter(C.NCUFF_FILTER_ARGS{1}, C.NCUFF_FILTER_ARGS{2}/(C.REC_FS/2), C.NCUFF_FILTER_ARGS{3});

%TODO: split these into sets of channels if they're stimulated together -
%use the defined value but check with actual stim time stamps
%rearrange stimIdx into minimal array (all same number of channels, in same
%order as the STIM_MAP)


if max(numEvts) == min(numEvts) && isempty(C.HIGHAMP_HEADSTAGE_LOC) % no overlapping events, only one headstage
    fprintf('Only one cycle of stimulation\n');
    stimChan = cell2mat(C.STIM_MAP);
    firstChan = stimChan(:, 1);
    allChan = sort(reshape(stimChan, numel(stimChan), 1));
    chanIdx = find(ismember(allChan, firstChan));
    stimIdx = stimIdx(chanIdx, :);
    numEvts = repmat(size(stimIdx, 2), size(stimIdx, 1), 1);
else
    fprintf('Multiple cycles of stimulation or multiple headstages\n');
    warning('STILL TESTING FOR MONOPOLAR/MULTIPLE HEADSTAGES, CHECK RESULTS');
    newIdx = zeros(size(C.STIM_MAP, 1), C.MAX_AMP_REPS);
    if size(C.STIM_MAP, 2)==2
        stimChan = cell2mat(C.STIM_MAP);
        allChan = unique(reshape(stimChan, numel(stimChan), 1));
        chanIdx = arrayfun(@(x) find(x==allChan), stimChan);
        if allChan(1)>=C.ACTIVE_CHAN(1)
            stimChan = stimChan-C.ACTIVE_CHAN(1)+1;
        end
        for i=1:size(stimChan, 1)
            iChan = chanIdx(i, :);
            if any(rem(numEvts, C.MAX_AMP_REPS))
                error('Number of events applied is not consistent across channels')
            end
            
            stimVals = stimIdx(iChan, 1:C.MAX_AMP_REPS:max(numEvts));
            matchVal = unique(stimVals);
            matchVal(matchVal==0) = [];
            for j = 1:length(matchVal)
                if isempty(find(~sum(matchVal(j)==stimVals, 2), 1))
                    %replace appropriate index
                    [row, col] = find(matchVal(j) == stimVals);
                    stimSection = ((col(row==1)-1)*C.MAX_AMP_REPS+1):col(row==1)*C.MAX_AMP_REPS;
                    newIdx(i, :) = stimIdx(iChan(1), stimSection); 
                    break
                elseif j==length(matchVal)
                    warning('No stim index values were found that match across these channels');
                    disp(i);
                    disp(iChan); 
                    keyboard;
                end
            end
        end
        stimIdx = newIdx;
        numEvts = repmat(size(stimIdx, 2), size(stimIdx, 1), 1);
    end
    %keyboard;
end

%extract analog data for all channels
for j = 1:numChans
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
        for k=1:size(stimIdx, 1) %for all channels
            for n=1:size(stimIdx, 2) %for all events
                temp = interp1([stimIdx(k, n)-1 (stimIdx(k, n)+1+blankTime)], ...
                    diffchan([stimIdx(k, n)-1 (stimIdx(k, n)+1+blankTime)])', ...
                    stimIdx(k, n):(stimIdx(k, n)+blankTime))';
                diffchan(stimIdx(k, n):(stimIdx(k, n)+blankTime)) = temp;
            end
        end
    end
    %filter
    tmpChan = filter(b,a, diffchan);
    %split the data according to which set of channels is being stimulated
    for i = 1:size(C.STIM_MAP, 1)
        %get segment just before and for a bit after stimulation on each
        %channel set
        tmpIdx = ceil(median(diff(stimIdx(i, :))));
        %put results in an array that is chanSnips{nervecuffnum, stimchannum}
        chanSnips{j, i} = cell2mat(arrayfun(@(x) tmpChan((round(x-pre_window)):(round(x+window_len))), stimIdx(i, 1:numEvts(i)-2),'UniformOutput',false))';
    end
end


ns_CloseFile(hFile);
ns_CloseFile(hFilens5);


