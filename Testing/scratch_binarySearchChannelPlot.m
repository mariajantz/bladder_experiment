
num_subplots = 15;
plot_count = 1;
clrs = get(gca, 'ColorOrder'); 
for i = 1:length(amps)
    %if necessary, make a new figure and reset count
    if plot_count>num_subplots
        figure;
        plot_count = 1;
    end
    %choose constant to determine level on y axis of bars for plot
    minvals = 0;
    for j = 1:size(chanSnips, 1)
        subplot(4, 4, plot_count); hold on;
        %plot the mean traces for each nerve cuff
        temptrace = mean(chanSnips{j, amp_idx(i)}, 1);
        xvals = 1/C.REC_FS:1/C.REC_FS:length(temptrace)/C.REC_FS; 
        plot(xvals, temptrace, 'Linewidth', 2, 'Color', clrs(j, :));
        %choose y level to plot the zones where a response was found for each nerve cuff
        minvals = min(min(temptrace), minvals);
    end
    %TODO plot the bars where there are responses
    yLvl = minvals*.1+minvals;
    for j = 1:size(chanSnips, 1)
        if ~isempty(time_windows{amp_idx(i), j})
            for k = 1:size(time_windows{amp_idx(i), j})
                plot(time_windows{amp_idx(i), j}(k, :), [yLvl+j*minvals*.05-1 yLvl+j*minvals*.05-1], 'Linewidth', 2, 'Color', clrs(j, :));
            end
        end
    end
    
    plot_count = plot_count+1;
    axis tight; 
    title(amps(i)); 
end
legend(C.BIPOLAR.CUFF_LABELS); 
%TODO save