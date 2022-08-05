function str = cellArrayMatrixToString(cell_array_input,col_delimiter,varargin)
%cellArrayMatrixToString
%
%   str = cellArrayMatrixToString(cell_array_input,col_delimiter,varargin)
%
%   INPUTS
%   =====================================
%   cell_array_input :
%   col_delimiter    :
%
%   OPTIONAL INPUTS
%   ====================================
%   row_delimiter              : (default '\n')
%   make_literal_row_delimiter : (default true)
%   make_literal_col_delimiter : (default true)
%
%   EXAMPLE
%   ==================================
%   TODO: Insert example
%
%   See Also:
%       cellArrayToString

in.row_delimiter = '\n';
in.make_literal_row_delimiter = true;
in.make_literal_col_delimiter = true;
in = processVarargin(in,varargin);

nLines = size(cell_array_input,1);
line_cells = cell(1,nLines);
for iLine = 1:nLines
   line_cells{iLine} = cellArrayToString(cell_array_input(iLine,:),...
       col_delimiter,~in.make_literal_col_delimiter);
end

str = cellArrayToString(line_cells,in.row_delimiter,~in.make_literal_row_delimiter);

end