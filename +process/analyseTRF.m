function analyseTRF(group, chan)
BSL = guidata(gcf);
block = BSL.block;
if nargin == 0
    group = 1:block.nGroups;
    chan = 1:block.nChannels;
end

% Preallocate in case of the first time calculation
if ~isfield(block.custom, 'TRF')
    block.custom.TRF_filt = cell(1, block.nGroups);
    block.custom.TRF_clean = cell(1, block.nGroups);
    block.custom.dPrime = cell(1, block.nGroups);
    block.custom.BF = cell(1, block.nGroups);
    block.custom.Threshold = cell(1, block.nGroups);
    block.custom.CF = cell(1, block.nGroups);
    block.custom.ThrCF = cell(1, block.nGroups);
    block.custom.BW10 = cell(1, block.nGroups);
    block.custom.BWat60 = cell(1, block.nGroups);
    
    for k = 1:block.nGroups
        block.custom.TRF_filt{k} = cell(1, block.nChannels);
        block.custom.TRF_clean{k} = cell(1, block.nChannels);
        block.custom.dPrime{k} = zeros(1, block.nChannels);
        block.custom.BF{k} = zeros(1, block.nChannels);
        block.custom.Threshold{k} = zeros(1, block.nChannels);
        block.custom.CF{k} = zeros(1, block.nChannels);
        block.custom.ThrCF{k} = zeros(1, block.nChannels);
        block.custom.BW10{k} = zeros(1, block.nChannels);
        block.custom.BWat60{k} = zeros(1, block.nChannels);
    end
end

stim_lev = block.stim(1);
stim_fq = block.stim(2);

medFiltX = sscanf(get(findobj('Tag', 'e_medFiltX_trf'), 'String'), '%f', 1);
medFiltY = sscanf(get(findobj('Tag', 'e_medFiltY_trf'), 'String'), '%f', 1);
iterations = sscanf(get(findobj('Tag', 'e_iterations_trf'), 'String'), '%f', 1);

for k = group
    for l = chan
        trf = block.custom.TRF{k}{l};
        % ----- TRF filtered
        trf_filt = trf;
        for m = 1:iterations
            trf_filt = medfilt2(trf_filt, [medFiltX medFiltY], 'symmetric');
        end
        block.custom.TRF_filt{k}{l} = trf_filt;
        
        % ----- TRF clean
        spontRateMean = block.spontRateMean{k}(l);
        spontRateStd = block.spontRateStd{k}(l);
        
        trf_clean = trf_filt - spontRateMean;
        if get(findobj('Tag', 'cb_cleanWithPeakAmpl_trf'), 'Value') == 0
            trf_clean(trf_clean < 3*spontRateStd) = 0;
        else
            peakAmp = block.peakAmp{k}(l);
            peakAmplPort = sscanf(get(findobj('Tag', 'e_peakAmplPort_trf'), ...
                'String'), '%f', 1);
            trf_clean(trf_clean < peakAmp*peakAmplPort) = 0;
        end
        block.custom.TRF_clean{k}{l} = trf_clean;
        
        if isnan(trf_clean)==1
            block.custom.dPrime{k}(l) = 0;
            block.custom.BF{k}(l) = NaN;
            block.custom.Thr{k}(l) = NaN;
            block.custom.BW10{k}(l) = NaN;
            block.custom.CF{k}(l) = NaN;
            block.custom.ThrCF{k}(l) = NaN;
            block.custom.BWat60{k}(l) = NaN;
        else
            
            % ----- dPrime
            trf_signal = trf(trf_clean ~= 0);
            trf_noise = trf(trf_clean == 0);
            %what Ivan computed
            block.custom.dPrime{k}(l) = (mean(trf_signal) - mean(trf_noise)) / sqrt((var(trf_signal) + var(trf_noise))/2);
            
%             % what WeImpale had - changed by TRB Dec 9 2015
%             trf_mask = trf_clean;
%             (trf_mask ~=0)== 1;
%             trfmaskupper = trf_mask;
%             trfmaskupper(1:round(size(trf_mask,1)/2),:) = 1;
%             trf_noise2 = trf(trfmaskupper < 1);
%             randTrialNum = 1000;
%             sampNum = 40;
%             noiseDistr = zeros(randTrialNum,1);
%             signalDistr = zeros(randTrialNum,1);
%             for i = 1:randTrialNum;
%                 if (length(trf_signal)*0.5 > sampNum)
%                     signalDistr(i) = mean(trf_signal(ceil(rand(sampNum,1)*(length(trf_signal)-1))+1));
%                     noiseDistr(i) = mean(trf_noise(ceil(rand(sampNum,1)*(length(trf_noise)-1))+1));
%                 else
%                     signalDistr(i) = mean([trf_signal(ceil(rand(round(length(trf_signal)*0.5),1)*(length(trf_signal)-1))+1);...
%                         trf_noise2(ceil(rand(sampNum-round(length(trf_signal)*0.5),1)*(length(trf_noise2)-1))+1)]);
%                     noiseDistr(i) = mean(trf_noise(ceil(rand(sampNum,1)*(length(trf_noise)-1))+1));
%                 end;
%             end;
%             block.custom.dPrime{k}(l) = (mean(signalDistr)-mean(noiseDistr))*2/(std(signalDistr)+std(noiseDistr));
            
            % ----- Best frequency
            [~, ind_bf] = max(sum(trf_clean, 1));
            block.custom.BF{k}(l) = stim_fq.val(ind_bf);
            
            % Step size in octaves
            octSize = log2(stim_fq.val(end)/stim_fq.val(1))/(stim_fq.len-1);
            
            %ind_thr = find(trf_clean(:, ind_bf) == 0, 1, 'last') + 1; %how it was done before December 8 - TRB
            ind_thr = find(trf_clean(:, ind_bf) > 0, 1, 'first');
            if ~isempty(ind_thr) && ind_thr < stim_lev.len
                % ----- Threshold
                Thr = stim_lev.val(ind_thr);
                block.custom.Thr{k}(l) = Thr;
                
                % ----- CF
                %             cf_min = find(trf_clean(ind_thr, 1:ind_bf-1) == 0, 1, 'last') + 1;
                %             if isempty(cf_min)
                %                 cf_min = 1;
                %             end
                %             cf_max = find(trf_clean(ind_thr, ind_bf+1:end) == 0, 1, 'first') + ind_bf - 1;
                %             if isempty(cf_max)
                %                 cf_max = stim_fq.len;
                %             end
                %             [~, ind_cf] = max(trf_clean(ind_thr, cf_min:cf_max));
                %             ind_cf = ind_cf + cf_min - 1;
                %             block.custom.CF{k}(l) = stim_fq.val(ind_cf);
                
                % ----- BW10
                ind10 = find(stim_lev.val == Thr+10);
                val10min = find(trf_clean(ind10, 1:ind_bf-1) == 0, 1, 'last') + 1;
                val10max = find(trf_clean(ind10, ind_bf+1:end) == 0, 1, 'first') + ind_bf - 1;
                if isempty(val10min) || isempty(val10max)
                    block.custom.BW10{k}(l) = NaN;
                else
                    block.custom.BW10{k}(l) = (val10max - val10min)*octSize;
                end
            else
                block.custom.Thr{k}(l) = NaN;
                block.custom.BW10{k}(l) = NaN;
                %      block.custom.CF{k}(l) = NaN;
            end
            
            % ----- CF
            ind_ThrCF = find(sum(trf_clean,2),1, 'first');
            if isempty(ind_ThrCF)
                block.custom.CF{k}(l) = NaN;
                block.custom.ThrCF{k}(l) = NaN;
            else
                block.custom.ThrCF{k}(l)=stim_lev.val(ind_ThrCF);
                ind_cf=min(find(trf_clean(ind_ThrCF,:)==max(trf_clean(ind_ThrCF,:)),2));
                block.custom.CF{k}(l) = stim_fq.val(ind_cf);
            end
            
            % ----- BWat60
            ind60 = find(stim_lev.val == 60);
            val60min = find(trf_clean(ind60, 1:ind_bf-1) == 0, 1, 'last') + 1;
            if isempty(val60min)
                val60min = 1;
            end
            val60max = find(trf_clean(ind60, ind_bf+1:end) == 0, 1, 'first') + ind_bf - 1;
            if isempty(val60min) || isempty(val60max)
                block.custom.BWat60{k}(l) = NaN;
            else
                block.custom.BWat60{k}(l) = (val60max - val60min)*octSize;
            end
        end
    end
end

