function PSTH()
BSL = guidata(gcf);
block = BSL.block;

ax_psth = findobj('Tag', 'ax_psth');

spikes = block.spikesTimeRaster{BSL.curGroup}{BSL.curChannel};
spikes = arrayfun(@(k) vertcat(spikes{k,:}), (1:block.nTrials)', ...
    'UniformOutput', false);

histogram(ax_psth, cell2mat(spikes), ...
    linspace(block.timeRasterMin, block.timeRasterMax, BSL.nBins_psth+1));
xlim(ax_psth, [block.timeRasterMin block.timeRasterMax]);

if BSL.fixLim_psth
    set(ax_psth, 'YLim', [0 BSL.fixedMaxVal_psth]);
else
    set(ax_psth, 'YLimMode', 'auto');
    lim = get(ax_psth, 'YLim');
    BSL.fixedMaxVal_psth = lim(2);
end

display.updateProcArea();

