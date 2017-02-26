function calcDiscriminability(group, source)
BSL = guidata(gcf);
block = BSL.block;
if nargin == 0
    group = 1:block.nGroups;
    %chan = 1:block.nChannels;
end

% Preallocate in case of the first time calculation
if ~isfield(block.custom, 'Beha')
    block.custom.HitRate = cell(1, block.nGroups);
    block.custom.FARate = cell(1, block.nGroups);
    block.custom.dprime = cell(1, block.nGroups);
    block.custom.correctresponse = cell(1, block.nGroups);
    block.custom.reaxtime = cell(1, block.nGroups);
end

%There is a bug in the TDT software that sometimes add a gotone and
%a hit when starting the program- if that happens, first points
%should be removed
if source.Hit_.onset(1)<3
    source.Hit_.onset = source.Hit_.onset([2:end]);
    source.Hit_.data = source.Hit_.data([2:end]);
end

LickTime=source.Hit_.onset;

for k = group
    %Make sure there are some go and nogo tones
    if length(find(source.beha.data==0))~=0
        if length(find(source.beha.data~=0))~=0
            
            % Hit rate, FA rate,reaction time and dprime calculation
            for i=1:length(source.Hit_.data)
                timesub=source.Hit_.onset(i)-source.beha.onset;
                [ind]=find(timesub==(min(abs(timesub))));
                %Hit calculations
                nbhit=sum(source.Hit_.data(1:i)~=0);
                nbgotone=length(find(source.beha.data(1:ind)==0));
                if nbgotone ~=0 % if a gotone has been presented
                    hitrate(i)=nbhit/nbgotone;
                    if source.Hit_.data(i)==1 % if it is a hit
                        reaxtimehit(i)=timesub(ind);
                    else
                        reaxtimehit(i)=NaN;
                    end
                else
                    hitrate(i)=0.5;
                    reaxtimehit(i)=NaN;
                end
                
                %FA calculations
                nbFA=sum(source.Hit_.data(1:i)==0);
                nbnogotone=length(find(source.beha.data(1:ind)~=0));
                if nbnogotone ~=0 % if a nogotone has been presented
                    FArate(i)=nbFA/nbnogotone;
                    if source.Hit_.data(i)==0 % if it is a FA
                        reaxtimeFA(i)=timesub(ind);
                    else
                        reaxtimeFA(i)=NaN;
                    end
                else
                    FArate(i)=0.5;
                    reaxtimeFA(i)=NaN;
                end
                
                % Dprime calculation
                hitratefordprime=hitrate(i);
                FAratefordprime=FArate(i);
                if hitratefordprime==1
                    hitratefordprime=1-(1/(2*nbgotone));
                end
                if FAratefordprime==0
                    FAratefordprime=1/(2*nbnogotone);
                end
                if hitratefordprime==0
                    hitratefordprime=1/(2*nbgotone);
                end
                if FAratefordprime==1
                    FAratefordprime=1-(1/(2*nbnogotone));
                end
                dprime(i)=norminv(hitratefordprime)-norminv(FAratefordprime);
                
            end
            
        else
            sprintf('This experiment has no false alarm')
        end
    else
        sprintf ('This experiment has no hit.')
    end
end

