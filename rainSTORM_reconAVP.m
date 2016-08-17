function [Image] = rainSTORM_reconAVP(SupResPosits,SupResParams,linMag,sizeOfFrame)
% Copyright 2012. Refer to 00_license.txt for details.

nRows = sizeOfFrame(1)*linMag;  % Size of super-resolution reconstruction
nCols = sizeOfFrame(2)*linMag; 
SupResImHist = uint16(zeros(nRows,nCols)); % 2^16 is unlikely to overflow

myPosits = SupResPosits*linMag; % Scale localisations to super-res grid
myPosits = ceil(myPosits);      % Digitise localisations to super-res grid

for lpSRI = 1:size(myPosits,1)
  SupResImHist( myPosits(lpSRI,1)  , myPosits(lpSRI,2)  ) = ...
  SupResImHist( myPosits(lpSRI,1)  , myPosits(lpSRI,2)  ) +1;
  % Elementwise binning. Not very elegant, I admit.
end % End of allocating dyes to pixels of the reconstruction

SupResImPrec = uint16(zeros(nRows,nCols)); % 2^16 is unlikely to overflow
deltaX = rainSTORM_precision(SupResParams);

for lpSRI = 1:size(myPosits,1)
  SupResImPrec( myPosits(lpSRI,1)  , myPosits(lpSRI,2)  ) = ...
  SupResImPrec( myPosits(lpSRI,1)  , myPosits(lpSRI,2)  ) + deltaX(lpSRI,1);

end % End of allocating dyes to pixels of the reconstruction
 
% Divide sum of precisions by histogram image to produce a confidence
% image.
    Image = (100*SupResImHist./SupResImPrec);
    
    
    assignin('base','SupResImHist',SupResImHist);
    assignin('base','SupResImPrec',SupResImPrec);
end % End of rainSTORM_recon function, for STORM image reconstruction