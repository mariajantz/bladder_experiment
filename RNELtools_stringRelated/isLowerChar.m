function mask = isLowerChar(str)
%isLowerChar  Returns logical as to whether characters are uppercase
%
%   MASK = isLowerChar(STRING)
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

    mask = str >= 97 & str <= 122;