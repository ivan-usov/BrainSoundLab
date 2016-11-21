classdef FMS < Block
    
    properties (Transient)
        panels = {'SelectivityInd', 'TuningCurves'};
    end
    
    methods
        function stimData = getStimuliConditions(this, source)
            stimData{1} = source.decB.data;
            this.stim(1).label = 'Level, dB';
            
            stimData{2} = source.rate.data;
            this.stim(2).label = 'Sweep rate, oct/s';
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
        
        function sweepTime = calcSweepTime(this)% Recalculate the sweepTime so that we can make the window longer if wanted - last line of this function
            % Border frequencies
            fq_min = 2000;
            fq_max = 48000;
            
            sweepOct = abs(log2(fq_max/fq_min));
            sweepTime = abs(sweepOct ./ this.stimConditions(:, 2))/1000; % seconds
            sweepTime = sweepTime+ 0.00; % FMS increased window analysis
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

