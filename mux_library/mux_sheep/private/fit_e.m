function r = fit_e(m_list)
    r = size(m_list,1); % # of rows
    t = sum(m_list,2);  % sum over rows
    if any(t==0)
        r = -1;
        return
    end
    
    if r > sum(sum(m_list) > 0)
        r = -1;
        return
    end
    if r == 1        
        r = find(m_list==1,1);
        return
    end
    
    if all(t==1)
        x  = [];
        for i=1:r
          x= [x find(m_list(i,:)==1)];
        end
        r = x;              
        return
    end
    
    for i = find(m_list(1,:)==1)
        mm = m_list(2:end,:);
        mm(:,i)=0;
        r = fit_e(mm);
        if r ~= -1
            r = [i r];
            return 
        end
    end

end

