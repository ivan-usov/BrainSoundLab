function SelectivityInd()
BSL = guidata(gcf);
block = BSL.block;

stim_lev = block.stim(1);
stim_rate = block.stim(2);

% ----- dsi
ax = findobj('Tag', 'ax_dsi_n');
result = block.custom.DSIwspont{BSL.curGroup}{BSL.curChannel};
plot(stim_rate.val(stim_rate.len/2+1:end), result, 'Marker', '.', 'Parent', ax);
legend(ax, num2str(stim_lev.val));

% ----- dsi witout spont activity
ax = findobj('Tag', 'ax_dsi_r');
result = block.custom.DSIwospont{BSL.curGroup}{BSL.curChannel};
plot(stim_rate.val(stim_rate.len/2+1:end), result, 'Marker', '.', 'Parent', ax);

% ----- lsi
ax = findobj('Tag', 'ax_lsi_n');
result = block.custom.LSIwspont{BSL.curGroup}{BSL.curChannel};
plot(stim_rate.val, result, 'Marker', '.', 'Parent', ax);

% ----- lsi without spont activity
ax = findobj('Tag', 'ax_lsi_r');
result = block.custom.LSIwospont{BSL.curGroup}{BSL.curChannel};
plot(stim_rate.val, result, 'Marker', '.', 'Parent', ax);

% ----- rsi_n
ax = findobj('Tag', 'ax_rsi_n');
result = block.custom.RSInum{BSL.curGroup}{BSL.curChannel};
plot([-1, 1], result, 'Marker', '.', 'Parent', ax);
set(ax, 'XTick', [-1, 1], 'XTickLabel', {'Down', 'Up'});
legend(ax, num2str(stim_lev.val));

% ----- rsi_r
ax = findobj('Tag', 'ax_rsi_r');
result = block.custom.RSIrate{BSL.curGroup}{BSL.curChannel};
plot([-1, 1], result, 'Marker', '.', 'Parent', ax);
set(ax, 'XTick', [-1, 1], 'XTickLabel', {'Down', 'Up'});

% ----- Update information
cc = BSL.curChannel;
inf_data = {
    'DSI@75''', block.custom.DSIwspont{1,1}{1,cc}(13),block.custom.DSIwspont{1,1}{1,cc}(14),block.custom.DSIwspont{1,1}{1,cc}(15), ''; ...
    };

set(findobj('Tag', 'tab_information'), 'Data', inf_data, ...
    'ColumnName', {'Parameter', '40dB', '60dB','80dB', ''}, ...
    'ColumnFormat', {'char', 'bank', 'bank', 'bank','char'});


