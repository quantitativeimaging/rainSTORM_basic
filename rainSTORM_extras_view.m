%  THIS IS NO LONGER A FUNCTION THAT IS CALLED - IT IS A STANDALONE SCRIPT
%  function [SupResIm,Im2] = rainSTORM_extras_view(SupResPosits,linMag,sizeOfFrame)

sizeOfFrame = size(myFrame);

flagImTK = true; % If true, use imclose in Matlab Im Processing toolkit
flagRSIC = false;  % Else, if imclose is unavailable, substitute this

myPosits = SupResPosits*linMag; % Digitise localisations, on a denser grid
% myPosits(:,1) = myPosits(:,1) - floor(min(myPosits(:,1)));
% myPosits(:,2) = myPosits(:,2) - floor(min(myPosits(:,2)));
% nRows = ceil(max(myPosits(:,1))); % Rows in reconstruction image
% nCols = ceil(max(myPosits(:,2))); % Cols in reconstruction image
nRows = sizeOfFrame(1)*linMag; 
nCols = sizeOfFrame(2)*linMag; 

SupResIm = uint16(zeros(nRows,nCols)); % 2^16 is unlikely to overflow

for lpSRI = 1:size(myPosits,1)
  SupResIm(ceil(myPosits(lpSRI,1) ),ceil(myPosits(lpSRI,2) )) = ...
  SupResIm(ceil(myPosits(lpSRI,1) ),ceil(myPosits(lpSRI,2) )) +1;
  % Elementwise binning. Not very elegant, I admit.
end % End of allocating dyes to pixels of the reconstruction

SupResIm = flipud(SupResIm); % Flip image up-down, for scatterplot overlay

% Plot some visualisations of the localised dye positions
figure
% subplot(1,3,1)   % Scatterplot of raw locations - slow for 100k+ points
%  scatter(SupResPosits(:,2),-SupResPosits(:,1),'xk')
%  title('Scatterplot of localisations')
%  xlabel('pixel');
%  ylabel('pixel');
subplot(1,2,1)
 imagesc(SupResIm)           % Binned density image, as determined above
 colormap('hot');
 title('Binned image');
 xlabel('pixel*linMag');
 ylabel('pixel*linMag');
if(flagImTK)                 % If we want to use imclose, in Image toolkit
subplot(1,2,2)
 se = strel('square',3);     % Fillhole structuring element
 Im2 = imclose(SupResIm,se); % Density image, filled
 imagesc(Im2)
 colormap('hot');
 title('3 by 3 fillhole post-processing (imclose)');
 xlabel('pixel*linMag');
 ylabel('pixel*linMag');
elseif(flagRSIC)             % Else use my substitute imclose function
subplot(1,2,2)
 Im2 = rainSTORM_smooth(SupResIm);
  imagesc(Im2)
 colormap('hot');
 title('3 by 3 fillhole post-processing (rainSTORM smooth)');
 xlabel('pixel*linMag');
 ylabel('pixel*linMag');
end
 
%  end % End of rainSTORM_view function