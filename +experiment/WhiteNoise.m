classdef WhiteNoise < Block
    
    properties (Transient)
        panels = {'AllChTRF', 'TRF'};
    end
    
    methods
        function stimData = getStimuliConditions(this, source)
            stimData{1} = source.decB.data;
            this.stim(1).label = 'Level, dB';
            
            stimData{2} = ones([this.nTotal, 1]);
            this.stim(2).label = 'White Noise';
        end
    end
    
    methods (Static)
        function customAnalysis(group, chan)
            process.calcTRF(group, chan);
            process.analyseTRF(group, chan);
        end
    end
end

