% rainSTORM_extras_z_loc
%
% THIS SCRIPT NEEDS CHECKING (22 / 12 / 2011 no time to validate)
%
% Determine Z-positions of fluorophores, based on optical system parameters
% (for the Holtzer-2007 model of astigmatic Gaussian optics) and the
% Row- and Col-widths of the PSFs, determined by rainSTORM. In fact we will
% process reviewedParams, which are determined by the rainSTORM_reviewer.
% This means that we can first apply quality control to the localised
% positions, before determining Z-positions.
%
% Units are nanometres
%

% Define input parameters (as Holtzer-2007 model)
mySig0  = 180;
myZR    = 400;
myGamma = 600;

% CCD pixel width - import in correct order and SCALE!
sigXsqr = ( reviewedParams(:,4).*pixelWidth ).^2;
sigYsqr = ( reviewedParams(:,5).*pixelWidth ).^2;

% Assume Z > -gamma, and determine z from sigXsqr
zOfX = (myZR/mySig0)*( sigXsqr - ones(size(sigXsqr)).*mySig0^2 ).^0.5 - myGamma;
% Assume Z < gamma,  and determine z from sigYsqr
zOfY= -(myZR/mySig0)*( sigYsqr - ones(size(sigYsqr)).*mySig0^2 ).^0.5 + myGamma;

fittedZ = ( zOfX + zOfY ) / 2;

% Exclude solutions which didn't fit the Z-assumptions above!
fittedZ( (zOfX>myGamma) | zOfY < -myGamma ) = [];

% Return fittedZ to workspace...

reviewedPositZ = fittedZ;