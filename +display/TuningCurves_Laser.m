function TuningCurves_Laser()
BSL = guidata(gcf);
block = BSL.block;

stim_lev = block.stim(1);
stim_rate = block.stim(2);

% ----- Spike number as a fct of sweep rate at 40dB
ax = findobj('Tag', 'ax_spikenb40_TuningCurvesLaser');
resultoff = block.custom.TRFnum{1,1}{BSL.curChannel}(1,:);
resulton = block.custom.TRFnum{1,2}{BSL.curChannel}(1,:);
plot(stim_rate.val, resultoff, stim_rate.val, resulton,'Marker', '.', 'Parent', ax);
legend(ax, 'off','on');

% ----- Spike rate as a fct of sweep rate at 40dB
ax = findobj('Tag', 'ax_spikert40_TuningCurvesLaser');
resultoff = block.custom.TRFrate{1,1}{BSL.curChannel}(1,:);
resulton = block.custom.TRFrate{1,2}{BSL.curChannel}(1,:);
plot(stim_rate.val, resultoff, stim_rate.val, resulton,'Marker', '.', 'Parent', ax);
%legend(ax, 'off','on');

% ----- Spike number as a fct of sweep rate at 60dB
ax = findobj('Tag', 'ax_spikenb60_TuningCurvesLaser');
resultoff = block.custom.TRFnum{1,1}{BSL.curChannel}(2,:);
resulton = block.custom.TRFnum{1,2}{BSL.curChannel}(2,:);
plot(stim_rate.val, resultoff, stim_rate.val, resulton,'Marker', '.', 'Parent', ax);
%legend(ax, 'off','on');

% ----- Spike rate as a fct of sweep rate at 60dB
ax = findobj('Tag', 'ax_spikert60_TuningCurvesLaser');
resultoff = block.custom.TRFrate{1,1}{BSL.curChannel}(2,:);
resulton = block.custom.TRFrate{1,2}{BSL.curChannel}(2,:);
plot(stim_rate.val, resultoff, stim_rate.val, resulton,'Marker', '.', 'Parent', ax);
%legend(ax, 'off','on');

% ----- Spike number as a fct of sweep rate at 80dB
ax = findobj('Tag', 'ax_spikenb80_TuningCurvesLaser');
resultoff = block.custom.TRFnum{1,1}{BSL.curChannel}(3,:);
resulton = block.custom.TRFnum{1,2}{BSL.curChannel}(3,:);
plot(stim_rate.val, resultoff, stim_rate.val, resulton,'Marker', '.', 'Parent', ax);
%legend(ax, 'off','on');

% ----- Spike rate as a fct of sweep rate at 80dB
ax = findobj('Tag', 'ax_spikert80_TuningCurvesLaser');
resultoff = block.custom.TRFrate{1,1}{BSL.curChannel}(3,:);
resulton = block.custom.TRFrate{1,2}{BSL.curChannel}(3,:);
plot(stim_rate.val, resultoff, stim_rate.val, resulton,'Marker', '.', 'Parent', ax);
legend(ax, 'off','on');

% ----- Update information
cc = BSL.curChannel;
inf_data = {
    'DSI@75''', block.custom.DSIwspont{1,1}{1,cc}(13),block.custom.DSIwspont{1,2}{1,cc}(13),...
    block.custom.DSIwspont{1,1}{1,cc}(14),block.custom.DSIwspont{1,2}{1,cc}(14),...
    block.custom.DSIwspont{1,1}{1,cc}(15),block.custom.DSIwspont{1,2}{1,cc}(15), ''; ...
    };

set(findobj('Tag', 'tab_information'), 'Data', inf_data, ...
    'ColumnName', {'Parameter', '40dB off','40dB on' '60dB off','60dB on','80dB off', '80dB on', ''}, ...
    'ColumnFormat', {'char', 'bank', 'bank', 'bank','bank', 'bank', 'bank','char'});


