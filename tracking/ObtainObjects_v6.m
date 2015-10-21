function [ObjectsByFrame, PixelListByFrame] =  ObtainObjects_v6(parameters,blankflag)
% This version includes more information about fluoresent intensity
% local mean for spatially distributed protein, top50% mean, 
% local area, top50%intensity_area, total intensity, top50% total intensity,
% std of local intensity, max of local intensity


% this version makes fluorescent channel optional.
% If you don't have fluorescent images, set the number of fluorescent
% channels = 0.

ON=parameters.ON;
maskfilenames=parameters.maskfilenames;

if parameters.numcolors
    fluorfilenames=parameters.fluorfilenames;
end

nfiles=size(maskfilenames, 1);
ObjectsByFrame = cell([nfiles, 1]);
PixelListByFrame = cell([nfiles, 1]);

if parameters.numcolors
for i=1:nfiles
%for i=1:5
    ['Object loop, file: ' num2str(i) ' ' datestr(now)]
    %read mask files
    mask=~imread(maskfilenames{i},'tif');
    
    
    CurrentObjects = regionprops(bwconncomp(mask,4),'Area','Centroid','Eccentricity','Orientation','PixelIdxList');
    
    FluorImages = cell([parameters.numcolors, 1]);

        %determine if there are fluorescent images for this time step, note
        %this function assumes there are blank images at other time points
        if(mod(i-1,parameters.step) == 0)
            for cn=1:parameters.numcolors

                %Determine if there are blank images present in the
                %fluorescence channel (sometimes the microscope software saves
                %these when fluor not sampled with phase).  If yes then there
                %are an equal number of phase and fluor images and they can be
                %scrolled through normally.  If no then there are less fluor
                %then phase and this needs to be taken into account when
                %indexing
                if(blankflag==1)
                    FluorImages{cn} = imread(fluorfilenames{cn, i},'tif');
                else
                    FluorImages{cn} = imread(fluorfilenames{cn, ((i-1)/parameters.step)+1},'tif');
                end
            end
        end
    
    PixelListByFrame{i} = cell(length(CurrentObjects), 1);
    
    for j=1:length(CurrentObjects)

        %CurrentObjects(j).Number=uint16(j);  
        ObjectsByFrame{i}(j,ON.Area)=CurrentObjects(j).Area;
        ObjectsByFrame{i}(j,ON.CentroidX)=CurrentObjects(j).Centroid(1);
        ObjectsByFrame{i}(j,ON.CentroidY)=CurrentObjects(j).Centroid(2);
        ObjectsByFrame{i}(j,ON.Eccentricity)=CurrentObjects(j).Eccentricity;
        ObjectsByFrame{i}(j,ON.Orientation)=CurrentObjects(j).Orientation;
        ObjectsByFrame{i}(j,ON.Number)=j;
        
        PixelListByFrame{i}{j} = CurrentObjects(j).PixelIdxList;
        
        for cn=1:parameters.numcolors
                %Images taken in uint16 format, to compute std they must be
                %converted to double
                if(mod(i-1,parameters.step) == 0)
                    intlist = double(FluorImages{cn}(CurrentObjects(j).PixelIdxList));
                    [nonzero_pixel_id nouse]= find(intlist);
                    nonzero_pixel = intlist(nonzero_pixel_id);
                    
                    if isempty(nonzero_pixel)
                        ObjectsByFrame{i}(j,ON.fluorMean(cn))=0;
                        ObjectsByFrame{i}(j,ON.fluorMeanLocal(cn))=0;
                        ObjectsByFrame{i}(j,ON.fluorMeanTop50(cn))=0;
                        ObjectsByFrame{i}(j,ON.fluorMeanTop25(cn))=0;
                        ObjectsByFrame{i}(j,ON.fluorAreaLocal(cn))=0;
                        ObjectsByFrame{i}(j,ON.fluorAreaTop50(cn))=0;
                        ObjectsByFrame{i}(j,ON.fluorAreaTop25(cn))=0;
                        ObjectsByFrame{i}(j,ON.fluorStdLocal(cn))=0;
                        ObjectsByFrame{i}(j,ON.fluorStdTop50(cn))=0;
                        ObjectsByFrame{i}(j,ON.fluorStdTop25(cn))=0;
                    else
                        
                        ObjectsByFrame{i}(j,ON.fluorMean(cn))=mean(intlist);
                        ObjectsByFrame{i}(j,ON.fluorMeanLocal(cn))=mean(nonzero_pixel);
                        ObjectsByFrame{i}(j,ON.fluorAreaLocal(cn))=size(nonzero_pixel,1);
                        ObjectsByFrame{i}(j,ON.fluorStdLocal(cn))=std(nonzero_pixel);

                        %make histogram of fluordata with 10 bins
%                         hi=max(nonzero_pixel); lo=min(nonzero_pixel);
%                         points=linspace(lo,hi,10);
%                         [hist_int0] = histc(nonzero_pixel,points);
                        
                        sorted_fluor = sort(nonzero_pixel, 'descend');                      
                        top50_fluor = sorted_fluor(1:round(size(sorted_fluor)/20));
                        bot50_fluor = sorted_fluor(1+round(size(sorted_fluor)/20) : end);
                        top25_fluor = sorted_fluor(1:round(size(sorted_fluor)/4));
                        bot25_fluor = sorted_fluor(1+round(size(sorted_fluor)/4) : end);


                            
                        ObjectsByFrame{i}(j,ON.fluorMeanTop50(cn))=mean(top50_fluor)-mean(bot50_fluor);
                        ObjectsByFrame{i}(j,ON.fluorAreaTop50(cn))=size(top50_fluor,1);
                        ObjectsByFrame{i}(j,ON.fluorStdTop50(cn))=sum(top50_fluor);
                        ObjectsByFrame{i}(j,ON.fluorMeanTop25(cn))=mean(top25_fluor)-mean(bot25_fluor);
                        ObjectsByFrame{i}(j,ON.fluorAreaTop25(cn))=size(top25_fluor,1);
                        ObjectsByFrame{i}(j,ON.fluorStdTop25(cn))=sum(top25_fluor);
                    
                    end
                    
%                     prcVals=prctile(double(FluorImages{cn}(CurrentObjects(j).PixelIdxList)),parameters.prcRange);
    %                 ObjectsByFrame{i}(j,ON.fluorPrcRatio(cn))=prcVals(2)/prcVals(1);
                else
                        ObjectsByFrame{i}(j,ON.fluorMean(cn))=NaN;
                        ObjectsByFrame{i}(j,ON.fluorMeanLocal(cn))=NaN;
                        ObjectsByFrame{i}(j,ON.fluorMeanTop50(cn))=NaN;
                        ObjectsByFrame{i}(j,ON.fluorMeanTop25(cn))=NaN;
                        ObjectsByFrame{i}(j,ON.fluorAreaLocal(cn))=NaN;
                        ObjectsByFrame{i}(j,ON.fluorAreaTop50(cn))=NaN;
                        ObjectsByFrame{i}(j,ON.fluorAreaTop25(cn))=NaN;
                        ObjectsByFrame{i}(j,ON.fluorStdLocal(cn))=NaN;
                        ObjectsByFrame{i}(j,ON.fluorStdTop50(cn))=NaN;
                        ObjectsByFrame{i}(j,ON.fluorStdTop25(cn))=NaN;
    %                 ObjectsByFrame{i}(j,ON.fluorPrcRatio(cn))=NaN;                
                end
        end
        
    end

    %count=count+1
    %waitbar(count / nfiles,h)
end
end


if ~parameters.numcolors
%%%% change 20130627 for debug    
    for i=1:nfiles
    ['Object loop, file: ' num2str(i) ' ' datestr(now)]
    %read mask files
    mask=~imread(maskfilenames{i},'tif');

    CurrentObjects = regionprops(bwconncomp(mask,4),'Area','Centroid','Eccentricity','Orientation','PixelIdxList');
    
    PixelListByFrame{i} = cell(length(CurrentObjects), 1);
    
% %     figure; 
% %     imagesc(I_removesmall)
        
    for j=1:length(CurrentObjects)
            
            PixelListByFrame{i}{j} = CurrentObjects(j).PixelIdxList;


            %CurrentObjects(j).Number=uint16(j);  
            ObjectsByFrame{i}(j,ON.Area)=CurrentObjects(j).Area;
            ObjectsByFrame{i}(j,ON.CentroidX)=CurrentObjects(j).Centroid(1);
            ObjectsByFrame{i}(j,ON.CentroidY)=CurrentObjects(j).Centroid(2);
            ObjectsByFrame{i}(j,ON.Eccentricity)=CurrentObjects(j).Eccentricity;
            ObjectsByFrame{i}(j,ON.Orientation)=CurrentObjects(j).Orientation;
            ObjectsByFrame{i}(j,ON.Number)=j;

% %             hold on;
% %             plot(CurrentObjects(j).Centroid(1), CurrentObjects(j).Centroid(2), 'w.');
% %             text(CurrentObjects(j).Centroid(1), CurrentObjects(j).Centroid(2), num2str(j),'Color', [1,1,1]);
            
            cn=1;
            ObjectsByFrame{i}(j,ON.fluorMean(cn))=Nan;
            ObjectsByFrame{i}(j,ON.fluorMeanLocal(cn))=Nan;
            ObjectsByFrame{i}(j,ON.fluorMeanTop50(cn))=Nan;
            ObjectsByFrame{i}(j,ON.fluorMeanTop25(cn))=Nan;
            ObjectsByFrame{i}(j,ON.fluorAreaLocal(cn))=Nan;
            ObjectsByFrame{i}(j,ON.fluorAreaTop50(cn))=Nan;
            ObjectsByFrame{i}(j,ON.fluorAreaTop25(cn))=Nan;
            ObjectsByFrame{i}(j,ON.fluorStdLocal(cn))=Nan;
            ObjectsByFrame{i}(j,ON.fluorStdTop50(cn))=Nan;
            ObjectsByFrame{i}(j,ON.fluorStdTop25(cn))=Nan;

    end
    
% %     pause;

    end
end





end
