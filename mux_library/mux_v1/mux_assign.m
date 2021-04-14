%% MUX switch control function
% assign MUX electrode (e-line) to Ripple stimulator channels (s-line)

%% Inputs
% list of electrodes to stimulate (0-indexed)

%% Outputs
% * e -- electrode list
%
% * ripple -- Ripple stimulator list
%
% * p -- command for MUX controller box


%% Example
% [e, ripple, p] = mux_assign([0 1 2 3 4 5])



function [e,ripple,p] = mux_assign(e_list)
dropped = [];
selected = [];    
sid = [];
for el=e_list
    selected = [selected el];
    for k = MLMUX.MUX_ID_2(el+1,:)
        if ~isnan(k)
            sid = union(sid,k);
        end
    end
    if length(sid) >= length(selected) || length(selected)<=3
        continue
    else
        dropped = [dropped selected(end)];
        selected(end) = [];        
    end   
    
    end
    if ~isempty(dropped)
     fprintf("dropped electrode selection = %i\n",dropped);
    end
sid = [];
for el = selected
    for k = MLMUX.MUX_ID_2(el+1,:)
        if ~isnan(k)         
            sid = union(sid,k);
        end
    end
end
m=[];

    for el = selected
    m_row = zeros(1,length(sid));
    for k = MLMUX.MUX_ID_2(el+1,:)   
        m_row = m_row + (k==sid);
    end
    m = [m;m_row];
end
r = fit_e(m>=1);
if r == -1
    e=[];
    ripple=[];
    p=[];
    disp("failed to swtich")
    return
else
   s = sid(r);
   % map to Ripple channel   
   ripple = MLMUX.RIPPLE(s+1);
   e = selected;
   p = [];
   for i = 1:length(s)
       p=[p e(i) find(MLMUX.MUX_ID_2(e(i)+1,:)==s(i),1)];
   end
   
   return
   
end

end

