#include "mex.h"
#include <math.h>

/*  the gateway routine.  */
void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[] ) {
    
    mxArray *tO, *ON;
    double  *score, *cTx, *cTy, *cOx, *cOy, *aT, *aO, *eO, *eT, *orO, *orT, AvDiam, alpha, beta, epsilon, gamma, tmp, *otc, *ptr_tO;
    int ON_cx, ON_cy, ON_a, ON_e, ON_o , *dTj;
    const double angleNorm=1.0/90;
    mwIndex i;
    size_t m, n, numOfElements;
    
    tO = prhs[0];
    otc = mxGetPr(prhs[1]);
    AvDiam = *mxGetPr(prhs[2]);
    alpha = *mxGetPr(prhs[3]);
    beta = *mxGetPr(prhs[4]);
    epsilon = *mxGetPr(prhs[5]);
    gamma = *mxGetPr(prhs[6]);
    ON = prhs[7];
    
    ON_cx=*mxGetPr(mxGetField(ON, 0, "CentroidX"))-1;
    ON_cy=*mxGetPr(mxGetField(ON, 0, "CentroidY"))-1;
    ON_a=*mxGetPr(mxGetField(ON, 0, "Area"))-1;
    ON_e=*mxGetPr(mxGetField(ON, 0, "Eccentricity"))-1;
    ON_o=*mxGetPr(mxGetField(ON, 0, "Orientation"))-1;
    
    //get a pointer to the trajectory array
    ptr_tO=mxGetPr(tO);
    //mexPrintf("ON CX %d, ON CY %d, ON Area %d, ON Ecc %d, ON Ori %d \n",ON_cx,ON_cy,ON_a,ON_e,ON_o);
    
    //Find the values for the object to compare
    cOx=&otc[ON_cx];
    cOy=&otc[ON_cy];
    aO=&otc[ON_a];
    eO=&otc[ON_e];
    orO=&otc[ON_o];
    
    //mexPrintf("Obj Area %f,Cx %f, Cy %f, Ecc %f, Ori %f \n", aO,cOx,cOy,eO,orO);
    // note first dimension is rows, second is cols;
    dTj = mxGetDimensions(tO);
    
    plhs[0] = mxCreateDoubleMatrix(dTj[0], 1, mxREAL);
    score = mxGetPr(plhs[0]);
//     for (i=0;i<(dTj[0]*dTj[1]);i++){
//         mexPrintf("tO value %f \n",ptr_tO[i]);
// }
    for (i=0;i<dTj[0];i++){
        //Find values for the current scored trajectory        
        aT=&ptr_tO[i+ON_a*dTj[0]];
        cTx=&ptr_tO[i+ON_cx*dTj[0]];
        cTy=&ptr_tO[i+ON_cy*dTj[0]];
        eT=&ptr_tO[i+ON_e*dTj[0]];
        orT=&ptr_tO[i+ON_o*dTj[0]];
        
        //mexPrintf("Traj Area %f,Cx %f, Cy %f, Ecc %f, Ori %f \n", *aT, *cTx, *cTy, *eT, *orT);
        
        score[i] = (alpha/(pow(AvDiam, 2)))*(pow((*cOx-*cTx), 2)+ pow((*cOy-*cTy), 2));
        score[i] += (beta*fabs(*aO-*aT))/(0.5*(*aO+*aT));
        score[i] += epsilon*fabs(*eO-*eT);
        
        //orientation: scale by average eccentricity.  Ie if cells are circular (eccentricity of zero)
        //the orientation measurement will be inherently poor.  The max angle difference between objects is 90
        //that can be distiguished.  Normalize to 1/90 so the difference ranges between zero and one.  To make
        //the metric symmetric we need to take the min of either the two angles subtracted from each other or from 180.
        tmp=fabs(*orO-*orT);
        if(tmp < 90){
            score[i] += gamma*(0.5*(*eO+*eT))*angleNorm*(tmp);
            //tmp2 = angleNorm;
            //mexPrintf("orientation diff less %f score %f \n", tmp,tmp2);
        }else{
            score[i] += gamma*(0.5*(*eO+*eT))*angleNorm*(180-tmp);
            //mexPrintf("orientation diff greater %f score %f \n", tmp,tmp2);
        }
    }
}

    