function SelectivityInd()
BSL = guidata(gcf);
block = BSL.block;

stim_lev = block.stim(1);
stim_rate = block.stim(2);

% ----- dsi_n
ax = findobj('Tag', 'ax_dsi_n');
result = block.custom.DSInum{BSL.curGroup}{BSL.curChannel};
plot(stim_rate.val(stim_rate.len/2+1:end), result, 'Marker', '.', 'Parent', ax);
legend(ax, num2str(stim_lev.val));

% ----- dsi_r
ax = findobj('Tag', 'ax_dsi_r');
result = block.custom.DSIrate{BSL.curGroup}{BSL.curChannel};
plot(stim_rate.val(stim_rate.len/2+1:end), result, 'Marker', '.', 'Parent', ax);

% ----- lsi_n
ax = findobj('Tag', 'ax_lsi_n');
result = block.custom.LSInum{BSL.curGroup}{BSL.curChannel};
plot(stim_rate.val, result, 'Marker', '.', 'Parent', ax);

% ----- lsi_r
ax = findobj('Tag', 'ax_lsi_r');
result = block.custom.LSIrate{BSL.curGroup}{BSL.curChannel};
plot(stim_rate.val, result, 'Marker', '.', 'Parent', ax);

% ----- rsi_n
ax = findobj('Tag', 'ax_rsi_n');
result = block.custom.RSInum{BSL.curGroup}{BSL.curChannel};
plot([-1, 1], result, 'Marker', '.', 'Parent', ax);
set(ax, 'XTick', [-1, 1], 'XTickLabel', {'Down', 'Up'});
legend(ax, num2str(stim_rate.val(stim_rate.len/2+1:end)));

% ----- rsi_r
ax = findobj('Tag', 'ax_rsi_r');
result = block.custom.RSIrate{BSL.curGroup}{BSL.curChannel};
plot([-1, 1], result, 'Marker', '.', 'Parent', ax);
set(ax, 'XTick', [-1, 1], 'XTickLabel', {'Down', 'Up'});

