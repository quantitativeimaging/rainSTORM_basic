% Non-stable function if used, since not enough SupResParams are found
function [myFits,myParams] = rainSTORM_fitFB(myFrame,myPixels,rad,initSig)

myFits = -ones(size(myPixels,1),2);   % [row col] matrix for each candidate
r = rad;                     % Use a (2r+1) by (2r+1) square ROI
bkSig= std(double(myFrame(:)));    % Standard deviation (for FB thresholding)
sigmaFB  = initSig;            % Need guess of Gaussian PSF sigma: in pixel-widths

for lpPx = 1:size(myPixels,1); % For local maxima in descending order
myRow = myPixels(lpPx,1);
myCol = myPixels(lpPx,2);
myROI = myFrame(myRow-r:myRow+r,myCol-r:myCol+r); 
myROI = myROI - min(myROI(:));  % Get square centred on maximum; remove background

threshFB = 0.2*bkSig;    % Consider only pixels with apparently-good signal

[rowFB,colFB] = find(myROI > threshFB);
posRowFB = rowFB - (r+1);     % Position from centre of (r+1,r+1) pixel
posColFB = colFB - (r+1);

B = zeros(length(rowFB),3); % B-matrix for Fluoro-Bancroft
B(:,1) = rowFB;
B(:,2) = colFB;
B(:,3) = 1;

Bdagger = ((B'*B)^-1)*B';   % 'pinv' command takes much longer

Q = [ 1,0,0; 0,1,0 ]; % Q just extracts x0,y0 - see Andersson 2007 paper

%Calculate Psquared and Alpha. Need to obtain paired elements 
%(ex: (1,1),(2,2) ) for (rowFB,colFB), so need to use diagonal only.
% Psquared = (2*(sigmaFB^2)).*log(double( diag(myROI(rowFB,colFB)) ));
% Alpha = ( posRowFB.^2 + posColFB.^2 + Psquared )/2;

Alpha = zeros(size(rowFB)); % Should vectorise the following loop
  for lpALPH = 1:length(Alpha);
    Psquared = 2*(sigmaFB^2)*log(double( myROI(rowFB(lpALPH),colFB(lpALPH)) ));
    Alpha(lpALPH) = double( posRowFB(lpALPH)^2 + posColFB(lpALPH)^2 + Psquared )/2;
  end

solution = ( Q * Bdagger * Alpha );

x0 = solution(1); % Dye position relative to middle of centre pixel
y0 = solution(2); % 

myFits(lpPx,:) = [(double(myRow)+x0),(double(myCol)+y0)];

end

fits = isnan(myFits);
myFits(fits(:,1)== 1,:) = [];   % Remove NaN fits

myFits = myFits(myFits(:,1)>0,:); % Return accepted fits only. (-1)s are rejected fits.
myFits = myFits(myFits(:,2)>0,:);
myFits = myFits(myFits(:,1)<=64,:);
myFits = myFits(myFits(:,2)<=64,:);

myParams = zeros(length(myFits),7);

end % End of Fluoro-Bancroft function