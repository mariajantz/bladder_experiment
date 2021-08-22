function [outputString,keptWords] = removeShortWords(inputStr,minLength,varargin)
%removeShortWords  Removes short words from a string
%
%   [outputString,keptWords] = removeShortWords(inputStr,minLength,varargin)
%
%   INPUTS
%   ========================================================
%   inputStr  : Input string to parse
%   minLength : minimum length of words to keep
%
%   OPTIONAL INPUTS
%   ========================================================
%   delimiter    : (default ' '), what to use when grouping words to form
%                   output
%   no_interp    : (default true), if true, the delimiter is not
%                   interpreted by a sprintf statement, but is written as
%                   is (like "\t" if true vs "    " if false)
%   postpend_str : (default ''), string that gets added to each word before
%                  grouping together to form the output string
%   prepend_str  : (default ''), gets prepended to each word
%   strip_nonAlphaNum : (default false)
%   
%   OUTPUTS
%   ========================================================
%   outputString : string after removal of small words, 
%   keptWords    : cell array of words that were kept, before addition of
%                  other strings via optional inputs
%
%   JAH TODO: Allow stripping of non-alpha and non-numeric characters
%
%   EXAMPLE
%   ========================================================
%   outputString = removeShortWords('Leave out all the rest',4)
%   outputString => 'Leave rest'
%
%   See Also:
%   getWords   
%   cellArrayToString

DEFINE_CONSTANTS
delimiter    = ' ';
no_interp    = true;
postpend_str = '';
prepend_str  = '';
strip_nonAlphaNum = false;
END_DEFINE_CONSTANTS

%NOTE: This won't handle contractions well ...
%IMPROVE
if strip_nonAlphaNum
   mask = isstrprop(inputStr,'alphanum'); %#ok<UNRCH> % | isspace(inputStr);
   inputStr(~mask) = ' ';
end

words = getWords(inputStr);
words(cellfun('length',words) < minLength) = [];
keptWords = words;

if ~isempty(prepend_str)
    words = cellfun(@(x) [prepend_str x],words,'UniformOutput',false);
end

if ~isempty(postpend_str)
    words = cellfun(@(x) [x postpend_str ],words,'UniformOutput',false);
end

outputString = cellArrayToString(words,delimiter,no_interp);