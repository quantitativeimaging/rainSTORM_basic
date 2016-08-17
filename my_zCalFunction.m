function F = my_zCalFunction(xx,xData)

mySigRsqr = xData(1,:);
myEpsilon = xData(2,:);

mySig0 = xx(1);
myZR   = xx(2);
myGamma= xx(3);

F = zeros(1,size(xData,2)); % Allocate memory for Z posits

for lpDat = 1:length(F)
  if(myEpsilon(lpDat) <= 1)
    F(lpDat) = (myZR/mySig0)*sqrt( (mySigRsqr(lpDat)/myEpsilon(lpDat)^2) ...
                 - mySig0^2 )...
                - myGamma;
  
  else % For myEpsillon(lpDat) > 1
    F(lpDat) = - (myZR/mySig0)*sqrt( (mySigRsqr(lpDat)*myEpsilon(lpDat)^2) ...
                 - mySig0^2 )...
                + myGamma;
  end
end


end