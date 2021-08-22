function array2TexTable(array)
% ARRAY2TEXTABLE Format a 2D array into a tex Table
%
% array2TexTable(array)
%
% Requires \usepackage{float}.
% 
% INPUTS
% =========================================================================
%  array - (numeric) The array to convert
%
% OUTPUTS
% =========================================================================
%  None.
%
%  tags: text, parsing
nRow = size(array,1);
nCol = size(array,2);
tabular_arg = repmat('c | ',[1 nCol]);
hline = '\hline';
fprintf('\\begin{table}[H]\n');
fprintf('\\centering\n');
fprintf('\\begin{tabular}{|c||%s}\n',tabular_arg);
fprintf('%s\n',hline);
for iiRow = 1:nRow
    fprintf('Row%03d & %s',iiRow,arrayToString(array(iiRow,:),' & '))
    fprintf(' \\\\ %s\n',hline);
end
fprintf('\\end{tabular}\n');
fprintf('\\caption{ { \\small Small Caption Text!} }\n');
fprintf('\\label{tab:your_label_her}\n');
fprintf('\\end{table}\n');