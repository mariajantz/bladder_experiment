function str = trimNullTerminatedString(str)
%trimNullTerminatedString
%
%   str = trimNullTerminatedString(str)
%
%   This file was originally created for implementing file specifications
%   which specify null termination (if needed) but allow a maximum of a 
%   certain # of bytes.
%
%   The hope was that I could find a way to make this quicker ... so
%   abstract the simple functionality by making it a method with the
%   possibility that its implementation might change
%
%   EXAMPLE
%   ==================================================================
%   str = ['abcd' char(0) '... junk ...'];
%   str = trimNullTerminatedString(str);
%   str = 'abcd';
%   

   str(find(str == char(0),1):end) = [];
end