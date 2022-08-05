function str = toString(data,varargin)
%toString
%
%   str = toString(data,varargin)
%
%   INPUTS
%   =========================================================
%   data (current supported types)
%      - scalar, 1d, 2d - numeric or logical values
%      - strings
%      - cell array of strings
%   
%   OPTIONAL INPUTS
%   =========================================================
%   see code ...
%
%
%   JAH: This code needs to be cleaned up and simplified significantly ...
%

%OPTIONAL INPUTS
%==========================================================================
DEFINE_CONSTANTS

%NUMERIC OPTIONS
%=========================================================================
compress_integers  = true;  %uses array2strMatlabStyle to compress rows
add_cast_data_type = false; %if true, adds a cast around the type
logicals_as_text   = true;
dont_add_type_double = true; %don't add the type for the default type
add_brackets       = true;  %if true, adds brackets around numeric values
float_format       = '%g';  %format to use for single or double when 
%not detected to be integers
row_per_line       = false;
maintain_colum_vec = false; %if true, writes a column vector as a column
%vector instead of a row vector or typical "1d" array
keep_semis         = true; %Matlab automatically inteprets new lines with
% no "..." as new columns, no need for the semicolon, but it might be
% desired for obviousness
first_row_newline  = true; %put the first line on its own line
%-> only if row_per_line is true
scalar_no_brackets = true; %if true, brackets are not added to numeric scalars
%NOT YET IMPLEMENTED
% align_columns       = false; %NOTE: this may be slow, not yet implemented

%FUNCTION_HANDLE
%=========================================
include_handle_sym = true;

%STRING_OPTIONS
%==========================================================================
pre_post_append_strings = {'''' ''''};
escape_apostr_string = true; %If true, replaces "'" with ''

END_DEFINE_CONSTANTS
%==========================================================================



junk_char = '$'; %This will get inserted after every element but replaced 
%by the new_line_space_holder for values at the edge of the new line
new_line_space_holder = '@'; %This will be replaced by the newline character
%JAH - why not just use the \n? -> allows for more straight forward code,
%common pathway for integers and floats

%If we cast we have to add brackets (unless scalar, handled below)
if add_cast_data_type
    add_brackets = true;
end

%If we're keeping everything on one line, don't split
if ~row_per_line
    first_row_newline = false;
    %align_columns = false; %Not yet implemented
    keep_semis        = true;
end

isLogical = false;
newL = char(10);
switch class(data)
    case 'logical'
        isLogical = true;
        isNumeric = true;
        isInteger = true;
        compress_integers = false;
    case {'double' 'single'}
        isNumeric = true;
        isInteger = all(fp_isinteger(data(:)));
    case {'cell'}
        if ~iscellstr2(data)
            if size(data,1) == 1
                temp = cellfun(@toString,data,'un',0);
                str = ['{' cellArrayToString(temp,' ') '}'];
            elseif size(data,2) == 1
                temp = cellfun(@toString,data,'un',0);
                str = ['{' cellArrayToString(temp,'; ') '}'];
            else
                error('Currently only cell array of strings is supported in 2d')
            end
        else
            %NOTE: As they stand currently, the defaults are such so as to
            %allow evaluation of the output, i.e. apostrophes are escaped 
            %and bracketed by aposthrophes
            %i.e. my'String becomes 'my''String'
            
            data      = cellfun(@toString,data,'UniformOutput',false);
            nCols     = size(data,2);
            strLength = cellfun('length',data);
            rowLength = sum(strLength,2) + (nCols - 1);
            str       = cellArrayToString(data',' '); 
            
            %NOTE ON CALCULATION BELOW
            %The first character needs to be inserted after the length of
            %the first row
            %The second character needs to be insertd after the first row
            %& the ' ' & the 2nd row + 1
            %It turns out that this statement below works
            %
            %ex -> '12345 789 ' -> insert at 6 and 10, lengths are 5 and 3
            %respectively -> cumsum -> 5,8 -> + 1:2 => 6 & 10
            
            semi_positions = cumsum(rowLength(:)') + (1:length(rowLength));
            
            str(semi_positions) = ';';
            str(end) = []; %remove last semicolon
            str = ['{' str '}']; 
        end
        return
    case {'int8' 'int16', 'int32', 'int64', 'uint8', 'uint16', 'uint32', 'uint64'}
        isNumeric = true;
        isInteger = true;
    case 'function_handle'
        str = func2str(data);
        if include_handle_sym
            %NOTE: An anonymous function will already
            %have the handle symbol
            %-> @(x)x+3 -> stays the same
            %-> @mean   -> mean
            if str(1) ~= '@'
                str = ['@' str];
            end
        end
        return
    case 'char'
        if escape_apostr_string
            str = regexprep(data,'''','''''');
        else
            str = data;
        end
        
        if ~isempty(pre_post_append_strings)
            str = [pre_post_append_strings{1} str pre_post_append_strings{2}];
        end
        %JAH TODO: Allow escaping of characters
        %ex. -> & to &amp
        return %Done to make obvious that nothing is needed below
    otherwise
        %Could add on check for toString or other similar method String()?
        error('Unhandled class')
end


if isNumeric
    remove_junk_char = false;
    
    %SOME ERROR CHECKING AND SETTING UP DIMENSIONS
    %----------------------------------------------------------------------
    if ndims(data) > 2
        error('arrays of greater than 2 dimensions are not supported')
    end
    
    if size(data,2) == 1 && ~maintain_colum_vec
        data = data'; %Force row vector
    end
    
    nRows = size(data,1);
    nCols = size(data,2);
    
    if numel(data) == 1 && scalar_no_brackets
        add_brackets = false;
    end
    
    %CONVERSION OF INTEGERS AND FLOATS TO MATRICES
    %---------------------------------------------------------------------
    if isInteger && compress_integers
        %NOTE: We need to compress along rows
        rowStrings = cell(1,nRows);
        for iRow = 1:nRows
            if length(unique(data(iRow,:))) == nCols
                rowStrings{iRow} = array2strMatlabStyle(data(iRow,:));
            else
                rowStrings{iRow} = sprintf('%ld ',data(iRow,:));
                rowStrings{iRow}(end) = [];
            end
        end
        if keep_semis && row_per_line
            delim = [';' new_line_space_holder];
        else
            delim = ';';
        end
        str = cellArrayToString(rowStrings,delim);
    else
        %CRAP: This is very close to mat2str, that doesn't allow
        %a format, just precision
        %Might rewrite using that if
        if isInteger
            float_format = '%ld';
        end
        %NOTE: a transpose is needed as we would normally go down a column
        %in reading the array, but in specifying the array we go across a
        %data = 1:4 <=(row) ; <=(new column) 5:8 etc
        %data(1) = 1; data(2) = 5; <= reading down the column
        
        if keep_semis && row_per_line
            delim = [' ' junk_char]; %2 spaces
            remove_junk_char = true; %We'll remove the 2 spaces which
            %aren't at a newline later
        else
            delim = ' ';
        end
        
        
        str = sprintf([float_format delim],data'); %We added a space so that
        %values are spaced out between each other
        I_SPACE = find(str == ' ');
        str(I_SPACE(nCols:nCols:end)) = ';';
        if keep_semis && row_per_line
            str(I_SPACE(nCols:nCols:end)+1) = new_line_space_holder;
        end
        str(end) = [];
    end
    
    %NOTE: At this point the string has no brackets and some extra junk if
    %we are planning on splitting it up into lines
    
    %EXECUTING A FEW EXTRA OPTIONS
    %---------------------------------------------------------------
    if row_per_line
        if keep_semis
            str(str == new_line_space_holder) = newL; %#ok<*UNRCH>
        else
            str(str == ';') = newL; %#ok<*UNRCH>
        end
    end
    
    if add_brackets
        if first_row_newline
            str = ['[' newL str ']'];
        else
            str = ['[' str ']'];
        end
    end
    
    if add_cast_data_type && (~strcmpi(class(data),'double') || ~dont_add_type_double)
        str = [class(data) '(' str ')'];
    end
    
    if remove_junk_char
        str(str == junk_char) = [];
    end
    
    if isLogical && logicals_as_text
       str = regexprep(str,'0','false');
       str = regexprep(str,'0','true');
    end
end