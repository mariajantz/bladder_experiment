function b = stringCompare(A,op,B)
% stringCompare Compare ordering of two strings, e.g. 'Alpha' '<=' 'bet'
% 
% Uses 'issorted' internally to determine alphabetic ordering, which uses ASCII
if nargin == 1 && strcmp(A,'test'), test(); return; end;
assert(nargin == 3)
assert(iscellstr({A op B}),'All inputs must be strings')

switch op
    case '=='
        b = strcmp(A,B);
    case '~='
        b = ~strcmp(A,B);
    case '>='
        b = strcmp(A,B) || ~issorted({A B});
    case '>'
        b = ~issorted({A B});
    case '<='
        b = issorted({A B});
    case '<'
        b = ~strcmp(A,B) && issorted({A B});
    otherwise
        error('Unknown operator %s',op)
end

end

function test()
assert(stringCompare('A','==','A'))
assert(~stringCompare('A','==','B'))

assert(stringCompare('A','~=','a'))
assert(~stringCompare('A','~=','A'))

assert(stringCompare('A','>=','A'))
assert(stringCompare('B','>=','A'))
assert(~stringCompare('A','>=','B'))

assert(stringCompare('A','<=','A'))
assert(stringCompare('A','<=','B'))
assert(~stringCompare('B','<=','A'))

assert(stringCompare('A','<','B'))
assert(stringCompare('a','<','b'))
assert(~stringCompare('b','<','a'))

assert(stringCompare('B','>','A'))
assert(~stringCompare('A','>','B'))
end