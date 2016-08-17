% ColormapInterpolator
% by Mark Deimund 16/05/11


function map = rainSTORM_colormap(color)         

% % Input RGB values for the desired colormap into 'colors' matrix.
colors = [   0   0   0;     % Black
             color;         % Desired intermediate color(s)
             1   1   1];    % White
         
% Select the number of points required for the colormap.    
xx = length(colormap);

%Define 'map' size,
map = zeros(xx,3);

% Carry out interpolation for each range (between fixed colors).
range = size(colors,1) - 1;
intervalwidth = ((xx-1)/range);

for lpRange = 1:range;

    %Slope for interpolation
    m = (colors(lpRange+1,:) - colors(lpRange,:)) ./ intervalwidth;

    % Interpolate between endpoints in each range.    
    for lpPoint = 1:intervalwidth;
        % Assign RGB values to each place in the colormap vector.
       map(floor(lpPoint+intervalwidth*(lpRange-1)),:) = m * (lpPoint-1) + colors(lpRange,:);
       map(ceil(lpPoint+intervalwidth*(lpRange-1)),:) = m * (lpPoint-1) + colors(lpRange,:);  
    end
    
end

map(xx,:) = colors(end,:);

% Display new colormap.
set(imgcf,'Colormap',map);

end