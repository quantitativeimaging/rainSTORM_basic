function flagMarkAnchor = rainSTORM_setAnchor(flagMarkAnchor)
% Identifies the mean position of a fiducial marker, 
% So that other marker positions (even in another stack of im data) can be 
% subtracted to give required drift corrections.

markerPosits = evalin('base','markerPosits');

markerAnchor = mean(markerPosits,1);

assignin('base','markerAnchor',markerAnchor);

flagMarkAnchor = 1; % Indicates a fiducial marker "anchor position" is set
end