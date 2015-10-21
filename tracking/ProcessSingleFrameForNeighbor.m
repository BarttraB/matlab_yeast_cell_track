function [CurrFrameNeighbors]= ProcessSingleFrameForNeighbor(curFrame,Traj,TrajBin, activeTraj, ObjectsInCurrentFrame,params)
% [NeighborProps{j}]= ProcessSingleFrameForNeighbor(j,Traj,TrajBin,TrajInFrames{j},ObjectsContainedInFrames{j},params);
  

%%%% NOTE, curFrame & Traj & activeTraj are not used right now. Probably
%%%% use them if considering the overlap.

[numOfObjectsInFrame,ONprops]=size(ObjectsInCurrentFrame);
CurrFrameNeighbors=cell(numOfObjectsInFrame,1);

%Process each object in the current frame and find trajectories in the
%objects neighborhood located in the TrajBin.  Score each object
%against all located trajectories and store

parfor k=1:numOfObjectsInFrame 
    CurrFrameNeighbors{k}=CalculateNeighborProperties(ObjectsInCurrentFrame(k,:),TrajBin,params);
end



