function [varargout] = find_curFile(datapath, varargin)
%if testing, input the arguments 'testing', true, 'datafile', datafilenum
% This function either finds the highest-numbered file in a folder or the
% next argument in a set of files, which it pops off the stack

varargin = sanitizeVarargin(varargin);
DEFINE_CONSTANTS
testing = false;
datafiles = [0]; 
END_DEFINE_CONSTANTS

allNEV = dir([datapath '\*.ns5']);
switch testing
    case false
        if isempty(allNEV) %deal with first file
            varargout{1} = 1; 
        else
            varargout{1} = str2double(allNEV(end).name(9:12))+1; 
        end
        varargout{2} = []; 
    case true
        varargout{1} = datafiles(1); 
        if ~any(contains({allNEV.name}, sprintf('%04d', datafiles(1))))
            error('Error: There is no file with that name in that directory.'); 
        end
        varargout{2} = datafiles(2:end); 
end
