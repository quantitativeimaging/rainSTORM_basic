function flagSaved = rainSTORM_save( flagSaved )
%rainSTORM_save
% Copyright 2012. Refer to 00_license.txt for details.
%   edited, 7 Jan 2013, Eric Rees
%   This function is called by clicking the Save button in the Reviewer
%   It (tries to) save the following files:
%      1. dataFileName-STORMdataImage (histogram image data, 16 bit grey)
%      2. dataFileName-onScreenImage  (on-screen visualisation, colour)
%      3. dataFileName-hists          (quality histograms, if available)
%      4. dataFileName-sum            (sum of images ~ conventional image)
%      5. dataFileName-info           (text metadata about results)
%      6. dataFileName-JHistImage     (Jittered Jistogram data)
%   Then sets flagSaved in the base workspace, to show pictures are saved

% 0. Determine file name of the Localisation Microscopy data being handled
  J = evalin('base','filename');

% 1. Save a greyscale "Simple Histogram Visualisation"  
% This contains numerical values of the reconstruction made by the reviewer 
  SupResIm = evalin('base','SupResIm');
  imwrite(uint16(SupResIm),[J,'-STORMdataImage.png']); % Was "-greyscale"

% 2. Get the on-screen Visualisation, maybe w/ colour, contrast, scalebar
% BEWARE the figure handle points to the wrong figure if the most recent
%  visualisation has been closed (or its figure handle changed)
% Save the processed "On Screen" visualisation to a file.  
  try
    figNewReconHandle = evalin('base','figNewReconHandle');
    myIm = getframe(figNewReconHandle);
    imwrite(myIm.cdata,[J,'-onScreenImage.png']);
  catch MErr % MErr is for "My Error" although it is not essential
    warning('rainSTORM:Reviewer:saveReconFailed', ...
        'Could not save the processed visualisation from on-screen fig')
  end

% 3. Try to save the Localisation data histograms, if available
% Note, this method now saves the Figure at the time of plotting, 
% rather than grabbing a user-edited window. 
% This increases software-robustness against saving the wrong figure
  try
    flagHistsPlotted = evalin('base','flagHistsPlotted');
    if (flagHistsPlotted)
      figHistsImage = evalin('base', 'figHistsImage');
      imwrite(figHistsImage, [J,'-hists.png']);
    else
      flagHistsPlotted = rainSTORM_histograms(flagHistsPlotted);
      assignin('base','flagHistsPlotted',flagHistsPlotted);
      figHistsImage = evalin('base', 'figHistsImage');
      imwrite(figHistsImage, [J,'-hists.png']);
    end
  catch myError % "My Error"
    warning('rainSTORM:Reviewer:printHistsFailed','No histograms saved');
    assignin('base','myError',myError);
  end
  
% 3b. Try to save the MATLAB matrix data for the Jittered Histogram image
% If there is one
  try
    flagCalculatedJH = evalin('base','flagCalculatedJH');
    if(flagCalculatedJH)
      jhImage = evalin('base','jhImage');
      jhImage = jhImage./max(jhImage(:));
      imwrite(jhImage,[J,'-JHistImage.png']); % Jittered Histogram data
    end
  catch myError % MErr is "My Error"
    warning('rainSTORM:Reviewer:saveJHfail','Cannot save Jitt Hist Image');
    assignin('base','myError3',myError);
    
  end
  
% 4. Try to save the sum of raw data: it approximatates a normal image
  try
    flagSum = evalin('base','flagSum');
    linMag = evalin('base', 'linMag'); % rSt_display 's Newest Scale Factor
    if(flagSum)
    sumFrame = evalin('base','sumFrame');
    sumFrame = double(sumFrame);
    sumFrame = sumFrame - min(sumFrame(:)); % Avoid washout of sum image
    sumFrame = sumFrame/max(sumFrame(:));   % By saving after min-max scale
    sumFrRsz = imresize(sumFrame,linMag,'nearest');
    imwrite(sumFrRsz,[J,'-sum.png']);
    end
  catch myError % MErr is "My Error"
    warning('rainSTORM:Reviewer:printSumFailed','Cannot print Sum figure');
    assignin('base','myError2',myError);
  end
  
% 5. Try saving some metadata about the reconstruction
  try 
  fid = fopen([J '-info.txt'], 'wt'); % "wt" indicates "Write Text"
  % 'w' mode needs Wordpad, since notepad dislikes 'w' newlines.
  % Use commas to separate columns, for easy import to Excel etc.
  fprintf(fid, 'Information about Reconstructed Image, \n , \n' );
  fprintf(fid, 'Raw Image Data, %s \n', J); 
  fprintf(fid, 'Date, %s \n , \n', datestr(now, 'dd-mmm-yyyy  HH.MM.SS') );
  
  fprintf(fid, 'Precision Limit= 2*RMS Thompson precision (nm) ROW-axis, %f \n', ...
      evalin('base', 'SparrowThompsonLimit(1)') );
  fprintf(fid, 'Precision Limit= 2*RMS Thompson precision (nm) COL-axis, %f \n', ...
      evalin('base', 'SparrowThompsonLimit(2)') );
  fprintf(fid, 'Sparse Sampling Limit= 3*RMS Thompson precision (nm) ROW-axis, %f \n', ...
      evalin('base', '1.5 * SparrowThompsonLimit(1)') );
  fprintf(fid, 'Sparse Sampling Limit= 3*RMS Thompson precision (nm) COL-axis, %f \n', ...
      evalin('base', '1.5 * SparrowThompsonLimit(2)') );

  fprintf(fid, 'Thompson Precision Cutoff (nm), %i \n', evalin('base','newPrecision') );
  fprintf(fid, 'Accepted data frames, %i - %i \n', evalin('base','newFrames(1)'), evalin('base','newFrames(2)') );
  fprintf(fid, 'Accepted spot width (pixels), %f - %f \n', evalin('base','newSigma(1)'), evalin('base','newSigma(2)') );
  fprintf(fid, 'Accepted spot count threshold, %i \n', evalin('base','newThresh') );
  fprintf(fid, 'Accepted fit tolerance, %f \n', evalin('base','newTol') );
  fprintf(fid, 'Mean precision estimate (row-direction nm), %f \n', evalin('base','meanRevDeltaX(1)') );
  fprintf(fid, 'Mean precision estimate (col-direction nm), %f \n', evalin('base','meanRevDeltaX(2)') );
  fprintf(fid, 'StDv precision estimate (row-direction nm), %f \n', evalin('base','stdRevDeltaX(1)') );
  fprintf(fid, 'StDv precision estimate (col-direction nm), %f \n', evalin('base','stdRevDeltaX(2)') );

  fprintf(fid, 'CCD pixel width on sample (nm), %i \n', evalin('base','pixelWidth') );
  fprintf(fid, 'Super-resolution image pixel width (nm), %i \n', evalin('base','pixelWidth/reconstructionScaleFactor') );
  fprintf(fid, 'Counts per photon for calibration, %f \n', evalin('base','countsPerPhoton') );
  fprintf(fid, 'Number of accepted localisations, %i \n', evalin('base','size(reviewedPosits,1)') );
  fprintf(fid, 'Number of rejected candidates, %i \n', evalin('base','size(SupResPosits,1)-size(reviewedPosits,1)') );

  fclose(fid);  
  catch MErr % MErr is "My Error"
      warning('rainSTORM:Reviewer:saveInfoFailed','Info text file failed');
      try
        fclose(fid);
      catch MError
        warning('rainSTORM:Reviewer:saveInfoFailed','Text file may not be closed for writing');
        assignin('base','MError',MError);
      end
  end

  
flagSaved = 1;
assignin('base', 'flagSaved', flagSaved); % Indicates images saved.

end

