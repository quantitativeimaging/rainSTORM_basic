% rainSTORM_extras_z_view
%
% Visualises 3D localisation data
%
% This script displays "z-sliced" super-resolution images
% It may require some manual adjustment of Z-display ranges
%
% To use:
% 1. Use rainSTORM to "Process Images" (Search / Fit)
% 2. Use rainSTORM Reviewer (Review / Quality Control)
% 3. Run rainSTORM_extras_z_loc (with astigmatism parameters set sensibly)
% 4. Run this script


for lpSlice = 1:6 
zLo = (lpSlice-4) *100; % Define 6 Z-slices arbitrarily (in "nm" )
zHi = zLo + 100;

slicePosits = reviewedPosits( (reviewedPositZ>zLo)&(reviewedPositZ<zHi),:);
sliceParams = reviewedParams( (reviewedPositZ>zLo)&(reviewedPositZ<zHi),:);

% Evaluate a 2D histogram of localisation density, for this Z-slice
[SupResIm] = rainSTORM_recon(slicePosits,sliceParams, ...
             reconstructionScaleFactor,size(myFrame)); 

% Visualise this Z-slice in terms of fluorophore (localisation) density
figNewReconHandle = rainSTORM_display(SupResIm, reconstructionScaleFactor);

end