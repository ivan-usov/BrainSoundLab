function DT_sequence()
BSL = guidata(gcf);
block = BSL.block;

ax = findobj('Tag', 'ax_dt_sequence');
cla(ax);

spikes_std_mean = block.custom.DT_standard_mean{BSL.curChannel};
spikes_std_sigma = block.custom.DT_standard_sigma{BSL.curChannel};
spikes_dev_mean = block.custom.DT_deviant_mean{BSL.curChannel};
spikes_dev_sigma = block.custom.DT_deviant_sigma{BSL.curChannel};

x = 0:length(spikes_std_mean)-1;

hold(ax, 'on');
errorbar(ax, x, spikes_std_mean, spikes_std_sigma, '.-', 'MarkerSize', 10);
errorbar(ax, x, spikes_dev_mean, spikes_dev_sigma, '.-', 'MarkerSize', 10);

legend(ax, 'Standard', 'Deviant');
set(ax, 'XLim', [-1, length(spikes_std_mean)]);

