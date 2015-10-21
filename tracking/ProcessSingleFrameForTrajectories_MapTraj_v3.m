function [Traj,activeTraj,MapTraj,ObjCalcProps]=ProcessSingleFrameForTrajectories_MapTraj_v3(curFrame,Traj,TrajBin, PixelBin, activeTraj,ObjectsInCurrentFrame, PixelOfCurrentFrame,params)

NumberOfFramesToConsider=params.numOfPreviousFramesToConsider;

scoreCutoff=2.5;
    
[numOfObjectsInFrame,ONprops]=size(ObjectsInCurrentFrame);
ObjCalcProps=cell(numOfObjectsInFrame,1);

%Process each object in the current frame and find trajectories in the
%objects neighborhood located in the TrajBin.  Score each object
%against all located trajectories and store

for k=1:numOfObjectsInFrame  % parfor !!
    ObjCalcProps{k}=CalculateObjectProperties_v3(ObjectsInCurrentFrame(k,:), PixelOfCurrentFrame{k}, TrajBin, PixelBin, params);
end

%At this point the objects should have scored all the trajectories in their neighborhoods.  Of course objects in this frame
%Will have been scored by multiple trajectories, so now we need to
%go through all the objects and find the best match trajectory.  We
%will have to control for the case where two objects have the same
%trajectory as the best match.  In this case the best scoring object
%will be assigned to the trajectory and the poorer matching object will
%be kicked out and will go back to searching.  For objects with no best
%matching object new trajectories will started.


ObjectsToMatch=ObjectsInCurrentFrame(:,params.ON.Number);
MapTraj = zeros(1, length(ObjectsToMatch));

%keep computing until all Objects have been either assigned to a
%current trajectory or a new trjectory is made for them
while ~isempty(ObjectsToMatch)
    currentObject=ObjectsToMatch(end);
    
%     [currentObject, ObjectsInCurrentFrame(currentObject,params.ON.Number)]
    
    %check to make sure at least one trajectory score was made if
    %not add to a new trajectory.  Also make sure there are some active trajectories to
    %compare, if not start a new trajectory
    if(any(ObjCalcProps{currentObject}(:,params.CP.active)))
        
        active=ObjCalcProps{currentObject}(:,params.CP.active);
        
        %%%%%%%%%%%%%####################%%%%%%%%%%%%%%%%%%%%%%
        %
        %
        %
        score1=ObjCalcProps{currentObject}(:,params.CP.score);
        overlaparea = ObjCalcProps{currentObject}(:,params.CP.overlap);
        score2 = ObjCalcProps{currentObject}(:,params.CP.sumscore);
        % [score1, overlaparea, score2];
        BestMatchScore=min(score2(logical(active)));
        %
        %
        %
        %
        
        %Make sure that the trajectory with the best score is
        %above the score cutoff, if not start a new trajectory
        if(BestMatchScore<scoreCutoff)
            
            %Determine the best match index from the best match score.
            %Note there is a case when two trajectories have the same score
            %they will both come back as matching the best match index.
             %The second part of the comparison makes sure only the active
            %one is chosen. Also choose the first BestMatchIndex for
            %the case when there are two identical scores and both are
            %active
            
            %%% CP.score to CP.sumscore
            BestMatchIndex=find(ObjCalcProps{currentObject}(:,params.CP.sumscore)==BestMatchScore &...
                ObjCalcProps{currentObject}(:,params.CP.active)==1,1);
            %%%
            BestMatchTraj=ObjCalcProps{currentObject}(BestMatchIndex,params.CP.trajNumber);
            %Determine if the best matching trajectory already
            %has a matching object assigned to it.  If not
            %assign this object and remove it from the search
            
            [endIndex numOfTN]=size(Traj{BestMatchTraj});
            if(Traj{BestMatchTraj}(endIndex,params.TN.frame) ~= curFrame)
                Traj{BestMatchTraj}(endIndex+1,params.TN.frame)=curFrame;
                Traj{BestMatchTraj}(endIndex+1,params.TN.object)=ObjectsInCurrentFrame(currentObject,params.ON.Number);
                %%%
                Traj{BestMatchTraj}(endIndex+1,params.TN.score)=ObjCalcProps{currentObject}(BestMatchIndex,params.CP.sumscore);
                
                               
                MapTraj(ObjectsInCurrentFrame(currentObject,params.ON.Number)) = BestMatchTraj;
                
                ObjectsToMatch=RemoveObjectFromMatchGroup(ObjectsToMatch,ObjectsInCurrentFrame(currentObject,params.ON.Number));
                
            else
                %The best match trajectory already had a object
                %assigned, determine if the current object is a
                %better match.  If so swap objects, if not
                %remove this trajectory from the active list
                %and keep searching
                
                %%%
                if(Traj{BestMatchTraj}(endIndex,params.TN.score)<ObjCalcProps{currentObject}(BestMatchIndex,params.CP.sumscore))
                    ObjCalcProps{currentObject}(BestMatchIndex,params.CP.active)=0;
                else
                    previousObjectNumber=Traj{BestMatchTraj}(endIndex,params.TN.object);
                    
                    Traj{BestMatchTraj}(endIndex,params.TN.object)=ObjectsInCurrentFrame(currentObject,params.ON.Number);
                    %%%
                    Traj{BestMatchTraj}(endIndex,params.TN.score)=ObjCalcProps{currentObject}(BestMatchIndex,params.CP.sumscore);
                    MapTraj(ObjectsInCurrentFrame(currentObject,params.ON.Number)) = BestMatchTraj;
                    
                    ObjectsToMatch=RemoveObjectFromMatchGroup(ObjectsToMatch,ObjectsInCurrentFrame(currentObject,params.ON.Number));
                    %%%
                    [ObjectsToMatch,ObjCalcProps]=AddObjectToMatchGroup(ObjectsToMatch,ObjCalcProps,params.CP,previousObjectNumber,BestMatchTraj);
                end
                
            end
            %At this point the object has failed to generate a
            %best match trajectory, assign a new trajectory to
            %the object
        else
            [Traj,activeTraj]=InsertNewTraj(Traj,params.TN,ObjectsInCurrentFrame(currentObject,params.ON.Number),activeTraj,curFrame);
            MapTraj(ObjectsInCurrentFrame(currentObject,params.ON.Number)) = size(Traj,1);
            ObjectsToMatch=RemoveObjectFromMatchGroup(ObjectsToMatch,ObjectsInCurrentFrame(currentObject,params.ON.Number));
        end
    else
        [Traj,activeTraj]=InsertNewTraj(Traj,params.TN,ObjectsInCurrentFrame(currentObject,params.ON.Number),activeTraj,curFrame);
        MapTraj(ObjectsInCurrentFrame(currentObject,params.ON.Number)) = size(Traj,1);
        ObjectsToMatch=RemoveObjectFromMatchGroup(ObjectsToMatch,ObjectsInCurrentFrame(currentObject,params.ON.Number));
    end
end
MapTraj;
%Find all trajectories that have not generated a hit in the specified
%time frame and effectively end the trajectory
%%%
[activeTraj]=PruneFromActiveTrajListBin(Traj,params.TN,curFrame,activeTraj,NumberOfFramesToConsider);
activeTraj;

%TrajInFrames{curFrame}=activeTraj;