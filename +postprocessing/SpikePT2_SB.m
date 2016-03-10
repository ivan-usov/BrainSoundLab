% Plot data element from blockType2 vs data element from blockType1 for
% each channel in the first group
function [xdata, ydata, allx, ally, meanallx, meanally, stdrallx, stdrally] = SpikePT2_SB()
blockType1 = 'experiment.ToneFine';
labbookType1 = 'labbook';

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

    function [x, x_label, y, y_label] = extractData(block1)
        BF = block1.custom.BF{1};
        TRF = block1.custom.TRF{1};
        for row=1:17
        Temp_TRF(row,:) = cellfun(@(x) x(row,15), TRF); %%% 1-17: 0-80 dB in step 5 %%% 1-37: 37 different frequencies (block.stim.freq)
        Temp_TRF(row,:)=  Temp_TRF(row,:)/0.05;        % Spikes per 50 ms
        T_TRF = Temp_TRF';
        end
% % %         ind = validateBlockType1a(block1) & validateBlockType1b(block1) & validateBlockType1c(block1) & validateBlockType2(block2)& validateRecordingSites(sitesDepth) ;
        TRF=T_TRF;
        ind = validateBlockType1a(block1) & validateBlockType1b(block1) & validateBlockType1c(block1);
        x = BF(ind);
        x_label = 'BF, kHz';
        
        y = TRF(ind);
        y_label = 'Spikes/s';
    end

    %---select only data with BF between 5 and 40 kHz
    function ind = validateBlockType1a(block)  
        BF = block.custom.BF{1};
        ind = (BF>5 & BF<40) ; 
    end

    %---select only data dPrime > 3
        function ind = validateBlockType1b(block)  
        dPrime = block.custom.dPrime{1};
        ind = (dPrime > 0.6);
    end


    %---select only data with threshold between 10 and 70 dB
    function ind = validateBlockType1c(block)  
        Thresh = block.custom.Thr{1};
        ind = (Thresh > 10 & Thresh < 70) ;
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
allx=[];
ally=[];


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
% % %         sitesDepth{1} = labbook.sitesDepth{blockInd}(:);
% % %         sitesDepth{1} = sitesDepth{1}';
    end
    
    blockType1_ind = strcmp(blockType1, classType);
    
    
    % Find appropriate block types within the same penetration number and
    % extract data, which fits to the defined requirements
    penNums = unique(penetration)';
    for penNum = penNums
        pen_ind = (penetration == penNum);
        block1_ind = find(blockType1_ind & pen_ind);
        if length(block1_ind) == 1
            mat1 = matfile(fullfile(intDir, matFileNames{block1_ind}));
            % % %             [x, x_label, y, y_label] = extractData(mat1.block, mat2.block, sitesDepth);
            [x, x_label, y, y_label] = extractData(mat1.block);
            xdata{k}{end+1} = x;
            ydata{k}{end+1} = y;
            allx=[allx,x];
            ally=[ally,y];
        else
            % Ask user about the found blocks
        end
    end
end

% Remove empty cells from 'xdata' and 'ydata'
emptyCell_ind = cellfun(@isempty, xdata);
xdata = xdata(~emptyCell_ind);
ydata = ydata(~emptyCell_ind);

% Remove 'ydata' and 'xdata' whose 'xdata' is NaN 
temp_allx=allx;
allx(isnan(temp_allx)==1)=[];
ally(isnan(temp_allx)==1)=[];  
  
% Remove 'ydata' and 'xdata' whose 'ydata' is NaN 
temp_ally=ally;
ally(isnan(temp_ally)==1)=[];
allx(isnan(temp_ally)==1)=[];  


% No. of BF present, BF1: 4-8, BF2: 8-16, BF3: 16-32, BF4: 32-64
BF1=0;
BF2=0;
BF3=0;
BF4=0;
for n=1:length(allx)
    if allx(1,n)>= 4 && allx(1,n)<8
        BF1= (BF1)+1;
    elseif allx(1,n)>= 8 && allx(1,n)<16
        BF2= (BF2)+ 1;
    elseif allx(1,n)>= 16 && allx(1,n)<32
        BF3= (BF3)+1;
    elseif allx(1,n)>= 32 && allx(1,n)<48
        BF4=(BF4)+1;
    else
    end
end
    

% Plot data in a figure
% Max number of possible symbols (max unique animals) = 12
% Maxumber of possible colors (max unique penetrations per animal) = 7


h=figure;
set(h,'name',userDir);

subplot(3,1,1)
plot (allx, ally, '.')
xlabel ('BF')
ylabel ('Spikes/s')
xlim ([0 40])

numbern=length(ally);
%Mean std sem
mval=mean(ally);
sdev=std(ally);
sem=sdev/sqrt(length(ally));

%Plot Mean graph with SEM
subplot(3,1,2)
bar(mval,'r')
hold on
errorbar(mval,sem,'r')
ylabel ('Mean Spikes/s')
xlim ([0 2])

%Plot BF distribution
subplot(3,1,3)
y=[BF1,BF2,BF3,BF4];
bar (y,'w')
% % % xlabel ('4-8'; '8-16'; '16-32'; '32-48')
xlim ([0 5])
set(gca,'XTickLabel',{'4-8','8-16','16-32','32-48'})
ylabel ('No. of BF')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Save all data in an analysis m file
newname = strcat(userDir,'_AnalysisSpikesAmsPT2.mat');
analysis.meanally = mval;
analysis.stdrally = sdev;
analysis.semrally = sem;
analysis.xdata = xdata;
analysis.ydata = ydata;
analysis.allx = allx;
analysis.ally = ally;
analysis.numbern = numbern;
analysis.BFnumber= y;
figname = strcat(userDir,'_AnalysisSpikesAmsPT2.fig');

save(newname,'analysis');
savefig(h,figname);

end


