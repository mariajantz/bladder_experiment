function n = str2int(s1)
%str2int  A function for quickly converting a string to an integer.
%
%   NOTE: There is no error checking on this function, it only works for
%         integers with only such as -1 or 100 or 533, etc, not with any 
%         other fancy notation

lt = length(s1);

%Basic approach here is it take powers of 10 to each place
if s1(1) == '-'
    n = -1*((double(s1(2:lt))-48)*(((10*ones(1,lt-1)).^(lt-2:-1:0))'));
else    
    n = (double(s1)-48)*(((10*ones(1,lt)).^(lt-1:-1:0))');
end

%ERROR CHECKING APPROACH
%===================================
%MUCH SLOWER
%
% if s1(1) == '-'
%     start = 2;
% else
%     start = 1;
% end
% 
% lt = length(s1);
% %48 or 57
% if ~isempty(find(s1(start:lt) > 57 | s1(start:lt) < 48,1))  
%     n = str2double(s1);
%     return
% end
%    
% if start == 2
%     temp = double(s1(2:end)) - 48;
%     %Basic approach here is it take powers of 10 to each place
%     n = -1*(temp*((10*ones(1,lt-1).^(lt-2:-1:0))'));
% else
%     temp = double(s1(1:lt)) - 48; 
%     n = temp*((10*ones(1,lt).^(lt-1:-1:0))');
% end