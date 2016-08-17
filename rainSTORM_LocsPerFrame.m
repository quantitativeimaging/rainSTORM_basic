function flagLocsPerFrame = rainSTORM_LocsPerFrame(flagLocsPerFrame)
% Copyright 2012. Refer to 00_license.txt for details.

numberOfFiles  = evalin('base', 'numberOfFiles');
reviewedParams = evalin('base', 'reviewedParams');
SupResParams   = evalin('base', 'SupResParams');

numberAcceptedPerFrame = zeros(1,numberOfFiles);
numberCandidatesPerFrame = zeros(1,numberOfFiles);

for lpLoc = 1:size(reviewedParams,1)
  numberAcceptedPerFrame(reviewedParams(lpLoc,7)) = ...
      numberAcceptedPerFrame(reviewedParams(lpLoc,7))+1;
end

for lpLoc = 1:size(SupResParams,1)
  numberCandidatesPerFrame(SupResParams(lpLoc,7)) = ...
      numberCandidatesPerFrame(SupResParams(lpLoc,7))+1;
end

numberRejectedPerFrame = numberCandidatesPerFrame - numberAcceptedPerFrame;

numberAcceptedPerFrameSm = smooth(numberAcceptedPerFrame,100);
numberRejectedPerFrameSm = smooth(numberRejectedPerFrame,100);

plot(1:numberOfFiles, numberRejectedPerFrameSm, 'r')
xlabel('CCD frame number', 'fontSize', 12, 'fontWeight', 'bold');
ylabel('Number per Frame', 'fontSize', 12, 'fontWeight', 'bold');
title('Localisations per Frame (smoothed)', ... 
    'fontSize', 12,'fontWeight','bold');
set(gca, 'fontSize', 12, 'fontWeight', 'bold')
  hold on
  plot(1:numberOfFiles, numberAcceptedPerFrameSm,'b')
  legend('Rejected','Accepted');
  hold off

assignin('base', 'numberAcceptedPerFrame', numberAcceptedPerFrame);
assignin('base', 'numberRejectedPerFrame', numberRejectedPerFrame);

flagLocsPerFrame = 1;
end