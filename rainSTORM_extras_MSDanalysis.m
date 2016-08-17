% rainSTORM_extras_MSDanalysis.m 
% Eric Rees, May 2013
%
% FUNCTION
%   Script to analyse Mean Square Displacements, hence Brownian Diff Coeffs
%   By processing trajectory data from Localisation Microscopy
%   
%  
% USING THIS SCRIPT
%   1. Run rainSTORM "Process Images" from the main GUI
%   2. Run Reviewer to do quality control, producing reviewedPosits
%   3. Select boxedPosits from reviewedPosits (or transcribe all data)
%   4. Run Trajectory Fitting
%   5. Ensure camera cyle time is defined OK (it is hard-coded below)
%   6. Run this MSD (Mean Squared Displacement) analysis
%      - One may: Evaluate current cell
%
% FURTHER WORK TO TRY:
%   1. Use trajectories to reprocess data to mitigate persistent images
%      Need a name for this - "Smudging" / "Desmudging"
%   2. Jittered historgram visualisation (based on Silverman)
%
% NOTES
%   The input data are selected localisations (boxedPositions) 
%     and the corresponding trajectN which associate them in trajectories
%   Note that there is no guarantee that these trajectories were 
%     correctly identified - so the user must apply some judgement
% 


% 1. INPUTS
%   Localisations and associated trajectories should be available
%   Camera cycle time, bewteen consecutive exposure starts, is needed
tFrame = 0.034;         % E.g. 40 ms Cycle time

% pixelWidth =160       % Should be set from rainSTORM main GUI
% numberOfTrajectories  % Should be set from _trajectoryFitting
% msdOfTracks = zeros(numberOfTrajectories,3); % Dummy data for MSDs 


% 2. PROCESS
%   Determine Mean Square Displacements of trajectories
for lpTracks = 1:numberOfTrajectories

 data = boxedPosits(trajectN == lpTracks,:);
 
 % Calculate MSDs of each Track, and store these in a cell array
 nData = size(data,1); %# number of data points
 numberOfDeltaT = floor(nData/1)-1; % Saxon book suggests up to 1/4 of data
 msd = zeros(numberOfDeltaT,3); %# We'll store [mean, std, n]
 %# calculate msd for all deltaT's
 for dt = 1:numberOfDeltaT
    deltaCoords = data(1+dt:end,1:2) - data(1:end-dt,1:2);
    squaredDisplacement = sum(deltaCoords.^2,2); %# dx^2+dy^2  % +dz^2
 
    msd(dt,1) = mean(squaredDisplacement);   % average
    msd(dt,2) = std(squaredDisplacement);    % std
    msd(dt,3) = length(squaredDisplacement); % number of (not indep) steps
 end

 msdOfTracks{lpTracks} = msd;

end

% Plot msds and 
% Calculate average msd of all tracks - not really optimised here
longestTrack = max(trajectoryDurations)-1; % From Trajectory fitting
listOfMsds   = zeros(numberOfTrajectories,longestTrack); % 
avMsds       = zeros(longestTrack,1);

% 3. OUTPUT
%   Plot MSD versus time for each measured trajectory
myPlot3 = figure(5);

hold on
for lpTracks = 1:numberOfTrajectories
    
    msd = msdOfTracks{lpTracks};
    
    plot( ((1:size(msd,1))*tFrame), ...
    msd(:,1) * (pixelWidth/1000)^2 ,'color',[0.3 0.3 0.3],'LineWidth',1); 
    
    if(~isempty(msd))
     listOfMsds(lpTracks,1:size(msd,1)) = msd(:,1);
    end
end

for lpLen = 1:longestTrack % Note trajectDurations 2 = gap 1
 avMsds(lpLen) = sum(listOfMsds(:,lpLen)) * (pixelWidth/1000)^2 ...
     /sum(trajectoryDurations >lpLen);
 
end
handleLine1 = plot( (1:longestTrack)*tFrame, avMsds, 'b--','LineWidth',4);

hold off

xlabel('Time / s', 'fontsize',18)
ylabel('MSD  / \mu{}m^2 ', 'fontsize',18)
title('Mean Squared Displacements', 'fontsize',18)
legend(handleLine1,'Average')

set(gca,'FontSize',18,'fontweight','bold');
set(myPlot3,'Position',[100,100,600,400]); % 720 px wide, 600 high
set(myPlot3,'color','w')

% FURTHER OUTPUT
%   Determine a best-fit diffusivity from some average of the MSD-t lines
%   Note that fitting a line is an early attempt at this. 
% Attempt 1:
%   Fit a line to the first quarter of the times in the MSD plot
%   First quarter is suggested by [Saxon]. 
%   For very short series, try using more time-delay points...

myLim = floor(longestTrack/4);
if     (longestTrack < 4)
         myLim = longestTrack;
elseif (longestTrack<8)
         myLim = floor(longestTrack/2);
end

myLine = polyfit( (1:myLim )*tFrame, avMsds(1:myLim)', 1); % y = a_1*x +a_2
myDifCoefEst = myLine(1)/4 % In microns squared per second. 4D in 2 dim.
