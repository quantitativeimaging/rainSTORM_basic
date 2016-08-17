% rainSTORM_recon_JH
%
% 22 May 2013 Eric Rees
%
% Under Development
%
% FUNCTION
%   Plot a Jittered Histogram visualisation of Localisation Microscopy data
%   Make use of principles from [Silverman] and [Krizek] refs
%   
% MOTIVATION
%   Need an optimised method for plotting fluorophore density
%   Want to minimise user-supplied parameters (e.g. pixel size)
%   Consider using Simple Histogram as a Pilot Estimate 
%   Epanechnikov kernel might be better (Silverman)
%
% NOTES
%   A Jittered Histogram ~ a digitised Adaptive Kernel Density Estimate
%   The tweakable parameters (jhArbitFactor, jhAlpha) are partly able to 
%   compensate for the imperfect evaluation of the Thompson Precision
%   which is used as the baseline width for jittering
%
% FURTHER READING
%   D. Baddeley, (2010) doi:10.1017/S143192760999122X
%   P. Krizek, (2011) Vol. 19,  No. 4, OPTICS EXPRESS 3226
%   B. Silverman, Density Estimation Theory (CRC Press) pp. 100-110
%   E. Rees, (2012) http://www.optnano.com/content/1/1/12
%

function [figNewReconHandle, jhLinMag] = rainSTORM_recon_JH(reviewedPosits,reviewedParams,reviewedDeltaX)
% 0. FLOW CONTROL
flagPlotJH = 1;    % 1 to enable plotting of a reconstucted image


% 1. INPUTS

jhAlpha       = 0.5;   % See [Silverman, page 101 onwards]
jhArbitFactor = 0.85;  % For tweaking the jittering (kernel) width. Try 1
jhFinesse     = 0.85;   % Tweaks the pixel width of reconstruction. Try 1
jhNJitters    = 60;    % Number of Jitters per localisation
jhPilotCoarseness = 2; % To coarsen pilot estimate
flagJHBlur = 1;        % To blur pilot estimate by convolution w/ ones(3)

pixelWidth     = evalin('base','pixelWidth');
sizeOfCCDFrame = evalin('base','sizeOfCCDFrame');

% reviewedPosits
% reviewedParams
% reviewedDeltaX
% SupResIm      % Simple Histogram Pilot Estimate of fluorophore density
% ??            % Pixel width of pilot estimate
% flagSB        % Scalebar needed?
%               % Scalebar length
%               % Simple Histogram pixel width


% 2. PROCESS
%    Determine reconstruction pixel size and smoothing,
%    Calculate jittered histogram (JH) reconstruction
% DETERMINE RECONSTRUCTION PIXEL WIDTH:
% Try the nearest power of 2 nm below mean Precision, * jhFinesse to tweak
% (Issue: this will often be 16 or 32 nm in practice... Any problems?)
jhPixelWidthPow = floor(log2(jhFinesse*mean(reviewedDeltaX(:))));
jhPixelWidth    = 2^jhPixelWidthPow;

jhLinMag = pixelWidth/jhPixelWidth; % CCD pixel width / required width
jhLinMagPilot = jhLinMag / jhPilotCoarseness;

% Make a Simple Histogram image to get a pilot estimate of density
jhPilotIm = double( rainSTORM_recon(reviewedPosits, reviewedParams, ...
               jhLinMagPilot, sizeOfCCDFrame) );
if (flagJHBlur)
     jhPilotIm = conv2(jhPilotIm, ones(3), 'same'); % Blur the pilot estim
end

% Pre-allocate memory for adaptive kernel width estimation
% jhParams means "jittered histogram Parameters"
jhParams  = zeros(size(reviewedPosits,1),4); % N,f_pilot, Lambda, jhSig

% Find number of nearby localisations for each reviewedPosit
% Column 1 of jhParams is for "N"
for lpLoc = 1: size(reviewedPosits,1);
  myRow = ceil( reviewedPosits(lpLoc,1) * jhLinMagPilot );
  myCol = ceil( reviewedPosits(lpLoc,2) * jhLinMagPilot );
  jhParams(lpLoc,1) = jhPilotIm(myRow,myCol);  
end

% Find pilot probability distribution
numberAcceptedLocalisations = size(reviewedPosits,1);  % 
jhPilotF = jhParams(:,1)./numberAcceptedLocalisations; % Pilot prob density
jhParams(:,2) = jhPilotF;
jhG = geomean(jhPilotF);

% Calculate Local Bandwidth Factors:
jhLambda = (jhPilotF/jhG).^-jhAlpha; % varies on 0.4 to 1.4 in test run
% jhLambda(jhLambda > 2) = 2; % Doesn't seem helpful
jhParams(:,3) = jhLambda;

% Calculate Adaptive Kernel Widths
% These can act as std dev's for a (digitised) Gaussian Kernel
% An arbitrary scaling factor may be useful
jhKWidths = jhLambda .* mean(reviewedDeltaX,2) * jhArbitFactor;
jhParams(:,4) = jhKWidths;

% Create a jittered histogram image
jhImage = zeros(sizeOfCCDFrame * jhLinMag);     % Pre-allocate memory
for lpJts = 1:jhNJitters
    jtOffset = jhKWidths*ones(1,2);             % Envelope of offset
    jtOffset = jtOffset.*randn(size(jtOffset)); % In nm, randomised offset
    jtOffset = jtOffset./pixelWidth;            % In CCD pixel Widths
    
    jtPosits = reviewedPosits + jtOffset;
    
    jhImage = jhImage + double(rainSTORM_recon(jtPosits,reviewedParams, ...
               jhLinMag, sizeOfCCDFrame) );
end


% 3. OUTPUT
%    Visualise Jittered Histogram fluorophore density reconstruction
if(flagPlotJH)
    figNewReconHandle = rainSTORM_display(jhImage, jhLinMag);
end

flagCalculatedJH = 1; % Indicate a JH reconstructed image is available

% Assign useful outputs to base workspace, for easy inspection
assignin('base','flagCalculatedJH',flagCalculatedJH);
assignin('base','jhImage',jhImage);
assignin('base','jhParams',jhParams);
end