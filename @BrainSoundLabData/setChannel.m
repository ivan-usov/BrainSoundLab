function setChannel(this)

block = this.block;

% Update timeRasterMin and timeRasterMax values (in s)
set(findobj('Tag', 'e_timeRasterMin_raster'), ...
    'String', block.timeRasterMin);
set(findobj('Tag', 'e_timeRasterMax_raster'), ...
    'String', block.timeRasterMax);

% Update timeProcMin and timeProcMax values (in ms)
set(findobj('Tag', 'e_timeProcMin_raster'), ...
    'String', block.timeProcMin{this.curGroup}(this.curChannel)*1000);
set(findobj('Tag', 'e_timeProcMax_raster'), ...
    'String', block.timeProcMax{this.curGroup}(this.curChannel)*1000);

if block.autoProcTime{this.curGroup}(this.curChannel)
    set(findobj('Tag', 'pb_autoRange_raster'), 'Enable', 'off');
else
    set(findobj('Tag', 'pb_autoRange_raster'), 'Enable', 'on');
end

block.displayData();

