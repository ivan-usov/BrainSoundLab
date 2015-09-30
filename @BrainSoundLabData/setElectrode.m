function setElectrode(this, electrodeType)
% Update the electrode panel according to the provided electrode type

allElectrodeTypes = {this.labbook.customElectrode.type};
ind_similar = strncmp(electrodeType, allElectrodeTypes, 3);
if ~any(ind_similar)
    error('BrainSoundLabData:setElectrode', 'Unknown electrode type');
end

similarElectrodes = allElectrodeTypes(ind_similar);
relative_ind = find(strcmp(electrodeType, similarElectrodes));

set(findobj('Tag', 'pm_type_electrode'), ...
    'String', similarElectrodes, 'Value', relative_ind);

ind = strcmp(electrodeType, allElectrodeTypes);
set(findobj('Tag', 'tab_channels_electrode'), ...
    'Data', this.labbook.customElectrode(ind).sites);

% Modify the 'electrode.type' in the Labbook class
this.labbook.electrode.type = this.labbook.customElectrode(ind).type;

