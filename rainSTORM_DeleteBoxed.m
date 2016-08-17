function flagSomeCuts = rainSTORM_DeleteBoxed(flagSomeCuts)
% Copyright 2012. Refer to 00_license.txt for details.
% 0. 
% Load required inputs from base workspace
% boxCols = evalin('base','boxCols');
% boxRows = evalin('base','boxRows');
flagSavedSupResData = evalin('base', 'flagSavedSupResData');
reviewedParams = evalin('base', 'reviewedParams');
reviewedPosits = evalin('base', 'reviewedPosits');
selectedRows = evalin('base', 'selectedRows'); % From box or poly select

% 1. 
% Save unedited raw localisation results if they aren't yet saved
if (flagSavedSupResData == 0) % If unedited results aren't yet saved
                              % Then save them:
    SavedSupResPosits = evalin('base', 'SupResPosits'); 
    SavedSupResParams = evalin('base', 'SupResParams');  
    assignin('base', 'SavedSupResPosits', SavedSupResPosits);
    assignin('base', 'SavedSupResParams', SavedSupResParams);

    assignin('base', 'flagSavedSupResData', 1);%Flag unedited results exist
end


% 2. 
% Remove boxed positions from the reviewed data 
% This can remove spurious blobs from the reconstruction

rowsToDelete = selectedRows;
% rowsToDelete = (reviewedPosits(:,1) > boxRows(1) & ...
%                 reviewedPosits(:,1) < boxRows(2) & ...
%                 reviewedPosits(:,2) > boxCols(1) & ...
%                 reviewedPosits(:,2) < boxCols(2) );
 
reviewedParams(rowsToDelete, :) = []; % CLEAR PARAMS FIRST 

reviewedPosits(rowsToDelete, :) = []; % CLEAR POSITIONS LAST

           
% 3. 
% Write results to the base workspace,
% Copy reviewed data (with empty box) over SupResPosits and SupResParams, 
%... so that subsequent uses of the Reviewer refer to corrected data.
assignin('base', 'SupResParams', reviewedParams);
assignin('base', 'SupResPosits', reviewedPosits);
assignin('base', 'reviewedParams', reviewedParams);
assignin('base', 'reviewedPosits', reviewedPosits);
           
end