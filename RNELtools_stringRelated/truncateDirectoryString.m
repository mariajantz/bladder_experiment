function str = truncateDirectoryString(str, levels, side)
% TRUNCATEDIRECTORYSTRING Truncate a directory string to a specified level
%
% truncateDiretoryString(str, *levels, *side)
%
%
% INPUTS
% =========================================================================
%   str    - (char) string to crop
%   levels - (numeric) number of directory levels remaining after crop,
%    default: 3
%   side   - (char) 'right' or 'left', which side remains after crop,
%       default: 'right'

if nargin < 3
    side = 'right';
    if nargin < 2
        levels = 3;
    end
end

if isempty(str) 
    return
end

sepkey = regexptranslate('escape',filesep);
key    = sprintf('(?<=%s)[^%s]+',sepkey,sepkey);
str    = regexp(str,key,'match');

levels = min(length(str),levels);
if strcmp(side,'right')
    str = [ '...', filesep, fullfile(str{end-(levels-1):end})];
elseif strcmp(side,'right')
    str = [ fullfile(str{1:levels}), filesep, '...'];
else
    error('Unknown side option: ''%s''. ''left'' or ''right'' only',side);
end

end