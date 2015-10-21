function PredictedObject = GetPredictedObject(BaseObject,velocityfield,curFrame,lastFrameObjectAppeared,params)
PredictedObject=BaseObject;
%update objects position based on the velocity field.
if(~isempty(velocityfield))       
        [PredictedObject(params.ON.CentroidX:params.ON.CentroidY)]=getUpdatedCentroidFromVelocityField(velocityfield,curFrame,...
            BaseObject(params.ON.CentroidX:params.ON.CentroidY),lastFrameObjectAppeared);
end