%
% By special request, a script to analyse spot lifetimes.
%


activePositions = [];
activeLifetimes = [];

finishedPositions = [];
finishedLifetimes = [];

flagMatched = false;

for lpFrame = 1:numberOfFiles
    newPositions = reviewedPosits(reviewedParams(:,7)==lpFrame,:);
    newLifetimes = ones(size(newPositions,1),1);
    
    % Increment lifetime of ongoing spots, and
    % Flush finished spots to a record
    lpAPs = 1;
    target = size(activePositions,1);
    while lpAPs <= target
    % for lpAPs = 1:size(activePositions,1)
      flagMatched = false;
        
      for lpNPs = 1:size(newPositions,1)
        dX = activePositions(lpAPs,:) - newPositions(lpNPs,:);
       
        if( abs(dX(1))<1 && abs(dX(2))<1 ) % Found ongoing spot
            activeLifetimes(lpAPs) = activeLifetimes(lpAPs)+1;
            newPositions(lpNPs,:) = [];
            flagMatched = true;
            break;
        end
      end
      
      if (flagMatched == false) % No match means spot is finished
        finishedPositions = [finishedPositions;activePositions(lpAPs)];
        finishedLifetimes = [finishedLifetimes;activeLifetimes(lpAPs)];
        
        activePositions(lpAPs,:) = [];
        activeLifetimes(lpAPs) = [];
        target = target-1;
      else % If a match was found, and hence the lifetime incremented
          lpAPs = lpAPs + 1;
      end
      
    end
    
    % Append new spots, if not ongoing, to active list
    activePositions = [activePositions;newPositions];
    activeLifetimes = [activeLifetimes;newLifetimes];
    
    waitbar(lpFrame/numberOfFiles);
end

figure(3)
hist(finishedLifetimes,max(finishedLifetimes))
xlabel('Spot Lifetime (frames)', 'fontSize',12, 'fontWeight','bold')
ylabel('Number of spots', 'fontSize',12, 'fontWeight','bold')
set(gca, 'fontSize',12, 'fontWeight','bold')