function words = randword(nWords,lengthRange,charsUse)
%randword Generates random words
%
%   words = randword(nWords,lengthRange,charsUse)
%
%   INPUTS
%   =========================================================
%   nWords : # of words to generate
%   
%

wordLengths = randi(lengthRange,1,nWords);
words = arrayfun(@(x) char(charsUse(randi(length(charsUse),1,x))),wordLengths,'un',0);