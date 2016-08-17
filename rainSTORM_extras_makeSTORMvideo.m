% rainSTORM_extras_makeSTORMvideo
%
% Eric Rees. Version 1.2 (development, 24/10/2011)
%
% WARNING: THIS SCRIPT CREATES A FOLDER IN THE WORKING DIRECTORY, AND SAVES
% SOME IMAGE FILES THERE
%
% This script generates the image frames necessary to create a movie 
% showing the progress of a super-resolution reconstruction. It plots
% STORM reconstructions using all the localisations in SupResPosits, up 
% to a progressively higher frame number (compare "lpFrm" to  in Column 7 
% of SupResParams). 
%
% It only provides basic quality control -
%
% This script saves a set of png images, which you can assemble into a
% video using ImageJ (Save As> AVI). To open the images as a stack in
% ImageJ, cut and paste all the pictures into a folder, and drag the folder
% onto the ImageJ menu.
%
% INSTRUCTIONS
% 1. First run rainSTORM to localise fluorophore positions.
% 2. Set suitable input parameters in this script.
% 3. Note that Thompson Precision is not yet implemented here
% 

% INPUT PARAMETERS (Variously needed as they don't seem to be saved to the
% workspace from rainSTORM. Sorry.)
linMag = evalin('base', 'linMag'); % Assume written to 'base' by _main
sizeOfFrame = evalin('base','sizeOfCCDFrame');
% numberOfFiles % Is needed in base workspace
% sizeOfCCDFrame = [128,128]; % This is saved by rainSTORM V 2-8 and later
flagSB         = true;
flagSaveImages = 1;

newThresh = evalin('base','newThresh'); % Set by running _reviewer
newTol    = evalin('base','newTol');    % Set by running _reviewer
newSig    = evalin('base','newSigma');  % Set by running _reviewer

% SET THE THRESHOLD THOMPSON PRECISION HERE, IF REQUIRED 
% newPrecision = 50; % nm BUT CHECK CCD LENGTHSCALE IS OK

% CUT OUT LOCALISATIONS WITH POOR THOMPSON PRECISION HERE, IF REQUIRED
% SupResDeltaX = rainSTORM_precision(SupResParams);
% deltaX = mean(SupResDeltaX,2); % Assumes Reviewer has been run
% SupResPosits = SupResPosits((deltaX(:,1)<newPrecision), :);
% SupResParams = SupResParams((deltaX(:,1)<newPrecision), :);

if(flagSaveImages)
 mkdir('mySTORMvideo'); % Create a folder to hold output files
end
 
for lpFrm = 2:500:numberOfFiles

% Apply quality control, and select fits from a range of frames
theseSupResPosits = SupResPosits( (SupResParams(:,1)>newThresh) &...
                               (SupResParams(:,2)<newTol) &...
                               (SupResParams(:,4)>newSig(1) ) &...
                               (SupResParams(:,4)<newSig(2) ) &...
                               ... % (deltaX(:,1)<newPrecision) &... 
                               (SupResParams(:,7)>0 ) &...
                               (SupResParams(:,7)<lpFrm )  ... 
                              ,:); % Read all columns of Posits
 
theseSupResParams = SupResParams( (SupResParams(:,1)>newThresh) &...
                               (SupResParams(:,2)<newTol) &...
                               (SupResParams(:,4)>newSig(1) ) &...
                               (SupResParams(:,4)<newSig(2) ) &...
                               ... % (deltaX(:,1)<newPrecision) &... 
                               (SupResParams(:,7)>0 ) &...
                               (SupResParams(:,7)<lpFrm )  ... 
                              ,:); % Read all columns of Params

[SupResIm] = rainSTORM_recon(theseSupResPosits,theseSupResParams,linMag,sizeOfFrame); 

% plot SupResIm
myplot = figure(1);
imshow(SupResIm, 'border', 'tight')
hold on
caxis([min(SupResIm(:)) max(SupResIm(:))]);
colormap(hot);
  
%Add scale bar if desired.    
if(flagSB) 
    plot([max(xlim) (max(xlim)-scaleBarLn*linMag)]-10,[max(ylim)*0.9 max(ylim)*0.9],'w-','LineWidth',3);
    text((max(xlim)-1.3*scaleBarLn*linMag),(max(ylim)*0.87),'1 µm','FontSize',12,'Color','w');
end

hold off

 if(flagSaveImages)
  myIm = getframe(gcf);
  myIm = myIm.cdata;
  imwrite(myIm, ['mySTORMvideo/SupResVid', int2str(lpFrm), '.png'],'png')
 end
 
 % waitbar(lpFrm/10000)
end