function next_amp = determine_amplitude(response_arr, prev_amps, min_diff, max_diff)
% Function to determine the amplitude of the subsequent stimulation
% INPUTS:
% number of responses present for each previous amplitude and this amp
% what amplitudes have been run previously
% max of resolution desired of response, resolution of stimulator

%ALTERNATE MATH
%BASE CONDITION
next_amp = 0; 
if ~any(response_arr==0) && ~any(prev_amps==min_diff)
    % if there's no lower response, do half of the current current
    next_amp = .5*prev_amps(end);
    next_amp = round(next_amp/min_diff)*min_diff;
else
    %otherwise interpolate
    [sort_amps, sort_idx] = sort(prev_amps);
    sort_resp = response_arr(sort_idx);
    change_idx = find(diff(sort_resp)>0); %ignore negatives (ie drop response)
    
    for c = 1:length(change_idx)
        last_pair = sort_amps(change_idx(c):change_idx(c)+1);
        if diff(last_pair)>min_diff
            next_amp = .5*diff(last_pair)+min(last_pair);
            % adjust next amplitude to the resolution desired
            next_amp = round(next_amp/min_diff)*min_diff;
            if ~any(ismember(prev_amps, next_amp))% && next_amp>cutoff
                break;
            end
        end
    end
end
%exit stimulation if this amplitude is included in previous trials
if any(ismember(prev_amps, next_amp))% || next_amp < cutoff
    next_amp = 0;
end

%add survey function
if next_amp == 0
    [sort_amps, ~] = sort(prev_amps);
    add_vals = find(diff(sort_amps)>max_diff);
    if ~isempty(add_vals)
        %add survey val
        %TODO fix this so it's not doing it by halves, it's just
        %dividing
        drange = diff([sort_amps(add_vals(1)) sort_amps(add_vals(1)+1)]); 
        
        next_amp = sort_amps(add_vals(1))+ceil(drange/ceil(drange/max_diff));
        next_amp = round(next_amp/min_diff)*min_diff;
    end
end




