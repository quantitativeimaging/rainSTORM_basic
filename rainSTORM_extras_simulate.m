% rainSTORM_extras_simulate_3D_BW
%
% 2011 November 29  pseudo-3D_STORM_SIMULATION from Black and White object
%  Simulate some frames for astigmatic 3D storm...  
% See    C:\Documents and Settings\ejr36\My
% Documents\Projects\2011_3D_Anisotropic_STORM\2011_11_29_3Dstorm

% Eric Rees
% 2D work on ERF()-matrix method by Mark Deimund
%
% Simulate a stack of anisotropic (3D) localisation microscopy data.
% This simulation uses our usual dSTORM assumptions: temporally independent
% frames, and randomly-activated fluorophores that persist for a duration
% of exactly one frame.
% It also assumes elliptical Gaussian PSFs, after Holtzer-2007:
%
% Refer to Thompson-2002 method:
% Biophysical Journal Volume 82 May 2002 2775–2783
%
% Holtzer-2007 Gaussian beams [APPLIED PHYSICS LETTERS 90, 053902 2007]
%
% The units in this script (used implicitely) are nanometres
% 16 nm per true-object pixel, 160 nm per CCD pixel
% Beware if other scripts use microns (mine often do - EJR)
%
% Outline:
% 1. Import "crossed lines" as the "true object"
%    This script assumes a black (0) and white (>0) true object
%    Greyscale true objects can be simulated using small edits, if needed
% 2. Determine the "true" fluorophore positions in x-y
%    Assign some z-positions (first try a pseudo-2D inclined plane)
% 3. Simulate some noise-free images using a 2D Gaussian allocation
% 4. Add (optionally) Gaussian and/or Poisson noise
% 5. Save each image sequentially
% 
% ImageJ can then be used to compile the stack into a multipage .tif
%
% NOTES FOR SUCCESSFUL USE OF THIS SCRIPT
%
% Memo: in 2D we could use simple conv2, but for a Z-dep Gaussian, we'll
% need something more sophisticated. One approach that could work would be
% to allocate individual PSFs.
% 
% Avoid simulating objects whose psfs will overfill their input image size!
% This script will fail if it tries to allocate signal beyond the border o
% the CCD (which equals the true object area). Will try to fix later.
%
% New users will want to edit file output directory (do find: imwrite )


% 0. Set flags to control the algorithm
close all
rng('shuffle')               % Start a random number sequence (see 'rng')

flag1p               = 0;    % Simulate a single dye molecule
flag2D               = 0;    % True: all z-posits = 0. False: 'inclined' Z

flagSaveTifs         = 1;    % Save grayscale tif frames
flagShowCCDImages    = 1;    % Show simulated frame on screen (slow)

flagGaussianNoise    = 1;    % Add Gaussian "camera noise" to ccdSignal
flagPoissonNoise     = 0;    % Add Poisson "background noise" to ccdSignal
flagQuantumPoisson   = 1;    % Convert expected photon number to Poisson variate. Simulates quantum behaviour

% saveDir = 'C:\Documents and Settings\ejr36\My Documents\...
%  Work_Papers\2013JoOptics\Matlab\image'
% saveDir = 'C:\Users\user\simulations\lines\sim\';
saveDir = 'C:\Users\user\simulations\calm\sim\';

% 1. Import a "true object" and set parameters
%readDir  = ''%'C:\Users\user\simulations\calm\';
readDir  = 'C:\Users\user\simulations\calm\';
% readFile = 'crossed_lines2.png'; 
readFile = 'calm_bw.png'
% C:\Documents and Settings\ejr36\My Documents\Projects\2011_3D_Anisotropic_STORM\2011_11_29_3Dstorm\crossed_lines.png
readIn   = [readDir, readFile];

trueObj = imread(readIn);
trueObj = trueObj(:,:,1); % Really I want a black-and-white object

pxObj    = 5;      % nm per pixel for true object, 16 fills the frame
rescale  = 32;     % (Use an Integer) # of true object pixels per CCD pixel
pxCCD    = pxObj*rescale;  % nm width of CCD pixels
ccdEdgesRow = 0:pxCCD:pxObj*size(trueObj,1);
ccdEdgesCol = 0:pxCCD:pxObj*size(trueObj,2);

numberOfImages     = 50;      % How many simulated images do we want?
 dyeFraction        = 0.000034;   % Probability a given dye is "on". Indep!! 
%  dyeFraction   =  0.1;
dyePhotons         = 1000;
noiseGaussianMean  = 100;
noiseGaussianSigma = 10;
noisePoissonMean   = 0;

simSig2D   = 160;      % (2D) Define PSF shape for simulated data...
simSigZero = 160;      % (3d) Define values for simulated data...
simZR      = 500;      % nanometers for all of these...
simGamma   = 600;

% USE THESE PARAMETERS IN THE MODEL EQUATION (Holtzer 2007):
% sigXsqr = ((simSigZero/simZR)^2) *(yData+simGamma).^2 + simSigZero^2;
% sigYsqr = ((simSigZero/simZR)^2) *(yData-simGamma).^2 + simSigZero^2;


% 2. Determine (or define) the dye locations in [Row,Col], and Z
% Assume dyes stick in the centre of the hi-res pixels

if(flag1p) % For a 1-molecule simulation, overwrite the input picture...
  trueObj = zeros(32);
  % trueObj(19,19)=1; % One dye
  % Two dyes:
  trueObj(17,23)=1;
  trueObj(24,12)=1;
  
  pxObj    = 80;    % nm per pixel for true object, 16 fills the frame
  rescale  = 2;     %(Use an Integer) # of true object pixels per CCD pixel
  pxCCD    = pxObj*rescale;  % nm width of CCD pixels
  ccdEdgesRow = 0:pxCCD:pxObj*size(trueObj,1);
  ccdEdgesCol = 0:pxCCD:pxObj*size(trueObj,2);
  
  dyeFraction    = 1; % For a single molecule, set it to be always on
end

trueObjBW = ( trueObj >= 1 ); % This is a "black and white" object

[dyeObPosRow, dyeObPosCol] = find(trueObjBW);

% Determine Z-positions of dye molecules
if(flag2D) % (i) Simulate a flat plane of Z-positions: a 2D object
  trueObjZ = zeros(size(trueObj)); % All dyes are in the plane Z = 0
else   
           % (ii) Alternatively, simulate something with 3D detail
           % Define Z-positions by putting the object on an inclined plane
  trueObjRows = size(trueObj,1);
  Zincrement  = 750/(trueObjRows - 1);
  trueObjLine = -375:Zincrement:375;
  trueObjZ    = flipud( (ones(size(trueObj,2),1)*trueObjLine)' );
end
  % Extract the vector of Z-positions from "image matrix" trueObjZ
  dyeObPosZ   = trueObjZ(sub2ind(size(trueObj),dyeObPosRow,dyeObPosCol));


% 3. Simulate the images, using subsets of dyes, then get ccd
% images. Also need some way to visualise this as an image stack

figure(1)
colormap(gray)

tic % Start timing how long it takes to simulate a stack of images
for lpIm = 1:numberOfImages    
  
  dyeIsActive = rand(size(dyeObPosRow));     % "Activate" a subset of dyes
  dyeIsActive = (dyeIsActive < dyeFraction);
  dyeIndexes  = find(dyeIsActive);
  
  imageCCD     = zeros( ceil( size(trueObj)./(rescale) ) );

  % For each dye glowing in the current frame:
  for loopDyes = 1:length(dyeIndexes); % Add photons for each dye in frame

      if(flag2D)
       mySigRow = simSig2D; % Circular Gaussian PSF, for 2D
       mySigCol = simSig2D;
      else
       myZ = dyeObPosZ(dyeIndexes(loopDyes));
       sigXsqr = ((simSigZero/simZR)^2) *(myZ+simGamma).^2 + simSigZero^2;
       sigYsqr = ((simSigZero/simZR)^2) *(myZ-simGamma).^2 + simSigZero^2;
       mySigRow = sqrt(sigYsqr);
       mySigCol = sqrt(sigXsqr); % This determines the PSF ellipticity
      end
      
      % Allocate signal from this dye onto the CCD grid
      % Use a reasonable analytical approximation...
      % First find relative CCD grid distances
      % "-0.0 used to be -0.5, for registration..."
      myPosRow = (dyeObPosRow(dyeIndexes(loopDyes)) -0.0)*pxObj;
      myPosCol = (dyeObPosCol(dyeIndexes(loopDyes)) -0.0)*pxObj; % Dye position in nm
      myCcdEdgeRow = find(ccdEdgesRow == max(ccdEdgesRow(ccdEdgesRow < myPosRow)) );
      myCcdEdgeCol = find(ccdEdgesCol == max(ccdEdgesCol(ccdEdgesCol < myPosCol)) );
      relCcdEdgesRow = (myCcdEdgeRow-4:myCcdEdgeRow+5)*pxCCD - myPosRow;
      relCcdEdgesCol = (myCcdEdgeCol-4:myCcdEdgeCol+5)*pxCCD - myPosCol;
      
      % Determine amount of psf in each pixel using vectorised format
      thisDyeSignal = (10000).*...  % Try handling numbers near 1
            ( erf(relCcdEdgesRow(2:10)/(mySigRow)) - erf(relCcdEdgesRow(1:9)/(mySigRow)) )'*...
            ( erf(relCcdEdgesCol(2:10)/(mySigCol)) - erf(relCcdEdgesCol(1:9)/(mySigCol)) );
       
      % Allocate signal photons to each pixel in proportion to psf fraction
      totalPsfSignal = sum(thisDyeSignal(:));
      thisDyeSignal = thisDyeSignal./totalPsfSignal; % Normalise
      thisDyeSignal = thisDyeSignal*dyePhotons;      % Photons in ccd pixels
 
      thisDyeSignal = floor(thisDyeSignal);
      
      if(flagQuantumPoisson)
       % Thompson-2002 converts expected photon number to a Poisson variate
       % This simulates Quantum Mechanical photon statistics 
       % It worsens localisation precision (physically realistically)
       thisDyeSignal = uint16(thisDyeSignal);
       thisDyeSignal = imnoise(thisDyeSignal, 'poisson');
       thisDyeSignal = double(thisDyeSignal);
      end
      
      % Commented 2016 April
%       imageCCD(myCcdEdgeRow-4:myCcdEdgeRow+4, ...
%                myCcdEdgeCol-4:myCcdEdgeCol+4) = ...
%       imageCCD(myCcdEdgeRow-4:myCcdEdgeRow+4, ...
%                myCcdEdgeCol-4:myCcdEdgeCol+4) + thisDyeSignal;
           
      % Added 2016 - April - bodge to prevent simulation outside CCD crash
      for lpRR = 1:size(thisDyeSignal, 1)
        for lpCC = 1:size(thisDyeSignal, 2)
            RR = myCcdEdgeRow + lpRR - 5;
            CC = myCcdEdgeCol + lpCC - 5;
            if(RR>0 && CC>0 && RR<=size(imageCCD,1) && CC <= size(imageCCD,2))
                imageCCD(RR,CC) = imageCCD(RR,CC) + thisDyeSignal(lpRR,lpCC);
            end
        end
      end 
      
  end % Have now simulated image of all "active" dyes in this frame
  
% Now add camera (Gaussian) and shot (Poisson) noise to simulated data  
  if(flagGaussianNoise)
    % Note the use of "floor" to quantise integer numbers of photons
    W = ones(size(imageCCD))*noiseGaussianMean + floor(noiseGaussianSigma*randn(size(imageCCD)) );
    imageCCD = imageCCD + W;
  end
    
  if(flagPoissonNoise) 
    % Note the use of "uint16" to set integer scale for noise
    B = imnoise(uint16( noisePoissonMean*ones(size(imageCCD)) ),'poisson');
    imageCCD = uint16(imageCCD) + B;
  end
  
    
 imageCCD(imageCCD<0) = 0;        % Let negative noisy intensities = 0
  
  % Save image as a tif 
  if(flagSaveTifs)
  imageCCD = uint16(imageCCD); % Vista Preview dislikes 16-bit.. ImageJ OK
  tifName = [saveDir,int2str(lpIm),'.tif'];
  % Write as tif. Note that "append" mode is N^2 slow; avoid if possible.
  imwrite(imageCCD,tifName,'tif'); %,'writemode', 'append'); 
  % Don't use 'writemode', 'append' - stacking in ImageJ is faster
  end
  
  if(flagShowCCDImages)
  figure(1)            % NOTE THAT DISPLAYING IMAGES ON SCREEN IS SLOW!
  imagesc(imageCCD)
  end
  
  waitbar(lpIm/numberOfImages)
end     % Have now simulated one CCD image
toc     % Have now simulated a stack of dSTORM images. Stack them in ImageJ
