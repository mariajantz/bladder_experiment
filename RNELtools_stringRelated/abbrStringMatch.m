function isMatch = abbrStringMatch(str1,str2,wordsRemove)
%abbrStringMatch
%
%   isMatch = abbrStringMatch(str1,str2,wordsRemove)
%
%   The goal of this function is to attempt to match strings
%   based on truncating words until the strings might match
%
%   ex. 
%   str1 = 'Prog Brain Res'
%   str2 = 'Progress In Brain Research'
%   wordsRemove = {'in' 'the' 'a'};
%
%   isMatch = abbrStringMatch(str1,str2,wordsRemove)
%   isMatch => true

str1 = strtrim(str1);
str2 = strtrim(str2);

str1_ca = lower(regexp(str1,' ','split'));
str2_ca = lower(regexp(str2,' ','split'));

str1_ca(ismember(str1_ca,wordsRemove)) = [];
str2_ca(ismember(str2_ca,wordsRemove)) = [];

isMatch = true;
if length(str1_ca) ~= length(str2_ca)
    isMatch = false;
else
   len1 = cellfun('length',str1_ca);
   len2 = cellfun('length',str2_ca);
   for iWord = 1:length(str1_ca)
      if ~strncmp(str1_ca{iWord},str2_ca{iWord},min(len1(iWord),len2(iWord)))
         isMatch = false;
         break
      end
   end
end

