function popPanel(hObject, panel)

ax = findobj('Type', 'axes', 'Parent', panel);
set(ax, 'Units', 'normalized');

new_fig = figure();
new_ax = copyobj(ax, new_fig);
set(new_ax, 'ActivePositionProperty', 'outerposition');
set(ax, 'Units', 'pixels');

% Clear all tags from the copied objects, so that they won't overlap with
% the BrainSoundLab panel elements
set(findobj('Parent', new_fig), 'Tag', '');

