classdef IsodB2xMix < Block
    
    properties (Transient)
        panels = {'AllChTRF', 'TRF_IsodB2xMix'};
    end
    
    methods
        function stimData = getStimuliConditions(this, source)
            stimData{1} = source.freq.data/1000; % convert to kHz
            this.stim(1).label = 'Frequency, kHz';
        end
        
        function groupData = getGroupingConditions(this, source)
            groupData{1} = repmat([0; 1], [this.nTotal/2, 1]);
            this.group(1).label = 'Laser';
            
        end
    end
    
    methods (Static)
        function customAnalysis(group, chan)
            process.calcTRF(group, chan);
        end
    end
    
    methods % Redefined methods
        function [tMin, tMax] = calcTimeProcRange(this, group, chan)
            tMin = 0;
            tMax = 0.05;
        end
    end
end

