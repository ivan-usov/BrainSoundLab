% Plot data element from blockType2 vs data element from blockType1 for
% each channel in the first group
function [xdata, ydata, allx,ally,meanallx, meanally,stdrallx,stdrally] = DSIvsBF_loop_TRB()
blockType1 = 'experiment.ToneFine';
blockType2 = 'experiment.FMS';
labbookType1 = 'labbook';

%Frequency Window (in kHz)
lowBF=4;
highBF=50;
% Depth Window (in um)
lowDepth=50;
highDepth=700;
%Dprime value
dprime=3;
%DSI parameters
DSIlevel=2; %DSIlevel of 1=40dB, DSIlevel of 2=60dBM DSIlevel of 3=80dB
DSIspeed=1; %DSIspeed of 6=90oct/s, DSIspeed of 5=75oct/s etc

    function isValid = validateExperiment(labbook)
        isValid = 0;
        
%         if ~strcmp(labbook.mouse.age, '7 weeks') % strings are not equal
%             return
%         end
%         
%         if labbook.mouse.weight ~= 20
%             return
%         end
        
        isValid = 1;
    end

    function [x, x_label, y, y_label] = extractData(block1, block2, sitesDepth)
        BF = block1.custom.BF{1};
        DSI = block2.custom.DSIwspont{1};
        DSI = cellfun(@(x) x(DSIlevel,DSIspeed), DSI); % 2 - 60 dB, 5 - 75 oct/s
        
        ind = validateBlockType1a(block1) & validateBlockType1b(block1) & validateBlockType2(block2)& validateRecordingSites(sitesDepth) ;
        x = BF(ind);
        x_label = 'BF, kHz';
        
        y = DSI(ind);
        y_label = 'DSI';
    end

    function ind = validateBlockType1a(block)  
        BF = block.custom.BF{1};
        ind = (BF<highBF & BF>=lowBF) ; %select only data with BF between the 2 values in kHz
    end

    function ind = validateBlockType1b(block)  
        dPrime = block.custom.dPrime{1};
        ind = (dPrime > dprime);
    end

    function ind = validateBlockType1c(block)  
        Thresh = block.custom.Thr{1};
        ind = (Thresh < 70 & Thresh > 10) ;
    end

    function ind = validateBlockType2(block)
        ind = true(1, block.nChannels);
    end

    function ind = validateRecordingSites(sitesDepth)  
        SiteDepth = sitesDepth{1};
        ind = (SiteDepth > lowDepth & SiteDepth < highDepth);
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
xdataplot = cell(length(dir_ind), 1); %for plotting in octave
allx=[];
ally=[];
allxplot=[]; %for plotting in octave

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
        sitesDepth{1} = labbook.sitesDepth{blockInd}(:);
        sitesDepth{1} = sitesDepth{1}';
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
            [x, x_label, y, y_label] = extractData(mat1.block, mat2.block, sitesDepth);
            
            xdata{k}{end+1} = x;
            ydata{k}{end+1} = y;
            xplot =log2(x/4); %for plotting in octave scale
            xdataplot{k}{end+1} =xplot;  %for plotting in octave scale
            allx=[allx,x];
            allxplot=[allxplot,xplot]; %for plotting in octave scale
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
xdataplot = xdataplot(~emptyCell_ind);

% Remove 'ally' and 'allx' whose 'allx' is NaN 
temp_allx=allx;
allx(isnan(temp_allx)==1)=[];
ally(isnan(temp_allx)==1)=[];  
  
% Remove 'ally' and 'allx' whose 'ydata' is NaN 
temp_ally=ally;
ally(isnan(temp_ally)==1)=[];
allx(isnan(temp_ally)==1)=[];

% calculate mean and stdr of allx and ally data
numbern(1)=length(ally);
meanallx(1)=mean(allx);
stdrallx(1)=std(allx)/sqrt(length(allx));
meanally(1)=mean(ally);
stdrally(1)=std(ally)/sqrt(length(ally));

%calculate mean and stdr of allx and ally data by grouping them into
%octaves
BFrange=[4,8,16,32,59];
for i=2:(length(BFrange))
    BFmin=BFrange(i-1);
    BFmax=BFrange(i);
    tempallx=allx(find(allx>=BFmin&allx<BFmax));
    tempally=ally(find(allx>=BFmin&allx<BFmax));
    numbern(i)=length(tempally);
    meanallx(i)=mean(tempallx);
    stdrallx(i)=std(tempallx)/sqrt(numbern(i));
    meanally(i)=mean(tempally);
    stdrally(i)=std(tempally)/sqrt(numbern(i));
end
    

% Plot data in a figure
% Max number of possible symbols (max unique animals) = 12
% Maxumber of possible colors (max unique penetrations per animal) = 7

%Transform some values to get Tick well located and displaced in kHz (not
%octave) - here it is to get 4 ticks in total
xtick1=log2(lowBF/4);
xtick4=log2(highBF/4);
xtick2=xtick1+(xtick4-xtick1)/3;
xtick3=xtick1+(xtick4-xtick1)*2/3;

h=figure;
subplot(3,1,1);
set(h,'name',userDir);
axes;

hold on
symbols = ['o', '+', '*', 'x', 's', 'd', '^', 'v', '<', '>', 'p', 'h'];
for k = 1:length(xdata)
    symbol = symbols(k);
    expDataX = xdataplot{k};
    expDataY = ydata{k};
    cellfun(@(x,y) plot(x,y,symbol), expDataX, expDataY);
    set(gca, 'ColorOrderIndex', 1);
end

xlabel(x_label)
ylabel(y_label)
set(gca,'XLim',[xtick1 xtick4]);
set(gca,'XTick',[xtick1 xtick2 xtick3 xtick4]);
set(gca,'XTickLabel',[lowBF round(4*2^xtick2) round(4*2^xtick3) highBF]);
hold off

subplot(3,1,2)
bar(meanally);
hold on
errorbar(meanally,stdrally,'.');
ylabel(y_label);
hold off

subplot(3,1,3)
bar(meanallx);
hold on
errorbar(meanallx,stdrallx,'.');
ylabel(x_label);
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Save all data in an analysis m file
newname = strcat(userDir,'_Analysis.mat');
analysis.meanallx =meanallx';
analysis.meanally = meanally';
analysis.stdrallx = stdrallx';
analysis.stdrally = stdrally';
analysis.xdata = xdata;
analysis.ydata = ydata;
analysis.allx = allx';
analysis.ally = ally';
analysis.numbern = numbern';
figname = strcat(userDir,'_Analysis.fig');

save(newname,'analysis');
savefig(h,figname);
end

