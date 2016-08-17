function [SupResIm] = rainSTORM_recon(SupResPosits,SupResParams,linMag,sizeOfFrame)
% rainSTORM_recon
% Copyright 2012. Refer to 00_license.txt for details.
%  Creates a simple histogram visualisation using localised positions
%  Note that the input arguments can be supplied as reviewedPosits etc.

nRows = ceil(sizeOfFrame(1)*linMag);   % Size of super-res reconstruction
nCols = ceil(sizeOfFrame(2)*linMag);   % Ceil() allows awkward scalings
SupResIm = uint16(zeros(nRows,nCols)); % 2^16 is unlikely to overflow

myPosits = SupResPosits*linMag; % Scale localisations to super-res grid
myPosits = ceil(myPosits);      % Digitise localisations to super-res grid

for lpSRI = 1:size(myPosits,1)
  if ( myPosits(lpSRI,1)<1 || myPosits(lpSRI,2)<1 || ...
       myPosits(lpSRI,1)>nRows || myPosits(lpSRI,2)>nCols )
    continue; % Skip over positions if they are outside reconstruction (JH)
  end
    
  SupResIm( myPosits(lpSRI,1)  , myPosits(lpSRI,2)  ) = ...
  SupResIm( myPosits(lpSRI,1)  , myPosits(lpSRI,2)  ) +1;
  % Elementwise binning. Not very elegant, I admit.
end % End of allocating dyes to pixels of the reconstruction
 
end % End of rainSTORM_recon function, for STORM image reconstruction