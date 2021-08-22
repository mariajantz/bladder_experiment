function strOut = javaString_encode_decode(str,option)
%javaString_encode_decode
%
%   strOut = javaString_encode_decode(str,option)
%
%   JAH TODO: finish this function


switch lower(option)
    case 'encode'
        error('Not yet implemented')
    case 'decode'
       strOut = char(org.apache.commons.lang.StringEscapeUtils.unescapeJava(str));
       %
%        temp = java.lang.String(str);
%        strOut = char(java.lang.String(temp.getBytes,'UTF-8'));  
end