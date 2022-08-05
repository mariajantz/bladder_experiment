function [TF,LOC] = ismemberStr(s1,s2)
%ismemberStr  returns whether or not a string is in a cell array, and where
%   [TF,LOC] = ismemberStr(S1,CELL_ARRAY_OF_STRINGS) returns whether
%   or not (TF) S1 is in the CELL_ARRAY_OF_STRINGS, as well as the location 
%   (LOC) of the first match.  If no match is found then LOC = 0
%

%JAH NOTE: This function should probably be removed, clutters namespace and
%isn't all that useful

if ~ischar(s1) || ~(ischar(s2) || iscellstr(s2))
    error('S1 must be a string and the 2nd input must be a string or cell array of strings')
end

LOC = find(strcmp(s1,s2),1);
if isempty(LOC)
    LOC = 0;
    TF = false;
else
    TF = true;
end