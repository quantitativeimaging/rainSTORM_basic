% rainSTORM_extras_makeSUMvideo
%
% Eric Rees. Version 1.0 (development, 9/4/2014)
%
% Makes a video illustating the fluorescence signals that are 
%  accepted to make a super-resolution image - showing these images 
%  at their original size rather than at localised size
%
% Use all the "reviewedPosits"
% 
% To use:
%   Run once with "flagSaveImages = 0"
%   Then run again with "flagSaveImages = 1"

flagSaveImages = 0;


if(flagSaveImages)
 mkdir('mySUMvideo'); % Create a folder to hold output files
end


% figure

for lpFrm = 2:2:300

% Apply quality control, and select fits from a range of frames
theseSupResPosits = reviewedPosits( (reviewedParams(:,7)>0 ) &...
                                    (reviewedParams(:,7)<lpFrm )  ... 
                                   ,:); % Read all columns of Posits
 
theseSupResParams = reviewedParams( (reviewedParams(:,7)>0 ) &...
                                    (reviewedParams(:,7)<lpFrm )  ... 
                                   ,:); % Read all columns of Params

cmImage = zeros(sizeOfFrame); % Empty "cumulative image"
myBlobX = meshgrid([-3:3]);   % For adding each spot to image
myBlobY = meshgrid([-3:3])';

 for lpLoc = 1:size(theseSupResPosits,1)
     
  myPosit = floor( theseSupResPosits(lpLoc,:) );
     
  if ( myPosit(1)<4 || myPosit(2)<4 || ...
       myPosit(1)>(sizeOfFrame(1)-3) || myPosit(2)>(sizeOfFrame(2)-3) )
    continue; % Skip over positions if blob would extend outside cmImage
  end
  
  myBlob = theseSupResParams(lpLoc,3) .* ...  % Brightness
            exp(- myBlobY.^2 / (2*theseSupResParams(lpLoc,4)^2) ) .* ...
            exp(- myBlobX.^2 / (2*theseSupResParams(lpLoc,5)^2) );
  
  cmImage( myPosit(1)-3:myPosit(1)+3 , myPosit(2)-3:myPosit(2)+3  ) = ...
  cmImage( myPosit(1)-3:myPosit(1)+3 , myPosit(2)-3:myPosit(2)+3  ) +...
         myBlob;
  % Elementwise binning. Not very elegant, I admit.
 end % End of allocating dyes to pixels of the reconstruction

   imagesc(cmImage)
   colormap(jet)
   % drawnow
    if(flagSaveImages)
     cmImage = cmImage./myFinalCaxis(2);
     myIm = getframe(gcf);
     myIm = myIm.cdata;
     imwrite(cmImage, ['mySUMvideo/SumVid', int2str(lpFrm), '.png'],'png')
    end
end

myFinalCaxis = caxis;