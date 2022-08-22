function compressed_str = compressNumberedStrings(inputStrs,forceString)
% compressNumberedStrings  Compresses several numbered strings into a single string
%
% compressNumberedStrings(inputStrs,*forceString)
%
% Given a set of numbered strings produces a single string with the numbers
% compressed into a single array.
%
% Examples:
%  PREFIX
%  input:  {'The_String_1','The_String_2','The_String_3'}
%  output: {'The_String_1:3'}
%
%  SUFFIX
%  input:  {'1The_String','2The_String','3The_String'}
%  output: {'1:3The_String'}
%
%  BOOKEND
%  input:  {'The1String','The2String','The3String'}
%  output: {'The1:3String'}
%
% INPUT
% =========================================================================
%  inputStrs   - (cell) cell array of numbered strings
%  forceString - (logical) forces string when output numel == 1, default: false
%
% OUTPUT
% =========================================================================
%  compress_str - (cell)

if nargin < 2
    forceString = false;
end

b_transpose = false;
if size(inputStrs,1) > size(inputStrs,2)
    inputStrs = inputStrs';
    % transpose the result
    b_transpose = true;
end
compressed_str = {};

if ~iscell(inputStrs)
    inputStrs = {inputStrs};
end
%  no work to be done, peace out
if length(inputStrs) == 1
    compressed_str = inputStrs;
    if forceString
        compressed_str = compressed_str{1};
    end
    return;
end

% break the input strings into their constitutive elements
[strs,strs_start] = regexp(inputStrs,'([^\d]+)','match','start');

% get # of tokens per string, these are used to separate prefixes &
% suffixes from bookends
lens             = cellfun('length',strs_start);
single_token_ind = strfind(lens == 1,1);
multi_token_ind  = strfind(lens > 1,1);

% handles prefixes & non-numbered strings
prefix_ind            = single_token_ind(strfind([strs_start{single_token_ind}] == 1,1));
[prefix,~, iiB]       = unique_2011b([strs{prefix_ind}]);
prefix_compressed_str = cell(1,length(prefix));
for iiPrefix = 1:length(prefix)
    match_str = [prefix{iiPrefix} '(\d+)' ];
    num_str   = regexp(inputStrs(prefix_ind(iiB == iiPrefix)),match_str,'tokens','once');
    mask      = ~cellfun(@isempty,num_str);
    % strings that do not contain a number are handled here
    if any(mask)
        nums = cellfun(@(x)str2num(x{1}),num_str(mask));
        str  = sprintf('%s%s',prefix{iiPrefix},array2strMatlabStyle(nums));
    else
        str = prefix{iiPrefix};
    end
    prefix_compressed_str{iiPrefix} = str;
end

% handles suffixes
suffix_ind          = single_token_ind(strfind([strs_start{single_token_ind}] > 1,1));
[suffix,~, iiB]     = unique_2011b([strs{suffix_ind}]);
suffix_compressed_str = cell(1,length(suffix));
for iiSuffix = 1:length(suffix)
    match_str = ['(\d+)' suffix{iiSuffix} ];
    
    nums= cellfun(@(x)str2num(x{1}),regexp(inputStrs(suffix_ind(iiB == iiSuffix)),match_str,'tokens','once'));
    
    suffix_compressed_str{iiSuffix} = sprintf('%s%s',array2strMatlabStyle(nums),suffix{iiSuffix});
end

% handle bookends (i.e. both prefix and suffix)
% to determine the uniquness of each bookend I concatenate the two parts
% and then unique the result
bookend_str = cellfun(@(x)cellArrayToString(x,''),strs(multi_token_ind),'UniformOutput',false);

[bookend,iiA, iiB]     = unique_2011b(bookend_str);
bookend_compressed_str = cell(1,length(bookend));
for iiBookend = 1:length(bookend)
    prefix = strs{multi_token_ind(iiA(iiBookend))}{1};
    suffix = strs{multi_token_ind(iiA(iiBookend))}{2};
    match_str = [prefix '(\d+)' suffix];
    
    nums= cellfun(@(x)str2num(x{1}),regexp(inputStrs(multi_token_ind(iiB == iiBookend)),match_str,'tokens','once'));
    
    bookend_compressed_str{iiBookend} = sprintf('%s%s%s',prefix,array2strMatlabStyle(nums),suffix);
end

compressed_str = [prefix_compressed_str suffix_compressed_str bookend_compressed_str];

% worst case, couldnt figure out how to compress
if ~isempty(inputStrs) && isempty(compressed_str)
    compressed_str = inputStrs;
end

if b_transpose
    compressed_str  =compressed_str';
end
if forceString && length(compressed_str) == 1
    compressed_str = compressed_str{1};
end
end