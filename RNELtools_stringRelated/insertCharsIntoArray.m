function outputArray = insertCharsIntoArray(inputArray,charsInsert,indices)
%insertScalarsIntoArray Inserts charsInsert into an array at specified positions, expanding the array
%
%   outputArray = insertScalarsIntoArray(inputArray,charsInsert,indices)
%
%   INPUTS
%   =====================================
%   inputArray : the original input array
%   charsInsert: the values to insert into the array
%   indices    : indices of the original array after which to insert the 
%                new values, note, a value of 0 makes the value the first
%                value in the array
%
%   NOTE: Repeats of indices & charsInsert are inserted in order, thus if an
%   index is repeated twice, the first scalar value gets inserted after the
%   original value, and the second value gets inserted after the first
%
%   EXAMPLE
%   =======================================

if ischar(charsInsert)
    charsInsert = {charsInsert};
end

if length(indices) ~= length(charsInsert)
    error('The length of indices and charsInsert must match')
end

outputArray = char(zeros(1,length(inputArray) + sum(cellfun('length',charsInsert))));

[indices,I] = sort(indices);
charsInsert = charsInsert(I);
lenChars = cellfun('length',charsInsert);

%Now, since all the indices are sorted, we get the the boundaries
[~,I] = unique_2011b(indices,'first');
I(end + 1) = length(indices) + 1;

if indices(1) < 0 || indices(end) > length(inputArray)
    error('Indices are out of range')
end

curNewIndex  = 1;
curOrigIndex = 0;

for iGroup = 1:(length(I)-1)
   %Placement of proceeding array data
   lengthProc = indices(I(iGroup)) - curOrigIndex;
   outputArray(curNewIndex:(curNewIndex+lengthProc-1)) = inputArray(curOrigIndex+1:curOrigIndex+lengthProc);
   curNewIndex = curNewIndex + lengthProc;
   curOrigIndex = curOrigIndex + lengthProc;
   
   %Insertion of all charsInsert that go in after that index
   indicesUse = I(iGroup):I(iGroup+1)-1;
   lengthGroup = sum(lenChars(indicesUse));
   outputArray(curNewIndex:(curNewIndex+lengthGroup-1)) = [charsInsert{indicesUse}];
   curNewIndex = curNewIndex + lengthGroup;
end

if curOrigIndex ~= length(inputArray)
    outputArray(curNewIndex:end) = inputArray(curOrigIndex+1:end);
end