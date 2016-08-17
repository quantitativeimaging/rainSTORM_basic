% Plot Quality Control Data for Localisations
function flagHistsPlotted = rainSTORM_histograms(flagHistsPlotted)
% Copyright 2012. Refer to 00_license.txt for details.

% 1. Read inputs
% Load localisation parameters from 'base' workspace
SupResParams = evalin('base','SupResParams');
newThresh    = evalin('base','newThresh');
newPrecision = evalin('base','newPrecision'); % Allowed localisation error
newSig       = evalin('base','newSigma');

% 2. Plot graphs
% Create a new figure, of reasonable size:
scrsz = get(0,'ScreenSize');
figSize = [1,100, min(1120, scrsz(3)-1 ), min(840, scrsz(4)-100) ];

figHistsHandle = figure('OuterPosition', ...
    figSize ,'Name','Histograms', ...
    'NumberTitle','off');
assignin('base','figHistsHandle',figHistsHandle)

% Histogram of counts associated with localisations, in 3x3 pixel centres
% Determine bar chart data:
[myN,myCounts] = hist(SupResParams(:,1),50); % Get Hist data
myCountsGood = myCounts(myCounts>newThresh );
myNGood      = myN(myCounts>newThresh );
myCountsBad  = myCounts(myCounts<=newThresh );
myNBad       = myN(myCounts<=newThresh );

% subplot(2,2,1) % Use this if screen shape spoils the method below
subplot('Position', [0.07,0.56,0.4,0.4])
hold on
if not(isempty(myNGood))
  bar(myCountsGood,myNGood,'g');
end
if not(isempty(myNBad))
  bar(myCountsBad,myNBad,'FaceColor',[0.4 0.4 0.4]);
end
hold off
title('Candidate Brightness (3x3)', ...
    'fontSize', 12, 'fontWeight', 'bold');
xlabel('Camera counts (in 3x3 centres)', ...
    'fontSize', 12, 'fontWeight', 'bold')
ylabel('Number of Candidates', ...
    'fontSize', 12, 'fontWeight', 'bold');
set(gca, 'fontSize', 12, 'fontWeight', 'bold');


% Second subplot:
% subplot(2,2,2)
subplot('Position', [0.57,0.56,0.4,0.4])

% REMOVED TOLERANCES FIGURE - IT WAS RARELY USEFUL - 17/09/2012
% hist(SupResParams(:,2),50) % Tolerances
% title('Candidate Tolerances', ...
%     'fontSize', 12, 'fontWeight', 'bold');
% set(gca, 'fontSize', 12, 'fontWeight', 'bold');

% Localisations per frame - a more useful plot
flagLocsPerFrame = rainSTORM_LocsPerFrame(0); 


% Third Plot
% Localisation diameters (fitted sigma values)
% New 22/3/2013 - CHECK for some bars "hiding" others, or other bugs
% subplot(2,2,3)
subplot('Position', [0.07,0.04,0.4,0.4])

[myNr,mySigsR] = hist(SupResParams(:,4),50); % Inter-Row direction
[myNc,mySigsC] = hist(SupResParams(:,5),50); % Inter-Column direction

mySigsRG = mySigsR( mySigsR>newSig(1) &  mySigsR<newSig(2) ); % Row good
myNRG    =    myNr( mySigsR>newSig(1) &  mySigsR<newSig(2) ); % Row good
mySigsCG = mySigsC( mySigsC>newSig(1) &  mySigsC<newSig(2) ); % Col good
myNCG    =    myNc( mySigsC>newSig(1) &  mySigsC<newSig(2) ); % Col good

mySigsRB = mySigsR(not( mySigsR>newSig(1) &  mySigsR<newSig(2))); % Row bad
myNRB    =    myNr(not( mySigsR>newSig(1) &  mySigsR<newSig(2))); % Row bad
mySigsCB = mySigsC(not( mySigsC>newSig(1) &  mySigsC<newSig(2))); % Col bad
myNCB    =    myNc(not( mySigsC>newSig(1) &  mySigsC<newSig(2))); % Col bad

hold on
flagBars = [0,0,0]; % To determine arguments for legend
if not(isempty(mySigsRG))
  bar(mySigsRG,myNRG,'r', 'BarWidth', 0.4)
  flagBars(1) = 1;
end
if not(isempty(mySigsCG))
  bar(mySigsCG,myNCG,'b', 'BarWidth', 0.4)
  flagBars(2) = 1;
end
if not(isempty(mySigsRB))
  bar(mySigsRB,myNRB,'FaceColor',[0.4 0.4 0.4], 'BarWidth', 0.4)
  flagBars(3) = 1;
end
if not(isempty(mySigsCB))
  bar(mySigsCB,myNCB,'FaceColor',[0.4 0.4 0.4], 'BarWidth', 0.4)
  flagBars(3) = 1;
end

hold off

title('Fitted Std Devs, Pixel Widths, row-direction is vertical', ...
    'fontSize', 12, 'fontWeight', 'bold');
ylabel('Number of Candidates', 'fontSize', 12, 'fontWeight', 'bold');
if (flagBars(1)==1 && flagBars(2) ==1)     % If there are red and blue bars
  legend('Row-direction','Col-direction'); % Then give a legend for them
end
set(gca, 'fontSize', 12, 'fontWeight', 'bold');


% Fourth Figure
% Thompson localisation precisions
% subplot(2,2,4)
subplot('Position', [0.57,0.04,0.4,0.4])
deltaX = rainSTORM_precision(SupResParams); % ERIC: Note this is now 2D ***

[myNr,myDeltR] = hist(deltaX(:,1),100); % Inter-Row direction
[myNc,myDeltC] = hist(deltaX(:,2),100); % Inter-Column direction

myDeltRG = myDeltR( myDeltR<newPrecision ); % Row good
myNRG    =    myNr( myDeltR<newPrecision ); % Row good
myDeltCG = myDeltC( myDeltC<newPrecision ); % Col good
myNCG    =    myNc( myDeltC<newPrecision ); % Col good

myDeltRB = myDeltR(not( myDeltR<newPrecision )); % Row bad
myNRB    =    myNr(not( myDeltR<newPrecision )); % Row bad
myDeltCB = myDeltC(not( myDeltC<newPrecision )); % Col bad
myNCB    =    myNc(not( myDeltC<newPrecision )); % Col bad


hold on
flagBars = [0,0,0]; % To determine arguments for legend
if not(isempty(myDeltRG))
  bar(myDeltRG,myNRG,'r', 'BarWidth', 0.4)
  flagBars(1) = 1;
end
if not(isempty(myDeltCG))
  bar(myDeltCG,myNCG,'b', 'BarWidth', 0.4)
  flagBars(2) = 1;
end
if not(isempty(myDeltRB))
  bar(myDeltRB,myNRB,'FaceColor',[0.4 0.4 0.4], 'BarWidth', 0.4)
  flagBars(3) = 1;
end
if not(isempty(myDeltCB))
  bar(myDeltCB,myNCB,'FaceColor',[0.4 0.4 0.4], 'BarWidth', 0.4)
  flagBars(3) = 1;
end
hold off

title( {'Thompson Localisation Precisions (nm)'}, ...
    'fontSize', 12, 'fontWeight', 'bold');
ylabel('Number of Candidates', 'fontSize', 12, 'fontWeight', 'bold');
if (flagBars(1)==1 && flagBars(2) ==1)     % If there are red and blue bars
  legend('Row-direction','Col-direction'); % Then give a legend for them
end

xlim([0 150])    % Set x-range to the interesting 0-150 nm region

set(gca, 'fontSize', 12, 'fontWeight', 'bold');

hold off

% set(gca, 'LooseInset', get(gca,'TightInset'))
% set(gcf, 'border', 'tight')

% Record the hist figure on the base workspace
figHistsImage = getframe(figHistsHandle); 
figHistsImage = figHistsImage.cdata;
assignin('base', 'figHistsImage', figHistsImage);
assignin('base', 'flagLocsPerFrame', flagLocsPerFrame);


flagHistsPlotted = 1; % Return flag to say that histograms exist

end