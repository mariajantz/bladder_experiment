function protocol = generateElecMap(firstPair, varargin)
% generates a map of electrodes based on the first pair (anode-cathode) of
% the array (entering 1-2 will assign "horizontal" pairs, 1-5 will assign
% "vertical" pairs, 2-1 switches polarity)
% if variable argument 'arbitrary' is set to on, it will return two-channel pairs for each
% anode and cathode according to the assignments of those pairs to the
% array from the arbitrary mapping board

allChan = 1:16;
protocol = firstPair; 
for i=1:7
    allChan = setdiff(allChan, protocol); 
    protocol(i+1, :) = firstPair+allChan(1)-1;
end
protocol = num2cell(protocol);

%check if arbitrary is true, if so, replace with arbitrary mapping
if ~isempty(varargin)
    arMap = [1:2:31; 2:2:32]';
    temp = cell(size(protocol)); 
    for i=1:numel(protocol)
        temp{i} = arMap(protocol{i}, :); 
    end
    protocol = temp; 
end






