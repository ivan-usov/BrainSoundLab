classdef Labbook < handle
    
    properties % Basic labbook information
        name = char.empty;
        path = char.empty;
        date                % yy/mm/dd
        expID
        experimenter
        experimentComments
    end
    
    properties
        mouse               % Basic mouse data
        exposure            % Pre-experiment exposure
        headFix             % Head-fixation conditioning
        behaviour           % Behavioural testing
        anesthesia          % Anesthesia
        craniotomy          % Craniotomy
        electrode           % Electrophy
    end
    
    properties % Blocks
        penetrationNum
        region
        tipDepth
        blockNum
        stimulusSet
        startTime
        audResponse
        bf
        lightPower
        videoEMG
        blockComments
        
        customElectrode 	% electrode configuration (not from the xlsx file)
    end
    
    properties (Dependent, SetAccess = private)
        nChannels
        sitesDepth          % see calcSitesDepth.m
    end
    
    methods
        function this = Labbook(fileName, filePath) % Labbook constructor
            % Basic labbook information
            this.name = fileName;
            this.path = filePath;
            
            % Load the data from the xlsx file
            this.load(fileName, filePath);
            
            % Load electrode configurations
            this.loadCustomElectrodeConfig();
        end
        
        function val = get.nChannels(this)
            val = prod(sscanf(this.electrode.type, '%ux%u'));
        end
        
        function val = get.sitesDepth(this)
            ind = strcmp({this.customElectrode.type}, this.electrode.type);
            val = cellfun(@(td)plus(td, this.customElectrode(ind).spacing), ...
                this.tipDepth, 'UniformOutput', false);
        end
    end
end

