% rainSTORM_extras_z_cal
%
% This esimates the optical parameters of an astigmatic localisation
% microscope system, within the Holtzer-2007 model of astigmatic Gaussian
% beam optics.
%
% The input data is a stack of CCD images
% We also need input data stating the z-positions of each image 
% (The Z-data is not read in from a file - it must be correctly set as 
%  a vector in this script)
%
% NOTES
%
%  Refer to Holtzer, APPLIED PHYSICS LETTERS 90, 053902 (2007)
% SigZero = 0.4;      Minimum beam width (standard deviation at waist)
% ZR      = 0.5;      Depth of field
% Gamma   = 0.6;      Half the separation between astigmatic focal planes
%
%  This script uses lsqcurvefit, where:
%  fun = [refer to the above paper, equation 3]
%  x0 is initial guess of parameters: sigmaZero, zR and gamma
%  yData are Z-positions - a function of(x0, xData)
%  xData are corresponding processed values of sigmaX,sigmaY
%
% This script works in microns 



% 1. Input data
% Define z-positions corresponding to the observed PSF widths
% 
% Z-positions should be < 2 zR, for Holtzer's approximations to hold, and
% Z-positions should be within +/- gamma, for my (EJR's) preferred method
% Z-positions are in the term "zData", which in the documentation of the 
%   function lsqnonlin is actually the variable (yData)
zData = -0.6:0.05:0.6; 

% Read in PSF widths
% In the following line I import sigX and sigY from the reviewedParams
% matrix, which I will assume contains rows of parameters corresponding to
% the Z-positions defined above.
% Obviously, for sources of calibration data different from a stack of
% simulated images which correspond to the data import method I have 
% written here, this data import method will have to change radically.
%
% Note these are the SQUARES of the observed sigma values in X and Y
% Note that X- and Y- must be found from ROW- and COL- in a suitable way
sigXsqr = reviewedParams(:,4).^2;
sigYsqr = reviewedParams(:,5).^2;


% 2. Transform to Holtzer-2007 generalised variables 
% (This makes the calibration function a direct copy of his function)
sigRsqr  = sqrt( sigXsqr.*sigYsqr );      % Generalised Width
epsil    = ( sigYsqr ./ sigXsqr ).^(1/4); % Ellipticity

% Move this synthesised data into a matrix for the lsqcurvefit function
xData = [sigRsqr; epsil];

% Try using Levenberg-Marquadt to determine the system parameters
x0 = [0.9,0.9,0.9];    % Initial Guesses to fit [ sigmaZero, zR, gamma ]

options = optimset('lsqcurvefit'); % Don't ask! See lsqcurvefit
options = optimset (options, 'Algorithm', 'levenberg-marquardt', 'PrecondBandWidth', 0);
xx = lsqcurvefit(@my_zCalFunction,x0,xData,zData,[],[], options); % REVERSE ORDER?

% Print fitted variables to the MATLAB console
fittedSigmaZero = xx(1)
fittedZR        = xx(2)
fittedGamma     = xx(3)

% Provided these look reasonable, they can be set (manually) at the start
% of the Z-localisation script.
