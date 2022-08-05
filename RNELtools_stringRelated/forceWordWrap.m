function ret = forceWordWrap(str, lineLength, returnAsCell, lineSeparator)
% FORCEWORDWRAP Converts a long string into multiple lines
%
% ret = forceWordWrap(str,*lineLength, *returnAsCell, *newLineStr)
%
% Attempts to split a string every 'lineLength' characters, but will not
% break a line within a word. Therefore resulting lines may be longer than
% 'lineLength'
%
% INPUTS
% =========================================================================
%   str          - (char) string to split
%   lineLength   - (numeric) maximum line length, defaults to command
%   window size
%   returnAsCell - (logical) return result as a cell, rather than a string (false)
%   newLingStr   - (char) line separator to use ('\n')
%
% OUTPUTS
% =========================================================================
%   multiline_str - (string/cell) resulting
%
% tags: text, parsing, utility,

if nargin < 4
    lineSeparator = '\n';
    if nargin < 3
        returnAsCell = false;
        if nargin < 2
            cur_units = get(0,'Units');
            set(0,'Units','Characters');
            sz = get(0,'CommandWindowSize');
            set(0,'Units',cur_units);
            lineLength = sz(1);
        end
    end
end

if length(str) > lineLength
    
    % this matches as string size lineLength that does not break a word
    key       = sprintf('.{1,%d}\\S*\\s*',round(lineLength));
    line_cell = regexp(str,'[\r\n]','split');
    % CAA In the distant future it would be nice to ignore hyperlinks but its
    % kinda tricky.  The following code will remove them resulting in proper
    % breaking but then the links need to be added back in.
    % remove any links, these will incorrectly inflate the line length
    link_key = '(<\s*a\s+href.*?>)|(<\s*/\s*a\s*>)';
    % determine the start and stop position of links
    [start,stop] = regexp(line_cell,link_key,'start','end');
    % %     if all(cellfun(@isempty,start))
    % no links, do the remaining work is a lot easier
    ret = regexp(line_cell,key,'match');
    ret = [ret{:}];
    % %     else
    % %         % because there are links in this string we cannot immediately
    % %         % break the line. First we must remove the links...
    % %         str          = regexprep(line_cell,link_key,'');
    % %         % and then determine where the breaks would go if the links did not
    % %         % exist...
    % %         newline_idx  = regexp(line_cell,key,'end');
    % %
    % %         % now the line breaks are added, adjusting for the links
    % %         ret = cell(size(line_cell));
    % %         for iiLine = 1:length(line_cell)
    % %             if any(newline_idx{iiLine} < length(line_cell{iiLine}))
    % %                 % this line will be broken, but the link must first be
    % %                 % accounted for ...
    % %                 last_break = 1;
    % %                 for iiBreak = 1:length(newline_idx{iiLine})-1
    % %                     this_break  = newline_idx{iiLine}(iiBreak);
    % %                     this_break  = this_break + stop{iiLine}(find(stop{iiLine} < this_break,1,'last'));
    % %                     ret{iiLine} = [ret{iiLine} line_cell{iiLine}(2last_break:this_break)];
    % %                     last_break  = this_break;
    % %                 end
    % %                 ret{iiLine} = [ret{iiLine} line_cell{iiLine}(last_break:this_break)]
    % %                 keyboard
    % % %                 newline_idx{iiLine}
    % %             else
    % %                 % this line will not be broken, just copy to output
    % %                 ret{iiLine} = line_cell{iiLine};
    % %             end
    % %         end
    % %     end
    if ~returnAsCell
        mask = arrayfun(@length,ret) > 1;
        ret(mask) = cellfun(@(x)cellArrayToString(x,lineSeparator),ret(mask),'UniformOutput',false);
        ret = cellArrayToString(ret,lineSeparator);
    end
else
    ret = str;
end
end