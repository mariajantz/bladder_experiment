function outputString = arrayToString(array,delimiter,format)
%arrayToString  Converts a numeric array to string with delimeter between values
%
%   OUTPUT_STRING = arrayToString(ARRAY, DELIMITER, FORMAT)
%
%   OUTPUT_STRING = arrayToString(ARRAY, DELIMITER) uses a default FORMAT
%   of '%g'
%
%   Differs from num2str in that it puts a delimiter between the values
%
%   EXAMPLE
%   ===========================================
%   OUTPUT_STRING = arrayToString([1.1 2.34 5.678 4],', ')
%   OUTPUT_STRING => '1.1, 2.34, 5.678, 4'

if nargin < 1 || nargin > 3
    error('There must be 2 or 3 inputs to %s',mfilename); 
end
if nargin < 2
    delimiter = ', ';
end
if nargin < 3
    format = '%g';
end

if isempty(array)
    outputString = '';
    return
end

L    = length(sprintf(delimiter)); % Pass the delimiter through sprintf in case the user protected an escape sequence. TODO: escape the delimiter sequence.
temp = sprintf([format delimiter],array);

outputString = temp(1:end-L);