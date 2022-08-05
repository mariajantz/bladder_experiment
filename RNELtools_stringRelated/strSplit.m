function [before,after,matchFound] = strSplit(str,toMatch)
%strSplit  Splits a string into 2 parts based on a string match separator
%
%   [before,after,matchFound] = strSplit(str,toMatch)
%
%   Returns the strings before and after the toMatch input
%   Similar to the function in Labview that splits a string based on a match
%   
%   INPUTS
%   =====================
%   str     : string to split
%   toMatch : string to match
%   
%   OUTPUTS
%   ========================
%   before     : string before match, if no match is found this value takes
%                on the value of the input
%   after      : string after match
%   matchFound : boolean (0,1) on whether value was found
%       Note: an empty 'after' string does not mean matchFound = 0
%
%   EXAMPLES
%   =========================
%   str = 'this is a test';
%   toMatch = ' is ';
%   [before,after,matchFound] = strSplit(str,toMatch)
%
%   before: 'this'
%   after : 'a test'
%   match : 1
%
%   -   -   -   -   -   -   -   -
%   
%   str = 'this is a test';
%   toMatch = 'isa';
%   [before,after,matchFound] = strSplit(str,toMatch)
%
%   before: 'this is a test'
%   after : ''
%   match : 0

I = strfind(str,toMatch);

after = '';
matchFound = 0;
if isempty(I)
    before = str;
else
    before = str(1:I(1)-1);
    matchFound = 1;
    if length(toMatch)+I(1) <= length(str)
        after = str(I(1)+length(toMatch):end);
    end
end