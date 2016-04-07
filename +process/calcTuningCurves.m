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
    block.custom.SpontTRFrate = cell(1, block.nGroups);
    block.custom.stdSpontTRFrate = cell(1, block.nGroups);
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
        block.custom.SpontTRFrate{k} = cell(1, block.nChannels);
        block.custom.stdSpontTRFrate{k} = cell(1, block.nChannels);
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
    all_group_spontSpikes = block.spontSpikesTimeProc{k}; %added by TRB Dec 17 2015
    
    for l = chan
        % Sort conditions
        [~, ind] = sortrows(block.stimConditions, [stim_rate.ind stim_lev.ind]);
        
        sweepTime = block.calcSweepTime();
        all_spikes = all_group_spikes{l}(ind, :); %TODO: block.selRep
        all_spontSpikes = all_group_spontSpikes{l}(ind, :);
        sweepTime_ordered = sweepTime(ind, :); %added by TRB Dec 16

        
        % Calculate Sweep TRF number and rate
        
        trf_num = sum(cellfun(@length, all_spikes), 2)/length(block.selRep);
        trf_rate = trf_num ./ sweepTime_ordered;
        spontTRF_rate = sum(cellfun(@length, all_spontSpikes), 2)/length(block.selRep)/0.1;
            %0.1 is the duration of the window for the calculation of spont activity  
        stdSpontTRF_rate = std(cellfun(@length, all_spontSpikes),0,2)/0.1;
        
        trf_num = reshape(trf_num, [stim_lev.len stim_rate.len]); 
        trf_rate = reshape(trf_rate, [stim_lev.len stim_rate.len]);
        spontTRF_rate = reshape(spontTRF_rate, [stim_lev.len stim_rate.len]);
        stdSpontTRF_rate = reshape(stdSpontTRF_rate, [stim_lev.len stim_rate.len]);
        
        block.custom.TRFnum{k}{l} = trf_num;
        block.custom.TRFnum_max{k}(l) = max(max(trf_num));
        block.custom.TRFrate{k}{l} = trf_rate;
        block.custom.SpontTRFrate{k}{l} = spontTRF_rate;
        block.custom.stdSpontTRFrate{k}{l} = stdSpontTRF_rate;
        block.custom.TRFrate_max{k}(l) = max(max(trf_rate));
        
        % -----
        % TODO: remove after the nStdDev is clarified
        nStdDev = BSL.nStdDev_psth;
        % Spike spontaneous activity (from -0.15s to -0.05s)
        mSpont = block.spontRateMean{k}(l);
        sSpont = block.spontRateStd{k}(l);
        
        % Reorder spikes for the first stimulus (for FMS the first stimulus
        % is sound level)
        [~, ind] = sortrows(block.stimConditions, [stim_lev.ind stim_rate.ind]);
        all_spikes = all_group_spikes{l}(ind, :); % TODO: block.selRep
        
        % Calculate peak amplitude and latency for each first stim (ie sound level) value
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
        
        % Reorder spikes for the second stimulus (in the case of FMS the
        % second stimulus is the sweep rate)
        [~, ind] = sortrows(block.stimConditions, [stim_rate.ind stim_lev.ind]);
        all_spikes = all_group_spikes{l}(ind, :); % TODO: block.selRep
        
        % Calculate peak amplitude and latency for each second stim (ie sweeprate) value
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

