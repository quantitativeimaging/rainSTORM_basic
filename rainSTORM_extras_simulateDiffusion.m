% rainSTORM_extras_simulate_3D_BW
% Eric Rees 17 May 2013  
%
% Later Edits
%   None yet
%
% Function
%   Simulates molecular diffusion imaging data for Localisation Microscopy
%   Modified from rainSTORM_extras_simulate.m in V2.32
%
% Motivation
%   Demonstrate and explore forward-simulation of diffusion imaging
%   Generate data for validation and testing of diffusion analysis methods
%
% Further Reading
%   Einstein 1905 Brownian Motion
%   Thompson 2002 Biophys J 
%   Savin and Doyle 2005 Biophys J
%   Crocker and Grier 199(2)
%
% Outline of this program
%   0. Flow Control
%   1. Define input: one or more static or moving molecules, and CCD size
%   2. Simulate molecular diffusion imaging data
%   3. Outputs: TIFs
% 
% Notes
%   The folder of individual TIFs can be assembled into a stack by ...
%     dropping the folder onto the ImageJ bar.
%   Molecules can drift off-camera in a slightly non-physical way.
%     For now, avoid generating this kind of data by keeping dyes mid-CCD.
%   The dimensions used in this simualtion are nanometres and seconds
%   A later simulation will consider time-correlated fluorescence
%   The hard-coded boxcar window in the PSF simulation is a flaw
%     But it seems insignificant for the default widths !!


% 0. Set flow control for the simulation
close all                    % Close figures
rng('shuffle')               % Start a random number sequence (see 'rng')

% Initial conditions
flagOneMol           = 1;    % Setup simulation with one dye molecule
flagTwoMol           = 0;    % Alternative. Simulation of 2 molecules
flagMultiMol         = 0;    % Alternative. Simulation of many molecules
flagMultiMolBrowDis  = 0;    % Alternative. Multi mols, distinct D's
flagTimeCorrBlinks   = 0;    % Alternative. See below for details. 

% Purely in-loop simulation conditions
flagBrownianConst    = 1;    % Molecule(s) move with Brownian diffusion

% 3D options
flag2D               = 1;    % True: all z-positions are zero

% Output options
flagSaveTifs         = 0;    % Save grayscale tif frames
flagShowCCDImages    = 1;    % Show simulated frames on screen (IS SLOW!)

writeFile = 'C:\simulations\2013_DiffusionSims\image'; % Save images here


% 1. Initialise simulation parameters

% Instrument Properties
numberOfImages       = 100;    % How many frames of data to simulate?
simSig2D             = 160;    % Define 2D PSF, by std dev of 2D circ Gaus

flagGaussianNoise    = 1;    % Add Gaussian "camera noise" to ccdSignal
flagPoissonNoise     = 0;    % Add Poisson "background noise" to ccdSignal
flagQuantumPoisson   = 1;    % Convert expected photon number to a Poisson 
                             % variate. Simulates quantum behaviour

% Fluorescence Properties
  dyeFraction        = 1;      % Fraction of time spent in "bright" state
% dyeFraction        = 0.1;    % Blinking

dyePhotons           = 1000;   % Expected photons captured per whole frame
noiseGaussianMean    = 100;    % d.c. background level of camera (counts)
noiseGaussianSigma   = 10;     % std dev of noise is 'b' in Thompson-2002
noisePoissonMean     = 0;      % Best set to zero for simplicity

% Diffusion or dynamic properties
dyeBrownianD         = 1E6;    % Diffusivity (Brownian), nm^2/s
cameraCycleTime      = 0.040;  % Camera cycle time, seconds

brownianSigX         = sqrt(2*dyeBrownianD*cameraCycleTime); % in each Dim!


% The following section sets up a one-molecule simulation, with:
%   Molecule Position
%   Camera grid size
if(flagOneMol) 
  simGridSize  = [64, 64];       % size of a "Simulation Grid" space 
  pxSimGrid    = 160;            % nm per unit of "Simulation Grid"

  rescale  = 1;                  % rescale simulation grid to camera pixels
  pxCCD    = pxSimGrid*rescale;  % nm width of CCD pixels
  ccdGridSize = simGridSize./rescale;
  
  ccdEdgesRow = 0 : pxCCD : pxSimGrid*simGridSize(1);
  ccdEdgesCol = 0 : pxCCD : pxSimGrid*simGridSize(2);  

  dyeObPosRow = 33;
  dyeObPosCol = 31;
end

% The following section sets up a two-molecule simulation, with:
%   Molecule Positions
%   Camera grid size
if(flagTwoMol) 
  simGridSize  = [128, 128];       % size of a "Simulation Grid" space 
  pxSimGrid    = 160;            % nm per unit of "Simulation Grid"

  rescale  = 1;                  % rescale simulation grid to camera pixels
  pxCCD    = pxSimGrid*rescale;  % nm width of CCD pixels
  ccdGridSize = simGridSize./rescale;
  
  ccdEdgesRow = 0 : pxCCD : pxSimGrid*simGridSize(1);
  ccdEdgesCol = 0 : pxCCD : pxSimGrid*simGridSize(2);  

  dyeObPosRow = [43, 45];
  dyeObPosCol = [80, 80];
end

% The following section sets up a multi-molecule simulation
%   Random Molecule Positions within the middle of the field of view
%   Camera grid size
if(flagMultiMol) 
  simGridSize  = [64, 64];       % size of a "Simulation Grid" space 
  pxSimGrid    = 160;            % nm per unit of "Simulation Grid"

  rescale  = 1;                  % rescale simulation grid to camera pixels
  pxCCD    = pxSimGrid*rescale;  % nm width of CCD pixels
  ccdGridSize = simGridSize./rescale;
  
  ccdEdgesRow = 0 : pxCCD : pxSimGrid*simGridSize(1);
  ccdEdgesCol = 0 : pxCCD : pxSimGrid*simGridSize(2);  
  
  numberOfMolecules = 6;
  
  dyeObPosRow = 10 + rand( numberOfMolecules , 1)*40;
  dyeObPosCol = 10 + rand( numberOfMolecules , 1)*40;
end

% The following section sets up
%   Some molecules at random positions
%   And this setup is meant to be used with a time-correlated blinking 
%   behaviour, designed below. 
if (flagTimeCorrBlinks)
  simGridSize  = [64, 64];       % size of a "Simulation Grid" space 
  pxSimGrid    = 160;            % nm per unit of "Simulation Grid"

  rescale  = 1;                  % rescale simulation grid to camera pixels
  pxCCD    = pxSimGrid*rescale;  % nm width of CCD pixels
  ccdGridSize = simGridSize./rescale;
  
  ccdEdgesRow = 0 : pxCCD : pxSimGrid*simGridSize(1);
  ccdEdgesCol = 0 : pxCCD : pxSimGrid*simGridSize(2);  
  
  numberOfMolecules = 6;
  
  dyeObPosRow = 10 + rand( numberOfMolecules , 1)*40;
  dyeObPosCol = 10 + rand( numberOfMolecules , 1)*40;
  
  dyePersistenceChance = 0.5; % Probability an active dye continues
end




% Determine Z-positions of dye molecules. This may be needed for 3D.
if(flag2D)
  dyeObPosZ = zeros( size(dyeObPosRow) ); % 2D simulation uses z = 0
end


% 2. Simulate Images
% 3. Images are saved as the last step within each loop of simulation

figure(1)
colormap(gray)

tic % Start timing how long it takes to simulate a stack of images
for lpIm = 1:numberOfImages    
  
  dyeChance   = rand(size(dyeObPosRow));  % Random number for each dye
 % Determines which fluoresce
  if(flagTimeCorrBlinks)
      dyeActive = ( (dyeChance < dyeFraction) | ...
                    (dyeChance < dyePersistenceChance) );
  else 
      dyeActive = (dyeChance < dyeFraction);  
  end
  
  dyeIndexes  = find(dyeActive);          % Index of fluorescent dyes
  
  imageCCD     = zeros( ccdGridSize ); % Setup empty camera measurement

  % Now generate the image of each dye which is fluorescing:
  for loopDyes = 1:length(dyeIndexes); 

      if(flag2D)            % Circularly-symmetric Gaussian PSF, for 2D
       mySigRow = simSig2D; 
       mySigCol = simSig2D;
      end
      
      myPosRow = (dyeObPosRow(dyeIndexes(loopDyes)) -0.0)*pxSimGrid;
      myPosCol = (dyeObPosCol(dyeIndexes(loopDyes)) -0.0)*pxSimGrid; % nm
      % Avoid simulating molecules that are off-camera
      if( myPosRow < 0 || myPosCol < 0)
         continue;  % Skip to the next dye 
      end
      % Allocate signal from this dye onto the CCD grid
      % Use a reasonable analytical approximation...
      % First find relative CCD grid distances
      % "-0.0 used to be -0.5, for registration..."
      myCcdEdgeRow = find(ccdEdgesRow == max(ccdEdgesRow(ccdEdgesRow < myPosRow)) );
      myCcdEdgeCol = find(ccdEdgesCol == max(ccdEdgesCol(ccdEdgesCol < myPosCol)) );
      relCcdEdgesRow = (myCcdEdgeRow-4:myCcdEdgeRow+5)*pxCCD - myPosRow;
      relCcdEdgesCol = (myCcdEdgeCol-4:myCcdEdgeCol+5)*pxCCD - myPosCol;
      
      % Neglect molecules in or beyond camera border, to avoid errors
      % The following is an imperfect method
      % Recall localisation microscopy may fail in the image border anyway
      % And note the following is really to prevent the simulation stopping
      % And you should verify plausible data is simulated, by eye
      if( myCcdEdgeRow(1) <5 || ...
          myCcdEdgeCol(1) <5 || ...
          myCcdEdgeRow(end)>ccdGridSize(1)-4 || ...
          myCcdEdgeCol(end)>ccdGridSize(2)-4       )
          continue  % Skip to the next dye
      end
      
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
      
      imageCCD(myCcdEdgeRow-4:myCcdEdgeRow+4, ...
               myCcdEdgeCol-4:myCcdEdgeCol+4) = ...
      imageCCD(myCcdEdgeRow-4:myCcdEdgeRow+4, ...
               myCcdEdgeCol-4:myCcdEdgeCol+4) + thisDyeSignal;
      
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
  
  % Save image as a TIF, if required
  if(flagSaveTifs)
    imageCCD = uint16(imageCCD); 
    tifName = [writeFile,int2str(lpIm),'.tif'];
    imwrite(imageCCD,tifName,'tif');  
    % SLOW ALTERNATIVE, if you must create the stack in MATLAB
    % imwrite(imageCCD,tifName,'tif','writemode', 'append'); % SLOW!
  end
  
  if(flagShowCCDImages)
    % figure(1)           
    imagesc(imageCCD)
  end
  
  % Update molecule positions due to Diffusion (or other motion):
  % The first option is for Brownian motion, and all molecules have equal D
  if(flagBrownianConst)
      dyeObPosRow = dyeObPosRow + ...
          randn(size(dyeObPosRow)) * (brownianSigX/pxSimGrid);
      dyeObPosCol = dyeObPosCol + ...
          randn(size(dyeObPosCol)) * (brownianSigX/pxSimGrid);
  end
  
  waitbar(lpIm/numberOfImages)
end     % Have now simulated one CCD image
toc     % Have now simulated a stack of dSTORM images. Stack them in ImageJ
