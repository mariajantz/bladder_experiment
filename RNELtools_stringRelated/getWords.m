function words = getWords(str,varargin)
%getWords  Retrieves words from string (groupings of non-space characters)
%
%   words = getWords(str,varargin)
%
%   OPTIONAL INPUTS
%   =================================
%   REMOVE_EMPTY: (default true)
%
%   Example:
%   ==================================
%   words = getWords('This is a test');
%   words => {'This' 'is' 'a' 'test'}

DEFINE_CONSTANTS
REMOVE_EMPTY = true;
END_DEFINE_CONSTANTS

words = regexp(str,'[\s]','split');

if REMOVE_EMPTY
   words(cellfun('isempty',words)) = []; 
end