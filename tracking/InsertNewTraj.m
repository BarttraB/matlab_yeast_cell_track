function [Traj,activeTraj]=InsertNewTraj(Traj,TN,ObjectToInsertNumber,activeTraj,frame)
NumOfNewTraj=length(Traj)+1;
%ObjectToInsertNumber
% Traj{NumOfNewTraj}(1).frame=frame;
% Traj{NumOfNewTraj}(1).object=ObjectToInsertNumber;
% Traj{NumOfNewTraj}(1).score=NaN;

Traj{NumOfNewTraj}(1,TN.frame)=frame;
Traj{NumOfNewTraj}(1,TN.object)=ObjectToInsertNumber;
Traj{NumOfNewTraj}(1,TN.score)=NaN;

activeTraj(end+1)=NumOfNewTraj;
