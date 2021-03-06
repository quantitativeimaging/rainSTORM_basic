% rainSTORM main script 
% Copyright 2012. Refer to 00_license.txt for details.
% Eric Rees. Development version of PALM/STORM code: version 1.12
% Modified for GUI by Mark Deimund
% 
% Method
% This script performs these operations on a stack of STORM data:
% 0. READ DATA
%    Opens a multi-page tiff, of say 10000 frames each of 64x64 pixels.
%    Then performs localisation (steps 1-3) one frame at a time.
% 1. SEGMENTATION [Ref 1,2].   Function: rainSTORM_avNMS
%    Averaging and non-maximum suppression. 
%    Finds possible images of single molecules.
%    Ignores the image border within which centres can't be well fitted
% 2. THRESHOLD 
%    Neglects weak images (weak signals or high noise)
%    Lists and sorts local maxima - this is for readers' convenience.
% 3. FITTING                   Function: rainSTORM_fitLM
%                              Function: rainSTORM_fitLocGF3
%    Fits centre positions to remaining images (Nonlin least squares 
%    Gaussian, or an alternative like Fluoro-Bancroft or Max Likelyhood)
%    Latest for version 1-10 is fitLocGF3: Gaussian Fit, local background
%    subtraction, and Halt each frame after 3 rejected fits.
%    JUDGING                   
%    Accepts or rejects each fit depending on its residue and width
%    Good fits have small residues, and widths appropriate to the optics.
% 4. RECONSTRUCTION.           Function: rainSTORM_recon
%    Having found localisation data (positions and parameters)
%    rainSTORM_reviewer re-judges all these fits, 
%    Lists all the identified fits that also satisfy its parameters
%    So stricter threshold, tolerance, allowSig can be applied here.
%    Calls rainSTORM_recon to draw a reconstructed image with these data,
%    And displays a reconstruction 
%    Various reconstruction methods exist [REF 1] 
%
% References on STORM image processing - see [1] in particular:
% [1] S. Wolter, Journal of Microscopy, Vol. 237, Pt 1 2010, pp. 12�22
% [2] Cheezum, Biophys. J. 81(4), 2378�2388
% [3] Master's dissertations by Jessica Brush / Chris Arnott.
%
% Notes
% 1. For data input, Version_1-7 onward reads a multi-page tif file,
%    State the input file location with [readDir fname]
%
%    IMPORTANT SPEED ISSUE - when reading multi-page tiffs:
%    http://blogs.mathworks.com/steve/2009/04/02/matlab-r2009a-imread-
%    and-multipage-tiffs/ 
% 
%    In Matlab 2009a and later, avoid n^2 imread() slowdown by using: 
%    myFrame=imread( [readDir,fname], lpIm ,'Info', myImInfo);
%    BUT WARNING - I have seen this function stall, during its first call
%
%    Note 5/7/2013: try libtif file opening with 2012+ MATLAB
%
% 2. The units of distance in this script are 'CCD pixel widths'
%    I've assumed equal CCD pixel widths in the [row] and [col] direction
% 3. JUDGING whether to accept a fit.
%    'thresh' rejects weak (averaged) maxima, before trying a fit. 
%    'tol' rejects a fit if the least squares residue is too high
%    'allowSig' rejects fits unless the fitted Gaussian sigma is in range
%    'allowX' rejects fits with centre positions far from the initial pixel 
% 4. OUTPUT. Simplest form is the hi-res [row,col] positions of dyes
%    SupResPosits stores the [row,col] coordinates of localised maxima
%    SupResParams stores corresponding [Strength,Residue,Intensity,Sigma]
%    [Strength,Residue] are the critical [Thresh,tol] for these points
%    'Intensity' estimates the total signal counts associated with a fit
%    By referring to SupResParams, we can generate reconstucted images
%    during post-processing, with stricter threshold and tolerance than 
%    was applied during the initial fitting process.
% 5. IMAGE RECONSTRUCTION
%    The image reconstruction script can call a custom fillhole script, 
%    called rainSTORM_smooth. Useful if imclose() is not available.
%    Edit rainSTORM_view to control choice of fillhole function.
% 
%    IMAGE VERTICAL FLIP FOR DISPLAY
%    Depending on image acquisition setup, the 'flipud' commands 
%    in _recon and _reviewer might need deletion, or may be vital.
%
%    REGISTERING IMAGES FOR OVERLAYS OF STORM IMAGE ON SUM IMAGE
%    From Version 1_12 onward, the fitting algorithms include a "-0.5" 
%    offset in the localised row and column positions, so that the STORM 
%    reconstruction is registered with respect to the SUM (and
%    conventional) images, allowing simple overlays. This is because the
%    CCD pixel (1,1) actually has its centre at (0.5,0.5), and the fit
%    algorithm should now return the position (0.5,0.5) for a spot here.
%
%    ARGUMENT PASSING
%    This software uses a mixture of argument passing, and of 
%    writing important variables to the base workspace - this is for 
%    user-accessibility to the values. 

function yy=rainSTORM_main_GUI_both(filename,ext,initX0,initSig,rad,tol,Thresh,maxIts,flagSB,alg,flagSum,pixelWidth)

allowSig = [0.5 (rad+1)]; % Reject fits with way-out sigma values (0.8--3)
allowX = 2;           % Reject localisations if abs(x0) > over  (2)
estNum = 30; % For speed, preallocate memory for estNum fits per frame
prevSF = 5;  % Preview scale factor ("linMag"). Scales sample pixel width.

% myBGSE = strel('diamond', rad); % For determining background areas

% initX0 = Initial guess of x0 ('0' = centre of middle pixel)
% initSig = Initial guess of Point Spread Function (PSF) sigma
% %              % Initial guess of Gaussian height is best done from data!
% rad = Radius of ROI for fitting. Fit in squares of side (-rad:rad)
% tol = Tolerance to accept a least squares fit (0.10)
% thresh = Ignore maxima (post-averaging) of low intensity (12)
% maxIts = Number of fitting iterations to try (8 is high. Try 4 or 6)

switch ext;
case '.tif' 
    % Identify a multi-page tif
    myImInfo = imfinfo(filename,'tif');   % Extract file headers and info
    numberOfFiles = numel(myImInfo);      % Number of images in the tif

    FileTif=[filename,'.tif'];
    myImInfo=imfinfo(FileTif); 
    mImage=myImInfo(1).Width; 
    nImage=myImInfo(1).Height; 
    NumberImages=numberOfFiles;
    
    TifLink = Tiff(FileTif, 'r');

case '.raw' 
    [ImSzX,ImSzY,numberOfFiles] = rainSTORM_xmlread(filename);
    fileID = fopen([filename '.raw'],'r'); % Open the file for reading  

end

% Pre-allocate memory for SupRes matrices.
SupResPosits = zeros(numberOfFiles*estNum,2); % To hold [row,col] of fits
SupResParams = zeros(numberOfFiles*estNum,7); % And [Str,Res,Int,Sigma]
SupResNumber = 1; % Current write row in SupResPosits, etc.

tic % See % http://www.matlabtips.com/waiting-for-the-waitbar/
progress = waitbar(0,'Working on image stack');
dividerWaitbar=10^(floor(log10(numberOfFiles))-1);
for lpIm = 1:numberOfFiles; 
 
 switch ext;
 case '.tif' 
   % myFrameIn=imread(filename,'tif',lpIm,'Info',myImInfo); % Not n^2 time
   TifLink.setDirectory(lpIm);    
   myFrameIn = TifLink.read();
 case '.raw' 
   myFrameIn= fread(fileID,[ImSzX,ImSzY],'uint16'); % X,Y order - NEEDS CHECK
   myFrameIn=myFrameIn'; % Image orientation ??
 end
        
myFrame = uint32(myFrameIn);

% bkgdSig = std(double(myFrame(:))); % Find this frame's Poisson std dev

% 1. Identify local maxima above threshold, and return [row,col,magnitude]
myPixels = rainSTORM_avNMS(myFrame,rad);

% 2. Thresholding. To remove noise maxima and weak signals.
myPixels((myPixels(:,3))<Thresh,:)=[]; % Apply threshold
myPixels = flipud(sortrows(myPixels,3)); % Sort for human-readability

% % Make improved background estimate - edited 5/7/2013:
% %  -- changed Sept/2013, as STRELS are slow.
% myBGarea = true(size(myFrame));
% myMeanInt = mean(myPixels(:,3));
% myBrPixels = myPixels(myPixels(:,3)>myMeanInt,1:2);
% myBGarea(sub2ind(size(myFrame), myBrPixels(:,1),myBrPixels(:,2)) ) = 0;
% myBGarea = imerode(myBGarea,myBGSE);
% bkgdSig = std(double(myFrame(myBGarea)));
bkgdSig = std(double(myFrame(myFrame < mean(myFrame(:))))); % Avoids signal

% 3. Localise centre of each pixellated blur (and reject if not Gaussian)
%Implement selected image processing algorithm.
if alg==1
    [myFits,myParams] = rainSTORM_fitLocGF3(myFrame,myPixels,initX0,initSig,allowSig,rad,tol,allowX,bkgdSig,maxIts);

elseif alg==2
    % % [myFits,myParams] = rainSTORM_fitFB(myFrame,myPixels,rad,initSig); % Or fit by Fluoro-Bancroft
    % Least squares Gaussian Fitting without halting
    [myFits,myParams] = rainSTORM_fitLocGF(myFrame,myPixels,initX0,initSig,allowSig,rad,tol,allowX,bkgdSig,maxIts);

elseif alg==3 % Or fit by Centre of Mass: find 1st+2nd moment of intensity
    [myFits,myParams] = rainSTORM_fitCoM(myFrame,myPixels,rad,bkgdSig); 
end

% Add frame number to myParams.
myParams(:,7) = lpIm;

% Store super-resolution positions, and corresponding accuracy indicators
SupResPosits(SupResNumber:SupResNumber + size(myFits,1)-1,:) = myFits;
SupResParams(SupResNumber:SupResNumber + size(myFits,1)-1,:) = myParams;
SupResNumber = SupResNumber + size(myFits,1); % Track write row

  if (round(lpIm/dividerWaitbar)==lpIm/dividerWaitbar) 
   waitbar(lpIm/numberOfFiles,progress); 
  end
end

% After image analysis, close files.
switch ext;
case '.tif' 
    % Add to allow rainSTORM_recon to determine size of myFrame.
    myFrame=imread( filename,'tif', 1 ,'Info', myImInfo);
    myFrame = uint32(myFrame);
    
    TifLink.close();
case '.raw' 
   fclose(fileID); 
end
      
close(progress)
toc

% Remove any empty placeholders from the list of localised positions
% Remove empty first row from SupResPosits and SupResParams (by starting at row 2).
SupResPosits = SupResPosits(1:SupResNumber-1,:);
SupResParams = SupResParams(1:SupResNumber-1,:);

% 4. Reconstruct localised positions into a super-resolution image
%    Inputs are [positions, pixel-densification factor, [nRows nCols]]
%    SupResIm is the directly binned image.
%    Im2 is SupResIm with an image closure applied.
% To display a reconstuction immediately, without running the reviewer, 
% uncomment the following:

% Reconstruct a figure using all the candidate localisations
% prevSF, the reconstruction Scale Factor, is set above, for this preview
[SupResIm] = rainSTORM_recon(SupResPosits,SupResParams,prevSF,size(myFrame)); 

figNewReconHandle = rainSTORM_display(SupResIm, prevSF);
    
       
% Find sum of fluorescence images if desired.
if(flagSum) 
  sumFrame = uint32( zeros(size(myFrame)) );
  sumProgress = waitbar(0,'Generating sum image');

  switch ext;
  case '.tif' 
    TifLink = Tiff(FileTif, 'r');
    for lpImSum = 1:(numberOfFiles);
      % myFrame=imread(filename, 'tif', lpImSum ,'Info', myImInfo);  % Read in a frame
      TifLink.setDirectory(lpIm);    
      myFrame = TifLink.read();
      myFrame = uint32(myFrame);
      
      sumFrame = sumFrame + myFrame;

      if (round(lpImSum/dividerWaitbar)==lpImSum/dividerWaitbar) 
        waitbar(lpImSum/numberOfFiles); 
      end
    end
      TifLink.close();
      
    case '.raw' 
      fileID = fopen([filename '.raw'],'r'); % Open the file for reading  
      for lpImSum = 1:(numberOfFiles);
        myFrameIn= fread(fileID,[ImSzX,ImSzY],'uint16');
        myFrameIn=myFrameIn'; % Image orientation
        myFrame = uint32(myFrameIn);
        sumFrame = sumFrame + myFrame;

        waitbar(lpImSum/(numberOfFiles))
      end
      fclose(fileID);
  end
  close(sumProgress)
  assignin('base','sumFrame',sumFrame);
    
  figSum = figure;
  % Scale Sum image display to match preview reconstruction - uses % size
  imshow(sumFrame,'border','tight','InitialMagnification',prevSF*100)
  hold on
  caxis([min(sumFrame(:)) max(sumFrame(:))]);
  colormap(gray)    
  hold off
end


%Write some variables to main workspace.
assignin('base','SupResIm',SupResIm);
assignin('base','SupResNumber',SupResNumber);
assignin('base','SupResParams',SupResParams);
assignin('base','SupResPosits',SupResPosits);
assignin('base','Thresh',Thresh);
assignin('base','allowSig',allowSig);
assignin('base','estNum',estNum);
assignin('base','filename',filename);
assignin('base','initSig',initSig);
assignin('base','initX0',initX0);
% % assignin('base','linMag',linMag); % Now saved by _display!!! 
assignin('base','maxIts',maxIts);
assignin('base','myFrame',myFrame);
assignin('base','numberOfFiles',numberOfFiles); % (Means number of frames)
assignin('base','allowX',allowX);
assignin('base','rad',rad);
% assignin('base','scaleBarLn',scaleBarLn); % Now calculated in _display
assignin('base','sizeOfCCDFrame',size(myFrame) ); % Size of CCD image
assignin('base','tol',tol);
assignin('base','alg',alg);
assignin('base','figNewReconHandle', figNewReconHandle);
assignin('base','flagSum',flagSum);
assignin('base','flagSB',flagSB);
% assignin('base','pixelWidth',pixelWidth); % Now assigned by rainSTORM.m
assignin('base','prevSF',prevSF); % Preview Scale Factor

end