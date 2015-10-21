
function parameters=getParameters_v5(experiment, fluorflag)
%%has modified parameters.binSize for 60X (rather than 40X)

parameters.subexperiment=experiment.edit1;
parameters.numcolors=fluorflag; %str2double(get(experiment.edit2,'String'));
parameters.step=experiment.edit2;

%parameters.binSize=30; %str2double(get(experiment.edit4,'String'));
parameters.binSize=220; %for 60X


parameters.numOfPreviousFramesToConsider=1; % str2double(get(experiment.edit6,'String'));
%change parameters.maskConcat to ask for user input if desired
parameters.maskConcat='mask_';
%Setup Trajectory Navigator
parameters.TN.frame=1;
parameters.TN.object=2;
parameters.TN.score=3;
parameters.TN.TBC1=4;
parameters.TN.TBC2=5;

%Setup Object Navigator
ON.Area=1;
ON.CentroidX=2;
ON.CentroidY=3;
ON.Eccentricity=4;
ON.Orientation=5;
ON.Number=6;
numOfFields=length(fieldnames(ON));
if parameters.numcolors
    for k=1:parameters.numcolors
        ON.fluorMean(k)=numOfFields+k;
        ON.fluorMeanLocal(k)=numOfFields+parameters.numcolors+k;
        ON.fluorAreaLocal(k)=numOfFields+2*parameters.numcolors+k;
        ON.fluorStdLocal(k)=numOfFields+3*parameters.numcolors+k;

        ON.fluorMeanTop50(k)=numOfFields+4*parameters.numcolors+k;
        ON.fluorAreaTop50(k)=numOfFields+5*parameters.numcolors+k;
        ON.fluorStdTop50(k)=numOfFields+6*parameters.numcolors+k; 

        ON.fluorMeanTop25(k)=numOfFields+7*parameters.numcolors+k;
        ON.fluorAreaTop25(k)=numOfFields+8*parameters.numcolors+k;
        ON.fluorStdTop25(k)=numOfFields+9*parameters.numcolors+k; 
    end
else % although keep the fluor readout, their values are zeros
    k=1;
        ON.fluorMean(k)=numOfFields+k;
        ON.fluorMeanLocal(k)=numOfFields+parameters.numcolors+k;
        ON.fluorAreaLocal(k)=numOfFields+2*parameters.numcolors+k;
        ON.fluorStdLocal(k)=numOfFields+3*parameters.numcolors+k;

        ON.fluorMeanTop50(k)=numOfFields+4*parameters.numcolors+k;
        ON.fluorAreaTop50(k)=numOfFields+5*parameters.numcolors+k;
        ON.fluorStdTop50(k)=numOfFields+6*parameters.numcolors+k; 

        ON.fluorMeanTop25(k)=numOfFields+7*parameters.numcolors+k;
        ON.fluorAreaTop25(k)=numOfFields+8*parameters.numcolors+k;
        ON.fluorStdTop25(k)=numOfFields+9*parameters.numcolors+k; 
end
parameters.ON=ON;

parameters.CP.trajNumber=1;
parameters.CP.score=2;
parameters.CP.active=3;

parameters.maskfilenames=getFilenameCellList(experiment.maskdir,'*.tif');
phasepattern = ['*' parameters.subexperiment 'c1.tif'];
parameters.phasefilenames=getFilenameCellList(experiment.phasedir,phasepattern);
parameters.maskfilenamesToOutput=getFilenameCellListConcat(experiment.phasedir,phasepattern,experiment.maskdir,parameters.maskConcat);

if fluorflag
    for cn = 1:parameters.numcolors
       %come up with the color pattern, note the colors begin at c2 to
       fluorpattern=['*' parameters.subexperiment 'c' num2str(cn+1) '.tif'];
       parameters.fluorfilenames(cn,:)=getFilenameCellList(experiment.fluordir,fluorpattern);
    end
end
 

%find image dimensions from the mask
mask=~imread(parameters.maskfilenames{1});
% can't suppress the output of imread...:(
parameters.imageDimensions(1)=size(mask,2);
parameters.imageDimensions(2)=size(mask,1);

parameters.binnedDimensions=round(parameters.imageDimensions/parameters.binSize)

%parameters.AvCellBox=21;
parameters.AvCellBox=31; %for 60X

%weighting parameters for Will's Metric
parameters.alpha=0.5;
parameters.beta=2;
parameters.epsilon=1;
parameters.gamma=0.25;

parameters.prcRange=[10 90];

end