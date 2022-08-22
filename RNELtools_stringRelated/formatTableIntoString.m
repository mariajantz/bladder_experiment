function table_str = formatTableIntoString(table,varargin)
% FORMATTABLEINTOSTRING Stringigies a cell matrix into a table
%
% table_str = formatTableIntoString(table)
%
%
% tags:
% see also:

varargin = sanitizeVarargin(varargin);
DEFINE_CONSTANTS
header   = {};
delimter = '';
END_DEFINE_CONSTANTS

nCol = size(table,2);
nRow = size(table,1);
str  = '';
has_header = ~isempty(header);
for iiCol = 1:nCol
    % convert all numbers into strings
    mask              = cellfun(@isnumeric,table(:,iiCol));
    tmp               = deal(cellfun(@num2str,table(mask,iiCol),'UniformOutput',false));
    table(mask,iiCol) = tmp;
    
    % get the longest column
    len     = cellfun(@length,table(:,iiCol));
    if has_header
        len = [len length(header{iiCol})];
    end
    
    max_len = max(len);
    buffer  = arrayfun(@(x)repmat(' ',[ 1 x]),max_len-len+2,'UniformOutput',false);
    tmp     = deal(cellfun(@(x,y)[x y],table(:,iiCol),buffer,'UniformOutput',false));
    
    if iiCol < nCol
        table(:,iiCol) = tmp;
    end
    
    if has_header
        header{iiCol} = [header{iiCol} repmap(' ',[max_len - length(header{iiCol})])];
    end
end

table_str = cell(nRow,1);
for iiRow = 1:nRow
    table_str{iiRow,:} = [table{iiRow,:}];
end

end
