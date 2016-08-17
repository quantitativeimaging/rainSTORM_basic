% rainSTORM_extras_batchProcess
% Copyright 2012. Refer to 00_license.txt for details.
%
% A script, designed for Version 2-10, to process several files using
% identical parameters, and save the results. 
% 
% Image processing parameters are read from the 'base' workspace. 
% To make sure they are available, run rainSTORM and Reviewer, or add them
% to the workspace
%
% 2011_11_08: This script is not yet tested.
% 2013_01_09: Edited to call functions instead of local code. Tested.
%             Seems to run OK on a test directory with 2 RAW files.

%
% Target files are "all RAW files in a user-chosen directory" although 
% we could alternatively write a list manually at the start of this script
%
% Applies rainSTORM to each file of the chosen fileType in the folder
% Uses quality control parameters set during the most recent run through
% Saves Sum, Hist, reconstructed images + text
%
% Instructions:
% 
% 1. Manually edit "fileType" if processing TIF, not RAW files
% 2. Run rainSTORM, Reviewer, and plot Hists once for the first image stack
% 3. Run this script
% 4. The user should choose a single file from the target directory
% 5. All RAW image files in the same folder should be processed

% 0.
% Set some input parameters (caxis for recon)
myCaxis  = [0 50];
fileType = '*.tif';

% 1.
% Acquire image processing parameters from 'base' workspace
% These could be set manually, or could have been assigned already.
% For a script, Evalin() are unnecessary, if running in 'base' workspace
% But for a function, which may be a future development, these are needed
initX0 = evalin('base','initX0');
initSig = evalin('base','initSig');
rad = evalin('base','rad');
tol = evalin('base','tol');
Thresh = evalin('base','Thresh');
maxIts = evalin('base','maxIts');
flagSB = evalin('base','flagSB');
alg = evalin('base','alg');
flagSum = evalin('base','flagSum');
pixelWidth = evalin('base','pixelWidth');
newThresh = evalin('base','newThresh');
newTol = evalin('base','newTol');
newSig = evalin('base','newSigma');
newPrecision = evalin('base','newPrecision');
newFrames = evalin('base','newFrames');

scaleBarLn = evalin('base', 'scaleBarLn'); % # CCD Pixels for 1 micron bar
linMag = evalin('base', 'reconstructionScaleFactor');  % E.g. 10 

% 2. 
% Get a list of input files
% The user should choose a single file from the target directory
% Need to know filename (inc path), and extension.
myPaths = {'C:\dSTORMdat\2014_Gabi_aSyn\100d_p_09_feb_2012cells\' , ...
           'C:\dSTORMdat\2014_Gabi_aSyn\2012_02_15_alphaSynCells_c\' ,...
           'C:\dSTORMdat\2014_Gabi_aSyn\2012_02_15_alphaSynCells_d\' ,...
           'C:\dSTORMdat\2014_Gabi_aSyn\2012_02_15_alphaSynCells_pd\' ,...
           'C:\dSTORMdat\2014_Gabi_aSyn\2012_02_28_alphaSyn\' ,...
           'C:\dSTORMdat\2014_Gabi_aSyn\2012_02_28_alphaSyn\Cells_09-02-12_d50\' ,...
           'C:\dSTORMdat\2014_Gabi_aSyn\2012_02_28_alphaSyn\Cells_09-02-12_d50_p\' ,...
           'C:\dSTORMdat\2014_Gabi_aSyn\2012_02_28_alphaSyn\Cells_09-02-12_p\' ,...
           'C:\dSTORMdat\2014_Gabi_aSyn\2012_03_01_alphaSynCells\cells_09-02-12_c\' ,...
           'C:\dSTORMdat\2014_Gabi_aSyn\2012_03_01_alphaSynCells\cells_09-02-12_d100\' ,...
           'C:\dSTORMdat\2014_Gabi_aSyn\2012_03_06_alphaSynCells\100d_p_09_feb_2012cells\' ,...
           'C:\dSTORMdat\2014_Gabi_aSyn\2012_03_06_alphaSynCells\Controls_16_02_2012\' ,...
           'C:\dSTORMdat\2014_Gabi_aSyn\2012_05_01_alphaSynCells\24h_control\' ,...
           'C:\dSTORMdat\2014_Gabi_aSyn\2012_05_01_alphaSynCells\24h_ProteosomeInhibitorOnly\' ,...
           'C:\dSTORMdat\2014_Gabi_aSyn\Controls_16_02_2012\'};

for lpDirs = 1:length(myPaths)

   PathName = myPaths{lpDirs}
    
% [FileName,PathName,FilterIndex] = uigetfile();
listOfFiles = dir( [PathName fileType] ); % Try .RAW for DM. Edit for .TIF

% 3. 
% Apply rainSTORM to each file, save Sum/Hist/dataImage/processedImage
for lpFiles = 1:length(listOfFiles)

filename = listOfFiles(lpFiles).name; % Select an input file.
  if( not(strcmp(filename(end-8:end), 'stack.tif')) )
    continue % Don't process files unless they end 'stack.tif'
  end
  filename
ext = filename(end-3:end);
filename = [PathName, filename(1:end-4)];
% Note that rainSTORM_main__GUI_both will overwrite 'filename' in 'base'
% This is nearly an example of the problems caused by global variables!

% Run rainSTORM script (not parallel, TIF or RAW input)
rainSTORM_main_GUI_both(filename,ext,initX0,initSig,rad,tol, ... 
    Thresh,maxIts,flagSB,alg,flagSum,pixelWidth);
% Note that rainSTORM_main__GUI_both will overwrite 'filename' in 'base'
close all; % (Don't want a stack of preliminary figures building up).

% 3b. 
% Run Reviewer to apply quality control parameters
% rainSTORM_reviewer writes SupResIm (and more) to base workspace
rainSTORM_reviewer(newThresh,newTol,newSig,newPrecision,SupResParams, ... 
    SupResPosits,myFrame,flagSB,newFrames);

figNewReconHandle = rainSTORM_display(SupResIm, linMag);

caxis(myCaxis);

% 3c. 
% Create Hists, and save Sum image
% (Update this by copying from Reviewer
flagHistsPlotted = rainSTORM_histograms(0);

% 4. 
% Save the results (super-resolution images, histogram, metadata): 
flagSaved = 0; 
flagSaved = rainSTORM_save( flagSaved ); % 

close all; % Close on-screen reconstructions and histograms

end % End of image processing operations for each target file

% End of script for processing one directory
end % Next directory