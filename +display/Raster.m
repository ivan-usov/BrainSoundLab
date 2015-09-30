function Raster()
BSL = guidata(gcf);
block = BSL.block;

% Handle of the axes in the raster panel
ax_raster = findobj('Tag', 'ax_raster');

if strcmp(BSL.stimPrime.label, 'Number') % Sorting by the trial number
    % Sort the stimulus conditions by the trial number
    [~, ind] = sort(block.stimTimings(:, :, BSL.curGroup));
    
    % Arrange spike timings
    spikes = cell(block.nTrials, block.nRep);
    for k = BSL.block.selRep
        spikes(:, k) = block.spikesTimeRaster{BSL.curGroup}{BSL.curChannel}(ind(:, k), k);
    end
    
    % Tick positions and tick labels
    tick_pos = {'YTickMode', 'auto'};
    tick_labels = {'YTickLabelMode', 'auto'};
    
else % Sorting by the prime stimulus
    % Sort conditions
    [~, ind] = sortrows(block.stimConditions, [BSL.stimPrime.ind BSL.stimSecond.ind]);
    
    % Arrange spike timings
    spikes = block.spikesTimeRaster{BSL.curGroup}{BSL.curChannel}(ind, :); %TODO: BSL.block.selRep
    
    % Tick positions and tick labels
    tick_pos = {'YTick', linspace(BSL.stimSecond.len/2, ...
        block.nTrials-BSL.stimSecond.len/2, BSL.stimPrime.len) + 0.5};
    tick_labels = num2cell(BSL.stimPrime.val);
    % clear floating point numbers in 'Frequency' stimulus
    if strcmp(BSL.stimPrime.label, 'Frequency, kHz')
        for k = 1:length(tick_labels)
            if abs(tick_labels{k} - fix(tick_labels{k})) > eps
                tick_labels{k} = [];
            end
        end
    end
    tick_labels = {'YTickLabel', tick_labels};
end

% Values for the scatter plot (raster)
t_rast = arrayfun(@(k) vertcat(spikes{k,:}), (1:block.nTrials)', ...
    'UniformOutput', false);
y_rast = arrayfun(@(k) k*ones(size(t_rast{k})), (1:block.nTrials)', ...
    'UniformOutput', false);

% Plot the graph in the raster panel
scatter(ax_raster, cell2mat(t_rast), cell2mat(y_rast), 'Marker', '.', ...
    'SizeData', 10, 'CData', [0 0 0]);
set(ax_raster, tick_pos{:}, tick_labels{:});
xlim(ax_raster, [block.timeRasterMin block.timeRasterMax]);
ylim(ax_raster, [0 block.nTrials] + 0.5);
ylabel(ax_raster, BSL.stimPrime.label);

% Gray horizontal patches
for i = 1:floor(BSL.stimPrime.len/2)
    patch([block.timeRasterMin block.timeRasterMax block.timeRasterMax block.timeRasterMin], ...
        [2*i-1, 2*i-1, 2*i, 2*i]*BSL.stimSecond.len + 0.5, ...
        'black', 'FaceAlpha', 0.07, ...
        'Parent', ax_raster,  'EdgeColor', 'none');
end

