function str = mat2str(data,varargin)
%mat2str Replaces default mat2str with one that uses a format specifier
%
%   mat2str like you want it ...
%
%   TODO: Document function 
%
%   JAH TODO: Could improve this ...

in.format = '%0g';
in = processVarargin(in,varargin);

temp = arrayfun(@(x) sprintf(in.format,x),data,'un',0);

nRows = size(temp,1);
rowsTemp = cell(1,nRows);
for iRow = 1:nRows
   rowsTemp{iRow} = cellArrayToString(temp(iRow,:),' '); 
end

str = ['[' cellArrayToString(rowsTemp,'; ') ']'];


end