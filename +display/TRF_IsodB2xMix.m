function TRF_IsodB2xMix()
BSL = guidata(gcf);
block = BSL.block;

ax_control = findobj('Tag', 'ax_control_isodB2xMix');
ax_laser = findobj('Tag', 'ax_laser_isodB2xMix');
ax_0dB = findobj('Tag', 'ax_0dB_isodB2xMix');


cla(ax_control);
cla(ax_laser);
cla(ax_0dB);


stim_fq = block.stim(1);

% ----- Contol graph
control_0 = block.custom.TRF{1}{BSL.curChannel};
laser_0 = block.custom.TRF{2}{BSL.curChannel};

semilogx(stim_fq.val, [control_0], 'Parent', ax_control);
semilogx(stim_fq.val, [laser_0], 'Parent', ax_laser);

semilogx(stim_fq.val, [control_0, laser_0], 'Parent', ax_0dB);
legend(ax_0dB, 'control', 'laser');

minXVal = stim_fq.val(1);
maxXVal = stim_fq.val(end);
n = 2;

set([ax_control, ax_laser, ax_0dB], ...
    'XLim', [minXVal, maxXVal], ...
    'XTick', [minXVal, maxXVal], ...
    'XTickLabel', {minXVal, round(maxXVal*10^n)/10^n});

