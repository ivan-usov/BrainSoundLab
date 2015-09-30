function updateProcArea()
BSL = guidata(gcf);
block = BSL.block;

if isnan(block.timeProcMin{BSL.curGroup}(BSL.curChannel)) || ...
        isnan(block.timeProcMax{BSL.curGroup}(BSL.curChannel))
    return
end

ax_raster = findobj('Tag', 'ax_raster');
ax_psth = findobj('Tag', 'ax_psth');

if ~isempty(BSL.p1)
    delete([BSL.p1, BSL.p2]);
end

y_min = 0.5;
y_max = block.nTrials + 0.5;
t_min = block.timeProcMin{BSL.curGroup}(BSL.curChannel);
t_max = block.timeProcMax{BSL.curGroup}(BSL.curChannel);

% Red patch for the processing area
BSL.p1 = patch('Parent', ax_raster, ...
    'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.1, ...
    'XData', [t_min t_max t_max t_min], ...
    'YData', [y_min y_min y_max y_max]);

% Red patch on the PSTH plot
BSL.p2 = patch('Parent', ax_psth, ...
    'FaceColor', 'red', 'EdgeColor', 'none', 'FaceAlpha', 0.1, ...
    'XData', [t_min t_max t_max t_min], ...
    'YData', [0 0 BSL.fixedMaxVal_psth BSL.fixedMaxVal_psth]);

