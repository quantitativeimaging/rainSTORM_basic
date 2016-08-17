function resid = findSecMoment(fibrilTrueRad,sigmaSqTotal, obsSigma)
% findSecMoment
%   Finds the residual of the second moment of the
%  super-resolved x-section of fluorescence density, given the 
%  fibril radius and the Gaussian blur due to localisation microscopy
%
% Assumptions
%   Cylindrical shell with uniform labelling probability
%   1D, z-invariant Gaussian localisation error (OK for 20 nm thick fibril)
%   Cross section is perpendicular to the cylinder axis
%   That the numerical model of the fibril uses a sufficiently fine grid
%   Ignoring end-effects of cylinder (x-section in middle somewhere)
%
% Comments:
%   This involved processing the reconstructed image x-section
%   Rather than the localised positions
%   In practice, this should allow inclusion of more fluorescent molecules
%    into the measured cross-section, so seems reasonable. 
%
%   Using this numerical model allows more complex geometries to be studied
%    fairly simply.


% 1. INPUTS
%    Read in the length scales of the mode

modelScale = 0.1;    % Nanometres
modelLimit = 150;    % Edge of simulation grid at +/1 this value, nm.
 
% Lengthscales:
% % fibrilTrueRad = 4.5; % nanometres. Argument fed to function.
% % sigmaLocError = 8;  % nanometres. Mean loc error in radial direction
% % sigmaVisual   = 4;  % nanometres. Mean sec moment of KDE visualisation
% % sigmaSqTotal  = sigmaLocError^2 + sigmaVisual^2;

% Define x-coordinates for simulation
xCentres  = -modelLimit: modelScale :+modelLimit;
xEdges = -(modelLimit+0.5*modelScale):modelScale: ...
         +(modelLimit+0.5*modelScale);

     
% 2. PROCESS


blurData = exp(-((xCentres.^2)./(2*sigmaSqTotal)) ); % Use same 1D grid...

% Fluorophore density. Zero outside fibril
nData = zeros(length(xCentres),1);   
% vData = zeros(length(xCentres),1); % Visualisation data

isInFibril = ( abs(xEdges(1:end-1)) <= fibrilTrueRad ) & ...
             ( abs(xEdges(2:end))   <= fibrilTrueRad );

indInFibril = find(isInFibril);
         
numInFibril = sum(isInFibril(:));

for lp = 1:numInFibril
    
   nData(indInFibril(lp)) = ...
               (2/pi)*( asin(xEdges(indInFibril(lp)+1)/fibrilTrueRad ) -...
                        asin(xEdges(indInFibril(lp)  )/fibrilTrueRad) );
end

vData = conv(nData, blurData,'same');

sumVData = sum(vData(:));

secMom = sum( (xCentres.^2).*vData' ) /sumVData ;

resid = abs( secMom - obsSigma^2 ); % Residual of fit to given observation

end