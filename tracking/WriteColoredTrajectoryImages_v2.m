function WriteColoredTrajectoryImages_v2(objectCell,Traj,TrajInFrames,parameters,OutputDir,flag)
ON=parameters.ON;
TN=parameters.TN;
phasefilenames=parameters.phasefilenames;
if parameters.numcolors
    fluorfilenames=parameters.fluorfilenames(1,:);
end
maskfilenames=parameters.maskfilenames;

colorDepth=255;

if(~isdir(OutputDir))
        mkdir(OutputDir);
end

numOfFrames=length(objectCell);

h = waitbar(0,'Writing output images');

for slice=1:numOfFrames
%for slice=1:5

    mask=~imread(maskfilenames{slice},'tif');
    
    CurrentObjects = regionprops(bwconncomp(mask,4),'PixelIdxList');
    rgbMask=uint16(mask);
   % for j=1:length(Traj)
        
%     TrajObjectsInSlice=[TrajBin{slice}{:}];
%     TrajNumbers=[TrajObjectsInSlice.Number];
   % slice
    
    colorFirstEntry=1;
    x=[];
    y=[];
    TrajNumsToPrint=[];
    
    TrajInCurrentFrame=TrajInFrames{slice};

    for i=1:length(TrajInCurrentFrame)

        frameArray=Traj{TrajInCurrentFrame(i)}(:,TN.frame)==slice;
        if(any(frameArray))    

            objectNum=Traj{TrajInCurrentFrame(i)}(frameArray,TN.object);
         
            x(end+1)=round(objectCell{slice}(objectNum,ON.CentroidX));
            y(end+1)=round(objectCell{slice}(objectNum,ON.CentroidY));

            TrajNumsToPrint(end+1)=TrajInCurrentFrame(i);
            
            %mark the mask based on the object num.  Note the
            %if(max(rgbMask(:))<colorDepth ensures that there will always be a
            %max of 255 in this label matrix, even for low cell numbers.
            %This helps with consistency of the coloring
           % if(max(rgbMask(:))<colorDepth)
           if(colorFirstEntry)
                rgbMask(CurrentObjects(objectNum).PixelIdxList)=colorDepth;
                colorFirstEntry=0;
            else
                rgbMask(CurrentObjects(objectNum).PixelIdxList)=mod(TrajInCurrentFrame(i),colorDepth);
           end           
        end     
    end
  
  
    rgb=label2rgb(rgbMask,'hsv','k','shuffle');
    
    
    trajRGB = writeIntToImg(rgb, x, y, TrajNumsToPrint, [1 1 1]);
    
    if(flag.trajRGB)
        colorFileName=['SegmentedColor',num2str(slice),'.tif'];
        imwrite(trajRGB,[OutputDir colorFileName],'tif','Compression','none');
    end
    
    if(flag.overlay)
        boundariesLow=0.0125;
        boundariesHigh=1-boundariesLow;
        
        phase=imread(phasefilenames{slice},'tif');
        phaseDBL=im2double(phase);
        [M N]=size(phaseDBL);
        phaseRESHAPE=reshape(phaseDBL,M*N,1);
        %hist(phaseRESHAPE,25)
        
        phaseRESHAPE_sort=sort(phaseRESHAPE);      
        phaseRESHAPE_length=length(phaseRESHAPE_sort);
        
%%%% changed! for test 20130627
        lowbound=phaseRESHAPE_sort(round(phaseRESHAPE_length*boundariesLow));
        highbound=phaseRESHAPE_sort(round(phaseRESHAPE_length*boundariesHigh));
        
        phaseDBLscaled=(1/(highbound-lowbound))*(phaseDBL-lowbound);
        phaseUINT8=im2uint8(phaseDBLscaled);
                
        [phaseInd,map]=gray2ind(phaseUINT8);
        phaseRGB=ind2rgb8(phaseInd,map);
        
        compositeRGB=0.5*phaseRGB+0.5*trajRGB;

        colorFileName=['CompositeColor',num2str(slice),'.tif'];
        imwrite(compositeRGB,[OutputDir colorFileName],'tif','Compression','none');
    end
    if(flag.overlayFluor)
        boundariesLow=0.0125;
        boundariesHigh=1-boundariesLow;
        
        fluor=imread(fluorfilenames{slice},'tif');
        
        fluorDBL=im2double(fluor);
        [M N]=size(fluorDBL);
        fluorRESHAPE=reshape(fluorDBL,M*N,1);
        %hist(phaseRESHAPE,25)
        
        fluorRESHAPE_sort=sort(fluorRESHAPE);      
        fluorRESHAPE_length=length(fluorRESHAPE_sort);
        
        lowbound=fluorRESHAPE_sort(round(fluorRESHAPE_length*boundariesLow));
        highbound=fluorRESHAPE_sort(round(fluorRESHAPE_length*boundariesHigh));
        
        fluorDBLscaled=(1/(highbound-lowbound))*(fluorDBL-lowbound);
        fluorUINT8=im2uint8(fluorDBLscaled);
                
        [fluorInd,map]=gray2ind(fluorUINT8);
        fluorRGB=ind2rgb8(fluorInd,map);
        
        fluorRGBint = writeIntToImg(fluorRGB, x, y, TrajNumsToPrint, [1 0 0]);
%         
%         compositeFluorRGB=0.8*fluorRGB+0.2*trajRGB;
% 
         colorFluorFileName=['CompositeFluorColor',num2str(slice),'.tif'];
%         imwrite(compositeFluorRGB,[OutputDir colorFluorFileName],'tif','Compression','none');
        imwrite(fluorRGBint,[OutputDir colorFluorFileName],'tif','Compression','none');
    end
    %imwrite(rgb,[OutputDir colorFileName],'tif','Compression','none');
   
    waitbar(slice / numOfFrames,h)
end
%fclose(fidO);