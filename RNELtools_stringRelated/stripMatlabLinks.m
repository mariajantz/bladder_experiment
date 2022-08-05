function str = stripMatlabLinks(link_str)
% STRIPMATLABLINKS Strips matlab links from a string
% str = stripMatlabLinks(link_str)
str = regexprep(link_str,'<a href="matlab[^>]+>','');
str = regexprep(str,'</a>','');
end
