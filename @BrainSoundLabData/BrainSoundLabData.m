classdef BrainSoundLabData < handle
    %BRAINSOUNDLABDATA BrainSoundLab core class
    
    properties % Basic data
        panels                      % references to all panels
        openPanels                  % references to the open panels
        
        defaultPanels = {'Experiment', ...   % initially open panels
            'Information', ...
            'Electrode', ...
            'Raster', ...
            'PSTH'};
        
        labbook                     % labbook data
        block                       % block data
        
        stimPrime                   % selected stimulus in the raster panel
        stimSecond                  % secondary stimulus
        
        curBlock                    % current number of a block
        curChannel = 1;             % current number of a channel
        curGroup = 1;               % current number of a group
        
        dataName = char.empty;      % name of the file to save data to
        dataPath = char.empty;      % path of the file to save data to
        
        isDataModified = false;
    end
    
    properties % Properties of the core panels
        blockIndex
        
        % Experiment panel
        suppressRepSpikes = true;
        tolerance = 1e-5;
        nRepSpikes = 5;
        
        % PSTH panel
        fixLim_psth = false;
        fixedMaxVal_psth
        nBins_psth = 200;
        nStdDev_psth = 3;
        
        % Red patches in the Raster and PSTH plots
        p1
        p2
    end
    
    methods
        function set.openPanels(this, val)
            this.openPanels = val;
            this.updatePanelPosition();
        end
        
        function set.curBlock(this, val)
            this.enableItems();
            temp = this.curBlock;
            % Try to load the block
            this.curBlock = this.blockIndex{val, 1};
            set(findobj('Tag', 'lb_blocks_experiment'), 'Value', val);
            
            status = this.loadBlock(val);
            if status == 0
                this.curBlock = temp;
                if ~isempty(temp)
                    % Recover the previously selected block
                    set(findobj('Tag', 'lb_blocks_experiment'), 'Value', temp);
                end
                return
            end
        end
        
        function set.curChannel(this, val)
            this.curChannel = val;
            set(findobj('Tag', 'lb_channels_experiment'), 'Value', val);
            this.setChannel();
        end
        
        function val = get.curGroup(this)
            val = this.block.getGroupNumber();
        end
        
        function set.fixedMaxVal_psth(this, val)
            this.fixedMaxVal_psth = val;
            set(findobj('Tag', 'e_fixedMaxVal_psth'), 'String', val);
        end
    end
end

