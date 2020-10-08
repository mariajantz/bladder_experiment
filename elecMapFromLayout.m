function test_pairs = elecMapFromLayout(C, firstset)
%quickly generate layouts from layout map
%firstset = [1 2]; 
for val = 1:length(firstset)
    [i(val), j(val)] = find(C.LAYOUT_MAP==firstset(val)); 
end

[max_i, max_j] = size(C.LAYOUT_MAP); 

j_iter = j; 
test_pairs = zeros(length(firstset), max_i*max_j);
t = 1; 
for i_idx = 1:max_i
    for j_idx = 1:max_j
        try
        this_val = unique(C.LAYOUT_MAP(i, j_iter)); 
        %reshape
        test_pairs(:, t) = this_val; 
        t = t+1; 
        j_iter = j_iter + ones(size(j_iter)); 
        catch
        continue
        end
    end
    i = i + ones(size(i)); 
    j_iter = j; 
end

[~, col] = find(test_pairs==0, 1, 'first');

if ~isempty(col)
test_pairs = test_pairs(:, 1:col(1)-1);
end

if sum(test_pairs(:, 1)==firstset')~=length(firstset)
    for i = 1:length(firstset)
        rowIdx = find(test_pairs(:, 1)==firstset(i));
        new_array(rowIdx, :) = test_pairs(i, :);
    end
    test_pairs = new_array; 
    if sum(test_pairs(:, 1)==firstset')~=length(firstset)
        error('Wrong order in output or problem with first set of electrodes')
    end
end



