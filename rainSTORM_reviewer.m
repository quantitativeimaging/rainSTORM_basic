% rainSTORM_reviewer 
%   Copyright 2012. Refer to 00_license.txt for details.
%   Eric Rees, and GUI developed initially by Mark Deimund
%
% FUNCTION
%   A function to apply Quality Control to Localisation Microscopy data
%   And then create the required Visualisation of the data
%   This function can be run via the "Reviewer" GUI
%
% USING THIS SCRIPT:
%   Use this function after running rainSTORM_main on some data,
%   Which may produce ~10000+ SupResPosits and corresponding SupResParams.
%
% NOTES
%   This script reviews Localisation data, then calls an image
%     reconstruction
%   Reviewing parameters permits tightening of acceptance parameters
%     (such as threshold, tolerance, allowSig).
%   This obviates re-running the (5 min) image analysis algorithm
%   But this script only reviews fitted data, 
%     so only higher Threshold       (new Thresh)
%     or smaller tolerance           (newTol)
%     or a narrower range of widths  (newSig)
%     will have any effect on the SupResPosits that are accepted.
%
%   A new sub-pixel resolution is defined for the visualisation  (linMag)
%   A scale bar length (in CCD pixels) is defined (scaleBarLn)
%
% FURTHER READING
%   Rees et al. Optical Nanoscopy 1:12
%
% REQUIRED INPUTS - 
% these must be available:
% 
% SupResPosits  % [Rows, Cols] of localisations, with sub-pixel resolution
% SupResParams  % [Threshold, Tolerance, Total counts, SigX] 
% scaleBarLn    % e.g. scaleBarLn = 8.33; % For 2 micro-m, at 240 nm/Px
% linMag        % e.g. linMag = 10; % But we could redefine this here
% size(myFrame) % e.g. [64 64]

function yy=rainSTORM_reviewer(newThresh,newTol,newSig,newPrecision,SupResParams,SupResPosits,myFrame,flagSB,newFrames)

reconstructionScaleFactor = evalin('base','reconstructionScaleFactor');
algVisual = evalin('base','algVisual');

% newThresh = New threshold 
% newTol = New tolerance (*almost* identical to _fitLM method)
% newSig = New acceptable range of widths for Gaussian fits
% flagSB = If true, plot scalebar


% Compute precision in fitted positions, in [row-direction, col-direction]
[SupResDeltaX,nPhotons] = rainSTORM_precision(SupResParams);

% Use the mean Thompson precision for 2D quality control
% For 3D, let us change this and apply the precision limit to both axes
% deltaX = mean(SupResDeltaX,2); 

% Review localisation parameters to choose good localisations
% 
% SupResParams(:,1): Is a 3x3 spot brighter than a threshold? AND
% SupResParams(:,2): Is the residual of the Gaussian fit small enough? AND
% SupResParams(:,4): Is the Gaussian Std Dev in the row direction in range,
% SupResParams(:,5): Is the Gaussian Std Dev in the col direction in range,
% SupResDeltaX(:,1): Is the Thompson Precision estimate precise enough- row
% SupResDeltaX(:,2): Is the Thompson Precision estimate precise enough- col
% SupResParams(:,7): Is the localisation from a wanted CCD frame number?
% 
qualityApprovedRows = ( (SupResParams(:,1)>newThresh) &...
                        (SupResParams(:,2)<newTol) &...
                        (SupResParams(:,4)>newSig(1) ) &...
                        (SupResParams(:,4)<newSig(2) ) &...
                        (SupResParams(:,5)>newSig(1) ) &...
                        (SupResParams(:,5)<newSig(2) ) &...
                        (SupResDeltaX(:,1)<newPrecision) &... 
                        (SupResDeltaX(:,2)<newPrecision) &...
                        (SupResParams(:,7)>=newFrames(1) ) &...
                        (SupResParams(:,7)<=newFrames(2) )  ... 
                       );

reviewedPosits = SupResPosits( qualityApprovedRows,: ); % All Columns
reviewedParams = SupResParams( qualityApprovedRows,: );
reviewedDeltaX = SupResDeltaX( qualityApprovedRows,: );

reviewedPhotonNums = nPhotons( qualityApprovedRows,: );


meanRevDeltaX = mean(reviewedDeltaX); % Mean precision in reconstruction
stdRevDeltaX  = std(reviewedDeltaX);  % Std Dev of precisions- poor metric?
SparrowThompsonLimit = 2*sqrt(mean(reviewedDeltaX.^2)) % Apprx 'resolution'

% Reconstruct an image using the reviewed localisations
% The following line creates a "Simple Histogram Image"
[SupResIm] = rainSTORM_recon(reviewedPosits,reviewedParams, ...
               reconstructionScaleFactor,size(myFrame)); 

% Now either plot the "Simple Histogram Image"
% Or create and plot the "Jittered Histogram Image" 
if(algVisual == 1)         
  figNewReconHandle =rainSTORM_display(SupResIm,reconstructionScaleFactor);
elseif(algVisual == 2)
  [figNewReconHandle, jhLinMag] = rainSTORM_recon_JH(reviewedPosits, ...
                        reviewedParams,reviewedDeltaX);
  reconstructionScaleFactor = jhLinMag; % Keep recent value updated in base
end
   
numberOfFits = size(SupResPosits,1);
densestPoint = max(SupResIm(:));

%Write variables to main workspace.
assignin('base','SparrowThompsonLimit',SparrowThompsonLimit);
assignin('base','SupResDeltaX',SupResDeltaX); % Check this works
assignin('base','SupResIm',SupResIm);
assignin('base','densestPoint',densestPoint);
assignin('base','figNewReconHandle',figNewReconHandle);
assignin('base','meanRevDeltaX',meanRevDeltaX);
assignin('base','newThresh',newThresh);
assignin('base','newTol',newTol);
assignin('base','newSigma',newSig);
assignin('base','newPrecision',newPrecision);
assignin('base','newFrames',newFrames);
assignin('base','numberOfFits',numberOfFits);
assignin('base','qualityApprovedRows',qualityApprovedRows);
assignin('base','reconstructionScaleFactor',reconstructionScaleFactor);
assignin('base','reviewedPosits',reviewedPosits);
assignin('base','reviewedParams',reviewedParams);
assignin('base','reviewedDeltaX',reviewedDeltaX);
assignin('base','reviewedPhotonNums',reviewedPhotonNums);
assignin('base','stdRevDeltaX',stdRevDeltaX);

end