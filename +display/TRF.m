function TRF()
BSL = guidata(gcf);
block = BSL.block;

ax = findobj('Tag', 'ax_trf');
ax_filt = findobj('Tag', 'ax_trf_filt');
ax_clean = findobj('Tag', 'ax_trf_clean');

cla(ax);
cla(ax_filt);
cla(ax_clean);

stim1 = block.stim(1);
stim2 = block.stim(2);

% ----- Normal TRF
trf = block.custom.TRF{BSL.curGroup}{BSL.curChannel};
image(trf, 'Parent', ax, 'CDataMapping', 'scaled');
xlabel(ax, stim2.label);
ylabel(ax, stim1.label);

% ----- Filtered TRF
trf_filt = block.custom.TRF_filt{BSL.curGroup}{BSL.curChannel};
image(trf_filt, 'Parent', ax_filt, 'CDataMapping', 'scaled');
xlabel(ax_filt, stim2.label);
ylabel(ax_filt, stim1.label);

% ----- Clean TRF
trf_clean = block.custom.TRF_clean{BSL.curGroup}{BSL.curChannel};
image(trf_clean, 'Parent', ax_clean, 'CDataMapping', 'scaled');
xlabel(ax_clean, stim2.label);
ylabel(ax_clean, stim1.label);

% Draw utility lines on the clean TRF
BF = block.custom.BF{BSL.curGroup}(BSL.curChannel);
Thr = block.custom.Thr{BSL.curGroup}(BSL.curChannel);
if ~isnan(Thr)
    ind_bf = find(stim2.val == BF);
    ind_thr = find(stim1.val == Thr);
    line([ind_bf ind_bf], [ind_thr, stim1.len+0.5], 'LineWidth', 2, ...
        'Color', 'red', 'Parent', ax_clean);
    
    CF = block.custom.CF{BSL.curGroup}(BSL.curChannel);
    ThrCF = block.custom.ThrCF{BSL.curGroup}(BSL.curChannel);
    ind_cf = find(stim2.val == CF);
    ind_ThrCF = find(stim1.val == ThrCF);
    line(ind_cf, ind_ThrCF, 'LineStyle', 'none', 'Marker', 'o', ...
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
axis([ax, ax_filt, ax_clean], 'tight');

% Arrange axis tick labels
n_digits = 2;
if stim1.len > 1
    tickLabel_min = round(stim1.val(1)*10^n_digits)/10^n_digits;
    tickLabel_max = round(stim1.val(end)*10^n_digits)/10^n_digits;
    set([ax, ax_filt, ax_clean], 'YTick', [1, stim1.len], ...
        'YTickLabel', {tickLabel_min, tickLabel_max});
else % stim1.len == 1
    set([ax, ax_filt, ax_clean], 'YTick', []);
end
if stim2.len > 1
    tickLabel_min = round(stim2.val(1)*10^n_digits)/10^n_digits;
    tickLabel_max = round(stim2.val(end)*10^n_digits)/10^n_digits;
    set([ax, ax_filt, ax_clean], 'XTick', [1, stim2.len], ...
        'XTickLabel', {tickLabel_min, tickLabel_max});
else % stim2.len == 1
    set([ax, ax_filt, ax_clean], 'XTick', []);
end

localColorScale = findobj('Tag', 'cb_localColorScale_trf');
if get(localColorScale, 'Value') == get(localColorScale, 'Max')
    set([ax, ax_filt, ax_clean], ...
        'CLim', [0 block.custom.TRF_max{BSL.curGroup}(BSL.curChannel)+eps]);
else
    set([ax, ax_filt, ax_clean], ...
        'CLim', [0 max(block.custom.TRF_max{BSL.curGroup})+eps]);
end

% Arrange a colorbar
colorbar(ax, 'off');
c = colorbar(ax, 'northoutside');
c.Label.String = 'Spike rate, spikes/s';
cpos = c.Position;
cpos(2) = 0.8;
c.Position = cpos;

% ----- Update information
cg = BSL.curGroup;
cc = BSL.curChannel;
inf_data = {
    'd''', block.custom.dPrime{cg}(cc), [ ]; ...
    'BF', block.custom.BF{cg}(cc), 'kHz'; ...
    'Threshold', block.custom.Thr{cg}(cc), 'dB'; ...
    'CF', block.custom.CF{cg}(cc), 'kHz'; ...
    'ThrCF', block.custom.ThrCF{cg}(cc), 'dB'; ...
    'BW10' block.custom.BW10{cg}(cc), 'oct'; ...
    'BW@60' block.custom.BWat60{cg}(cc), 'oct'; ...
    'PeakAmp' block.peakAmp{cg}(cc), 'spikes/s'; ...
    'PeakLatency' block.peakPos{cg}(cc)*1000, 'ms'; ...
    'SpontActRateMean' block.spontRateMean{cg}(cc), 'spikes/s'; ...
    'SpontActRateStd' block.spontRateStd{cg}(cc), 'spikes/s'; ...
    'PostStimActRateMean' block.postStimRateMean{cg}(cc), 'spikes/s'; ...
    'PostStimActRateStd' block.postStimRateStd{cg}(cc), 'spikes/s'; ...
    };

set(findobj('Tag', 'tab_information'), 'Data', inf_data, ...
    'ColumnName', {'Parameter', 'Value', '', ''}, ...
    'ColumnFormat', {'char', 'bank', 'char', 'char'});

