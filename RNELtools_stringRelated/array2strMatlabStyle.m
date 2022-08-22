function str = array2strMatlabStyle(A,varargin)
%function str = array2strMatlabStyle(A)
%
%   str = array2strMatlabStyle(A,varargin)
%
%   Reduces an INTEGER array input into a shortened colon notation
%
%   OPTIONAL INPUTS
%   =======================================================================
%   add_commas : (default true), if false, adds spaces instead of commas
%   small      : (default 1e-5), epsilon in determing if two floating point
%                 numbers are equal
%   mult_steps : (default false), if true, allows multiple step sizes to
%                 compress the data
%
%   EXAMPLE:
%   =============================================
%   A = [1 4 5 6 7 8 9 10 12 15 16 17 21 23 24 25];
%   str = array2strMatlabStyle(A)
%   str => 1,4:10,12,15:17,21,23:25
%
%   str2num(str) yields A again
%
%   NOTES:
%   2) Duplicates are removed and the string is sorted
%
%   See Also:
%   fp_isequal
%   cellArrayToString
%
%  tags: text, parsing

DEFINE_CONSTANTS
add_commas = true;
small      = 1e-5;
mult_steps = false;
END_DEFINE_CONSTANTS

%Sorts and removes duplicates
A = unique(A);

if isempty(A)
    str = '';
    return
elseif length(A) == 1
    str = num2str(A);
    return
end

%note, isinteger only checks the class type
if any(A - round(A) ~= 0)
    disp('Input must be an integer array')
end

if size(A,2) == 1
    A = A';
end

%diff below examines 2nd difference, not available for 2 elements
if length(A) == 2
    if A(2) - A(1) == 1
        str = sprintf('%ld:%ld',A(1),A(2));
    else
        str = sprintf('%ld %ld',A(1),A(2));
    end
    return
end

% detect arrays that have uniform spacing between elements value other than one
dA     = diff(A); %
dA2    = diff(dA);
isZero = fp_isequal(dA2,0,small);

if all(isZero)
    %do something
    if dA(1) == 1
        str = sprintf('%ld:%ld',A(1),A(end));
    else
        str = sprintf('%ld:%ld:%ld',A(1),dA(1),A(end));
    end
    return
end

if mult_steps
    %More compression, a bit slower ...
     
    dA = [dA NaN]; %Need to expand to avoid indexing issues
    
    sI = false(1,length(A));
    eI = false(1,length(A));
    
    eI(end) = true;
    runSize = 0;
    for i_Index = 1:length(A)-1
  
        if eI(i_Index)
            continue
        end
        
        %Determining if at a start
        %-----------------------------------
        if runSize == 0
            sI(i_Index) = true;
            runSize = 1;
        else
            runSize = runSize + 1;
        end
        
        %Determine if at an end
        %-------------------------------------
        if dA(i_Index) ~= dA(i_Index + 1)
            %This one took a while to figure out
            %Example 1:
            %I  = 1 2 3
            %A  = 2 4 8
            %dA = 2 4 NaN
            %@I = 1, we could do 2:2:4, but I decided not to allow this,
            %the first "if" statement takes care of this
            %
            %I  = 1 2 3 4
            %A  = 2 4 6 10
            %dA = 2 2 4 NaN
            %@I = 2, we have dA(2) ~= dA(4), but, we've had at least
            %one run of 2, so we decided to end at I = 3
            %2:2:6 10
            if runSize < 2
                eI(i_Index) = true;
            else
                %Next one will be a end
                eI(i_Index + 1) = true;
            end
            runSize = 0;
        end
    end
    
    %One edge case at the end:
    if eI(end - 1)
        sI(end) = true;
    end
    
    %For each group:
    %If sI(index) && eI(index) -> single value

    Istart = find(sI);
    Iend   = find(eI);
    temp_cellArray = cell(1,length(Istart));
    
    for i_Index = 1:length(Istart)
        if Istart(i_Index) == Iend(i_Index)
            temp_cellArray{i_Index} = int2str(A(Istart(i_Index)));
        elseif dA(Istart(i_Index)) == 1
            temp_cellArray{i_Index} = sprintf('%ld:%ld',A(Istart(i_Index)),A(Iend(i_Index))); 
        else
            temp_cellArray{i_Index} = sprintf('%ld:%ld:%ld',A(Istart(i_Index)),dA(Istart(i_Index)),A(Iend(i_Index)));    
        end
    end
    
    if add_commas
        str = cellArrayToString(temp_cellArray,',');
    else
        str = cellArrayToString(temp_cellArray,' ');
    end
else
    
    %OLD CODE
    %=====================================================
    aStep = 1;
    str_sep = ':';
    
    %We keep track of where the difference is aStep
    d = [0 dA 0]; %to take care of edge effects
    d(~fp_isequal(d,aStep,small)) = 0;

    %We then look for a transition to 1 or to -1
    d2 = diff(d);

    %These are the numbers we are going to keep
    I = find(fp_isequal(d2,aStep,small)| fp_isequal(d2,-aStep,small)| d(2:end) == 0);

    %This puts a , between all of the numbers
    %If there was a group together, we put a ':' in, instead
    P = cell(2,length(I));
    P(1,:) = cellfun(@num2str,num2cell(A(I)),'UniformOutput',false);
    %P(1,:) = cellfun(@(x) int2str(x),num2cell(A(I)),'UniformOutput',false);
    if add_commas
        P(2,:) = {','};
    else
        P(2,:) = {' '};     %#ok<*UNRCH>
    end
    P(2,d2(I) == aStep) = {str_sep};
    P{2,end} = [] ;

    str = sprintf('%s',P{:});
 
    
    
end

end



%groupInfo =
%           counts: [1 3]
%     startIndices: [1 4]
%2     4     6    10    11    12    13    14



% % % %JAH - we could improve to allow different compression for different parts of the array
% % % if all(fp_isequal(dA(1),dA(2:end),small)) && dA(1) ~= 1
% % %     aStep   = dA(1);
% % %     str_sep = [':',num2str(aStep),':'];
% % % else
% % %     str_sep = ':';
% % %     aStep = 1;
% % % end


% % % end


%VALIDATION
%====================
% B = str2num(str);
% C = A - B;
% if any(C ~= 0)
%     error('oops')
% else
%     disp('Hooray')
% end