classdef AMS < Block
    
    properties (Transient)
        panels = {'SelectivityInd', 'TuningCurves'};
    end
    
    methods
        function stimData = getStimuliConditions(this, source)
            stimData{1} = source.freq.data;
            this.stim(1).label = 'Freq, kHz';
            
            stimData{2} = source.dura.data;
            this.stim(2).label = 'Sweep duration, ms';
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
        
        function sweepTime = calcSweepTime(this)
            % Sweep time in seconds directly from the second stimulus condition
            sweepTime = this.stimConditions(:, 2)/1000;
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
                
                sweepTime = repmat(abs(this.stimConditions(:, 2)/1000), 1, length(this.selRep));
                
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

