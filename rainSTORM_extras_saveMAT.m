% rainSTORM_extras_saveMAT
% Eric Rees
%
% Version 1-0, 12 Sept 2011
%
% Purpose: to save all the outputs from rainSTORM that are required for
% subsequent analysis, so that you do not have to run the image processing
% method (with the same paramters) again. This is a stand-alone script, so
% it expects the required information to be in the MATLAB workspace.
%
% Obviously we could just use 'save('myData') but this would also save some
% unnecessary, memory-hogging image matrixes that we can remake from the
% localisation data
%
% The next trick will be to load this data into Matlab, and make it
% available to run the rainSTORM reviewer GUI. This is potentialy tricky, 
% since we don't want to create conflicts with the normal method for 
% starting the rainSTORM GUI. I think we do need to send a command to
% enable the reviewer (for simplicity, the user should ensure the rainSTORM
% GUI has already been started).
%


% REQUIRED INPUTS.
% THESE MUST BE AVAILABLE IN THE MATLAB WORKSPACE
% Most of these are saved, but myFrame is only converted to sizeOfMyFrame, 
% The filename of the input data is also used to set the save destination
% 
% SupResDeltaX    % Localisation precisions **(run reviewer to generate)**
% SupResNumber    % Number of accepted localisations 
% SupResParams    % Accepted localisation parameters
% SupResPosits    % Accepted localisation [row,col] positions
% Thresh          % Threshold used to find acceptable localisations
% alg             % Fitting algorithm used ('1' is Gaussian fitting)
% allowSig        % Width (Gaussian sigma) of acceptable localisations
% allowX          % Maximum allowed centre-position drift of localisations 
% filename        % Filename of input data (e.g. 'myData.tif' ]
% initSig         % Initial guess of Gaussian width
% initX0          % Initial guess of position - should be zero
% linMag          % Create this many super-res rows/cols per CCD row/column
% maxIts          % Iterate Gaussian fitting this many times
% myFrame         % Need to know the size of the CCD (but not the image)
%
% numberOfFiles   % This means number of frames of data ('Files' is legacy)
% rad             % Fitting ROI is a square of size -rad:+rad, e.g. -3:3
% scaleBarLn      % The Scalebar is this many CCD pixels wide
% sizeOfCCDFrame  % Size of CCD image used for STORM (rows,cols)


% DESCRIPTION OF SAVED LOCALISATION PARAMETERS (from _LocGF3 fitting)
% 
% SupResPosits: One row per localisation
%               1st Column contains row-position of localisations
%               2nd Column contains column-position of localisations
%
% SupResParams: One row per localisation
%               1st Column contains signal magnitude (sum of 3x3 ROI data)
%               2nd Column contains a TOL value (fit residue/norm of data)
%               3rd Column contains sum of ROI signal counts, after
%                 background subtraction [estimated as min(myROI(:)) ]
%               4th Column contains SigX, fitted sigma in ROW-direction
%               5th Column contains SigY, fitted sigma in COL-direction
%               6th Column contains std(myFrame(:)), for Thompson precision
%               7th Column contains the frame number, for post-analysis
%
% SupResDeltaX: One row per localisation
%               1st Column: Thompson Precision estimate in Row direction
%               2nd Column: Thompson Precision estimate in Col direction


myFileOut = [filename,'_data.mat']; % I think "filename" contains a path


save(myFileOut, ...
    'SupResNumber', 'SupResParams', 'SupResPosits', 'Thresh', 'alg', ...
    'allowSig', 'allowX', 'filename', 'initSig', 'initX0', 'linMag', ...
    'maxIts', 'numberOfFiles', 'rad', 'scaleBarLn', ...
    'sizeOfCCDFrame', 'SupResDeltaX')


