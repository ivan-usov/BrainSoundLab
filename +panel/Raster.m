function p = Raster
ph = 470; % panel height
pTitle = 'Raster';
pTag = 'Raster';
% Panel and hide button
p = uipanel(gcf, 'Units', 'pixels', 'FontWeight', 'bold', 'Visible', 'off', ...
    'BorderType', 'line', 'HighlightColor', [0.5 0.5 0.5], ...
    'Title', pTitle, ...
    'Tag', pTag, ...
    'Position', [0 0 1000 ph]);
BSL = guidata(gcf);
uicontrol(p, 'Style', 'pushbutton', ...
    'String', char(9645), 'FontWeight', 'bold', 'FontSize', 12, ...
    'HitTest', 'off', ...
    'Callback', @(h,ed) BSL.popPanel(p), ...
    'Position', [957 ph-30 21 16]);
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'x', ...
    'HitTest', 'off', ...
    'Callback', @(h,ed) BSL.hidePanel(pTag), ...
    'Position', [977 ph-30 20 16]);
% Panel components --------------------------------------------------------
% Raster axes
axes('Parent', p, 'Units', 'pixels', 'NextPlot', 'replacechildren', ...
    'Box', 'on', ...
    'FontSize', 9, ...
    'Tag', 'ax_raster', ...
    'Position', [60, 45, 720, 400]);
xlabel('Time, s');
ylabel('Trial');
% Time plotting range
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Time plotting range:', ...
    'Position', [810 ph-45 150 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 's', ...
    'Position', [973 ph-68 35 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'Enable', 'off', ...
    'Tag', 'e_timeRasterMin_raster', ...
    'Callback', @(h,ed) Callback_timeRaster(h, BSL), ...
    'Position', [870 ph-72 51 22]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'Enable', 'off', ...
    'Tag', 'e_timeRasterMax_raster', ...
    'Callback', @(h,ed) Callback_timeRaster(h, BSL), ...
    'Position', [920 ph-72 51 22]);
% Groups and filters
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Groups and filters:', ...
    'Position', [810 ph-101 150 14]);
uicontrol(p, 'Style', 'listbox', 'HorizontalAlignment', 'left', ...
    'Enable', 'off', ...
    'Tag', 'lb_groupsFiltersLabel_raster', ...
    'Callback', @(h,ed) Callback_groupsFiltersLabel(h, BSL), ...
    'Position', [810 ph-195 101 90]);
uicontrol(p, 'Style', 'listbox', 'HorizontalAlignment', 'left', ...
    'Enable', 'off', ...
    'Tag', 'lb_groupsFiltersVal_raster', ...
    'Callback', @(h,ed) Callback_groupsFiltersVal(h, BSL), ...
    'Position', [920 ph-195 50 90]);
% Sort trials by
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Sort trials by:', ...
    'Position', [810 ph-224 150 14]);
uicontrol(p, 'Style', 'popupmenu', 'HorizontalAlignment', 'left', ...
    'String', ' ', ...
    'Enable', 'off', ...
    'Tag', 'pm_sortBy_raster', ...
    'Callback', @(h,ed) Callback_sortBy (h, BSL), ...
    'Position', [870 ph-251 101 22]);
% Processing range
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Processing range', ...
    'Position', [810 ph-280 150 14]);
% ----- time
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'time:', ...
    'Position', [820 ph-303 150 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'ms', ...
    'Position', [973 ph-303 35 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'Enable', 'off', ...
    'Tag', 'e_timeProcMin_raster', ...
    'Callback', @(h,ed) Callback_timeProc(h, BSL), ...
    'Position', [870 ph-307 51 22]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'Enable', 'off', ...
    'Tag', 'e_timeProcMax_raster', ...
    'Callback', @(h,ed) Callback_timeProc(h, BSL), ...
    'Position', [920 ph-307 51 22]);
% Left/Right
uicontrol(p, 'Style', 'pushbutton', ...
    'String', char(8592), ...
    'Enable', 'off', ...
    'Tag', 'pb_left_raster', ...
    'Callback', @(h,ed) Callback_leftright(h, BSL), ...
    'Position', [870 ph-330 51 22]);
uicontrol(p, 'Style', 'pushbutton', ...
    'String', char(8594), ...
    'Enable', 'off', ...
    'Tag', 'pb_right_raster', ...
    'Callback', @(h,ed) Callback_leftright(h, BSL), ...
    'Position', [920 ph-330 51 22]);
% Auto range
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Auto', ...
    'Enable', 'off', ...
    'Tag', 'pb_autoRange_raster', ...
    'Callback', @(h,ed) Callback_autoRange(h, BSL), ...
    'Position', [870 ph-352 51 22]);
% Fix range
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Fix', ...
    'Enable', 'off', ...
    'Tag', 'pb_fixRange_raster', ...
    'Callback', @(h,ed) Callback_fixRange(h, BSL), ...
    'Position', [920 ph-352 51 22]);
% Repetitions
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Repetitions:', ...
    'Position', [810 ph-381 95 14]);
uicontrol(p, 'Style', 'listbox', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'Max', 10, ... % Make the multiple selection possible
    'Enable', 'off', ...
    'Tag', 'lb_repetitions_raster', ...
    'Callback', @(h,ed) Callback_repetitions(h, BSL), ...
    'Position', [920 ph-455 51 90]);
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Select all', ...
    'Enable', 'off', ...
    'Tag', 'pb_selectAllRep_raster', ...
    'Callback', @(h,ed) Callback_selectAll(h, BSL), ...
    'Position', [810 ph-455 75 22]);

function Callback_timeRaster(hObject, BSL)
block = BSL.block;
val = sscanf(get(hObject, 'String'), '%f', 1);
switch get(hObject, 'Tag')
    case 'e_timeRasterMin_raster'
        if isempty(val)
            set(hObject, 'String', block.timeRasterMin);
            errordlg('timeRasterMin must be a number', 'Error');
            return
        end
        block.timeRasterMin = val;
        
    case 'e_timeRasterMax_raster'
        if isempty(val)
            set(hObject, 'String', block.timeRasterMax);
            errordlg('timeRasterMax must be a number', 'Error');
            return
        end
        block.timeRasterMax = val;
end
block.processData('timeRasterMod');

function Callback_groupsFiltersLabel(hObject, BSL)
block = BSL.block;
str = get(hObject, 'String');
val = get(hObject, 'Value');

ind = strcmp({block.group.label}, str(val));
if any(ind)
    set(findobj('Tag', 'lb_groupsFiltersVal_raster'), ...
        'Max', 1, ...
        'String', block.group(ind).val, ...
        'Value', block.group(ind).sel);
end

if ~isempty(block.filtSpikes)
    ind = strcmp({block.filtSpikes.label}, str(val));
    if any(ind)
        set(findobj('Tag', 'lb_groupsFiltersVal_raster'), ...
            'Max', 10, ...
            'String', block.filtSpikes(ind).val, ...
            'Value', block.filtSpikes(ind).sel);
        
        % TODO: this should be generalized or removed completely
        % modify Clusters list based on Single Unit selection, e.g. show in
        % red clusters that don't belong to the selected Single Unit filter
        if strcmp(block.filtSpikes(ind).label, 'Cluster')
            su_ind = find(strcmp({block.filtSpikes.label}, 'Single Unit'));
            su_sel = block.filtSpikes(su_ind).sel;
            unsel_ind = find(~ismember(1:block.filtSpikes(su_ind).len, su_sel));
            if ~isempty(unsel_ind)
                idx = block.custom.temp_clusters{unsel_ind(1)};
                for i = unsel_ind(2:end)
                    idx = idx & this.custom.temp_clusters{i};
                end
                
                lines = num2cell(block.filtSpikes(ind).val);
                for i = find(idx)'
                    lines(i) = {['<HTML><BODY color="Red">', num2str(lines{i})]};
                end
                set(findobj('Tag', 'lb_groupsFiltersVal_raster'), 'String', lines);
            end
        end
        % -----------------------------------------------------------------
    end
end

if ~isempty(block.filtStim)
    ind = strcmp({block.filtStim.label}, str(val));
    if any(ind)
        set(findobj('Tag', 'lb_groupsFiltersVal_raster'), ...
            'Max', 10, ...
            'String', block.filtStim(ind).val, ...
            'Value', block.filtStim(ind).sel);
    end
end

function Callback_groupsFiltersVal(hObject, BSL)
block = BSL.block;
val = get(hObject, 'Value');

str = get(findobj('Tag', 'lb_groupsFiltersLabel_raster'), 'String');
ind = get(findobj('Tag', 'lb_groupsFiltersLabel_raster'), 'Value');

idx = strcmp({block.group.label}, str(ind));
if any(idx)
    block.group(idx).sel = val;
    block.displayData();
end

if ~isempty(block.filtSpikes)
    idx = strcmp({block.filtSpikes.label}, str(ind));
    if any(idx)
        block.filtSpikes(idx).sel = val;
        block.processData('timeRasterMod');
    end
end

if ~isempty(block.filtStim)
    idx = strcmp({block.filtStim.label}, str(ind));
    if any(idx)
        block.filtStim(idx).sel = val;
        block.processData('timeRasterMod');
    end
end

function Callback_sortBy(hObject, BSL)
str = get(hObject, 'String');
val = get(hObject, 'Value');
BSL.selectSortByStim(str(val));

display.Raster();
display.updateProcArea();

BSL.block.displayData();

function Callback_timeProc(hObject, BSL)
block = BSL.block;
val = sscanf(get(hObject, 'String'), '%f', 1)/1000; % convert to seconds
switch get(hObject, 'Tag')
    case 'e_timeProcMin_raster'
        if isempty(val)
            set(hObject, 'String', block.timeProcMin{BSL.curGroup}(BSL.curChannel));
            errordlg('timeProcMin must be a number', 'Error');
            return
        end
        block.timeProcMin{BSL.curGroup}(BSL.curChannel) = val;
        
    case 'e_timeProcMax_raster'
        if isempty(val)
            set(hObject, 'String', block.timeProcMax{BSL.curGroup}(BSL.curChannel));
            errordlg('timeProcMax must be a number', 'Error');
            return
        end
        block.timeProcMax{BSL.curGroup}(BSL.curChannel) = val;
end

block.autoProcTime{BSL.curGroup}(BSL.curChannel) = false;
set(findobj('Tag', 'pb_autoRange_raster'), 'Enable', 'on');

block.processData('timeProcMod', BSL.curGroup, BSL.curChannel);

function Callback_leftright(hObject, BSL)
block = BSL.block;
t_min = block.timeProcMin{BSL.curGroup}(BSL.curChannel);
t_max = block.timeProcMax{BSL.curGroup}(BSL.curChannel);

shift = (block.timeRasterMax-block.timeRasterMin)*0.02;

switch get(hObject, 'Tag')
    case 'pb_left_raster'
        if t_min - shift > block.timeRasterMin
            t_min = t_min - shift;
            t_max = t_max - shift;
        else
            shift = t_min - block.timeRasterMin;
            t_min = block.timeRasterMin;
            t_max = t_max - shift;
        end
        
    case 'pb_right_raster'
        if t_max + shift < block.timeRasterMax
            t_min = t_min + shift;
            t_max = t_max + shift;
        else
            shift = block.timeRasterMax - t_max;
            t_min = t_min + shift;
            t_max = block.timeRasterMax;
        end
end

block.timeProcMin{BSL.curGroup}(BSL.curChannel) = t_min;
block.timeProcMax{BSL.curGroup}(BSL.curChannel) = t_max;

set(findobj('Tag', 'e_timeProcMin_raster'), 'String', t_min*1000);
set(findobj('Tag', 'e_timeProcMax_raster'), 'String', t_max*1000);

block.autoProcTime{BSL.curGroup}(BSL.curChannel) = false;
set(findobj('Tag', 'pb_autoRange_raster'), 'Enable', 'on');

block.processData('timeProcMod', BSL.curGroup, BSL.curChannel);

function Callback_autoRange(hObject, BSL)
block = BSL.block;
block.processData('autoProcRange', BSL.curGroup, BSL.curChannel);

t_min = block.timeProcMin{BSL.curGroup}(BSL.curChannel);
t_max = block.timeProcMax{BSL.curGroup}(BSL.curChannel);
set(findobj('Tag', 'e_timeProcMin_raster'), 'String', t_min*1000);
set(findobj('Tag', 'e_timeProcMax_raster'), 'String', t_max*1000);

block.autoProcTime{BSL.curGroup}(BSL.curChannel) = true;
set(findobj('Tag', 'pb_autoRange_raster'), 'Enable', 'off');

block.processData('timeProcMod', BSL.curGroup, BSL.curChannel);

function Callback_fixRange(hObject, BSL)
block = BSL.block;

t_min = block.timeProcMin{BSL.curGroup}(BSL.curChannel);
t_max = block.timeProcMax{BSL.curGroup}(BSL.curChannel);

for k = 1:block.nGroups
    for l = 1:block.nChannels
        block.timeProcMin{k}(l) = t_min;
        block.timeProcMax{k}(l) = t_max;
        block.autoProcTime{k}(l) = false;
        block.processData('timeProcMod', k, l);
    end
end

function Callback_repetitions(hObject, BSL)
block = BSL.block;
val = get(hObject, 'Value');
if isempty(val); return; end

block.selRep = val;

block.processData('all');

function Callback_selectAll(hObject, BSL)
block = BSL.block;
h = findobj('Tag', 'lb_repetitions_raster');
val = 1:length(get(h, 'String'));
set(h, 'Value', val);

block.selRep = val;

block.processData('all');

