function figNewReconHandle = rainSTORM_display(SupResIm, linMag)
% rainSTORM_display
% Copyright 2012. Refer to 00_license.txt for details.
% This script displays a localisation density histogram in a MATLAB figure
% Optionally, a scalebar is plotted.
% To manually select a scalebar (or not), edit flagSB in the base workspace

% SupResIm is the Simple Histogram visualsation of localisation density
% linMag is the factor for sub-dividing pixel widths
%     linMag is the "reconstructionScaleFactor" for reviewed images
%     linMag is set by "prevSF" for the preview (5 is hardcoded - often OK)
flagSB = evalin('base','flagSB');          % Flag whether to plot scalebar
pixelWidth = evalin('base', 'pixelWidth'); % Pixel width, on sample, nm

scaleBarLn = 1000/pixelWidth; % Length for a 1 micron scalebar
% % scaleBarLn=6.25;          % E.g. 6.25 for 1 micron at 160nm/pixel

% BRACKET THIS WITH IF OR CASE STATEMENTS, FOR ALTERNATIVE VISUALISATION
% For a Simple Histogram visualisation (as the on-screen figure)
figNewReconHandle = figure;
imshow(SupResIm, 'border', 'tight')
% For a Jittered Histogram, call rainSTORM_reconJH() and plot
% Need to thread linMag through as an argument - variable origins
%
     
hold on
caxis([min(SupResIm(:)) max(SupResIm(:))]);
colormap(hot); % Default colormap - can be changed in Reviewer
    
if(flagSB) 
  plot([max(xlim) (max(xlim)-scaleBarLn*linMag)]-10, ...
        [max(ylim)*0.9 max(ylim)*0.9],'w-','LineWidth',3);
  text((max(xlim)-1.0*scaleBarLn*linMag - 14), ...
      (max(ylim)*0.90 -18),'1 µm','FontSize',12,'Color','w');
end

hold off

assignin('base','linMag',linMag); % Most recent linMag: to save sumImage
assignin('base','scaleBarLn',scaleBarLn); % In case this is needed...
% Function returns figNewReconHandle; this the visualisation figure number 
end