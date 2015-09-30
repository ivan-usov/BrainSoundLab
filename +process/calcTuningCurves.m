function calcTuningCurves(group, chan)
BSL = guidata(gcf);
block = BSL.block;
if nargin == 0
    group = 1:block.nGroups;
    chan = 1:block.nChannels;
end

% Preallocate in case of the first time calculation
if ~isfield(block.custom, 'TRFnum')
    block.custom.TRFnum = cell(1, block.nGroups);
    block.custom.TRFnum_max = cell(1, block.nGroups);
    block.custom.TRFrate = cell(1, block.nGroups);
    block.custom.TRFrate_max = cell(1, block.nGroups);
    
    block.custom.peakLat_stim1 = cell(1, block.nGroups);
    block.custom.peakAmp_stim1 = cell(1, block.nGroups);
    block.custom.onsetLat_stim1 = cell(1, block.nGroups);
    block.custom.peakLat_stim2 = cell(1, block.nGroups);
    block.custom.peakAmp_stim2 = cell(1, block.nGroups);
    block.custom.onsetLat_stim2 = cell(1, block.nGroups);
    
    for k = 1:block.nGroups
        block.custom.TRFnum{k} = cell(1, block.nChannels);
        block.custom.TRFnum_max{k} = zeros(1, block.nChannels);
        block.custom.TRFrate{k} = cell(1, block.nChannels);
        block.custom.TRFrate_max{k} = zeros(1, block.nChannels);
        
        block.custom.peakLat_stim1{k} = cell(1, block.nChannels);
        block.custom.peakAmp_stim1{k} = cell(1, block.nChannels);
        block.custom.onsetLat_stim1{k} = cell(1, block.nChannels);
        block.custom.peakLat_stim2{k} = cell(1, block.nChannels);
        block.custom.peakAmp_stim2{k} = cell(1, block.nChannels);
        block.custom.onsetLat_stim2{k} = cell(1, block.nChannels);
    end
end

stim_lev = block.stim(1);
stim_rate = block.stim(2);

for k = group
    all_group_spikes = block.spikesTimeProc{k};
    
    for l = chan
        % Sort conditions
        [~, ind] = sortrows(block.stimConditions, [stim_rate.ind stim_lev.ind]);
        
        % Calculate TRF number and rate
        all_spikes = all_group_spikes{l}(ind, :); %TODO: block.selRep
        
        trf_num = sum(cellfun(@length, all_spikes), 2)/length(block.selRep);
        
        sweepTime = block.calcSweepTime();
        trf_rate = trf_num ./ sweepTime;
        
        trf_num = reshape(trf_num, [stim_lev.len stim_rate.len]);
        trf_rate = reshape(trf_rate, [stim_lev.len stim_rate.len]);
        
        block.custom.TRFnum{k}{l} = trf_num;
        block.custom.TRFnum_max{k}(l) = max(max(trf_num));
        block.custom.TRFrate{k}{l} = trf_rate;
        block.custom.TRFrate_max{k}(l) = max(max(trf_rate));
        
        % -----
        % TODO: remove after the nStdDev is clarified
        nStdDev = BSL.nStdDev_psth;
        % Spike spontaneous activity (from -0.15s to -0.05s)
        mSpont = block.spontRateMean{k}(l);
        sSpont = block.spontRateStd{k}(l);
        
        % Reorder spikes for the first stimulus
        [~, ind] = sortrows(block.stimConditions, [stim_lev.ind stim_rate.ind]);
        all_spikes = all_group_spikes{l}(ind, :); % TODO: block.selRep
        
        % Calculate peak amplitude and latency for each stimPrime value
        peakLat_stim1 = zeros(1, stim_lev.len);
        peakAmp_stim1 = zeros(1, stim_lev.len);
        onsetLat_stim1 = zeros(1, stim_lev.len);
        for m = 1:stim_lev.len
            spikes = all_spikes(1+(m-1)*stim_rate.len:m*stim_rate.len, :);
            n_all = histcounts(cell2mat(spikes(:)), linspace(0, 0.3, 301));
            n_all = n_all/numel(spikes)/0.001;
            
            % Make the spike time distribution smooth (reason for using hann(9)?)
            kernel = hann(9);
            kernel = kernel/sum(kernel);
            sn_all = filtfilt(kernel, 1, n_all);
            
            [peakAmp_stim1(m), peakLat_stim1(m)] = max(sn_all);
            peakLat_stim1(m) = peakLat_stim1(m)/1000;
            
            ind = find(sn_all >= mSpont + nStdDev*sSpont, 1, 'first')-1;
            if isempty(ind)
                onsetLat_stim1(m) = NaN;
            else
                onsetLat_stim1(m) = ind/1000;
            end
        end
        
        block.custom.peakLat_stim1{k}{l} = peakLat_stim1;
        block.custom.peakAmp_stim1{k}{l} = peakAmp_stim1;
        block.custom.onsetLat_stim1{k}{l} = onsetLat_stim1;
        
        % Reorder spikes for the second stimulus
        [~, ind] = sortrows(block.stimConditions, [stim_rate.ind stim_lev.ind]);
        all_spikes = all_group_spikes{l}(ind, :); % TODO: block.selRep
        
        peakLat_stim2 = zeros(1, stim_rate.len);
        peakAmp_stim2 = zeros(1, stim_rate.len);
        onsetLat_stim2 = zeros(1, stim_lev.len);
        for m = 1:stim_rate.len
            spikes = all_spikes(1+(m-1)*stim_lev.len:m*stim_lev.len, :);
            n_all = histcounts(cell2mat(spikes(:)), linspace(0, 0.3, 301));
            n_all = n_all/numel(spikes)/0.001;
            
            % Make the spike time distribution smooth (reason for using hann(9)?)
            kernel = hann(9);
            kernel = kernel/sum(kernel);
            sn_all = filtfilt(kernel, 1, n_all);
            
            [peakAmp_stim2(m), peakLat_stim2(m)] = max(sn_all);
            peakLat_stim2(m) = peakLat_stim2(m)/1000;
            
            ind = find(sn_all >= mSpont + nStdDev*sSpont, 1, 'first')-1;
            if isempty(ind)
                onsetLat_stim2(m) = NaN;
            else
                onsetLat_stim2(m) = ind/1000;
            end
        end
        
        block.custom.peakLat_stim2{k}{l} = peakLat_stim2;
        block.custom.peakAmp_stim2{k}{l} = peakAmp_stim2;
        block.custom.onsetLat_stim2{k}{l} = onsetLat_stim2;
    end
end

