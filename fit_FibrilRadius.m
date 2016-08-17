% Use fminbnd on the fibril x-section model to estimate cylinder radius.

% Input measured data:
sigmaSqTotal = 8.3^2;  % nm^2  
                      % Blur. From Thompson + Kernel smoothing
obsSigma     = 18;    % nm    Standard deviation of x-section (in image.)


[x,fval] = fminbnd( @(x) findSecMoment(x,sigmaSqTotal, obsSigma), 0,120 )

% listResids = zeros(100,1);
% for lp = 1:100;
%    listResids(lp) =  findSecMoment(lp,sigmaSqTotal, obsSigma);
% end

%% 
% Make graphs look nice
%
figure(1)
plot(xCentres,nData, 'lineWidth',2)

xlim([-30 30])
ylim([0 0.07])
set(gca,'fontSize',14)
xlabel('x, nm','fontSize',14)
ylabel('Fluorophore density','fontSize',14)

% set(gca, 'XTick', []);
set(gca, 'YTick', []);
set(gcf,'Position',[100,100,300,250]); % 720 px wide, 600 high
set(gcf,'color','w')

%
figure(2)
plot(xCentres,vData)

xlim([-40 40])

xlabel('x, nm','fontSize',14)
ylabel('Visualised density','fontSize',14)

set(gca, 'YTick', []);
set(gcf,'Position',[100,100,300,250]); % 720 px wide, 600 high
set(gcf,'color','w')

% 
blurDataLoc = exp(-((xCentres.^2)./(2*100)) ); % Precision only
blurDataVis = exp(-((xCentres.^2)./(2*169)) ); % Precision AND opt visual.

figure(3)
plot(xCentres,blurDataLoc, 'b', 'lineWidth',2)
hold on
  plot(xCentres,blurDataVis, 'k--')
hold off

xlim([-30 30])
ylim([0 1.16])

xlabel('x, nm','fontSize',14)
ylabel('Localisation density','fontSize',14)
% legend('Precision', 'Visualisation','fontSize',12);


set(gca,'fontSize',14)
set(gca, 'YTick', []);
set(gcf,'Position',[100,100,300,250]); % 720 px wide, 600 high
set(gcf,'color','w')

% Histogram of fibril diameters
figure(4)
hist(myDiams,5:10:100);
xlabel('Fitted fibril diameter, nm','fontSize',14)
ylabel('Number','fontSize',14)
xlim([0 120])

set(gca, 'XTick', [0,20,40,60,80,110]);
set(gca,'fontSize',18)
set(gcf,'Position',[100,100,300,250]); % 720 px wide, 600 high
set(gcf,'color','w')

% Histogram of super-res FWHM
figure(5)
hist(myFWHM,5:10:150);
xlabel('Super-resolved FWHM, nm','fontSize',14)
ylabel('Number','fontSize',14)
xlim([0 150])

set(gca, 'XTick', [0,50,100,150]);
set(gca,'fontSize',18)
set(gcf,'Position',[100,100,300,250]); % 720 px wide, 600 high
set(gcf,'color','w')

