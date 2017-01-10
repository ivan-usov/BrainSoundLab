function TRF_Laser()
BSL = guidata(gcf);
block = BSL.block;

ax1 = findobj('Tag', 'ax_trf1_TRFlaser');
ax1_clean = findobj('Tag', 'ax_clean1_TRFlaser');
ax2 = findobj('Tag', 'ax_trf2_TRFlaser');
ax2_clean = findobj('Tag', 'ax_clean2_TRFlaser');
ax_compare = findobj('Tag', 'ax_compare_TRFlaser');

cla(ax1);
cla(ax2);
cla(ax1_clean);
cla(ax2_clean);
cla(ax_compare);

% ----- Normal TRF and Clean TRF
plotTRF(block, 1, BSL.curChannel, ax1, ax1_clean);
plotTRF(block, 2, BSL.curChannel, ax2, ax2_clean);

localColorScale = findobj('Tag', 'cb_localColorScale_TRFlaser');
if get(localColorScale, 'Value') == get(localColorScale, 'Max')
    maxVals = [block.custom.TRF_max{1}(BSL.curChannel), block.custom.TRF_max{2}(BSL.curChannel)];
    set([ax1, ax2, ax1_clean, ax2_clean], ...
        'CLim', [0 max(maxVals)+eps]);
else
    set([ax1, ax2, ax1_clean, ax2_clean], ...
        'CLim', [0 max(block.custom.TRF_max{BSL.curGroup})+eps]);
end

% Arrange a colorbar
colorbar(ax1, 'off');
c1 = colorbar(ax1, 'northoutside');
c1.Label.String = 'Spike rate, spikes/s';
cpos = c1.Position;
cpos(1) = 0.58;
cpos(2) = 0.85;
c1.Position = cpos;

% ----- BWatXX comparison
stim2 = block.stim(2);
idx = get(findobj('Tag', 'pm_sectionTRF_TRFlaser'), 'Value');
line([0.5, stim2.len+0.5], [idx idx], 'LineWidth', 1, ...
    'LineStyle', '--', 'Color', 'green', 'Parent', ax1_clean);
line([0.5, stim2.len+0.5], [idx idx], 'LineWidth', 1, ...
    'LineStyle', '--', 'Color', 'green', 'Parent', ax2_clean);

% 14 - 65dB, laser on - red, laser off - blue
trf_clean1 = block.custom.TRF_clean{1}{BSL.curChannel};
trf_clean2 = block.custom.TRF_clean{2}{BSL.curChannel};
l_off = trf_clean1(idx, :);
l_on = trf_clean2(idx, :);
semilogx(stim2.val, l_off, stim2.val, l_on, 'Parent', ax_compare);
legend(ax_compare, 'Control', 'Laser');

minXVal = stim2.val(1);
maxXVal = stim2.val(end);
n = 2;
set(ax_compare, 'XLim', [minXVal, maxXVal], 'XTick', [minXVal, maxXVal], ...
    'XTickLabel', {minXVal, round(maxXVal*10^n)/10^n});

% ----- Update information
cc = BSL.curChannel;
inf_data = {
    'd''', block.custom.dPrime{1}(cc), block.custom.dPrime{2}(cc), [ ]; ...
    'BF', block.custom.BF{1}(cc), block.custom.BF{2}(cc), 'kHz'; ...
    'Threshold', block.custom.Thr{1}(cc), block.custom.Thr{2}(cc), 'dB'; ...
    'CF', block.custom.CF{1}(cc), block.custom.CF{2}(cc), 'kHz'; ...
    'BW10' block.custom.BW10{1}(cc), block.custom.BW10{2}(cc) 'oct'; ...
    'PeakAmp' block.peakAmp{1}(cc), block.peakAmp{2}(cc), 'spikes/s'; ...
    'PeakLatency' block.peakPos{1}(cc)*1000, block.peakPos{2}(cc)*1000, 'ms'; ...
    'SpontActRateMean' block.spontRateMean{1}(cc), block.spontRateMean{2}(cc), 'spikes/s'; ...
    'SpontActRateStd' block.spontRateStd{1}(cc), block.spontRateStd{2}(cc), 'spikes/s'; ...
    'PostStimActRateMean' block.postStimRateMean{1}(cc), block.postStimRateMean{2}(cc), 'spikes/s'; ...
    'PostStimActRateStd' block.postStimRateStd{1}(cc), block.postStimRateStd{2}(cc), 'spikes/s'; ...
    };

set(findobj('Tag', 'tab_information'), 'Data', inf_data, ...
    'ColumnName', {'Parameter', 'Off', 'On', ''}, ...
    'ColumnFormat', {'char', 'bank', 'bank', 'char'});

function plotTRF(block, group, chan, ax, ax_clean)
stim1 = block.stim(1);
stim2 = block.stim(2);

% ----- Normal TRF
trf = block.custom.TRF{group}{chan};
image(trf, 'Parent', ax, 'CDataMapping', 'scaled');
xlabel(ax, stim2.label);
ylabel(ax, stim1.label);

% ----- Clean TRF
trf_clean = block.custom.TRF_clean{group}{chan};
image(trf_clean, 'Parent', ax_clean, 'CDataMapping', 'scaled');
xlabel(ax_clean, stim2.label);
ylabel(ax_clean, stim1.label);

% Draw utility lines on the clean TRF
BF = block.custom.BF{group}(chan);
Thr = block.custom.Thr{group}(chan);
if ~isnan(Thr)
    ind_bf = find(stim2.val == BF);
    ind_thr = find(stim1.val == Thr);
    line([ind_bf ind_bf], [ind_thr, stim1.len+0.5], 'LineWidth', 2, ...
        'Color', 'red', 'Parent', ax_clean);

    CF = block.custom.CF{group}(chan);
    ind_cf = find(stim2.val == CF);
    line(ind_cf, ind_thr, 'LineStyle', 'none', 'Marker', 'o', ...
        'Color', 'red', 'Parent', ax_clean);
    
    ind_Thr10 = find(stim1.val == Thr+10);
    val10min = find(trf_clean(ind_Thr10, 1:ind_bf-1) == 0, 1, 'last') + 1;
    val10max = find(trf_clean(ind_Thr10, ind_bf+1:end) == 0, 1, 'first') + ind_bf - 1;
    if ~isempty(val10min) && ~isempty(val10max)
        line([val10min, val10max], [ind_Thr10 ind_Thr10], 'LineWidth', 1, ...
            'Color', 'green', 'Parent', ax_clean);
    end
end

% ----- Properties of all graphs
axis([ax, ax_clean], 'tight');

% Arrange axis tick labels
n_digits = 2;
if stim1.len > 1
    tickLabel_min = round(stim1.val(1)*10^n_digits)/10^n_digits;
    tickLabel_max = round(stim1.val(end)*10^n_digits)/10^n_digits;
    set([ax, ax_clean], 'YTick', [1, stim1.len], ...
        'YTickLabel', {tickLabel_min, tickLabel_max});
else % stim1.len == 1
    set([ax, ax_filt, ax_clean], 'YTick', []);
end
if stim2.len > 1
    tickLabel_min = round(stim2.val(1)*10^n_digits)/10^n_digits;
    tickLabel_max = round(stim2.val(end)*10^n_digits)/10^n_digits;
    set([ax, ax_clean], 'XTick', [1, stim2.len], ...
        'XTickLabel', {tickLabel_min, tickLabel_max});
else % stim2.len == 1
    set([ax, ax_filt, ax_clean], 'XTick', []);
end

