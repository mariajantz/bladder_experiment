function str = toCellArrayString(cA,varargin)
%toCellArrayString  Converts a cell array of strings to a string
%
%   STRING = toCellArrayString(CELL_ARRAY,varargin) converts CELL_ARRAY 
%   to a string such that eval(STRING) equals CELL_ARRAY
%
%   FUNCTION CURRENTLY ONLY IMPLEMENTED FOR 1D CELL ARRAY
%
%   OPTIONAL INPUTS: IMPORTANT MUST BE PROPERTY/VALUE PAIRS
%   =======================================================================
%
%
%
%   EXAMPLE:
%   =================================
%   a = {'a' 'b' 'c'};
%   str = toCellArrayString(a);
%   
%   str => '{''a'' ''b'' ''c''}';
%   a = eval(str)
%   a => {'a' 'b' 'c'};
%
%   example for which it was developed
%   functionString = ['variablesToStruct(' toCellArrayString(a) ')'];
%   functionString => 'variablesToStruct({''a'' ''b'' ''c''})'
%   constStruct = evalin('caller',functionString)
%
%   See Also: variablesToStruct, cellArrayToString

%This function is called by END_DEFINE_CONSTANTS
%so they can't be used here
temp = [who; {'temp'}];
keepMatrix = false;
alignVars  = true;
spacePad   = 2;
addDots    = true;
defaultOPTS = setdiff(who,temp);

if nargin > 1
    defNames = varargin(1:2:end);
else
    defNames = {};
end

for iDefault = 1:length(defaultOPTS)
    curVariable = defaultOPTS{iDefault};
    I = find(strcmpi(curVariable,defNames),1);
    if ~isempty(I)
        eval([curVariable '= varargin{2*I};'])
    end
end

extraSpaces = spacePad*ones(size(cA));
if keepMatrix && alignVars
   strSize   = cellfun(@(x) length(x) + length(find(x == '''')),cA);
   maxLength = max(strSize,[],1);
   extraSpaces = bsxfun(@minus,maxLength,strSize) + extraSpaces;
end

%NOTE: We need to escape all ' with two
%example -> a'b, needs to be written as a''b
cA  = cellfun(@(x,y) ['''' regexprep(x,'''','''''') '''' blanks(y)],cA,num2cell(extraSpaces),'un',0);
if keepMatrix
   nRows = size(cA,1);
   rowCA = cell(1,nRows+2);
   for iRow = 1:nRows
      if addDots
          rowCA{iRow+1} = [cA{iRow,:} '...'];
      else
          rowCA{iRow+1} = [cA{iRow,:}];
      end
   end
   rowCA{1} = '{...';
   rowCA{end} = '};';
   str = char(rowCA);
else
    str = cellArrayToString(cA,' ');
    str = ['{' str '}'];
end

end