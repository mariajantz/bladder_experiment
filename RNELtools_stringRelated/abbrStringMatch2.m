function isMatch = abbrStringMatch2(strShort,strLong,varargin)
%abbrStringMatch2  Tests if one string is in another (allows words in between)
%
%   isMatch = abbrStringMatch2(strShort,strLong,varargin)
%
%   This function looks to see if one string is contained in another.  It
%   handles missing words and truncations.
%
%   INPUTS
%   ======================================================
%   strShort : the string that must have all of its words present
%   strLong  : the longer string, which can be used to match the short
%              string
%
%   OPTIONAL INPUTS
%   ======================================================
%   REMOVE_NON_AN  : (default false) remove non-alpha-numeric
%   CASE_SENSITIVE : (default false)
%   CHECK_BOTH     : (default false), not yet implemented
%   
%   EXAMPLE
%   ======================================================
%   strLong  = 'Journal of neurosurgery';
%   strShort = 'J. Neurosurg';
%   isMatch  = abbrStringMatch2(strShort,strLong)
%   isMatch  => true


DEFINE_CONSTANTS
REMOVE_NON_AN  = false;
CASE_SENSITIVE = false;
CHECK_BOTH     = false;
END_DEFINE_CONSTANTS

if CHECK_BOTH
    nRounds = 2;
else
    nRounds = 1;
end

if REMOVE_NON_AN
   strLong(~isstrprop(strLong,'alphanum'))  = [];
   strShort(~isstrprop(strLong,'alphanum')) = [];
end

for iRound = 1:nRounds

    if iRound == 2
        [strLong,strShort] = deal(strShort,strLong);
    end
    
wordsShort = getWords(strShort);
pat        = cellArrayToString(wordsShort,'.*?',true); %Essentially we look 
%for all of the short words with anything in between

if CASE_SENSITIVE
   temp = regexp(strLong,pat,'once'); 
else
   temp = regexpi(strLong,pat,'once');  
end

isMatch = ~isempty(temp);

if isMatch
    break
end

end