function tf = strncmp_ca(ca,str,case_sensitive)
%strncmp_ca  Performs strncmp when first input is a cell array
%
%   strncmp_ca(ca,str,*case_sensitive)
%
%   Use this function when you want to compare a bunch of strings of
%   variable lengths (cellstr) to another string
%
%   INPUTS
%   =======================================================================
%   ca : (cellstr)
%   str: string to compare cell array options to
%
%   OPTIONAL INPUTS
%   =======================================================================
%   case_sensitive: (default true)
%
%   EXAMPLE
%   =======================================================================
%   ca = {'a' 'ba' 'cba' 'test'};
%   str = 'bath';
%   tf = strncmp_ca(ca,str);
%   tf => 0     1     0     0

if ~exist('case_sensitive','var')
    case_sensitive = true;
end

tf = false(1,length(ca));
if case_sensitive
    for i_ca = 1:length(ca)
        tf(i_ca) = strncmp(ca{i_ca},str,length(ca{i_ca}));
    end
else
    for i_ca = 1:length(ca)
        tf(i_ca) = strncmpi(ca{i_ca},str,length(ca{i_ca}));
    end
end

end
