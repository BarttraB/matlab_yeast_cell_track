function img = writeIntToImg(img, xlist, ylist, klist, rgbCol)

%persistent bInit imgnumlib imgnumlibMask baseDir pixelWidth pixelHeight pixelHeight_h maxPixel
persistent bInit imgnumlib imgnumlibMask pixelWidth pixelHeight pixelHeight_h maxPixel


if (isempty(bInit))
    bInit = true;
    
    %baseDir = './numimg/';
    
    for ii=0:9
        %imgnumlib{ii+1} = imread(strcat(baseDir,sprintf('numcharimg%g.tif',ii)));
        imgnumlib{ii+1} = imread(sprintf('numcharimg%g.tif',ii));
        imgnumlibMask{ii+1} = 1.0-(imgnumlib{ii+1}./max(max(imgnumlib{ii+1})));
        
        %         max(max(imgnumlib{ii+1}))
    end
    
    SZ = size(imgnumlib{1});
    pixelHeight = SZ(1);
    pixelWidth = SZ(2);
    pixelHeight_h = floor(pixelHeight/2.0);
    
    maxPixel = 255;
    
    display('writeIntToImg Initialized');
end





INDS = min([length(xlist) length(ylist) length(klist)]);
for IND=1:INDS
    x=xlist(IND);
    y=ylist(IND);
    k=klist(IND);
    
    
    
    
    
    
    
    
    % make k a positive integer
    k = floor(abs(k));
    
    
    
    MAXMAG = 12;
    
    
    
    
    chars = zeros(MAXMAG);
    gb = 10;        % base 10
    lastNonZero = 1;
    for mag = 1:MAXMAG
        r = mod(k,gb);
        k = (k-r)/gb;
        
        if (r>0)
            bstart=true;
        end
        
        chars(mag) = r;
        
        
        % keep track of lastNonZero
        if (r>0)
            lastNonZero = mag;
        end
    end
    chars = chars(1:lastNonZero);
    % chars
    
    
    
    
    
    
    
    % img = img .* 0.0;
    
    
    LL = length(chars);
    pixelNumWidth = LL*pixelWidth;
    pixelNumWidth_h = floor(pixelNumWidth/2.0);
    
    
    xleft = floor(x-pixelNumWidth_h);
    ytop = floor(y-pixelHeight_h);
    
    
    
    imgSZ = size(img);
    xleft = min(max(xleft,1),imgSZ(2)-pixelNumWidth);
    ytop = min(max(ytop,1),imgSZ(1)-pixelHeight);
    
    
    
    for ii=1:LL
        ichar = chars(ii);
        
        ilow = ytop;
        jlow = xleft + pixelWidth*(LL - (ii-1) - 1);
        ihigh = ilow+pixelHeight-1;
        jhigh = jlow+pixelWidth-1;
        
        
        for ccol=1:3
            img(ilow:ihigh,jlow:jhigh,ccol) = min(maxPixel, ...
                img(ilow:ihigh,jlow:jhigh,ccol).*imgnumlibMask{ichar+1} + rgbCol(ccol).*imgnumlib{ichar+1} );
        end
        
    end
    
    
    
    
    
end    % going through list



end

