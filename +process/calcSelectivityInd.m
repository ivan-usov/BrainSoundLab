function calcSelectivityInd(group, chan)
BSL = guidata(gcf);
block = BSL.block;
if nargin == 0
    group = 1:block.nGroups;
    chan = 1:block.nChannels;
end

% Preallocate in case of the first time calculation
if ~isfield(block.custom, 'DSIn')
    block.custom.DSInum = cell(1, block.nGroups);
    block.custom.DSIrate = cell(1, block.nGroups);
    block.custom.LSInum = cell(1, block.nGroups);
    block.custom.LSIrate = cell(1, block.nGroups);
    block.custom.RSInum = cell(1, block.nGroups);
    block.custom.RSIrate = cell(1, block.nGroups);
    
    for k = 1:block.nGroups
        block.custom.DSInum{k} = cell(1, block.nChannels);
        block.custom.DSIrate{k} = cell(1, block.nChannels);
        block.custom.LSInum{k} = cell(1, block.nChannels);
        block.custom.LSIrate{k} = cell(1, block.nChannels);
        block.custom.RSInum{k} = cell(1, block.nChannels);
        block.custom.RSIrate{k} = cell(1, block.nChannels);
    end
end

stim_lev = block.stim(1);
stim_rate = block.stim(2);

for k = group
    for l = chan
        trf_num = block.custom.TRFnum{k}{l};
        trf_rate = block.custom.TRFrate{k}{l};
        
        % ----- dsi_n
        down = trf_num(:, stim_rate.len/2:-1:1);
        up = trf_num(:, stim_rate.len/2+1:end);
        
        block.custom.DSInum{k}{l} = (down-up)./(down+up);
        
        % ----- dsi_r
        down = trf_rate(:, stim_rate.len/2:-1:1);
        up = trf_rate(:, stim_rate.len/2+1:end);
        
        block.custom.DSIrate{k}{l} = (down-up)./(down+up);
        
        % ----- lsi_n
        trf_mean = mean(trf_num);
        trf_max = max(trf_num);
        
        block.custom.LSInum{k}{l} = (1-trf_mean./trf_max)*stim_lev.len/(stim_lev.len-1);
        
        % ----- lsi_r
        trf_mean = mean(trf_rate);
        trf_max = max(trf_rate);
        
        block.custom.LSIrate{k}{l} = (1-trf_mean./trf_max)*stim_lev.len/(stim_lev.len-1);
        
        % ----- rsi_n
        down = trf_num(:, stim_rate.len/2:-1:1);
        up = trf_num(:, stim_rate.len/2+1:end);
        
        meanVal = [mean(down, 2), mean(up, 2)];
        maxVal = [max(down, [], 2), max(up, [], 2)];
        
        block.custom.RSInum{k}{l} = (1-meanVal./maxVal)*(stim_rate.len/2)/((stim_rate.len)/2-1);
        
        % ----- rsi_r
        down = trf_rate(:, stim_rate.len/2:-1:1);
        up = trf_rate(:, stim_rate.len/2+1:end);
        
        meanVal = [mean(down); mean(up)];
        maxVal = [max(down); max(up)];
        
        block.custom.RSIrate{k}{l} = (1-meanVal./maxVal)*stim_lev.len/(stim_lev.len-1);
    end
end

