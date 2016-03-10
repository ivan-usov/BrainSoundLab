% Plot data element from blockType2 vs data element from blockType1 for
% each channel in the first group
function [xdata, ydata] = DSIvsBF()
blockType1 = 'experiment.ToneFine';
blockType2 = 'experiment.FMS';

    function isValid = validateExperiment(labbook)
        isValid = 0;
        
%        if ~strcmp(labbook.mouse.age, '7 weeks') % strings are not equal
%             return
%         end
%         
%         if labbook.mouse.weight ~= 20
%             return
%         end
        
        isValid = 1;
    end

    function [x, x_label, y, y_label] = extractData(block1, block2)
        BF = block1.custom.BF{1};
        DSI = block2.custom.DSInum{1};
        DSI = cellfun(@(x) x(2,6), DSI); % 2 - 60 dB, 6 - 90 oct/s
        
        ind = validateBlockType1(block1) & validateBlockType2(block2);
        x = BF(ind);
        x_label = 'BF, kHz';
        
        y = DSI(ind);
        y_label = 'DSI';
    end

    function ind = validateBlockType1(block)
        dPrime = block.custom.dPrime{1};
        ind = (dPrime > 0.6);
    end

    function ind = validateBlockType2(block)
        ind = true(1, block.nChannels);
    end

% ------------------------------------------------------------------------------
% Open folder selection dialog
userDir = uigetdir(pwd, 'Select folder with all experiments');

% Get indexes of the valid experiment folders
dir_list = dir(userDir);
dir_name = {dir_list.name};
dir_ind = find([dir_list.isdir] & ~strcmp(dir_name, '.') & ~strcmp(dir_name, '..'));

xdata = cell(length(dir_ind), 1);
ydata = cell(length(dir_ind), 1);
for k = 1:length(dir_ind)
    % Find matlab files in k'th experiment folder
    intDir = fullfile(userDir, dir_name{dir_ind(k)});
    matFiles = what(intDir);
    matFileNames = matFiles.mat;
    
    % Identify a class type and a penetration number of all found mat files
    % in the experiment folder
    classType = cell(size(matFileNames));
    penetration = zeros(size(matFileNames));
    for l = 1:length(matFileNames)
        mat = matfile(fullfile(intDir, matFileNames{l}));
        
        if l == 1 % Validate experiment
            labbook = mat.labbook;
            if ~validateExperiment(labbook)
                break
            end
        end
        
        % Save class type
        block = mat.block;
        classType{l} = class(block);
        
        % Save penetration
        blockNum = sscanf(block.name, [labbook.expID '_Block-%u']);
        blockInd = (labbook.blockNum == blockNum);
        penetration(l) = labbook.penetrationNum{blockInd};
    end
    
    blockType1_ind = strcmp(blockType1, classType);
    blockType2_ind = strcmp(blockType2, classType);
    
    % Find appropriate block types within the same penetration number and
    % extract data, which fits to the defined requirements
    penNums = unique(penetration)';
    for penNum = penNums
        pen_ind = (penetration == penNum);
        block1_ind = find(blockType1_ind & pen_ind);
        block2_ind = find(blockType2_ind & pen_ind);
        if length(block1_ind) == 1 && length(block2_ind) == 1
            mat1 = matfile(fullfile(intDir, matFileNames{block1_ind}));
            mat2 = matfile(fullfile(intDir, matFileNames{block2_ind}));
            [x, x_label, y, y_label] = extractData(mat1.block, mat2.block);
            xdata{k}{end+1} = x;
            ydata{k}{end+1} = y;
        else
            % Ask user about the found blocks
        end
    end
end

% Remove empty cells from 'xdata' and 'ydata'
emptyCell_ind = cellfun(@isempty, xdata);
xdata = xdata(~emptyCell_ind);
ydata = ydata(~emptyCell_ind);

% Plot data in a figure
% Max number of possible symbols (max unique animals) = 12
% Maxumber of possible colors (max unique penetrations per animal) = 7
figure;
axes;
hold on
symbols = ['o', '+', '*', 'x', 's', 'd', '^', 'v', '<', '>', 'p', 'h'];
for k = 1:length(xdata)
    symbol = symbols(k);
    expDataX = xdata{k};
    expDataY = ydata{k};
    cellfun(@(x,y) plot(x,y,symbol), expDataX, expDataY);
    set(gca, 'ColorOrderIndex', 1);
end
hold off
xlabel(x_label);
ylabel(y_label);

end

