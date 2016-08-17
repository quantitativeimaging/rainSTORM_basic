function flagUndrifted = rainSTORM_undrift(flagUndrifted)
% Copyright 2012. Refer to 00_license.txt for details.

% 0. Load required information from base workspace
flagSavedSupResData = evalin('base', 'flagSavedSupResData');
markerAnchor = evalin('base','markerAnchor');
markerFrames = evalin('base', 'markerFrames'); % List of frame #s with mark
% markerParams = evalin('base', 'markerParams');   % Presently not needed
markerPosits   = evalin('base', 'markerPosits'); 
reviewedParams = evalin('base', 'reviewedParams');
reviewedPosits = evalin('base', 'reviewedPosits');


% 1. Save the uncorrected localisation data, if necessary
% To reload, run the next two lines (without commenting them out):
%    SupResPosits = SavedSupResPosits;
%    SupResParams = SavedSupResParams;
%    flagSavedSupResData is set=0 on running the rainSTORM.m Search
%    This Saved Data flag MAY also be set by the optical offset panel
if (flagSavedSupResData == 0) % If this is the first try at drift correction, 
    % Then save the uncorrected data, for user reference / reload
    SavedSupResPosits = evalin('base', 'SupResPosits'); 
    SavedSupResParams = evalin('base', 'SupResParams');  
    
    assignin('base', 'SavedSupResPosits', SavedSupResPosits);
    assignin('base', 'SavedSupResParams', SavedSupResParams);
    assignin('base', 'flagSavedSupResData', 1);%Flag unedited results exist
end

% 2. PROCESS: Evaluate required drift correction:
driftCorrection = ones(size(markerPosits,1),1)*markerAnchor - markerPosits;
% Note that a vector outer product generates a N-row by 2-Col matrix 
% 'mean(markerPosits,1)' gives the [Row,Col] mean marker postion, by taking
% the mean value down each row of data 


% 3. PROCESS: CORRECT DRIFT
% Use the identified fiducial marker data to correct drift
% This method uses a simple translation - affine TFORM needs real thought
% This method is elementwise; and ideally should be vectorised!
for lpLc = 1:size(reviewedPosits,1) % For each quality-controlled position

    % Logical test: "Does a marker position come from this frame?"
   thisFrameMark = (markerFrames == reviewedParams(lpLc, 7) ); 
   
   if(sum(thisFrameMark) == 0 )     % If this frame has no marker position
       reviewedPosits(lpLc,1) = -1; % Set reviewedPosits to an error code
       reviewedParams(lpLc,1) = -1; %...And clear error-coded data at end
   else
       reviewedPosits(lpLc,1) = reviewedPosits(lpLc,1) + ...
           driftCorrection(thisFrameMark, 1); 
       reviewedPosits(lpLc,2) = reviewedPosits(lpLc,2) + ...
           driftCorrection(thisFrameMark, 2); 
   end
end

reviewedPosits(reviewedPosits(:,1) == -1, :) = []; % Clear error-coded data
reviewedParams(reviewedParams(:,1) == -1, :) = [];



% 4. OUTPUT
% Write results to the base workspace,
% Copy reviewed data (now corrected) over SupResPosits and SupResParams, 
%... so that subsequent uses of the Reviewer refer to corrected data.
assignin('base', 'SupResParams', reviewedParams);
assignin('base', 'SupResPosits', reviewedPosits);
assignin('base', 'reviewedParams', reviewedParams);
assignin('base', 'reviewedPosits', reviewedPosits);

flagUndrifted = 1; % Return 1 to indicate SupResPosits have been adjusted
end