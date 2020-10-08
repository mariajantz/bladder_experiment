function [] = plot_STA_progress(subject, rootPath, NEVfilenum)
    
    %   DESCRIPTION
    %   ===================================================================
    %   Plots stim triggered average for specified analog channels from 
    %   a given file ns5 file
    %
    %   INPUTS
    %   ===================================================================
    %   subject    : (string) animal name
    %   rootPath   : (string) path to fodler containing data file
    %   NEVfilenum : (int) data file
    %
    %
    %   OUTPUTS
    %   ===================================================================
    %   Figure per STA channel
    %
    %   REQUIREMENT
    %   ===================================================================
    %   1) Animal is added to constants file with channel mapping. Make 
    %      sure the channel mapping is NOT zero indexed
    %   2) SVN matlab repos is on path
    %
    %   EXAMPLE
    %   ===================================================================
    %   plot_STA('Bacchus','R:\data_raw\cat\2017\Bacchus-20171212\Grapevine',846)
    % 

    C = experiment_constants(subject);
    
    headstage = C.REC_HEADSTAGE;
    chanLabel = C.BIPOLAR_CUFF_MAPPING(:,2);
    channels = C.BIPOLAR_CUFF_MAPPING(:,1); 
    numChans = length(channels);
    
    stimTimes = read_stimEvents(fullfile(rootPath, sprintf('datafile%04d.nev',NEVfilenum)), []);
    if size(stimTimes,2) ~= 1
        error('multiple stim chans detected...')
    end
    stimIdx = ceil(stimTimes{1}*30e3);

    [b,a] = butter(2,300/30e3,'high');
    chanSnips = cell(1,numChans);
    
    analogData = read_continuousData(fullfile(rootPath, sprintf('datafile%04d.nev',NEVfilenum)), 'raw', [channels{:}]);
    for i = 1:numChans
        if strcmpi(headstage, 'surfd_raw')
            chanSnips{i} = cell2mat(arrayfun(@(x) analogData(1,(x-30):(x+600)), stimIdx,'UniformOutput',false)');

        else
            tmpChan = analogData(2*(i-1)+1,:) - analogData(2*i,:);
            tmpChan = filter(b,a,tmpChan);
            chanSnips{i} = cell2mat(arrayfun(@(x) tmpChan((x-30):(x+600)), stimIdx,'UniformOutput',false)');
        end

        figure;
        plot((-30:600)/30e3*1000, mean(chanSnips{i}))
        xlabel('time (sec)')
        ylabel('uV')
        axis tight
        title(chanLabel{i})
    end
end
