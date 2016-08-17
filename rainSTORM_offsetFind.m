function flagOpoffFound = rainSTORM_offsetFind( opoff_Nmarkers )
% rainSTORM_offsetFind 
% Copyright 2012. Refer to 00_license.txt for details.
%   Reads localisation data from 2 channels
%   Channel 1 is RED   fluorescence, for example
%   Channel 2 is GREEN fluorescence, for example
%   ( 'opoff' is a prefix for OPtical OFFset values, by the way)
%   Heuristically identifies matching pairs of white markers in each image
%   Using these localisations as control points
%   Identifies the transform to correct channel 2 back onto channel 1
%   Returns output data to the base workspace
%   Control Point Transforms need the MATLAB image processing kit, I think
%   _DeltaX and _Params are not used, but are loaded for future convenience

% Flow Control and arbitrary numbers
matchRadius = 1.25; % Markers correspond if within this radius, CCD pixels
                    % Something of an arbitrary number: needs tuning

% 1. Load input data - RED and GREEN localisations - from base workspace
opoffCh1_reviewedDeltaX = evalin('base','opoffCh1_reviewedDeltaX');
opoffCh1_reviewedParams = evalin('base','opoffCh1_reviewedParams');
opoffCh1_reviewedPosits = evalin('base','opoffCh1_reviewedPosits');
% opoffCh1_SupResIm       = evalin('base','opoffCh1_SupResIm');

opoffCh2_reviewedDeltaX = evalin('base','opoffCh2_reviewedDeltaX');
opoffCh2_reviewedParams = evalin('base','opoffCh2_reviewedParams');
opoffCh2_reviewedPosits = evalin('base','opoffCh2_reviewedPosits');
% opoffCh2_SupResIm       = evalin('base','opoffCh2_SupResIm');

% Select RED and GREEN channel data, and ensure it is sorted
% Arbitrarily choose the first frame of each channel data, if 
% multiple frames were captured by the input buttons
frameCH1 = min(opoffCh1_reviewedParams(:,7)); % Example = 1
frameCH2 = min(opoffCh2_reviewedParams(:,7));

% Keep rows of localisation data from the chosen frame for each channel
% Overwrite PARAMS last, obviously, as it is used for sorting the others
opoffCh1_reviewedDeltaX = opoffCh1_reviewedDeltaX(opoffCh1_reviewedParams(:,7)==frameCH1,:);
opoffCh1_reviewedPosits = opoffCh1_reviewedPosits(opoffCh1_reviewedParams(:,7)==frameCH1,:);
opoffCh1_reviewedParams = opoffCh1_reviewedParams(opoffCh1_reviewedParams(:,7)==frameCH1,:);

opoffCh2_reviewedDeltaX = opoffCh2_reviewedDeltaX(opoffCh2_reviewedParams(:,7)==frameCH2,:);
opoffCh2_reviewedPosits = opoffCh2_reviewedPosits(opoffCh2_reviewedParams(:,7)==frameCH2,:);
opoffCh2_reviewedParams = opoffCh2_reviewedParams(opoffCh2_reviewedParams(:,7)==frameCH2,:);

% Sort by descending intensity - the first column of reviewedParams
% - This should already have been done, but no-harm in re-sorting
% opoffCh1_reviewedDeltaX = flipud(sortrows(opoffCh1_reviewedDeltaX,opoffCh1_reviewedParams(:,1)));
% opoffCh1_reviewedPosits = flipud(sortrows(opoffCh1_reviewedPosits,opoffCh1_reviewedParams(:,1)));
% opoffCh1_reviewedParams = flipud(sortrows(opoffCh1_reviewedParams,opoffCh1_reviewedParams(:,1)));
% 
% opoffCh2_reviewedDeltaX = flipud(sortrows(opoffCh2_reviewedDeltaX,opoffCh2_reviewedParams(:,1)));
% opoffCh2_reviewedPosits = flipud(sortrows(opoffCh2_reviewedPosits,opoffCh2_reviewedParams(:,1)));
% opoffCh2_reviewedParams = flipud(sortrows(opoffCh2_reviewedParams,opoffCh2_reviewedParams(:,1)));


% 2. Find corresponding markers in the RED and GREEN CHANNELS
if( opoff_Nmarkers > size(opoffCh1_reviewedPosits,1) || ...
    opoff_Nmarkers > size(opoffCh2_reviewedPosits,1) )

    opoff_Nmarkers = min([ size(opoffCh1_reviewedPosits,1) ...
                          size(opoffCh2_reviewedPosits,1)] );
   % Careful not to scan through more markers than exist
end

offPairsCH1 = -ones(opoff_Nmarkers,2); % Delete unsolved -1s at end
offPairsCH2 = -ones(opoff_Nmarkers,2);

for lpPairs = 1:opoff_Nmarkers
  
  thisPositCH1 = opoffCh1_reviewedPosits(lpPairs,:);
  
  vectCH2f1 = opoffCh2_reviewedPosits ...
              - (ones(size(opoffCh2_reviewedPosits),1)) *  thisPositCH1;
          % Produces a warning "input arguments must be scalar", but why?

  distCH2f1 = vectCH2f1(:,1).^2 + vectCH2f1(:,2).^2;
  distCH2f1 = sqrt(distCH2f1);
  
  possPositsCH2 = opoffCh2_reviewedPosits(distCH2f1 < matchRadius,:);
  
  if(size(possPositsCH2,1)==1)
    offPairsCH1(lpPairs,:) = thisPositCH1;
    offPairsCH2(lpPairs,:) = possPositsCH2;
  end
end

% This loop should have found corresponding RED and GREEN marker positions
% Now expunge -1 values, which signify unsolved pairs
offPairsCH1( (offPairsCH1(:,1) == -1),:) = []; % Delete unfound values
offPairsCH2( (offPairsCH2(:,1) == -1),:) = [];

% Plot the locations of marker pairs
figOffsetPairs = figure;
  scatter(offPairsCH1(:,2), -offPairsCH1(:,1), '+r');
  hold on
  scatter(offPairsCH2(:,2), -offPairsCH2(:,1), '+g');
  hold off
  title('Optical Offset Markers', 'fontSize', 12, 'fontWeight', 'bold')
  xlabel('CCD pixel, column-direction (horizontal)', ...
      'fontSize', 12, 'fontWeight', 'bold');
  ylabel(' - CCD pixel, row-direction (vertical)', ...
      'fontSize', 12, 'fontWeight', 'bold');
  set(gca, 'fontSize', 12, 'fontWeight', 'bold');

% Now determine the transform from CH2 back to CH1, using control points
% In MATLAB cp2tform, input is the image that needs to be warped to bring 
% it into the coordinate system of the base image
% 19/09/2012 - this order works provided tforminv() is used for correction:

optOffTFORM = cp2tform(offPairsCH1,offPairsCH2,'polynomial',2);
% (input_points, base_points, ...
% Note, need 10 noncolinear pairs for cubic, 6 pairs for quadratic

assignin('base','figOffsetPairs',figOffsetPairs);
assignin('base','offPairsCH1', offPairsCH1);
assignin('base','offPairsCH2', offPairsCH2);
assignin('base','optOffTFORM', optOffTFORM );

flagOpoffFound = 1;
end

