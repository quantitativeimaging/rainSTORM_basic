function flagBoxed = rainSTORM_boxTracker(flagBoxed)
%  rainSTORM_extras_boxTracker
% Copyright 2012. Refer to 00_license.txt for details.
%
% FUNCTION
%   Selects quality-controlled localisations within a user-defined box
%   Plots the data as a scatterplot, colour coded by frame number
%   May be used to inspect data for motion blur
%   The selected "boxedPosits" can be used for Fiduciary Drift Correction
%
% USER NOTES
% 0. This tool identifies localisations within a user-defined rectangle,
%    for use as a fiducial marker for drift correction.
% 1. Apply this tool to the most recent super-res reconstruction Figure
%    It searches for reviewed Posits - i.e. accepted Localisations - 
%    which are only retained for one Figure at a time
%    To avoid confusion, I recommend closing all figure windows, and then 
%    plotting a Reviewed reconstruction to work on with this tool - EJR.
% 2. The tool allow you to select one rectangular region within the 
%    Super-resolution reconstruction.
% 3. All localisations within this region are identified, and stored as
%    boxedPosits and associated boxedParams
%   ====> boxed Posits might be useful on their own, for identifying the
%    frames that give rise to particular reconstructed features.
% 4. Within each CCD frame for which there is at least one boxed position, 
%    the brightest boxed position is identified as a fiducial marker - the 
%    data for these points are stored as markerPosits and markerParams
% 4b: BEWARE: If there is one bead in the box, then it should be the
% brightest feature in the box, in each frame - I am assuming this is the
% case. If there are 2 or more beads, or if there are other bright
% features, then this method, in which I identify the brightest boxed
% feature as the fiducial marker, may go wrong and identify some incorrect
% positions for drift correction.
% 5. NOTE that when a Fiducial Mark-corrected reconstruction is plotted, 
%    the markerPosits should be removed from reviewedPosits before plotting
%    THIS IS NOW DONE BY THIS SCRIPT - but not immune from overwriting
%    Since the markerPosits have been used to adjust position data, and 
%    cannot (well, should not) also be used to display positions.
% 6. NOTE that plotting the scatterplot of boxed Posits can take several
%    seconds - this is (probably) not a MATLAB crash, so be patient.
%    NOTE: Co-ordinates are in the [ROW, COLUMN] image-like notation

% Part 0: Flow Control and Input Arguments
reviewedPosits = evalin('base','reviewedPosits');
reviewedParams = evalin('base','reviewedParams');
reviewedDeltaX = evalin('base','reviewedDeltaX');
reconstructionScaleFactor = evalin('base','reconstructionScaleFactor');

flagShowBoxedPosits = 1; % Set to zero to supress drawing a scatterplot
                         % -- plotting it can be time consuming

% Part 1: Identify user-boxed localisations
rect = getrect(evalin('base','figNewReconHandle')); 
% Above: user must use a UI to specify a region of the reconstuction.
boxCols = [rect(1), rect(1) + rect(3) ] ./ reconstructionScaleFactor;
boxRows = [rect(2), rect(2) + rect(4) ] ./ reconstructionScaleFactor;

selectedRows = ( (reviewedPosits(:,1) > boxRows(1)) & ...
                 (reviewedPosits(:,1) < boxRows(2)) & ...
                 (reviewedPosits(:,2) > boxCols(1)) & ...
                 (reviewedPosits(:,2) < boxCols(2)) );

boxedDeltaX = reviewedDeltaX( selectedRows, :);
boxedParams = reviewedParams( selectedRows, :);
boxedPosits = reviewedPosits( selectedRows, :); 

meanBoxedPosits = mean(boxedPosits,1); % Used to plot reconstuction

% Remove boxed positions from the reviewed data 
% This is to prevent spuriously accurate blobs appearing in reconstruction
% reviewedParams(reviewedPosits(:,1) > boxRows(1) & ...
%                reviewedPosits(:,1) < boxRows(2) & ...
%                reviewedPosits(:,2) > boxCols(1) & ...
%                reviewedPosits(:,2) < boxCols(2) ...
%                , :) = []; % CLEAR PARAMS FIRST - NEED POSIT DATA TO DO IT!
% 
% reviewedPosits(reviewedPosits(:,1) > boxRows(1) & ...
%                reviewedPosits(:,1) < boxRows(2) & ...
%                reviewedPosits(:,2) > boxCols(1) & ...
%                reviewedPosits(:,2) < boxCols(2) ...
%                , :) = []; % CLEAR POSITIONS LAST


% Part 2: Optionally display the boxed localisations, colour-coded in
% time-order - currently using the jet colormap (first=blue -> last=red)
if(flagShowBoxedPosits)
  % Note that Y-positions are plotted as negative row positions,
  % to match image matrix orientation.
  figure
  myCmap = colormap( jet(reviewedParams(end,7)) ); % 1 entry per frame
  boxedColour = ones(size(boxedPosits,1), 3);
  for lpBox = 1:size(boxedPosits,1)
    boxedColour(lpBox,:) = myCmap(boxedParams(lpBox,7), : );
  end
  
  scatter(boxedPosits(:,2), -boxedPosits(:,1), 12, boxedColour, 'x')
  title('Boxed Positions (Colour = Frame Number)', ...
      'fontSize', 12, 'fontWeight', 'bold');
  xlabel('CCD Col Number', 'fontSize', 12, 'fontWeight', 'bold');
  ylabel('CCD Row Number (Negative for image alignment)', ...
      'fontSize', 12, 'fontWeight', 'bold');
  colorbar
  caxis([0 size(myCmap,1) ])
  set(gca, 'fontSize', 12, 'fontWeight', 'bold');
  axis equal % Set axis increments to be of equal size; prevent stretching
 %  xlim([meanBoxedPosits(2) - 0.25, meanBoxedPosits(2) + 0.25 ]) % Cols
 %  ylim([-meanBoxedPosits(1) - 0.25, -meanBoxedPosits(1) + 0.25 ]) % Rows

    
end


% Part 3: Identify Fiducial Marker positions
% Find markerPosits (using ROW, COL coordinates of CCD)
% These are the brightest boxed Position in each frame
% Need the corresponding Frame numbers which have a reliable marker

markerPosits = -ones(boxedParams(end,7),2); % Initialise as -1 (error)
markerParams = -ones(boxedParams(end,7),7); % Initialise as -1 (error)
markerFrames = (1: boxedParams(end,7) )';   % Corresponding frame numbers

for lpFrms = 1:boxedParams(end,7)
  myParams = boxedParams(boxedParams(:,7) == lpFrms, :); % Finds boxed data
  myPosits = boxedPosits(boxedParams(:,7) == lpFrms, :); %...in this frame

  if(size(myParams,1)<1)
    % If there is no marker for this frame, then:
    markerFrames(lpFrms) = -1; % Replace "frame number" with 'error' (-1)
   continue; % and delete values which are still == -1 at end of scan
  else
  myList = [myParams,myPosits]; % Catenate Fit Data for sorting
  myList = flipud(sortrows(myList,3));  % Row 1 is brightest 
  markerPosits(lpFrms,:) = myList(1,8:9); % Identify brightest accepted position as the fiducial marker
  markerParams(lpFrms,:) = myList(1,1:7); % ... and note its Parameters
  end
  
end

markerFrames(markerFrames == -1        ) = []; % Clear unidentified results
markerParams(markerParams(:,1) == -1, :) = [];
markerPosits(markerPosits(:,1) == -1, :) = [];

% Part 4: (Drift Correction moved to undrift script)


% Part 5: OUTPUTS
% Write useful outputs to base workspace, for user (and FN) accessibility
assignin('base', 'boxCols', boxCols); % For box deletion by Subtract Drift
assignin('base', 'boxRows', boxRows);
assignin('base', 'boxedColour',  boxedColour);
assignin('base', 'boxedDeltaX',  boxedDeltaX);
assignin('base', 'boxedParams',  boxedParams);
assignin('base', 'boxedPosits',  boxedPosits);
assignin('base', 'markerFrames', markerFrames);
assignin('base', 'markerParams', markerParams);
assignin('base', 'markerPosits', markerPosits);
assignin('base', 'reviewedPosits', reviewedPosits); % With box excluded!
assignin('base', 'reviewedParams', reviewedParams);
assignin('base', 'selectedRows', selectedRows); % boxed rows of reviewed


flagBoxed = 1; % Return 1 to indicate boxTracker completed an analysis
end
