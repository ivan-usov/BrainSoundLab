function setBlock(this)
% Update the name and path for data to save
% (dataPath is empty, so that the initial call of Save Data -> Save Data As)
this.dataName = [this.block.name '.mat'];
this.dataPath = '';

% Get tags of all currently open panels
openPanelTags = get(this.openPanels, 'Tag');

% Close all panels with tags in 'openPanelTags' that are not in
% 'this.defaultPanels' or 'this.block.analysis'
for k = 1:length(openPanelTags)
    tag = openPanelTags{k};
    if ~any(strcmp(tag, this.defaultPanels)) && ~any(strcmp(tag, this.block.panels))
        this.hidePanel(tag);
    end
end

% Reupdate all currently open panels
openPanelTags = get(this.openPanels, 'Tag');

% Open all panels with tags in 'this.block.panels' that are not in
% 'openPanelTags'
for k = 1:length(this.block.panels)
    tag = this.block.panels{k};
    if strcmp(tag, 'AllChTRF')
        % In case of 'AllChTRF' analysis, open the correct version of the panel
        tag = [tag, '_', num2str(this.block.nChannels)];
    end
    if ~any(strcmp(tag, openPanelTags))
        this.showPanel(tag);
    end
end

% Update the Information panel
set(findobj('Tag', 'tab_information'), 'Data', [], ...
    'ColumnName', {'Parameter', 'Value', '', ''}, ...
    'ColumnFormat', {'char', 'bank', 'char', 'char'});
set(findobj('Tag', 'e_experimentComments_information'), ...
    'String', this.labbook.experimentComments);
set(findobj('Tag', 'e_blockComments_information'), ...
    'String', this.labbook.blockComments(this.curBlock));

% Update the Electrode panel
this.setElectrode(this.labbook.electrode.type);

% Update the Raster panel
gf_list = [];
gf_val = [];
if ~strcmp(this.block.group(1).label, 'None')
    gf_list = {this.block.group(:).label};
    gf_val = this.block.group(1).val;
end
if ~isempty(this.block.filtStim)
    gf_list = [gf_list, {this.block.filtStim(:).label}];
    if isempty(gf_val)
        gf_val = this.block.filtStim(1).val;
    end
end
if ~isempty(this.block.filtSpikes)
    gf_list = [gf_list, {this.block.filtSpikes(:).label}];
    if isempty(gf_val)
        gf_val = this.block.filtSpikes(1).val;
    end
end

if isempty(gf_list)
    set(findobj('Tag', 'lb_groupsFiltersLabel_raster'), ...
        'Enable', 'off', 'Max', 10, ...
        'String', {''}, ...
        'Value', []);
    set(findobj('Tag', 'lb_groupsFiltersVal_raster'), ...
        'Enable', 'off', 'Max', 10, ...
        'String', {''}, ...
        'Value', []);
else
    set(findobj('Tag', 'lb_groupsFiltersLabel_raster'), ...
        'Enable', 'on', 'Max', 1, ...
        'String', gf_list, ...
        'Value', 1);
    set(findobj('Tag', 'lb_groupsFiltersVal_raster'), ...
        'Enable', 'on', 'Max', 1, ...
        'String', gf_val, ...
        'Value', 1);
end

set(findobj('Tag', 'pm_sortBy_raster'), ...
    'String', {this.block.stim.label, 'Number'}, ...
    'Value', 1);

% Update the TRFLaser panel
val = this.block.stim(1).val;
ind = find(val == 65);
set(findobj('Tag', 'pm_sectionTRF_TRFlaser'), 'String', val, 'Value', ind);

