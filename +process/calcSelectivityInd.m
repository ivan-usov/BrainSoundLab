function calcSelectivityInd(group, chan)
BSL = guidata(gcf);
block = BSL.block;
if nargin == 0
    group = 1:block.nGroups;
    chan = 1:block.nChannels;
end

% Preallocate in case of the first time calculation
if ~isfield(block.custom, 'DSIn')
    block.custom.DSIwspont = cell(1, block.nGroups);
    block.custom.DSIwospont = cell(1, block.nGroups);
    block.custom.LSIwspont = cell(1, block.nGroups);
    block.custom.LSIwospont = cell(1, block.nGroups);
    block.custom.RSInum = cell(1, block.nGroups);
    block.custom.RSIrate = cell(1, block.nGroups);
    
    for k = 1:block.nGroups
        block.custom.DSIwspont{k} = cell(1, block.nChannels);
        block.custom.DSIwospont{k} = cell(1, block.nChannels);
        block.custom.LSIwspont{k} = cell(1, block.nChannels);
        block.custom.LSIwospnot{k} = cell(1, block.nChannels);
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
        Sponttrf_rate = block.custom.SpontTRFrate{k}{l};
        
        % ----- dsi
        down = trf_num(:, stim_rate.len/2:-1:1);
        up = trf_num(:, stim_rate.len/2+1:end);
        
        block.custom.DSIwspont{k}{l} = (up-down)./(down+up);
        
        % ----- dsi with spont activity subtracted from tone response activity 
 
        down = trf_rate(:, stim_rate.len/2:-1:1)- Sponttrf_rate(:, stim_rate.len/2:-1:1);
        up = trf_rate(:, stim_rate.len/2+1:end)-Sponttrf_rate(:, stim_rate.len/2+1:end);
        
        %put all negative values (ie when spont activity is bigger than tone activity) to 0
        down=max(down,0);
        up=max(up,0);
        
        block.custom.DSIwospont{k}{l} = (up-down)./(down+up);
        
        % ----- lsi
        trf_mean = mean(trf_num);
        trf_max = max(trf_num);
        
        block.custom.LSIwspont{k}{l} = (1-trf_mean./trf_max)*stim_lev.len/(stim_lev.len-1);
        
        % ----- lsi with spont activity subtracted from tone response activity 
        trf_mean = mean(trf_rate-Sponttrf_rate);
        trf_max = max(trf_rate-Sponttrf_rate);
        
        %put all negative values (ie when spont activity is bigger than tone activity) to 0
        trf_mean = max(trf_mean,0);
        trf_max = max(trf_max,0);
        
        block.custom.LSIwospont{k}{l} = (1-trf_mean./trf_max)*stim_lev.len/(stim_lev.len-1);
        
        % ----- rsi_n 
        down = trf_num(:, stim_rate.len/2:-1:1);
        up = trf_num(:, stim_rate.len/2+1:end);
        
        meanVal = [mean(down,2), mean(up,2)];
        maxVal = [max(down,[],2), max(up,[],2)];
        
        block.custom.RSInum{k}{l}=(1-meanVal./maxVal)*(stim_rate.len/2)/((stim_rate.len/2)-1);
        
        % ----- rsi_r
        down = trf_rate(:, stim_rate.len/2:-1:1);
        up = trf_rate(:, stim_rate.len/2+1:end);
        
        meanVal = [mean(down,2), mean(up,2)];
        maxVal = [max(down,[],2), max(up,[],2)];
        
        block.custom.RSIrate{k}{l}=(1-meanVal./maxVal)*(stim_rate.len/2)/((stim_rate.len/2)-1);
    end
end

