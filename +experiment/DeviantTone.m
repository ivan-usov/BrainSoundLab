classdef DeviantTone < Block
    
    properties (Transient)
        panels = {};
    end
    
    methods
        function stimData = getStimuliConditions(this, source)
            stimData{1} = source.decB.data;
            this.stim(1).label = 'Level, dB';
        end
        
        function filtStimCond = getStimuliFilteringConditions(this, source)
            filtStimCond{1} = source.freq.data/1000; % convert to kHz
            this.filtStim(1).label = 'Frequency, kHz';
            
            % Force the number of repetitions to 1
            this.nTrials = length(filtStimCond{1});
        end
    end
    
    methods (Static)
        function customAnalysis(group, chan)
        end
    end
end

