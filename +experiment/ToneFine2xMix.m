classdef ToneFine2xMix < Block
    
    properties (Transient)
        panels = {'TRF_Laser', 'AllChTRF'};
    end
    
    methods
        function stimData = getStimuliConditions(this, source)
            stimData{1} = source.decB.data;
            this.stim(1).label = 'Level, dB';
            
            stimData{2} = source.freq.data/1000; % convert to kHz
            this.stim(2).label = 'Frequency, kHz';
        end
        
        function groupData = getGroupingConditions(this, source)
            groupData{1} = repmat([0; 1], [this.nTotal/2, 1]);
            this.group(1).label = 'Laser';
        end
        
        function [tMin, tMax] = calcTimeProcRange(this, group, chan)
            tMin = 0;
            tMax = 0.05;
        end
    end
    
    methods (Static)
        function customAnalysis(group, chan)
            process.calcTRF(group, chan);
            process.analyseTRF(group, chan);
        end
        
    end
end

