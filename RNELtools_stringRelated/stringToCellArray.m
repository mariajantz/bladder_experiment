function cellArray = stringToCellArray(str,delimiter,interpDelim)
%stringToCellArray  Splits a string into multiple strings using a delimiter
%
%   cellArray = stringToCellArray(str,delimiter,interpDelim)
%
%   Splits a string (STR) along a DELIMETER and passes the resulting
%   strings into a cell array.  If the optional input, interpDelim is true,
%   then the delimeter is used directly in the regular expression.
%
%   OPTIONAL INPUTS
%   ===============================================
%   interpDelim : (default false)
%
%   EXAMPLE
%   ===============================================
%   1) Basic example
%   str = 'one,two,three';
%   delimiter = ',';
%   cellArray = stringToCellArray(str,delimiter)
%
%   cellArray => {'one' 'two' 'three'};
%
%   2) Using the INTERP_DELIM input
%   str = ['1' 10 '2' 10 '3'];
%   str => '1   %This is what the above code yields, 10 is windows newline
%           2   
%           3';
%   cellArray = stringToCellArray(str,'\n',true);
%   cellArray => {'1' '2' '3'};
%   
%   3) When you wouldn't want INTERP_DELIM
%   str = 'one.two.three'
%   cellArray = stringToCellArray(str,'.');
%
%   See also cellArrayToString


if isempty(str)
    cellArray = {};
    return
end

if nargin == 2
    interpDelim = false;
end

if ~interpDelim
    delimiter = regexptranslate('escape',delimiter);
end

cellArray = regexp(str,delimiter,'split');
if isempty(cellArray{end})
    cellArray = cellArray(1:end-1);
end

%OLD CODE
% cellArray = textscan(str,'%s','Delimiter',delimiter,'MultipleDelimsAsOne',true);
% cellArray = cellArray{1};