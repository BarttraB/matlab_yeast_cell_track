function [activeTraj]=PruneFromActiveTrajListBin(Traj,TN,curFrame,activeTraj,NumberOfFramesToConsider)
%function [activeTraj,TrajBin,Traj]=PruneFromActiveTrajListBin(Traj,TN,TrajBin,ObjectsContainedInFrames,ON,curFrame,activeTraj,NumberOfFramesToConsider,binSize,velocityfield)

%This variable is necessary because deleting spots in an array (see below)
%also shortens the array.  When shortened the index variable i will
%eventually run out of bounds
curTraj=activeTraj;

for i=1:length(curTraj)

    TrajToProcess=Traj{curTraj(i)};

    %Determine if the last frame in the trajectory is outside the frame
    %limits to consider.  If yes then discard trajectory, if not add to the
    %Trajectory Bin for the next time step.
    [endIndex numOfTN]=size(TrajToProcess);
    if(TrajToProcess(endIndex,TN.frame)<=(curFrame-NumberOfFramesToConsider))      
        activeTraj(activeTraj==curTraj(i))=[];
    end
end