function [FluorTraj,Traj,TrajInFrames,ObjectsByFrame, keepTrajID]  = cell_tracking_nogui_BB6()

dbstop if error

addpath('/Volumes/Storage/MATLAB/Image_analysis/Yeast/')
cd /Volumes/Storage/Expt_BB/expt12_aug8_2014/
%cell_tracking_nogui( 'begin001/c1/', 'begin001/', 'begin001/masks/', 'begin001/out/', 'trajs_begin001.mat', 'xy1', 1, 2, 2, 20)

% matlabpool open
%global experiment

tic

%phasename
experiment.edit1 = 'xy1';
%flrfreq - sampling freq of fluorescent channels (relative to c1)?
experiment.edit2 = 2;

%output directory
experiment.outmat = 'trajs_begin001.mat';
% where mat file is written
experiment.outdir = '/Volumes/Storage/Expt_BB/expt12_aug8_2014/begin001/out/';
%directories where masks, phase contrast channel (c1), and fluorescent
%files are (c2, ...)
experiment.maskdir = '/Volumes/Storage/Expt_BB/expt12_aug8_2014/begin001/masks/';
experiment.phasedir = '/Volumes/Storage/Expt_BB/expt12_aug8_2014/begin001/c1/';
experiment.fluordir = '/Volumes/Storage/Expt_BB/expt12_aug8_2014/begin001/'; 
%sampling frequency (of phase contrast, c1)?  
imfreq=1;
%number of fluorescence channels (0 means just phase contrast).
fluornum=2;
%if the fluorescence channels are subsampled every nth c1 frame
blankflag = 1;
velocityfield = [];

experiment.parameters = getParameters_v5(experiment, fluornum);


[experiment.ObjectsByFrame] =  ObtainObjects_v6(experiment.parameters,blankflag);


'finished collecting objects'

[experiment.Traj, experiment.TrajInFrames] = makeTrajectoriesFromBinnedObjects(...
    experiment.ObjectsByFrame,velocityfield,experiment.parameters);

%   updateTrajTable(experiment)

Traj = experiment.Traj;
ObjectsByFrame = experiment.ObjectsByFrame;
TrajInFrames=experiment.TrajInFrames;
parameters=experiment.parameters;

% save([experiment.outdir,experiment.outmat],'Traj','ObjectsByFrame','TrajInFrames','parameters')
% 'wrote raw .mat file'

%%%%%% write the colored trajectory images %%%%%%%
colorOutputFlag.trajRGB=0; % colored trajectory images
colorOutputFlag.overlay=1; % colored trajectory images overlay with phase images
colorOutputFlag.overlayFluor=0; % colored trajectory images overlay with fluor images

%write trajectory output file
if(colorOutputFlag.trajRGB || colorOutputFlag.overlay || colorOutputFlag.overlayFluor)
    WriteColoredTrajectoryImages_v2(experiment.ObjectsByFrame,experiment.Traj,...
        experiment.TrajInFrames,experiment.parameters,experiment.outdir,colorOutputFlag)
end

%%%%%%% output Traj, ObjectsByFrame, etc into continuous trajectories
%%%%%%% with basic information

% load 

cutoffL = 400;

sizeTraj = zeros(length(Traj), 1);
for i=1:length(Traj)
    sizeTraj(i) = size(Traj{i},1);
end

cutoffTraj = cutoffL;

keepTrajs = sum((sizeTraj> cutoffTraj));
newTraj = cell(keepTrajs,1);

keepTrajID = zeros(keepTrajs, 2);
keepTrajID(:,1) = find(sizeTraj > cutoffTraj);
keepTrajID(:,2) = sizeTraj(keepTrajID(:,1));
    
%[frame, objnum, area, centroidX, centroidY, fluorMean, score, binX, binY]
for i=1:length(keepTrajID)
    
        k = keepTrajID(i, 1);
        newTraj{i} = zeros(keepTrajID(i,2), 9);
        newTraj{i}(:, [1,2,7:9]) = Traj{k};
        
        for clrn =1: parameters.numcolors
            FluorTraj{i,clrn} = zeros(keepTrajID(i,2), 12);
            FluorTraj{i,clrn}(:, [1,2]) = newTraj{i}(:, [1,2]); % [frame#, obj#]
        end       
        
        
        for j = 1:keepTrajID(i,2)
            newTraj{i}(j, 3:6) = ObjectsByFrame{Traj{k}(j,1)}(Traj{k}(j,2), [1:3,7]);
            
                    for clrn =1: parameters.numcolors 
                       fluorMean(clrn)=6+clrn;
                       fluorMeanLocal(clrn)=6+parameters.numcolors+clrn;
                       fluorAreaLocal(clrn)=6+2*parameters.numcolors+clrn;
                       fluorStdLocal(clrn)=6+3*parameters.numcolors+clrn;

                       fluorMeanTop50(clrn)=6+4*parameters.numcolors+clrn;
                       fluorAreaTop50(clrn)=6+5*parameters.numcolors+clrn;
                       fluorStdTop50(clrn)=6+6*parameters.numcolors+clrn; 

                       fluorMeanTop25(clrn)=6+7*parameters.numcolors+clrn;
                       fluorAreaTop25(clrn)=6+8*parameters.numcolors+clrn;
                       fluorStdTop25(clrn)=6+9*parameters.numcolors+clrn; 

                       FluorTraj{i,clrn}(j, 3:12) = ObjectsByFrame{Traj{k}(j,1)}(Traj{k}(j,2),[fluorMean(clrn) fluorMeanLocal(clrn) fluorAreaLocal(clrn) fluorStdLocal(clrn) fluorMeanTop50(clrn) fluorAreaTop50(clrn) fluorStdTop50(clrn) fluorMeanTop25(clrn) fluorAreaTop25(clrn) fluorStdTop25(clrn)]);
%                     [flr.Mean(clrn) flr.MeanLocal(clrn) flr.MeanTop50(clrn) flr.Max(clrn) flr.Total(clrn) flr.TotalTop50(clrn) flr.localArea(clrn) flr.MeanTop25(clrn)]);
            end
        end
end
            
 save([experiment.outdir,'output_', experiment.outmat],'newTraj','cutoffTraj', 'FluorTraj')
'wrote output .mat file'  

toc

% plotter_expt11
%end
