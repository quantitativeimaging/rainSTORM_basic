
numberAcceptedPerFrame = zeros(1,numberOfFiles);

for lpFrame = 1:size(reviewedParams,1)
    numberAcceptedPerFrame(reviewedParams(lpFrame,7)) = ...
        numberAcceptedPerFrame(reviewedParams(lpFrame,7))+1;
end


plot(1:numberOfFiles, numberAcceptedPerFrame)
xlabel('CCD frame number', 'fontSize', 12, 'fontWeight', 'bold');
ylabel('N accepted localisations', 'fontSize', 12, 'fontWeight', 'bold');
set(gca, 'fontSize', 12, 'fontWeight', 'bold')