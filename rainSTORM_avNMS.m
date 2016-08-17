function [myPixels]=rainSTORM_avNMS(myFrame,rad)
% Copyright 2012. Refer to 00_license.txt for details.

persistent avNMSim Gtr mask myRR myRC; % Does this minimise memory calls? 
% 1(a) Averaging. Create averaged image for non-max suppression:
% These 9 matrix additions are equivalent to conv(ones(3)). Neglect edge.
avNMSim = (myFrame);
avNMSim(1:end-1, :)=avNMSim(1:end-1, :) + myFrame(2:end,:);
avNMSim(2:end, :)  =avNMSim(2:end, :)   + myFrame(1:end-1,:);
avNMSim(:, 1:end-1)=avNMSim(:, 1:end-1) + myFrame(:,2:end);
avNMSim(:, 2:end)  =avNMSim(:, 2:end)   + myFrame(:, 1:end-1);
avNMSim(1:end-1,1:end-1) = avNMSim(1:end-1,1:end-1) + myFrame(2:end,2:end);
avNMSim(1:end-1,2:end) = avNMSim(1:end-1,2:end) + myFrame(2:end,1:end-1);
avNMSim(2:end,1:end-1) = avNMSim(2:end,1:end-1) + myFrame(1:end-1,2:end);
avNMSim(2:end,2:end) = avNMSim(2:end,2:end) + myFrame(1:end-1,1:end-1);

% 1(b) Non-maximum suppression
% Create a logical mask with true values at local maxima. Neglect border.
myRR = rad+1:size(myFrame,1)-rad; % Range of rows within border 
myRC = rad+1:size(myFrame,2)-rad; % Range of cols within border
Gtr = false([size(avNMSim),8] );
Gtr(myRR,myRC,1) = avNMSim(myRR,myRC) >  avNMSim(myRR,myRC+1);
Gtr(myRR,myRC,2) = avNMSim(myRR,myRC) >= avNMSim(myRR,myRC-1);
Gtr(myRR,myRC,3) = avNMSim(myRR,myRC) >  avNMSim(myRR+1,myRC);
Gtr(myRR,myRC,4) = avNMSim(myRR,myRC) >= avNMSim(myRR-1,myRC);
Gtr(myRR,myRC,5) = avNMSim(myRR,myRC) >= avNMSim(myRR-1,myRC-1);
Gtr(myRR,myRC,6) = avNMSim(myRR,myRC) >= avNMSim(myRR-1,myRC+1);
Gtr(myRR,myRC,7) = avNMSim(myRR,myRC) >  avNMSim(myRR+1,myRC-1);
Gtr(myRR,myRC,8) = avNMSim(myRR,myRC) >  avNMSim(myRR+1,myRC+1);

mask = Gtr(:,:,1)&Gtr(:,:,2)&Gtr(:,:,3)&Gtr(:,:,4)&...
       Gtr(:,:,5)&Gtr(:,:,6)&Gtr(:,:,7)&Gtr(:,:,8);

% 1(c) Return myPixels=[rows,cols, intensities] of local maxima,
%      I suggest that we then threshold and sort these values.
[myRows,myCols] = find(mask);
idx = sub2ind(size(mask),myRows,myCols);
myIntens = avNMSim(idx);  % Divide by 9 to return mean smoothed peak value

myPixels = [myRows,myCols,myIntens];
end