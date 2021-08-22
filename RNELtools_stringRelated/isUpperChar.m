function mask = isUpperChar(str)
%isUpperChar  Returns logical as to whether characters are uppercase
%
%   MASK = isUpperChar(STRING)
%
%   INPUTS
%   =======================================================================
%   STRING :
%   
%   OUTPUTS
%   =======================================================================
%   MASK   :
%
%   See Also: isUpperChar

    mask = str >= 65 & str <= 90;