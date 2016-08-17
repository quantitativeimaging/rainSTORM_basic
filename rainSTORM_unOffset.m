function flagOpoffCorrected = rainSTORM_unOffset( ~ )
% rainSTORM_unOffset
% Copyright 2012. Refer to 00_license.txt for details.
%   Corrects optical offset of localised CH2 data

flagSavedSupResData = evalin('base', 'flagSavedSupResData');
% reviewedDeltaX = evalin('base', 'reviewedDeltaX');
reviewedParams = evalin('base', 'reviewedParams');
reviewedPosits = evalin('base', 'reviewedPosits');
optOffTFORM    = evalin('base', 'optOffTFORM');

% Copied from _UNDRIFT, save data for reversion if necessary
if (flagSavedSupResData == 0) % 
    % Then save the uncorrected data, for user reference / reload
    SavedSupResPosits = evalin('base', 'SupResPosits'); 
    SavedSupResParams = evalin('base', 'SupResParams');  
    
    assignin('base', 'SavedSupResPosits', SavedSupResPosits);
    assignin('base', 'SavedSupResParams', SavedSupResParams);
    assignin('base', 'flagSavedSupResData', 1);%Flag unedited results exist
end

% SHOULD THIS BE FORWARDS, OR BACKWARDS? Am trying Inverse.
reviewedPosits = tforminv(optOffTFORM, reviewedPosits);

% Write the offset-corrected positions to the base workspace
% For both immediate analysis (rev...) and image reconstruction (Sup...)
assignin('base', 'SupResParams', reviewedParams);
assignin('base', 'SupResPosits', reviewedPosits);
assignin('base', 'reviewedParams', reviewedParams);
assignin('base', 'reviewedPosits', reviewedPosits);

flagOpoffCorrected = 1;
end

