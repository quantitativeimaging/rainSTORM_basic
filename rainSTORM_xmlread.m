% rainSTORM_xmlread
% by Mark Deimund
%
% This routine determines the image size and number of frames for .raw data
% from xml data.
%
%
function [ImSzX,ImSzY,numberOfFrames] = rainSTORM_xmlread(filename)

readXml  = [filename '.xml'];

xmlstr   = xmlread(readXml); 

% Get into correct section of xml structure
xmlFile = xmlstr.getElementsByTagName('acquisition_metadata');
metadata = xmlFile.item(0);
  
acqMeta = metadata.getElementsByTagName('Camera_settings');
cameraSettings = acqMeta.item(0);     
    
subimageBinning = cameraSettings.getElementsByTagName('Subimage__binning');
xMax = subimageBinning.item(0);

acqProgress = cameraSettings.getElementsByTagName('Acquisition_progress');
acqProg = acqProgress.item(0);

% Obtain values for frame number dimensions.
thisList = xMax.getElementsByTagName('x_max');
thisElement = thisList.item(0);
xmax = char(thisElement.getFirstChild.getData);

thisList2 = xMax.getElementsByTagName('x_min');
thisElement2 = thisList2.item(0);
xmin = char(thisElement2.getFirstChild.getData);

thisList3 = xMax.getElementsByTagName('y_max');
thisElement3 = thisList3.item(0);
ymax = char(thisElement3.getFirstChild.getData);

thisList4 = xMax.getElementsByTagName('y_min');
thisElement4 = thisList4.item(0);
ymin = char(thisElement4.getFirstChild.getData);

% Obtain value for the number of frames.
thisList = acqProg.getElementsByTagName('Saved');
thisElement = thisList.item(0);
numFrames = char(thisElement.getFirstChild.getData);



% Calculate image size and number of frames.
ImSzX = str2num(xmax) - str2num(xmin) + 1;
ImSzY = str2num(ymax) - str2num(ymin) + 1;
numberOfFrames = str2num(numFrames);

end
