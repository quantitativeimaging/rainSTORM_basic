function [SupResIm] = rainSTORM_reconIP(SupResPosits,SupResParams,linMag,sizeOfFrame)
% Copyright 2012. Refer to 00_license.txt for details.

nRows = sizeOfFrame(1)*linMag;  % Size of super-resolution reconstruction
nCols = sizeOfFrame(2)*linMag; 
SupResIm = uint16(zeros(nRows,nCols)); % 2^16 is unlikely to overflow

myPosits = SupResPosits*linMag; % Scale localisations to super-res grid
myPosits = ceil(myPosits);      % Digitise localisations to super-res grid

fitPrecision = rainSTORM_precision(SupResParams);
intensity = SupResParams(:,1) ./ fitPrecision;

for lpSRI = 1:size(myPosits,1)
  SupResIm( myPosits(lpSRI,1)  , myPosits(lpSRI,2)  ) = ...
  SupResIm( myPosits(lpSRI,1)  , myPosits(lpSRI,2)  ) + intensity(lpSRI,1);

end % End of allocating dyes to pixels of the reconstruction
 
end % End of rainSTORM_recon function, for STORM image reconstruction