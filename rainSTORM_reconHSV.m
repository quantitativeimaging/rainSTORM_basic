function [myRgbIm] = rainSTORM_reconHSV(SupResPosits,SupResParams,linMag,sizeOfFrame)
% Copyright 2012. Refer to 00_license.txt for details.

nRows = sizeOfFrame(1)*linMag;  % Size of super-resolution reconstruction
nCols = sizeOfFrame(2)*linMag; 
SupResIm = uint16(zeros(nRows,nCols)); % 2^16 is unlikely to overflow

myPosits = SupResPosits*linMag; % Scale localisations to super-res grid
myPosits = ceil(myPosits);      % Digitise localisations to super-res grid

for lpSRI = 1:size(myPosits,1)
  SupResIm( myPosits(lpSRI,1)  , myPosits(lpSRI,2)  ) = ...
  SupResIm( myPosits(lpSRI,1)  , myPosits(lpSRI,2)  ) +1;
  % Elementwise binning. Not very elegant, I admit.
end % End of allocating dyes to pixels of the reconstruction

% Compute confidence image:
SupResConf = double(zeros(nRows,nCols));

deltaX = rainSTORM_precision(SupResParams);

for  lpSRI = 1:size(myPosits,1)
SupResConf( myPosits(lpSRI,1)  , myPosits(lpSRI,2)  ) = ...
SupResConf( myPosits(lpSRI,1)  , myPosits(lpSRI,2)  ) + deltaX(lpSRI);
% Add deltaX to each pixel.
end

% Normalise per localisation:
SupResConf = SupResConf./double(SupResIm);
SupResConf(isnan(SupResConf)) = 0;
SupResConf = min((20./SupResConf),1); % Divide so that fits less than this precision are scaled
assignin('base','SupResConf',SupResConf);

myHsvIm = zeros(640,640,3);
myHsvIm(:,:,1) = SupResConf;
myHsvIm(:,:,2) = 1;
myHsvIm(:,:,3) = min((SupResIm/20),1);
myRgbIm = hsv2rgb(myHsvIm);

end % End of rainSTORM_reconHSV function, for STORM image reconstruction