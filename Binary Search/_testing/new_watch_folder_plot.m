function [] = new_watch_folder_plot(subjectName, fileTrunk)
% watch for new file in folder - check every 5 seconds
% run this while a binary search is running to get plot updates after every
% channel - this one will run for the entirety of an experiment, and
% automatically updates folder
% example usage: watch_folder_plot('Albus', 'X:\2018\');

topFolder = fullfile(fileTrunk, subjectName, 'Documents\Experiment_Files');
datapath = fullfile(fileTrunk, subjectName, 'Grapevine');


% every 5 seconds, check for folders if exit condition hasn't updated
mouse_out = [];
prev_plots = [];
plotHandles = [];
skippedFiles = [];
loop_count = 0;
hclose = figure(50);
set(gcf, 'units','normalized','outerposition',[0 0 .2 .5]);

title('Click in this field to end plotting loop', 'FontSize', 20);
box on;
set(gca, 'XTick', [], 'YTick', []);
set(gca, 'Color', 'b');
set(gcf, 'units','normalized','outerposition',[0 .5 .3 .5])

while isempty(mouse_out)
    % figure out location being tested presently
    a = dir(fullfile(topFolder, '**\stimChan*'));
    [~, date_idx] = sort({a.date});
    
    % set up folders
    watchFolder = a(date_idx(end)).folder;
    savepath = fullfile(watchFolder, 'saved_figs');
    anlspath = fullfile(watchFolder, 'saved_analysis');
    if ~exist(savepath, 'dir')
        mkdir(savepath)
    end
    if ~exist(anlspath, 'dir')
        mkdir(anlspath)
    end
    constFiles = dir([watchFolder '\experiment_const*']);
    load(fullfile(watchFolder, constFiles(end).name));
    
    % when a new file appears, plot the last stimChan file
    stimFiles = dir(fullfile(watchFolder, 'stimChan*'));
    newFile = str2double(stimFiles(end).name(end-7:end-4));
    
    %Plot if any of the following is true: 
    % 1. a new file appears in the folder that is after the current file
    % 2. the last file hasn't been updated for more than 90 seconds and it
    % hasn't been plotted already
    % 3. there are more stimFiles than there are prev_plots (meaning one
    % was skipped) TODO make this part happen
    if (~isempty(prev_plots) && prev_plots(end)~=newFile) 
        % set name of file to load if new file appeared 
        plotFile = stimFiles(end-1).name; 
    elseif (seconds(datetime('now')-stimFiles(end).date)>90 && ~ismember(newFile, prev_plots))
        % set name of file to load if last file hasn't been updated for 90
        % seconds
        plotFile = stimFiles(end).name; 
    elseif ~isempty(skippedFiles)
        % set name of file to plot if there have been skipped plots and
        % reset the 
        plotFile = stimFiles(skippedFiles(1)).name; 
        skippedFiles(1) = []; 
    else 
        % otherwise, don't plot anything
        plotFile = []; 
    end
    
    if ~isempty(plotFile)
        %change this to double check I'm not skipping any due to the time spent
        this_plot = str2double(plotFile(end-7:end-4));
        
        % get number of stimFiles just in case the plotting takes longer
        % than it takes to finish the next channel 
        total_stimFiles = length(stimFiles); 
        % close last plots
        close(plotHandles);
        % make plots
        [~, plotHandles, anlsStruct] = plot_channel(C, fullfile(watchFolder, plotFile), datapath);
        % save plots
        for i = 1:length(plotHandles)
            saveas(plotHandles(i), sprintf('%s\\chan %s_fig%d.png', savepath, num2str(anlsStruct.stimChan), i));
        end
        %save analysis
        anlsStruct.subject = subjectName;
        [~, location] = fileparts(watchFolder);
        anlsStruct.location = location; 
        save(sprintf('%s\\stimFile%d_analysis', anlspath, this_plot), 'C', 'anlsStruct'); 
        
        loop_count = 0;
        prev_plots = [prev_plots this_plot];
        
        %compare number of stimFiles - if an additional one was generated
        %during the process of making this plot, make sure to plot that one
        %in the next round
        if total_stimFiles < length(stimFiles)
            %get index of all skipped files and plot them next
            for i = 1:(length(stimFiles)-total_stimFiles)
                skippedFiles = [skippedFiles length(stimFiles) - (1:(length(stimFiles)-total_stimFiles)) + 1]; 
                fprintf('Files skipped and queued: %d \n', skippedFiles);
            end
        end
        
        %
        %     elseif loop_count >= 60 %this is commented out to remove the timeout
        %         %add timeout condition - if it's been more than 5 minutes, end the
        %         %loop and plot the last one
        %         % close last plots
        %         close(plotHandles);
        %         [stimChan, plotHandles] = plot_channel(C, fullfile(watchFolder, stimFiles(end).name), datapath);
        %         % save plots
        %         for i = 1:length(plotHandles)
        %             saveas(plotHandles(i), sprintf('%s\\chan %s_fig%d.png', savepath, num2str(stimChan), i));
        %         end
        %         break
    end
    
    %make button for exit condition - run loop every 5 seconds
    figure(50);
    mouse_out = mouseinput_timeout(5);
    loop_count = loop_count + 1; %add timeout for loop
end

close(hclose);
fprintf('Done with plot loop\n');



