% Script to select localisations inside a user defined polygon
%
% To use:
%    1. Run rainSTORM "Process Images" and 
%    2. Run Reviewer, setting the Reconstruction Scale Factor to 1 ***
%    3. Keep the reviewed image on screen as a figure
%    4. USe roipoly tool: double click, or right click in mask to create 
%       the mask. The script will then continue.
%
%   Note that "reconstuctionScaleFactor" is not handled here
%    - in general, it is too likely to be over-written by user changes
%    - So users of this polygon select tool should instead work on an 
%      image with a reconstruction scale factor of 1.

flagUseROIPOLY      = 1; % To select using MATLAB's roipoly...
flagInvertSelection = 1; % To select outside a polygon
% reconstructionScaleFactor

% 1. INPUT
%    The user must select the region of interest
if (flagUseROIPOLY)
    myPolyMask = roipoly;
else
    [FileName,PathName,FilterIndex] = uigetfile('.tif')
    myPolyMask = imread([PathName, FileName]);
    myPolyMask = (myPolyMask(:,:,1) > 0);
end
    
selectedRows = zeros(size(reviewedPosits,1), 1);

for lpLoc = 1:size(reviewedPosits,1);
   
    myRowIndex = floor(reviewedPosits(lpLoc,1)*reconstructionScaleFactor);
    myColIndex = floor(reviewedPosits(lpLoc,2)*reconstructionScaleFactor);
    
    if(myRowIndex<1)
        myRowIndex = 1;
    end
    if(myColIndex<1)
        myColIndex = 1;
    end
    
    selectedRows(lpLoc) = myPolyMask(myRowIndex, myColIndex );    
end

if(flagInvertSelection)
   selectedRows = not(selectedRows); 
end

