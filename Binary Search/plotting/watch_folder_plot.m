function [] = watch_folder_plot(subjectName, location, fileTrunk)
% watch for new file in folder - check every 5 seconds
% run this while a binary search is running to get plot updates after every
% channel
% example usage: watch_folder_plot('Albus', 'Epidural - L6', 'X:\2018\');

watchFolder = fullfile(fileTrunk, subjectName, 'Experiment_Files', location);
datapath = fullfile(fileTrunk, subjectName, 'Grapevine'); 
savepath = fullfile(watchFolder, 'saved_figs'); 
if ~exist(savepath)
    mkdir(savepath)
end
constFiles = dir([watchFolder '\experiment_const*']); 
load(fullfile(watchFolder, constFiles(end).name)); 

% every 5 seconds, check for folders if exit condition hasn't updated
mouse_out = [];
last_plot = [];
plotHandles = []; 
loop_count = 0;
hclose = figure(50); 
set(gcf, 'units','normalized','outerposition',[0 0 .2 .5]);

title('Click in this field to end plotting loop', 'FontSize', 20);
box on;
set(gca, 'XTick', [], 'YTick', []);
set(gca, 'Color', 'b'); 
set(gcf, 'units','normalized','outerposition',[0 .5 .3 .5])

while isempty(mouse_out)
    % TODO deal with last file
    % when a new (stimChan or summary?) file appears, plot the last stimChan file
    stimFiles = dir(fullfile(watchFolder, 'stimChan*'));
    this_plot = str2num(stimFiles(end).name(end-7:end-4));
    
    if ~isempty(last_plot) && last_plot~=this_plot
        % close last plots
        close(plotHandles); 
        % make plots
        [stimChan, plotHandles] = plot_channel(C, fullfile(watchFolder, stimFiles(end-1).name), datapath); 
        % save plots
        for i = 1:length(plotHandles)
            saveas(plotHandles(i), sprintf('%s\\chan %s_fig%d.png', savepath, num2str(stimChan), i)); 
        end
        loop_count = 0;
    elseif loop_count >= 60
        %add timeout condition - if it's been more than 5 minutes, end the
        %loop and plot the last one
        % close last plots
        close(plotHandles); 
        [stimChan, plotHandles] = plot_channel(C, fullfile(watchFolder, stimFiles(end).name), datapath); 
        % save plots
        for i = 1:length(plotHandles)
            saveas(plotHandles(i), sprintf('%s\\chan %s_fig%d.png', savepath, num2str(stimChan), i)); 
        end
        break
    end
    
    %make button for exit condition - run loop every 5 seconds
    figure(50);
    mouse_out = mouseinput_timeout(5);
    loop_count = loop_count + 1; %add timeout for loop
    last_plot = this_plot; 
end

close(hclose); 
fprintf('Done with plot loop\n');



