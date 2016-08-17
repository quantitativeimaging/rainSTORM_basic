% rainSTORM_extras_removeAverageBG
%
% June 2013
%
% FUNCTION
% A script to remove a d.c. background from an image stack
% Pre-processes Klarite data for CS
%
%

% 0. Flow Control

% 1. Inputs

myDir = 'C:\Documents and Settings\ejr36\My Documents\Projects\2013_Klarite_CS\2013_02_08_Klarite\';
myFile = 'sample_3_area_3_z=+800.tif';
filename = [myDir,myFile];

myDirOut = 'C:\dSTORMdat\2013_BGsubt\';
myFileOut = 'test';

% 2. Background Subtraction and image saving

myImInfo = imfinfo(filename,'tif');     % Extract file headers and info
numberOfFrames = numel(myImInfo);        % Number of images in the tif

% Create emtpy matrix to store sum of input images
myFrame = imread(filename,'tif',1,'Info',myImInfo); % Not n^2 time!
sumFrame = double(zeros(size(myFrame)));

% Find d.c. background
for lpFrm = 1:numberOfFrames
  myFrameIn=imread(filename,'tif',lpFrm,'Info',myImInfo); % Not n^2 time!
  myFrame = double(myFrameIn);

  sumFrame = sumFrame + myFrame;
  myBar5 = waitbar(lpFrm/numberOfFrames);
end
close(myBar5)
meanFrame = uint16(floor(sumFrame./numberOfFrames));

% Subtract d.c. bavkground from each frame
for lpFrm = 1:numberOfFrames
  myFrameIn=imread(filename,'tif',lpFrm,'Info',myImInfo); % Not n^2 time!
  myFrame = uint16(myFrameIn);
  
  myFrame = myFrame - meanFrame;
  myFrame(myFrame<0) = 0;
  
  fileOut = [myDirOut,myFileOut,int2str(lpFrm),'.tif'];
  
  imwrite(myFrame,fileOut,'tif')
    myBar6 = waitbar(lpFrm/numberOfFrames);
end
close(myBar6)
