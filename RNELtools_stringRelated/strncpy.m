function out = strncpy(str,n)
% STRNCPY - Copy STR to OUT, with gauranteed length N (fixed-width output)
% 
% Behaves exactly like libc strncpy. Two cases:
%   length(STR) < N: OUT is padded with null bytes ('\0') to length N.
%   length(STR) >= N: OUT(1:N) = STR(1:N)
% 
% Althogh trivial, it can be used for fwrite() with fixed-width header fields

out = repmat(char(0),[1 n]);
out(1:min(length(str),n)) = str;
