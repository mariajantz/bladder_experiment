function chanSnips = single_amp_split_wf(C, wf_array, stim_in, stimTime, varargin)
% loads the maximum amplitude file and splits it into arrays for each
% electrode (or pair/set of electrodes)
% SAME AS max_amp_split but doesn't load raw data - this is more
% appropriate for testing from MDF/other database formats. 
% filepath = 'R:\data_raw\cat\2018\Caravel-20180501\Grapevine\datafile0400'; %for testing
% C = experiment_constants_example;
% assume stim blanking is on unless defined otherwise
varargin = sanitizeVarargin(varargin);
DEFINE_CONSTANTS
stim_blanking = true;
END_DEFINE_CONSTANTS

%get stim event count
numEvts = sum(stimTime~=0, 2);

%find the correct number of events, sometimes off by one 
% for i = -1:1
%     if any(C.THRESH_REPS + i == numEvts)
%         evtIdx = find(C.THRESH_REPS + i == numEvts);
%     end
% end
evtIdx = 1; 

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

stimIdx = ceil(stimTime*C.REC_FS);

%define parameters of the split
window_len = C.REC_FS/20; %number of samples between stimuli; surveys usually done at 20 hz
pre_window = C.PRE_WINDOW*C.REC_FS/1000; %include 1 ms of time before stimulation
%numChans = length(C.BIPOLAR.CUFF_CHANNELS);
% startIdx = 1;
% endIdx = hFilens5.FileInfo(end).TimeStamps(2);
[b,a] = butter(C.NCUFF_FILTER_ARGS{1}, C.NCUFF_FILTER_ARGS{2}/(C.REC_FS/2), C.NCUFF_FILTER_ARGS{3});

%TODO: split these into sets of channels if they're stimulated together -
%use the defined value but check with actual stim time stamps

if max(numEvts) == min(numEvts) % no overlapping events
    fprintf('Only one cycle of stimulation\n');
    stimChan = stim_in;
    firstChan = stimChan(:, 1);
    allChan = sort(reshape(stimChan, numel(stimChan), 1));
    chanIdx = find(ismember(allChan, firstChan));
    stimIdx = stimIdx(chanIdx, :);
    numEvts = repmat(size(stimIdx, 2), size(stimIdx, 1), 1);
else
    %TODO: will need to update this one still...
    fprintf('Multiple cycles of stimulation\n');
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
end

%extract analog data for all channels
for j = 1:length(wf_array)    
    %difference the channels
    diffchan = wf_array{j}(1, :)-wf_array{j}(2, :); 
    
    %stim blanking
    if stim_blanking
        blankTime = C.MIN_RESPONSE_LATENCY*C.REC_FS;
        for k=1:size(stimIdx, 1)
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
    for i = 1:length(stim_in)
        %get segment just before and for a bit after stimulation on channel
        %set
        tmpIdx = ceil(median(diff(stimIdx(i, :))));
        %put results in an array that is chanSnips{nervecuffnum, stimchannum}
        chanSnips{j, i} = cell2mat(arrayfun(@(x) tmpChan((round(x-pre_window)):(round(x+window_len))), stimIdx(i, 1:numEvts(i)-2),'UniformOutput',false)');
    end
end


