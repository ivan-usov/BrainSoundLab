function calcTRF(group, chan)
BSL = guidata(gcf);
block = BSL.block;
if nargin == 0
    group = 1:block.nGroups;
    chan = 1:block.nChannels;
end

% Preallocate in case of the first time calculation
if ~isfield(block.custom, 'TRF')
    block.custom.TRF = cell(1, block.nGroups);
    block.custom.TRF_max = cell(1, block.nGroups);
    for k = 1:block.nGroups
    	block.custom.TRF{k} = cell(1, block.nChannels);
        block.custom.TRF_max{k} = zeros(1, block.nChannels);
    end
end

stim_lev = block.stim(1);
stim_fq = block.stim(2);

for k = group
    all_group_spikes = block.spikesTimeProc{k};
    
    for l = chan
        % Sort conditions
        [~, ind] = sortrows(block.stimConditions, [stim_fq.ind stim_lev.ind]);
        
        % Arrange spike timings
        spikes = all_group_spikes{l}(ind, :); % TODO: block.selRep
        
        t_min = block.timeProcMin{k}(l);
        t_max = block.timeProcMax{k}(l);
                       
        tf=strcmp(block.stim(1).label, 'Thi_, ms');

        if tf==1
        
        trf = reshape(sum(cellfun(@length, spikes), 2) ...
            /length(block.selRep), [stim_lev.len stim_fq.len]);
        else
         trf = reshape(sum(cellfun(@length, spikes), 2) ...
            /length(block.selRep)/(t_max-t_min), [stim_lev.len stim_fq.len]);    
            
        end   
        
        block.custom.TRF{k}{l} = trf;
        block.custom.TRF_max{k}(l) = max(max(trf));
    end
end

