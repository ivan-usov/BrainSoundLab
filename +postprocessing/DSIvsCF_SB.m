% Plot data element from blockType2 vs data element from blockType1 for
% each channel in the first group
function [xdata, ydata, allx,ally, meanallx, meanally, stdrallx, stdrally] = DSIvsCF_SB()
blockType1 = 'experiment.ToneFine';
blockType2 = 'experiment.FMS';
labbookType1 = 'labbook';


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
        CF = block1.custom.CF{1};
        DSI = block2.custom.DSInum{1};
        DSI = cellfun(@(x) x(2,5), DSI);
        % 1,2,3 - 40,60,80 dB (1st value of DSI)
        % 1,2,3,4,5,6 - 15,30,45,60,75,90 oct/s (2nd value of DSI)
        
        ind = validateBlockType1a(block1) & validateBlockType1b(block1) & validateBlockType1c(block1) & validateBlockType2(block2)& validateRecordingSites(sitesDepth) ;
        x = CF(ind);
        x_label = 'CF (kHz)';
        
        y = DSI(ind);
        y_label = 'DSI';
    end

    %---select only data with BF between the 2 values in kHz
    function ind = validateBlockType1a(block)  
        CF = block.custom.CF{1};
        ind = (CF<40 & CF>5) ; 
    end

    %---select only data dPrime > 3
    function ind = validateBlockType1b(block)  
        dPrime = block.custom.dPrime{1};
        ind = (dPrime > 0.6);
    end

    %---select only data with threshold between 10 and 70 dB
    function ind = validateBlockType1c(block)  
        Thresh = block.custom.Thr{1};
        ind = (Thresh < 70 & Thresh > 10) ;
    end

    %---elect only data with sitedepth between 2 values in um
    %In P20:         I/II 250 um;      III/IV 250-450;           V/VI >450   
    function ind = validateRecordingSites(sitesDepth)
        SiteDepth = sitesDepth{1};
        ind = (SiteDepth > 100 & SiteDepth < 700);
    end

    %---select only data with block 2 type present
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
xdataplot = cell(length(dir_ind), 1); %for plotting in octave
allx=[];
ally=[];
allxplot=[]; %for plotting in octave
x_label = 'CF (kHz)'; y_label = 'DSI'; %% added by RR Mar 2016

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

% Remove empty cells from 'ydata' and 'xdata'
emptyCell_ind = cellfun(@isempty, xdata);
xdata = xdata(~emptyCell_ind);
ydata = ydata(~emptyCell_ind);
xdataplot = xdataplot(~emptyCell_ind);

% Remove 'ydata' and 'xdata' whose 'xdata' is NaN 
temp_allx=allx;
temp_allxplot=allxplot;
allx(isnan(temp_allx)==1)=[];
allxplot(isnan(temp_allxplot)==1)=[];
ally(isnan(temp_allx)==1)=[];  

 
% Remove 'ydata' and 'xdata' whose 'ydata' is NaN 
temp_ally=ally;
ally(isnan(temp_ally)==1)=[];
allx(isnan(temp_ally)==1)=[];
allxplot(isnan(temp_ally)==1)=[]; 

    
% Mean and STDev of allx and ally data
numbern=length(ally);
meanallx=mean(allxplot);
stdrallx=std(allx)/sqrt(length(allx));
meanally=mean(ally);
stdrally=std(ally)/sqrt(length(ally));


% Plot data in a figure
% Max number of possible symbols (max unique animals) = 12
% Maxumber of possible colors (max unique penetrations per animal) = 7

%--------------FIGURE 1---------------------------------------

%Transform some values to get equally spaced tick in kHz (not octave)
% here it is to get 4 ticks in total

lowCF=5;
highCF=50;


xtick1=log2(lowCF/4);
xtick4=log2(highCF/4);
xtick2=xtick1+(xtick4-xtick1)/3;
xtick3=xtick1+(xtick4-xtick1)*2/3;

h=figure;
set(h,'name',userDir);
axes;
hold on
symbols = ['o', '+', '*', 'x', 's', 'd', '^', 'v', '<', '>', 'p', 'h'];
for k = 1:length(xdataplot)
    symbol = symbols(k);
    expDataX = xdataplot{k};
    expDataY = ydata{k};
    cellfun(@(x,y) plot(x,y,symbol), expDataX, expDataY);
    set(gca, 'ColorOrderIndex', 1);
end

% plot regression line
p = polyfit(allxplot,ally,1);
pp = polyval (p,allxplot);
R=corrcoef(allxplot,ally);
R_squared=R(2)^2;
slope = p(1);

hold on
plot(allxplot,pp, '-m')
xlabel(x_label)
ylabel(y_label)

title('CF vs DSI')

set(gca,'YLim',[-1 1])
set(gca,'YTick',[-1:0.5:1])
set(gca,'XLim',[xtick1 xtick4]);
set(gca,'XTick',[xtick1 xtick2 xtick3 xtick4]);
set(gca,'XTickLabel',[lowCF round(4*2^xtick2) round(4*2^xtick3) highCF]);

hold on
hline = refline([0 0]);          % add reference line at 0
hline.Color = [0.6, 0.6, 0.6];   % color of the line is grey

hold on
text(xtick3, 0.9, ['R^2 = ' num2str(R_squared)])
% text (x coordinate, y coordinate, R....
text(xtick3, 0.8, ['m = ' num2str(slope)])
% y= mx + c

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Save all data in an analysis m file
newname = strcat(userDir,'_Analysis.mat');
analysis.meanallx =meanallx;
analysis.meanally = meanally;
analysis.stdrallx = stdrallx;
analysis.stdrally = stdrally;
analysis.xdata = xdata;
analysis.ydata = ydata;
analysis.allx = allx;
analysis.ally = ally;
analysis.numbern = numbern;
analysis.R_squared = R_squared;
analysis.slope = slope;
figname = strcat(userDir,'_Analysis.fig');

save(newname,'analysis');
savefig(h,figname);


end


