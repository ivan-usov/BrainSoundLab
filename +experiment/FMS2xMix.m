classdef FMS2xMix < Block
    
    properties (Transient)
        panels = {'SelectivityInd', 'TuningCurves'};
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
        
        
    end
end

