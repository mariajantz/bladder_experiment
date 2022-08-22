function [fcn_result, windowStarts_sec] = moving_window_fast(wf, fs, featFn, windowSize_sec, winDisplace)
% Makes sliding windows that overlap by 

% To test example w/random normal distribution: 
% windowSize_sec = 2.5e-4
% winDisplace = 2.5e-5
% fs = 30e3
% featFn = @(y) sqrt(mean(y.^2));
% wf = normrnd(2,2,[1, 15*fs/1000]) %this is for a 15 ms "recording"
% HERE, RUN ALL LINES IN THIS FUNCTION THEN DO PLOTTING 

%     DEFINE_CONSTANTS
%     windowSize_sec = 2.5e-4;
%     winDisplace = 2.5e-5;
%     END_DEFINE_CONSTANTS

    %NumWins = @(signalLen, winLen, winDisp) floor((signalLen-winLen)/(winDisp))+1;
     
    windowSize_samples = windowSize_sec*fs;
    duration_sec = length(wf)/fs;
    overlap_sec = windowSize_sec - winDisplace;

    %numWindows = NumWins(duration_sec, windowSize_sec, winDisplace);
    windowStarts_sec = (0:(windowSize_sec-overlap_sec):duration_sec-windowSize_sec);
    windowStarts_idx = round(windowStarts_sec*fs);
    
    window_idx   = bsxfun(@plus,[1:windowSize_samples]',windowStarts_idx);
    sliding_data = wf(window_idx);
    fcn_result   = featFn(sliding_data);
    
% % PLOT WF: PLOTS WINDOW STARTS AND ENDS
% subplot(2, 1, 1); hold on
% plot(wf)
% plot(windowStarts_idx, ones(size(windowStarts_idx)), 'o')
% plot(windowStarts_idx+windowSize_samples, ones(size(windowStarts_idx)), 'o')
% % PLOT SLIDING DATA???
% subplot(2, 1, 2); hold on
% plot(sliding_data')
% hold on
% plot(fcn_result, 'k', 'LineWidth', 2)

end