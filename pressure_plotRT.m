%structure of this plot: scrolling window on the  top that shows the last 2
%minutes, bottom two plots show the last 10 minutes, and when they have
%cycled off, the plot autosaves the next pair. 

close all
clear all

%initialize arduino and plot
saveloc = 'E:\2020\Quirrell\CystometryPlots'; 
save_iter = 1; 
save_on = 1; 
a = arduino; 
figure(2);
set(gcf, 'Position', [40 42 972 954])
set(gcf,'color','w');
static_plot_length = 5*60; %length of each plot in seconds
scroll_plot_length = 1.5*60; %length of scrolling plot in seconds
maxpoints = scroll_plot_length*38;
clr = [66, 135, 245; 57, 138, 0]/255; 
anChan = 'A1'; 

total_time = 40000; %arbitrary val

%first make the scrolling plot
subplot(4, 1, [1 2]); title('Pressure Change in Real Time'); 
grid on; box on;
xlabel('Time (s)');ylabel ('Pressure(mmHg)')
scrollh = animatedline('MaximumNumPoints', maxpoints, 'Linewidth', 2, 'Color', clr(1, :));
%scrollh_eus = animatedline('MaximumNumPoints', scroll_plot_length*30, 'Linewidth', 2, 'Color', clr(2, :));

subplot(4, 1, 3); title('Recent History'); 
xlabel('Time (s)');ylabel ('Pressure(mmHg)')
grid on; box on;
statich1 = animatedline('Linewidth', 2, 'Color', clr(1, :));
%statich1_eus = animatedline('Linewidth', 2, 'Color', clr(2, :));

subplot(4, 1, 4); 
xlabel('Time (s)');ylabel ('Pressure(mmHg)')
grid on; box on;
statich2 = animatedline('Linewidth', 2, 'Color', clr(1, :));
%statich2_eus = animatedline('Linewidth', 2, 'Color', clr(2, :));

time_adjust = 0; 
ttimer = tic; %x vals will be set by this
t = 1; 
while t>0
    %read data and convert to mmHg
    chan1(t) = readVoltage(a, anChan)/50*1000; 
    %chan2(t) = readVoltage(a, 'A1')/10*1000; 
    x(t) = toc(ttimer) - time_adjust; 
    
    %update scrolling plot
    subplot(4, 1, [1 2]); 
    if x(t)<scroll_plot_length
        %update without scrolling
%         plot(x, chan1); 
%         plot(x, chan2); 
        addpoints(scrollh, x(t), chan1(t));
        %addpoints(scrollh_eus, x(t), chan2(t));
        axis([0 scroll_plot_length 0 50]); 
        drawnow
    else
        %update with scrolling
        addpoints(scrollh, x(t), chan1(t));
        %addpoints(scrollh_eus, x(t), chan2(t));
%         tidx = find(x<(x(t)-scroll_plot_length), 1, 'last'); 
%         plot(x(tidx:end), chan1(tidx:end)); 
%         plot(x(tidx:end), chan2(tidx:end)); 
        
        axis([x(end)-scroll_plot_length x(end) 0 50]); 
        drawnow
    end
%     box off; 
%     set(gca, 'TickDir', 'out');
%     title('Last 2 minutes'); 
    
    %update static plots
    if x(t)<static_plot_length
        %plot static vals on plot 1
        subplot(4, 1, 3); 
        addpoints(statich1, x(t), chan1(t));
        %addpoints(statich1_eus, x(t), chan2(t));
        %plot(x, chan1); 
        xlim([0 static_plot_length]); 
        drawnow
        
    elseif x(t) >= static_plot_length && x(t) < static_plot_length*2
        %plot static vals on plot 2
        subplot(4, 1, 4); 
        addpoints(statich2, x(t)-static_plot_length, chan1(t));
        %addpoints(statich2_eus, x(t)-static_plot_length, chan2(t));
        %plot(x, chan1); 
        xlim([0 static_plot_length]); 
        drawnow
        
    else
        %save plot
        if mod(save_iter, 2)==1 && save_on
            savefig(fullfile(saveloc, sprintf('pressure_%s', datestr(datetime, 'mm-dd HH-MM')))); 
        end
        %move data in the second plot to the first one
        subplot(4, 1, 3); 
        statich2.Parent = statich1.Parent;
        delete(statich1);
        statich1 = statich2; 
        %statich2_eus.Parent = statich1_eus.Parent;
        %delete(statich1_eus);
        %statich1_eus = statich2_eus; 
        
        subplot(4, 1, 4); 
        statich2 = animatedline('Linewidth', 2, 'Color', clr(1, :));
        %statich2_eus = animatedline('Linewidth', 2, 'Color', clr(2, :));
        
        %reset time and save count
        time_adjust = time_adjust + static_plot_length; 
        save_iter = save_iter+1; 
        
        %add adjusted time to top axis
        %addpoints(scrollh, 
        
        tidx = find(diff(x)<0, 1, 'last')+1;
        
        if isempty(tidx) 
            tidx = 1; 
        else
            tidx = tidx(1); 
            if length(x)-tidx>maxpoints
                tidx = length(x)-maxpoints + 1; 
            end
        end
        %tidx = scroll_plot_length; 
        %clearpoints(scrollh); %clearpoints(scrollh_eus); 
        %break
        %addpoints(scrollh, x(tidx:end)-time_adjust, chan1(tidx:end));
        %addpoints(scrollh_eus, x(tidx:end)-time_adjust, chan2(tidx:end));
        
        %keyboard %TODO SAVING
    end
    t = t + 1;  
end




