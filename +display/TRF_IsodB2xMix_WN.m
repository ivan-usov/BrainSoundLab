function TRF_IsodB2xMix_WN()
BSL = guidata(gcf);
block = BSL.block;

ax_control = findobj('Tag', 'ax_control_isodB2xMix_WN');
ax_laser = findobj('Tag', 'ax_laser_isodB2xMix_WN');
ax_0dB = findobj('Tag', 'ax_0dB_isodB2xMix_WN');
ax_40dB = findobj('Tag', 'ax_40dB_isodB2xMix_WN');
ax_60dB = findobj('Tag', 'ax_60dB_isodB2xMix_WN');

cla(ax_control);
cla(ax_laser);
cla(ax_0dB);
cla(ax_40dB);
cla(ax_60dB);

stim_fq = block.stim(1);

% ----- Contol graph
control_0 = block.custom.TRF{1}{BSL.curChannel};
control_40 = block.custom.TRF{3}{BSL.curChannel};
control_60 = block.custom.TRF{5}{BSL.curChannel};
laser_0 = block.custom.TRF{2}{BSL.curChannel};
laser_40 = block.custom.TRF{4}{BSL.curChannel};
laser_60 = block.custom.TRF{6}{BSL.curChannel};

semilogx(stim_fq.val, [control_0, control_40, control_60], 'Parent', ax_control);
semilogx(stim_fq.val, [laser_0, laser_40, laser_60], 'Parent', ax_laser);
legend(ax_laser, '0dB', '40dB', '60dB');

semilogx(stim_fq.val, [control_0, laser_0], 'Parent', ax_0dB);
semilogx(stim_fq.val, [control_40, laser_40], 'Parent', ax_40dB);
semilogx(stim_fq.val, [control_60, laser_60], 'Parent', ax_60dB);
legend(ax_60dB, 'control', 'laser');

minXVal = stim_fq.val(1);
maxXVal = stim_fq.val(end);
n = 2;
set([ax_control, ax_laser, ax_0dB, ax_40dB, ax_60dB], ...
    'XLim', [minXVal, maxXVal], ...
    'XTick', [minXVal, maxXVal], ...
    'XTickLabel', {minXVal, round(maxXVal*10^n)/10^n});

