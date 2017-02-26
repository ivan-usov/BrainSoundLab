classdef FMS2xMix < Block
    
    properties (Transient)
       panels = {'TuningCurves','TuningCurves_Laser'};
    end
    
    methods
        function stimData = getStimuliConditions(this, source)
            stimData{1} = source.decB.data;
            this.stim(1).label = 'Level, dB';
            
            stimData{2} = source.rate.data;
            this.stim(2).label = 'Rate, oct/s';
        end
        
        function groupData = getGroupingConditions(this, source)
            groupData{1} = repmat([0; 1], [this.nTotal/2, 1]);
            this.group(1).label = 'Laser';
        end
    end
    
    methods (Static)
        function customAnalysis(group, chan)
            process.calcTuningCurves(group, chan);
            process.calcSelectivityInd(group, chan);
        end
    end
    
    methods % Redefined methods
        function [tMin, tMax] = calcTimeProcRange(this, group, chan)
            tMin = NaN;
            tMax = NaN;
        end
        
        function spikes = getSpikeTimings(this, t_min, t_max, group, chan)
            if isnan(t_min) || isnan(t_max) % get spikes for the timeProcRange
                % Find all spikes in a time window according to the sweepTime
                
                spikeTimings = this.spikeTimings{chan};
                if ~isempty(this.filtSpikes)
                    for k = 1:length(this.filtSpikes)
                        filtParam = this.filtSpikes(k).val(this.filtSpikes(k).sel);
                        map = ismember(this.filtSpikes(k).map{chan}, filtParam);
                    end
                    spikeTimings = spikeTimings(map);
                end
                
                sweepTime = repmat(this.calcSweepTime(), 1, length(this.selRep));
                
                spikes = arrayfun(@spike_count, ...
                    this.stimTimings(:, this.selRep, group), sweepTime, ...
                    'UniformOutput', false);
                
            else % call the superclass method otherwise
                spikes = getSpikeTimings@Block(this, t_min, t_max, group, chan);
            end
            
            function spikes = spike_count(t0, sweepTime)
                ind1 = find(spikeTimings >= t0, 1, 'first');
                ind2 = find(spikeTimings <= t0 + sweepTime, 1, 'last');
                spikes = spikeTimings(ind1:ind2) - t0;
            end
        end
    end
end

