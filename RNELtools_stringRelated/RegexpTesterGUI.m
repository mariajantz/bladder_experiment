function hfig = RegexpTesterGUI(str,key)
% REGEXPTESTERGUI Simple GUI for testing regular expressions
%
% RegexpTestGUI
%
%
% tags: gui, parsing, text, regexp
% see also: regexp, regexptranslate, regexprep, VariableSelectionGUI

if nargin < 1
    str = '';
    if nargin < 2
        key = '';
    end
end


hfig = figure( ...
    'Name','Regular Expression Tester', ...
    'MenuBar','none',                   ...
    'NumberTitle','off',                ...
    'IntegerHandle','off');

position    = get(hfig,'Position');
position(4) = position(4)-300;
set(hfig,'Position',position);

% Input String
% ============================================================
margins = [.075 .05];
height  = 0.3;
width   = 0.9;
x = margins(1);
y = 1 - margins(2)- height;
string_edit = uicontrol('Style','edit','Tag','stringedit','Callback',@stringedit_Callback, ...
    'Min',0,'Max',1e3,'Units','Normalized','Position',[x y width height],'Parent',hfig, 'FontSize',12, ...
    'HorizontalAlignment','left','String',str);
h_text =  add_uicontrol_title(string_edit,'String','left');

file_push = uicontrol('Style','pushbutton','Tag','filepush','Callback',@filepush_Callback, ...
    'Units','Normalized','Position',[x y .19 height],'Parent',hfig, 'FontSize',12,'visible','off', ...
    'String', 'Open File...');

% Result String ===========================================================
y = y - height;
result_edit = uicontrol('Style','listbox','Tag','resultedit','Enable','on', ...
    'Min',0,'Max',1e3, ...
    'Units','Normalized','Position',[x y width height],'Parent',hfig, 'FontSize',12);
h_text =  add_uicontrol_title(result_edit,'Result','left');

% Regexp String ===========================================================
y = y - height;
regexp_edit = uicontrol('Style','edit','Tag','regexpedit',  ...
    'Callback',@regexpedit_Callback, ...'KeyPressFcn',@regexpedit_KeyPressFcn, ...
    'Units','Normalized','Position',[x y width height],'Parent',hfig, 'FontSize',12, ...
    'String',str);
h_text =  add_uicontrol_title(regexp_edit,'Key','left');

% Replace String (Created Invisible) ======================================
replace_edit = uicontrol('Style','edit','Tag','replaceedit',  ...
    'Callback',@regexpedit_Callback, ...'KeyPressFcn',@regexpedit_KeyPressFcn, ...
    'Units','Normalized','Position',[.5 .05 .475 height],'Parent',hfig, 'FontSize',12, ...
    'String','','Visible','off','HitTest','off');
h_text =  add_uicontrol_title(replace_edit,'Replace','left');
set(h_text,'tag','replacetext','Visible','off','HitTest','off');

% Source UIMenu ===========================================================
source_menu = uimenu('Tag','src','Label','Source');
uimenu('Tag','src','Label','gui','Parent',source_menu,...
    'Checked','on','Callback',@(x,y)sourcemenu_Callback(x,y,'src'));
uimenu('Tag','src','Label','file','Parent',source_menu,...
    'Checked','off','Callback',@(x,y)sourcemenu_Callback(x,y,'src'));
uimenu('Tag','src','Label','workspace','Parent',source_menu,...
    'Checked','off','Callback',@(x,y)sourcemenu_Callback(x,y,'src'));

% Method UIMenu ===========================================================
method_menu = uimenu('Tag','method','Label','Method');
uimenu('Tag','method','Label','regexp','Parent',method_menu,...
    'Checked','on','Callback',@(x,y)singlecheck_uimenu_Callback(x,y,'method'));
uimenu('Tag','method','Label','regexpi','Parent',method_menu,...
    'Checked','off','Callback',@(x,y)singlecheck_uimenu_Callback(x,y,'method'));
% uimenu('Tag','method','Label','regexprep','Parent',method_menu,...
%     'Checked','off','Callback',@(x,y)singlecheck_uimenu_Callback(x,y,'method'));

% Mode UIMenu =============================================================
mode_menu = uimenu('Tag','mode','Label','Mode');
uimenu('Tag','mode','Label','match','Parent',mode_menu,...
    'Checked','on','Callback',@(x,y)modemenu_Callback(x,y,'mode'));
uimenu('Tag','mode','Label','replace','Parent',mode_menu,...
    'Checked','off','Callback',@(x,y)modemenu_Callback(x,y,'mode'));
uimenu('Tag','mode','Label','names','Parent',mode_menu,...
    'Checked','off','Callback',@(x,y)modemenu_Callback(x,y,'mode'));

% Export UIMenu =============================================================
export_menu = uimenu('Tag','export','Label','Export');
uimenu('Tag','export','Label','export', 'Parent', export_menu,...
    'Callback',@(x,y)exportmenu_Callback(x,y));

% Help UIMenu =============================================================
help_str = sprintf('jar:file:///%s/help/techdoc/help.jar!/matlab_prog/f0-42649.html',matlabroot);

help_menu = uimenu('Tag','helpmenu','Label','Help');
uimenu('Tag','helpmenu','Label','regexp',....
    'Callback',@(x,y)doc('regexp'),'Parent',help_menu);
uimenu('Tag','helpmenu','Label','Regular Expressions',....
    'Callback',@(x,y)web(help_str, '-helpbrowser'),'Parent',help_menu, 'Accelerator','H');

if isempty(str)
    % set initial focus to the string edit for typing
    setfocus(string_edit);
else
    % update the search
    event           = [];
    event.Character = '';
    event.Key       = 'enter';
    event.Modifier  = {};
    execute_callback(regexp_edit,'KeyPressFcn',event);
end

end

function exportmenu_Callback(hObject,event)
h   = findobj('tag','regexpedit');
str = get_uicontrol_selection(h,true);
assignin('base','RegexpTesterGUI_key',str);
fprintf('Assigning ''%s'' to variable ''RegexpTesterGUI_key''\n',str);
end

function filepush_Callback(hObject,event)
[filename, pathname, filterindex] = uigetfile('*.*','File Selector');
if filterindex
    filepath = fullfile(pathname,filename);
    
    str      = fileread(filepath);
    
    set(findobj(gcbf,'tag','stringedit'),'string',str);
end

end

function sourcemenu_Callback(hObject,event,tag)
singlecheck_uimenu_Callback(hObject,event,tag)
src_str = get(findobj(gcbf,'Tag',tag,'Checked','on'),'Label');
switch(lower(src_str))
    case 'gui'
        set(findobj('String','String'),'visible','on')
        set(findobj(gcbf,'Tag','filepush'),'visible','off')
        h = findobj(gcbf,'Tag','stringedit');
        set(h,'position',[.075 .65 .9 .3],'visible','on')
    case 'file'
        set(findobj(gcbf,'String','String'),'visible','off')
        hpush = findobj(gcbf,'Tag','filepush');
        pushpos   = get(hpush,'Position');
        set(hpush,'visible','on')    
        hedit   = findobj(gcbf,'tag','stringedit');
        editpos = get(hedit,'Position');
        pos     = [pushpos(1)+pushpos(3) editpos(2) editpos(3)-pushpos(3) pushpos(4) ];
        set(hedit,'Position',pos) 
    case 'workspace'       
        [ret,str] = VariableSelectionGUI({'char','cell'});
        if ret
            assert(ischar(str) || (iscell(str) && all(cellfun(@(x)strcmp(class(x),'char'),str))), ...
                'variable must either be a character or a cell of characters')
            set(findobj(gcbf,'Tag','stringedit'),'String',str);
        end
    otherwise
        error('Unknown source ''%s''',src_str)
end
end

function modemenu_Callback(hObject,event,tag)
singlecheck_uimenu_Callback(hObject,event,tag)
src_str = get(findobj(gcbf,'Tag',tag,'Checked','on'),'Label');
switch(lower(src_str))
    case 'match'
        set(findobj(gcbf,'Tag','replaceedit','-or','Tag','replacetext'),'visible','off','hittest','off')
        set(findobj(gcbf,'Tag','regexpedit'),'Position',[.075 .05 .9 .3])
    case 'replace'
        set(findobj(gcbf,'Tag','replaceedit','-or','Tag','replacetext'),'visible','on','hittest','on')
        set(findobj(gcbf,'Tag','regexpedit'),'Position',[.075 .05 .35 .3])
    case 'names'
        set(findobj(gcbf,'Tag','replaceedit','-or','Tag','replacetext'),'visible','off','hittest','off')
        set(findobj(gcbf,'Tag','regexpedit'),'Position',[.075 .05 .9 .3])
    otherwise
        error('Unknown source ''%s''',src_str)
end

end

function singlecheck_uimenu_Callback(hObject,event,tag)
% Don't allow unchecking!
if strcmpi(get(hObject,'Checked'),'on')
    return
end

% uncheck all
set(findobj(gcbf,'Tag',tag),'Checked','off')
% check this menu
set(hObject,'Checked','on')

execute_callback(findobj(gcbf,'Tag','regexpedit'));

end

function stringedit_Callback(hObject,event)
execute_callback(findobj(gcbf,'Tag','regexpedit'));

end

function regexpedit_KeyPressFcn(hObject,event)

hresultedit = findobj(gcbf,'Tag','resultedit');
hstringedit = findobj(gcbf,'Tag','stringedit');

% don't update for special keys
if ~isempty(strfind(event.Key,'arrow')) || any(strcmpi(event.Key,{'shift','home','end','f5','f10','f11'}))
    return
end

% manually set focus, otherwise the 'String' property of the control
% wont get updated. This was a HUGE PiTA
pause(.1)
setfocus(hstringedit);
pause(.01)
setfocus(hObject);

% concatenate horizontally
src_str = cellArrayToString(get_uicontrol_selection(hstringedit,false),'\n');
if size(src_str,1) > 1
    src_str = reshape(src_str',[1 numel(src_str)]);
end
key_str = get_uicontrol_selection(hObject,true);
if isempty(src_str) || isempty(key_str)
    set(hresultedit,'String','');
    return
end

% find method string and convert to function
search_method_str = get(findobj(gcbf,'type','uimenu','tag','method','checked','on'),'Label');
search_method     = str2func(search_method_str);
search_mode       = get(findobj(gcbf,'type','uimenu','tag','mode','checked','on'),'Label');

if strcmpi(search_method_str,'replace')
    matches = search_method(src_str,key_str,search_mode);
elseif strcmpi(search_method_str,'replace')
    rep_str = get_uicontrol_selection(findobj(gcbf,'type','edit','tag','replaceedit'),true);
    matches = search_method(src_str,key_str,rep_str);
else
    error('Unhandled search method ''%s''',search_method_str);
end
% matches = [matches{:}];
if ~isempty(matches)
    if length(matches) > 1
        result_str = sprintf('{%s}',cellArrayToString(matches,'} , {'));
    else
        result_str = matches{1};
    end
    set(hstringedit,'Units','Character')
    nchar = get(hstringedit,'Position');
    set(hstringedit,'Units','Normalized')
    result_str = forceWordWrap(result_str,nchar(3)-nchar(1),true);
else
    result_str = '[ ];';
end
set(hresultedit,'String',result_str);
end

function regexpedit_Callback(hObject,event)


hresultedit = findobj(gcbf,'Tag','resultedit');
hstringedit = findobj(gcbf,'Tag','stringedit');
hkeyedit    = findobj(gcbf,'tag','regexpedit');
hreplacedit = findobj(gcbf,'tag','replaceedit');
% concatenate horizontally
src_str = cellArrayToString(get_uicontrol_selection(hstringedit,false),'\n');
if size(src_str,1) > 1
    src_str = reshape(src_str',[1 numel(src_str)]);
end
key_str = get_uicontrol_selection(hkeyedit,true);
if isempty(src_str) || isempty(key_str)
    set(hresultedit,'String','');
    return
end

% find method string and convert to function
search_method = str2func(get(findobj(gcbf,'type','uimenu','tag','method','checked','on'),'Label'));
search_mode   = get(findobj(gcbf,'type','uimenu','tag','mode','checked','on'),'Label');
if strcmpi(search_mode,'match')
    matches = search_method(src_str,key_str,search_mode);
elseif strcmpi(search_mode,'replace')
    replace_str = get_uicontrol_selection(hreplacedit,true);
    if isempty(replace_str)
        replace_str = '';
    end
    matches     = regexprep(src_str,key_str,replace_str);
elseif strcmpi(search_mode,'names')
    matches = search_method(src_str,key_str,search_mode);
    if ~isempty(matches)
        fields = fieldnames(matches);
        matches = cellfun(@(x)sprintf('%s: %s',x,cellArrayToString({matches.(x)},',')),fields,'UniformOutput',false);
    end
else 
    error('Unknown search mode ''%s''',search_mode);
end

if isempty(matches)
    matches = {'[ ];'};
end
set(hresultedit,'String',matches,'Value',1);
end
